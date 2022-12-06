//
//  UIScrollView+Util.swift
//  ZYZKit
//
//  Created by wz on 2022/12/6.
//

import Foundation

public extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        if self.contentSize.height < self.bounds.size.height { return }
        let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}
