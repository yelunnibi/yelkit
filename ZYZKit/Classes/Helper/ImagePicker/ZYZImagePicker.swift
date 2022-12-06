//
//  ZYZImagePicker.swift
//  AFNetworking
//
//  Created by wz on 2022/11/24.
//

import Foundation
import Photos
import TLPhotoPicker
import MBProgressHUD
///
public class ZYZImagePicker: TLPhotosPickerViewControllerDelegate {
    
    public func dismissPhotoPicker(withPHAssets: [PHAsset]) {
//        print("")
//        self.contination?.resume(returning: [])
    }
    
    public func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        print("")
//        self.contination?.resume(returning: [])
    }
    
    @MainActor
    public func shouldDismissPhotoPicker(withTLPHAssets: [TLPHAsset]) -> Bool {
        
        DispatchQueue.main.async {
            MBProgressHUD.showToastMain("loading_str".local)
        }
        
        self.selectedAssets = withTLPHAssets
        var imgs: [UIImage] = []
        
        if withTLPHAssets.count == 0 {
            self.contination?.resume(returning: [])
            return true
        }
        
        for asset in self.selectedAssets {
            if let img = asset.fullResolutionImage, let upimg = img.fixedOrientation() {
                let cropImg = upimg.resizedScreenWidth()
                imgs.append(cropImg)
                if imgs.count == self.selectedAssets.count {
                    MBProgressHUD.hide()
                    self.contination?.resume(returning: imgs)
                }
            } else {
                DispatchQueue.main.async {
                    MBProgressHUD.showToastMain("loading_str".local)
                }
                asset.cloudImageDownload(progressBlock: { (progress) in
                    print("cloud img \(progress)")
                }, completionBlock: {(image) in
                    if let img = image {
                        imgs.append(img)
                    }
                    
                    if imgs.count == self.selectedAssets.count {
                        MBProgressHUD.hide()
                        self.contination?.resume(returning: imgs)
                    }
                })
            }
        }
        return true
    }
    
    public func dismissComplete() {
        
    }
    
    public func photoPickerDidCancel() {
        self.contination?.resume(returning: [])
    }
    
    public func canSelectAsset(phAsset: PHAsset) -> Bool {
        return true
    }
    
    public func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        
    }
    
    public func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        
    }
    
    public func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        
    }
    
    var selectedAssets = [TLPHAsset]()
    var tlvc: TLPhotosPickerViewController!
    
    var contination: CheckedContinuation<[UIImage], Never>?
    
   public init(maxum: Int = 9) {
        tlvc = TLPhotosPickerViewController()
        tlvc.delegate = self
        var configure = TLPhotosPickerConfigure()
        configure.maxSelectedAssets = maxum
        configure.cancelTitle = "ac_cancel_str".local
        configure.doneTitle = "ac_done_str".local
        configure.tapHereToChange = "ac_tap_change_str".local
       configure.emptyMessage = "No albums"
       configure.selectMessage = "Select"
       configure.deselectMessage = "Deselect"
       
       
        configure.usedCameraButton = false
        configure.selectedColor = UIColor(hexString: "#009ed8")
        let opt = PHFetchOptions()
        opt.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        opt.sortDescriptors =  [NSSortDescriptor(key: "creationDate", ascending: false)]
        configure.fetchOption = opt
        tlvc.configure = configure
    }
    
   public func chooseImage(from vc: UIViewController) async -> [UIImage] {
        await self.presentVC(vc: vc)
        
        return await withCheckedContinuation ({ continu in
            self.contination = continu
        })
    }
    
    @MainActor
    func presentVC(vc from: UIViewController) {
        self.tlvc.modalPresentationStyle = .fullScreen
        from.present(self.tlvc, animated: true) {
        }
    }
}
