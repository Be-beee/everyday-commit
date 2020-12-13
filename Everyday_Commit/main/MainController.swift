//
//  MainController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/10.
//

import UIKit
import SafariServices

class MainController: UIViewController {

    var userContributions: UserContributions?
    var themeDataManager = ThemeDataManager()
    @IBOutlet weak var commitHistoryView: UICollectionView!
    
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImg.layer.cornerRadius = userImg.frame.height/2
        setLightModeOnly()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activityIndicator.startAnimating()
        if let color = UserDefaults.shared?.string(forKey: "color") {
            view.backgroundColor = themeDataManager.themeColorDict[color]
            self.tabBarController?.tabBar.tintColor = themeDataManager.themeColorDict[color]
        }
        if let id = UserInfoManager.user?.login, let img = UserInfoManager.user?.avatar_url {
            userId.text = id
            userImg.image = urlToImage(from: img)
            callCommitData()
            activityIndicator.stopAnimating()
        } else if let token = UserDefaults.shared?.string(forKey: "token") {
            guard let url = URL(string: ClientLogin.reqUserInfoUrl) else { return }
            var req = URLRequest(url: url)
            req.setValue("token \(token)", forHTTPHeaderField: ClientLogin.userInfoHeader.0)
            UserInfoManager.requestInfo(req, .user) {
                if let id = UserInfoManager.user?.login, let img = UserInfoManager.user?.avatar_url {
                    self.userId.text = id
                    self.userImg.image = self.urlToImage(from: img)
                    self.callCommitData()
                }
                self.activityIndicator.stopAnimating()
            } handlingError: {
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "알림", message: "네트워크 연결 상태를 확인해주세요.", preferredStyle: .alert)
                let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.shared?.string(forKey: "token") == nil {
            guard let loginVC = UIStoryboard(name: "LoginController", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as? LoginController else { return }
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: false, completion: nil)
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
    func callCommitData() {
        guard let id = UserInfoManager.user?.login else { return }
        guard let contributionsUrl = URL(string: "https://github.com/users/\(id)/contributions") else { return }
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: contributionsUrl) { (data, response, error) in
            let success = 200 ..< 300
            guard error == nil, let statusCode = (response as? HTTPURLResponse)?.statusCode, success.contains(statusCode) else { return }
            guard let result = data else { return }
            let parser = ContributionsParser(data: result)
            DispatchQueue.main.async {
                self.userContributions = parser.userContributions
                self.commitHistoryView.reloadData()
            }
        }
        dataTask.resume()
    }
    
}

extension MainController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 60
        
        return CGSize(width: width, height: height)
    }
}

extension MainController: UICollectionViewDelegate {}
extension MainController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = userContributions?.commitHistory.count {
            if count >= 10 {
                return 10
            }
            return count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "historyCell", for: indexPath) as? HistoryCell else {
            return UICollectionViewCell()
        }
        if let date = userContributions?.commitHistory[indexPath.row].date, let count = userContributions?.commitHistory[indexPath.row].count, let score = userContributions?.commitHistory[indexPath.row].score {
            cell.dateLabel.text = date
            
            if let emojis = UserDefaults.shared?.stringArray(forKey: "emoji") {
                cell.contributionsLabel.text = emojis[score]+" "+String(count)
            } else {
                let defaults = themeDataManager.emoji[0].split(separator: " ").map{ String($0) }
                cell.contributionsLabel.text = defaults[score]+" "+String(count)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "listHeader", for: indexPath) as? ListHeaderView else {
                return UICollectionReusableView()
            }
            if let total = userContributions?.total {
                header.numOfContributes.text = String(total)+" contributions"
            }
            return header
            
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "listFooter", for: indexPath) as? ListFooterView else {
                return UICollectionReusableView()
            }
            footer.moreButton.addTarget(self, action: #selector(goToMyGitHub), for: .touchUpInside)
            
            return footer
        default:
            return UICollectionReusableView()
        }
    }
    
    @objc func goToMyGitHub() {
        guard let id = UserInfoManager.user?.login else { return }
        guard let url = URL(string: "https://github.com/\(id)") else { return }
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}

class HistoryCell: UICollectionViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contributionsLabel: UILabel!
}

class ListHeaderView: UICollectionReusableView {
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var numOfContributes: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ListFooterView: UICollectionReusableView {
    @IBOutlet weak var moreButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
