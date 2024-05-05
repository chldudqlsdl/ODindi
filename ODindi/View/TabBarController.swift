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
        configureViewControllers()
        setupBindings()
        configureAutolayout()
    }
    
    
    // MARK: - Helpers
    func configureViewControllers(){
        let nav1 = configureNavController(vc: MainViewController(), image: UIImage(systemName: "map")!)
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
        viewModel.checkLocationAuth
    }
    
    
    // MARK: - Properties
    lazy var button = UIButton(type: .custom).then {
        $0.setTitle("Auth", for: .normal)
        $0.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
    }


// MARK: - AutoLayouts
    
    func configureAutolayout() {
        view.addSubview(button)
        button.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(100)
        }
    }


// MARK: - Selectors
    @objc func btnTapped() {
        LocationService.shared.requestLocation()
            .bind { print($0) }
            .disposed(by: self.disposeBag)
    }

}
