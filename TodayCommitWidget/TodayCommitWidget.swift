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
            if let data = data, let decodedData = try? JSONDecoder().decode(UserInfo.self, from: data) {
//                self.user = decodedData
                print(decodedData.login)
                completion(decodedData)
                return
            }
         
            print(error?.localizedDescription ?? "ERROR !")
        }
        dataTask.resume()
    }
}

struct Provider: TimelineProvider {
    var networkManager = NetworkManager()
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), id: "None")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), id: "None")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        if let token = UserDefaults(suiteName: "group.com.sbk.todaycommit")?.string(forKey: "token") {
            networkManager.fetchData(token: token) { (data) in
                let entries = [
                    SimpleEntry(date: Date(), id: data.login)
                ]
                let timeline = Timeline(entries: entries, policy: .never)
                completion(timeline)
            }
        } else {
            let currentDate = Date()
            for secOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .second, value: secOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, id: "None")
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
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
        TodayCommitWidgetEntryView(entry: SimpleEntry(date: Date(), id: "User Id"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
