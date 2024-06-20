
# 어디인디<img src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/f2007359-317b-4148-b405-8f05871715fb" align=left width=120>

> 내 주변의 독립(인디)영화관을 찾아주는 서비스 🍿  
> 1인 개발 (24.05.05 ~ 24.06.11)

<br />

## 💭 소개

> 우리 주변에는 특별한 영화들을 상영하는 작은 독립영화관이 숨어 있습니다  
> 때로는 크고 유명한 영화관을 벗어나 작은 영화관에서 인생 영화를 만날지도 몰라요
> 
> 내 위치에서 가까운 독립영화관 세곳의 상영 정보를 빠르게 확인할 수 있고  
> 지도에서는 전국의 모든 독립영화관들의 정보를 한눈에 확인할 수 있어요
> 
> **이번 주말에는 어디인디와 함께 가까운 독립영화관으로 떠나보는건 어떨까요?**



<br />

## ✨ 기능 및 구현사항
<img src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/882b842e-0129-4a9d-92d9-ca8a302cba6d" >

**0. 아키텍쳐 및 주요기술** 
  - MVVM 아키텍쳐
 - RxSwift 

**1. 가까운 영화관 탭 (메인탭)** 
  - **내 위치에서 가까운 독립 영화관 세곳의 상영정보를 볼 수 있습니다**
  - CoreLocation 을 활용해 300m 이동마다 근처의 독립영화관 업데이트
  - DiffableDataSource ∙ CompositionalLayout 활용해 영화관 ∙ 상영일 ∙ 영화셀 구현
  - SwiftSoup 을 활용해 독립영화관 영업일 정보 크롤링
  - 영화 상세 정보 보기 ∙ 보고싶어요(북마크) 기능

**2. 지도탭**
  - **지도에서 전국의 모든 독립영화관 정보를 볼 수 있습니다.**
  - mapView 에 전국 모든 독립영화관 데이터를 AnnotationView 로 추가
  - Annotation 선택시 메인뷰와 동일하게 상영정보 표출
  - webView 를 통해 해당 영화관의 인스타그램 ∙ 네이버지도로 연결

**3. 북마크탭**
 - **보고싶어요(북마크)한 영화들이 이곳에 저장됩니다**
  - RealmDB 에 저장된 북마크한 영화 불러오기
  - 보고싶어요 취소시 메인탭을 업데이트하여 취소 사항이 바로 반영되도록 구현


<br />


## 🤔 개발과정의 고민

<details>
<summary><strong style="font-size: 1.2em;">메인탭</strong></summary>

## 고민한 점

### RxSwift 도입으로 얻은 다양한 효과

**RxSwift를 사용해 비동기 작업의 흐름을 명확하게 표현하여 코드의 가독성과 유지보수성을 높임**

`selectedCinema`는`PublishSubject`로, 컬렉션뷰에서 선택된 영화관 인스턴스를 전달받는다. 이 인스턴스는 네트워크 요청을 담당하는 `Observable`에 전달되어 영화관의 상영 일정을 가져온다. 이때 `flatMap` 연산자를 사용하여 네트워크 요청을 비동기적으로 처리하고, `subscribe(on:)`을 통해 백그라운드 스레드에서 실행하도록 지정하였다. 네트워크 요청이 완료되면 결과인 영화관 영업일 리스트를 `selectedCinemaCalendar`라는 `PublishSubject`에 전달한다.

이렇게 RxSwift를 사용하면 비동기 작업의 시작부터 결과 처리까지의 흐름을 한눈에 파악할 수 있어 코드의 가독성과 유지보수성을 향상시킬 수 있었다.

```swift
selectedCinema
    .flatMap { cinema in
        return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
    .do(onNext: { [weak self] _ in self?.isLoading.onNext(false)})
    .bind(to: selectedCinemaCalendar)
    .disposed(by: disposeBag)
```

**RxSwift의 다양한 Operator 를 적절히 사용하여 직관적으로 이해할 수 있는 코드를 작성함**

메인탭의 영화 상영 정보를(포스터 및 상영시간) 표시하기 위해서는 선택된 영화관(`selectedCinema` - Subject), 선택된 영화관의 상영 날짜 리스트(`selectedCinemaCalendar` - Subject), 그리고 선택된 날짜 인덱스(`didSelectDate` - Subject) 이 세가지 데이터가 모두 필요하다. 또한 이 세 데이터 중 하나라도 변경될 때마다 새로운 영화 상영 정보를 표시해야 한다.
이를 위해 `combineLatest` Operator 를 사용해 각 Subject가 방출하는 최신값을 결합한다. 각 Subject의 값이 변할 때마다 새로운 값이 결합되고 이를 통해 새로운 상영 정보를 요청하고 업데이트할 수 있다.
이와 같은 Operator 사용으로 적절한 기능 구현을 함과 동시에 코드의 직관성과 가독성을 높일 수 있었다.

