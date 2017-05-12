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
import RxSwift
import RxCocoa


class ViewController: UIViewController {
    
    // MARK: - Properties -
    
    fileprivate lazy var disposeBag = DisposeBag()
    fileprivate lazy var dataSource = MyDataSource()
    fileprivate lazy var postModelObserver: Observable<Results<Post>?> = PostViewModel.sharedPostViewModel.posts.asObservable()
    
    
    // MARK: - Views -
    
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width,
                                 height: self.view.frame.height)
        
        return tableView
    }()
    
    fileprivate lazy var postButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .red
        button.clipsToBounds = true
        button.frame = CGRect(x: self.view.frame.width - 72, y: self.view.frame.height - 72,
                              width: 56, height: 56)
        button.layer.cornerRadius = 28
        
        return button
    }()
    
    
    // MARK: - Life Cycle Events -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        view.addSubview(postButton)
        postButton.addTarget(self, action: #selector(ViewController.goToPostViewController),
                             for: .touchUpInside)
        
        setupObserver()
        setupTableView()
        setupTouchEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
}


extension ViewController {
    
    // MARK: - Methods -
    
    fileprivate func setupObserver() {
        PostViewModel.sharedPostViewModel.posts.value?.rx_response().subscribe(
            onNext: { [weak self] results in
                self?.tableView.reloadData()
            }).addDisposableTo(disposeBag)
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = dataSource
        postModelObserver
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func setupTouchEvent() {
        dataSource.selectedIndexPath
            .subscribe(onNext: { path in print(path.row) })
            .addDisposableTo(disposeBag)
    }
    
    func goToPostViewController() {
        let postViewController = PostViewController()
        navigationController!.pushViewController(postViewController, animated: true)
    }
}


class MyDataSource: NSObject, RxTableViewDataSourceType, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties -
    
    typealias Element = Results<Post>?
    private var itemModels: Element = nil
    fileprivate let selectedIndexPath = PublishSubject<IndexPath>()
    
    
    // MARK: - RxTableViewDataSourceType -
    
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        UIBindingObserver(UIElement: self) { (dataSource, element) in
            dataSource.itemModels = element
            tableView.reloadData()
        }.on(observedEvent)
    }
    
    
    // MARK: - UITableViewDataSource -
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath.onNext(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if itemModels == nil {
            return 0
        }
        else {
            return itemModels!.count
        }
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let element = itemModels?[indexPath.row] {
            cell.textLabel?.text = element.content
        }
        
        return cell
    }
}
