//
//  UIImageView+Util.swift
//  Document
//
//  Created by wz on 2021/9/30.
//

import Foundation
import UIKit

let kRotatingTag = 10223


extension UIImageView {
    /// 添加蒙层
    /// - Parameter targetImageView: targetImageView description
    func makeBlurImage(targetImageView:UIImageView?){
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = targetImageView!.bounds

        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        targetImageView?.addSubview(blurEffectView)
    }
}

extension UIImageView {
    /// 获取imageview 里面 aspectfit  image 的实际 frame
    var imageRealRect: CGRect {
        let off =  CGSize.aspectFit(image: self.image!.size, boundingSize: self.bounds.size)
        let rect =  CGRect(x: off.xOffset, y: off.yOffset, width: off.size.width, height: off.size.height)
        return rect
    }
}

extension UIImage {
    func rotate(orientation: UIImage.Orientation) -> UIImage {
        guard let imagRef = self.cgImage else {
            print(" no cgimage ")
            return self
        }
        let rect = CGRect(origin: .zero, size: CGSize(width: CGFloat(imagRef.width), height: CGFloat(imagRef.height)))
        var bnds = rect
        var transform = CGAffineTransform.identity
        
        switch orientation {
        case .up:
            return self
        case .upMirrored:
            transform = transform.translatedBy(x: rect.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .down:
            transform = transform.translatedBy(x: rect.width, y: rect.height)
            transform = transform.rotated(by: .pi)
        case .downMirrored:
            transform = transform.translatedBy(x: 0, y: rect.height)
            transform = transform.scaledBy(x: 1, y: -1)
        case .left:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: 0, y: rect.width)
            transform = transform.rotated(by: CGFloat.pi * 3 / 2)
        case .leftMirrored:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: rect.height, y: rect.width)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat.pi * 3 / 2)
        case .right:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.translatedBy(x: rect.height, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2)
        case .rightMirrored:
            bnds = swapRectWidthAndHeight(bnds)
            transform = transform.scaledBy(x: -1, y: 1)
            transform = transform.rotated(by: CGFloat.pi / 2)
        @unknown default:
            return self
        }
        
        UIGraphicsBeginImageContext(bnds.size)
        let context = UIGraphicsGetCurrentContext()
        switch orientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            context?.scaleBy(x: -1, y: 1)
            context?.translateBy(x: -rect.height, y: 0)
        default:
            context?.scaleBy(x: 1, y: -1)
            context?.translateBy(x: 0, y: -rect.height)
        }
        context?.concatenate(transform)
        context?.draw(imagRef, in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
    
    func swapRectWidthAndHeight(_ rect: CGRect) -> CGRect {
        var r = rect
        r.size.width = rect.height
        r.size.height = rect.width
        return r
    }
}



extension CGSize {
    /// 根据imageview 的大小 和image的大小 计算出 aspectfit 下 图片实际大小
    /// - Parameters:
    ///   - aspectRatio: aspectRatio description
    ///   - boundingSize: boundingSize description
    /// - Returns: description
    static func aspectFit(image size: CGSize, boundingSize: CGSize) -> (size: CGSize, xOffset: CGFloat, yOffset: CGFloat)  {
        let mW = boundingSize.width / size.width;
        let mH = boundingSize.height / size.height;
        var fittedWidth = boundingSize.width
        var fittedHeight = boundingSize.height
        var xOffset = CGFloat(0.0)
        var yOffset = CGFloat(0.0)

        if( mH < mW ) {
            fittedWidth = boundingSize.height / size.height * size.width;
            xOffset = abs(boundingSize.width - fittedWidth)/2
        }
        else if( mW < mH ) {
            fittedHeight = boundingSize.width / size.width * size.height;
            yOffset = abs(boundingSize.height - fittedHeight)/2
        }
        let size = CGSize(width: fittedWidth, height: fittedHeight)
        return (size, xOffset, yOffset)
    }
}

extension CGPoint {
    func cartesian(for size: CGSize) -> CGPoint {
        let realPoint = self.applying(CGAffineTransform(scaleX: size.width, y: size.height))
        return CGPoint(x: realPoint.x, y: size.height - realPoint.y)
      }
    
    func clipdistance(to: CGPoint) -> CGFloat {
        return (sqrt(CGPointDistanceSquared(from: self, to: to)))
    }
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    
    /// 计算三个point 之间的夹角  计算 当前点 和其他两个点之间的夹角
    /// - Parameters:
    ///   - point1: point1 description
    ///   - point2: point2 description
    /// - Returns: description
    func angleBetween(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let a = self.clipdistance(to: point1)
        let b = point1.clipdistance(to: point2)
        let c = self.clipdistance(to: point2)
        let angle = acos(((a*a)+(c*c)-(b*b))/((2*(a)*(c))))
        print("angl---\(angle)")
        return angle
    }
    
    static func paralletLine(p1: CGPoint, p2: CGPoint, p3: CGPoint, p4: CGPoint) -> Bool {
        let d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x)
        if d == 0 {
          return true
        }
        return false
    }
    
