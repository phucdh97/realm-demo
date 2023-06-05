//
//  RealmService.swift
//  RealmDemo
//
//  Created by Do Huu Phuc on 04/03/2023.
//


import UIKit
import RealmSwift


final class RealmService: RealmServiceProtocol {
    
    private var realm: Realm?
    private var internalQueue = DispatchQueue(label: "com.phucdh.realmdb")
    
    //MARK: - Public functions
    
    init(queue: DispatchQueue? = nil) {
        if let customQueue = queue {
            self.internalQueue = customQueue
        }
        
        internalQueue.sync { [weak self] in
            self?.openDatabase()
        }
    }
    
    func addObject(object: BusinessObject) {
        internalQueue.async { [weak self] in
            if let dbObject = object.toDBObject() {
                self?.internalAddObject(dbObject)
            }
        }
    }
    
    func getObjects<T: BusinessObject>(objectType: T.Type) -> [T] {
        var ans: [T] = []
        internalQueue.sync {
            let cls = objectType.getDBClass()
            let frozenObjects = realm?.objects(cls).freeze()
            guard let objects = frozenObjects else {
                assertionFailure("Can not get class type")
                return
            }
            
            for obj in objects {
                if let ele = obj.toBusinessObject(), let rs = ele as? T {
                    ans.append(rs)
                }
            }
        }
        return ans
    }
    
    func getObjects<T: BusinessObject>(objectType: T.Type, query: NSPredicate?) -> [T] {
//        let predicate = NSPredicate(format: "progressMinutes > 1 AND name == %@", "Ali")
        guard let query = query else {
            return self.getObjects(objectType: objectType)
        }
        var ans: [T] = []
        internalQueue.sync {
            let cls = objectType.getDBClass()
            let frozenObjects = realm?.objects(cls).freeze().filter(query)
            guard let objects = frozenObjects else {
                assertionFailure("Can not get class type")
                return
            }
            
            for obj in objects {
                if let ele = obj.toBusinessObject(), let rs = ele as? T {
                    ans.append(rs)
                }
            }
        }
        return ans
    }
    
    func deleteObject<T: BusinessObject>(objectType: T.Type, query: NSPredicate?) {
        //        let predicate = NSPredicate(format: "progressMinutes > 1 AND name == %@", "Ali")
        //        let rs = self.realm?.objects(DBToDoTask.self).filter("progressMinutes > 1")
        guard let query = query else {
            return
        }
        
        internalQueue.async { [weak self] in
            do {
                try self?.realm?.write {
                    if let rs = self?.realm?.objects(objectType.getDBClass()).filter(query) {
                        self?.realm?.delete(rs)
                    }
                }
            } catch {
                assertionFailure("Error deleting object: \(error) with query: \(query)")
            }
        }
    }
    
    func deleteAllObjects() {
        internalQueue.async { [weak self] in
            do {
                try self?.realm?.write {
                    self?.realm?.deleteAll()
                }
            } catch {
                assertionFailure("Error deleting all objects: \(error)")
            }
        }
    }
    
    //MARK: - Private functions
    
    private func openDatabase() {
        do {
            let folderName = "Data"
            var config = Realm.Configuration.defaultConfiguration
            guard var url = config.fileURL else {
                assertionFailure("URL configuration is nil")
                return
            }
            url.deleteLastPathComponent()
            url.appendPathComponent(folderName)
            url.appendPathExtension("realm")
            config.fileURL = url
            config.deleteRealmIfMigrationNeeded = true
            config.schemaVersion = 1
            realm = try Realm(configuration: config, queue: internalQueue)
        }
        catch let error as NSError {
            assertionFailure("Create DB failed \(error)")
        }
    }
    
    private func internalAddObject<T: Object>(_ object: T) {
        do {
            try self.realm?.write {
                self.realm?.add(object, update: .modified)
            }
        }
        catch let error as NSError {
            assertionFailure("Add object failed \(error)")
        }
    }
    
    
    private func deleteObject<T: Object>(_ object: T) {
        internalQueue.async { [weak self] in
            do {
                try self?.realm?.write {
                    self?.realm?.delete(object)
                }
            } catch {
                assertionFailure("Error deleting object \(error)")
            }
        }
    }
    
    private func deleteObject<T: Object>(objectType: T.Type) {
        internalQueue.async { [weak self] in
            do {
                try self?.realm?.write {
                    if let allObjects = self?.realm?.objects(objectType) {
                        self?.realm?.delete(allObjects)
                    }
                }
            } catch {
                assertionFailure("Error deleting object type \(error)")
            }
        }
    }
}
