//
//  DataBaseManager.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/28/24.
//

import Foundation
import RealmSwift

class WatchLater: Object {
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    @Persisted var movieCode: String
    @Persisted var date: Date = Date()
    
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
    
    func read(_ object: WatchLater.Type) -> Results<WatchLater> {
        return database.objects(object)
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
    
    func delete(_ code :String) {
        do {
            let item = database.objects(WatchLater.self)
                .filter {
                    $0.movieCode == code
                }
            try database.write {
                database.delete(item.first ?? item[0])
                print("Item Deleted")
            }
        } catch let error {
            print(error)
        }
    }
}
