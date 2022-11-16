//
//  UIImage+Util.swift
//  cleaner
//
//  Created by zy on 2020/9/4.
//  Copyright © 2020 gramm. All rights reserved.
//

import Foundation
import UIKit
import Accelerate
import CommonCrypto
import CoreGraphics


extension UIImage
{
    
    /// 修改图片颜色
    /// - Parameters:
    ///   - color: color description
    ///   - blendMode: blendMode description
    /// - Returns: description
    func tint(color: UIColor, blendMode: CGBlendMode) -> UIImage? {
        let drawRect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        //let context = UIGraphicsGetCurrentContext()
        //CGContextClipToMask(context, drawRect, CGImage)
        color.setFill()
        UIRectFill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: 1.0)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage
    }
    
    
    /// 修改为白色模式
    /// - Returns: description
    func whiteMode() -> UIImage? {
        return self.tint(color: .white, blendMode: .destinationIn)
    }
}

extension UIImage {
    
    /// 生成  圆形 imag
    /// - Parameters:
    ///   - size: size description
    ///   - backgroundColor: backgroundColor description
    /// - Returns: description
  static func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension CIImage {
    func toUIImage() -> UIImage? {
        let context = CIContext()
        guard let cgImage = context.createCGImage(self, from: self.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}

extension Data {
    var md5 : String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        _ =  self.withUnsafeBytes { bytes in
            CC_MD5(bytes, CC_LONG(self.count), &digest)
        }
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
}

extension UIImage {
    var md5: String? {
        if let d = self.jpegData(compressionQuality: 1) {
            return d.md5
        }
        return nil
    }
}


// 大小 变换
public extension UIImage {
    
    var ratio: CGFloat {
        return self.size.height / self.size.width
    }
    
    func resizedImage(size: CGSize) -> UIImage {
        if self.size.width < size.width {
            return self
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func resizedImage(size: CGSize) async -> UIImage {
        if self.size.width < size.width {
            return self
        }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// Processing speed is better than resize(:) method
    func resize_vI(_ size: CGSize) -> UIImage? {
        guard  let cgImage = self.cgImage else { return nil }
        
        var format = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 32, colorSpace: nil,
                                          bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.first.rawValue),
                                          version: 0, decode: nil, renderingIntent: .defaultIntent)
        
        var sourceBuffer = vImage_Buffer()
        defer {
            if #available(iOS 13.0, *) {
                sourceBuffer.free()
            } else {
                sourceBuffer.data.deallocate()
            }
        }
        
        var error = vImageBuffer_InitWithCGImage(&sourceBuffer, &format, nil, cgImage, numericCast(kvImageNoFlags))
        guard error == kvImageNoError else { return nil }
        
        let destWidth = Int(size.width)
        let destHeight = Int(size.height)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let destBytesPerRow = destWidth * bytesPerPixel
        
        let destData = UnsafeMutablePointer<UInt8>.allocate(capacity: destHeight * destBytesPerRow)
        defer {
            destData.deallocate()
        }
        var destBuffer = vImage_Buffer(data: destData, height: vImagePixelCount(destHeight), width: vImagePixelCount(destWidth), rowBytes: destBytesPerRow)
        
        // scale the image
        error = vImageScale_ARGB8888(&sourceBuffer, &destBuffer, nil, numericCast(kvImageHighQualityResampling))
        guard error == kvImageNoError else { return nil }
        
        // create a CGImage from vImage_Buffer
        guard let destCGImage = vImageCreateCGImageFromBuffer(&destBuffer, &format, nil, nil, numericCast(kvImageNoFlags), &error)?.takeRetainedValue() else { return nil }
        guard error == kvImageNoError else { return nil }
        
        // create a UIImage
        return UIImage(cgImage: destCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    func clipImage(angle: CGFloat, editRect: CGRect, isCircle: Bool) -> UIImage? {
        let a = ((Int(angle) % 360) - 360) % 360
        var newImage = self
        if a == -90 {
            newImage = self.rotate(orientation: .left)
        } else if a == -180 {
            newImage = self.rotate(orientation: .down)
        } else if a == -270 {
            newImage = self.rotate(orientation: .right)
        }
        guard editRect.size != newImage.size else {
            return newImage
        }
        let origin = CGPoint(x: -editRect.minX, y: -editRect.minY)
        UIGraphicsBeginImageContextWithOptions(editRect.size, false, newImage.scale)
        let context = UIGraphicsGetCurrentContext()
        if isCircle {
            context?.addEllipse(in: CGRect(origin: .zero, size: editRect.size))
            context?.clip()
        }
        newImage.draw(at: origin)
        let temp = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgi = temp?.cgImage else {
            return temp
        }
        let clipImage = UIImage(cgImage: cgi, scale: newImage.scale, orientation: .up)
        return clipImage
    }
    
    
    
    func toCIImage() -> CIImage? {
        var ci = self.ciImage
        if ci == nil, let cg = self.cgImage {
            ci = CIImage(cgImage: cg)
        }
        return ci
    }
    
    func resizedImage(width: CGFloat) -> UIImage {
        let h = (self.size.height / self.size.width) * width
        return self.resizedImage(size: CGSize(width: width, height: h))
    }
    
    func resizedImage(width: CGFloat) async -> UIImage {
        let h = (self.size.height / self.size.width) * width
        return await self.resizedImage(size: CGSize(width: width, height: h))
    }
    
    func resizedScreenWidth() -> UIImage {
        return self.resizedImage(width: CGFloat(UIScreen.width))
    }

    
    func resizedScreenWidth() async -> UIImage {
        return await self.resizedImage(width: CGFloat(UIScreen.width))
    }

    
    
    func resizeImageVI(width: CGFloat) -> UIImage? {
        let h = (self.size.height / self.size.width) * width
        return self.resize_vI(CGSize(width: width, height: h))
    }
    
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        @unknown default:
            print("")
        }
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            print("")
        }
        ctx.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
}

// 生产颜色图片
public extension UIImage {
     static func withColor(_ color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
          let format = UIGraphicsImageRendererFormat()
          format.scale = 1
          let image =  UIGraphicsImageRenderer(size: size, format: format).image { rendererContext in
              color.setFill()
              rendererContext.fill(CGRect(origin: .zero, size: size))
          }
          return image
      }
}

// 压缩图片 上传
extension UIImage {
    func compressImageMid(maxLength: Int) -> Data {
         var compression: CGFloat = 1
        guard var data = self.jpegData(compressionQuality: 1) else { return Data() }
//         XYJLog(message: "压缩前kb: \( Double((data.count)/1024))")
         if data.count < maxLength {
             return data
         }
         print("压缩前kb", data.count / 1024, "KB")
         var max: CGFloat = 1
         var min: CGFloat = 0
         for _ in 0..<6 {
             compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression)!
             if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                 min = compression
             } else if data.count > maxLength {
                 max = compression
             } else {
                 break
             }
         }
//         var resultImage: UIImage = UIImage(data: data)!
         if data.count < maxLength {
             return data
         }
        return self.jpegData(compressionQuality: 0.5) ?? Data()
    }
    
    var uploadData: Data {
//        var imgData: Data?
        if let imgData = self.jpegData(compressionQuality: 0.9) {
            if imgData.count > 2000000 {
                if let nextDa = self.jpegData(compressionQuality: 0.7) {
                    if nextDa.count > 2000000 {
                        if let nextnextDa = self.jpegData(compressionQuality: 0.5) {
                            return nextnextDa
                        }
                    }
                    return nextDa
                }
            }
            return imgData
        }
        
        if  let d = self.pngData() {
            return d
        }
        return Data()
    }
}

public extension UIImage {
    /// 根据文字生成包含第一个文字的图片
    /// - Parameters:
    ///   - text: 文字
    ///   - size: 大小
    ///   - backColor: 颜色
    ///   - textColor: yans
    ///   - isCircle: 是不是要圆形
    /// - Returns: description
    class func image(_ text: String, size: (CGFloat, CGFloat), backColor: UIColor = UIColor(hexString: "#07CB84"), textColor: UIColor = UIColor.white, isCircle: Bool = true) -> UIImage? {
        // 过滤空""
        if text.isEmpty { return nil }
        // 取第一个字符(测试了,太长了的话,效果并不好)
        let letter = (text as NSString).substring(to: 1)
        let sise = CGSize(width: size.0, height: size.1)
        let rect = CGRect(origin: CGPoint.zero, size: sise)
        // 开启上下文
        UIGraphicsBeginImageContext(sise)
        // 拿到上下文
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        // 取较小的边
        let minSide = min(size.0, size.1)
        // 是否圆角裁剪
        if isCircle {
            UIBezierPath(roundedRect: rect, cornerRadius: minSide * 0.5).addClip()
        }
        // 设置填充颜色
        ctx.setFillColor(backColor.cgColor)
        // 填充绘制
        ctx.fill(rect)
        let attr = [NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: minSide * 0.5)]

