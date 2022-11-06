//
//  ScanViewPresenter.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation
import UIKit

protocol ScanViewPresenterProtocol: AnyObject {
    func viewDidLoad()
    func sendPhoto(image: UIImage)
}

class ScanViewPresenter: ScanViewPresenterProtocol {
    private struct LogoutAlertString {
        static let title = "Are you sure you want to logout?"
        static let logoutAction = "Logout"
        static let cancelAction = "Cancel"
    }

    weak var view: ScanView?
    
    func viewDidLoad() {
        print("Scan view did load")
    }
    
    func sendPhoto(image: UIImage) {
        debugPrint("Sending photo to server.")
        
//        let treeType = "Oak"
//        let treeImage = UIImage(named: "healthy")!
//
        let url = URL(string: "https://forestry-367712.ey.r.appspot.com")!

        var request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let image = UIImage(data: data)
            } else if let error = error {
                print("HTTP Request Failed \(error)")
            }
        }

        task.resume()
        
        //view?.newTree(image: treeImage, type: treeType)
        
        //showLogoutAlert()
    }
    
    func showLogoutAlert() {
        let alert = UIAlertController(
            title: LogoutAlertString.title,
            message: nil,
            preferredStyle: .alert
        )

        let logoutAction: (UIAlertAction) -> Void = { _ in self.logout() }
        alert.addAction(UIAlertAction(title: LogoutAlertString.cancelAction, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: LogoutAlertString.logoutAction, style: .default, handler: logoutAction))
        view?.present(alert: alert)
    }
    
    private func logout() {
        
    }
}
