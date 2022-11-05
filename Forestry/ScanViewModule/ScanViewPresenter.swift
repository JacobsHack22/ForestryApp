//
//  ScanViewPresenter.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation
import Alamofire
import UIKit

protocol ScanViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func sendPhoto(image: UIImage)
}

struct Response {
    
}

class ScanViewPresenter: ScanViewPresenterProtocol {
    private struct LogoutAlertString {
        static let title = "A new tree has been added"
        static let cancelAction = "Okay"
    }

    weak var view: ScanView?
    
    func viewDidLoad() {
        print("Scan view did load")
    }
    
    func sendPhoto(image: UIImage) {
        debugPrint("Sending photo to server.")
        let img = UIImage(named: "Tree")
        addToUDcollection(img: img, name: "Tree")
//        emptyCollections()
        
        showAlert()
    }
    
    func showAlert() {
        let alert = UIAlertController(
            title: LogoutAlertString.title,
            message: nil,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: LogoutAlertString.cancelAction, style: .cancel, handler: nil))
        view?.present(alert: alert)
    }
}
