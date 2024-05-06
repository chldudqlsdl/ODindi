//
//  TabBarController.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/5/24.
//

import Foundation
import UIKit
import RxSwift
import Then
import SnapKit
import RxCocoa
import CoreLocation

class TabBarController: UITabBarController{
    
    let disposeBag = DisposeBag()
    var viewModel: TabBarViewModelType
    
    // MARK: - Lifecycle
    init(viewModel: TabBarViewModelType = TabBarViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBindings()
    }
    
    
    // MARK: - Helpers
    func configureViewControllers(currentCoordinate: CLLocationCoordinate2D){
        let mainVM = MainViewModel(currentCoordinate)
        let mainVC = MainViewController(viewModel: mainVM)
        
        let nav1 = configureNavController(vc: mainVC, image: UIImage(systemName: "map")!)
        let nav2 = configureNavController(vc: SubViewController(), image: UIImage(systemName: "magnifyingglass")!)
        viewControllers = [nav1, nav2]
    }
    func configureNavController(vc: UIViewController, image: UIImage) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.tabBarItem.image = image
        return navigationController
    }
    
    
    // MARK: - UI Bindings
    
    func setupBindings() {
        
        //INPUT
        
        // 위치 권한 요청
        Observable
            .just(())
            .bind(to: viewModel.checkLocationAuth)
            .disposed(by: disposeBag)
        // 좌표 값 요청
        Observable
            .just(())
            .bind(to: viewModel.fetchCoordinate)
            .disposed(by: disposeBag)
        
        // OUTPUT
        viewModel.currentCoordinate
            .subscribe { [weak self] coordinate in
                self?.configureViewControllers(currentCoordinate: coordinate)
            }
            .disposed(by: disposeBag)
            
        
    }

}

