//
//  SwitchPublisher.swift
//  AFNetworking
//
//  Created by wz on 2022/11/25.
//

import Foundation
import Combine
import UIKit

public extension UISwitch {
    @available(iOS 13.0, *)
    var publisher: Publishers.SwitchPublisher {
        return Publishers.SwitchPublisher(switcher: self)
    }
}

@available(iOS 13.0, *)
public extension Publishers {
    struct SwitchPublisher: Publisher {
        public typealias Output = Bool
        public typealias Failure = Never
        
        private let switcher: UISwitch
        
        init(switcher: UISwitch) { self.switcher = switcher }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Publishers.SwitchPublisher.Failure == S.Failure, Publishers.SwitchPublisher.Output == S.Input {
            let subscription = SwitchSubscription(subscriber: subscriber, switcher: switcher)
            subscriber.receive(subscription: subscription)
        }
    }
    
    class SwitchSubscription<S: Subscriber>: Subscription where S.Input == Bool, S.Failure == Never {
        
        private var subscriber: S?
        private weak var switcher: UISwitch?
        
        init(subscriber: S, switcher: UISwitch) {
            self.subscriber = subscriber
            self.switcher = switcher
            subscribe()
        }
        
        public func request(_ demand: Subscribers.Demand) { }
        
        public func cancel() {
            subscriber = nil
            switcher = nil
        }
        
        private func subscribe() {
            switcher?.addTarget(self,
                                action: #selector(tap(_:)),
                                for: .valueChanged)
        }
        
        @objc private func tap(_ sender: UISwitch) {
            _ = subscriber?.receive(sender.isOn)
        }
    }
}
