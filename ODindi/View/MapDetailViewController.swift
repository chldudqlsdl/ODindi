//
//  MapDetailViewController.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/4/24.
//

import Foundation
import UIKit
import RxSwift
import WebKit
import Loaf

class MapDetailViewController: UIViewController {
    
    // MARK: - Nested Type
    private enum Section {
        case date
        case movie
    }
    typealias DateItem = BusinessDayStatus
    typealias MovieItem = MovieSchedule
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    let viewModel: MapDetailViewModelType
    
    let logoImageView = UIImageView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let instaBtn = UIImageView()
    let mapBtn = UIImageView()
    let instaBtnTapRecognizer = UITapGestureRecognizer()
    let mapBtnTapRecognizer = UITapGestureRecognizer()
    let btnStackView = UIStackView()
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    var webView: WKWebView!
    let webViewController = UIViewController()
    let noMovieLabel = UILabel()
    
    private var dateCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var movieCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var dateDataSource: UICollectionViewDiffableDataSource<Section, DateItem>!
    private var movieDataSource: UICollectionViewDiffableDataSource<Section, MovieItem>!
    private var dateSnapshot: NSDiffableDataSourceSnapshot<Section, DateItem>!
    private var movieSnapshot: NSDiffableDataSourceSnapshot<Section, MovieItem>!
    private var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        collectionViewAttribute()
        layout()
        collectionViewLayout()
        bind()
    }
    
    init(viewModel: MapDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - attribute
    
    func attribute() {
        view.backgroundColor = .systemBackground
        
        logoImageView.do {
            $0.contentMode = .scaleAspectFit
        }
        nameLabel.do {
            $0.font = UIFont.customFont(ofSize: 25, style: .pretendardBold)
        }
        addressLabel.do {
            $0.font = UIFont.customFont(ofSize: 15, style: .pretendardMedium)
            $0.textColor = .gray
            $0.textAlignment = .center
        }
        instaBtn.do {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "Instagram_icon")
            $0.addGestureRecognizer(instaBtnTapRecognizer)
            $0.isUserInteractionEnabled = true
        }
        mapBtn.do {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "map_icon")
            $0.addGestureRecognizer(mapBtnTapRecognizer)
            $0.isUserInteractionEnabled = true
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 0.6
            $0.layer.borderColor = UIColor.lightGray.cgColor
        }
        btnStackView.do {
            $0.addArrangedSubview(instaBtn)
            $0.addArrangedSubview(mapBtn)
            $0.spacing = 30
        }
        noMovieLabel.do {
            $0.font = UIFont.customFont(ofSize: 18, style: .pretendardSemiBold)
            $0.text = "영화 상영정보가 없습니다 😭"
            $0.isHidden = true
        }
        
    }
    
    private func collectionViewAttribute() {
        let cvs = [dateCollectionView, movieCollectionView]
        cvs.forEach { cv in
            cv.backgroundColor = .systemBackground
            cv.isScrollEnabled = false
        }
        configureCellRegisterationAndDataSource()
    }
    
    private func configureCellRegisterationAndDataSource() {
        dateCollectionView.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        movieCollectionView.register(MovieCell.self, forCellWithReuseIdentifier: "MovieCell")
        
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
                        Loaf("보고싶어요에 추가되었습니다", state: .custom(.init(backgroundColor: .customMedium.withAlphaComponent(0.9), font: .customFont(ofSize: 15, style: .pretendardMedium), icon: UIImage(systemName: "eyeglasses") ,textAlignment: .center, iconAlignment: .left)), sender: self ?? UIViewController()).show(.custom(1.5))
                    }
                }
                .disposed(by: cell.disposeBag)
            
            cell.posterTapped
                .bind { [weak self] movieCode in
                    self?.present(MovieViewController(viewModel: MovieViewModel(movieCode)), animated: true)
                }
                .disposed(by: cell.disposeBag)
            
            return cell
        })
    }
    
    
    // MARK: - Layout
    func layout() {
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
            $0.height.lessThanOrEqualTo(50)
            $0.width.lessThanOrEqualTo(150)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(addressLabel)
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.left.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        
        instaBtn.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        mapBtn.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        view.addSubview(btnStackView)
        btnStackView.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(dateCollectionView)
        dateCollectionView.snp.makeConstraints {
            $0.top.equalTo(btnStackView.snp.bottom).offset(18)
            $0.width.equalToSuperview()
            $0.height.equalTo(60)
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
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.top.equalTo(btnStackView.snp.bottom).offset(18)
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
        }
    }
    
    func layoutIndicator() {
        webView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    private func collectionViewLayout() {
        dateCollectionView.collectionViewLayout = configureCollectionViewLayout(.date)
        movieCollectionView.collectionViewLayout = configureCollectionViewLayout(.movie)
    }
    
    private func configureCollectionViewLayout(_ option: Section) -> UICollectionViewLayout {
        
        let widthDimension: (itemWidth: NSCollectionLayoutDimension, groupWidth: NSCollectionLayoutDimension)
        switch option {
        case .date:
            widthDimension = (NSCollectionLayoutDimension.fractionalWidth(1), NSCollectionLayoutDimension.fractionalWidth(0.2))
        case .movie:
            widthDimension = (NSCollectionLayoutDimension.fractionalWidth(1), NSCollectionLayoutDimension.fractionalWidth(0.6))
        }
        
        let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension.itemWidth, heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension.groupWidth, heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: - bind
    
    func bind() {
        viewModel.cinemaData
            .bind { [weak self] cinemaData in
                self?.logoImageView.image = UIImage(named: cinemaData.name)
                self?.nameLabel.text = cinemaData.name
                self?.addressLabel.text = cinemaData.address
            }
            .disposed(by: disposeBag)
        
        instaBtnTapRecognizer.rx.event
            .bind { [weak self] _ in
                self?.configureWebViewController()
                self?.viewModel.instaBtnTapped.onNext(())
            }
            .disposed(by: disposeBag)
        
        mapBtnTapRecognizer.rx.event
            .bind { [weak self] _ in
                self?.configureWebViewController()
                self?.viewModel.mapBtnTapped.onNext(())
            }
            .disposed(by: disposeBag)
        
        viewModel.urlRequest
            .bind { [weak self] URLRequest in
                self?.webView.load(URLRequest)
            }
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isLoading in
                if isLoading {
                    self?.activityIndicator.isHidden = false
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.isHidden = true
                    self?.activityIndicator.stopAnimating()
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.selectedCinemaCalendar
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind(onNext: { [weak self] cinemaCalendar in
                UIView.transition(with: UIImageView(), duration: 0.7, options: .transitionCrossDissolve) {
                    self?.setDateSnapshot(cinemaCalendar.businessDayStatusArray)
                }
            })
            .disposed(by: disposeBag)
        
        dateCollectionView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.didSelectDate)
            .disposed(by: disposeBag)
        
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
                UIView.transition(with: self?.noMovieLabel ?? UILabel(), duration: 1.0, options: .transitionCrossDissolve) {
                    self?.noMovieLabel.isHidden = !items.isEmpty
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    func configureWebViewController() {
        self.webView = WKWebView()
        self.layoutIndicator()
        self.webView.navigationDelegate = self
        self.loadingIndicator.startAnimating()
        webViewController.view = self.webView
        self.present(webViewController, animated: true)
    }
    
    func setDateSnapshot(_ items: [DateItem]) {
        dateSnapshot = NSDiffableDataSourceSnapshot<Section, DateItem>()
        dateSnapshot.appendSections([.date])
        dateSnapshot.appendItems(items, toSection: .date)
        dateDataSource.apply(dateSnapshot, animatingDifferences: true)
        { [weak self] in
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
            self?.movieCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [.centeredHorizontally])
        }
    }
}

extension MapDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
}
