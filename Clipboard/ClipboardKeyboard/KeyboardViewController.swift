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
        
        let container = PersistenceController(inMemory: true).container
        let viewContext = container.viewContext
        let fetchRequest: NSFetchRequest = Clipboards.fetchRequest()
        guard let clipboards = try? viewContext.fetch(fetchRequest) as? [Clipboards] else { return }
        
        // sort by updateTime and top
        let sortedClipboards = clipboards.sorted { $0.updateTime > $1.updateTime }.sorted { $0.top && !$1.top }
        
        // Perform custom UI setup here
        self.keyboardView(clipboards: sortedClipboards);
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
    
    private func keyboardView(clipboards: [Clipboards]) {
        let stackView = keyboardStackView()
        let scrollView = keyboardScrollView(stackView: stackView)
        keyboardAccessoryView(stackView: stackView)
        keyboardClipboardsView(scrollView: scrollView, clipboards: clipboards)
    }
    
    private func keyboardStackView() -> UIStackView {
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
        
        return stackView
    }
    
    private func keyboardScrollView(stackView: UIStackView) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        
        stackView.addArrangedSubview(scrollView)
        
        scrollView.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: 0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -50).isActive = true
        scrollView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 0).isActive = true
        
        return scrollView
    }
    
    private func keyboardAccessoryView(stackView: UIStackView) {
        let accessoryView = UIStackView()
        accessoryView.axis = .horizontal
        accessoryView.spacing = 5.0
        accessoryView.backgroundColor = .clear
        
        stackView.addArrangedSubview(accessoryView)
        
        accessoryView.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 10).isActive = true
        accessoryView.rightAnchor.constraint(equalTo: stackView.rightAnchor, constant: -10).isActive = true
        
        // space button
        let spaceButton = UIButton()
        spaceButton.setTitle("space", for: .normal)
        spaceButton.setTitleColor(.black, for: .normal)
        spaceButton.backgroundColor = .white
        spaceButton.layer.cornerRadius = 5.0
        spaceButton.addTarget(self, action: #selector(onInsertSpace), for: .touchUpInside)
        accessoryView.addArrangedSubview(spaceButton)
        
        // delete button
        let deleteButton = UIButton()
        deleteButton.setImage(UIImage(systemName: "delete.left"), for: .normal)
        deleteButton.tintColor = .black
        deleteButton.backgroundColor = .white
        deleteButton.layer.cornerRadius = 5.0
        
        // add tap and long press event
        deleteButton.addTarget(self, action: #selector(onDeleteText), for: .touchUpInside)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressDeleteKey))
        longPressRecognizer.minimumPressDuration = 0.5
        longPressRecognizer.numberOfTouchesRequired = 1
        longPressRecognizer.allowableMovement = 0.1
        deleteButton.addGestureRecognizer(longPressRecognizer)

        accessoryView.addArrangedSubview(deleteButton)
        deleteButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        // done button
        let doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = .systemBlue
        doneButton.layer.cornerRadius = 5.0
        
        doneButton.addTarget(self, action: #selector(onReturn), for: .touchUpInside)
        accessoryView.addArrangedSubview(doneButton)
        doneButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func keyboardClipboardsView(scrollView: UIScrollView, clipboards: [Clipboards]) {
        var topView: UIView? = nil
        for item in clipboards {
            let contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = .white
            if item.top {
                contentView.layer.borderWidth = 1
                contentView.layer.borderColor = UIColor.systemBlue.cgColor
            }
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
    
    @objc func onLongPressDeleteKey(longGesture: UILongPressGestureRecognizer) {
        self.textDocumentProxy.deleteBackward()
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc func onInsertSpace() {
        self.textDocumentProxy.insertText(" ")
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
    @objc func onReturn() {
        self.textDocumentProxy.insertText("\n")
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
}

class ViewTapGesture: UITapGestureRecognizer {
    var text = String()
}
