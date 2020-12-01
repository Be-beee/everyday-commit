//
//  TodayCommitWidget.swift
//  TodayCommitWidget
//
//  Created by 서보경 on 2020/11/13.
//

import WidgetKit
import SwiftUI

class NetworkManager: NSObject, XMLParserDelegate {
    var userData = UserInfo(id: "None", today_count: 0)
    init(id: String) {
        userData.id = id
    }
    func fetchData(id: String, completion: @escaping (UserInfo) -> Void) {
        guard let url = URL(string: "https://github.com/users/\(id)/contributions") else {
            print("Please check URL")
            return
        }
        guard let xmlParser = XMLParser(contentsOf: url) else { return }
        xmlParser.delegate = self
        xmlParser.parse()
        completion(userData)
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "rect" {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let today = df.string(from: Date())
            if let date = attributeDict["data-date"], let count = attributeDict["data-count"], date == today  {
                userData.today_count = Int(count) ?? 0
                parser.abortParsing()
            }
        }
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> UserEntry {
        UserEntry(date: Date(), today: "0 contributions")
    }

    func getSnapshot(in context: Context, completion: @escaping (UserEntry) -> ()) {
        let entry = UserEntry(date: Date(), today: "0 contributions")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        if let id = UserDefaults(suiteName: "group.com.sbk.todaycommit")?.string(forKey: "userID") {
            let networkManager = NetworkManager(id: id)
            networkManager.fetchData(id: id) { (data) in
                let entries = [
                    UserEntry(date: Date(), today: String(data.today_count))
                ]
                let timeline = Timeline(entries: entries, policy: .never)
                completion(timeline)
            }
        } else {
            var entries: [UserEntry] = []
            let currentDate = Date()
            for secOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .second, value: secOffset, to: currentDate)!
                let entry = UserEntry(date: entryDate, today: "0 contributions")
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
}

struct UserEntry: TimelineEntry {
    let date: Date
    let today: String
}

struct UserInfo {
    var id: String
    var today_count: Int
}

struct TodayCommitWidgetEntryView : View {
    var entry: Provider.Entry
    @State var user: UserInfo?

    var body: some View {
        if let _ = UserDefaults(suiteName: "group.com.sbk.todaycommit")?.string(forKey: "userID") {
            VStack {
                Text("Today's Contributions").bold()
                Text("")
                Text("🌳 "+entry.today)
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
        TodayCommitWidgetEntryView(entry: UserEntry(date: Date(), today: "# of contributions"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
