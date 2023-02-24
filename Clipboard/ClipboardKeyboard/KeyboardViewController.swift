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
        
        let scrollView = self.addKeyboardButtons()
        
        let mainStackView = UIStackView(arrangedSubviews: [scrollView])
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
        let numberOfSubViews = 5
        
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
                constant: 0.0)])

        var previousViewElement:UIView!

        let colorsArray = [UIColor.red, UIColor.green, UIColor.blue,
                           UIColor.cyan, UIColor.magenta, UIColor.yellow]

        for item in 1...numberOfSubViews {
            let view = UIView()
            view.backgroundColor = colorsArray[Int(arc4random_uniform(UInt32(colorsArray.count)))] as UIColor
            view.translatesAutoresizingMaskIntoConstraints = false
            
            let button = UIButton(type: .system)
            button.setTitle("\(item)", for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
            view.addSubview(button)
            
            contentView.addSubview(view)
            
            contentView.addConstraints([
                NSLayoutConstraint(item: view,
                    attribute: .centerX,
                    relatedBy: .equal,
                    toItem: contentView,
                    attribute: .centerX,
                    multiplier: 1.0,
                    constant: 0.0),
                NSLayoutConstraint(item: view,
                    attribute: .width,
                    relatedBy: .equal,
                    toItem: contentView,
                    attribute: .width,
                    multiplier: 6/7,
                    constant: 0.0),
                NSLayoutConstraint(item: view,
                    attribute: .height,
                    relatedBy: .equal,
                    toItem: nil,
                    attribute: .notAnAttribute,
                    multiplier: 0.0,
                    constant: 50.0 * CGFloat(1 + arc4random_uniform(7)))])
            
            if previousViewElement == nil {
                contentView.addConstraint(
                    NSLayoutConstraint(item: view,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: contentView,
                        attribute: .top,
                        multiplier: 1.0,
                        constant: 20.0))
            } else {
                contentView.addConstraint(
                    NSLayoutConstraint(item: view,
                        attribute: .top,
                        relatedBy: .equal,
                        toItem: previousViewElement,
                        attribute: .bottom,
                        multiplier: 1.0,
                        constant: 20.0))
            }
            
            previousViewElement = view
        }

        // At this point previousViewElement refers to the last subview, that is the one at the bottom.
        contentView.addConstraint(
            NSLayoutConstraint(item: previousViewElement,
                attribute: .bottom,
                relatedBy: .equal,
                toItem: contentView,
                attribute: .bottom,
                multiplier: 1.0,
                constant: -20.0))

        return scrollView
    }
    
    @objc func didTapButton(sender: UIButton) {
        
        let button = sender as UIButton
        guard let title = button.titleLabel?.text else { return }
        self.textDocumentProxy.insertText(title)
        UIDevice.current.playInputClick()
        
    }

}
