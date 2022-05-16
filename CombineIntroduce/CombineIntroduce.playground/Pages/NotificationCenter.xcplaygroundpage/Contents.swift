import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class News {
    var info: String
    init(info: String) {
        self.info = info
    }
}

extension Notification.Name {
    static let News = Notification.Name("com.combine_introduce.news")
}

print("\n*** 1 ***")

class NewsSubscriber: Subscriber {
    typealias Input = Notification  // NotificationCenter.Publisherと型を合わせる
    typealias Failure = Never  // NotificationCenter.Publisherと型を合わせる
    var publisher: NotificationCenter.Publisher  // Publisher
    var subscription: Subscription?

    init(notificationPublisher: NotificationCenter.Publisher) {
        self.publisher = notificationPublisher
        self.publisher.subscribe(self)  // 1. PublisherにSubscriberが登録
    }
    
    // MARK: - Subscriber Protocol Methods
    
    // 2. PublisherがSubsriptionを送る
    // publisherがsubscriberを登録したときに呼ばれる
    func receive(subscription: Subscription) {
        print("🐱: receive(subscription: Subscription)")
        print(subscription)
        self.subscription = subscription
        subscription.request(.unlimited)
    }
    
    // 3. SubscriberがSubscriptionを通してN個の値をリクエスト
    // publisherから要素が送られてくる。配信個数を要求する
    func receive(_ input: Notification) -> Subscribers.Demand {
        print("🐱: func receive(_ input: Notification) -> Subscribers.Demand {")
        let news = input.object as? News
        print(news?.info ?? "")
        return .unlimited  // 配信個数に制限なし
    }
    
    // 4. Publisherが完了イベントを送る
    // 配信が完了したときに呼ばれる
    func receive(completion: Subscribers.Completion<Never>) {
        print("🐱: func receive(completion: Subscribers.Completion<Never>) {")
        print("completion")
    }
}

do {
    let notificationPublisher = NotificationCenter.Publisher(center: .default, name: .News, object: nil)
    let _ = NewsSubscriber(notificationPublisher: notificationPublisher)  // NewsSubscriberのreceiveが呼ばれる
    notificationPublisher.center.post(name: .News, object: News(info: "you got a news!"))
}

print("\n*** 2 ***")

do {
    // map: Publisherから配信される値を全て変換し、新しいPublisherを作る
    // sink: Subscriberを作成し、Publisherから配信されるイベントをクロージャベールでハンドリングできるOperator
    NotificationCenter.default.publisher(for: .News ,object: nil)
        .map { (notification) -> String in
            print("map")
            return (notification.object as? News)?.info ?? ""
    }.sink(receiveCompletion: { (complition) in
        print("complition")
    }, receiveValue: { newsString in
        print(newsString)
    })
    NotificationCenter.default.post(name: .News, object: News(info: "it's rain today"))
}

print("\n*** 3 ***")

do {
    // assign: Subscriberを作成するOperator
    // Publisherから送信された値をインスタンスのプロパティに代入する -> 今回でいうとlet news
    //
    let news = News(info: "")
    NotificationCenter.default.publisher(for: .News ,object: nil)
        .map { (notification) -> String in
            print("map")
            return (notification.object as? News)?.info ?? ""
        }
        .assign(to: \.info, on: news)  // KeyPath指定
    
    NotificationCenter.default.post(name: .News, object: News(info: "it's rain sunny"))
    print(news.info)
}
