//
//  UserViewModel.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import Foundation

struct UserDisplayModel {
    let userModels: [UserModel]
}

struct UserModel: Codable {
    var _id: Int
    var avatarUrl: String
    var login: String
    var htmlUrl: String
    var note: String?
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case login
    }
    
    func getCellType(at indexPath: IndexPath) -> UserTableViewCellProtocol.Type {
        if (indexPath.row + 1) % 4 != 0 {
            if let _ = note {
                return UserNoteTableViewCell.self
            } else{
                return UserNormalTableViewCell.self
            }
        } else {
            if let _ = note {
                return UserNoteInvertedTableViewCell.self
            } else{
                return UserInvertedTableViewCell.self
            }
        }
        
    }
}

