//
//  BookmarkViewController.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/3/24.
//

import Foundation
import UIKit
import RxSwift
import RxAppState

class BookmarkViewController: UIViewController {
    
    // MARK: - NestedType
    enum Section {
        case movie
    }
    
    typealias MovieItem = WatchLater
    
    // MARK: - Properties
    let viewModel: BookmarkViewModelType
    let disposeBag = DisposeBag()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    var dataSource: UICollectionViewDiffableDataSource<Section, MovieItem>!
    var alertSheet: UIAlertController!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
        collectionViewLayout()
        bind()
    }
    
    init(viewModel: BookmarkViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Attribute
    
    private func attribute() {
        self.navigationItem.title = "보고싶어요"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        collectionView.backgroundColor = .systemBackground
        collectionView.register(BookmarkCell.self, forCellWithReuseIdentifier: "BookmarkCell")
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkCell", for: indexPath) as! BookmarkCell
            cell.viewModel = BookmarkCellViewModel(movieCode: item.movieCode)
            
            cell.posterTapped
                .bind { [weak self] movieCode in
                    self?.present(MovieViewController(viewModel: MovieViewModel(movieCode)), animated: true)
                }
                .disposed(by: cell.disposebag)
            
            cell.bookmarkTapped
                .bind { [weak self] string in
                    self?.showAlert(string)
                }
                .disposed(by: cell.disposebag)
                
            return cell
        })
    }
    
    // MARK: - Layout
    
    private func layout() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func collectionViewLayout() {
        collectionView.collectionViewLayout = configureLayout()
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(310))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(310))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        let collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
        return collectionViewLayout
    }
    
    
    // MARK: - bind
    
    private func bind() {
        
        self.rx.viewWillAppear
            .map { _ in ()}
            .bind(to: viewModel.viewWillAppear)
            .disposed(by: disposeBag)
        
        self.rx.viewDidAppear
            .map { _ in ()}
            .bind(to: viewModel.viewDidAppear)
            .disposed(by: disposeBag)
        
        viewModel.bookmarkedMovieDatas
            .bind { [weak self] movies in
                self?.setSnapshot(movies)
            }
            .disposed(by: disposeBag)
    }
    
    func setSnapshot(_ items: [MovieItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MovieItem>()
        snapshot.appendSections([.movie])
        snapshot.appendItems(items, toSection: .movie)
        dataSource.apply(snapshot)
    }
    
    func showAlert(_ string: String) {
        
        alertSheet = UIAlertController(title: "더이상 보고싶지 않나요?", message: "한번 삭제하면 되돌릴 수 없습니다 🥹", preferredStyle: .alert)
        alertSheet.addAction(UIAlertAction(title: "취소", style: .default))
        alertSheet.addAction(UIAlertAction(title: "확인", style: .destructive, handler: { [weak self] _ in
            Observable
                .just(string)
                .bind { string in
                    self?.viewModel.deleteBookmarkedMovie.onNext(string)
                }
                .disposed(by: self?.disposeBag ?? DisposeBag())
        }))
        present(alertSheet, animated: true)
    }
}
