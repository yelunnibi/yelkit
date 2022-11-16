//
//  View+Blend.swift
//  DocumentCS
//
//  Created by wz on 2022/5/16.
//

import Foundation
import UIKit

public extension UIView {
       //将当前视图转为UIImage
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

extension UIView {
    
    /// 把image和view混合生成image
    /// - Parameters:
    ///   - image: image description
    ///   - view: view description
    /// - Returns: description
    static func blendImage(image: UIImage, and view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let scale = image.size.width / (view.frame.size.width)
        if let context = UIGraphicsGetCurrentContext() {
            context.concatenate(CGAffineTransform(scaleX: scale, y: scale))
            view.layer.render(in: context)
            context.concatenate(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        }
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return image
        }
        return UIImage(cgImage: cgi, scale: image.scale, orientation: .up)
    }
}


extension UIImage {
    /// 混合两个image
    /// - Parameters:
    ///   - image: image description
    ///   - otherimage: otherimage description
    /// - Returns: description
    static func blendImage(image: UIImage, otherimage: UIImage) async -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        let scale = image.size.width / (otherimage.size.width)
        if let context = UIGraphicsGetCurrentContext() {
            context.concatenate(CGAffineTransform(scaleX: scale, y: scale))
            otherimage.draw(in: CGRect(x: 0, y: 0, width: otherimage.size.width, height: otherimage.size.height))
            context.concatenate(CGAffineTransform(scaleX: 1/scale, y: 1/scale))
        }
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return image
        }
        return UIImage(cgImage: cgi, scale: image.scale, orientation: .up)
    }
}