```swift
Observable
    .combineLatest(selectedCinema, selectedCinemaCalendar, didSelectDate) { cinema, calendar, dateIndex -> (IndieCinema, String)? in
        return (cinema, calendar.alldays[dateIndex])
    }
    .flatMapLatest { cinemaAndDate in
        return CinemaService.shared.fetchCinemaSchedule(cinema: cinemaAndDate.0, date: cinemaAndDate.1)
    }
    .bind(to: selectedDateMovieSchedule)
    .disposed(by: disposeBag)
```

## TroubleShooting

### **flatMap 에서 flatMapLatest 로 변경**

**문제상황**

A코드를 보면 ‘선택된 영화관(`selectedCinema` - Subject)’ 에 따라서 ‘상영 날짜 리스트(`selectedCinemaCalendar` - Subject)’ 가 바뀌도록 연동되어 있다. 이는 영화관 마다 상영 날짜 리스트가 다르기 때문이다.
이 때문에  `selectedCinema` 가 바뀐다면 B코드에서는 `selectedCinema` 가 바뀔 때 한 번, `selectedCinemaCalendar` 가 바뀔 때 한 번, 총 두 번 순서대로 값이 전달되고 flatMap 을 통한 요청도 두 번 수행된다. 
B코드는 기존에 flatMapLatest 가 아니라, flatMap 으로 작성되었는데, flatMap 의 경우 값을 전달 받는 순서와 상관없이 비동기 처리가 끝난 순서대로 결과 값이 나온다. 이 때문에 `selectedCinemaCalendar` 가 바뀔 때 결합된 값에 의한 비동기 처리 결과 값이 먼저 나오고, 이후에 `selectedCinema` 가 바뀔 때 결합된 값에 의한 비동기 처리 결과 값이 나오면 다른 영화관의 상영 날짜 리스트를 기반으로 비동기 처리를 요청한 것이 된다.

**해결방법**

이 때문에 flatMap 을 flatMapLatest 로 변경했으며, 이는 결합된 값이 flatMapLatest 넘어간 순서에 따라 결과 값을 리턴해주는 것을 보장한다. 이에 더해 flatMapLatest 내부의 로직을 처리하는 도중  다른 값이 들어오면 기존의 로직 처리를 중단하고 새 값에 대한 로직 처리를 시작하기 때문에 불필요한 작업을 줄이는 효과도 얻을 수 있었다. 

```swift
// A코드
selectedCinema
    .flatMap { cinema in
        return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
    .bind(to: selectedCinemaCalendar)
    .disposed(by: disposeBag)

// B코드 
Observable
    .combineLatest(selectedCinema, selectedCinemaCalendar, didSelectDate) { cinema, calendar, dateIndex -> (IndieCinema, String)? in
        return (cinema, calendar.alldays[dateIndex])
    }
    .flatMapLatest { cinemaAndDate in
        return CinemaService.shared.fetchCinemaSchedule(cinema: cinemaAndDate.0, date: cinemaAndDate.1)
    }
    .bind(to: selectedDateMovieSchedule)
    .disposed(by: disposeBag)
```

### **dequeueReusableCell 과 RxSwift 를 함께 사용할 때 주의점**

```swift
// MainViewController
movieDataSource = UICollectionViewDiffableDataSource(collectionView: movieCollectionView, cellProvider: { collectionView, indexPath, item in
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
    cell.viewModel = MovieCellViewModel(item)
    
    // 영화셀에서 포스터가 탭되면 영화 상세 정보 View 를 띄워줌
    cell.posterTapped
        .bind { [weak self] movieCode in
            self?.present(MovieDetailViewController(viewModel: MovieDetailViewModel(movieCode)), animated: true)
        }
        .disposed(by: cell.disposeBag)
    return cell
})
```

**문제상황**
영화셀의 포스터를 탭하면 탭 여부가 `posterTapped` - Subject 로 전달되어, `MainViewController` 에서 영화 상세 정보 뷰를 present 하도록 구현하였다. 하지만 간헐적으로 포스터를 한번만 탭하였는데도 상세 정보 뷰 컨트롤러(`MovieDetailViewController`) 가 중복되어 생성되는 경우가 발생하였다.

