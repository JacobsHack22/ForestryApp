//
//  MainViewController.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation
import UIKit

class MainViewController: UIViewController {
    enum Constants {
        static let headerViewHeight: CGFloat = 140
        static let bottomBarHeight: CGFloat = 80
        static let logoutButtonSide: CGFloat = 34
        
        static let matchCellMargin: CGFloat = 16
        
        static let tabBarTitle = "My Tree"
    }
    
    private let layout = UICollectionViewFlowLayout()
    private lazy var matchesCollectionView: UICollectionView = {
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return view
    } ()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .secondaryLabel
        indicator.startAnimating()
        return indicator
    }()
    
    var mainViewPresenter: MainViewPresenter?

    private var headerView: UIView = UIView()

    private var headerLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.font = font
        label.text = Constants.tabBarTitle
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(
            headerView,
            headerLabel
        )
        
        view.backgroundColor = .cyan

        mainViewPresenter?.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var uiPrevMaxY: CGFloat = 0
        
        headerView.frame = CGRect(
            x: 0, y: 0,
            width: view.bounds.width, height: Constants.headerViewHeight
        )
        uiPrevMaxY += Constants.headerViewHeight
    
        headerLabel.frame = CGRect(
            x: 1.5 * Constants.matchCellMargin,
            y: headerView.frame.maxY - 60.0,
            width: view.frame.width,
            height: 40
        )

        layout.invalidateLayout()
    }
}

protocol MainView: AnyObject {}

extension MainViewController: MainView {}
