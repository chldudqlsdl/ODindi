//
//  IndieCinema.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/6/24.
//

import Foundation
import CoreLocation

struct IndieCinema: Hashable {

    let id: Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let code: [String]
    let instagram: String
    let map: String
    let address: String
    var distance: Double = 0
    
    // distance를 파라미터로 받아 km 단위로 환산하여 리턴, 도보로는 몇분 소요되는지 리턴하는 메서드
    func distanceWithTime() -> (distanceLabel: String, timeLabel: String) {
        let distance = Int(self.distance)
                
        var distanceResult = ""
        var timeResult = ""
        let walkingSpeedPerMinute = 5000.0 / 60.0
        
        if distance < 1000 {
            distanceResult = String(distance) + "m"
        } else if distance >= 1000 && distance < 10000  {
            distanceResult = String(format: "%.1f", Double(distance) / 1000) + "km"
        } else {
            distanceResult = String(format: "%.0f", Double(distance) / 1000) + "km"
        }
        
        if distance < 5000 {
            timeResult = "도보 \(String(Int((self.distance / walkingSpeedPerMinute).rounded())))분 거리에 있어요! 🥳"
        } else {
            timeResult = "조금 거리가 있네요... 😅"
        }
        return (distanceResult, timeResult)
    }
}

extension IndieCinema {
    
    // 독립영화관 목록
    static var list: [IndieCinema] {
        var cinemas: [IndieCinema] = []
        for (index, name) in IndieCinemaData.nameList.enumerated() {
            cinemas.append(IndieCinema(id: index, name: name, coordinate: CLLocationCoordinate2D(latitude: IndieCinemaData.latitudeList[index], longitude: IndieCinemaData.longitudeList[index]), code: IndieCinemaData.cinemaCodeList[name] ?? ["indieart","000057"], instagram: IndieCinemaData.instagramList[name] ?? "", map: IndieCinemaData.mapList[name] ?? "", address: IndieCinemaData.addressList[name] ?? "" ))
        }
        return cinemas
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: IndieCinema, rhs: IndieCinema) -> Bool {
        return lhs.id == rhs.id 
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
        "KU시네마테크",
        "시티극장",
        "시네마엠엠"
    ]
    
    static let latitudeList : [Double] = [
        35.149788,
        35.146904,
        37.654235,
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
//        37.533965,
        37.565135,
        35.100483,
        36.320947,
        37.600234,
        37.461238,
        37.550888,
        37.542888,
        37.500379,
        34.807876
    ]
    
    static let longitudeList : [Double] = [
        126.912410,
        126.922060,
        127.061447,
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
//        127.002064,
        126.930871,
        129.030800,
        127.409955,
        127.013910,
        126.680589,
        126.921102,
        127.073069,
        127.026914,
        126.429572
    ]
    
    static let cinemaCodeList: [String : [String]] = ["광주극장" : ["indieart","000066"] , "광주독립영화관" : ["indieart","000054"] , "더숲아트시네마" : ["indieart","000065"] , "씨네아트리좀" : ["indieart","000053"] , "아트하우스모모" : ["indieart","000067"] , "안동중앙아트시네마" : ["indieart","000051"] , "에무시네마" : ["indieart","000069"] , "오오극장" : ["indieart","000059"] , "인디플러스포항" : ["indieart","000057"] , "인디플러스천안" : ["indieart","000068"] , "인천미림극장" : ["indieart","000052"] , "전주디지털독립영화관" : ["indieart","000061"] , "판타스틱큐브" : ["indieart","000056"] , "필름포럼" : ["indieart","000070"] , "헤이리시네마" : ["indieart","000071"] , "씨네큐브광화문" : ["cinecube","000003"] , "오르페오한남" : ["monoplex","000096"] , "라이카시네마" : ["spacedog","000072"] , "모퉁이극장" : ["etc","000097"] , "씨네인디U" : ["etc","000098"] , "아리랑시네센터" : ["etc","000088"] , "영화공간주안" : ["etc","000094"] , "KT&G상상마당시네마" : ["etc","000089"] , "KU시네마테크" : ["etc","000102"], "시티극장" : ["etc","000133"], "시네마엠엠" : ["etc","000146"]]
    
