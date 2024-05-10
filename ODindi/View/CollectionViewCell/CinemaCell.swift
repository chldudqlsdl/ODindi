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
    var name: String?
    
    lazy var nameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
        $0.text = self.name
    }
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .brown
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configureUI() {
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }
}
