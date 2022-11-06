//
//  CollectionViewAssembly.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation

class CollectionViewAssembly {
    static func createModule() -> CollectionViewController {
        let viewController = CollectionViewController()
        let presenter = CollectionViewPresenter()

        viewController.collectionViewPresenter = presenter
        presenter.view = viewController

        return viewController
    }
}
