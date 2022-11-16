//
//  ZYZPDFManger.swift
//  DocumentCS
//
//  Created by wz on 2022/5/24.
//

import Foundation
import PDFKit
import Zip

//import CollectionConcurrencyKit
import AVFoundation

extension FileManager {
    public static func temporaryFileURL(name: String = UUID().uuidString) -> URL? {
        return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(name)
    }
    
    public static func clearTmpDirectory() {
        let desUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let fileNames = try? FileManager.default.contentsOfDirectory(atPath: desUrl.path)
        guard fileNames?.count ?? 0 > 0  else {
            return
        }
        
        for name in fileNames! {
            var durl = desUrl
            durl.appendPathComponent(name)
            try? FileManager.default.removeItem(at: durl)
        }
    }
}

/// PDF 相关处理
class ZYZPDFManger {
    public static let directoryName = "PDFFiles"
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    public static func createPDFFrom(images list: [UIImage], name: String = UUID().uuidString.appending(".pdf"), pdfpass: String = "", completion: @escaping (URL?) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            var newname = name
            if newname.contains(".pdf") == false {
                newname = name.appending(".pdf")
            }
//            let doc = PDFDocument()
//            var ops: [PDFDocumentWriteOption: Any] = [:]
//            if pdfpass.count > 0 {
//                ops = [PDFDocumentWriteOption.userPasswordOption : pdfpass,
//                       PDFDocumentWriteOption.ownerPasswordOption : pdfpass]
//            }
            
            guard let finalUrl = FileManager.temporaryFileURL(name: newname) else {
                completion(nil)
                return
            }
            
            let num = 10
            let sliceCount = list.count / num
            let left = list.count % num
            
            var urlList: [URL] = []
            
            let totalCount = sliceCount + (left > 0 ? 1 : 0)
            
            for i in 0..<sliceCount {
                autoreleasepool {
                    print(" i >--\(num * i) ---> \((num * (i + 1))) ")
                    if let url =  createSubPDF(images:Array(list[num * i..<(num * (i + 1))]), name: name + "\(i)") {
                        urlList.append(url)
                        if urlList.count == totalCount {
                            print("free oom -->")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                if let url =  mergePDFs(with: urlList, pdfpass: pdfpass, finalUrl: finalUrl) {
                                    completion(url)
                                    return
                                }
                            }
                        }
                    }
                }
            }
            
