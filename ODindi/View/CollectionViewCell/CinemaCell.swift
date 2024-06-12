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
    var indieCinema: IndieCinema? {
        didSet { configureTitle() }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                UIView.transition(with: self.insetView, duration: 0.2, options: .transitionCrossDissolve) {
                    self.insetView.layer.borderColor = UIColor.black.cgColor
                    self.insetView.backgroundColor = UIColor.customLight
                }
            } else {
                UIView.transition(with: self.insetView, duration: 0.2, options: .transitionCrossDissolve) {
                    self.insetView.layer.borderColor = UIColor.clear.cgColor
                    self.insetView.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    lazy var insetView = UIView().then {
        $0.layer.cornerRadius = self.frame.height / 2
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 0.6
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    
    lazy var nameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textAlignment = .center
    }
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(insetView)
        insetView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalToSuperview()
            $0.left.equalToSuperview().inset(15)
        }
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalToSuperview().inset(25)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configureTitle() {
        nameLabel.text = indieCinema?.name
    }
}


