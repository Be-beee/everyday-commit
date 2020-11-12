//
//  MainController.swift
//  Everyday_Commit
//
//  Created by 서보경 on 2020/11/10.
//

import UIKit

class MainController: UIViewController {

    @IBOutlet weak var commitHistoryView: UICollectionView!
    
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImg.layer.cornerRadius = userImg.frame.height/2

        if let id = UserInfoManager.user?.login, let img = UserInfoManager.user?.avatar_url {
            userId.text = id
            userImg.image = urlToImage(from: img)
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
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "historyCell", for: indexPath) as? HistoryCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "listHeader", for: indexPath) as? ListHeaderView else {
                return UICollectionReusableView()
            }
            
            return header
            
        case UICollectionView.elementKindSectionFooter:
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "listFooter", for: indexPath) as? ListFooterView else {
                return UICollectionReusableView()
            }
            
            return footer
        default:
            return UICollectionReusableView()
        }
    }
}

class HistoryCell: UICollectionViewCell {
    @IBOutlet weak var contentsLabel: UILabel!
    
}

class ListHeaderView: UICollectionReusableView {
    @IBOutlet weak var sectionTitleLabel: UILabel!
    @IBOutlet weak var numOfContributes: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ListFooterView: UICollectionReusableView {
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func showMoreContributions(_ sender: UIButton) {
    }
    
}
