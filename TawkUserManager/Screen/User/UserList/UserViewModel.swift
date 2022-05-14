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
    private let onLoading = PublishSubject<Void>()
    private let display = PublishSubject<UserDisplayModel>()
    
    struct Input {
        let onLoading: AnyObserver<Void>
    }
    
    struct Output {
        let display: Observable<UserDisplayModel>
        let onNext: Observable<Void>
    }
    
    init() {
        input = Input(onLoading: onLoading.asObserver())
        output = Output(
            display: display.asObservable(),
            onNext: PublishSubject<Void>()
        )
        observeInput()
    }
    
    private func observeInput() {
        disposeBag.insert([
            onLoading.subscribe(onNext: { [weak self] in
                self?.sendRequest()
            })
        ])
    }
    
    private func sendRequest() {
        
    }
}
