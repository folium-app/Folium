//
//  AddCheatViewController.swift
//  Folium
//
//  Created by Jarrod Norwell on 21/6/2024.
//

#if canImport(Cytrus)

import Cytrus
import Foundation
import UIKit

class AddCheatViewController : UIViewController {
    fileprivate var textField: MinimalRoundedTextField!
    fileprivate var textView: MinimalRoundedTextView!
    
    var titleIdentifier: UInt64
    var cheatManager: CheatManager
    init(_ titleIdentifier: UInt64, _ cheatManager: CheatManager) {
        self.titleIdentifier = titleIdentifier
        self.cheatManager = cheatManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.setLeftBarButton(.init(systemItem: .cancel, primaryAction: .init(handler: { _ in
            self.dismiss(animated: true)
        })), animated: true)
        navigationItem.setRightBarButton(.init(systemItem: .save, primaryAction: .init(handler: { _ in
            guard let name = self.textField.text, !name.isEmpty else {
                self.textField.error()
                return
            }
            
            guard let code = self.textView.text, !code.isEmpty else {
                self.textView.error()
                return
            }
            
            self.cheatManager.addCheat(withName: name, code: code, comments: "") // code, name
            self.cheatManager.loadCheats(self.titleIdentifier)
            self.dismiss(animated: true)
        })), animated: true)
        title = "Add Cheat"
        view.backgroundColor = .systemBackground
        
        
        textField = .init("Cheat Name", .all)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        view.addSubview(textField)
        
        textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = .init(string: "Cheat Code", attributes: [
            .font : UIFont.boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize),
            .foregroundColor : UIColor.label
        ])
        label.textAlignment = .left
        view.addSubview(label)
        
        label.topAnchor.constraint(equalTo: textField.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        
        textView = .init(.all)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.isScrollEnabled = false
        view.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: label.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
}

extension AddCheatViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddCheatViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else {
            return
        }
        
        if text.suffix(2) == "\n\n" {
            textView.resignFirstResponder()
        }
    }
}

#endif
