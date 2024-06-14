
# 어디인디<img src="https://github.com/chldudqlsdl/ODindi/assets/83645833/8587f87b-2694-4b3f-b1fc-74d39d429770" align=left width=120>

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

## ✨ 기능 
|가까운 영화관 탭 (메인탭)|지도 탭|북마크 탭|
|-|-|-|
|내 위치에서 가까운 독립(인디)영화관 <br> 세곳의 상영정보를 볼 수 있습니다|전국의 모든 독립영화관의 정보를 <br>지도에서 볼 수 있습니다 | 보고싶어요(북마크)한 영화가 <br> 이곳에 보관됩니다|
|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/74a48c0a-8091-4d23-a479-dc087f51533f">|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/4f6932f3-fd25-403a-84ea-c760d6e76564">|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/811c02ff-02a3-498e-b69d-ac3b21ea2c8d">|
| - 300m 이동시 마다 위치 업데이트 <br> - 상영날짜 ∙ 정보 ∙ 영화상세정보 크롤링 <br> - 보고싶어요(북마크) 기능 <br> - DiffableDataSource | - 전국 26개 독립 영화관 Annotation <br> - 인스타그램 ∙ 네이버지도 웹뷰 연결 <br> - 메인탭과 동일한 보고싶어요 기능 | - RealmDB 에 저장된 데이터 표출 <br> - 보고싶어요 취소시 메인탭 업데이트|

<br />


## 🤔 개발과정의 고민

<details>
<summary><strong style="font-size: 1.2em;">메인탭</strong></summary>

## 간헐적으로 날짜 ∙ 포스터 안나오던 에러 픽스

<aside>
💡 시뮬레이터 재생버튼을 눌러 앱을 실행하면 높은 확률(가끔 됨)로 날짜 ∙ 포스터가 표출되지 않는 이슈

</aside>

### 어디서 문제가 발생하나

- flatMap 으로 값이 전달이 안되고 있음을 파악

```swift
selectedCinema
    .do(onNext: { [weak self] _ in self?.didSelectDate.onNext(0) })
    .flatMap { cinema in
        return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
    }
    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    .do(onNext: { [weak self] _ in self?.isLoading.onNext(false)})
    .bind(to: selectedCinemaCalendar)
    .disposed(by: disposeBag)
```

### BehaviorSubject

- 기존에 `selectedCinema` 가 `PublishSubject` 로 정의되어 있는데
- 이를 `BehaviorSubject` 로 바꾸면 에러가 해결 됨
- **그렇다면 Subject 가 넘겨주는 값 보다 Subscribe 가 늦게 일어난다는 말인데…**

```swift
var selectedCinema: PublishSubject<IndieCinema> { get }
```

### debug

- **debug 를 해보면 실제로 selectedCinema 에 값이 전달되는 시점이, 구독 되는 시점보다 빠르다!**
    - PublishSubject 이기 때문에 값이 전달되고 나서, 구독이 되면 이전에 전달됨 값은 사라진다
    
    <img width="600" alt="ss" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/e6a46f78-68ed-4e4d-ae7d-ead7d73abccb">

    
- 근데 콘솔을 보면 74 ∙ 79 빼고 모든 Observable 은 대부분 vm 이 Init 되자마자 곧바로 subscribed 가 됨
    - 심지어 viewWillAppear 보다도 빠르게
- 얘네의 공통점 `.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))` 가 작성된 코드
    - `.subscribe(on:)` 은 이상의 코드에 있어서 구독이 지정한 스케줄러(스레드)에서 돌아가게 만든다
    - 스레드를 바꿔주는 과정이 모종의 이유로 subscribe 를 지연시키고, 구독보다 값 전달이 먼저 일어나면서 값은 무시되고 이후의 스트림이 진행이 안되면서 화면에 아무것도 안뜨게 되는 것

### `.subscribe(on:)`

- 얘를 작성해주면 가장 위에 있는 Observable 의 이벤트 처리가 지정된 스레드에서 시작된다
    - 별다른 지시가 없으면 이하의 모든 스트림은 지정된 스레드에서 진행된다
- 현재 프로젝트에서는 스레드를 바꿔주려다 시간이 지연되어 아무 값도 못 받아 온다
    - 미스테리한 건 가끔 될 때는 지맘대로 `.subscribe(on:)` 을 써줘도 mainThread 에서 돌더라
        - 그래서 될 때 보라색 메시지가 나왔던 것

### 해결책

- `CinemaService.shared.fetchCinemaCalendar(cinema: cinema)` 에 직접 써줬다, 이 작업은 시간이 많이 소모되는 것이랑 상관 없기에 절대 에러가 발생할 일이 없다

```swift
.flatMap { cinema in
        return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
```
---

## flatMap → flatMapLatest

