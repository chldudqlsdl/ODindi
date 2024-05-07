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
    
    var viewModel: MainViewModelType
    var disposeBag = DisposeBag()
    
    // MARK: - LifeCycle
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
        configureAutolayout()
        setupBindings()
    }
    
    // MARK: - UI Binding
    func setupBindings() {
        Observable
            .just(())
            .bind(to: viewModel.fetchNearCinemas)
            .disposed(by: disposeBag)
        
        viewModel.cinemaSchedule
            .observe(on: MainScheduler.instance)
            .compactMap { $0.first?.imageUrl }
            .flatMap { [weak self] urlString in
                self!.movieImageView.kf.rx.setImage(with: URL(string: urlString)!)
            }
            .subscribe { _ in
                print("Image Binding Completed")
            }
            .disposed(by: disposeBag)
            
        
        viewModel.cinemaCalendar
            .map { $0.businessDays.first ?? "" }
            .observe(on: MainScheduler.instance)
            .bind(to: dateLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.nearCinemas
            .map { $0.first?.name ?? "" }
            .observe(on: MainScheduler.instance)
            .bind(to: cinemaLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.cinemaSchedule
            .map { $0.first?.name ?? "" }
            .observe(on: MainScheduler.instance)
            .bind(to: movieLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.cinemaSchedule
            .map { $0.first?.timeTable.joined(separator: " ∙ ") ?? "" }
            .observe(on: MainScheduler.instance)
            .bind(to: timeTableLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Properties
    let movieImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    let dateLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 25)
        $0.textColor = .white
    }
    let cinemaLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 25)
        $0.textColor = .white
    }
    let movieLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 25)
        $0.textColor = .white
    }
    let timeTableLabel = UILabel().then {
        $0.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 25)
        $0.textColor = .white
    }
    lazy var stackView = UIStackView(arrangedSubviews: [dateLabel, cinemaLabel, movieLabel, timeTableLabel]).then {
        $0.axis = .vertical
        $0.spacing = 20
    }
    
    // MARK: - ConfigureAutolayout
    func configureAutolayout() {
        
        view.addSubview(movieImageView)
        movieImageView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}

