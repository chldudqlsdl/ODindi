//
//  MovieDetailViewController.swift
//  ODindi
//
//  Created by Youngbin Choi on 5/26/24.
//

import Foundation
import UIKit

class MovieViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: MovieViewModelType
    
    // MARK: - Lifecycle
    init(viewModel: MovieViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .orange
    }
}
