//
//  MovieCell.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/12/24.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

class MovieCell: UICollectionViewCell {
    
    // MARK: - Properties
    var imageUrlString: String? {
        didSet { configure() }
    }
    
    var imageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        guard let imageUrlString = imageUrlString else { return }
        imageView.kf.setImage(with: URL(string: imageUrlString))
    }
}
