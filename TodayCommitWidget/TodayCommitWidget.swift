//
//  TodayCommitWidget.swift
//  TodayCommitWidget
//
//  Created by 서보경 on 2020/11/13.
//

import WidgetKit
import SwiftUI

class NetworkManager {
    func fetchData(token: String, completion: @escaping (UserInfo) -> Void) {
        guard let url = URL(string: "https://api.github.com/user") else {
            print("Please check URL")
            return
        }
         
        var request = URLRequest(url: url)
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            let successRange = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange.contains(statusCode) else { return }
            if let data = data, let decodedData = try? JSONDecoder().decode(UserInfo.self, from: data) {
                completion(decodedData)
                return
            }
        }
        dataTask.resume()
    }
}

struct Provider: TimelineProvider {
    var networkManager = NetworkManager()
    func placeholder(in context: Context) -> UserEntry {
        UserEntry(date: Date(), id: "None")
    }

    func getSnapshot(in context: Context, completion: @escaping (UserEntry) -> ()) {
        let entry = UserEntry(date: Date(), id: "None")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        if let token = UserDefaults(suiteName: "group.com.sbk.todaycommit")?.string(forKey: "token") {
            networkManager.fetchData(token: token) { (data) in
                let entries = [
                    UserEntry(date: Date(), id: data.login)
                ]
                let timeline = Timeline(entries: entries, policy: .never)
                completion(timeline)
            }
        } else {
            var entries: [UserEntry] = []
            let currentDate = Date()
            for secOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .second, value: secOffset, to: currentDate)!
                let entry = UserEntry(date: entryDate, id: "None")
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct UserEntry: TimelineEntry {
    let date: Date
    let id: String
}

struct UserInfo: Codable {
    var login: String
    var name: String
    var avatar_url: String
    var bio: String
    var public_repos: Int
    var updated_at: String
}

struct TodayCommitWidgetEntryView : View {
    var entry: Provider.Entry
    @State var user: UserInfo?

    var body: some View {
        if let _ = UserDefaults(suiteName: "group.com.sbk.todaycommit")?.string(forKey: "token") {
            VStack {
                Text(entry.id)
            }
        } else {
            Text("로그인 해주세요!")
        }
    }
    
}

@main
struct TodayCommitWidget: Widget {
    let kind: String = "TodayCommitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayCommitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct TodayCommitWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayCommitWidgetEntryView(entry: UserEntry(date: Date(), id: "User Id"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
