//
//  UserViewModel.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 14/05/2022.
//

import RxCocoa
import RxSwift

class UserViewModel: ViewModelType {
    var input: Input
    var output: Output
    private let disposeBag = DisposeBag()
    private let onRequest = PublishSubject<Int>()
    private let onResponse = PublishSubject<[UserModel]>()
    private let searchText = BehaviorSubject<String>(value: "")
    
    
    struct Input {
        let onRequest: AnyObserver<Int>
        let searchText: AnyObserver<String>
    }
    
    struct Output {
        let display: Observable<UserDisplayModel>
        let onNext: Observable<Void>
    }
    
    init() {
        input = Input(
            onRequest: onRequest.asObserver(),
            searchText: searchText.asObserver()
        )
        output = Output(
            display: Observable
                .combineLatest(onResponse, searchText.map({ $0.trim() }))
                .map { userModels, searchText in
                    if searchText.isEmpty {
                        return UserDisplayModel(userModels: userModels)
                    }
                    let searchedUserModels = userModels.filter {
                        return $0.login.contains(searchText) || ($0.note?.contains(searchText) ?? false)
                    }
                    return UserDisplayModel(userModels: searchedUserModels)
                },
            onNext: PublishSubject<Void>()
        )
        observeInput()
    }
    
    private func observeInput() {
        disposeBag.insert([
            onRequest.subscribe(onNext: { [weak self] userId in
                self?.sendRequest(userId: userId)
            })
        ])
    }
    
    private func sendRequest(userId: Int) {
        let request = UserRequest(since: userId)
        APIService.shared.doRequestArray(
            request,
            completion: { [weak self] (result: Result<[UserModel], APIError>) in
                switch result {
                case .success(let success):
                    self?.onResponse.onNext(success)
                case .failure(_):
                    break
                }
            })
    }
}
