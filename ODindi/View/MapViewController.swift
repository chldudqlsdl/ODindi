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
            $0.left.right.top.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
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
        
        mapView.rx.didSelect
            .do(onNext: { [weak self] annotationView in
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self?.mapView.deselectAnnotation((annotationView as? MKAnnotation), animated: true)
                }
            })
            .withLatestFrom(viewModel.coordinate) {(annotationView, coordinate) -> (String, CLLocationCoordinate2D)? in
                guard let cinemaNameOptional = annotationView.annotation?.title else { return nil }
                guard let cinemaName = cinemaNameOptional else { return nil }
                return (cinemaName, coordinate)
            }
            .compactMap { $0 }
            .bind { [weak self] (cinemaName, coordinate) in
                self?.configureSheet(cinemaName: cinemaName, coordinate: coordinate)
            }
            .disposed(by: disposeBag)
    }
    
    func configureSheet(cinemaName: String, coordinate: CLLocationCoordinate2D) {
        let vc = MapDetailViewController(viewModel: MapDetailViewModel(coordinate: coordinate, cinemaName: cinemaName))
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
            present(vc, animated: true)
        } else {
            return
        }
    }
}

