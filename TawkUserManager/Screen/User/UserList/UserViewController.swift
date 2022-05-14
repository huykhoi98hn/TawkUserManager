//
//  UserViewController.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class UserViewController: UIViewController {
    private var viewModel: UserViewModel!
    private let disposeBag = DisposeBag()
    var display = UserDisplayModel(userModels: [UserModel(isNote: false), UserModel(isNote: true)])
    
    private lazy var userTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self
        tableView.separatorStyle = .none
        tableView.registerCell(UserNormalTableViewCell.self)
        tableView.registerCell(UserNoteTableViewCell.self)
        tableView.registerCell(UserInvertedTableViewCell.self)
        tableView.registerCell(UserNoteInvertedTableViewCell.self)
        tableView.backgroundColor = Color.white
        return tableView
    }()
    
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
        view.backgroundColor = Color.black
        
        [userTableView].forEach {
            view.addSubview($0)
        }
        
        userTableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
        self.display = display
    }
}
