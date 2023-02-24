//
//  KeyboardViewController.swift
//  ClipboardKeyboard
//
//  Created by ybw-macbook-pro on 2023/2/23.
//

import UIKit

class KeyboardViewController: UIInputViewController {

    @IBOutlet var nextKeyboardButton: UIButton!
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Perform custom UI setup here
        self.nextKeyboardButton = UIButton(type: .system)
        
        self.nextKeyboardButton.setTitle(NSLocalizedString("Next Keyboard", comment: "Title for 'Next Keyboard' button"), for: [])
        self.nextKeyboardButton.sizeToFit()
        self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.nextKeyboardButton.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allTouchEvents)
        
        self.view.addSubview(self.nextKeyboardButton)
        
        self.nextKeyboardButton.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.nextKeyboardButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        self.addKeyboardButtons()
    }
    
    override func viewWillLayoutSubviews() {
        self.nextKeyboardButton.isHidden = !self.needsInputModeSwitchKey
        super.viewWillLayoutSubviews()
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        self.nextKeyboardButton.setTitleColor(textColor, for: [])
    }
    
    func addKeyboardButtons() {
        let RowStackView = UIStackView.init()
        RowStackView.spacing = 5
        RowStackView.axis = .horizontal
        RowStackView.alignment = .fill
        RowStackView.distribution = .fillEqually
        
        let buttonA = UIButton(type: .system)
        buttonA.setTitle("A", for: .normal)
        buttonA.sizeToFit()
        buttonA.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        buttonA.translatesAutoresizingMaskIntoConstraints = false
        buttonA.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        
        let buttonB = UIButton(type: .system)
        buttonB.setTitle("A", for: .normal)
        buttonB.sizeToFit()
        buttonB.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        buttonB.translatesAutoresizingMaskIntoConstraints = false
        buttonB.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)
        
        RowStackView.addArrangedSubview(buttonA)
        RowStackView.addArrangedSubview(buttonB)

        self.view.addSubview(RowStackView)
    }
    
    @objc func didTapButton(sender: UIButton) {
        
        let button = sender as UIButton
        guard let title = button.titleLabel?.text else { return }
        let proxy = self.textDocumentProxy
        
        UIView.animate(withDuration: 0.25, animations: {
            button.transform = CGAffineTransform(scaleX: 1.20, y: 1.20)
            UIDevice.current.playInputClick()
            proxy.insertText(title)
        }) { (_) in
            UIView.animate(withDuration: 0.10, animations: {
                button.transform = CGAffineTransform.identity
            })
        }
        
    }

}
