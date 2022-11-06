//
//  MainViewAssembly.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation

class MainViewAssembly {
    static func createModule() -> MainViewController {
        let viewController = MainViewController()
        let presenter = MainViewPresenter()

        viewController.mainViewPresenter = presenter
        presenter.view = viewController

        return viewController
    }
}
