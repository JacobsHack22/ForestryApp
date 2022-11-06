//
//  ScanViewAssembly.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation

class ScanViewAssembly {
    static func createModule() -> ScanViewController {
        let viewController = ScanViewController()
        let presenter = ScanViewPresenter()

        viewController.scanViewPresenter = presenter
        presenter.view = viewController

        return viewController
    }
}
