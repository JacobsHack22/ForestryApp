//
//  CollectionViewPresenter.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

protocol CollectionViewPresenterProtocol: AnyObject {
    func viewDidLoad()
}

class CollectionViewPresenter: CollectionViewPresenterProtocol {
    private struct LogoutAlertString {
        static let title = "Are you sure you want to logout?"
        static let logoutAction = "Logout"
        static let cancelAction = "Cancel"
    }

    weak var view: CollectionView?
    
    func viewDidLoad() {
        print("Collection view did load")
    }
}