### 영화관 변경시 날짜에 맞는 영화 정보가 제대로 표출되지 않는 문제 발생

- 원인 : flatMap 에 Event 가 들어가는 순서대로 값이 튀어나오는게 아니라 순서를 무시하고 빨리 도착하는대로 값이 튀어나온다

### flatMap → flatMapLatest

- flatMap
    - 초록색 마블이 먼저 들어가도 파란색 마블보다 늦게 나오기도 함
    
    <img width="748" alt="3" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/8a85fa7f-fb7c-41e8-95ec-21facf3be485">
    
- flatMapLatest
    - 이름 그대로 최신의 것만 flatMap 한다!
    - 초록색 마블을 처리하는 중 파란색 마블이 들어오면 초록색 마블의 작업을 중단한다
    
    <img width="748" alt="3" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/f1fbe418-c1d2-4091-a97a-412788777ba7">
    

### 코드

```swift
Observable
    .combineLatest(selectedCinema, selectedCinemaCalendar, didSelectDate) { cinema, calendar, dateIndex -> (IndieCinema, String)? in
        guard !calendar.alldays.isEmpty else { return nil }
        return (cinema, calendar.alldays[dateIndex])
    }
    .compactMap { $0 }
    .flatMapLatest { cinemaAndDate in
        return CinemaService.shared.fetchCinemaSchedule(cinema: cinemaAndDate.0, date: cinemaAndDate.1)
    }
    .bind(to: selectedDateMovieSchedule)
    .disposed(by: disposeBag)
```
---
## dequeueReusableCell

<aside>
💡 에러발생 : Cell 의 UI에 TapGesture 를 연결하여 이를 VC 로 보내고 다시 VM 으로 보내서 프린트를 하는데 이벤트가 자꾸 여러번 찍힌다

</aside>

### 범인은 bind()?

- TapGeture 가 발생하면, 이를 VC 로 보내는데, bind() 함수가 여러번 실행되어서 한번 터치를 해도 여러번 VC 로 넘어가는 듯
    - 근데 대체 왜 여러번 실행되는 겨?

```swift
// MovieCell

override init(frame: CGRect) {
    super.init(frame: frame)
    layout()
    bind()
}

func bind() {
    watchLaterTapGesture.rx.event
        .bind { [weak self] _ in
            guard let movieSchedule = self?.movieSchedule else { return }
            self?.watchLaterButtonTapped.onNext(movieSchedule.code)
        }
        .disposed(by: disposeBag)
}
```

### 혹시 dequeueReusableCell bind() 가 여러번 실행되나?

- MovieCell 은 dequeueReusableCell 의 형태로 구성되어 있다
- 이를 사용하면 실제 갯수만큼 셀을 만드는 것이 아니라, 조금만 만들어서 이를 계속 재활용한다
- 아 그렇다면 Cell이 Reuse 되면, bind() 함수가 실행되는 건가?

### 응 아니야~

- bind() 함수에 프린트를 찍어보면, 여러번 실행되지 않는다
- 게다가 bind() 는 현재 init() 에 올라가 있고, init 은 5번? 정도 생성됨 → Reusable 하니까

### 진짜 범인은 바로

- CinemaVC 에서 cell 의 Subject 값을 받고 있는데, cell 이 리유즈 될 때 얘가 계속 생겨났던 것…

```swift
movieDataSource = UICollectionViewDiffableDataSource(collectionView: movieCollectionView, cellProvider: { collectionView, indexPath, item in
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
    cell.movieSchedule = item
    
    cell.watchLaterButtonTapped
        .bind { movieCode in
            self.viewModel.watchLaterButtonTapped.onNext(movieCode)
        }
        .disposed(by: cell.disposeBag)
 
    return cell
})
```

### 어떻게 해결하나요?

- cell 이 리유즈될 때 이전의 인스턴스가 가지고 있던 스트림을 모두 dispose 시켜버리자
    - 위의 진범 스트림도 cell.disposeBag 에 들어가 있다!

```swift
override func prepareForReuse() {
    self.disposeBag = DisposeBag()
}
```

- 그리고 하나더
    - bind() 를 configure 로 옮겨주기 → 옮겨주지 않으면 bind()는 이닛에 작성되어 있기 때문에 한번 스트림이 사라지면 다시 회복이 안된다!

</details>

<details>
<summary><strong style="font-size: 1.2em;">지도탭</strong></summary>
  

## 라이브러리 쓰지 않고 RxCocoa 와 MKMapViewDelegate 연결하기
### Proxy 만들기

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
### Delegate 함수와 연결

```swift
extension Reactive where Base: MKMapView {
    
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: self.base)
    }
    
    var didSelect: Observable<MKAnnotationView> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:didSelect:)))
            .map { params in
                print(params)
                return params[1] as! MKAnnotationView
            }
    }
}
```
</details>
  
