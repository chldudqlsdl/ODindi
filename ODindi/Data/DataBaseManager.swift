//
//  DataBaseManager.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/28/24.
//

import Foundation
import RealmSwift

// 보고싶어요 버튼을 누르면 해당 영화 코드와 날짜를 저장하는데 사용되는 모델
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
    
    // 데이터를 읽어올 때 isDeleted 값이 false 인 것만 필터링
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
    
    // 데이터 삭제시 isDeleted 값이 true 인 경우에만 삭제
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
