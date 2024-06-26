//
//  DateCell.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/23/24.
//

import UIKit
import Then
import SnapKit
import RxSwift

class DateCell: UICollectionViewCell {
    
    // MARK: - Properties
    let disposebag = DisposeBag()
    
    var viewModel: DateCellViewModelType? {
        didSet { configure() }
    }
    
    var isBusinessDay: Bool? {
        didSet { configureTitleColor() }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                selectedCircle.layer.borderColor = UIColor.black.cgColor
                selectedCircle.backgroundColor = UIColor.customLight
            } else {
                selectedCircle.layer.borderColor = UIColor.clear.cgColor
                selectedCircle.backgroundColor = UIColor.clear
            }
        }
    }
    lazy var selectedCircle = UIView().then {
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 0.6
        $0.layer.borderColor = UIColor.clear.cgColor
    }
    
    lazy var dayLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textAlignment = .center
    }
    
    lazy var daysOfWeekLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textAlignment = .center
    }
    
    
    // MARK: - LifeCycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(selectedCircle)
        selectedCircle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-15)
            $0.width.height.equalTo(30)
        }
                
        addSubview(dayLabel)
        dayLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-15)
        }
        
        addSubview(daysOfWeekLabel)
        daysOfWeekLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configure() {
        guard let viewModel = self.viewModel else { return }
        
        // 상영 날짜 셀의 날짜(숫자) 값 받아오기
        viewModel.day
            .bind { [weak self] string in
                self?.dayLabel.text = string
            }
            .disposed(by: disposebag)
        
        // 상영 날짜 셀의 요일 값 받아오기
        viewModel.daysOfweek
            .bind { [weak self] string in
                self?.daysOfWeekLabel.text = string
            }
            .disposed(by: disposebag)
    }
    
    func configureTitleColor() {
        if isBusinessDay! {
            dayLabel.textColor = .black
            daysOfWeekLabel.textColor = .black
        } else {
            dayLabel.textColor = .lightGray
            daysOfWeekLabel.textColor = .lightGray
        }
    }
}

