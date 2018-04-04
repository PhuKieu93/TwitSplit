//
//  MessageViewController.swift
//  TwitSplit
//
//  Created by Kieu Minh Phu on 4/3/18.
//  Copyright © 2018 Kieu Minh Phu. All rights reserved.
//

import UIKit

class MessageViewController: BaseViewController {

    @objc lazy var typeTextView = UIView()
    lazy var textField = UITextField()
    lazy var sendButton = UIButton()
    lazy var messageTableView = UITableView()
    
    fileprivate var cellItems = [Any]()
    
    fileprivate var sendTextColor = UIColor.white
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initializeUI()
        self.setWhiteSpaceTableView()
        
        self.addObserver(self, forKeyPath: "typeTextView.bounds", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Init UI
    func initializeUI() {
        self.title = "Message"
        self.view.backgroundColor = .white
        
        // typeTextView
        self.typeTextView.backgroundColor = .white
        self.view.addSubview(self.typeTextView)
        
        // textField
        self.textField.placeholder = "Start a message"
        self.textField.borderStyle = .roundedRect
        self.typeTextView.addSubview(self.textField)
        
        // send button
        self.sendButton.setTitle("Send", for: .normal)
        self.sendButton.setTitleColor(TwitColor.blue.havelockBlue, for: .normal)
        self.sendButton.addTarget(self, action: #selector(self.sendButtonTapped(button:)), for: .touchUpInside)
        self.typeTextView.addSubview(self.sendButton)
        
        // table view
        self.messageTableView.allowsSelection = false
        self.messageTableView.separatorStyle = .none
        self.messageTableView.rowHeight = UITableViewAutomaticDimension
        self.messageTableView.estimatedRowHeight = 200
        self.messageTableView.register(SendMessageTableViewCell.self, forCellReuseIdentifier: "sendCell")
        self.messageTableView.register(ReceiveMessageTableViewCell.self, forCellReuseIdentifier: "receiveCell")
        self.messageTableView.register(UITableViewCell.self, forCellReuseIdentifier: "whiteSpaceCell")
        self.messageTableView.dataSource = self
        self.messageTableView.delegate = self
        self.view.addSubview(self.messageTableView)
        
        // Set constraint layout
        self.typeTextView.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.height.equalTo(50)
            maker.left.right.bottom.equalTo(strongSelf.view)
        }
        
        self.textField.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.left.top.equalTo(strongSelf.typeTextView).offset(8)
            maker.bottom.equalTo(strongSelf.typeTextView).offset(-8)
        }
        
        self.sendButton.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.left.equalTo(strongSelf.textField.snp.right).offset(8)
            maker.centerY.equalTo(strongSelf.textField)
            maker.width.equalTo(45)
            maker.right.equalTo(strongSelf.view).offset(-8)
        }
        
