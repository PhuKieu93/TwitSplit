//
//  MessageTableViewCell.swift
//  TwitSplit
//
//  Created by Kieu Minh Phu on 4/3/18.
//  Copyright © 2018 Kieu Minh Phu. All rights reserved.
//

import UIKit

struct SendMessageTableCellItem {
    var message: String?
    var showBubbleTail: Bool?
}

class SendMessageTableViewCell: UITableViewCell {

    lazy var messageLabel = UILabel()
    lazy var bubbleView = UIView()
    lazy var bubbleImageView = UIImageView()
    
    var cellItem: SendMessageTableCellItem? {
        
        didSet {
            self.setData()
        }
    }
    
    // MARK: Init
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initializeUI() {
        
        self.backgroundColor = .clear
        
        // bubbleView
        self.bubbleView.layer.cornerRadius = 17
        self.bubbleView.layer.masksToBounds = true
        self.bubbleView.backgroundColor = TwitColor.blue.havelockBlue
        self.bubbleView.isHidden = true
        self.addSubview(self.bubbleView)
        
        // bubble imageview
        let image = UIImage(named: "bubble_sent")
        self.bubbleImageView.image = image?.resizableImage(withCapInsets: UIEdgeInsetsMake(17, 21, 17, 21), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
        self.bubbleImageView.tintColor = TwitColor.blue.havelockBlue
        self.bubbleImageView.isHidden = true
        self.addSubview(self.bubbleImageView)
        
        // messageLabel
        self.messageLabel.font = UIFont.systemFont(ofSize: 15)
        self.messageLabel.numberOfLines = 0
        self.messageLabel.textColor = .white
        self.addSubview(self.messageLabel)
        
        // Set constraint layout
        self.messageLabel.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.width.lessThanOrEqualTo(strongSelf).multipliedBy(2/3.0)
            maker.top.equalTo(strongSelf).offset(7)
            maker.right.equalTo(strongSelf).offset(-16)
            maker.bottom.equalTo(strongSelf).offset(-7)
        }
        
        self.bubbleView.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.left.equalTo(strongSelf.messageLabel).offset(-8)
            maker.top.equalTo(strongSelf.messageLabel).offset(-5)
            maker.bottom.equalTo(strongSelf.messageLabel).offset(5)
            maker.right.equalTo(strongSelf.messageLabel).offset(8)
        }
        
        self.bubbleImageView.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.left.equalTo(strongSelf.messageLabel).offset(-8)
            maker.top.equalTo(strongSelf.messageLabel).offset(-5)
            maker.bottom.equalTo(strongSelf.messageLabel).offset(5)
            maker.right.equalTo(strongSelf.messageLabel).offset(12)
        }
    }
    
    // MARK: Set data
    func setData() {
        
        self.bubbleImageView.isHidden = !(self.cellItem?.showBubbleTail ?? false)
        self.bubbleView.isHidden = self.cellItem?.showBubbleTail ?? false
        
        self.messageLabel.text = self.cellItem?.message
    }
    
    override func prepareForReuse() {
        self.messageLabel.text = nil
        self.bubbleView.isHidden = true
        self.bubbleImageView.isHidden = true
    }
}
