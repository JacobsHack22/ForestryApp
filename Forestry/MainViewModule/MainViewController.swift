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
        static let marginMainTB: CGFloat = 30
        
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
    
    private lazy var myTree: UIImageView = {
        let view = UIImageView()
    
        view.image = getCurrentfavorite()
        
        return view
    }()
    
    private var treeView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.black.cgColor
        
        return view
    }()
    
    private lazy var treeName: UILabel = {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.font = font
        label.textAlignment = .center
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(
            headerView,
            headerLabel,
            treeView
        )
        
        treeView.addSubviews(
            myTree,
            treeName
        )
        
        view.backgroundColor = mainGreen

        mainViewPresenter?.viewDidLoad()
    }
    
    private func getCurrentfavorite() -> UIImage {
        let fav_index = getFavorite()
        
        updateUDCollection()
        let imgs = UserDefaults.standard.object(forKey: "collectionImages") as! [String]
        var arr: [UIImage] = []
        for img in imgs {
            if let index = img.range(of: "/", options: .backwards)?.upperBound {
                let afterEqualsTo = String(img.suffix(from: index)).replacingOccurrences(of: "%20", with: " ")
                if let image = getSavedImage(named: afterEqualsTo) {
                    arr.append(image)
                }
            }
        }
        
        if fav_index >= imgs.count {
            return UIImage(named: "gray")!
        }
        
        let treeImg = arr[fav_index]
        
        return treeImg
    }
    
    private func getCurrentFavoriteName() -> String {
        let fav_index = getFavorite()
        
        updateUDCollection()
        let names = UserDefaults.standard.object(forKey: "collectionNames") as! [String]
        
        if fav_index >= names.count {
            return "Scan a tree!"
        }
        
        return names[fav_index]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        myTree.image = getCurrentfavorite()
        treeName.text = getCurrentFavoriteName()
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
        
        treeView.frame = CGRect(
            x: Constants.matchCellMargin,
            y: headerLabel.frame.maxY + Constants.marginMainTB,
            width: view.frame.width - 2 * Constants.matchCellMargin,
            height: view.frame.maxY - Constants.bottomBarHeight - Constants.marginMainTB - (headerLabel.frame.maxY + Constants.marginMainTB)
        )
        
        myTree.frame = CGRect(
            x: Constants.matchCellMargin,
            y: Constants.matchCellMargin,
            width: treeView.frame.width - 2 * Constants.matchCellMargin,
            height: (treeView.frame.width - 2 * Constants.matchCellMargin) * 1.1
        )
        
        treeName.frame = CGRect(
            x: 0,
            y: myTree.frame.maxY + Constants.matchCellMargin,
            width: myTree.frame.width,
            height: 30
        )
        treeName.center.x = myTree.center.x

        layout.invalidateLayout()
    }
}

protocol MainView: AnyObject {}

extension MainViewController: MainView {}
