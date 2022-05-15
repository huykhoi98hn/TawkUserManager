//
//  UserViewModel.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import Foundation

struct UserDisplayModel {
    var userModels: [UserModel]
    var isLoadmore = false
}

struct UserModel: Codable {
    var _id: Int
    var avatarUrl: String
    var login: String
    var htmlUrl: String
    
    var name: String?
    var followers, following: Int?
    var company: String?
    var blog: String?
    var note: String?
    
    init(user: User) {
        _id = NSNumber(value: user.id).intValue
        avatarUrl = user.avatar_url ?? ""
        login = user.login ?? ""
        htmlUrl = user.html_url ?? ""
        name = user.name
        followers = NSNumber(value: user.followers).intValue
        following = NSNumber(value: user.following).intValue
        company = user.company
        blog = user.blog
        note = user.note
    }
    
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case note // for convert to dict to save to Core Data
        case login, name, followers, following, company, blog
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

