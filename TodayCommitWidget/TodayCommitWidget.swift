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

extension Date {
    
}

struct ThemeData {
    static let defaultEmoji = ["🕸", "🌱", "🌿", "🌳"]
    static let defaultColor = [
        "Green": Color(UIColor.systemGreen),
        "Orange": Color(UIColor.systemOrange),
        "Pink": Color(UIColor.systemPink),
        "Blue": Color(UIColor.systemBlue),
        "Indigo": Color(UIColor.systemIndigo),
        "Dark Gray": Color(UIColor.darkGray)
    ]
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
            df.timeZone = TimeZone.autoupdatingCurrent
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
        let currentDate = Date()
        
        if let id = UserDefaults.shared?.string(forKey: "userID") {
            let parserManager = ParserManager(id: id)
            parserManager.fetchData(id: id) { (data) in
                let entries = addEntries(currentDate, String(data.today_count), data.score)
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        } else {
            let entries: [UserEntry] = addEntries(currentDate, "0", 0)
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }
    
    func addEntries(_ currentDate: Date, _ today: String, _ score: Int) -> [UserEntry] {
        var result: [UserEntry] = []
        for offset in 0 ..< 2 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: offset, to: currentDate)!
            let entry = UserEntry(date: entryDate, today: today, score: score)
            result.append(entry)
        }
        
        return result
    }
}

struct UserEntry: TimelineEntry {
    let date: Date
    let today: String
    let score: Int
    var emoji: String {
        var emoji = ""
        if let emojiArray = UserDefaults.shared?.stringArray(forKey: "emoji") {
            emoji = emojiArray[score]
        } else {
            emoji = ThemeData.defaultEmoji[score]
        }
        return emoji
    }
    var txtColor: Color {
        var colorData = Color(UIColor.systemGreen)
        if let txtColor = UserDefaults.shared?.string(forKey: "color") {
            colorData = ThemeData.defaultColor[txtColor] ?? Color(UIColor.systemGreen)
        }
        return colorData
    }
}


struct TodayCommitWidgetEntryView : View {
    @Environment(\.widgetFamily) private var widgetFamily
    @State var user: UserInfo?
    
    var entry: Provider.Entry
    
    
    
    var body: some View {
        if let _ = UserDefaults.shared?.string(forKey: "userID") {
            switch widgetFamily {
            case .systemSmall:
                ZStack {
                    Color(.white)
                    VStack {
                        Text("Today's Contributions")
                            .bold()
                            .foregroundColor(entry.txtColor)
                        Text("")
                        Text(entry.emoji+" "+entry.today)
                            .foregroundColor(.black)
                    }
                }
            default:
                Text("Default")
            }
        } else {
            ZStack {
                Color.white
                Text("GitHub로\n로그인하기")
                    .bold()
                    .foregroundColor(.black)
                    .lineSpacing(5)
                    .padding()
            }
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
