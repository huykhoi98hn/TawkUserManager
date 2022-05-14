//
//  UserViewController.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import UIKit
import RxSwift
import RxCocoa

class UserViewController: UIViewController {
    private var viewModel: UserViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        viewModel.input.onLoading.onNext(())
    }
}
extension UserViewController: ControllerType {

    typealias ViewModelType = UserViewModel
    
    func configViewModel(viewModel: UserViewModel) {
        self.viewModel = viewModel
    }
    
    func setupViews() {
        view.backgroundColor = .red
    }
    
    func bindViewModel() {
        let output = viewModel.output
        disposeBag.insert([
            output.display.bind(to: Binder(self) { target, value in
                target.setupDisplay(display: value)
            })
        ])
    }
    
    func setupDisplay(display: UserDisplayModel) {
        title = display.title
    }
}

