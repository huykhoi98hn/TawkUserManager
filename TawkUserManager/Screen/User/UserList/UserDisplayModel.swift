//
//  UserViewModel.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

struct UserDisplayModel {
    let userModels: [UserModel]
}

struct UserModel {
    var isNote = false
    
    func getCellType() -> UserTableViewCellProtocol.Type {
        if isNote {
            return UserNoteTableViewCell.self
        } else{
            return UserNormalTableViewCell.self
        }
    }
}

