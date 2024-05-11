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
    }
    typealias CinemaItem = IndieCinema
    
    // MARK: - Properties
    
    var viewModel: MainViewModelType
    var disposeBag = DisposeBag()
    private var cinemaCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var cinemaDataSource: UICollectionViewDiffableDataSource<Section, CinemaItem>!
    private var snapshot: NSDiffableDataSourceSnapshot<Section, CinemaItem>!
    
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
        cinemaCollectionView.backgroundColor = .secondarySystemBackground
    }
    
    private func configureAutoLayout() {
        view.addSubview(cinemaCollectionView)
        cinemaCollectionView.snp.makeConstraints {
            $0.width.height.equalToSuperview()
        }
    }
    
    private func configureCollectionView() {
        cinemaCollectionView.collectionViewLayout = configureCollectionViewLayout()
        configureCellRegisterationAndDataSource()
    }
    
    private func configureCellRegisterationAndDataSource() {
        cinemaCollectionView.register(CinemaCell.self, forCellWithReuseIdentifier: "CinemaCell")
        
        cinemaDataSource = UICollectionViewDiffableDataSource(collectionView: cinemaCollectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CinemaCell", for: indexPath) as? CinemaCell else { return nil}
            cell.name = item.name
            return cell
        })
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.4), heightDimension: .fractionalHeight(0.1))
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
                self?.setSnapShot(items)
            }
            .disposed(by: disposeBag)
    }
    
    func setSnapShot( _ items: [CinemaItem]) {
        snapshot = NSDiffableDataSourceSnapshot<Section, CinemaItem>()
        snapshot.appendSections([.cinema])
        snapshot.appendItems(items, toSection: .cinema)
        cinemaDataSource.apply(snapshot)
    }
}

