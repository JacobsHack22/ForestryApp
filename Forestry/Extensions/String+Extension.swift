//
//  String+Extension.swift
//  Forestry
//
//  Created by Андрей on 06.11.2022.
//


import Foundation
import UIKit

extension String {
    func appendingPath(_ path: String = "") -> String {
        self + "/" + path
    }
}
