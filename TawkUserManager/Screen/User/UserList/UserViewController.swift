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
    var display = UserDisplayModel(userModels: [])
    
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
    
    private let searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.returnKeyType = .done
        searchBar.showsCancelButton = true
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        viewModel.input.onRequest.onNext(0)
    }
}
extension UserViewController: ControllerType {

    typealias ViewModelType = UserViewModel
    
    func configViewModel(viewModel: UserViewModel) {
        self.viewModel = viewModel
    }
    
    func setupViews() {
        view.backgroundColor = .white
        
        [searchView, userTableView].forEach {
            view.addSubview($0)
        }
        
        searchView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
        }
        
        searchView.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.bottom.equalTo(-16)
            make.leading.trailing.equalToSuperview()
        }
        
        userTableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
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
        userTableView.reloadData()
    }
}

extension UserViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.input.searchText.onNext(searchText)
    }
}
