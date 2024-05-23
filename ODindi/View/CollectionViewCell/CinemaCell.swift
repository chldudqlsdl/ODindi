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
        didSet { configureTitle() }
    }
    var isBusinessDay: Bool? {
        didSet { configureTitleColor() }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.insetView.backgroundColor = .yellow
            } else {
                self.insetView.backgroundColor = .systemBackground
            }
        }
    }
    
    lazy var insetView = UIView()
    
    lazy var nameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 15)
//        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        insetView.layer.cornerRadius = self.frame.height / 2
        insetView.layer.masksToBounds = true
        
        addSubview(insetView)
        insetView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalToSuperview()
            $0.width.equalToSuperview().inset(10)
        }
       
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configureTitle() {
        nameLabel.text = name
    }
    func configureTitleColor() {
        if isBusinessDay! {
            nameLabel.textColor = .black
        } else {
            nameLabel.textColor = .lightGray
        }
    }
}