        let attStr = NSAttributedString(string: letter, attributes: attr)
        let getSize = attStr.getSize()
        var xR = ((minSide - getSize.width) / minSide) / 2
        var yR = ((minSide - getSize.height) / minSide) / 2
        if xR < 0 || xR > 0.5 {
            xR = 0.25
        }

        if yR < 0 || yR > 0.5 {
            yR = 0.25
        }

        // 写入文字
        (letter as NSString).draw(at: CGPoint(x: minSide * xR, y: minSide * yR), withAttributes: attr)
        // 得到图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // 关闭上下文
        UIGraphicsEndImageContext()
        return image
    }
}


extension UIImage {
//    - (UIImage*)drawText:(NSString*)text inImage:(UIImage*)image {
//        if (image == nil) return [[UIImage init] alloc];
//
//        UIFont *font = [UIFont boldSystemFontOfSize:40];
//        CGSize textsize = [text sizeWithFont:font];
//        CGPoint margin = CGPointMake(20, 20);
//        // draw text at bottom-right
//        CGRect textrect = CGRectMake(image.size.width - 0.7 * textsize.width + 0.3 * textsize.width - margin.x,
//                                     image.size.height - textsize.height - margin.y,
//                                     textsize.width,
//                                     textsize.height);
//
//        UIGraphicsBeginImageContext(image.size);
//        // draw image
//        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
//        // draw rotated text
//        [[UIColor lightGrayColor] set];
//        [text drawWithBasePoint:textrect.origin andAngle:-M_PI_4 andFont:font];
//        // get new image
//        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        return newImage;
//    }
    func addFullScreenWatermark(text: String, font: UIFont, color: UIColor) -> UIImage? { 
        let lb = UILabel()
        lb.text = text
        lb.font = font
        lb.textColor = color
        lb.sizeToFit()
        
        let size = lb.frame.size
        
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        
        let ctx = UIGraphicsGetCurrentContext()
        // 先移动到左上角 然后 旋转 然后放大
        ctx?.translateBy(x: -self.size.width, y: -self.size.height)
        ctx?.rotate(by: -CGFloat.pi/10)
        ctx?.scaleBy(x: 3, y: 3)
        // 行数 列数
        let linenum: Int = Int(self.size.height * 3 / (size.height))
        let colnum: Int = Int(self.size.width * 3 / (size.width))
        
        let nstext = text as NSString
        nstext.draw(at: CGPoint(x: 0, y: 0), withAttributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: font])

        
        for lnum in 0..<linenum {
            for cnum in 0..<colnum {
                if lnum % 2 == 0 {
                    if cnum % 2 == 0 {
                        let p = CGPoint(x: CGFloat(cnum) * size.width, y: CGFloat(lnum) * size.height)
                        nstext.draw(at: p, withAttributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: font])
                    } else {
                     // 偶数行 奇数列不显示
                    }
                } else {
                    // 奇数行 偶数列 不显示
                    if cnum % 2 == 0 {
                        
                    } else {
                        let p = CGPoint(x: CGFloat(cnum) * size.width, y: CGFloat(lnum) * size.height)
                        nstext.draw(at: p, withAttributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font: font])
                    }
                }
            }
        }
        
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg
    }
}
