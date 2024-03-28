//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Apple on 11.08.1444 (AH).
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
       let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.layer.cornerRadius = 40
        imageview.layer.masksToBounds = true
        return imageview
    }()
    
    private let userNameLb: UILabel = {
       let lb = UILabel()
        lb.numberOfLines = 1
        lb.font = .systemFont(ofSize: 21, weight: .semibold)
        return lb
    }()
    
    private let userMessageLb: UILabel = {
       let lb = UILabel()
        lb.numberOfLines = 0
        lb.textColor = .gray
        lb.font = .systemFont(ofSize: 19, weight: .regular)
        return lb
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLb)
        contentView.addSubview(userMessageLb)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 80, height: 80)
        userNameLb.frame = CGRect(x: userImageView.traling + 10,
                                  y: 15,
                                  width: contentView.width - 20 - userImageView.width,
                                  height: (contentView.height - 20)/2)
        userMessageLb.frame = CGRect(x: userImageView.traling,
                                  y: userNameLb.bottom + 10,
                                  width: contentView.width - 20 - userImageView.width,
                                  height: (contentView.height - 20)/2)
        
    }
    
    public func configure(with model: Conversation) {
        self.userNameLb.text = model.name
        self.userMessageLb.text = model.lastestMessage.message
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadUrl(for: path) {[weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print("failed to download image from database : \(error)")
            }
        }
    }
}
