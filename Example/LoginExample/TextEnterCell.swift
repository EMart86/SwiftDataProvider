//
//  TextEnterCell.swift
//  LoginExample
//
//  Created by Martin Eberl on 10.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol TextEnterCellTextUpdated: class {
    func content(_ content: TextEnterCell.Content, textChanged text: String?)
    func content(_ content: TextEnterCell.Content, textEntered text: String?)
}

final class TextEnterCell: UITableViewCell, XibLoadable {
    static let xibName = "TextEnterCell"
    
    struct Content: Comparable {
        static func < (lhs: TextEnterCell.Content, rhs: TextEnterCell.Content) -> Bool {
            return false
        }
        
        static func == (lhs: TextEnterCell.Content, rhs: TextEnterCell.Content) -> Bool {
            return lhs.title == rhs.title
        }
        
        let title: String
        var content: String?
        let isSecure: Bool
        let separatorColor: UIColor = .lightGray
        weak var delegate: TextEnterCellTextUpdated?
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var separator: UIView!
    
    private var didAppear = false
    
    var content: Content? {
        didSet {
            if didAppear {
                updateUI()
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            textField.becomeFirstResponder()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        didAppear = true
        
        textField.addTarget(self, action: #selector(textFieldDidChange(sender:)), for: .editingChanged)
        
        updateUI()
    }
    
     @objc func textFieldDidChange(sender: UITextField) {
        guard var content = content else {
            return
        }
        content.content = textField?.text
        content.delegate?.content(content, textChanged: textField.text)
    }
    
    // MARK: - Private
    
    private func updateUI() {
        label.text = content?.title
        textField.text = content?.content
        textField.isSecureTextEntry = content?.isSecure ?? false
        separator.backgroundColor = content?.separatorColor
    }
}

extension TextEnterCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard var content = content else {
            return
        }
        content.content = textField.text
        content.delegate?.content(content, textEntered: textField.text)
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard var content = content else {
            return
        }
        content.content = textField.text
        content.delegate?.content(content, textEntered: textField.text)
    }
}
