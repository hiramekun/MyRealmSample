//
//  ViewController.swift
//  MyRealmSample
//
//  Created by Takaaki Hirano on 2017/05/06.
//  Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import SnapKit
import RealmSwift


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var posts: Results<Post>? = nil


    // MARK: - Views -

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width,
                height: self.view.frame.height)
        return tableView
    }()

    fileprivate lazy var postButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: self.view.frame.width - 72, y: self.view.frame.height - 72,
                width: 56, height: 56)
        button.layer.cornerRadius = 28
        button.clipsToBounds = true
        button.backgroundColor = .red
        return button
    }()


    // MARK: - Life Cycle Events -

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        view.addSubview(postButton)
        postButton.addTarget(self, action: #selector(ViewController.goToPostViewController),
                for: .touchUpInside)
        posts = try! Realm().objects(Post.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.reloadData()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }


    func goToPostViewController() {
        let postViewController = PostViewController()
        navigationController!.pushViewController(postViewController, animated: true)
    }


    // MARK: - TableView Delegate Methods -

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = posts![indexPath.row].content
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts == nil {
            return 0
        }
        else {
            return posts!.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }

    public func tableView(_ tableView: UITableView,
                          commit editingStyle: UITableViewCellEditingStyle,
                          forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let deletePost = self.posts?[indexPath.row] else {
                return
            }
            let deletePostId = deletePost.id

            DispatchQueue(label: "background").async {
                autoreleasepool {

                    let realm = try! Realm()
                    try! realm.write {
                        realm.delete(realm.object(ofType: Post.self, forPrimaryKey: deletePostId)!)
                    }
                }

                DispatchQueue.main.async {
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
        }
    }
}
