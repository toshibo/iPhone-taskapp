//
//  Task.swift
//  taskapp
//
//  Created by Toshi Fujita on 2018/03/16.
//  Copyright © 2018年 toshibo. All rights reserved.
//

import RealmSwift

class Task: Object {
    //管理用ID. Primary Key
    @objc dynamic var id = 0
    
    //タイトル
    @objc dynamic var title = ""
    
    //カテゴリ
    @objc dynamic var category: Category?
    
    //内容
    @objc dynamic var contents = ""
    
    //日時
    @objc dynamic var date = Date()
    
    //IDをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}

class Category: Object {
    //ID, Primary Key
    @objc dynamic var id = 0
    
    //カテゴリ名
    @objc dynamic var name = ""
    
    //カテゴリとタスクは1:多の関係
    let tasks = List<Task>()
    
    //IDをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
