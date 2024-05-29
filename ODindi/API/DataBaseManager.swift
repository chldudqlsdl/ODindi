//
//  DataBaseManager.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/28/24.
//

import Foundation
import RealmSwift

class WatchLater: Object {
    @objc dynamic var movieCode: String
    @objc dynamic var date: Date
    
    init(movieCode: String) {
        self.movieCode = movieCode
        self.date = Date()
    }
}

class DataBaseManager {
    static let shared = DataBaseManager()
    
    private let database: Realm
    
    private init() {
        self.database = try! Realm()
    }
    
    func getLocationOfDefaultRealm() {
        print("Realm is located at:", database.configuration.fileURL!)
    }
    
    func read(_ object: WatchLater.Type) -> Results<WatchLater> {
        return database.objects(object)
    }
    
    func write(_ object: WatchLater) {
        do {
            try database.write {
                database.add(object, update: .modified)
                print("Item Added")
            }
        } catch let error {
            print(error)
        }
    }
    
    func delete(_ object: WatchLater) {
        do {
            try database.write {
                database.delete(object)
                print("Item Deleted")
            }
        } catch let error {
            print(error)
        }
    }
}
