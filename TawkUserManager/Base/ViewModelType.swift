//
//  ViewModelType.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var input: Input { get set }
    var output: Output { get set }
}
