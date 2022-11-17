//
//  File.swift
//  
//
//  Created by edz on 2021/4/21.
//

import Foundation
import UIKit


public extension UIViewController {
    /// 触动 反馈
    func feedback() {
        let gene =  UIImpactFeedbackGenerator(style: .light)
        gene.impactOccurred()
    }
}

public extension UIView {
    /// 触动 反馈
    func feedback() {
        let gene =  UIImpactFeedbackGenerator(style: .light)
        gene.impactOccurred()
    }
}

public extension UIView {
    @discardableResult
    func addTo(v: UIView) -> Self {
        v.addSubview(self)
        return self
    }
    
    @discardableResult
    func tag(t: Int) -> Self {
        self.tag = t
        return self
    }
    
    @discardableResult
    func bgColor(c: UIColor) -> Self {
        backgroundColor = c
        return self
    }
    
    @discardableResult
    func shadowCor(c: UIColor, offx: CGFloat = 0, offy: CGFloat = 2,radius: CGFloat = 10, opc: CGFloat = 1) -> Self {
        layer.shadowColor = c.cgColor
        layer.shadowOffset = CGSize(width: offx, height: offy)
        layer.shadowRadius = radius
        layer.shadowOpacity = Float(opc)
        return self
    }
    
    var width: CGFloat {
        return self.frame.size.width
    }
    
    var minY: CGFloat {
        get {
            return self.frame.minX
        }
        
        set {
            self.frame = CGRect(origin: CGPoint(x: self.frame.minX, y: newValue), size: self.frame.size)
        }
    }
    
    
    var maxY: CGFloat {
        get {
            return self.frame.maxY
        }
        
        set {
            self.frame = CGRect(origin: CGPoint(x: self.frame.minX, y: newValue - self.frame.size.height), size: self.frame.size)
        }
    }
    
    
    
    var height: CGFloat {
        return self.frame.size.height
    }
    
    @discardableResult
    func border(color: String, alpha: CGFloat = 1,width: CGFloat = 1) -> Self {
        layer.borderWidth = width
        layer.borderColor = UIColor(hexString: color, alpha: alpha).cgColor
        return self
    }
    
    @discardableResult
    func border(color: UIColor) -> Self {
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
        return self
    }
    
    @discardableResult
    func radius(r: CGFloat) -> Self {
        layer.cornerRadius = r
        if self is UIImageView {
            layer.masksToBounds = true
        }
        return self
    }
}


public extension UIView {
    func addRotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 0.5
        rotation.isCumulative = true
        rotation.repeatCount = 1
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private struct AssociatedKey {
//        static var animationUserInteractKey = "animationUserInteractKey"
        static var viewIdentiferKey = "viewIdentiferKey"
    }
    
    var identifier: String {
        set {
            self.setAssociated(value: newValue, associatedKey: &AssociatedKey.viewIdentiferKey)
        }
        
        get {
            return self.getAssociated(associatedKey: &AssociatedKey.viewIdentiferKey) ?? ""
        }
    }
    
    func findViewById(id: String) -> UIView? {
       return self.subviews.filter { v in
            if v.identifier == id {
                return true
            }
            return false
       }.first
    }
}


public enum Border: Int {
    case top = 0
    case bottom
    case right
    case left
    
    var name: String {
        switch self {
        case .right:
            return "Border" + "right"
        case .left:
            return "Border" + "left"
        case .bottom:
            return "Border" + "bottom"
        case .top:
            return "Border" + "top"
        }
    }
}