            if left > 0 {
                autoreleasepool {
                    print(" i >--\(num * sliceCount) ---> \(num * sliceCount + left) ")
                    //                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if let url =  createSubPDF(images: Array(list[num * sliceCount..<(num * sliceCount + left)]), name: name + "\(sliceCount + 1)") {
                        urlList.append(url)
                        if urlList.count == totalCount {
                            print("free oom -->")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                if let url = mergePDFs(with: urlList, pdfpass: pdfpass, finalUrl: finalUrl) {
                                    completion(url)
                                    return
                                }
                            }
                        }
                    }
                }
            }
        }
  
        
        /// 把多个pdf 合并成一个pdf
        /// - Parameters:
        ///   - urls: urls description
        ///   - pdfpass: pdfpass description
        ///   - finalUrl: finalUrl description
        /// - Returns: description
        func mergePDFs(with urls: [URL],pdfpass: String, finalUrl: URL) -> URL? {
            guard urls.isEmpty == false else { return nil }
            print("begin --> merge pdfs")
            var ops: [PDFDocumentWriteOption: Any] = [:]
            if pdfpass.count > 0 {
                ops = [PDFDocumentWriteOption.userPasswordOption : pdfpass,
                       PDFDocumentWriteOption.ownerPasswordOption : pdfpass]
            }
            var pdfdoc: PDFDocument? = nil
            return autoreleasepool { () -> URL? in
                for (_, url) in urls.enumerated() {
                    autoreleasepool {
                        if pdfdoc == nil {
                            pdfdoc = PDFDocument(url: url)
                        } else {
                            if let tempdf = PDFDocument(url: url) {
                                for i in 0..<tempdf.pageCount {
                                    if let page = tempdf.page(at: i) {
                                        pdfdoc?.insert(page, at: pdfdoc!.pageCount)
                                    }
                                }
                            }
                        }
                    }
                }
                if pdfdoc?.write(to: finalUrl, withOptions: ops) == true {
                    return finalUrl
                } else {
                    return pdfdoc?.documentURL
                }
                print("end --> merge pdfs")
            }
        }
        
        func createSubPDF(images list: [UIImage], name: String = UUID().uuidString.appending(".pdf")) -> URL? {
            var newname = name
            if newname.contains(".pdf") == false {
                newname = name.appending(".pdf")
            }
            guard let url = FileManager.temporaryFileURL(name: newname) else {
                return nil
            }
            
            print("begin ---> create pdf")
            return autoreleasepool { () -> URL? in
                let doc = PDFDocument()
                for (idx, img) in list.enumerated() {
                    if let page = PDFPage(image: img) {
                        doc.insert(page, at: idx)
                    }
                }
                
                if  doc.write(to: url) == true {
                    print("end ---> create pdf")
                    return url
                }
                return nil
            }
        }
    }
    
    public static func saveImagestoPDF(images: [UIImage], name: String = UUID().uuidString.appending(".pdf"), pdfpass: String = "") async -> URL? {
        var newname = name
        if newname.contains(".pdf") == false {
            newname = name.appending(".pdf")
        }
        print("--> begin save image to pdf \(newname) ")
        print("\n thread ->\(Thread.current)- Function: \(#function), line: \(#line)")
        
        let doc = PDFDocument()
        var ops: [PDFDocumentWriteOption: Any] = [:]
        if pdfpass.count > 0 {
           ops = [PDFDocumentWriteOption.userPasswordOption : pdfpass,
                       PDFDocumentWriteOption.ownerPasswordOption : pdfpass]
        }
        
        guard let url = FileManager.temporaryFileURL(name: newname) else { return nil }
//        guard doc.write(to: url, withOptions: ops) == true else {
//            return nil
//        }
        
        let num = 10
        let sliceCount = images.count / num
        let left = images.count % num
        
        for i in 0..<sliceCount {
            autoreleasepool {
                print(" i >--\(num * i) ---> \((num * (i + 1))) ")
                self.pdfappendImage(list: Array(images[num * i..<(num * (i + 1))]), url: url)
            }
        }
        
        if left > 0 {
            autoreleasepool {
                print(" i >--\(num * sliceCount) ---> \(num * sliceCount + left) ")
                self.pdfappendImage(list: Array(images[num * sliceCount..<(num * sliceCount + left)]), url: url)
            }
        }
        return url
    }
    
    static func pdfappendImage(list: [UIImage], url: URL, pdfpass: String = "") {
        var doc: PDFDocument? = PDFDocument(url: url)
        if  doc == nil {
            doc = PDFDocument()
        } else {
            if pdfpass.isEmpty == false {
                doc!.unlock(withPassword: pdfpass)
            }
        }
              
        guard doc != nil else { return }
        
        let lastcount = doc!.pageCount
        for (idx,img) in list.enumerated() {
            if let page = PDFPage(image: img) {
                doc!.insert(page, at: idx + lastcount)
                print("\n add page++ thread ->\(Thread.current)- Function: \(#function), line: \(#line)")
            }
        }
        
        var ops: [PDFDocumentWriteOption: Any] = [:]
        if pdfpass.count > 0 {
           ops = [PDFDocumentWriteOption.userPasswordOption : pdfpass,
                       PDFDocumentWriteOption.ownerPasswordOption : pdfpass]
        }
        
      autoreleasepool {
          if doc!.write(to: url, withOptions: ops) == false {
              print(" pdf write error nil ")
          }
        }
    }
    
    
    /// 创建一个数据量比较大的pdf， 当图片数量比较多的时候，一次创建一个pdf，导致内存崩溃
    /// - Parameters:
    ///   - list: list description
    ///   - middle: 中间图片处理环节
    static func createLargePDFFrom(image list: [UIImage], middle: () -> UIImage) {
        
    }
    
    deinit {
        print("ZYZPDFManger deinit")
    }
}

extension ZYZPDFManger {
    
    /// 把document 里面图片生成pdf
//    /// - Parameter document: document description
//    /// - Returns: description
//    public static func saveImagestoPDF(document: String) async ->  URL? {
////        guard let doc = DCSDocument.loadDocument(identifier: document) else { return nil }
////        let imgs =  await doc.fetchImagesSerialIn(pages: doc.pageList)
////        return await ZYZPDFManger.saveImagestoPDF(images: imgs, name: doc.name.appending(".pdf") ,pdfpass: doc.pdfpasword)
//    }
    
    
    /// 把多个document 生成pdf 并zip
    ///  - Parameter ids: ids description
//    ///  - Returns: description
//    public static func zipMutipleDocument(ids: [String]) async -> URL? {
//        FileManager.clearTmpDirectory()
//
//        // 这里不能用concurrent 因为多个大pdf文件并行会导致'NSMallocException', reason: 'Failed to grow buffer'， 使用串行安全
////        let urls =  await ids.asyncCompactMap { ident -> URL? in
////            return await self.saveImagestoPDF(document: ident)
////        }
//
//        do {
//           let u =  try Zip.quickZipFiles(urls, fileName: Date().secondsString.appending(".zip"))
//            return u
//        } catch let err {
//            await MBProgressHUD.debugshowToastMain(" zip faild \(err)")
//            return nil
//        }
//    }
    
}
