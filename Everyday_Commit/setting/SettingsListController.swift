//
//  SettingsListController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/20.
//

import UIKit
import MessageUI

class SettingsListController: UITableViewController, MFMailComposeViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            guard let userDetailVC = UIStoryboard(name: "UserDetailController", bundle: nil).instantiateViewController(withIdentifier: "UserDetailController") as? UserDetailController else { return }
            self.navigationController?.pushViewController(userDetailVC, animated: true)
        case 1:
            if indexPath.row == 0 {
                guard let themeVC = UIStoryboard(name: "ThemeColorController", bundle: nil).instantiateViewController(withIdentifier: "ThemeColorController") as? ThemeColorController else { return }
                self.navigationController?.pushViewController(themeVC, animated: true)
            } else {
                let mailComposeVC = configureMailComposer()
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposeVC, animated: true, completion: nil)
                } else {
                    print("이메일을 보낼 수 없습니다.")
                }
            }
        default:
            print("indexPath section: \(indexPath.section), row: \(indexPath.row)")
        }
        
    }
    
    func configureMailComposer() -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        let systemVersion = UIDevice.current.systemVersion
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["maybutter756@gmail.com"])
        mailComposeVC.setSubject("매일 커밋 문의")
        mailComposeVC.setMessageBody("현재 iOS 버전: \(systemVersion)\n문의 및 피드백 감사합니다!:)", isHTML: false)
        
        return mailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
