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

class CinemaViewController: UIViewController {
    
    // MARK: - Nested Type
    private enum Section {
        case cinema
        case date
        case movie
    }
    typealias CinemaItem = IndieCinema
    typealias DateItem = String
    typealias MovieItem = MovieSchedule
    
    // MARK: - Properties
    
    var viewModel: CinemaViewModelType
    var disposeBag = DisposeBag()
    private var cinemaCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var dateCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var movieCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var cinemaDataSource: UICollectionViewDiffableDataSource<Section, CinemaItem>!
    private var dateDataSource: UICollectionViewDiffableDataSource<Section, DateItem>!
    private var movieDataSource: UICollectionViewDiffableDataSource<Section, MovieItem>!
    private var cinemaSnapshot: NSDiffableDataSourceSnapshot<Section, CinemaItem>!
    private var dateSnapshot: NSDiffableDataSourceSnapshot<Section, DateItem>!
    private var movieSnapshot: NSDiffableDataSourceSnapshot<Section, MovieItem>!
    private var activityIndicator = UIActivityIndicatorView()
    
    private var selectedCinemaCalendar: CinemaCalendar?
    
    // MARK: - LifeCycle 
    
    init(viewModel: CinemaViewModelType) {
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
        self.title = "내 근처 독립영화관"
        navigationController?.navigationBar.prefersLargeTitles = true
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CinemaCell", for: indexPath) as? CinemaCell else { return nil}
            cell.name = item.name
            return cell
        })
        dateDataSource = UICollectionViewDiffableDataSource(collectionView: dateCollectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell else { return nil}
            guard let selectedCinemaCalendar = self?.selectedCinemaCalendar else { return nil }
            if selectedCinemaCalendar.businessDays.contains(item) {
                cell.isBusinessDay = true
            } else {
                cell.isBusinessDay = false
            }
            cell.viewModel = DateCellViewModel(item)
            return cell
        })
        
        movieDataSource = UICollectionViewDiffableDataSource(collectionView: movieCollectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
            cell.imageUrlString = item.imageUrl
            return cell
        })
    }
    
    // MARK: - Layout
    
    private func layout() {
        view.addSubview(cinemaCollectionView)
        cinemaCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
        }
        view.addSubview(dateCollectionView)
        dateCollectionView.snp.makeConstraints {
            $0.top.equalTo(cinemaCollectionView.snp.bottom).offset(10)
            $0.width.equalToSuperview()
            $0.height.equalTo(60)
        }
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.top.equalTo(cinemaCollectionView.snp.bottom).offset(10)
            $0.width.equalToSuperview()
            $0.height.equalTo(30)
        }
        view.addSubview(movieCollectionView)
        movieCollectionView.snp.makeConstraints {
            $0.top.equalTo(dateCollectionView.snp.bottom).offset(5)
            $0.width.equalToSuperview()
            $0.height.equalTo(300)
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
            widthDimension = (NSCollectionLayoutDimension.fractionalWidth(1), NSCollectionLayoutDimension.absolute(215))
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
    
    // MARK: - Binding
    func bind() {
        self.rx.viewWillAppear
            .map { _ in }
            .bind(to: viewModel.fetchNearCinemas)
            .disposed(by: disposeBag)
        
        viewModel.nearCinemas
            .observe(on: MainScheduler.instance)
            .bind { [weak self] items in
                self?.setCinemaSnapShot(items)
            }
            .disposed(by: disposeBag)
        
        cinemaCollectionView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.didSelectCinema)
            .disposed(by: disposeBag)
        
        viewModel.selectedCinemaCalendar
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] cinemaCalendar in
                self?.selectedCinemaCalendar = cinemaCalendar
                self?.setDateSnapshot(cinemaCalendar.alldays)
            })
            .disposed(by: disposeBag)
        
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
        
        dateCollectionView.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.didSelectDate)
            .disposed(by: disposeBag)
        
        
        viewModel.selectedDateMovieSchedule
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] items in
                self?.setMovieSnapshot(items)
            }
            .disposed(by: disposeBag)
    }
    
    func setCinemaSnapShot(_ items: [CinemaItem]) {
        cinemaSnapshot = NSDiffableDataSourceSnapshot<Section, CinemaItem>()
        cinemaSnapshot.appendSections([.cinema])
        cinemaSnapshot.appendItems(items, toSection: .cinema)
        cinemaDataSource.apply(cinemaSnapshot, animatingDifferences: true)
        { [weak self] in
            self?.cinemaCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
        }
        
    }
    func setDateSnapshot(_ items: [String]) {
        dateSnapshot = NSDiffableDataSourceSnapshot<Section, DateItem>()
        dateSnapshot.appendSections([.date])
        dateSnapshot.appendItems(items, toSection: .date)
        dateDataSource.apply(dateSnapshot, animatingDifferences: true) 
        { [weak self] in
            self?.viewModel.cinemaCalendarFirstIndex
                .observe(on: MainScheduler.instance)
                .bind(onNext: { index in
                    self?.dateCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: index == 0 ? .left : .centeredHorizontally)
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
            self?.movieCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
        }
    }
}
