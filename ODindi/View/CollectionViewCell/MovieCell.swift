//
//  MovieCell.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/12/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class MovieCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    let watchLaterButtonTapped = PublishSubject<String>()
    let posterTapped = PublishSubject<String>()
    let watchLaterTapGesture = UITapGestureRecognizer()
    let posterTapGesture = UITapGestureRecognizer()
        
    var movieSchedule: MovieSchedule? {
        didSet { configure() }
    }
    
    lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleToFill
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
        $0.addGestureRecognizer(posterTapGesture)
        $0.isUserInteractionEnabled = true
    }
    
    var imageViewForShadow = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.shadowOffset = CGSize(width: 6, height: 6)
        $0.layer.shadowOpacity = 0.6
        $0.layer.cornerRadius = 10
    }
    
    var titleLabel = UILabel().then {
        $0.font = UIFont.customFont(ofSize: 18, style: .pretendardBold)
        $0.numberOfLines = 0
    }
    
    var timeTableStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
    }
    
    lazy var watchLaterButton = UIImageView().then {
        $0.image = UIImage(systemName: "bookmark.fill")!.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        $0.contentMode = .scaleAspectFit
        $0.addGestureRecognizer(watchLaterTapGesture)
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        bind()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Attribute
    
    func configure() {
        guard let movieSchedule = movieSchedule else { return }
        imageView.kf.setImage(with: URL(string: movieSchedule.imageUrl))
                
        titleLabel.text = movieSchedule.name
        
        timeTableStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        movieSchedule.timeTable.forEach { time in
            let timeLabel = UILabel().then {
                $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            }
            timeLabel.text = time
            timeTableStackView.addArrangedSubview(timeLabel)
        }
    }
    
    // MARK: - Layout
    func layout() {
        
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
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(18)
            $0.left.equalTo(imageView.snp.left).inset(3)
            $0.right.equalTo(imageView.snp.right).inset(12)
        }
        
        addSubview(watchLaterButton)
        watchLaterButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.top)
            $0.right.equalTo(imageView.snp.right)
            $0.width.height.equalTo(25)
        }
        
        addSubview(timeTableStackView)
        timeTableStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalTo(imageView.snp.left).inset(3)
        }
    }
    
    // MARK: - Bind
    
    func bind() {
        
        watchLaterTapGesture.rx.event
            .bind { [weak self] _ in
                guard let movieSchedule = self?.movieSchedule else { return }
                self?.watchLaterButtonTapped.onNext(movieSchedule.code)
            }
            .disposed(by: disposeBag)
        
        posterTapGesture.rx.event
            .bind { [weak self] _ in
                guard let movieSchedule = self?.movieSchedule else { return }
                self?.posterTapped.onNext(movieSchedule.code)
            }
            .disposed(by: disposeBag)
    }
}


