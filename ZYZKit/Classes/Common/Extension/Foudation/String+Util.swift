//
//  String+Util.swift
//  cleaner
//
//  Created by zy on 2020/9/4.
//  Copyright © 2020 gramm. All rights reserved.
//

import Foundation
import UIKit

/// pinyin 拼音
public extension String {
    /// 是否有中文
    /// - Returns: description
    func isIncludeChinese() -> Bool {
        for ch in self.unicodeScalars {
            if (0x4e00 < ch.value  && ch.value < 0x9fff) { return true } // 中文字符范围：0x4e00 ~ 0x9fff
        }
        return false
    }
    
    
    /// 转到到拼音
    /// - Parameter hasBlank: hasBlank description
    /// - Returns: description
    func transformToPinyin(hasBlank: Bool = false) -> String {
        let stringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(stringRef,nil, kCFStringTransformToLatin, false) // 转换为带音标的拼音
        CFStringTransform(stringRef, nil, kCFStringTransformStripCombiningMarks, false) // 去掉音标
        let pinyin = stringRef as String
        return hasBlank ? pinyin : pinyin.replacingOccurrences(of: " ", with: "")
    }
    
    /// 获取中文首字母
    ///
    /// - Parameter lowercased: 是否小写（默认大写）
    func transformToPinyinHead(lowercased: Bool = false) -> String {
        let pinyin = self.transformToPinyin(hasBlank: true).capitalized // 字符串转换为首字母大写
        var headPinyinStr = ""
        for ch in pinyin {
            if ch <= "Z" && ch >= "A" {
                headPinyinStr.append(ch) // 获取所有大写字母
            }
        }
        return lowercased ? headPinyinStr.lowercased() : headPinyinStr
    }
}

public extension Array {
    /// 数组内中文按拼音字母排序
    ///
    /// - Parameter ascending: 是否升序（默认升序）
    func sortedByPinyin(ascending: Bool = true) -> Array<String>? {
        if self is Array<String> {
            return (self as! Array<String>).sorted { (value1, value2) -> Bool in
                let pinyin1 = value1.transformToPinyin()
                let pinyin2 = value2.transformToPinyin()
                return pinyin1.compare(pinyin2) == (ascending ? .orderedAscending : .orderedDescending)
            }
        }
        return nil
    }
}


