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
    private let onUpdate = PublishSubject<UserModel>()
    private let onRequest = PublishSubject<Int>()
    private let onResponse = PublishSubject<([UserModel], Bool)>()
    private let onSearchText = BehaviorSubject<String>(value: "")
    private let display = PublishSubject<UserDisplayModel>()
    private var userModels: [UserModel] = []
    private let onNext = PublishSubject<UserModel>()
    
    struct Input {
        let onRequest: AnyObserver<Int>
        let onSearchText: AnyObserver<String>
        let onNext: AnyObserver<UserModel>
        let onUpdate: AnyObserver<UserModel>
    }
    
    struct Output {
        let display: Observable<UserDisplayModel>
        let onNext: Observable<UserModel>
        let onUpdate: Observable<UserModel>
    }
    
    init() {
        input = Input(
            onRequest: onRequest.asObserver(),
            onSearchText: onSearchText.asObserver(),
            onNext: onNext.asObserver(),
            onUpdate: onUpdate.asObserver()
        )
        
        output = Output(
            display: display.asObservable(),
            onNext: onNext.asObservable(),
            onUpdate: onUpdate.asObservable()
        )
        observeInput()
    }
    
    private func observeInput() {
        disposeBag.insert([
            onRequest.subscribe(onNext: { [weak self] userId in
                self?.sendRequest(userId: userId)
            }),
            Observable
                .combineLatest(onResponse, onSearchText.map({ $0.trim().lowercased() }))
                .subscribe(onNext: { [weak self] response, searchText in
                    guard let self = self else {
                        return
                    }
                    if searchText.isEmpty {
                        self.display.onNext(UserDisplayModel(userModels: response.0, isLoadmore: response.1))
                    } else {
                        let searchedUserModels = response.0.filter {
                            return $0.login.lowercased().contains(searchText)
                            || ($0.note?.lowercased().contains(searchText) ?? false)
                        }
                        self.display.onNext(UserDisplayModel(userModels: searchedUserModels, isLoadmore: false))
                    }
                }),
        ])
    }
    
    private func sendRequest(userId: Int) {
        let request = UserRequest(since: userId)
        APIService.shared.doRequestArray(
            request,
            completion: { [weak self] (result: Result<[UserModel], APIError>) in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let success):
                    let processedData = self.processData(userModels: success)
                    if userId == 0 { // first load
                        self.userModels = processedData
                        self.onResponse.onNext((self.userModels, false))
                    } else { // load more
                        self.userModels.append(contentsOf: processedData)
                        self.onResponse.onNext((self.userModels, true))
                    }
                case .failure(let error):
                    if userId == 0 && error == .noInternet {
                        let savedUsers = UserManager.shared.getAllUser()
                        let processedData = self.processData(userModels: savedUsers)
                        self.userModels = processedData
                        self.onResponse.onNext((self.userModels, false))
                    }
                }
            })
    }
    
    private func processData(userModels: [UserModel]) -> [UserModel] {
        var processedUserModels = userModels
        for index in processedUserModels.indices {
            let userId = processedUserModels[index]._id
            if let user = UserManager.shared.getUser(userId: userId) {
                processedUserModels[index].followers = user.followers
                processedUserModels[index].following = user.following
                processedUserModels[index].note = user.note
                processedUserModels[index].blog = user.blog
                processedUserModels[index].company = user.company
                processedUserModels[index].name = user.name
            }
        }
        return processedUserModels
    }
}
