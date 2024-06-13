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
import RxAppState

class MainTabBarController: UITabBarController{
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    var viewModel: MainTabBarViewModelType
    
    // MARK: - Lifecycle
    
    init(viewModel: MainTabBarViewModelType = MainTabBarViewModel()) {
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
    }
    
    // MARK: - Attribute
    
    func attribute() {
        view.backgroundColor = .systemBackground
        let appearance = UITabBarAppearance()
        tabBar.standardAppearance = appearance
        tabBar.tintColor = .customMedium
    }
    
    // MARK: - Binding
    
    func bind() {
        
        // 위치 권한 요청
        self.rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.checkLocationAuth)
            .disposed(by: disposeBag)
        
        // 좌표 값 요청
        self.rx.viewWillAppear
            .map { _ in () }
            .bind(to: viewModel.fetchCoordinate)
            .disposed(by: disposeBag)
        
        // 모든 viewController 에 좌표값을 업데이트
        viewModel.currentCoordinate
            .subscribe { [weak self] coordinate in
                self?.configureViewControllers(coordinate: coordinate)
            }
            .disposed(by: disposeBag)
    }
    
    func configureViewControllers(coordinate: CLLocationCoordinate2D){
        let cinemaVM = MainViewModel(coordinate)
        let cinemaVC = MainViewController(viewModel: cinemaVM)
        
        let mapVM = MapViewModel(coordinate)
        let mapVC = MapViewController(viewModel: mapVM)
        
        let bookmarkVM = BookmarkViewModel()
        let bookmarkVC = BookmarkViewController(viewModel: bookmarkVM)
        
        let nav1 = configureNavController(vc: cinemaVC, image: UIImage(systemName: "popcorn")!)
        let nav2 = configureNavController(vc: mapVC, image: UIImage(systemName: "map")!)
        let nav3 = configureNavController(vc: bookmarkVC, image: UIImage(systemName: "bookmark")!)
        viewControllers = [nav1, nav2, nav3]
    }
    func configureNavController(vc: UIViewController, image: UIImage) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.tabBarItem.image = image
        navigationController.tabBarItem.title = ""
        return navigationController
    }
}


