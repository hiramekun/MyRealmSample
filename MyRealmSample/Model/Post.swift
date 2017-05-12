//
// Created by Takaaki Hirano on 2017/05/06.
// Copyright (c) 2017 hiramekun. All rights reserved.
//

import Foundation
import RealmSwift

class Post: Object {
    dynamic var id = ""
    dynamic var content = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
