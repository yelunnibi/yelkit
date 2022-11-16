//
//  UILabel+Helper.swift
//  TransOcr
//
//  Created by edz on 2021/5/7.
//

import Foundation
import UIKit

public extension UILabel {
    
    static func label(str: String, color: UIColor, font: UIFont) -> UILabel {
        let lb = UILabel()
        lb.text = str
        lb.textColor = color
        lb.font = font
        return lb
    }
}

public extension UILabel {
   
   @discardableResult
   static func lbl(s : String, fon: CGFloat, cor: String)  -> UILabel {
       let lbl = UILabel()
       return lbl.txt(s: s, fon: fon, cor: cor)
   }
   
   @discardableResult
   func txt(s: String) -> Self {
       text = s
       return self
   }
   
   @discardableResult
   func txtcol(c: UIColor) -> Self {
       textColor = c
       return self
   }
   
   @discardableResult
   func txtFont(f: CGFloat) -> Self {
       font = UIFont.systemFont(ofSize: f)
       return self
   }
   
   @discardableResult
   func txt(s : String, fon: CGFloat, cor: String) -> Self {
       textColor = UIColor(hexString: cor)
       font = UIFont.systemFont(ofSize: fon)
       text = s
       return self
   }
    
    @discardableResult
      func custom(s : String, customFon: UIFont, cor: String) -> Self {
          textColor = UIColor(hexString: cor)
          font = customFon
          text = s
          return self
      }
      
    
    @discardableResult
    func addUnderline(lineColor:UIColor) -> Self {
        let content = NSMutableAttributedString(string: text ?? "");
        let contentRange = NSRange(location: 0, length: text?.count ?? 0);
        content.addAttributes([NSAttributedString.Key.underlineStyle:NSNumber(integerLiteral: NSUnderlineStyle.single.rawValue)], range: contentRange)
        content.addAttributes([NSAttributedString.Key.underlineColor:lineColor], range: contentRange)
        self.attributedText = content;
        return self
    }
}
