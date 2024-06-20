//
//  MainViewController.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/5/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Then
import SnapKit
import Loaf

// 메인탭(첫번째 탭)의 ViewController
class MainViewController: UIViewController {
    
    // MARK: - Nested Type
    private enum Section {
        case cinema
        case date
        case movie
    }
    typealias CinemaItem = IndieCinema
    typealias DateItem = BusinessDayStatus
    typealias MovieItem = MovieSchedule
    
    
    // MARK: - Properties
    
    var viewModel: MainViewModelType
    var disposeBag = DisposeBag()
    
    let titleImage = UIImageView()
    let titleLabel = UILabel()
    let timeLabel = UILabel()
    let distanceLabel = UILabel()
    let noMovieLabel = UILabel()
    
    // 가까운 영화관 세곳을 보여주는 컬렉션뷰
    private var cinemaCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    // 선택된 영화관의 상영 날짜를 보여주는 컬렉션뷰
    private var dateCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    // 선택된 상영일의 상영 영화 정보를 보여주는 컬렉션뷰
    private var movieCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var cinemaDataSource: UICollectionViewDiffableDataSource<Section, CinemaItem>!
    private var dateDataSource: UICollectionViewDiffableDataSource<Section, DateItem>!
    private var movieDataSource: UICollectionViewDiffableDataSource<Section, MovieItem>!
    private var cinemaSnapshot: NSDiffableDataSourceSnapshot<Section, CinemaItem>!
    private var dateSnapshot: NSDiffableDataSourceSnapshot<Section, DateItem>!
    private var movieSnapshot: NSDiffableDataSourceSnapshot<Section, MovieItem>!
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private var selectedCinemaCalendar: CinemaCalendar?
    
    // MARK: - LifeCycle 
    
    init(viewModel: MainViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        collectionViewAttribute()
        layout()
        collectionViewLayout()
        bind()
    }
    
    // MARK: - Attribute
    
    private func attribute() {
        view.backgroundColor = .systemBackground
        titleImage.do {
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.font = UIFont.customFont(ofSize: 26, style: .pretendardBold)
        }
        
        timeLabel.do {
            $0.font = UIFont.customFont(ofSize: 16, style: .pretendardSemiBold)
            $0.textColor = .darkGray
        }
        
        distanceLabel.do {
            $0.font = UIFont.customFont(ofSize: 16, style: .pretendardMedium)
            $0.textColor = .gray
        }
        
        noMovieLabel.do {
            $0.font = UIFont.customFont(ofSize: 18, style: .pretendardSemiBold)
            $0.text = "영화 상영정보가 없습니다 😭"
            $0.isHidden = true
        }
    }
    
    private func collectionViewAttribute() {
        let cvs = [cinemaCollectionView, dateCollectionView, movieCollectionView]
        cvs.forEach { cv in
            cv.backgroundColor = .systemBackground
            cv.isScrollEnabled = false
        }
        configureCellRegisterationAndDataSource()
    }
    
