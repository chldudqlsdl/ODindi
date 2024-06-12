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
    let guideLabel = UILabel()
    
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
        mapView.delegate = self
        
        guideLabel.do {
            $0.font = .customFont(ofSize: 16, style: .pretendardSemiBold)
            $0.text = "지도에서 가까운 독립 영화관을\n탐색해보세요 👀"
            $0.backgroundColor = .customLight.withAlphaComponent(0.9)
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.numberOfLines = 2
            $0.textAlignment = .center
        }
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
        
        view.addSubview(guideLabel)
        guideLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
            $0.left.equalToSuperview().inset(40)
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

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "marker"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.markerTintColor = .customMedium
        annotationView?.titleVisibility = .visible
        annotationView?.subtitleVisibility = .visible
        if #available(iOS 14.0, *) {
            annotationView?.collisionMode = .none
        }
        return annotationView
    }
}
