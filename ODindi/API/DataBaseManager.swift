//
//  DataBaseManager.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/28/24.
//

import Foundation
import RealmSwift

class WatchLater: Object {
    
    @Persisted(primaryKey: true) var movieCode: String
    @Persisted var date: Date = Date()
    @Persisted var isDeleted: Bool = false
    
    convenience init(_ movieCode: String) {
        self.init()
        self.movieCode = movieCode
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
    
    func read() -> Results<WatchLater> {
        return database.objects(WatchLater.self)
            .filter("isDeleted == false")
    }
    
    func write(_ code: String) {
        
        let watchLater = WatchLater(code)
        do {
            try database.write {
                database.add(watchLater, update: .modified)
                print("Item Added")
            }
        } catch let error {
            print(error)
        }
    }
    
    func tempDelete(_ code: String) {
        do {
            let item = database.objects(WatchLater.self)
                .filter {
                    $0.movieCode == code
                }
            try database.write {
                item.first?.isDeleted = true
            }
        } catch let error {
            print(error)
        }
    }
    
    
    func delete() {
        do {
            let items = database.objects(WatchLater.self)
                .filter("isDeleted == true")
            try database.write {
                database.delete(items)
                print("Item Deleted")
            }
        } catch let error {
            print(error)
        }
    }
}
