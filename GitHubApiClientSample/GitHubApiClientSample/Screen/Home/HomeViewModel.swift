//
//  HomeViewModel.swift
//  GitHubApiClientSample
//
//  Created by satoutakeshi on 2020/02/01.
//  Copyright © 2020 satoutakeshi. All rights reserved.
//

import Foundation
import Combine
import UIKit

final class HomeViewModel: ObservableObject {

    // MARK: - Inputs
    enum Inputs {
        case onCommit(text: String)  // TextFieldで入力操作が終わった
        case tappedCardView(urlString: String)
    }

    // MARK: - Outputs
    @Published private(set) var cardViewInputs: [CardView.Input] = []
    @Published var inputText: String = ""
    @Published var isShowError = false
    @Published var isLoading = false
    @Published var isShowSheet = false
    @Published var repositoryUrl: String = ""

    init(apiService: APIServiceType) {
        self.apiService = apiService
        bind()  // Subjectをバインドする
    }
    
    // Inputsの実行
    func apply(inputs: Inputs) {
        switch inputs {
            case .onCommit(let inputText):
                onCommitSubject.send(inputText)
            case .tappedCardView(let urlString):
                repositoryUrl = urlString
                isShowSheet = true
        }
    }

    // MARK: - Private
    private let apiService: APIServiceType
    private let onCommitSubject = PassthroughSubject<String, Never>()  // sendメソッドを持つPublisher
    private let errorSubject = PassthroughSubject<APIServiceError, Never>()
    private var cancellables: [AnyCancellable] = []

    private func bind() {
        
        // APIリクエストの実行
        let responseSubscriber = onCommitSubject
            .flatMap { [apiService] (query) in
                
                // APIの呼びだし
                // catch: エラーが起こった場合にストリームの型変換をして新しいPublisherとしてイベントを流すOperator
                
                apiService.request(with: SearchRepositoryRequest(query: query))
                    .catch { [weak self] error -> Empty<SearchRepositoryResponse, Never> in
                        self?.errorSubject.send(error)  // エラーハンドリング
                        return .init()  // := Empty<SearchRepositoryResponse, Never>.init()
                    }
            }
            .map{ response in
                response.items
            }
            .sink(receiveValue: { [weak self] (repositories) in
                guard let self = self else { return }
                self.cardViewInputs = self.convertInput(repositories: repositories)
                self.inputText = ""
                self.isLoading = false
            })

        let loadingStartSubscriber = onCommitSubject
            .map { _ in true }
            .assign(to: \.isLoading, on: self)  // self.isLoadingをtrueに更新

        let errorSubscriber = errorSubject
            .sink(receiveValue: { [weak self] (error) in
                guard let self = self else { return }
                self.isShowError = true
                self.isLoading = false
            })

        cancellables += [
            responseSubscriber,
            loadingStartSubscriber,
            errorSubscriber
        ]
    }

    private func convertInput(repositories: [Repository]) -> [CardView.Input] {
        return repositories.compactMap { (repo) -> CardView.Input? in
            guard let url = URL(string: repo.owner.avatarUrl) else {
                return nil
            }
            let data = try? Data(contentsOf: url)
            let image = UIImage(data: data ?? Data()) ?? UIImage()
            return CardView.Input(iconImage: image,
                                  title: repo.name,
                                  language: repo.language,
                                  star: repo.stargazersCount,
                                  description: repo.description,
                                  url: repo.htmlUrl)
        }
    }
}
