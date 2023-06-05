//
//  RealmServiceProtocol.swift
//  RealmDemo
//
//  Created by Do Huu Phuc on 02/06/2023.
//

import Foundation

protocol RealmServiceProtocol : AnyObject {
    
    /// Initialize the Realm service with an optional queue.
    ///
    /// Initialize the Realm service with an optional `queue` parameter for handling operations asynchronously.
    ///
    /// - Parameters:
    ///   - queue: An optional `DispatchQueue` to perform operations asynchronously. Pass `nil` to use the default internal queue.
    ///
    /// - Returns: Void
    init(queue: DispatchQueue?)
    
    /// Add  `object` to database.
    ///
    /// Add object to Realm database
    ///
    /// > Example usage:
    /// ```
    /// let service: RealmServiceProtocol = RealmServiceImp()
    /// let object = BusinessObject()
    /// service.addObject(object: object)
    /// ```
    ///
    /// - Parameters:
    ///     - object: The business object based on `BusinessObject`.
    ///
    /// - Returns: Void
    func addObject(object: BusinessObject)
    
    /// Get objects of a specific type from the database.
    ///
    /// Retrieve all objects of the specified `objectType` from the Realm database.
    ///
    /// - Parameters:
    ///   - objectType: The type of business object to retrieve from the database.
    ///
    /// - Returns: An array of objects of type `T`.
    func getObjects<T: BusinessObject>(objectType: T.Type) -> [T]
    
    /// Get objects of a specific type from the database using a query.
    ///
    /// Retrieve objects of the specified `objectType` from the Realm database that match the given `query`.
    ///
    /// - Parameters:
    ///   - objectType: The type of business object to retrieve from the database.
    ///   - query: The query used to filter the objects. Pass `nil` to retrieve all objects.
    ///
    /// - Returns: An array of objects of type `T` that match the query.
    func getObjects<T: BusinessObject>(objectType: T.Type, query: NSPredicate?) -> [T]
    
    /// Delete objects of a specific type from the database using a query.
    ///
    /// Delete objects of the specified `objectType` from the Realm database that match the given `query`.
    ///
    /// - Parameters:
    ///   - objectType: The type of business object to delete from the database.
    ///   - query: The query used to filter the objects to be deleted. Pass `nil` to delete all objects of the given type.
    ///
    /// - Returns: Void
    func deleteObject<T: BusinessObject>(objectType: T.Type, query: NSPredicate?)
    
    /// Delete all objects from the database.
    ///
    /// Delete all objects of all types from the Realm database.
    ///
    /// - Returns: Void
    func deleteAllObjects()
}
