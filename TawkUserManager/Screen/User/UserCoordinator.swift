//
//  HomeCoordinator.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import UIKit
import RxSwift

class UserCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var userViewModel: UserViewModel?
    private let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func start() {
        let userViewController = UserViewController()
        let userViewModel = UserViewModel()
        self.userViewModel = userViewModel
        userViewModel.output.onNext.subscribe(onNext: { [weak self] userModel in
            self?.goToUserDetail(userModel: userModel)
        }).disposed(by: disposeBag)
        userViewController.configViewModel(viewModel: userViewModel)
        navigationController.pushViewController(userViewController, animated: false)
    }
    
    func goToUserDetail(userModel: UserModel) {
        let userDetailViewController = UserDetailViewController()
        let userDetailViewModel = UserDetailViewModel(userModel: userModel)
        userDetailViewModel.output.onBack.subscribe(onNext: { [weak self] userModel in
            self?.navigationController.popViewController(animated: true)
            self?.userViewModel?.input.onUpdate.onNext(userModel)
        }).disposed(by: disposeBag)
        userDetailViewController.configViewModel(viewModel: userDetailViewModel)
        navigationController.pushViewController(userDetailViewController, animated: true)
    }
}
