//
//  UserDetailController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/23.
//

import UIKit

class UserDetailController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userIdLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    @IBOutlet weak var userCompanyLabel: UILabel!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userBlogLabel: UILabel!
    @IBOutlet weak var userTwitterLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    var themeDataManager = ThemeDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImage.layer.cornerRadius = userImage.frame.height/2
        if let imgUrl = UserInfoManager.user?.avatar_url {
            userImage.image = urlToImage(from: imgUrl)
        }
        settingUserDetailUI()
        setLightModeOnly()
    }
    func settingUserDetailUI() {
        if let txt = UserDefaults.shared?.string(forKey: "color") {
            dismissButton.setTitleColor(themeDataManager.themeColorDict[txt], for: .normal)
        } else {
            dismissButton.setTitleColor(UIColor.systemGreen, for: .normal)
        }
        
        userIdLabel.text = UserInfoManager.user?.login
        userDescriptionLabel.text = UserInfoManager.user?.bio
        
        if let company = UserInfoManager.user?.company {
            userCompanyLabel.text = "🏢 "+company
        } else {
            userCompanyLabel.isEnabled = false
        }
        
        if let location = UserInfoManager.user?.location {
            userLocationLabel.text = "📌 "+location
        } else {
            userLocationLabel.isEnabled = false
        }
        
        if let email = UserInfoManager.user?.email {
            userEmailLabel.text = "📬 "+email
        } else {
            userEmailLabel.isEnabled = false
        }
        
        if let blog = UserInfoManager.user?.blog {
            userBlogLabel.text = "🔗 "+blog
        } else {
            userBlogLabel.isEnabled = false
        }
        
        if let twitter = UserInfoManager.user?.twitter_username {
            userTwitterLabel.text = "🐦 "+twitter
        } else {
            userTwitterLabel.isEnabled = false
        }
    }
    
    func urlToImage(from url: String) -> UIImage? {
        if let url = URL(string: url) {
            if let imgData = try? Data(contentsOf: url) {
                return UIImage(data: imgData)
            } else {
                return UIImage()
            }
        } else {
            return UIImage()
        }
    }

    @IBAction func dismissUserDetailVC(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
