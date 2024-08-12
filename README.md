
# オディンディ<img src="https://github.com/chldudqlsdl/ODindi/assets/83645833/c07492ff-91c2-4f9a-b934-d05e14a3e49e" align=left width=150>

> 近くの独立（インディー）映画館を探してくれるサービス (
「オディ - 韓国語」は日本語で「どこ」です。) 🍿  
>1人開発 （24.05.05 ～ 24.06.11）  
> [📺 アプリ紹介動画のリンク(YouTube)](https://www.youtube.com/watch?v=2q0a5HQbgXo&t=80s)

<br />

## 💭 紹介

> 私たちの周りには、特別な映画を上映している小さな独立系映画館が隠れています。  
> 時には、大きくて有名な映画館を離れて、小さな映画館で人生の一本に出会えるかもしれません。
> 
> 現在地から近い独立映画館3軒の上映情報を素早く確認でき、  
> 地図では全国のすべての独立映画館の情報を一目で確認できます。
> 
> **今週末は、オディンディと一緒に近くの独立映画館に足を運んでみませんか？**  
> [🛒 App Storeのリンク](https://apps.apple.com/jp/app/id6504532476)  



<br />

## ✨ 機能と実装事項
<img src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/0873a3e6-8c93-4826-853e-d6c765bd495e" >

**0. アーキテクチャと主要技術** 
  - MVVMアーキテクチャ
  - RxSwift

**1. 近くの映画館タブ（メインタブ）** 
  - **現在地から近い独立映画館3軒の上映情報を確認できます。**
  - CoreLocationを活用し、300m移動ごとに近くの独立映画館を更新
  - DiffableDataSource・CompositionalLayoutを活用して、映画館・上映日・映画セルを実装
  - SwiftSoupを活用して独立映画館の営業日情報をクロール
  - 映画詳細情報表示・「見たい」機能（ブックマーク）

**2. 地図タブ**
  - **地図で全国のすべての独立映画館の情報を確認できます。**
  - mapViewに全国の独立映画館データをAnnotationViewとして追加
  - Annotationを選択すると、メインビューと同様に上映情報を表示
  - webViewを通じて、該当映画館のInstagram・NAVER地図にリンク

**3. ブックマークタブ**
  - **「見たい」（ブックマーク）した映画がここに保存されます。**
  - RealmDBに保存されたブックマークした映画を読み込み
  - 「見たい」を解除すると、メインタブを更新して解除内容が即座に反映されるように実装


<br />


## 🤔 開発過程での悩み(ぜひお読みください🙏)
<details>
<summary><strong style="font-size: 1.2em;">RxSwift導入によって得られたさまざまな効果</strong></summary>
<br>

**RxSwiftを使用して非同期作業の流れを明確に表現し、コードの可読性と保守性を向上させました。**

`selectedCinema`は`PublishSubject`として、コレクションビューで選択された映画館のインスタンスを受け取ります。このインスタンスはネットワークリクエストを担当する`Observable`に渡され、映画館の上映スケジュールを取得します。このとき、`flatMap`演算子を使用して非同期的にネットワークリクエストを処理し、`subscribe(on:)`を通じてバックグラウンドスレッドで実行するように指定しました。ネットワークリクエストが完了すると、結果として得られた映画館の営業日リストを`selectedCinemaCalendar`という`PublishSubject`に渡します。

このようにRxSwiftを使用することで、非同期作業の開始から結果処理までの流れを一目で把握でき、コードの可読性と保守性を向上させることができました。

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

**RxSwiftのさまざまなOperatorを適切に使用して、直感的に理解できるコードを作成**

メインタブで映画の上映情報（ポスターおよび上映時間）を表示するためには、選択された映画館（`selectedCinema` - Subject）、選択された映画館の上映日リスト（`selectedCinemaCalendar` - Subject）、そして選択された日付のインデックス（`didSelectDate` - Subject）の3つのデータが必要です。また、この3つのデータのうち1つでも変更があった場合、常に新しい映画上映情報を表示する必要があります。
この目的のために、`combineLatest` Operatorを使用して各Subjectが放出する最新の値を結合します。各Subjectの値が変わるたびに新しい値が結合され、それを基に新しい上映情報をリクエストし、更新することができます。
このようにOperatorを活用することで、適切な機能を実現しながら、コードの直感性と可読性を向上させることができました。

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
</details>

<details>
<summary><strong style="font-size: 1.2em;">flatMapからflatMapLatestに変更</strong></summary>
<br>

**[エラー分析動画リンク(Youtube)](https://youtu.be/RUT8xTWbMJ8?si=zgbSCBlaDCS3nfN5&t=1m04s)**

**問題状況**

Aコードを見ると、「選択された映画館（`selectedCinema` - Subject）」に応じて「上映日リスト（`selectedCinemaCalendar` - Subject）」が変更されるように連動しています。これは映画館ごとに上映日リストが異なるためです。
このため、`selectedCinema`が変更されると、Bコードでは`selectedCinema`が変更されるときに一度、`selectedCinemaCalendar`が変更されるときにもう一度、合計で二回順番に値が伝達され、`flatMap`を通じたリクエストも二回実行されます。
Bコードは従来`flatMapLatest`ではなく`flatMap`で書かれていましたが、`flatMap`の場合、値が伝達される順序に関係なく、非同期処理が終了した順番で結果が返されます。そのため、`selectedCinemaCalendar`が変更されたときに結合された値による非同期処理の結果が先に出て、その後に`selectedCinema`が変更されたときに結合された値による非同期処理の結果が出ると、異なる映画館の上映日リストに基づいた非同期処理がリクエストされることになります。

**解決方法**

このため、`flatMap`を`flatMapLatest`に変更しました。これにより、結合された値が`flatMapLatest`に渡される順序に従って結果が返されることが保証されます。さらに、`flatMapLatest`内部でロジックを処理している途中で他の値が入力された場合、既存のロジック処理を中断し、新しい値に対するロジック処理を開始するため、不要な作業を減らす効果も得られました。

```swift
// Aコード
selectedCinema
    .flatMap { cinema in
        return CinemaService.shared.fetchCinemaCalendar(cinema: cinema)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    }
    .bind(to: selectedCinemaCalendar)
    .disposed(by: disposeBag)

// Bコード
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
</details>
<details>
<summary><strong style="font-size: 1.2em;">dequeueReusableCellとRxSwiftを一緒に使用する際の注意点</strong></summary>
<br>

**[エラー分析動画リンク(Youtube)](https://youtu.be/0pDcFlmsk30?si=N1sHY0IrRKY2c_ub&t=0m12s)**

```swift
// MainViewController
movieDataSource = UICollectionViewDiffableDataSource(collectionView: movieCollectionView, cellProvider: { collectionView, indexPath, item in
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
    cell.viewModel = MovieCellViewModel(item)
    
    // 映画セルでポスターがタップされたとき、映画の詳細情報ビューを表示します。
    cell.posterTapped
        .bind { [weak self] movieCode in
            self?.present(MovieDetailViewController(viewModel: MovieDetailViewModel(movieCode)), animated: true)
        }
        .disposed(by: cell.disposeBag)
    return cell
})
```

**問題状況**  
映画セルのポスターをタップすると、タップの有無が`posterTapped` - Subjectに伝達され、`MainViewController`で映画の詳細情報ビューが`present`されるように実装しました。しかし、ポスターを一度だけタップしたにもかかわらず、詳細情報ビューコントローラー（`MovieDetailViewController`）が重複して生成されるケースが断続的に発生しました。

**原因**  
原因はセルが`dequeueReusableCell`によって再利用されるためです。セルが再利用されるたびに`cell.posterTapped`のストリームが再生成され、その結果、ポスターを複数回タップしたかのような状況が発生したのです。

**解決方法**  
セルが再利用されるたびに、以前のセルで生成されたRxSwiftストリームをすべて削除する必要があります。以下の方法で`DisposeBag`を交換し、以前のストリームを削除しました。

```swift
// MovieCell
override func prepareForReuse() {
    self.disposeBag = DisposeBag()
}
```
</details>
<details>
<summary><strong style="font-size: 1.2em;">init(contentsOf:)はネットワークリクエスト時に使用しないこと</strong></summary>
<br>

**[エラー分析動画リンク(Youtube)](https://www.youtube.com/watch?v=XhiUO03A-2g&t=75s)**

<img src="https://github.com/chldudqlsdl/ODindi/assets/83645833/154d1655-ea99-4eb6-800e-4675c382f946"  width=200>

**問題状況**  
上記の画像は、アプリリリースのために審査提出を行った際、App Storeから受け取ったエラー画面のスクリーンショットです。原因不明の理由で映画館の上映日を取得できていません。しかし、このようなエラーは自分のXcodeや実機では全く発生しておらず、原因を特定するのに長い時間がかかりました。

**原因**

```swift
// 映画館をパラメータとして受け取り、該当映画館の営業日（休日を含む）をObservableとして返すメソッド
func fetchCinemaCalendar(cinema: IndieCinema = IndieCinema.list[0]) -> Observable<CinemaCalendar> {
    return Observable<CinemaCalendar>.create { emitter in

        do {
            let html = try String(contentsOf: url, encoding: .utf8)
            let doc: Document = try SwiftSoup.parse(html)
              // ... [省略] ...
        }
        return Disposables.create()
    }
}
```

原因は映画館の上映日を取得する`fetchCinemaCalendar`メソッドにありました。このメソッドでは、SwiftSoupを使用したウェブクローリングによって上映日を取得していますが、URLアドレスを使ってHTML文字列を取得する際に`String(contentsOf: url, encoding: .utf8)`を使用していました。

しかし、公式ドキュメントでは、ネットワークリクエストのためにURLアドレスを使用する場合、`init(contentsOf:)`を使用することを禁止しています。`init(contentsOf:)`は同期的なメソッドであり、実行時に呼び出したスレッドをブロックします。現在、バックグラウンドスレッドに切り替えているため、メインスレッドをブロックすることはありませんが、App Storeの審査時の特殊なネットワークやスレッド環境では、このようなスレッドブロックが重大なエラーを引き起こし、通信が失敗したと推測されます。

**解決方法**

```swift
URLSession.shared.dataTask(with: url) { data, response, error in
                do {
                    let html = String(data: data, encoding: .utf8) ?? ""
                    let doc: Document = try SwiftSoup.parse(html)
                    // ... [省略] ...
```

URLネットワーク通信には`URLSession.shared.dataTask`を使用することが公式ドキュメントでも推奨されているため、これに修正しました。`URLSession.shared.dataTask`は呼び出したスレッドをブロックせず、すべてのスレッドが使用中であれば、使用可能なスレッドが空くまで待機するため、安全に使用することができます。

加えて、`init(contentsOf:)`の使用用途は、ローカルでURLアドレスを通じて特定のファイルにアクセスする際に使用するために作られたメソッドだと推測できます。
</details>

<details>
<summary><strong style="font-size: 1.2em;">ライブラリを使用せずに、RxSwiftとDelegateを接続</strong></summary>
<br>
プロジェクトでは、CoreLocationに関して`CLLocationManagerDelegate`とRxSwiftを接続するためにRxCoreLocationライブラリを使用しました。しかし、ライブラリとRxSwiftのバージョンが一致せず、ライブラリの追加ができない場合があり、将来的にバージョンの問題でエラーが発生する可能性もあると考えました。

マップタブでは、`mapView`の`Annotation`が選択されたときの検出を`MKMapViewDelegate`のメソッドを通じて行います。そのため、ライブラリを使用せずに、直接`MKMapViewDelegate`とRxSwiftを接続するコードを作成しました。

**`MKMapViewDelegate`を`DelegateProxy`に変換するための`RxMKMapViewDelegateProxy`クラス** 

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

**`MKMapViewDelegate`のメソッドを`Observable`に変換するエクステンション**

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

**RxSwiftと`RxMKMapViewDelegateProxy`を接続した使用例**

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
<summary><strong style="font-size: 1.2em;">RealmDBのデータ削除時におけるDiffableDataSourceとの衝突</strong></summary>
<br>

**[エラー分析動画リンク(Youtube)](https://youtu.be/bQT_EvVskPw?si=LFi_5gOTOx6p5tVp&t=1m10s)**

以前は、映画ポスターの下にあるブックマークボタンを押すと、該当の映画がRealmDBに追加されていました。ブックマークに追加された映画は、ブックマークボタンが紫色に変わり、紫色のボタンを押すとブックマークを解除する必要があるため、その映画インスタンスをRealmDBから削除していました。

ブックマークタブに表示されるブックマークされた映画は、DiffableDataSourceを通じて表示され、データに変化が生じると、アニメーションとともに変更されたデータが表示されます。

**問題状況**

しかし、ブックマークを解除した後、DiffableDataSourceが変更される過程で、  
`Thread 1: "Object has been deleted or invalidated.”`  
というエラーメッセージが表示され、アプリがクラッシュしてしまいます。

**原因**

DiffableDataSourceは、データが変更されると、変更前のデータと変更後のデータの状態を比較してビューを更新します。そのため、DiffableDataSourceが変更前に削除されたデータのRealmObjectインスタンスにアクセスしようとしますが、RealmDBでは削除されたデータに対して参照できないように例外処理が行われているため、クラッシュが発生します。

**解決方法**

```swift
class WatchLater: Object {
    @Persisted(primaryKey: true) var movieCode: String
    @Persisted var date: Date = Date()
    @Persisted var isDeleted: Bool = false
}
```

上記のようにRealmObjectのデータモデルを変更し、ブックマークを解除する際にすぐにDBから削除せず、一時的にプロパティ`isDeleted`をtrueに変更します。DiffableDataSourceによるビューの更新が行われた後に、`isDeleted`がtrueのインスタンスだけをDBから削除すれば良いです。
</details>
<details>
<summary><strong style="font-size: 1.2em;">ビルド: 2つのライブラリ間の衝突</strong></summary>
<br>

**[エラー分析動画リンク(Youtube)](https://youtu.be/WvGNxJfl8ns?si=TFj_wLhOsfaRGB0G&t=0m22s)**

**問題状況**

<img src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/b2598d1d-e76f-49ac-915e-511c95f2e70a" width=200>

シミュレーターでのビルドを続けていたが、リリース直前に実機でビルドを行う過程でエラーが発生した。

**原因と問題解決**

<img src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/95afb076-be58-4560-bd28-cda1984c5169" width=400>

TARGET → Librariesを確認すると、RxCocoaとRxCocoa-Dynamicの2つのライブラリが追加されていることがわかります。両方のライブラリを追加しようとしたために発生したエラーであり、どちらか一方のライブラリだけを残して、もう一方を削除することで問題が解決します。

**ライブラリの種類とそれぞれの特徴**

ライブラリはXcode Targetの一部としてビルドされないコードやデータの断片です。ライブラリとアプリのソースコードファイルを結合するプロセスを「リンク」と呼び、このリンク方式によってライブラリは以下の2種類に分類されます。各ライブラリの特徴に応じて、適切なものを選択して使用できます。

**Static Library**

複数のライブラリがスタティックリンカーによって結合され、結合された結果が自分が作成したコードと一緒に実行可能ファイルが作成されます。そのため、実行可能ファイルが大きくなり、メモリ使用量が増加し、起動時間が遅くなります。ライブラリを更新する際には再度リンクを行う必要があり、結果が反映されます。

**Dynamic Library**

リンカーによって結合される点は同じですが、結合された結果の参照だけが実行可能ファイルに含まれ、別途ライブラリファイルが存在します。そのため、アプリを実行するたびにライブラリがアドレス空間にロードされる必要があり、起動時に時間がかかります（通常、スタティックライブラリよりも起動時間が長くなります）。

**ライブラリごとにビルド成果物フォルダや実行ファイルがどのように変わるかを実験**

**[実験結果のリンク(Notion)](https://slowsteadybrown.notion.site/Library-63da20ea88374e91924bf3f7247f8e15?pvs=4)**
  
</details>
<details>
<summary><strong style="font-size: 1.2em;">開発全体の日誌</strong></summary>

<br />
  
**[開発全体の日誌のリンク(Notion)](https://slowsteadybrown.notion.site/266fc8054a4240d8aca1cc07f0155d0e?pvs=4)**
  
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

## 🗂 フォルダ構造
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

## 📺 アプリの起動画面 
|**近くの映画館タブ（メインタブ）**|**マップタブ**|**ブックマークタブ**|
|-|-|-|
|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/74a48c0a-8091-4d23-a479-dc087f51533f">|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/4f6932f3-fd25-403a-84ea-c760d6e76564">|<img width="250" src="https://github.com/chldudqlsdl/Brown-Diary/assets/83645833/811c02ff-02a3-498e-b69d-ac3b21ea2c8d">|


