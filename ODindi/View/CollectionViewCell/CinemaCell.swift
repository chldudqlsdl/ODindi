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
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.selectedCircle.backgroundColor = .orange
            } else {
                self.selectedCircle.backgroundColor = .systemBackground
            }
        }
    }
    
    var selectedCircle = UIView()
    
    lazy var nameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 15)
        $0.numberOfLines = 0
    }
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(selectedCircle)
        selectedCircle.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        selectedCircle.layer.cornerRadius = 15
        selectedCircle.layer.masksToBounds = true
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure() {
        nameLabel.text = name
    }
}