**원인**

원인은 셀이 dequeueReusableCell 이기 때문이다. 셀이 재사용될 때마다 `cell.posterTapped` 의 스트림이 계속 생겨났고 이 때문에 포스터를 여러번 탭한 것과 같은 결과가 발생한 것이다.

**해결방법**

셀이 재사용될 때마다 이전의 셀에서 생성되었던 RxSwift 스트림을 모두 제거해야 한다. 아래의 방식으로 DisposeBag 을 교체해 이전의 스트림을 제거하였다.

```swift
// MovieCell
override func prepareForReuse() {
    self.disposeBag = DisposeBag()
}
```

</details>

<details>
<summary><strong style="font-size: 1.2em;">지도탭</strong></summary>

## 고민한 점

  ### 라이브러리 쓰지 않고 RxSwift 와 Delegate 연결

프로젝트에서 CoreLocation 의 경우 CLLocationManagerDelegate 와 RxSwift 를 연결하기 위해서 RxCoreLocation 라이브러리를 사용하였다. 하지만 라이브러리와 RxSwift 사이의 버전이 맞지 않아 라이브러리 추가가 안되는 경우가 있었고, 향후 버전 문제로 에러가 발생할 수도 있다고 생각하였다. 

지도탭에서는 mapView 의 Annotation이 선택되었을 때의 감지를 MKMapViewDelegate 의 메서드를 통해 수행한다. 이를 위해 라이브러리를 사용하지 않고 직접 MKMapViewDelegate 와 RxSwift 을 연결하는 코드를 작성하였다. 

**MKMapViewDelegate 를 DelegateProxy 로 변환하도록 하는 RxMKMapViewDelegateProxy 클래스** 

```swift
class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    static func registerKnownImplementations() {
        self.register { mapview -> RxMKMapViewDelegateProxy in
            RxMKMapViewDelegateProxy(parentObject: mapview, delegateProxy: self)
        }
    }
    static func currentDelegate(for object: MKMapView) -> MKMapViewDelegate? {
        return object.delegate
    }
    static func setCurrentDelegate(_ delegate: MKMapViewDelegate?, to object: MKMapView) {
        object.delegate = delegate
    }
}
```

**MKMapViewDelegate 의 메서드를 Observable 로 변환하는 확장**

```swift
extension Reactive where Base: MKMapView {
    
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: self.base)
    }
    
    var didSelect: Observable<MKAnnotationView> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:didSelect:)))
            .map { params in
                return params[1] as! MKAnnotationView
            }
    }
}
```

**RxSwift 와 RxMKMapViewDelegateProxy 연결한 사용례**

```swift
mapView.rx.didSelect
    .withLatestFrom(viewModel.coordinate) {(annotationView, coordinate) -> (String, CLLocationCoordinate2D)? in
        return (cinemaName, coordinate)
    }
      .bind { [weak self] (cinemaName, coordinate) in
        self?.configureSheet(cinemaName: cinemaName, coordinate: coordinate)
    }
```

</details>
  
<details>
<summary><strong style="font-size: 1.2em;">북마크탭</strong></summary>

 ## 고민한점

### RealmDB 데이터 삭제시 DiffableDataSource 와의 충돌

기존에는 영화 포스터 하단의 북마크 버튼을 누르면, 해당 영화가 RealmDB 에 추가된다. 북마크에 추가된 영화는 북마크 버튼이 보라색으로 바뀌며, 보라색 처리된 버튼을 누르면 북마크 취소를 해야하므로 해당 영화 인스턴스를 RealmDB 에서 Delete 해주었다.

북마크탭의 북마크된 영화들은 DiffableDataSource 를 통해 표시되고, 데이터에 변화가 일어나면 애니메이션과 함께 변경된 데이터가 표시된다

**문제상황**

그런데 북마크 취소 후 DiffableDataSource 가 변경되는 과정에서 
`Thread 1: "Object has been deleted or invalidated.”`
다음과 같은 에러메시지 표출과 함께 앱이 크래쉬된다

**원인**

DiffableDataSource 는 데이터가 변하면 변경전 데이터와 변경후 데이터의 상태를 비교해서 뷰를 갱신한다. 그래서 DiffableDataSource 변경전의 삭제된 데이터의 RealmObject 인스턴스에 접근하려 하는데, RealmDB에서는 삭제된 데이터에 대해서는 참조할 수 없도록 예외처리가 되어 있어 크래쉬가 발생하는 것

**해결방법**

