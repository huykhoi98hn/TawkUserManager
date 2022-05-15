//
//  UserDetailViewModel.swift
//  TawkUserManager
//
//  Created by Savvycom2021 on 15/05/2022.
//

import RxCocoa
import RxSwift

class UserDetailViewModel: ViewModelType {
    var input: Input
    var output: Output
    var userModel: UserModel
    private let disposeBag = DisposeBag()
    private let onLoading = PublishSubject<Void>()
    private let display: BehaviorSubject<UserDetailDisplayModel>
    private let onBack = PublishSubject<UserModel>()
    private let onSaveNote = PublishSubject<UserModel>()
    private let savedNote = PublishSubject<Bool>()
    
    struct Input {
        let onLoading: AnyObserver<Void>
        let onBack: AnyObserver<UserModel>
        let onSaveNote: AnyObserver<UserModel>
    }
    
    struct Output {
        let display: Observable<UserDetailDisplayModel>
        let onBack: Observable<UserModel>
        let savedNote: Observable<Bool>
    }
    
    init(userModel: UserModel) {
        self.userModel = userModel
        display = BehaviorSubject<UserDetailDisplayModel>(value: UserDetailDisplayModel(userModel: userModel))
        input = Input(
            onLoading: onLoading.asObserver(),
            onBack: onBack.asObserver(),
            onSaveNote: onSaveNote.asObserver()
        )
        output = Output(
            display: display.asObservable(),
            onBack: onBack.asObservable(),
            savedNote: savedNote.asObservable()
        )
        observeInput()
    }
    
    private func observeInput() {
        disposeBag.insert([
            onLoading.subscribe(onNext: { [weak self] userName in
                guard let self = self else {
                    return
                }
                self.sendRequest(userModel: self.userModel)
            }),
            onSaveNote.subscribe(onNext: { [weak self] userModel in
                self?.savedNote.onNext(UserManager.shared.saveUser(userModel))
            })
        ])
    }
    
    private func sendRequest(userModel: UserModel) {
        let request = UserDetailRequest(userName: userModel.login)
        APIService.shared.doRequest(
            request,
            completion: { [weak self] (result: Result<UserModel, APIError>) in
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let success):
                    let processedUserModel = self.processData(userModel: success)
                    self.display.onNext(UserDetailDisplayModel(userModel: processedUserModel))
                    UserManager.shared.saveUser(processedUserModel)
                case .failure(_):
                    break
                }
            })
    }
    
    private func processData(userModel: UserModel) -> UserModel {
        var processedUserModel = userModel
        processedUserModel.note = self.userModel.note
        return processedUserModel
    }
}