    static let instagramList : [String : String] = [
        "광주극장" : "https://instagram.com/cinema_gwangju_1933?igshid=MzRlODBiNWFlZA==",
        "광주독립영화관" : "https://instagram.com/gjcinema?igshid=MzRlODBiNWFlZA==",
        "더숲아트시네마" : "https://instagram.com/deosup_artcinema?igshid=MzRlODBiNWFlZA==",
        "씨네아트리좀" : "https://instagram.com/espacerhizome?igshid=MzRlODBiNWFlZA==",
        "아트하우스모모" : "https://instagram.com/arthousemomo?igshid=MzRlODBiNWFlZA==",
        "안동중앙아트시네마" : "https://instagram.com/joongangcinema.andong?igshid=MzRlODBiNWFlZA==",
        "에무시네마" : "https://instagram.com/emuartspace?igshid=MzRlODBiNWFlZA==",
        "오오극장" : "https://instagram.com/55cine?igshid=MzRlODBiNWFlZA==",
        "인디플러스포항" : "https://instagram.com/pohang_culture?igshid=MzRlODBiNWFlZA==",
        "인디플러스천안" : "https://instagram.com/indieplusca?igshid=MzRlODBiNWFlZA==",
        "인천미림극장" : "https://www.instagram.com/milimcine/",
        "전주디지털독립영화관" : "https://www.jeonjucinecomplex.kr/",
        "판타스틱큐브" : "https://instagram.com/__fantastic_cube?igshid=MzRlODBiNWFlZA==",
        "필름포럼" : "https://www.instagram.com/filmforum_cinema/",
        "헤이리시네마" : "https://www.instagram.com/heyri_cinema/?hl=ko",
        "씨네큐브광화문" : "https://instagram.com/cinecube_kr?igshid=MzRlODBiNWFlZA==",
        "오르페오한남" : "https://instagram.com/ode.orfeo?igshid=MzRlODBiNWFlZA==",
        "라이카시네마" : "https://instagram.com/laikacinema?igshid=MzRlODBiNWFlZA==",
        "모퉁이극장" : "https://instagram.com/corner_theater?igshid=MzRlODBiNWFlZA==",
        "씨네인디U" : "https://instagram.com/cineindieu?igshid=MzRlODBiNWFlZA==",
        "아리랑시네센터" : "https://instagram.com/arirang_cine?igshid=MzRlODBiNWFlZA==",
        "영화공간주안" : "https://instagram.com/cinespacejuan?igshid=MzRlODBiNWFlZA==",
        "KT&G상상마당시네마" : "https://instagram.com/sangsangcinema?igshid=MzRlODBiNWFlZA==",
        "KU시네마테크" : "https://instagram.com/kucinema?igshid=MzRlODBiNWFlZA==",
        "시티극장" : "https://www.instagram.com/citycinema.kr/",
        "시네마엠엠" : "https://www.instagram.com/cinemamm.official/"
    ]
    
