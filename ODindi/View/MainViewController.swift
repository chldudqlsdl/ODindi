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
            .map { $0.first?.name}
            .bind(to: coordinateLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Properties
    let coordinateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    // MARK: - ConfigureAutolayout
    func configureAutolayout() {
        view.addSubview(coordinateLabel)
        coordinateLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
