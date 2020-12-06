//
//  TodayCommitWidget.swift
//  TodayCommitWidget
//
//  Created by 서보경 on 2020/11/13.
//

import WidgetKit
import SwiftUI

extension UserDefaults {
    static var shared: UserDefaults? {
        let shared = UserDefaults(suiteName: "group.com.sbk.todaycommit")
        return shared
    }
}

class ParserManager: NSObject, XMLParserDelegate {
    var userData = UserInfo(id: "None", today_count: 0, score: 0)
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
                if let fill = attributeDict["fill"] {
                    if fill.contains("L1") {
                        userData.score = 1
                    } else if fill.contains("L2") {
                        userData.score = 2
                    } else if fill.contains("L3") || fill.contains("L4") {
                        userData.score = 3
                    } else {
                        userData.score = 0
                    }
                } else {
                    userData.score = 0
                }
                parser.abortParsing()
            }
        }
    }
}

struct UserInfo {
    var id: String
    var today_count: Int
    var score: Int // 0-🕸, 1-🌱, 2-🌿, 3-🌳
}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> UserEntry {
        UserEntry(date: Date(), today: "0 contributions", score: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (UserEntry) -> ()) {
        let entry = UserEntry(date: Date(), today: "0 contributions", score: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        if let id = UserDefaults.shared?.string(forKey: "userID") {
            let parserManager = ParserManager(id: id)
            parserManager.fetchData(id: id) { (data) in
                var entries: [UserEntry] = []
                for minOffset in 0 ..< 2 {
                    let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: Date())!
                    let entry = UserEntry(date: entryDate, today: String(data.today_count), score: data.score)
                    entries.append(entry)
                }
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        } else {
            let entries: [UserEntry] = [UserEntry(date: Date(), today: "0 contributions", score: 0)]
            let timeline = Timeline(entries: entries, policy: .never)
            completion(timeline)
        }
    }
}

struct UserEntry: TimelineEntry {
    let date: Date
    let today: String
    let score: Int
}


struct TodayCommitWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    @State var user: UserInfo?
    
    var entry: Provider.Entry
    var emoji: String {
        var emoji = ""
        if let emojiArray = UserDefaults.shared?.stringArray(forKey: "emoji") {
            emoji = emojiArray[entry.score]
        } else {
            let defaults = ["🕸", "🌱", "🌿", "🌳"]
            emoji = defaults[entry.score]
        }
        return emoji
    }
    var txtColor: Color {
        var colorData = Color(UIColor.systemGreen)
        if let txtColor = UserDefaults.shared?.string(forKey: "color") {
            switch txtColor {
            case "Green":
                colorData = Color(UIColor.systemGreen)
            case "Orange":
                colorData = Color(UIColor.systemOrange)
            case "Pink":
                colorData = Color(UIColor.systemPink)
            case "Blue":
                colorData = Color(UIColor.systemBlue)
            case "Indigo":
                colorData = Color(UIColor.systemIndigo)
            case "Dark Gray":
                colorData = Color(UIColor.darkGray)
            default:
                break
            }
        }
        return colorData
    }
    
    
    var body: some View {
        if let _ = UserDefaults.shared?.string(forKey: "userID") {
            switch widgetFamily {
            case .systemSmall:
                ZStack {
                    Color(.white)
                    VStack {
                        Text("Today's Contributions")
                            .bold()
                            .foregroundColor(txtColor)
                        Text("")
                        Text(emoji+" "+entry.today)
                            .foregroundColor(.black)
                    }
                }
//            case .systemMedium:
//                VStack {
//                    Text("Today's Contributions")
//                        .font(.subheadline)
//                        .padding()
//                    Text(emoji+" "+entry.today)
//                }
            default:
                Text("Default")
            }
        } else {
            Text("로그인이 필요합니다.").padding()
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
        .supportedFamilies([.systemSmall])
    }
}

struct TodayCommitWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayCommitWidgetEntryView(entry: UserEntry(date: Date(), today: "# of contributions", score: 0))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
