//
//  MainViewPresenter.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation

protocol MainViewPresenterProtocol: AnyObject {
    func viewDidLoad()
}

class MainViewPresenter: MainViewPresenterProtocol {
    private struct LogoutAlertString {
        static let title = "Are you sure you want to logout?"
        static let logoutAction = "Logout"
        static let cancelAction = "Cancel"
    }

    weak var view: MainView?
    
    func viewDidLoad() {
        print("Main view did load")
    }
}
