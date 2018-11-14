//
//  ViewModel.swift
//  LoginExample
//
//  Created by Martin Eberl on 10.11.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import SwiftDataProvider

class ViewModel {
    enum `Type` {
        case login
        case register
    }
    
    let contentAdapter: ContentProviderAdapter
    let section = Section()
    
    fileprivate var currentType: Type = .login
    private var email: String?
    private var firstName: String?
    private var lastName: String?
    
    init() {
        contentAdapter = ContentProviderAdapter()
        section.set(header: HeaderView.HeaderContent())
        contentAdapter.add(section: section)
        contentAdapter.commit()
    }
    
    func onChangeToRegisterClicked() {
        currentType = .register
        section.clear()
        section.set(footer: FooterView.FooterContent(firstButtonTitle: "Login", secondButtonTitle: "Register", delegate: self))
        section.add(row: TextEnterCell.Content(title: "E-Mail", content: email, isSecure: false, delegate: self), animation: .fade)
        section.add(row: TextEnterCell.Content(title: "Firstname", content: firstName, isSecure: false, delegate: self), animation: .fade)
        section.add(row: TextEnterCell.Content(title: "Lastname", content: lastName, isSecure: false, delegate: self), animation: .fade)
        contentAdapter.commit()
    }
    
    func onChangeToLoginClicked() {
        currentType = .login
        section.clear()
        section.set(footer: FooterView.FooterContent(firstButtonTitle: "Register", secondButtonTitle: "Back to login", delegate: self))
        section.add(row: TextEnterCell.Content(title: "E-Mail", content: email, isSecure: false, delegate: self), animation: .fade)
        section.add(row: TextEnterCell.Content(title: "Password", content: nil, isSecure: true, delegate: self), animation: .fade)
        contentAdapter.commit()
    }
}

extension ViewModel: TextEnterCellTextUpdated {
    func content(_ content: TextEnterCell.Content, textChanged text: String?) { }
    
    func content(_ content: TextEnterCell.Content, textEntered text: String?) { }
}

extension ViewModel: FooterViewDelegate {
    func firstButtonPressed() { }
    
    func secondButtonPressed() {
        switch currentType {
        case .login:
            onChangeToRegisterClicked()
        case .register:
            onChangeToLoginClicked()
        }
    }
}

struct Content {
    let title: String
    var content: String?
    let separatorColor: UIColor = .lightGray
    weak var delegate: TextEnterCellTextUpdated?
}
