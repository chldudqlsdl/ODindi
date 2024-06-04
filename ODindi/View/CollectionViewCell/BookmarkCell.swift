//
//  BookmarkCell.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/3/24.
//

import Foundation
import UIKit
import RxSwift

class BookmarkCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var disposebag = DisposeBag()
    let posterTapped = PublishSubject<String>()
    let posterTapRecognizer = UITapGestureRecognizer()
    let bookmarkTapped = PublishSubject<String>()
    let bookmarkTapRecognizer = UITapGestureRecognizer()
    
    var viewModel: BookmarkCellViewModelType? {
        didSet { bind() }
    }

    lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleToFill
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 0.05
        
        $0.addGestureRecognizer(posterTapRecognizer)
        $0.isUserInteractionEnabled = true
    }
    
    var imageViewForShadow = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.shadowOffset = CGSize(width: 3, height: 3)
        $0.layer.shadowOpacity = 0.4
        $0.layer.cornerRadius = 5
    }
    
    var titleLabel = UILabel().then {
        $0.font = UIFont.customFont(ofSize: 16, style: .pretendardSemiBold)
        $0.numberOfLines = 0
    }
    
    lazy var bookmarkIcon = UIImageView().then {
        $0.image = UIImage(systemName: "bookmark.fill")!.withTintColor(.orange, renderingMode: .alwaysOriginal)
        $0.contentMode = .scaleAspectFit
        $0.addGestureRecognizer(bookmarkTapRecognizer)
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        disposebag = DisposeBag()
    }
    
    // MARK: - Layout
    private func layout() {
        
        addSubview(imageViewForShadow)
        imageViewForShadow.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(imageViewForShadow.snp.width).multipliedBy(1.42)
        }
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(5)
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.42)
        }
        
        addSubview(bookmarkIcon)
        bookmarkIcon.snp.makeConstraints {
            $0.top.equalTo(imageView).inset(10)
            $0.right.equalTo(imageView).inset(10)
            $0.width.height.equalTo(30)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.left.equalTo(imageView.snp.left).inset(1)
        }
        
    }
    
    // MARK: - bind
    func bind() {
        
        guard let viewModel = viewModel else { return }
        
        viewModel.movieData
            .bind { [weak self] movieData in
                
                self?.imageView.kf.setImage(with: URL(string: movieData.poster.small))
                self?.titleLabel.text = movieData.title
            }
            .disposed(by: disposebag)
        
        posterTapRecognizer.rx.event
            .withLatestFrom(viewModel.movieCode) { _, movieCode in
                return movieCode
            }
            .bind(to: posterTapped)
            .disposed(by: disposebag)
        
        bookmarkTapRecognizer.rx.event
            .withLatestFrom(viewModel.movieCode) { _, movieCode in
                return movieCode
            }
            .bind { [weak self] string in
                self?.bookmarkTapped.onNext(string)
            }
            .disposed(by: disposebag)
    }
    
}
