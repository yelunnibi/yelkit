//
//  File.swift
//  
//
//  Created by edz on 2020/12/9.
//

import Foundation
import UIKit

public extension UIViewController {
    func addAlert(msg: String,sure: @escaping () -> Void) {
        let avc = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        avc.addAction(UIAlertAction(title: "ac_sure_str".local , style: .default, handler: { (a) in
            sure()
        }))
        
        avc.addAction(UIAlertAction(title: "ac_cancel_str".local, style: .cancel, handler: { (a) in
            avc.dismiss(animated: true, completion: nil)
        }))
        self.present(avc, animated: true, completion: nil)
    }
    
    func addAlert(title: String, msg: String,sure: @escaping () -> Void, cancel: (() -> Void)?) {
        let avc = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        avc.addAction(UIAlertAction(title: "ac_sure_str".local , style: .default, handler: { (a) in
            sure()
        }))
        
        avc.addAction(UIAlertAction(title: "ac_cancel_str".local, style: .cancel, handler: { (a) in
            avc.dismiss(animated: true) {
                cancel?()
            }
        }))
        self.present(avc, animated: true, completion: nil)
    }
    
    func addAlert(title: String, msg: String, sureTitle: String =  "ac_sure_str".local, cancelTitle: String = "ac_cancel_str".local , sure: @escaping () -> Void, cancel: (() -> Void)?) {
        let avc = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        avc.addAction(UIAlertAction(title: sureTitle , style: .default, handler: { (a) in
            sure()
        }))
        
        avc.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (a) in
            avc.dismiss(animated: true) {
                cancel?()
            }
        }))
        self.present(avc, animated: true, completion: nil)
    }
    
    
    func addActionSheet(title:String? = nil, message: String? = "", actions: [String],sure: @escaping (_ idx: Int) -> Void) {
        let avc = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
        
        for (idx,item) in actions.enumerated() {
            avc.addAction(UIAlertAction(title: item , style: .default, handler: { (a) in
                sure(idx)
            }))
        }
        
        avc.addAction(UIAlertAction(title: "ac_cancel_str".local, style: .cancel, handler: { (a) in
            avc.dismiss(animated: true, completion: nil)
        }))
        self.present(avc, animated: true, completion: nil)
    }
    
    func addTextEditeAlert(title: String = "", msg:String, placeholder: String? = "",content: String? = "", keyboard: UIKeyboardType = .default , secure: Bool = false,sure:@escaping(_ editeStr:String) ->Void, cancel :(() ->Void)?) {
        let avc = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        avc.addAction(UIAlertAction(title: "ac_sure_str".local , style: .default, handler: { (a) in
            let textField = avc.textFields?.first
//            if textField?.text?.count ?? 0 > 0 {
                sure(textField?.text ?? "")
//            }
        }))
        avc.addTextField { textfield in
            textfield.placeholder = placeholder
            textfield.text = content
            textfield.keyboardType = keyboard
            textfield.isSecureTextEntry = secure
        }
        avc.addAction(UIAlertAction(title: "ac_cancel_str".local, style: .cancel, handler: { (a) in
            avc.dismiss(animated: true) {
                cancel?()
            }
        }))
        self.present(avc, animated: true, completion: nil)
    }
    
}
