//
//  CustomSlider.swift
//  Document
//
//  Created by wz on 2022/2/25.
//

import Foundation
import UIKit


/// 自定义的slider 可以定义高度
class ZYZCustomSlider: UISlider {
  
  //To set line height value from IB, here ten is default value
  @IBInspectable var trackLineHeight: CGFloat = 3
    @IBInspectable var thumbHeight: CGFloat = 12
  
  //To set custom size of track so here override trackRect function of slider control
  override func trackRect(forBounds bound: CGRect) -> CGRect {
    //Here, set track frame
      let left = bound.origin.x + self.minimumValueImageRect(forBounds: bound).maxX + 10
      let width = bound.width - left
      return CGRect(origin: CGPoint(x: left, y: (bound.height - trackLineHeight) / 2), size: CGSize(width: width, height:  trackLineHeight))
  }
    
//    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
//        
//    }
}


