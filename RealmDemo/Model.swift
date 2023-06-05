//
//  Model.swift
//  RealmDemo
//
//  Created by Do Huu Phuc on 02/06/2023.
//

import RealmSwift

//MARK: - Abstract Models

class BusinessObject: NSObject {
    class func getDBClass() -> Object.Type {
        return Object.self
    }
    
    func toDBObject() -> Object? {
        return nil
    }
}

extension Object {
    @objc func toBusinessObject() -> BusinessObject? {
        return nil
    }
}



//MARK: - Models

class ToDoTask: BusinessObject {
    
    var tasknote: String?
    var taskid: String?
    var status: Double = 0.0
    
    override class func getDBClass() -> Object.Type {
        return DBToDoTask.self
    }
    
    override func toDBObject() -> Object? {
        let obj = DBToDoTask()
        obj.taskid = self.taskid
        obj.tasknote = self.tasknote
        obj.status = self.status
        return obj
    }
}

class DBToDoTask: Object {
    @Persisted(primaryKey: true) var taskid: String?
    @Persisted var tasknote: String?
    @Persisted var status: Double = 0.0
    @Persisted var addition: String?
    
    @objc override func toBusinessObject() -> BusinessObject? {
        let obj = ToDoTask()
        obj.taskid = self.taskid
        obj.tasknote = self.tasknote
        obj.status = self.status
        return obj
    }
}
