//
//  UITextView+Util.swift
//  ZYZKit
//
//  Created by wz on 2022/11/21.
//

import Foundation
import Combine


extension UITextField{
       
       @IBInspectable var doneAccessory: Bool{
           get{
               return self.doneAccessory
           }
           set (hasDone) {
               if hasDone{
                   addDoneButtonOnKeyboard()
               }
           }
       }
       
       func addDoneButtonOnKeyboard()
       {
           let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
           doneToolbar.barStyle = .default
           
           let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
           let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
           
           let items = [flexSpace, done]
           doneToolbar.items = items
           doneToolbar.sizeToFit()
           
           self.inputAccessoryView = doneToolbar
       }
       
       @objc func doneButtonAction() {
           self.resignFirstResponder()
       }
   }


public extension UITextView {

    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextView.textDidChangeNotification,
            object: self
        )
        .compactMap { ($0.object as? UITextView)?.text }
        .eraseToAnyPublisher()
    }
}

/// textview 实现returnbtn 点击
extension UITextView: UITextViewDelegate {
    
    /// 添加 toolbar 工具按钮
    ///
    /// - Parameter title:
    public func addButtonOnKeyboard(title: String = "Done") {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        NotificationCenter.default.post(name: NSNotification.Name.tapTextViewToolbarBtnNotification, object: self)
        self.resignFirstResponder()
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            NotificationCenter.default.post(name: NSNotification.Name.tapTextViewReturnBtnNotification, object: self)
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

public extension Notification.Name {
    static let tapTextViewToolbarBtnNotification = Notification.Name("tapTextViewToolbarBtnNotification")
    static let tapTextViewReturnBtnNotification = Notification.Name("tapTextViewReturnBtnNotification")
}

