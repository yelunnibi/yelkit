//
//  ZYZVerButton.swift
//  Document
//
//  Created by wz on 2021/10/12.
//

import Foundation

import Foundation
import UIKit

public class ZYZVerButton : UIButton {
    
    var imgname: String = "" {
        didSet {
            icon.image = UIImage(named: imgname)
            self.updateSize()
        }
    }
    
    var tip = "" {
        didSet {
            tiplbl.text = tip
            self.updateSize()
        }
    }
    
    fileprivate var icon = UIImageView()
    fileprivate var tiplbl = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(icon)
        self.addSubview(tiplbl)
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateSize()
    }
    
    func updateSize() {
        icon.image = UIImage(named: imgname)
        tiplbl.text = tip
        tiplbl.sizeToFit()
        let margin: CGFloat = 2

       
        guard self.icon.image != nil else { return }
        let w = max(tiplbl.width, self.icon.image!.size.width)
        self.frame.size.width = w
        self.frame.size.height = tiplbl.height + self.icon.image!.size.height + margin
        let space = (w - self.icon.image!.size.width) / 2
        icon.frame = CGRect(x: space, y: 0, width: self.icon.image!.size.width, height: self.icon.image!.size.height)
        
        tiplbl.frame = CGRect(x: 0, y: icon.frame.maxY + margin, width: w, height: tiplbl.height)
        tiplbl.textAlignment = .center
    }
    
    
    convenience init(img: String, tips: String, fontsize: CGFloat, color: UIColor) {
        self.init(frame: CGRect.zero)
        imgname = img
        tip = tips
        tiplbl.textColor = color
        tiplbl.font = UIFont.systemFont(ofSize: fontsize)
        updateSize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
