//
//  CollectionViewController.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation
import UIKit

class CollectionViewController: UIViewController {
    enum Constants {
        static let headerViewHeight: CGFloat = 140
        static let bottomBarHeight: CGFloat = 80
        static let logoutButtonSide: CGFloat = 34
        static let stdPaddingBetweenViews: CGFloat = 30
        
        static let stdMargin: CGFloat = 16
        
        static let tabBarTitle = "My Tree Collection"
    }
    
    private var currentSelectedIndex = 0
    
    private var treeImages: [UIImage] = {
        var arr: [UIImage] = []
        
        var imgs = UserDefaults.standard.object(forKey: "collectionImages") as! [String]
        print(imgs)
        
        for img in imgs {
            var afterEqualsTo = ""
            if let index = img.range(of: "/", options: .backwards)?.upperBound {
                let afterEqualsTo = String(img.suffix(from: index)).replacingOccurrences(of: "%20", with: " ")
                print(afterEqualsTo)
                if let image = getSavedImage(named: afterEqualsTo) {
                    arr.append(image)
                }
            }
        }
        
        print(imgs.count)
                
        return arr
    }()
    
    private var treeNames: [String] = {
        let kek = UserDefaults.standard.object(forKey: "collectionNames") as! [String]
        print(kek)
        return kek
    }()
    
    private var noOfCards : Int {
        get {
            treeImages.count
        }
    }
    private let layout = UICollectionViewFlowLayout()
    private lazy var treeCollectionView: UICollectionView = {
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        view.addGestureRecognizer(longPressedGesture)
    
        return view
    } ()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .secondaryLabel
        indicator.startAnimating()
        return indicator
    }()
    
    var collectionViewPresenter: CollectionViewPresenter?

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
            headerLabel,
            treeCollectionView
        )
        
        treeCollectionView.delegate = self
        treeCollectionView.dataSource = self
        treeCollectionView.register(
            TreeCell.self,
            forCellWithReuseIdentifier: "treeCell"
        )
        treeCollectionView.backgroundColor = mainGreen
        view.backgroundColor = mainGreen

        collectionViewPresenter?.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        treeCollectionView.reloadData()
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
            x: 1.5 * Constants.stdMargin,
            y: headerView.frame.maxY - 60.0,
            width: view.frame.width,
            height: 40
        )
        
        treeCollectionView.frame = CGRect(
            x: 0,
            y: headerLabel.frame.maxY + Constants.stdPaddingBetweenViews,
            width: view.frame.width,
            height: view.frame.height - (headerLabel.frame.maxY + Constants.stdPaddingBetweenViews) - Constants.bottomBarHeight - Constants.stdPaddingBetweenViews
        )

        layout.invalidateLayout()
        print(treeImages, treeNames, noOfCards)
        treeCollectionView.reloadData()
    }
}

extension CollectionViewController: UIGestureRecognizerDelegate {
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }

        let p = gestureRecognizer.location(in: treeCollectionView)

        if let indexPath = treeCollectionView.indexPathForItem(at: p) {
            setFavorite(indexPath.row)
            print(getFavorite())
        }
    }
}

protocol CollectionView: AnyObject {}

extension CollectionViewController: CollectionView {}

extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        noOfCards
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = treeCollectionView.dequeueReusableCell(
            withReuseIdentifier: "treeCell", for: indexPath
        ) as! TreeCell
        cell.configure(TreeModel(image: treeImages[indexPath.row], name: treeNames[indexPath.row]))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width:  treeCollectionView.frame.width,
            height: 400
        )
    }
        
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let currentCell = treeCollectionView.cellForItem(at: IndexPath(row: Int(currentSelectedIndex), section: 0))
        currentCell?.transformToStandard()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        guard scrollView == treeCollectionView else {
            return
        }

        targetContentOffset.pointee = scrollView.contentOffset

        let flowLayout = treeCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = flowLayout.itemSize.width + flowLayout.minimumLineSpacing
        let offset = targetContentOffset.pointee
        let horizontalVelocity = velocity.x

        var selectedIndex = currentSelectedIndex

        switch horizontalVelocity {
        // On swiping
        case _ where horizontalVelocity > 0 :
            selectedIndex = currentSelectedIndex + 1
        case _ where horizontalVelocity < 0:
            selectedIndex = currentSelectedIndex - 1

        // On dragging
        case _ where horizontalVelocity == 0:
            let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
            let roundedIndex = round(index)

            selectedIndex = Int(roundedIndex)
        default:
            print("Incorrect velocity for collection view")
        }

        let safeIndex = max(0, min(selectedIndex, noOfCards - 1))
        let selectedIndexPath = IndexPath(row: safeIndex, section: 0)

        flowLayout.collectionView!.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)

        let previousSelectedIndex = IndexPath(row: Int(currentSelectedIndex), section: 0)
        let previousSelectedCell = treeCollectionView.cellForItem(at: previousSelectedIndex)
        let nextSelectedCell = treeCollectionView.cellForItem(at: selectedIndexPath)

        currentSelectedIndex = selectedIndexPath.row

        previousSelectedCell?.transformToStandard()
        nextSelectedCell?.transformToLarge()
    }
}


