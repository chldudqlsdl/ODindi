//
//  RxMKMapViewDelegateProxy.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/5/24.
//

import Foundation
import RxCocoa
import RxSwift
import MapKit

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    static func registerKnownImplementations() {
        self.register { mapview -> RxMKMapViewDelegateProxy in
            RxMKMapViewDelegateProxy(parentObject: mapview, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: MKMapView) -> MKMapViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: MKMapViewDelegate?, to object: MKMapView) {
        object.delegate = delegate
    }
}

extension Reactive where Base: MKMapView {
    
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: self.base)
    }
    
    var didSelect: Observable<MKAnnotationView> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:didSelect:)))
            .map { params in
                print(params)
                return params[1] as! MKAnnotationView
            }
    }
}
