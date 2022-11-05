//
//  ViewController.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import UIKit

class RootViewController: UITabBarController {
    
    private var mainViewController: UIViewController = {
        let vc = MainViewAssembly.createModule()
        vc.title = MainViewController.Constants.tabBarTitle
        return vc
    } ()
  
    private var scanViewController: UIViewController = {
        let vc = ScanViewAssembly.createModule()
        vc.title = ScanViewController.Constants.tabBarTitle
        return vc
    }()
    
    private var collectionViewController: UIViewController = {
        let vc = CollectionViewAssembly.createModule()
        vc.title = CollectionViewController.Constants.tabBarTitle
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setViewControllers([collectionViewController, mainViewController, scanViewController], animated: false)
        
        guard let items = self.tabBar.items else { return }
        for i in 0...2 {
            items[i].image = UIImage(systemName: ["list.bullet.rectangle.fill", "house", "plus"][i])
        }
        
        self.tabBar.tintColor = .black
        self.view.backgroundColor = .green
    }


}

