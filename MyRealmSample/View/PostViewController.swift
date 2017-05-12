//
// Created by Takaaki Hirano on 2017/05/06.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class PostViewController: UIViewController {
    
    // MARK: - Views -
    
    fileprivate lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.frame = CGRect(x: 0, y: self.view.frame.height / 2, width: self.view.frame.width,
                                 height: 50)
        textField.backgroundColor = .gray
        return textField
    }()
    
    fileprivate lazy var sendButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: self.view.frame.height / 2 + 80, width: 56, height: 56)
        button.backgroundColor = .blue
        
        return button
    }()
    
    
    // MARK: - Life Cycle Events -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(inputTextField)
        view.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(PostViewController.post), for: .touchUpInside)
    }
    
    func post() {
        if let text = inputTextField.text {
            if text.isEmpty {
                return
            }
            
            DispatchQueue(label: "background").async {
                let realm = try! Realm()
                try! realm.write {
                    let post = Post()
                    post.id = NSUUID().uuidString
                    post.content = text
                    realm.add(post)
                }
                
                DispatchQueue.main.async { [weak self] () -> Void in
                    self?.navigationController!.popViewController(animated: true)
                }
            }
        }
    }
}
