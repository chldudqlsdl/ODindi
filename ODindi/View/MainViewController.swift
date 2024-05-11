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
import RxKingfisher

class MainViewController: UIViewController {
    
    // MARK: - Nested Type
    private enum Section {
        case cinema
        case date
    }
    typealias CinemaItem = IndieCinema
    typealias DateItem = String
    
    // MARK: - Properties
    
    var viewModel: MainViewModelType
    var disposeBag = DisposeBag()
    private var cinemaCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var dateCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var cinemaDataSource: UICollectionViewDiffableDataSource<Section, CinemaItem>!
    private var dateDataSource: UICollectionViewDiffableDataSource<Section, DateItem>!
    private var cinemaSnapshot: NSDiffableDataSourceSnapshot<Section, CinemaItem>!
    private var dateSnapshot: NSDiffableDataSourceSnapshot<Section, DateItem>!
    private var activityIndicator = UIActivityIndicatorView()
    
    // MARK: - LifeCycle Methods
    init(viewModel: MainViewModelType = MainViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        configureUI()
        bind()
    }
    
    // MARK: - Methods
    private func configureUI() {
        configureAutoLayout()
        configureCollectionView()
        cinemaCollectionView.backgroundColor = .orange
        dateCollectionView.backgroundColor = .orange
    }
    
    private func configureAutoLayout() {
        view.addSubview(cinemaCollectionView)
        cinemaCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
        view.addSubview(dateCollectionView)
        dateCollectionView.snp.makeConstraints {
            $0.top.equalTo(cinemaCollectionView.snp.bottom).offset(5)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.top.equalTo(cinemaCollectionView.snp.bottom).offset(5)
            $0.width.equalToSuperview()
            $0.height.equalTo(50)
        }
    }
    
    private func configureCollectionView() {
        cinemaCollectionView.collectionViewLayout = configureCollectionViewLayout()
        configureCellRegisterationAndDataSource()
        dateCollectionView.collectionViewLayout = configureCollectionViewLayout()
        cinemaCollectionView.isScrollEnabled = false
        dateCollectionView.isScrollEnabled = false
    }
    
    private func configureCellRegisterationAndDataSource() {
        cinemaCollectionView.register(CinemaCell.self, forCellWithReuseIdentifier: "CinemaCell")
        dateCollectionView.register(CinemaCell.self, forCellWithReuseIdentifier: "CinemaCell")
        
        cinemaDataSource = UICollectionViewDiffableDataSource(collectionView: cinemaCollectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CinemaCell", for: indexPath) as? CinemaCell else { return nil}
            cell.name = item.name
            return cell
        })
        dateDataSource = UICollectionViewDiffableDataSource(collectionView: dateCollectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CinemaCell", for: indexPath) as? CinemaCell else { return nil}
            cell.name = item
            return cell
        })
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    // MARK: - Rx Binding Methods
    func bind() {
        viewModel.fetchNearCinemas
            .onNext(())
        
        viewModel.nearCinemas
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] items in
                self?.setCinemaSnapShot(items)
            }
            .disposed(by: disposeBag)
        
        cinemaCollectionView.rx.itemSelected.asObservable()
            .map { $0.row }
            .bind(to: viewModel.didCinemaSelected)
            .disposed(by: disposeBag)
        
        viewModel.selectedCinemaCalendar
            .map { $0.businessDays }
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] items in
                self?.setDataSnapshot(items)
            }
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
    }
    
    func setCinemaSnapShot(_ items: [CinemaItem]) {
        cinemaSnapshot = NSDiffableDataSourceSnapshot<Section, CinemaItem>()
        cinemaSnapshot.appendSections([.cinema])
        cinemaSnapshot.appendItems(items, toSection: .cinema)
        cinemaDataSource.apply(cinemaSnapshot)
    }
    func setDataSnapshot(_ items: [String]) {
        dateSnapshot = NSDiffableDataSourceSnapshot<Section, DateItem>()
        dateSnapshot.appendSections([.date])
        dateSnapshot.appendItems(items, toSection: .date)
        dateDataSource.apply(dateSnapshot)
    }
}

