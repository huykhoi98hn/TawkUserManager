//
//  UserViewController.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import UIKit
import Combine
import SnapKit
import ESPullToRefresh

class UserViewController: UIViewController {
    private var cancelBag = Set<AnyCancellable>()
    var viewModel: UserViewModel!
    var display = UserDisplayModel(userModels: [])
    
    private lazy var userTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.registerCell(UserNormalTableViewCell.self)
        tableView.registerCell(UserNoteTableViewCell.self)
        tableView.registerCell(UserInvertedTableViewCell.self)
        tableView.registerCell(UserNoteInvertedTableViewCell.self)
        tableView.backgroundColor = .white
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
        viewModel.onRequest.send(0)
    }
}
extension UserViewController: ControllerType {

    typealias ViewModelType = UserViewModel
    
    func configViewModel(viewModel: UserViewModel) {
        self.viewModel = viewModel
    }
    
    func setupViews() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(notification:)),
                                               name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(notification:)),
                                               name: UIWindow.keyboardWillHideNotification, object: nil)
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
        addLoadmore()
    }
    
    func bindViewModel() {
        viewModel
            .display
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] display in
                self?.setupDisplay(display: display)
            }).store(in: &cancelBag)
        viewModel
            .onUpdate
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] userModel in
                guard let self = self else {
                    return
                }
                if let index = self.display.userModels.firstIndex(where: { $0._id == userModel._id }) {
                    self.display.userModels[index] = userModel
                    self.userTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }).store(in: &cancelBag)
    }
    
    func setupDisplay(display: UserDisplayModel) {
        if display.isLoadmore {
            userTableView.performBatchUpdates({ [weak self] in
                guard let self = self else {
                    return
                }
                let indexPaths = (self.display.userModels.count..<display.userModels.count).map {
                    IndexPath(row: $0, section: 0)
                }
                self.display = display
                self.userTableView.insertRows(at: indexPaths, with: .none)
                let urls = indexPaths.map { display.userModels[$0.row].avatarUrl }
                ImageDataManager.shared.prefetchImage(urls: urls)
            }, completion: { [weak self] _ in
                self?.userTableView.es.stopLoadingMore()
            })
        } else {
            self.display = display
            userTableView.reloadData()
            ImageDataManager.shared.prefetchImage(urls: display.userModels.map { $0.avatarUrl })
        }
    }
    
    private func addLoadmore() {
        userTableView.contentInset.bottom = 0
        userTableView.es.addInfiniteScrolling { [weak self] in
            guard let self = self,
                  let userId = self.display.userModels.last?._id else {
                      return
                  }
            self.viewModel.onRequest.send(userId)
        }
    }
    
    private func removeLoadmore() {
        userTableView.es.removeRefreshFooter()
        userTableView.contentInset.bottom = 0
    }
    
    @objc private func keyboardShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            userTableView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-keyboardSize.height)
            }
            guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
                  let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
                return
            }
            UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
                guard let self = self else {
                    return
                }
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc private func keyboardHide(notification: NSNotification) {
        userTableView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
            return
        }
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(rawValue: curve), animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension UserViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            addLoadmore()
        } else {
            removeLoadmore()
        }
        viewModel.onSearchText.send(searchText)
    }
}
