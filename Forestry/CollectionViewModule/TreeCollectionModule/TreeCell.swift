//
//  TreeCell.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation
import UIKit


final class TreeCell: UICollectionViewCell {
    enum Constants {
        static let identifier = "card-cell"
        static let stdInset: CGFloat = 30
    }
    
    private lazy var treeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = "Текст"
        return label
    }()
    
    var configurationModel: TreeModel? = nil
    
    private lazy var treeImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "healthy")
        
        return view
    }()
    
    private lazy var mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(
            mainView
        )
        
        mainView.addSubviews(
            treeImageView,
            treeLabel
        )
        
        contentView.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ withModel: TreeModel) {
        configurationModel = withModel
        
        treeImageView.image = withModel.image
        treeLabel.text = withModel.name
    }
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutTimeLabel()
    }
    
    private func layoutTimeLabel() {
        mainView.frame = CGRect(
            x: Constants.stdInset,
            y: 0,
            width: contentView.frame.width - (Constants.stdInset * 2),
            height: contentView.frame.height
        )

        let size = min(mainView.frame.width - 2 * 20, mainView.frame.maxY * 0.7)
        let inset = (mainView.frame.width - size) / 2
        treeImageView.frame = CGRect(
            x: inset,
            y: inset,
            width: size,
            height: size
        )
        
        treeLabel.frame = CGRect(
            x: 0,
            y: treeImageView.frame.maxY + 10,
            width: mainView.frame.width,
            height: 25
        )
    }
}

extension UICollectionViewCell {
    func transformToLarge() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.2)
        }
    }

    func transformToStandard() {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform.identity
        }
    }

}