public extension String {
    func zy_widthForComment(fontSize: CGFloat, height: CGFloat = 15) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.width)
    }
    
    func zy_heightForComment(fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)
    }
    
    func zy_heightForComment(fontSize: CGFloat, width: CGFloat, maxHeight: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let rect = NSString(string: self).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(rect.height)>maxHeight ? maxHeight : ceil(rect.height)
    }
    
    func positionOf(sub:String, backwards:Bool = false)->Int {
        var pos = 0
        if let range = range(of:sub, options: backwards ? .backwards : .literal ) {
            if !range.isEmpty {
                pos = self.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}


public extension NSAttributedString {
    /// 获取string文字size
    /// - Returns: description
    func getSize() -> CGSize {
        let lable = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        lable.attributedText = self
        lable.sizeToFit()
        return lable.frame.size
    }
}

public extension String {
    var url: URL {
        if let u = URL(string: self)  {
            return u
        }
        
        if let u = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let ur = URL(string: u) {
                return ur
            }
        }
        return URL(string: "https://www.google.com")!
    }
    
    
    var decodeBase64: String? {
        if let data = Data(base64Encoded: self)  {
            return String(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
}


// for language
public extension String {
    var local: String {
        return NSLocalizedString(self, comment: "")
    }
}


public extension Character {
    var isPureInteger: Bool {
        let s =  String(self)
        let scan = Scanner(string: s)
        var v: Int = 0
        return scan.scanInt(&v) && scan.isAtEnd
    }
}

/// 判断类型
public extension String {
    var isValidValidVCard: Bool {
        let r = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return r.hasPrefix("BEGIN:VCARD")
    }
    
    var isValidWebUrl: Bool {
        let r = self.trimmingCharacters(in: .whitespacesAndNewlines)
        if r.isEmpty {
            return false
        }
        
        guard let url = URL(string: r) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    var isValidPhoneNumber: Bool {
        let r = self.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let systemCharArr: [String] = ["(", ")", "+", "*", "-", "#", ";", " ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let filterStr: String = r.filter {
            !systemCharArr.contains(String($0))
        }
        
        if !filterStr.isEmpty {
            return false
        }
        
        let ns = r.filter {
            $0.isPureInteger
        }
        
        if ns.count >= 3, ns.count <= 20 {
            return true
        }
        return false
    }
    
    var isValidEmail: Bool {
        let r = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let regular = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9-]+\\.[A-Za-z.]{2,10}"
        let filter: NSPredicate = NSPredicate(format: "SELF MATCHES%@", regular)
        return filter.evaluate(with: r)
    }
}

public extension String {
    var fileUrl: URL {
        return URL(fileURLWithPath: self)
    }
    
    static var documentPath: String {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.path
    }
    
    
    /// 创建如果没有路径
    func createDirectoryIfNoExist() {
        var directEx: ObjCBool = false
        if FileManager.default.fileExists(atPath: self, isDirectory: &directEx) == true, directEx.boolValue == true {
        } else {
            try? FileManager.default.createDirectory(at: URL(fileURLWithPath: self), withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    static var tmpPath: String {
        let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
        return tmpDirURL.path
    }
    
    
    /// 匹配最后一个()
    var getLastCurly: String {
        guard let preStr: String = self.components(separatedBy: ".pdf").first else {
            return self
        }
        let reverseStr = String(preStr.reversed())
        let newStr = reverseStr.components(separatedBy: "(").last ?? reverseStr
        return String(newStr.reversed())
    }
    
    /// 匹配最后一个()中的内容
    var getLastCurlyContent: String {
        guard let preStr: String = self.components(separatedBy: ".pdf").first else {
            return self
        }
        let reverseStr = String(preStr.reversed())
        let str = reverseStr.components(separatedBy: "(").first ?? reverseStr
        let newStr = str.components(separatedBy: ")").last ?? str
        return String(newStr.reversed())
    }
    
    /// 重命名  会递归的命名
    /// - Parameters:
    ///   - num: 当前idx
    ///   - originName: 原来名字
    /// - Returns: 返回合适的名字
    static func rename(num: Int, originName: String) -> String {
        let newFileName: String = originName + "(\(num)).pdf"
        let newPath = String.documentPath + "/" + newFileName
        return FileManager.default.fileExists(atPath: newPath) ? rename(num: num + 1, originName: originName) : newFileName
    }

    
    var intValue: Int {
        return Int(self) ?? 0
    }

    var CGFloatValue: CGFloat {
        return CGFloat(Double(self) ?? 0)
    }
    
    /// 判断string内容是否是数字
    var isInt: Bool {
        let scan: Scanner = Scanner(string: self)
        var val: Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }
    
    ///  判断生成新的文件名
    /// - Parameter originFilePath: originFilePath description
    /// - Returns: description
//   static func checkandRenameFilePath(originFilePath: String) -> String {
//        let fileAllName: String = (originFilePath as NSString).lastPathComponent
//        let filePreName: String = fileAllName.getLastCurly
//        let intContent: String = fileAllName.getLastCurlyContent
//        let filePath = PDFDocDocumentCommon.pdfDirectorypath + "/" + fileAllName
//        // 2.判断文件是否存在
//        let fileManager = FileManager.default
//        var toPath = ""
//        if fileManager.fileExists(atPath: filePath) {
//            let newNum: Int = intContent.isInt ? intContent.intValue + 1 : 1
//            let newfileName = String.rename(num: newNum, originName: filePreName)
//            // 拼接新的字符串
//            guard let toThePath = (PDFDocDocumentCommon.pdfDirectorypath + "/" + newfileName).removingPercentEncoding else {
//                return ""
//            }
//            toPath = toThePath
//            if FileManager.default.fileExists(atPath: toPath) {
//                return  checkandRenameFilePath(originFilePath: toPath)
//            }
//        } else {
//            toPath = PDFDocDocumentCommon.pdfDirectorypath + "/" + fileAllName
//        }
//        return toPath
//    }
}

extension StringProtocol {
    
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

