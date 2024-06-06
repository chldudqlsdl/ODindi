//
//  MapDetailViewController.swift
//  ODindi
//
//  Created by Youngbin Choi on 6/4/24.
//

import Foundation
import UIKit
import RxSwift
import WebKit

class MapDetailViewController: UIViewController {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    let viewModel: MapDetailViewModelType
    
    let logoImageView = UIImageView()
    let nameLabel = UILabel()
    let addressLabel = UILabel()
    let instaBtn = UIImageView()
    let instaBtnTapRecognizer = UITapGestureRecognizer()
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    let webView = WKWebView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
        bind()
    }
    
    init(viewModel: MapDetailViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - attribute
    
    func attribute() {
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        
        logoImageView.do {
            $0.contentMode = .scaleAspectFit
        }
        nameLabel.do {
            $0.font = UIFont.customFont(ofSize: 25, style: .pretendardBold)
        }
        addressLabel.do {
            $0.font = UIFont.customFont(ofSize: 15, style: .pretendardMedium)
            $0.textColor = .gray
            $0.textAlignment = .center
        }
        instaBtn.do {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "Instagram_icon")
            $0.addGestureRecognizer(instaBtnTapRecognizer)
            $0.isUserInteractionEnabled = true
        }
    }
    
    
    // MARK: - Layout
    func layout() {
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
            $0.height.lessThanOrEqualTo(50)
            $0.width.lessThanOrEqualTo(150)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(addressLabel)
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.left.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        
        view.addSubview(instaBtn)
        instaBtn.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(10)
            $0.width.height.equalTo(30)
            $0.centerX.equalToSuperview()
        }
        
        webView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
    
    // MARK: - bind
    
    func bind() {
        viewModel.cinemaData
            .bind { [weak self] cinemaData in
                self?.logoImageView.image = UIImage(named: cinemaData.name)
                self?.nameLabel.text = cinemaData.name
                self?.addressLabel.text = cinemaData.address
            }
            .disposed(by: disposeBag)
        
        instaBtnTapRecognizer.rx.event
            .withLatestFrom(viewModel.cinemaData) { _, cinemaData in
                return cinemaData.instagram
            }
            .bind { [weak self] urlString in
                self?.loadingIndicator.startAnimating()
                                
                guard let URL = URL(string: urlString) else { return }
                let URLRequest = URLRequest(url: URL)
                self?.view = self?.webView
                self?.webView.load(URLRequest)
                
//                let vc = UIViewController()
//                vc.view = self?.webView
//                self?.present(vc, animated: true)
            }
            .disposed(by: disposeBag)
    }
}

extension MapDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
}