<details>
<summary><strong style="font-size: 1.2em;">북마크탭</strong></summary>

## DiffableDataSource & Realm

<aside>
💡 북마크(보고싶어요) 한 영화를 RealmDB 에 저장하는데, 삭제를 하고 DiffableDataSource 가 갱신되는 과정에서 크래시가 발생

</aside>

### 문제상황

- Realm 과 DiffableDataSource 를 함께 사용하고 있을 때
- Realm 의 데이터를 삭제하면
- 에러메시지 : Thread 1: "Object has been deleted or invalidated.”

### 원인

- **DiffableDataSource 는 데이터가 변하면 이전에 가지고 있던 상태와 비교해서 뷰를 갱신함**
- **Realm Object 로 생성된 객체는 삭제후 Realm DB 에서 참조할 수 없도록 예외처리가 들어가 있다**
- **삭제된 객체에 DiffableDataSource 가 접근하려 해서 충돌이 생기는 것**

### 해결방법

- 데이터 모델을 수정하여 삭제시 isDeleted = true 로 만들어 놓고 (삭제는 안된 상태), DiffableDataSource 업데이트가 끝난후 (viewDidAppear 이후)  isDeleted == true 인 인스턴스 삭제
  - 이 방법을 채택함!
    
    ```swift
    class WatchLater: Object {
        
        @Persisted(primaryKey: true) var movieCode: String
        @Persisted var date: Date = Date()
        @Persisted var isDeleted: Bool = false
        
        convenience init(_ movieCode: String) {
            self.init()
            self.movieCode = movieCode
        }
    }
    ```
    
- `applySnapshotUsingReloadData` 을 사용
    - iOS15 이상 에서만 사용이 가능해 선택하지 않음
    - DiffableDataSource 의 애니메이션도 사용할 수 없음
 
</details>
<details>
<summary><strong style="font-size: 1.2em;">빌드</strong></summary>

## 라이브러리는 두 종류가 있다
### 에러발생

- 지금까지 시뮬레이터로만 빌드하다가 처음으로 실기기 빌드하는 과정에서 아래와 같은 에러가 발생
  <img width="300" alt="0" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/7abed995-3e26-482b-96b2-74c646894a8f">
- 타겟 → 라이브러리로 가보면
- RxCocoa 와 같이 RxCocoa-Dynamic 이 있는 것을 알 수 있다
    - 그럼 라이브러리가 여러 종류라는 건가?


  
<img width="300" alt="5" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/4eaf142f-cc2f-48e8-90f7-44a856723c33">

### 문제해결

- 그러고보면 지금까지 spm 을 통해 라이브러리 추가할 때 무지성으로 여러개의 라이브러리를 추가해왔었고 그 과정에서 복수의 라이브러리가 매번 추가되었던 것
- Dynamic 이 적힌 라이브러리 들을 저 리스트에서 빼주면 빌드는 제대로 된다
- 참고로 시뮬레이터는 실 기기 빌드와는 많이 달라서 라이브러리가 복수로 올라가도 알아서 잘 처리하는 듯…

### Library?

- Xcode Target 의 일부로 빌드되지 않은 코드 및 데이터 조각
- 라이브러리와 앱의 소스코드용 파일을 병합하는 프로세스를 Link 라고 함
    - 컴파일 할 때 Link 실행
- 이 Link 방식에 따라 두가지 종류의 라이브러리로 분류된다
    - Static - 정적
    - Dynamic - 동적
### Static Library

<img width="300" alt="0" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/67d654cb-63ae-456f-9b99-c68791126931">

- 여러 라이브러리들이 Static linker 로 병합되고
- 병합된 결과가 내가 작성한 코드와 합쳐져서 executable file 이 만들어짐
- 큰 exe file → 느린 시작 시간 + 큰 메모리 공간
- Library Update 시 다시 Link 해야 결과가 반영

### Dynamic Library

<img width="300" alt="0" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/f2394658-3639-4b1d-a03a-b044547233c8">

- linker 로 병합되는 것은 똑같은데
- 병합된 결과의 참조만 exe file 에 포함됨 → 별도의 라이브러리 파일이 존재
- 그래서 매번 앱을 실행할 때 마다 주소 공간에 로드되고, 런치하는데 시간이 오래 걸린다
  
### 라이브러리 별로 빌드 산출물 폴더 ∙ 실행 파일이 어떻게 바뀌는지 실험
  
[실험 결과 링크](https://slowsteadybrown.notion.site/Library-63da20ea88374e91924bf3f7247f8e15?pvs=4)
  
</details>
<details>
<summary><strong style="font-size: 1.2em;">전체 개발일지 보기</strong></summary>

  
[전체 개발 일지 링크](https://slowsteadybrown.notion.site/266fc8054a4240d8aca1cc07f0155d0e?pvs=4)
  
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
