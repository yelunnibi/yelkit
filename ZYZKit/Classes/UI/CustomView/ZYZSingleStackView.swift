//
//  ZYZSingleStackView.swift
//  DocumentCS
//
//  Created by wz on 2022/4/1.
//

import Foundation
import UIKit
//
/////  自定义的stackview 能实现子元素 只能单独选中，
//class ZYZSingleSelectStackView: UIView {
//    var selectedItem: ZYItemSelectable?
//
//    var animated: Bool = false
//    var items: [ZYItemSelectable] = [] {
//        didSet {
//            self.subviews.forEach { element in
//                element.removeFromSuperview()
//            }
//            items.forEach { element in
//                self.addSubview(element)
//            }
//        }
//    }
//
//    func select(item: ZYItemSelectable) {
//        selectedItem?.isSelected = false
//        item.isSelected = true
//        selectedItem = item
//    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        // 主要是处理 在元素 宽高不等问题
//        items.forEach { element in
//            if element.width <= 0 || element.height <= 0 {
//                element.sizeToFit()
//            }
//        }
//
//        let itemsW =  items.reduce(0) { w, item in
//            w + item.frame.size.width
//        }
//
//        let space = (self.width - itemsW) / CGFloat(items.count + 1)
//        for (idx, item) in items.enumerated() {
//            var beforeItemsW: CGFloat = 0
//            item.frame.origin.y = (self.height - item.height) / 2
//            if idx >= 1 {
//               let subitems = items[0...(idx-1)]
//               beforeItemsW = subitems.reduce(0) { partialResult, item in
//                    partialResult + item.frame.size.width
//                }
//            }
//
//            if self.animated {
//                UIView.animate(withDuration: 0.25) {
//                    item.frame.origin.x = space * CGFloat(idx+1) + beforeItemsW
//                } completion: { f in
//
//                }
//            } else {
//                item.frame.origin.x = space * CGFloat(idx+1) + beforeItemsW
//            }
//        }
//    }
//}
//
//
//
///// 自由选择  可单选 || 可不选
//class ZYCustomSelectStackView: ZYSingleSelectStackView {
//    func toggle(item: ZYItemSelectable) {
//        if self.selectedItem != nil, item == self.selectedItem! {
//            self.selectedItem = nil
//            item.isSelected = false
//        } else {
//            selectedItem?.isSelected = false
//            item.isSelected = true
//            selectedItem = item
//        }
//    }
//}
//
//
/////  支持点击选中
//protocol ZYItemSelectable: UIView {
//     var isSelected: Bool { get set }
//
//    ///  选中
//     func select()
//}
//
//extension ZYItemSelectable {
//    func select() {
//        if let v = self.superview as? ZYSingleSelectStackView {
//            v.select(item: self)
//        }
//    }
//}
//
//extension UIControl: ZYItemSelectable {
//
//}
//
//protocol PDFDocStackItem: UIView {
//}
//
//
//extension UIView: PDFDocStackItem {
//}
//
//
///// 自动排列
//protocol PDFDocStackView: UIView {
//    var items: [PDFDocStackItem] { get set}
//
//    func layoutSubviews()
//}
//
//extension PDFDocStackView {
//     func layoutSubviews() {
////        super.layoutSubviews()
//
//        // 主要是处理 在元素 宽高不等问题
//
//        items.forEach { element in
//            element.sizeToFit()
//        }
//
//        let itemsW =  items.reduce(0) { w, item in
//            w + item.frame.size.width
//        }
//
//        let space = (self.width - itemsW) / CGFloat(items.count + 1)
//        for (idx, item) in items.enumerated() {
//            var beforeItemsW: CGFloat = 0
//            item.frame.origin.y = (self.height - item.height) / 2
//            if idx >= 1 {
//               let subitems = items[0...(idx-1)]
//               beforeItemsW = subitems.reduce(0) { partialResult, item in
//                    partialResult + item.frame.size.width
//                }
//            }
//           item.frame.origin.x = space * CGFloat(idx+1) + beforeItemsW
//        }
//    }
//}
//
//
//
