//
//  UIButton+Helper.swift
//  TransOcr
//
//  Created by edz on 2021/4/30.
//

import Foundation
import UIKit

//
//public extension UIButton {
//    static var expandKey = "zyzexpandKey"
//    func zyz_expandSize(width: CGFloat = 0, height: CGFloat = 0) {
//        objc_setAssociatedObject(self, &UIButton.expandKey, CGSize(width: width, height: height), objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
//    }
//    
//    private func expandedRect() -> CGRect {
//        guard let size = objc_getAssociatedObject(self, &UIButton.expandKey) as? CGSize else {
//            return bounds
//        }
//        return CGRect(x: bounds.origin.x - (size.width), y: bounds.origin.y - size.height, width: bounds.size.width + size.width * 2, height: bounds.size.height + size.height * 2)
//    }
//    
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        let r = expandedRect()
//        if r.equalTo(bounds) {
//            return super.point(inside: point, with: event)
//        } else {
//            return r.contains(point)
//        }
//    }
//}

extension UIButton {
    
    
  func alignImageAndTitleVertically(padding: CGFloat = 4.0) {
        self.sizeToFit()
    
        let imageSize = imageView!.frame.size
        let titleSize = titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding

        imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )

        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width - padding,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
}



extension UIButton {
    @discardableResult
    func selectedTxtColor(c: UIColor) -> Self {
        setTitleColor(c, for: .selected)
        return self
    }
    
    @discardableResult
    func highligted(img: String) -> Self {
        setImage(UIImage(named: img), for: .highlighted)
        return self
    }
}

public typealias BtnAction = (UIButton)->()

public extension UIButton{
    
    @discardableResult
    static func custom() -> UIButton {
        return UIButton(type: .custom)
    }
    
    
    @discardableResult
    func normal(txt: String, cor: UIColor, size: CGFloat) -> UIButton {
        self.normalTitle(txt: txt)
        self.txtColor(col: cor)
        self.fontSize(size: size)
        return self
    }
    
    
    @discardableResult
    func normalTitle(txt: String) -> UIButton {
        setTitle(txt, for: .normal)
        return self
    }

    @discardableResult
    func fontSize(size: CGFloat) -> UIButton {
        titleLabel?.font = UIFont.systemFont(ofSize: size)
        return self
    }
    @discardableResult
    func txtColor(col: UIColor) -> UIButton {
        setTitleColor(col, for: .normal)
        return self
    }

    
    @discardableResult
    func selectTitle(txt: String) -> UIButton {
        setTitle(txt, for: .selected)
        return self
    }
 
    @discardableResult
    func normalImage(name: String) -> UIButton {
        setImage(UIImage(named: name), for: .normal)
        return self
    }
    
    @discardableResult
    func selectedImage(name: String) -> UIButton {
        setImage(UIImage(named: name), for: .selected)
        return self
    }
    
    private struct AssociatedKeys{
       static var actionKey = "actionKey"
    }
    
    @objc dynamic var action: BtnAction? {
        set{
            objc_setAssociatedObject(self,&AssociatedKeys.actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get{
            if let action = objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? BtnAction{
                return action
            }
            return nil
        }
    }

    @discardableResult
    func addUpInsideAction(action:@escaping  BtnAction) -> UIButton {
        self.action = action
        self.addTarget(self, action: #selector(touchUpInSideBtnAction), for: .touchUpInside)
        return self
    }

    @objc  func touchUpInSideBtnAction(btn: UIButton) {
        if let action = self.action {
            action(self)
        }
    }
}

//
//extension UIControl {
//    private struct AssociatedKeys{
//       static var actionKey = "actionKey"
//    }
//
//    @objc dynamic var action: BtnAction? {
//        set{
//            objc_setAssociatedObject(self,&AssociatedKeys.actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
//        }
//        get{
//            if let action = objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? BtnAction{
//                return action
//            }
//            return nil
//        }
//    }
//
//    @discardableResult
//    func addUpInsideAction(action:@escaping  BtnAction) -> UIControl {
//        self.action = action
//        self.addTarget(self, action: #selector(touchUpInSideBtnAction), for: .touchUpInside)
//        return self
//    }
//
//    @objc func touchUpInSideBtnAction(btn: UIControl) {
//        if let action = self.action {
//            action(self)
//        }
//    }
//}


extension UIButton {
    @discardableResult
    func imageRight() -> Self {
        transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        return self
    }
}


/// 垂直 button
class PPDFDocVerButton : UIButton {
    fileprivate var icon = UIImageView()
    fileprivate var tiplbl = UILabel()
    
    fileprivate var norTxt: String = "", activeTxt: String = "", norColor: UIColor = .white, activieColor: UIColor = .white, norIcon: String = "", activieIcon: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(icon)
        self.addSubview(tiplbl)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateSize()
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected == true {
                self.icon.image = UIImage(named: self.activieIcon)
                self.tiplbl.text = self.activeTxt
                self.tiplbl.textColor = self.activieColor
            } else {
                self.icon.image = UIImage(named: self.norIcon)
                self.tiplbl.text = self.norTxt
                self.tiplbl.textColor = self.norColor
            }
        }
    }
//
    func updateSize() {
        icon.image = UIImage(named: self.isSelected ? activieIcon : norIcon)
        tiplbl.text = self.isSelected ? activeTxt : norTxt
        tiplbl.sizeToFit()
        let margin: CGFloat = 1

       
        guard self.icon.image != nil else { return }
        let w = max(tiplbl.width, self.icon.image!.size.width)
        self.frame.size.width = w
        self.frame.size.height = tiplbl.height + self.icon.image!.size.height + margin
        let space = (w - self.icon.image!.size.width) / 2
        icon.frame = CGRect(x: space, y: 0, width: self.icon.image!.size.width, height: self.icon.image!.size.height)
        
        tiplbl.frame = CGRect(x: 0, y: icon.frame.maxY + margin, width: w, height: tiplbl.height)
        tiplbl.textAlignment = .center
    }
    
    
    convenience init(img: String,selectedImg: String = "", tips: String, fontsize: CGFloat, color: UIColor, selectedColor: UIColor = .white, selectedTips: String = "") {
        self.init(frame: CGRect.zero)
        norIcon = img
        activieIcon = selectedImg
        if activieIcon.isEmpty {
            activieIcon = norIcon
        }
        activieColor = selectedColor
        norColor = color
        norTxt = tips
        tiplbl.textColor = color
        tiplbl.font = UIFont.systemFont(ofSize: fontsize)
        activeTxt = selectedTips.count > 0 ? selectedTips : norTxt
        updateSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
