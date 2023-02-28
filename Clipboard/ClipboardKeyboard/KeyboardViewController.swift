//
//  KeyboardViewController.swift
//  ClipboardKeyboard
//
//  Created by ybw-macbook-pro on 2023/2/23.
//

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        
        let mainStackView = UIStackView(arrangedSubviews: [self.addKeyboardButtons()])
        mainStackView.axis = .vertical
        mainStackView.spacing = 10.0
        mainStackView.distribution = .fillEqually
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(mainStackView)
        
        mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 2).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2).isActive = true
        mainStackView.heightAnchor.constraint(equalToConstant: 225).isActive = true
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
    }
    
    func addKeyboardButtons() -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.bounces = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        scrollView.addConstraints([
            NSLayoutConstraint(item: contentView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .centerX,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: contentView,
                attribute: .width,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .width,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: contentView,
                attribute: .top,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .top,
                multiplier: 1.0,
                constant: 0.0),
            NSLayoutConstraint(item: contentView,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: scrollView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: 0.0)
        ])

        var previousViewElement: UIView!
        
        let clipboard = [
            "numberOfSubViews",
            "view.backgroundColor = colorsArray[Int(arc4random_uniform(UInt32(colorsArray.count)))] as UIColor",
            "button.backgroundColor = .white",
            "let button = UIButton(type: .system)",
            "At this point previousViewElement refers to the last subview, that is the one at the bottom.",
            "button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)"
        ]

        for (index, item) in clipboard.enumerated() {

            let button = UIButton(type: .system)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.contentHorizontalAlignment = .left
            button.contentVerticalAlignment = .top
            button.contentEdgeInsets = UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
            button.translatesAutoresizingMaskIntoConstraints = false

            button.setTitle(item, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.titleLabel?.textColor = UIColor.black
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.lineBreakMode = .byCharWrapping
            button.sizeToFit()
            button.layoutIfNeeded()
            button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        
            contentView.addSubview(button)
            
            contentView.addConstraints([
                NSLayoutConstraint(item: button,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: contentView,
                    attribute: .centerX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(item: button,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: contentView,
                    attribute: .width,
                    multiplier: 0.9,
                    constant: 0.0),
                NSLayoutConstraint(item: button,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 1.0,
                    constant: 100.0)
            ])

            if previousViewElement == nil {
                contentView.addConstraint(
                    NSLayoutConstraint(item: button,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: contentView,
                        attribute: .top,
                        multiplier: 1.0,
                        constant: 10.0))
            } else {
                contentView.addConstraint(
                    NSLayoutConstraint(item: button,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: previousViewElement,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 10.0))
            }

            previousViewElement = button
        }

        // At this point previousViewElement refers to the last subview, that is the one at the bottom.
        contentView.addConstraint(
            NSLayoutConstraint(item: previousViewElement,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: -10.0))

        return scrollView
    }
    
    @objc func didTapButton(sender: UIButton) {
        
        let button = sender as UIButton
        guard let title = button.titleLabel?.text else { return }
        self.textDocumentProxy.insertText(title)
        UIDevice.current.playInputClick()
        
    }

}