        self.messageTableView.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.left.top.right.equalTo(strongSelf.view)
            maker.bottom.equalTo(strongSelf.typeTextView.snp.top)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "typeTextView.bounds" {
            self.typeTextView.addTopBorder(color: .groupTableViewBackground, width: 1)
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    func setWhiteSpaceTableView() {
        
        // add top tableview with 20pt
        self.cellItems.append(CGFloat(20.0))

        // add bottom tableview with 20pt
        self.cellItems.append(CGFloat(20.0))
    }
    
    // MARK: Action
    @objc func sendButtonTapped(button: UIButton) {
        
        if let text = self.textField.text, text != "" {
            self.textField.text = nil
            self.sendMessage(text)
//            self.recieveMessage(text)
        }
    }
    
    func sendMessage(_ message: String) {
        
        let limit = 50
        var indexPaths = [IndexPath]()
        
        // Change bubble UI of last message
        if let cellItem = self.cellItems[self.cellItems.count - 2] as? SendMessageTableCellItem {
            var newItem = cellItem
            newItem.showBubbleTail = false
            self.cellItems[self.cellItems.count - 2] = newItem
            
            self.messageTableView.reloadRows(at: [IndexPath(item: self.cellItems.count - 2, section: 0)], with: .none)
        }
        
        // Add new message
        if message.count <= limit {
            self.cellItems.insert(SendMessageTableCellItem(message: message, showBubbleTail: true), at: self.cellItems.count - 1)
            indexPaths.append(IndexPath(item: self.cellItems.count - 2, section: 0))
            
        } else {
            let splitMessages = self.splitMessage(message, limit: limit)
            
            for (index, splitMessage) in splitMessages.enumerated() {
                
                if index == splitMessages.count - 1 {
                    self.cellItems.insert(SendMessageTableCellItem(message: splitMessage, showBubbleTail: true), at: self.cellItems.count - 1)
                } else {
                    self.cellItems.insert(SendMessageTableCellItem(message: splitMessage, showBubbleTail: false), at: self.cellItems.count - 1)
                }
                
                indexPaths.append(IndexPath(item: self.cellItems.count - 2, section: 0))
            }
        }
        
        self.messageTableView.performBatchUpdates({
            self.messageTableView.insertRows(at:indexPaths, with: .fade)
        }, completion: { (finished) in

            if finished {
                self.messageTableView.scrollToRow(at: IndexPath(item: self.cellItems.count - 1, section: 0), at: .bottom, animated: true)
            }
        })
    }
    
    func recieveMessage(_ message: String) {
        
        let limit = 50
        var indexPaths = [IndexPath]()
        
        // Change bubble UI of last message
        if let cellItem = self.cellItems[self.cellItems.count - 2] as? ReceiveMessageTableCellItem {
            var newItem = cellItem
            newItem.showBubbleTail = false
            self.cellItems[self.cellItems.count - 2] = newItem
            
            self.messageTableView.reloadRows(at: [IndexPath(item: self.cellItems.count - 2, section: 0)], with: .none)
        }
        
        // Add new message
        if message.count <= limit {
            self.cellItems.insert(ReceiveMessageTableCellItem(message: message, showBubbleTail: true), at: self.cellItems.count - 1)
            indexPaths.append(IndexPath(item: self.cellItems.count - 2, section: 0))
            
        } else {
            let splitMessages = self.splitMessage(message, limit: limit)
            
            for (index, splitMessage) in splitMessages.enumerated() {
                
                if index == splitMessages.count - 1 {
                    self.cellItems.insert(ReceiveMessageTableCellItem(message: splitMessage, showBubbleTail: true), at: self.cellItems.count - 1)
                } else {
                    self.cellItems.insert(ReceiveMessageTableCellItem(message: splitMessage, showBubbleTail: false), at: self.cellItems.count - 1)
                }
                
                indexPaths.append(IndexPath(item: self.cellItems.count - 2, section: 0))
            }
        }
        
        self.messageTableView.performBatchUpdates({
            self.messageTableView.insertRows(at:indexPaths, with: .fade)
        }, completion: { (finished) in
            
            if finished {
                self.messageTableView.scrollToRow(at: IndexPath(item: self.cellItems.count - 1, section: 0), at: .bottom, animated: true)
            }
        })
    }
    
    // MARK: Split message
    
    func splitMessage(_ message: String, limit: Int) -> [String] {
        
        var output = [String]()
        let subStrings = message.split(separator: " ")
        var string = ""
        var sum = subStrings.first?.count ?? 0
        
        var indexMessage = 1
        var i = 0
        var numberOfMessage = 0
        
        // get minimum number of message
        for i in 1..<subStrings.count {
            
            let subString = subStrings[i]
            let temp = sum + subString.count + 1
            
            // subtract 4 characters (minimum number of characters indicator "@/@ ")
            if temp <= (limit - 4) {
                sum = temp
            } else {
                sum = subString.count
                numberOfMessage += 1
            }
            
            if i == subStrings.count - 1 {
                numberOfMessage += 1
            }
        }
        
        // split message
        string = "\(1)/\(numberOfMessage)"
        
        while i < subStrings.count {
            
            let subString = subStrings[i]
            let temp = string + " \(subString)"
            
            if temp.count <= limit {
                string = temp
            } else {
                indexMessage += 1
                output.append(String(string))
                string = "\(indexMessage)/\(numberOfMessage)" + " \(subString)"
                
                // check if number of message wrong, we increase number of message and re-split message again
                if indexMessage > numberOfMessage {
                    
                    numberOfMessage += 1
                    indexMessage = 1
                    string = "\(1)/\(numberOfMessage)"
                    i = 0
                    output.removeAll()
                    continue
                }
            }
            
            if i == subStrings.count - 1 {
                output.append(String(string))
            }
            
            i += 1
        }
        
        return output
    }
    
    // MARK: Keyboard
    @objc func keyboardWillHide(notification: NSNotification) {
        
        let userInfo = notification.userInfo
        let animationTime = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue ?? 0
        let animationCurve = UInt((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).integerValue ?? 0)
        
        
        UIView.animate(withDuration: animationTime, delay: 0.0, options:  UIViewAnimationOptions(rawValue: animationCurve), animations: {
            
            self.typeTextView.snp.updateConstraints({ [weak self] (maker) in
                
                guard let strongSelf = self else {
                    return
                }
                maker.bottom.equalTo(strongSelf.view)
            })
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo
        let animationTime = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue ?? 0
        let animationCurve = UInt((userInfo?[UIKeyboardAnimationCurveUserInfoKey] as AnyObject).integerValue ?? 0)
        
        var keyboardHeight: CGFloat = 0
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        
        UIView.animate(withDuration: animationTime, delay: 0.0, options:  UIViewAnimationOptions(rawValue: animationCurve), animations: {
            
            self.typeTextView.snp.updateConstraints({ [weak self] (maker) in
                
                guard let strongSelf = self else {
                    return
                }
                maker.bottom.equalTo(strongSelf.view).offset(-keyboardHeight)
            })
            self.view.layoutIfNeeded()
            
            if self.cellItems.count > 0 {
                 self.messageTableView.scrollToRow(at: IndexPath(item: self.cellItems.count - 1, section: 0), at: .bottom, animated: false)
            }
           
            
        }, completion: nil)
    }
}

extension MessageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cellItem = self.cellItems[indexPath.row] as? SendMessageTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendCell", for: indexPath) as! SendMessageTableViewCell
            cell.cellItem = cellItem
            
            return cell
        }
        
        if let cellItem = self.cellItems[indexPath.row] as? ReceiveMessageTableCellItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiveCell", for: indexPath) as! ReceiveMessageTableViewCell
            cell.cellItem = cellItem
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "whiteSpaceCell", for: indexPath)
        cell.backgroundColor = .clear
        
        return cell
    }
}

extension MessageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cellItem = self.cellItems[indexPath.row] as? CGFloat {
            return cellItem
        } else {
            return UITableViewAutomaticDimension
        }
    }
}