public extension UIView {
    @discardableResult
    func addBorder(for side: Border, withColor color: UIColor, borderWidth: CGFloat) -> CALayer {
        var borderLayer: CALayer!
        for la in self.layer.sublayers ?? [] {
            if la.name == side.name {
                borderLayer = la
                break
            }
        }
        
       if borderLayer == nil {
            borderLayer = CALayer()
            borderLayer.name = side.name
        }
       borderLayer.backgroundColor = color.cgColor

       let xOrigin: CGFloat = (side == .right ? frame.width - borderWidth : 0)
       let yOrigin: CGFloat = (side == .bottom ? frame.height - borderWidth : 0)

       let width: CGFloat = (side == .right || side == .left) ? borderWidth : frame.width
       let height: CGFloat = (side == .top || side == .bottom) ? borderWidth : frame.height

       borderLayer.frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
        
       layer.addSublayer(borderLayer)
       return borderLayer
    }
}

public extension CALayer {
    func updateBorderLayer(for side: Border, withViewFrame viewFrame: CGRect) {
        let xOrigin: CGFloat = (side == .right ? viewFrame.width - frame.width : 0)
        let yOrigin: CGFloat = (side == .bottom ? viewFrame.height - frame.height : 0)

        let width: CGFloat = (side == .right || side == .left) ? frame.width : viewFrame.width
        let height: CGFloat = (side == .top || side == .bottom) ? frame.height : viewFrame.height

        frame = CGRect(x: xOrigin, y: yOrigin, width: width, height: height)
    }
}

public extension UIView {
    func roundCorners(radius: CGFloat = 10, corners: UIRectCorner = .allCorners) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            var arr: CACornerMask = []
            
            let allCorners: [UIRectCorner] = [.topLeft, .topRight, .bottomLeft, .bottomRight, .allCorners]
            
            for corn in allCorners {
                if(corners.contains(corn)){
                    switch corn {
                    case .topLeft:
                        arr.insert(.layerMinXMinYCorner)
                    case .topRight:
                        arr.insert(.layerMaxXMinYCorner)
                    case .bottomLeft:
                        arr.insert(.layerMinXMaxYCorner)
                    case .bottomRight:
                        arr.insert(.layerMaxXMaxYCorner)
                    case .allCorners:
                        arr.insert(.layerMinXMinYCorner)
                        arr.insert(.layerMaxXMinYCorner)
                        arr.insert(.layerMinXMaxYCorner)
                        arr.insert(.layerMaxXMaxYCorner)
                    default: break
                    }
                }
            }
            self.layer.maskedCorners = arr
        } else {
            self.roundCornersBezierPath(corners: corners, radius: radius)
        }
    }
    
    private func roundCornersBezierPath(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    static func pushView(view:UIView,nav:UINavigationController){
        let pushVc = UIViewController()
        pushVc.view.addSubview(view)
        nav.pushViewController(pushVc, animated: true)
    }
    
}


public typealias TapGesAction = (UIView)->()
public extension UIView {
    private struct AssociatedKeys{
       static var tapActionKey = "tapActionKey"
    }

    @objc dynamic var tapAction: TapGesAction? {
        set{
            objc_setAssociatedObject(self,&AssociatedKeys.tapActionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get{
            if let tapAction = objc_getAssociatedObject(self, &AssociatedKeys.tapActionKey) as? TapGesAction{
                return tapAction
            }
            return nil
        }
    }

    @discardableResult
    func addTapGesAction(action:@escaping  TapGesAction) -> UIView {
        self.tapAction = action
        self.isUserInteractionEnabled = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGesAction))
        self.addGestureRecognizer(tapGes)
        return self
    }

    @objc func tapGesAction() {
        if let action = self.tapAction {
            action(self)
        }
    }
    
    /// 圆角设置
      ///
      /// - Parameters:
      ///   - view: 需要设置的控件
      ///   - corner: 哪些圆角
      ///   - radii: 圆角半径
      /// - Returns: layer图层
    func configRectCorner(corner: UIRectCorner, radii: CGSize,bounds:CGRect) -> CALayer {
          
          let maskPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: radii)
          
          let maskLayer = CAShapeLayer.init()
          maskLayer.frame = bounds
          maskLayer.path = maskPath.cgPath
          
          return maskLayer
      }
    
    @discardableResult
    func tag(mTag: Int) -> Self {
        tag = mTag
        return self
    }

    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

}