```swift
class WatchLater: Object {
    @Persisted(primaryKey: true) var movieCode: String
    @Persisted var date: Date = Date()
    @Persisted var isDeleted: Bool = false
}
```

위와 같이 RealmObject 의 데이터 모델을 변경하여, 북마크 취소시 바로 DB 에서 삭제하지 않고 임시로 프로퍼티 `isDeleted` 만 true 로 바꿔준다. DiffableDataSource 를 통한 뷰의 갱신이 일어난 이후에 `isDeleted` 가 true 인 인스턴스만 따로 DB에서 삭제해주면 된다.
</details>
<details>
<summary><strong style="font-size: 1.2em;">빌드</strong></summary>

## TroubleShooting

### 두 라이브러리 간의 충돌

**문제상황**

<img src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/b2598d1d-e76f-49ac-915e-511c95f2e70a" width=200>

계속해서 시뮬레이터로만 빌드하다가, 출시직전 실기기 빌드를 하는 과정에서 에러가 발생

**원인 및 문제해결**

<img src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/95afb076-be58-4560-bd28-cda1984c5169" width=400>

TARGET → Libraries 를 살펴보면 RxCocoa 와 RxCocoa-Dynamic 두가지의 라이브러리가 추가되어 있음을 알 수 있다. 두가지의 라이브러리를 모두 추가하려고 시도해서 발생한 에러이며 둘 중 하나의 라이브러리만 남기고 나머지를 삭제하면 문제를 해결된다

**라이브러리의 종류와 각각의 특징**

라이브러리는 Xcode Target 의 일부로 빌드되지 않은 코드 및 데이터 조각이다. 라이브러리와 앱의 소스코드용 파일을 병합하는 프로세스를 Link 라고 하는데, 이 Link 방식에 따라 두가지 종류의 라이브러리로 분류된다. 각 라이브러리의 특징에 따라 취사선택해서 사용할 수 있다.

**StaticLibrary**

여러 라이브러리들이 Static linker 로 병합되고 병합된 결과가 내가 작성한 코드와 합쳐져서 executable file 이 만들어진다. exefile 이 커지므로, 메모리 공간이 커지고, 시작시간이 느리다. Library Update 시 다시 Link 해야 결과가 반영된다

**Dynamic Library**

linker 로 병합되는 것은 똑같은데, 병합된 결과의 참조만 exe file 에 포함되고 별도의 라이브러리 파일이 존재한다. 그래서 매번 앱을 실행할 때 마다 주소 공간에 로드되고, 런치하는데 시간이 오래 걸린다 (보통 StaticLibrary 보다 런치 시간이 더 길다)

**라이브러리 별로 빌드 산출물 폴더 ∙ 실행 파일이 어떻게 바뀌는지 실험**

**[실험 결과 링크](https://slowsteadybrown.notion.site/Library-63da20ea88374e91924bf3f7247f8e15?pvs=4)**
  
</details>
<details>
<summary><strong style="font-size: 1.2em;">전체 개발일지 보기</strong></summary>

<br />
  
**[전체 개발 일지 링크](https://slowsteadybrown.notion.site/266fc8054a4240d8aca1cc07f0155d0e?pvs=4)**
  
</details>

<br />

## 📚 Architecture ∙ Framework ∙ Library

| Category| Name | Tag |
| ---| --- | --- |
| Architecture| MVVM |  |
| Framework| UIKit | UI |
| | CoreLocation | Location    |
| | MapKit | Map |
|Library | RxSwift |Reactive  |
| | SwiftSoup | HTML  |
| | RealmSwift | Database |
| | SnapKit | Layout |
| | Kingfisher | Image Caching |

<br />

## 🗂 폴더 구조
~~~
📦Odindi
 ┣ 📂App
 ┣ 📂Network
 ┣ 📂Data
 ┣ 📂Model
 ┣ 📂Presentation
 ┃ ┣ 📂MainTabBarScene
 ┃ ┣ 📂MainViewScene
 ┃ ┣ 📂MapViewScene
 ┃ ┗ 📂BookmarkScene
 ┣ 📂Utility
 ┗ 📂Resource
~~~

<br />

## 📺 앱 구동 화면 
|가까운 영화관 탭 (메인탭)|지도 탭|북마크 탭|
|-|-|-|
|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/74a48c0a-8091-4d23-a479-dc087f51533f">|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/4f6932f3-fd25-403a-84ea-c760d6e76564">|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/811c02ff-02a3-498e-b69d-ac3b21ea2c8d">|


