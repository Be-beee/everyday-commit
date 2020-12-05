//
//  ThemeColorController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/12/04.
//

import UIKit

class ThemeColorController: UIViewController {
    
    @IBOutlet weak var confirmButton: UIButton!
    var themeDataManager = ThemeDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let txt = UserDefaults.shared?.string(forKey: "color") {
            confirmButton.setTitleColor(themeDataManager.themeColorDict[txt], for: .normal)
        } else {
            confirmButton.setTitleColor(UIColor.systemGreen, for: .normal)
        }
    }
    
    @IBAction func closeThemeVC(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ThemeColorController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "COLOR"
        case 1:
            return "EMOJI"
        default:
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return themeDataManager.colorListCount
        case 1:
            return themeDataManager.emojiListCount
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell") as? ThemeCell else {
            return UITableViewCell()
        }
        switch indexPath.section {
        case 0:
            let txt = themeDataManager.themeColor[indexPath.row]
            guard let color = themeDataManager.themeColorDict[txt] else { return cell }
            cell.titleLabel.attributedText = NSAttributedString(string: txt, attributes: [.foregroundColor : color])
            cell.selectedLabel.isHidden = true
        case 1:
            cell.titleLabel.text = themeDataManager.emoji[indexPath.row]
            cell.selectedLabel.isHidden = true
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        if section == 0 {
            let txt = themeDataManager.themeColor[indexPath.row]
            UserDefaults.shared?.set(txt, forKey: "color")
            self.confirmButton.setTitleColor(themeDataManager.themeColorDict[txt], for: .normal)
        } else {
            let emojis = themeDataManager.emoji[indexPath.row].split(separator: " ").map{ String($0) }
            UserDefaults.shared?.set(emojis, forKey: "emoji")
        }
    }
    
}

class ThemeCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var selectedLabel: UILabel!
    
}

class ThemeDataManager {
    var themeColorDict = [
        "Green": UIColor.systemGreen,
        "Orange": UIColor.systemOrange,
        "Pink": UIColor.systemPink,
        "Blue": UIColor.systemBlue,
        "Indigo": UIColor.systemIndigo,
        "Dark Gray": UIColor.darkGray
    ]
    var emoji = ["🕸 🌱 🌿 🌳", "😢 ☺️ 😆 😍", "💔 💛 🧡 ❤️", "🥉 🥈 🥇 🎖", "💥 ⭐️ 💫 ✨"]
    
    var colorListCount: Int {
        return themeColor.count
    }
    var emojiListCount: Int {
        return emoji.count
    }
    
    var themeColor: [String] {
        var arr: [String] = []
        let sorted = themeColorDict.sorted { $0.key < $1.key }
        for (key, _) in sorted {
            arr.append(key)
        }
        return arr
    }
}
