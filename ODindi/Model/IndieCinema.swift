//
//  IndieCinema.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/6/24.
//

import Foundation
import CoreLocation

struct IndieCinema {
        
    let id: Int
    let name: String
    let location: CLLocationCoordinate2D
    let code: [String]

}

extension IndieCinema {
    
    // 독립영화관 목록
    static var list: [IndieCinema] {
        var cinemas: [IndieCinema] = []
        for (index, name) in IndieCinemaData.nameList.enumerated() {
            cinemas.append(IndieCinema(id: index, name: name, location: CLLocationCoordinate2D(latitude: IndieCinemaData.latitudeList[index], longitude: IndieCinemaData.longitudeList[index]), code: IndieCinemaData.cinemaCodeList[name] ?? ["indieart","000057"]))
        }
        return cinemas
    }
}

struct IndieCinemaData {
    static let nameList: [String] = [
        "광주극장",
        "광주독립영화관",
        "더숲아트시네마",
        "씨네아트리좀",
        "아트하우스모모",
        "안동중앙아트시네마",
        "에무시네마",
        "오오극장",
        "인디플러스포항",
        "인디플러스천안",
        "인천미림극장",
        "전주디지털독립영화관",
        "판타스틱큐브",
        "필름포럼",
        "헤이리시네마",
        "씨네큐브광화문",
//        "오르페오한남",
        "라이카시네마",
        "모퉁이극장",
        "씨네인디U",
        "아리랑시네센터",
        "영화공간주안",
        "KT&G상상마당시네마",
        "KU시네마테크"
    ]
    
    static let latitudeList : [Double] = [
        35.149793,
        35.146904,
        37.664192,
        35.205938,
        37.561342,
        36.565073,
        37.572129,
        35.870668,
        36.040895,
        36.808647,
        37.475437,
        35.818347,
        37.503474,
        37.563754,
        37.791493,
        37.569706,
        37.533965,
        37.565135,
        35.100483,
        36.320947,
        37.600234,
        37.461238,
        37.550888,
        37.542888
    ]
    
    static let longitudeList : [Double] = [
        126.912486,
        126.922060,
        127.066247,
        128.575802,
        126.947042,
        128.730979,
        126.969033,
        128.589413,
        129.367107,
        127.152192,
        126.634283,
        127.142540,
        126.765792,
        126.944109,
        126.699044,
        126.972269,
        127.002064,
        126.930871,
        129.030800,
        127.409955,
        127.013910,
        126.680589,
        126.921102,
        127.073069
    ]
    
    static let cinemaCodeList: [String : [String]] = ["광주극장" : ["indieart","000066"] , "광주독립영화관" : ["indieart","000054"] , "더숲아트시네마" : ["indieart","000065"] , "씨네아트리좀" : ["indieart","000053"] , "아트하우스모모" : ["indieart","000067"] , "안동중앙아트시네마" : ["indieart","000051"] , "에무시네마" : ["indieart","000069"] , "오오극장" : ["indieart","000059"] , "인디플러스포항" : ["indieart","000057"] , "인디플러스천안" : ["indieart","000068"] , "인천미림극장" : ["indieart","000052"] , "전주디지털독립영화관" : ["indieart","000061"] , "판타스틱큐브" : ["indieart","000056"] , "필름포럼" : ["indieart","000070"] , "헤이리시네마" : ["indieart","000071"] , "씨네큐브광화문" : ["cinecube","000003"] , "오르페오한남" : ["monoplex","000096"] , "라이카시네마" : ["spacedog","000072"] , "모퉁이극장" : ["etc","000097"] , "씨네인디U" : ["etc","000098"] , "아리랑시네센터" : ["etc","000088"] , "영화공간주안" : ["etc","000094"] , "KT&G상상마당시네마" : ["etc","000089"] , "KU시네마테크" : ["etc","000102"]  ]
}
