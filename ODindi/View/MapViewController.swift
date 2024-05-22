//
//  SubViewController.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/5/24.
//

import Foundation
import UIKit
import MapKit
import RxSwift

class MapViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: MapViewModelType
    var disposeBag = DisposeBag()
    let mapView = MKMapView()
    
    // MARK: - LifeCycle
    
    init(viewModel: MapViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
        bind()
    }
    
    // MARK: - Attribute
    private func attribute() {
        view.backgroundColor = .systemBackground
        mapViewAttribute()
    }
    
    private func mapViewAttribute() {
        mapView.showsUserLocation = true
    }
    
    
    // MARK: - Layout
    private func layout() {
        view.addSubview(mapView)
        mapView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    // MARK: - Binding
    func bind() {
        
        self.rx.viewWillAppear
            .withLatestFrom(viewModel.region)
            .bind { [weak self] region in
                self?.mapView.setRegion(region, animated: true)
            }
            .disposed(by: disposeBag)
        
        viewModel.annotations
            .bind { [weak self] annotations in
                annotations.forEach { annotation in
                    self?.mapView.addAnnotation(annotation)
                }
            }
            .disposed(by: disposeBag)
    }
}

