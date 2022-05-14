//
//  HomeCoordinator.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import UIKit

class UserCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let userViewController = UserViewController()
        let userViewModel = UserViewModel()
        userViewController.configViewModel(viewModel: userViewModel)
        navigationController.pushViewController(userViewController, animated: false)
    }
}
