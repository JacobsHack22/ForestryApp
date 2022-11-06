//
//  UserDefaults.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//

import Foundation
import UIKit

func updateUDCollection() {
    let userDefaults = UserDefaults.standard
    if userDefaults.object(forKey: "collectionImages") == nil {
        let array: [String] = []
        userDefaults.set(array, forKey: "collectionImages")
        userDefaults.set(array, forKey: "collectionNames")
        
        let img = UIImage(named: "dead")
        addToUDcollection(img: img, name: "Dead Bro(")
        let img1 = UIImage(named: "unhealthy")
        addToUDcollection(img: img1, name: "Sick bro")
        let img2 = UIImage(named: "healthy1")
        addToUDcollection(img: img2, name: "Jacobs")
    }
}

func addToUDcollection(img: UIImage?, name: String) {
    if let data = img?.pngData() {
        // Create URL
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("\(name).png")
        
        do {
            // Write to Disk
            try data.write(to: url)

            // Store URL in User Defaults
            let userDefaults = UserDefaults.standard
            var imgs = userDefaults.object(forKey: "collectionImages") as! [String]
            var names = userDefaults.object(forKey: "collectionNames") as! [String]
            imgs.append(url.absoluteString)
            names.append(name)
            
            print(imgs)
            print(names)
            
            userDefaults.set(imgs, forKey: "collectionImages")
            userDefaults.set(names, forKey: "collectionNames")
        } catch {
            print("Unable to Write Data to Disk (\(error))")
        }
    }
}

func getSavedImage(named: String) -> UIImage? {
    if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
        return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
    }
    return nil
}

func setFavorite(_ ind: Int) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(ind, forKey: "favoriteTree")
}

func getFavorite() -> Int {
    let userDefaults = UserDefaults.standard
    return userDefaults.object(forKey: "favoriteTree") as! Int
}

let mainGreen = UIColor(red: 0, green: 0.4863, blue: 0.1922, alpha: 1.0)
