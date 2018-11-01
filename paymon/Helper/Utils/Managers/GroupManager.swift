//
//  GroupManager.swift
//  paymon
//
//  Created by Maxim Skorynin on 04/10/2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import MBProgressHUD

public class GroupManager {
    
    static let shared = GroupManager()
    
    func updateAvatar(groupId : Int32, info: [UIImagePickerController.InfoKey : Any], avatarView : CircularImageView, vc : UIViewController){
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            var resizeImage = UIImage()
            
            let widthPixel = image.size.width * image.scale
//            let heigthPixel = image.size.height * image.scale
            
//            print("Image: width \(widthPixel) height: \(heigthPixel)")
            if widthPixel < 256 {
                _ = SimpleOkAlertController.init(title: "Upload photo failed".localized, message: "The minimum width of the photo can be 256 points".localized, vc: vc)
                return
            }
            if widthPixel > 512 {
                resizeImage = image.resizeWithWidth(width: 512)!
            } else {
                resizeImage = image
            }
//            print("Resize Image: width \(resizeImage.size.width * resizeImage.scale) height: \(resizeImage.size.height * resizeImage.scale)")
            
            let packet = RPC.PM_group_setPhoto()
            packet.id = groupId
            
            let _ = MBProgressHUD.showAdded(to: vc.view, animated: true)
            
            NetworkManager.shared.sendPacket(packet) { packet, error in
                
                if (packet is RPC.PM_boolTrue) {
                    Utils.stageQueue.run {
                        PMFileManager.shared.startUploading(jpegData: resizeImage.jpegData(compressionQuality: 0.85)!, onFinished: {
                            
                            DispatchQueue.main.async {
                                MBProgressHUD.hide(for: vc.view, animated: true)
                                Utils.showSuccesHud(vc: vc)
                                
                                avatarView.image = resizeImage
                                
                            }
                            
                        }, onError: { code in
                            print("file upload failed \(code)")
                            
                            DispatchQueue.main.async {
                                _ = SimpleOkAlertController.init(title: "Update failed".localized, message: "An error occurred during the update".localized, vc: vc)
                            }
                            
                        }, onProgress: { p in
                            
                        })
                    }
                } else {
                    
                    _ = SimpleOkAlertController.init(title: "Update failed".localized, message: "An error occurred during the update".localized, vc: vc)
                    
                    //TODO переписать в Кастомный алерт
                    PMFileManager.shared.cancelFileUpload(fileID: Int64(User.currentUser.id));
                }
            }
        }
    }
}
