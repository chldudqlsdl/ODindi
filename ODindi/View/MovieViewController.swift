//
//  MovieDetailViewController.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/26/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Loaf
import Kingfisher

class MovieViewController: UIViewController {
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    var viewModel: MovieViewModelType
    
    private var posterImageView = UIImageView()
    private var shadowView = UIView()
    private var ratingImageView = UIImageView()
    private var titleLabel = UILabel()
    private var infoStackView = UIStackView()
    private var releasedDateLabel = UILabel()
    private var genreLabel = UILabel()
    private var runningTimeLabel = UILabel()
    private var overViewLabel = UILabel()
    
    // MARK: - Lifecycle
    init(viewModel: MovieViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attribute()
        bind()
        layout()
    }
    
    // MARK: - Attribute
    func attribute() {
        view.backgroundColor = .systemBackground
        
        posterImageView.do {
            $0.contentMode = .scaleToFill
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
        }
        
        shadowView.do {
            $0.layer.shadowOffset = CGSize(width: 6, height: 6)
            $0.layer.shadowOpacity = 0.6
            $0.layer.cornerRadius = 10
        }
        
        titleLabel.do {
            $0.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            $0.numberOfLines = 0
        }
        
        let subViews = [releasedDateLabel, genreLabel, runningTimeLabel]
        subViews.forEach { label in
            label.do {
                $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
                $0.textColor = .secondaryLabel
            }
            infoStackView.addArrangedSubview(label)
        }
        
        infoStackView.do {
            $0.axis = .horizontal
            $0.spacing = 10
            $0.alignment = .leading
        }
        
        overViewLabel.do {
            $0.numberOfLines = 0
            $0.textColor = .darkText
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.lineBreakMode = .byClipping
        }
    }
    
    // MARK: - Layout
    func layout() {
        view.addSubview(shadowView)
        shadowView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(50)
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(shadowView.snp.width).multipliedBy(1.42)
        }
        
        view.addSubview(posterImageView)
        posterImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(50)
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(posterImageView.snp.width).multipliedBy(1.42)
        }
        
        view.addSubview(ratingImageView)
        ratingImageView.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.top).offset(10)
            $0.right.equalTo(posterImageView.snp.right).inset(10)
            $0.width.height.equalTo(30)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(posterImageView.snp.bottom).offset(20)
            $0.left.equalTo(posterImageView.snp.left)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(infoStackView)
        infoStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.left.equalTo(posterImageView.snp.left)
        }
        
        view.addSubview(overViewLabel)
        overViewLabel.snp.makeConstraints {
            $0.top.equalTo(infoStackView.snp.bottom).offset(10)
            $0.left.equalTo(posterImageView.snp.left)
            $0.centerX.equalToSuperview()
        }
    }
    
    override func viewDidLayoutSubviews() {
        genreLabel.snp.makeConstraints {
            if genreLabel.frame.width > 150 {
                $0.width.equalTo(150)
            }
        }
    }
    
    // MARK: - Bind()
    func bind() {
        
        viewModel.movieData
            .bind { [weak self] data in
                print(data)
                self?.posterImageView.kf.setImage(with: URL(string: data.poster), completionHandler: { _ in
                    self?.shadowView.backgroundColor = .systemBackground
                })
                self?.ratingImageView.image = data.rating.image
                self?.titleLabel.text = data.title
                self?.releasedDateLabel.text = data.releasedDate
                self?.genreLabel.text = data.genre
                self?.runningTimeLabel.text = data.runningTime
                self?.overViewLabel.text = data.overView
            }
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .bind { errorMsg in
                Loaf(errorMsg, state: .error, sender: self).show(.short)
            }
            .disposed(by: disposeBag)
    }
}

