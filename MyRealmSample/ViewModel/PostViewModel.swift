//
// Created by Takaaki Hirano on 2017/05/09.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RealmSwift

class PostViewModel {

    /// Do NOT initialize out of this file

    fileprivate init() {
    }


    // MARK: - Property -

    private (set) lazy var posts: Variable<Results<Post>?> = {
        return Variable(try! Realm().objects(Post.self))
    }()
}

extension PostViewModel {

    static var sharedPostViewModel: PostViewModel = {
        return PostViewModel()
    }()
}


extension Results {
    public func rx_response() -> Observable<Results<Element>> {
        return Observable.create { observer in
            MainScheduler.ensureExecutingOnScheduler()

            let token = self.addNotificationBlock { change in
                switch change {
                case .initial:
                    observer.onNext(self)
                case .update(self, _, _, _):
                    observer.onNext(self)
                case .error(let error):
                    observer.onError(error)
                default:
                    break
                }
            }

            return Disposables.create() {
                token.stop()
            }
        }
    }
}