//    // 查询 相交点
    static func findlinesCrossPoint(p1: CGPoint, p2: CGPoint, p3: CGPoint, p4: CGPoint) -> CGPoint? {

        let d = (p2.x - p1.x)*(p4.y - p3.y) - (p2.y - p1.y)*(p4.x - p3.x)
        if d == 0 {
            return nil
        }
        
        let u = ((p3.x - p1.x)*(p4.y - p3.y) - (p3.y - p1.y)*(p4.x - p3.x))/d
        let v = ((p3.x - p1.x)*(p2.y - p1.y) - (p3.y - p1.y)*(p2.x - p1.x))/d
        if (u < 0.0 || u > 1.0) {
            return nil; // intersection point not between p1 and p2
        }
        if (v < 0.0 || v > 1.0) {
            return nil; // intersection point not between p3 and p4
        }
        var intersection: CGPoint = .zero
        intersection.x = p1.x + u * (p2.x - p1.x)
        intersection.y = p1.y + u * (p2.y - p1.y)
        return intersection
    }
    
    
    static func pointsFormALine(_ points: [CGPoint]) -> Bool {
        
        // helper function to test if CGFloat is close enough to zero
        // to be considered zero
        func isZero(_ f: CGFloat) -> Bool {
            let epsilon: CGFloat = 0.00001

            return abs(f) < epsilon
        }

        // variables for computing linear regression
        var sumXX: CGFloat = 0  // sum of X^2
        var sumXY: CGFloat = 0  // sum of X * Y
        var sumX:  CGFloat = 0  // sum of X
        var sumY:  CGFloat = 0  // sum of Y

        for point in points {
            sumXX += point.x * point.x
            sumXY += point.x * point.y
            sumX  += point.x
            sumY  += point.y
        }

        // n is the number of points
        let n = CGFloat(points.count)

        // compute numerator and denominator of the slope
        let num = n * sumXY - sumX * sumY
        let den = n * sumXX - sumX * sumX

        // is the line vertical or horizontal?
        if isZero(num) || isZero(den) {
            return true
        }
        
        // calculate slope of line
           let m = num / den

           // calculate the y-intercept
           let b = (sumY - m * sumX) / n

           print("y = \(m)x + \(b)")

           // check fit by summing the squares of the errors
           var error: CGFloat = 0
           for point in points {
               // apply equation of line y = mx + b to compute predicted y
               let predictedY = m * point.x + b
               error += pow(predictedY - point.y, 2)
           }

           return isZero(error)
       }
}



extension UIImage {
    /// 四个点  是  左上角维坐标系 的坐标点  顺时针方向, 四个左边点 使用比例值
    func clipImageWithPoint(topLeft: CGPoint, topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint) -> UIImage? {
        let ciImage = CIImage(image: self)
        
        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")
        let imgSize = CGSize(width: self.size.width * self.scale,
                             height: self.size.height * self.scale)
        let context = CIContext(options: nil)
        guard let transform = perspectiveCorrection else { return nil }
        transform.setValue(CIVector(cgPoint: topLeft.cartesian(for: imgSize)),
                           forKey: "inputTopLeft")
        transform.setValue(CIVector(cgPoint: topRight.cartesian(for: imgSize)),
                           forKey: "inputTopRight")
        transform.setValue(CIVector(cgPoint: bottomRight.cartesian(for: imgSize)),
                           forKey: "inputBottomRight")
        transform.setValue(CIVector(cgPoint: bottomLeft.cartesian(for: imgSize)),
                           forKey: "inputBottomLeft")
        transform.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let perspectiveCorrectedImg = transform.outputImage, let cgImage = context.createCGImage(perspectiveCorrectedImg, from: perspectiveCorrectedImg.extent) else { return nil}
        
        return UIImage(cgImage: cgImage)
    }
}


extension UIImageView {
    /// 获取imageview 里面 aspectfit  image 的实际 frame
    var aspectFitImageRealRect: CGRect {
        let off =  CGSize.aspectFit(aspectRatio: self.image!.size, boundingSize: self.bounds.size)
        let rect =  CGRect(x: off.xOffset, y: off.yOffset, width: off.size.width, height: off.size.height)
        return rect
    }
    
    var fitRealFrame: CGRect {
        let off =  CGSize.aspectFit(aspectRatio: self.image!.size, boundingSize: self.bounds.size)
        let rect =  CGRect(x: off.xOffset + self.frame.minX, y: off.yOffset + self.frame.minY, width: off.size.width, height: off.size.height)
        return rect
    }
}


// 旋转
extension UIImageView {
    var isRotating: Bool {
        guard self.superview != nil else {  return  false }
        for view in self.superview!.subviews {
            if view is UIImageView && view.tag == kRotatingTag {
                return true
            }
        }
        
        
        self.image?.toCIImage()
        return false
    }
    
    /// 旋转imageview`
    func rotate(orientation:  UIImage.Orientation, completion: (()-> Void)? = nil) {
        guard self.image != nil else { return }
        
        if let aniview = self.superview?.subviews.filter({ v in
            v.tag == kRotatingTag
        }).last {
            aniview.removeFromSuperview()
        }
        
        if self.isRotating {
            return
        }
        
        let animationImv = UIImageView(image: self.image)
        animationImv.tag = kRotatingTag
        
        self.superview!.addSubview(animationImv)
        
        let fromRect = self.superview!.convert(self.imageRealRect, from: self)
        animationImv.frame = fromRect
        
        let rotatedImg = self.image!.rotate(orientation: orientation)
        self.image = rotatedImg
        
        let toRect = self.superview!.convert(self.imageRealRect, from: self)
        
        var angle = 0.0
        if orientation == .left {
            angle =  -CGFloat.pi/2
        } else {
           angle = CGFloat.pi/2
        }
        let transform = CGAffineTransform(rotationAngle: angle)
        self.alpha = 0
        UIView.animate(withDuration: 0.25, animations: {
            animationImv.transform = transform
            animationImv.frame = toRect
        }) { (_) in
            animationImv.removeFromSuperview()
            self.alpha = 1
            completion?()
        }
    }
}

extension UIImageView {
    @discardableResult
    func img(name: String) -> UIImageView {
        self.image = UIImage(named: name)
        return self
    }
    
    convenience init(name: String) {
        self.init(frame: .zero)
        self.img(name: name)
    }
}
