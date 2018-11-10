
//
//  HeaderView.swift
//  LoginExample
//
//  Created by Martin Eberl on 10.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

protocol FooterViewDelegate: class {
    func firstButtonPressed()
    func secondButtonPressed()
}

final class FooterView: UITableViewHeaderFooterView, XibLoadable {
    static let xibName = "FooterView"
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    private var didAppear = false
    var content: FooterContent? {
        didSet {
            if didAppear {
                updateUI()
            }
        }
    }
    
    struct FooterContent {
        let firstButtonTitle: String
        let secondButtonTitle: String
        weak var delegate: FooterViewDelegate?
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        didAppear = true
        updateUI()
    }
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        content?.delegate?.firstButtonPressed()
    }
    
    @IBAction func secondButtonPressed(_ sender: Any) {
        content?.delegate?.secondButtonPressed()
    }
    
    private func updateUI() {
        firstButton.setTitle(content?.firstButtonTitle, for: .normal)
        secondButton.setTitle(content?.secondButtonTitle, for: .normal)
    }
}

