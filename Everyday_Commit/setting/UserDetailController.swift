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
    override func viewDidLoad() {
        super.viewDidLoad()
        userImage.layer.cornerRadius = userImage.frame.height/2
        if let imgUrl = UserInfoManager.user?.avatar_url {
            userImage.image = urlToImage(from: imgUrl)
        }
        userIdLabel.text = UserInfoManager.user?.login
        userDescriptionLabel.text = UserInfoManager.user?.bio
        setLightModeOnly()
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

}
