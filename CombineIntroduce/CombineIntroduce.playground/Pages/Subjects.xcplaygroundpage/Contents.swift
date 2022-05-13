//: [Previous](@previous)

import Foundation
import Combine
import SwiftUI

do {
    class Logger {
        var tappedEvent = PassthroughSubject<String, Never>()  // PassthroughSubject: sendメソッドを持つPublisher
    }

    let logger = Logger()
    let subscriber = logger.tappedEvent.sink(receiveValue: { event in
        print("event Name: \(event)")
    })
    logger.tappedEvent.send("LoginButton")
    logger.tappedEvent.send("CameraButton")
    subscriber.cancel()
    logger.tappedEvent.send("LogoutButton")  // 受信されない
}

print("*** 🐱 ***")

do {
    class Logger {
        var tappedEvent = CurrentValueSubject<String, Never>("")  // 送信する値をvalueプロパティに保持する。初期化のイベントも発行される.
    }

    let logger = Logger()
    let subscriber = logger.tappedEvent.sink(receiveValue: { event in
        print("event Name: \(event)")
    })
    logger.tappedEvent.send("LoginButton")
    logger.tappedEvent.value = "CameraButton"  // Valueプロパティの直接更新でも値を送信できる
//    logger.tappedEvent.send(logger.tappedEvent.value)
    subscriber.cancel()
    logger.tappedEvent.value = "LogoutButton"
}

print("*** 🐶 ***")

do {
    class Logger {
        @Published var tappedEventName: String = ""  // CurrentValueSubjectと同じく初期化のイベントも発行される
    }
    let logger = Logger()
    let subscriber = logger.$tappedEventName.sink(receiveValue: { event in
        print("event Name: \(event)")
    })
    logger.tappedEventName = "LoginButton"
    logger.tappedEventName = "CameraButton"
    subscriber.cancel()
    logger.tappedEventName = "LogoutButton"
}

//: [Next](@next)
