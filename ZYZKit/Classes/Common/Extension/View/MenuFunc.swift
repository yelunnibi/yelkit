//
//  File.swift
//  
//
//  Created by edz on 2020/12/10.
//

import Foundation
import UIKit
import SafariServices
import ContactsUI


public extension UIView {
    
    var screenShot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        if let image = UIGraphicsGetImageFromCurrentImageContext(), let da = image.jpegData(compressionQuality: 0.5)  {
            UIGraphicsEndImageContext()
            if let img =  UIImage.init(data: da) {
                return img
            }
        }
        UIGraphicsEndImageContext()
        return nil
    }

}

public extension UIViewController {
    
    @MainActor
    func share(content: [Any],activity: [UIActivity]? = nil, completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        let shareVC = UIActivityViewController(activityItems: content, applicationActivities: activity)
        shareVC.completionWithItemsHandler = completion
        DispatchQueue.main.async {
            self.present(shareVC, animated: true, completion: nil)
        }
    }


    func search(content: String) {
        var s = ""
        if UIDevice.current.isCurrentSimpleChina {
            s = "https://www.baidu.com/s?wd=" + content
        } else {
            s = "https://www.google.com/#q=" + content
        }
        
        DispatchQueue.main.async {
            let vc = SFSafariViewController(url: s.url)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func openUrl(content: String) {
        DispatchQueue.main.async {
            let vc = SFSafariViewController(url: content.url)
            self.present(vc, animated: true, completion: nil)
        }
    }
}

public typealias HandlerError = ((Bool) -> Void)

public  extension UIApplication {
    
    @MainActor
    func share(content: [Any],activity: [UIActivity]? = nil, completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        let shareVC = UIActivityViewController(activityItems: content, applicationActivities: activity)
      
        shareVC.isModalInPresentation = true
        DispatchQueue.main.async {
            UIApplication.getTopViewController(base: nil)?.present(shareVC, animated: true, completion: nil)
        }
    }

    func sendEmail(content: String,option: [UIApplication.OpenExternalURLOptionsKey : Any], completionHandler: HandlerError? ) {
        let s: String = "mailto:" + content
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(s.url) {
                UIApplication.shared.open(s.url, options: option, completionHandler: completionHandler)
            }
        }
    }
    
    func call(content: String,option: [UIApplication.OpenExternalURLOptionsKey : Any],completionHandler: HandlerError?) {
        let s = "telprompt://" + content
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(s.url) {
                UIApplication.shared.open(s.url, options: option, completionHandler: completionHandler)
            }
        }
    }
    
    func copy(content: String,completionHandler: HandlerError?) {
        UIPasteboard.general.string = content
        DispatchQueue.main.async {
            if completionHandler != nil {
                completionHandler!(true)
            }
        }
    }
    
    func copyImages(content: [UIImage],completionHandler: HandlerError?) {
        UIPasteboard.general.images = content
        DispatchQueue.main.async {
            if completionHandler != nil {
                completionHandler!(true)
            }
        }
    }
    
    
    func saveImg(img: UIImage, completionHandler: HandlerError?) {
        PDFDocPrivacyTool.fetchPhotoPrivacy { (s) in
            if s == true {
                UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                if completionHandler != nil {
                    completionHandler!(true)
                }
                return
            }
            completionHandler?(false)
        }
    }
    
    @MainActor
    func save(image list: [UIImage], completionHandler: HandlerError?) {
        PDFDocPrivacyTool.fetchPhotoPrivacy { (s) in
            if s == true {
                for img in list {
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                }
                completionHandler?(true)
                return
            }
        }
    }
    
//    func addContct(name: String, phone: String = "", email: String = "",address: String = "", position: String = "", company: String = "",completionHandler: HandlerError?) {
//        TutorPrivacyUtil.fetchContactPrivacy { (s) in
//            guard s == true else {
//                completionHandler?(false)
//                return
//            }
//            
//            let store = CNContactStore()
//            let contactAdd = CNMutableContact()
//
//            contactAdd.nickname = name
//            let mobileNum = CNPhoneNumber(stringValue: phone)
//            let mobileValue = CNLabeledValue(label: CNLabelWork, value: mobileNum)
//            contactAdd.phoneNumbers = [mobileValue]
//            let email = CNLabeledValue(label: CNLabelWork, value:email as NSString)
//            contactAdd.emailAddresses = [email]
//            let addressInfo = CNMutablePostalAddress()
//            addressInfo.street = address
//            let address = CNLabeledValue<CNPostalAddress>(label: CNLabelWork, value: addressInfo)
//            contactAdd.postalAddresses = [address]
//            contactAdd.jobTitle = position
//            contactAdd.organizationName = company
//            let request = CNSaveRequest()
//            request.add(contactAdd, toContainerWithIdentifier: nil)
//            do {
//                try store.execute(request)
//                DispatchQueue.main.async {
//                    completionHandler?(true)
//                }
//            } catch _ as NSError {
//                DispatchQueue.main.async {
//                    completionHandler?(false)
//                }
//            }
//            
//            
//        }
//    }
}

