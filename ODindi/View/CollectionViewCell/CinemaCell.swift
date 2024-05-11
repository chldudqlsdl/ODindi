//
//  CinemaCell.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/10/24.
//

import UIKit
import Then
import SnapKit

class CinemaCell: UICollectionViewCell {
    
    // MARK: - Properties
    var name: String? {
        didSet { configure() }
    }
    
    lazy var nameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 15)
        $0.numberOfLines = 0
    }
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .brown
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure() {
        nameLabel.text = name
    }
}