    static let mapList : [String : String] = [
        "광주극장" : "https://m.place.naver.com/place/11830496",
        "광주독립영화관" : "https://m.place.naver.com/place/1528167363",
        "더숲아트시네마" : "https://m.place.naver.com/place/1015940361",
        "씨네아트리좀" : "https://m.place.naver.com/place/37383447",
        "아트하우스모모" : "https://m.place.naver.com/place/12948307",
        "안동중앙아트시네마" : "https://m.place.naver.com/place/34635294",
        "에무시네마" : "https://m.place.naver.com/place/37842043",
        "오오극장" : "https://m.place.naver.com/place/35966761",
        "인디플러스포항" : "https://m.place.naver.com/place/569933553",
        "인디플러스천안" : "https://m.place.naver.com/place/98309050",
        "인천미림극장" : "https://m.place.naver.com/place/33315469",
        "전주디지털독립영화관" : "https://m.place.naver.com/place/13112714",
        "판타스틱큐브" : "https://m.place.naver.com/place/38488228",
        "필름포럼" : "https://m.place.naver.com/place/11625927",
        "헤이리시네마" : "https://m.place.naver.com/place/38257172",
        "씨네큐브광화문" : "https://m.place.naver.com/place/13182210",
        "오르페오한남" : "https://m.place.naver.com/place/1017816573",
        "라이카시네마" : "https://m.place.naver.com/place/1156408497",
        "모퉁이극장" : "https://m.place.naver.com/place/1303271354",
        "씨네인디U" : "https://m.place.naver.com/place/1927181014",
        "아리랑시네센터" : "https://m.place.naver.com/place/11622504",
        "영화공간주안" : "https://m.place.naver.com/place/12035642",
        "KT&G상상마당시네마" : "https://m.place.naver.com/place/1361168366",
        "KU시네마테크" : "https://m.place.naver.com/place/19563767",
        "시티극장" : "https://m.place.naver.com/place/1776840393",
        "시네마엠엠" : "https://m.place.naver.com/place/1232809531"
    ]
    
    static let addressList : [String : String] = [
        "광주극장" : "광주광역시 동구 충장로46번길 10",
        "광주독립영화관" : "광주광역시 동구 제봉로 96 광주영상복합문화관 6층",
        "더숲아트시네마" : "서울특별시 노원구 노해로 480 조광빌딩 B",
        "씨네아트리좀" : "경상남도 창원시 마산합포구 동서북14길 24",
        "아트하우스모모" : "서울특별시 서대문구 이화여대길 52 이화여자대학교 ECC B402",
        "안동중앙아트시네마" : "경상북도 안동시 문화광장길 45",
        "에무시네마" : "서울특별시 종로구 경희궁1가길 7",
        "오오극장" : "대구광역시 중구 국채보상로 537",
        "인디플러스포항" : "경상북도 포항시 북구 서동로 83",
        "인디플러스천안" : "충청남도 천안시 동남구 중앙로 111 천안시영상미디어센터",
        "인천미림극장" : "인천광역시 동구 화도진로 31",
        "전주디지털독립영화관" : "전북 전주시 완산구 고사동 전주객사3길22 전주영화제작소 4층",
        "판타스틱큐브" : "경기 부천시 길주로 210 1층 판타스틱큐브",
        "필름포럼" : "서울특별시 서대문구 성산로 527 하늬솔빌딩 A동 지하1층",
        "헤이리시네마" : "경기도 파주시 탄현면 헤이리마을길 93-119 커피공장 103 카페 3층, 헤이리시네마",
        "씨네큐브광화문" : "서울특별시 종로구 새문안로 68 흥국생명빌딩 지하2층",
        "오르페오한남" : "서울특별시 용산구 대사관로 35 사운즈한남 5층",
        "라이카시네마" : "서울특별시 서대문구 연희로 8길 18",
        "모퉁이극장" : "부산광역시 중구 광복중앙로13 3층",
        "씨네인디U" : "대전광역시 중구 계백로 1712 기독교연합봉사 회관 1층",
        "아리랑시네센터" : "서울특별시 성북구 아리랑로 82",
        "영화공간주안" : "인천광역시 미추홀구 미추홀대로 716 메인프라자 7층",
        "KT&G상상마당시네마" : "서울특별시 마포구 어울마당로 65 상상마당 홍대 지하4층",
        "KU시네마테크" : "서울특별시 광진구 능동로 120 건국대학교 예술문화관 B108",
        "시티극장" : "서울 강남구 강남대로 422 지하2층",
        "시네마엠엠" : "전남 목포시 백년대로 394 2층"
    ]
}
