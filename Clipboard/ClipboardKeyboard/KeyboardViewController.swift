//
//  KeyboardViewController.swift
//  ClipboardKeyboard
//
//  Created by ybw-macbook-pro on 2023/2/23.
//

import UIKit
import SwiftUI
import CoreData

class KeyboardViewController: UIInputViewController {
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let controller = PersistenceController(inMemory: true)
        let fetchRequest: NSFetchRequest = Clipboards.fetchRequest()
        guard let clipboards = try? controller.container.viewContext.fetch(fetchRequest) as? [Clipboards] else { return }
        
        // Perform custom UI setup here
        self.keyboardView(clipboards: clipboards);
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
    
    func keyboardView(clipboards: [Clipboards]) {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10.0
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 225).isActive = true
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        
        stackView.addArrangedSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -50).isActive = true
        scrollView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 0).isActive = true
        
        let accessoryView = UIStackView()
        accessoryView.axis = .horizontal
        accessoryView.spacing = 5.0
        accessoryView.backgroundColor = .clear
        
        stackView.addArrangedSubview(accessoryView)
        
        accessoryView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10).isActive = true
        accessoryView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -10).isActive = true
        
        let spaceButton = UIButton()
        spaceButton.setTitle("space", for: .normal)
        spaceButton.setTitleColor(.black, for: .normal)
        spaceButton.backgroundColor = .white
        spaceButton.layer.cornerRadius = 5.0
        spaceButton.addTarget(self, action: #selector(onInsertSpace), for: .touchUpInside)
        accessoryView.addArrangedSubview(spaceButton)
        
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(systemName: "delete.left"), for: .normal)
        deleteButton.tintColor = .black
        deleteButton.backgroundColor = .white
        deleteButton.layer.cornerRadius = 5.0
        
        deleteButton.addTarget(self, action: #selector(onDeleteText), for: .touchUpInside)
        
        // TODO: batch delete is not smooth
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressDeleteKey))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.numberOfTouchesRequired = 1
        longPressRecognizer.allowableMovement = 0.1
        deleteButton.addGestureRecognizer(longPressRecognizer)

        accessoryView.addArrangedSubview(deleteButton)
        
        deleteButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        var topView: UIView? = nil
        for (index, item) in clipboards.enumerated() {
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 10
            contentView.layoutIfNeeded()
            
            let contentViewTap = ViewTapGesture(target: self, action: #selector(self.onInsertClipboardText(sender:)))
            contentViewTap.text = item.text
            contentView.addGestureRecognizer(contentViewTap)
            
            scrollView.addSubview(contentView)

            if let top = topView {
                contentView.topAnchor.constraint(equalTo: top.bottomAnchor, constant: 10).isActive = true
            } else {
                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10).isActive = true
            }
            contentView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
            contentView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
            
            topView = contentView

            let label = UILabel()
            label.numberOfLines = 0
            label.lineBreakMode = .byCharWrapping
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = item.text
            label.textColor = .black
            
            contentView.addSubview(label)
            
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
            label.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
            label.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        }
        
        if let top = topView {
            top.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10).isActive = true
        }
    }
    
    @objc func onInsertClipboardText(sender: ViewTapGesture) {
        self.textDocumentProxy.insertText(sender.text)
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc func onDeleteText() {
        self.textDocumentProxy.deleteBackward()
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc func onInsertSpace() {
        self.textDocumentProxy.insertText(" ")
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc func onLongPressDeleteKey(longGesture: UILongPressGestureRecognizer) {
        self.textDocumentProxy.deleteBackward()
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

class ViewTapGesture: UITapGestureRecognizer {
    var text = String()
}
