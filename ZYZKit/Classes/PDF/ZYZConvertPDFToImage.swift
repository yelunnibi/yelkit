//
//  ZYConvertPDFToImage.swift
//  DocumentCS
//
//  Created by wz on 2022/5/27.
//

import Foundation
import PDFKit

/// 把pdf 转化成image
class ZYZConvertPDFToImage {
    /// 把pdf 2 document
    /// - Parameter url: url description
    /// - Returns: description
//    func convertPDF(url: URL) async -> String? {
//        guard let document = PDFDocument(url: url) else { return  nil}
//        // Get the first page of the PDF document.
//        guard let page = document.page(at: 0) else { return  nil}
//        guard let id =  await DCSDocument.addNewDocument(image: self.draw(page: page)) else { return nil }
//
//        guard let doc = DCSDocument.loadDocument(identifier: id) else { return nil }
//        for i in 1...document.pageCount {
//            if let page = document.page(at: i) {
//                _ = await doc.newPage(image: self.draw(page: page))
//            }
//        }
//        // 删除
//        try? FileManager.default.removeItem(at: url)
//        return doc.identify
//    }
    
    func draw(page: PDFPage) -> UIImage {
        print("draw pdf page image = \(Thread.current)")
        // Fetch the page rect for the page we want to render.
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            // Set and fill the background color.
            UIColor.white.set()
            ctx.fill(CGRect(x: 0, y: 0, width: pageRect.width, height: pageRect.height))

            // Translate the context so that we only draw the `cropRect`.
            ctx.cgContext.translateBy(x: -pageRect.origin.x, y: pageRect.size.height - pageRect.origin.y)

            // Flip the context vertically because the Core Graphics coordinate system starts from the bottom.
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

            // Draw the PDF page.
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
        return img.resizedScreenWidth()
    }
}
 
