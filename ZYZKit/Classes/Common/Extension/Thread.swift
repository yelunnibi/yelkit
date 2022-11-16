//
//  Thread.swift
//  Document
//
//  Created by wz on 2021/11/4.
//

import Foundation
import UIKit

struct ZYThread {
    public typealias Task = () -> Void

    /// 异步操作
    /// - Parameter task: 任务
    public static func async(_ task: @escaping Task) {
        _async(task)
    }

    /// 异步操作
    /// - Parameters:
    ///   - task: 异步任务
    ///   - mainTask: 主线程任务
    public static func async(_ task: @escaping Task,
                             _ mainTask: @escaping Task) {
        _async(task, mainTask)
    }

    /// 内部方法 线程操作
    /// - Parameters:
    ///   - task: 子线程操作
    ///   - mainTask: 主线程操作
    private static func _async(_ task: @escaping Task,
                               _ mainTask: Task? = nil) {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().async(execute: item)

        if let main = mainTask {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
    }

    /// 子线程延迟函数
    ///  Parameters:
    ///   - seconds: 延迟的秒数
    ///   - task: 子线程任务
    /// - Returns: DispatchWorkItem
    @discardableResult
    public static func asyncDelay(_ seconds: Double,
                                  _ task: @escaping Task) -> DispatchWorkItem {
        return _asyncDelay(seconds, task)
    }

    /// 子线程延迟函数
    ///  Parameters:
    ///   - seconds: 延迟的秒数
    ///   - task: 子线程任务
    /// - Returns: DispatchWorkItem
    @discardableResult
    public static func asyncDelay(_ seconds: Double,
                                  _ task: @escaping Task,
                                  _ mainTask: @escaping Task) -> DispatchWorkItem {
        return _asyncDelay(seconds, task, mainTask)
    }

    /// 子线程主线程切换延迟函数
    /// - Parameters:
    ///   - seconds: 延迟秒数
    ///   - task: 子线程任务
    ///   - mainTask: 主线程任务
    /// - Returns: DispatchWorkItem
    private static func _asyncDelay(_ seconds: Double,
                                    _ task: @escaping Task,
                                    _ mainTask: Task? = nil) -> DispatchWorkItem {
        let item = DispatchWorkItem(block: task)
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + seconds, execute: item)
        if let main = mainTask {
            item.notify(queue: DispatchQueue.main, execute: main)
        }
        return item
    }
}
