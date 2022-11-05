//
//  ScanViewController.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation
import UIKit

class ScanViewController: UIViewController {
    enum Constants {
        static let headerViewHeight: CGFloat = 140
        static let bottomBarHeight: CGFloat = 80
        static let chooseButtonHeight: CGFloat = 50
        static let closeButtonRadius: CGFloat = 50
        
        static let stdMargin: CGFloat = 16
        static let betweenCells: CGFloat = 30
        
        static let tabBarTitle = "Scan Tree"
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
    
    var scanViewPresenter: ScanViewPresenter?

    private var headerView: UIView = UIView()
    
    private lazy var imagPickUp : UIImagePickerController = {
        let view = UIImagePickerController()
        view.delegate = self
        view.allowsEditing = false
        
        return view
    }()

    private var headerLabel: UILabel = {
        let label = UILabel()
        let font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.font = font
        label.text = Constants.tabBarTitle
        return label
    }()
    
    private lazy var choosePhotoButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.black.cgColor
        button.backgroundColor = .white
        button.setTitle("Choose Image", for: .normal)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action:#selector(self.buttonClicked), for: .touchUpInside)
        
        return button
    }()
    
    private var photoView: UIImageView = {
        let view = UIImageView()
        
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2.0
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.black.cgColor
        
        return view
    }()
    
    private lazy var rejectPhotoButton: UIButton = {
        let button = UIButton()
        
        button.layer.cornerRadius = 25
        button.backgroundColor = .red
        let image = UIImage(systemName: "multiply")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.isHidden = true
        button.addTarget(self, action:#selector(self.rejectButtonClicked), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var sendPhotoButton: UIButton = {
        let button = UIButton()
        
        button.layer.cornerRadius = 20
        button.backgroundColor = .white
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.black.cgColor
        button.setTitle("Send Image", for: .normal)
        button.titleLabel?.font =  UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action:#selector(self.sendButtonClicked), for: .touchUpInside)
        button.isHidden = true
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubviews(
            headerView,
            headerLabel,
            photoView,
            choosePhotoButton,
            rejectPhotoButton,
            sendPhotoButton
        )
        
        view.backgroundColor = mainGreen
        scanViewPresenter?.viewDidLoad()
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
        
        photoView.frame = CGRect(
            x: Constants.stdMargin,
            y: headerLabel.frame.maxY + Constants.betweenCells,
            width: view.frame.width - (Constants.stdMargin * 2),
            height: view.frame.height - (headerLabel.frame.maxY + Constants.betweenCells) - Constants.bottomBarHeight - Constants.betweenCells
        )
        photoView.center.x = view.center.x
        
        choosePhotoButton.frame = CGRect(
            x: 100,
            y: photoView.frame.maxY - Constants.stdMargin - Constants.chooseButtonHeight,
            width: photoView.frame.width - (Constants.stdMargin * 2),
            height: Constants.chooseButtonHeight
        )
        choosePhotoButton.center.x = view.center.x
        
        sendPhotoButton.frame = CGRect(
            x: 100,
            y: photoView.frame.maxY - Constants.stdMargin - Constants.chooseButtonHeight,
            width: photoView.frame.width - (Constants.stdMargin * 2),
            height: Constants.chooseButtonHeight
        )
        sendPhotoButton.center.x = view.center.x
        
        rejectPhotoButton.frame = CGRect(
            x: photoView.frame.maxX - Constants.stdMargin - Constants.closeButtonRadius,
            y: photoView.frame.minY + Constants.stdMargin,
            width: Constants.closeButtonRadius,
            height: Constants.closeButtonRadius
        )
        
        layout.invalidateLayout()
    }
    
    @objc func rejectButtonClicked() {
        photoView.image = nil
        rejectPhotoButton.isHidden = true
        sendPhotoButton.isHidden = true
        choosePhotoButton.isHidden = false
    }
    
    @objc func sendButtonClicked() {
        if let image = photoView.image {
            scanViewPresenter?.sendPhoto(image: image)
        }
    }
        
    @objc func buttonClicked() {
        let ActionSheet = UIAlertController(title: nil, message: "Select Photo", preferredStyle: .actionSheet)

        let cameraPhoto = UIAlertAction(title: "Camera", style: .default, handler: { [self]
            (alert: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){

                imagPickUp.mediaTypes = ["public.image"]
                imagPickUp.sourceType = UIImagePickerController.SourceType.camera;
                self.present(imagPickUp, animated: true, completion: nil)
            }
            else{
                UIAlertController(title: "iOSDevCenter", message: "No Camera available.", preferredStyle: .alert).show(self, sender: nil);
            }

        })

        let PhotoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: { [self]
            (alert: UIAlertAction) -> Void in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                imagPickUp.mediaTypes = ["public.image"]
                imagPickUp.sourceType = UIImagePickerController.SourceType.photoLibrary;
                self.present(imagPickUp, animated: true, completion: nil)
            }

        })

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction) -> Void in

        })

        ActionSheet.addAction(cameraPhoto)
        ActionSheet.addAction(PhotoLibrary)
        ActionSheet.addAction(cancelAction)


        if UIDevice.current.userInterfaceIdiom == .pad{
            let presentC : UIPopoverPresentationController  = ActionSheet.popoverPresentationController!
            presentC.sourceView = self.view
            presentC.sourceRect = self.view.bounds
            self.present(ActionSheet, animated: true, completion: nil)
        }
        else{
            self.present(ActionSheet, animated: true, completion: nil)
        }
    }
}

protocol ScanView: AnyObject {
    func newTree(image: UIImage, type: String)
    func present(alert: UIAlertController)
}

extension ScanViewController: ScanView {
    
    func newTree(image: UIImage, type: String) {
        
    }
    
    func present(alert: UIAlertController) {
        present(alert, animated: true)
    }
}

extension ScanViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        photoView.image = image
        rejectPhotoButton.isHidden = false
        sendPhotoButton.isHidden = false
        choosePhotoButton.isHidden = true
        imagPickUp.dismiss(animated: true, completion: { () -> Void in
            // Dismiss
        })

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagPickUp.dismiss(animated: true, completion: { () -> Void in
            // Dismiss
        })
    }
}

extension ScanViewController: UINavigationControllerDelegate {
    
}
