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
    let mapBtn = UIImageView()
    let instaBtnTapRecognizer = UITapGestureRecognizer()
    let mapBtnTapRecognizer = UITapGestureRecognizer()
    let btnStackView = UIStackView()
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    var webView: WKWebView!
    let webViewController = UIViewController()
    
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
        mapBtn.do {
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "map_icon")
            $0.addGestureRecognizer(mapBtnTapRecognizer)
            $0.isUserInteractionEnabled = true
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 0.1
        }
        btnStackView.do {
            $0.addArrangedSubview(instaBtn)
            $0.addArrangedSubview(mapBtn)
            $0.spacing = 30
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
        
        instaBtn.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        mapBtn.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        view.addSubview(btnStackView)
        btnStackView.snp.makeConstraints {
            $0.top.equalTo(addressLabel.snp.bottom).offset(15)
            $0.centerX.equalToSuperview()
        }
    }
    
    func layoutIndicator() {
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
            .bind { [weak self] _ in
                self?.configureWebViewController()
                self?.viewModel.instaBtnTapped.onNext(())
            }
            .disposed(by: disposeBag)
        
        mapBtnTapRecognizer.rx.event
            .bind { [weak self] _ in
                self?.configureWebViewController()
                self?.viewModel.mapBtnTapped.onNext(())
            }
            .disposed(by: disposeBag)
        
        viewModel.urlRequest
            .bind { [weak self] URLRequest in
                self?.webView.load(URLRequest)
            }
            .disposed(by: disposeBag)
    }
    
    func configureWebViewController() {
        self.webView = WKWebView()
        self.layoutIndicator()
        self.webView.navigationDelegate = self
        self.loadingIndicator.startAnimating()
        webViewController.view = self.webView
        self.present(webViewController, animated: true)
    }
}

extension MapDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }
}