    private func configureCellRegisterationAndDataSource() {
        cinemaCollectionView.register(CinemaCell.self, forCellWithReuseIdentifier: "CinemaCell")
        dateCollectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        movieCollectionView.register(MovieCell.self, forCellWithReuseIdentifier: "MovieCell")
        
        cinemaDataSource = UICollectionViewDiffableDataSource(collectionView: cinemaCollectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CinemaCell", for: indexPath) as! CinemaCell
            cell.indieCinema = item
            return cell
        })
        dateDataSource = UICollectionViewDiffableDataSource(collectionView: dateCollectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
            cell.isBusinessDay = item.isBusinessDay
            cell.viewModel = DateCellViewModel(item.dateString)
            return cell
        })
        
        movieDataSource = UICollectionViewDiffableDataSource(collectionView: movieCollectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
            
            cell.viewModel = MovieCellViewModel(item)
            
            cell.watchLaterButtonTapped
                .bind { [weak self] bool in
                    if !bool {
                        // 보고싶어요 추가시 Toater 메시지 표출
                        Loaf("보고싶어요에 추가되었습니다", state: .custom(.init(backgroundColor: .customMedium.withAlphaComponent(0.9), font: .customFont(ofSize: 15, style: .pretendardMedium), icon: UIImage(systemName: "eyeglasses") ,textAlignment: .center, iconAlignment: .left)), sender: self ?? UIViewController()).show(.custom(1.5))
                    }
                }
                .disposed(by: cell.disposeBag)
            
            // 영화셀에서 포스터가 탭되면 영화 상세 정보 View 를 띄워줌
            cell.posterTapped
                .bind { [weak self] movieCode in
                    self?.present(MovieDetailViewController(viewModel: MovieDetailViewModel(movieCode)), animated: true)
                }
                .disposed(by: cell.disposeBag)
            
            return cell
        })
    }
    
    // MARK: - Layout
    
    private func layout() {
        view.addSubview(titleImage)
        titleImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.lessThanOrEqualTo(150)
            if UIScreen.main.bounds.height < 800 {
                $0.height.equalTo(0)
                $0.top.equalToSuperview().inset(30)
            } else {
                $0.height.equalTo(50)
                $0.top.equalToSuperview().inset(60)
            }
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(titleImage.snp.bottom).offset(20)
            $0.left.equalToSuperview().inset(20)
        }
        
        view.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.left.equalTo(titleLabel.snp.left).inset(2)
        }
        
        view.addSubview(distanceLabel)
        distanceLabel.snp.makeConstraints {
            $0.bottom.equalTo(timeLabel.snp.bottom)
            $0.left.equalTo(timeLabel.snp.right).offset(10)
        }
        
        view.addSubview(cinemaCollectionView)
        cinemaCollectionView.snp.makeConstraints {
            $0.top.equalTo(timeLabel.snp.bottom).offset(27)
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
        }
        view.addSubview(dateCollectionView)
        dateCollectionView.snp.makeConstraints {
            $0.top.equalTo(cinemaCollectionView.snp.bottom).offset(18)
            $0.width.equalToSuperview()
            $0.height.equalTo(60)
        }
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.top.equalTo(cinemaCollectionView.snp.bottom).offset(18)
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
        }
        view.addSubview(movieCollectionView)
        movieCollectionView.snp.makeConstraints {
            $0.top.equalTo(dateCollectionView.snp.bottom).offset(18)
            $0.width.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.5)
        }
        view.addSubview(noMovieLabel)
        noMovieLabel.snp.makeConstraints {
            $0.top.equalTo(dateCollectionView.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func collectionViewLayout() {
        cinemaCollectionView.collectionViewLayout = configureCollectionViewLayout(.cinema)
        dateCollectionView.collectionViewLayout = configureCollectionViewLayout(.date)
        movieCollectionView.collectionViewLayout = configureCollectionViewLayout(.movie)
    }
    
    private func configureCollectionViewLayout(_ option: Section) -> UICollectionViewLayout {
        
        let widthDimension: (itemWidth: NSCollectionLayoutDimension, groupWidth: NSCollectionLayoutDimension)
        switch option {
        case .cinema:
            widthDimension = (NSCollectionLayoutDimension.estimated(50), NSCollectionLayoutDimension.estimated(50))
        case .date:
            widthDimension = (NSCollectionLayoutDimension.fractionalWidth(1), NSCollectionLayoutDimension.fractionalWidth(0.2))
        case .movie:
            widthDimension = (NSCollectionLayoutDimension.fractionalWidth(1), NSCollectionLayoutDimension.fractionalWidth(0.6))
        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension.itemWidth, heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: option == .cinema ? 0 : 10, bottom: 0, trailing: option == .cinema ? 0 : 10)
        let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension.groupWidth, heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: - Binding
    func bind() {
        
        // viewModel 에서 현위치 기준 가장 가까운 영화관 세곳 받아오기 -> 영화관 컬렉션뷰 스냅샷 만들기
        viewModel.nearCinemas
            .observe(on: MainScheduler.instance)
            .bind { [weak self] items in
                self?.setCinemaSnapShot(items)
                guard let cinema = items.first else { return }
                self?.titleImage.image = UIImage(named: "\(cinema.name)")
                self?.titleLabel.text = cinema.name
                self?.timeLabel.text = cinema.distanceWithTime().timeLabel
                self?.distanceLabel.text = cinema.distanceWithTime().distanceLabel
            }
            .disposed(by: disposeBag)
        
        // 영화관 컬렉션뷰에서 영화관이 선택되면 화면 UI를 변경하고, 선택된 영화관을 viewModel 로 전달
        cinemaCollectionView.rx.itemSelected
            .map { $0.row }
            .withLatestFrom(viewModel.nearCinemas) { [weak self] index, nearCinemas in
                TransitionHelper.configure(target: self?.titleImage) {
                    self?.titleImage.image = UIImage(named: "\(nearCinemas[index].name)")
                }
                TransitionHelper.configure(target: self?.titleLabel) {
                    self?.titleLabel.text = nearCinemas[index].name
                }
                TransitionHelper.configure(target: self?.timeLabel) {
                    self?.timeLabel.text = nearCinemas[index].distanceWithTime().timeLabel
                }
                TransitionHelper.configure(target: self?.distanceLabel) {
                    self?.distanceLabel.text = nearCinemas[index].distanceWithTime().distanceLabel
                }
                return index
            }
            .bind(to: viewModel.didSelectCinema)
            .disposed(by: disposeBag)
        
        // viewModel 에서 현재 선택된 영화관의 상영일 리스트 받아오기 -> 상영날짜 컬렉션뷰 스냅샷 만들기
        viewModel.selectedCinemaCalendar
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] cinemaCalendar in
                UIView.transition(with: UIImageView(), duration: 0.7, options: .transitionCrossDissolve) {
                    self?.setDateSnapshot(cinemaCalendar.businessDayStatusArray)
                }
            })
            .disposed(by: disposeBag)
        
        // 상영날짜, 상영정보가 모두 표시될 때까지 Indicator 표출
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
        // 상영날짜 컬렉션뷰에서 날짜가 선택되면 viewModel 로 전달
        dateCollectionView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.didSelectDate)
            .disposed(by: disposeBag)
        
        // combineLatest 를 이용해, viewWillAppear 가 되거나, 상영 날짜가 바뀌는 경우 마다 모두 값을 전달
        // viewWillAppear 는 탭 전환시 화면을 업데이트 하기 위함이며, 다른 탭에서 보고싶어요를 선택, 취소여부를 현재 뷰에 반영시키기 위함
        Observable
            .combineLatest(self.rx.viewWillAppear, viewModel.selectedDateMovieSchedule) { _ , items in
                return items
            }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] (items:[MovieSchedule]) in
                
                self?.movieCollectionView.reloadData()
                UIView.transition(with: UIImageView(), duration: 0.8, options: .transitionCrossDissolve) {
                    self?.setMovieSnapshot(items)
                }
                // 영화 상영 스케줄이 빈 배열일 경우 '영화 상영 정보가 없습니다' 레이블 표출
                UIView.transition(with: self?.noMovieLabel ?? UILabel(), duration: 1.0, options: .transitionCrossDissolve) {
                    self?.noMovieLabel.isHidden = !items.isEmpty
                }
            }
            .disposed(by: disposeBag)
        
        // viewModel 이 가까운 영화관 세곳을 불러오도록 명령을 전달
        Observable
            .just(())
            .bind(to: viewModel.fetchNearCinemas)
            .disposed(by: disposeBag)
    }
    
    func setCinemaSnapShot(_ items: [CinemaItem]) {
        cinemaSnapshot = NSDiffableDataSourceSnapshot<Section, CinemaItem>()
        cinemaSnapshot.appendSections([.cinema])
        cinemaSnapshot.appendItems(items, toSection: .cinema)
        cinemaDataSource.apply(cinemaSnapshot, animatingDifferences: true)
        { [weak self] in
            // 자동으로 영화 컬렉션뷰의 첫번째 아이템 선택
            self?.cinemaCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
        }
        
    }
    func setDateSnapshot(_ items: [DateItem]) {
        dateSnapshot = NSDiffableDataSourceSnapshot<Section, DateItem>()
        dateSnapshot.appendSections([.date])
        dateSnapshot.appendItems(items, toSection: .date)
        dateDataSource.apply(dateSnapshot, animatingDifferences: true) 
        { [weak self] in
            // 자동으로 상영일 중(휴일 제외) 첫번째 아이템 선택
            self?.viewModel.cinemaCalendarFirstIndex
                .observe(on: MainScheduler.instance)
                .bind(onNext: { index in
                    self?.dateCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
                })
                .disposed(by: self?.disposeBag ?? DisposeBag())
        }
    }
    func setMovieSnapshot(_ items: [MovieSchedule]) {
        movieSnapshot = NSDiffableDataSourceSnapshot<Section, MovieItem>()
        movieSnapshot.appendSections([.movie])
        movieSnapshot.appendItems(items, toSection: .movie)
        movieDataSource.apply(movieSnapshot, animatingDifferences: true) 
        { [weak self] in
            // 자동으로 상영 영화중 첫번째 아이템 선택, 영화 컬렉션뷰가 비었을 때는 리턴
            guard self?.movieCollectionView.numberOfItems(inSection: 0) ?? 0 > 0 else { return }
            self?.movieCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
        }
    }
}

