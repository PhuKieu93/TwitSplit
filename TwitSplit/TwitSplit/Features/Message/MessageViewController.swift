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
    lazy var textView = GrowingTextView()
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
        self.typeTextView.backgroundColor = TwitColor.gray.gallery
        self.view.addSubview(self.typeTextView)
        
        // textField
        self.textView.maxLength = 0
        self.textView.trimWhiteSpaceWhenEndEditing = false
        self.textView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
        self.textView.minHeight = 25.0
        self.textView.maxHeight = 80.0
        self.textView.backgroundColor = .white
        self.textView.layer.cornerRadius = 4.0
        self.textView.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        self.textView.layer.borderWidth = 1
        self.textView.layer.masksToBounds = true
        self.textView.font = UIFont.systemFont(ofSize: 15)
        self.textView.placeholder = "Start a message"
        self.typeTextView.addSubview(self.textView)
        
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
            
            maker.height.greaterThanOrEqualTo(50)
            maker.left.right.bottom.equalTo(strongSelf.view)
        }
        
        self.textView.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.left.top.equalTo(strongSelf.typeTextView).offset(8)
            maker.bottom.equalTo(strongSelf.typeTextView).offset(-8)
        }
        
        self.sendButton.snp.makeConstraints { [weak self] (maker) in
            
            guard let strongSelf = self else { return }
            
            maker.left.equalTo(strongSelf.textView.snp.right).offset(8)
            maker.bottom.equalTo(strongSelf.textView)
            maker.width.equalTo(50)
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
        
        if let text = self.textView.text, text != "" {
            self.sendMessage(text)
        }
    }
    
    func handleMessage(_ message: String, limit: Int) -> (messages: [String]?, error: String?) {
        
        if message.count <= limit {
            return ([message], nil)
            
        } else {
            return self.splitMessage(message, limit: limit)
        }
    }
    
    func sendMessage(_ message: String) {
        
        let limit = 50
        // using serialqueue and sync to send data order
        let serialQueue = DispatchQueue(label: "sendMessageQueue")
        serialQueue.sync { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let completion = strongSelf.handleMessage(message, limit: limit)
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else { return }
                
                var indexPaths = [IndexPath]()
                var reloadIndexPath: IndexPath?

                // Change bubble UI of last message
                if let cellItem = strongSelf.cellItems[strongSelf.cellItems.count - 2] as? SendMessageTableCellItem {
                    var newItem = cellItem
                    newItem.showBubbleTail = false
                    strongSelf.cellItems[strongSelf.cellItems.count - 2] = newItem
                    reloadIndexPath = IndexPath(item: strongSelf.cellItems.count - 2, section: 0)
                }

                // Add new message
                if let messages = completion.messages {
                    for (index, splitMessage) in messages.enumerated() {

                        if index == messages.count - 1 {
                            strongSelf.cellItems.insert(SendMessageTableCellItem(message: splitMessage, showBubbleTail: true), at: strongSelf.cellItems.count - 1)
                        } else {
                            strongSelf.cellItems.insert(SendMessageTableCellItem(message: splitMessage, showBubbleTail: false), at: strongSelf.cellItems.count - 1)
                        }

                        indexPaths.append(IndexPath(item: strongSelf.cellItems.count - 2, section: 0))
                    }

                    strongSelf.messageTableView.performBatchUpdates({

                        if let validIndexPath = reloadIndexPath {
                            strongSelf.messageTableView.reloadRows(at: [validIndexPath], with: .none)
                        }

                        strongSelf.messageTableView.insertRows(at:indexPaths, with: .fade)

                    }, completion: { (finished) in

                        if finished {
                            strongSelf.messageTableView.scrollToRow(at: IndexPath(item: strongSelf.cellItems.count - 1, section: 0), at: .bottom, animated: true)
                        }
                    })
                    
                    strongSelf.textView.text = nil
                
                } else {

                    let alertVC = UIAlertController(title: "Error", message: completion.error, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(okAction)

                    strongSelf.present(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    func recieveMessage(_ message: String) {
        
        let limit = 50
        // using serialqueue and sync to recive data order
        let serialQueue = DispatchQueue(label: "receiveMessageQueue")
        serialQueue.sync { [weak self] in
            
            guard let strongSelf = self else { return }
            
            let completion = strongSelf.handleMessage(message, limit: limit)
            
            DispatchQueue.main.async { [weak self] in
                
                guard let strongSelf = self else { return }
                
                var indexPaths = [IndexPath]()
                var reloadIndexPath: IndexPath?
                
                // Change bubble UI of last message
                if let cellItem = strongSelf.cellItems[strongSelf.cellItems.count - 2] as? ReceiveMessageTableCellItem {
                    var newItem = cellItem
                    newItem.showBubbleTail = false
                    strongSelf.cellItems[strongSelf.cellItems.count - 2] = newItem
                    reloadIndexPath = IndexPath(item: strongSelf.cellItems.count - 2, section: 0)
                }
                
                // Add new message
                if let messages = completion.messages {
                    for (index, splitMessage) in messages.enumerated() {
                        
                        if index == messages.count - 1 {
                            strongSelf.cellItems.insert(ReceiveMessageTableCellItem(message: splitMessage, showBubbleTail: true), at: strongSelf.cellItems.count - 1)
                        } else {
                            strongSelf.cellItems.insert(ReceiveMessageTableCellItem(message: splitMessage, showBubbleTail: false), at: strongSelf.cellItems.count - 1)
                        }
                        
                        indexPaths.append(IndexPath(item: strongSelf.cellItems.count - 2, section: 0))
                    }
                    
                    strongSelf.messageTableView.performBatchUpdates({
                        
                        if let validIndexPath = reloadIndexPath {
                            strongSelf.messageTableView.reloadRows(at: [validIndexPath], with: .none)
                        }
                        
                        strongSelf.messageTableView.insertRows(at:indexPaths, with: .fade)
                        
                    }, completion: nil)
                    
                } else {
                    
                    let alertVC = UIAlertController(title: "Error", message: completion.error, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(okAction)
                    
                    strongSelf.present(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: Split message
    
    func splitMessage(_ message: String, limit: Int) -> (messages: [String]?, error: String?) {
        
        var output = [String]()
        let errorMessage = "Message is not valid"
        let subStrings = message.split(separator: " ")
        var string = ""
        var sum = 0
        
        var indexMessage = 1
        var i = 0
        var numberOfMessage = 0
        
        // get minimum number of message
        for i in 0..<subStrings.count {
            
            let subString = subStrings[i]
            
            if subString.count > limit {
                return (nil, errorMessage)
            }
            
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
                
                if string.count > limit {
                    return (nil, errorMessage)
                }
                
                output.append(String(string))
            }
            
            i += 1
        }
        
        return (output, nil)
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
