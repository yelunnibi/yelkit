//
//  UITextFieldPublisher.swift
//  AFNetworking
//
//  Created by wz on 2022/11/25.
//

import Foundation
import Combine
import UIKit

public extension UITextField {
    @available(iOS 13.0, *)
    var publisher: Publishers.TextFieldPublisher {
        return Publishers.TextFieldPublisher(textField: self)
    }
}

@available(iOS 13.0, *)
public extension Publishers {
    struct TextFieldPublisher: Publisher {
        public typealias Output = String
        public typealias Failure = Never
        
        private let textField: UITextField
        
        init(textField: UITextField) { self.textField = textField }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Publishers.TextFieldPublisher.Failure == S.Failure, Publishers.TextFieldPublisher.Output == S.Input {
            let subscription = TextFieldSubscription(subscriber: subscriber, textField: textField)
            subscriber.receive(subscription: subscription)
        }
    }
    
    class TextFieldSubscription<S: Subscriber>: Subscription where S.Input == String, S.Failure == Never  {
        
        private var subscriber: S?
        private weak var textField: UITextField?
        
        init(subscriber: S, textField: UITextField) {
            self.subscriber = subscriber
            self.textField = textField
            subscribe()
        }
        
        public func request(_ demand: Subscribers.Demand) { }
        
        public func cancel() {
            subscriber = nil
            textField = nil
        }
        
        private func subscribe() {
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }

        @objc private func textFieldDidChange(_ textField: UITextField) {
            _ = subscriber?.receive(textField.text ?? "")
        }
    }
}
