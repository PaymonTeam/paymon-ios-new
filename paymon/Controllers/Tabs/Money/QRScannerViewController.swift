//
// Created by maks on 16.11.17.
// Copyright (c) 2017 Paymon. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol QRCaptureDelegate: class {
    func qrCaptureDidDetect(object: AVMetadataMachineReadableCodeObject)
}

class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var square: UIImageView!
    var video = AVCaptureVideoPreviewLayer()
    var delegate: QRCaptureDelegate?
    
    var session = AVCaptureSession()
    
    var result = ""
    var resultValid = false
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.delegate = self
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {return}

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            print("ERROR Input")
        }

        let output = AVCaptureMetadataOutput()
        
        if session.canAddOutput(output) {
            session.addOutput(output)
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]

        } else {
            failed()
            return
        }
        
        video = AVCaptureVideoPreviewLayer(session: session)

        video.videoGravity = .resizeAspectFill

        video.frame = view.layer.bounds

        view.layer.addSublayer(video)

        view.bringSubviewToFront(square)

        session.startRunning()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        guard let btcTransferVC = viewController as? BitcoinTransferViewController else {return}
        btcTransferVC.address.text = result
        btcTransferVC.addressIsNotEmpty = resultValid

    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 && !metadataObjects.isEmpty {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == .qr {
                    guard let scan = object.stringValue else {return}
                    
                    session.stopRunning()
                    result = CryptoManager.cutBitcoinWallet(scan: scan)
                    
                        
//                    } else if scan!.starts(with: QRScan.ETHEREUM_WALLET) {
//                        result = String(scan!.dropFirst(9))
//                        delegate?.qrCaptureDidDetect(object: object)
//
//                    } else if scan!.starts(with: QRScan.ETHEREUM_WALLET_2) {
//                        result = String(scan!.dropFirst(1))
//                        delegate?.qrCaptureDidDetect(object: object)
//
//                    } else if scan!.starts(with: QRScan.ETHEREUM_WALLET_3) {
//                        result = scan!
//                        delegate?.qrCaptureDidDetect(object: object)
//
//                    } else if scan!.starts(with: QRScan.WEB_CONTENT) || scan!.starts(with: QRScan.WEB_CONTENT_2){
//                        let alert = UIAlertController(title: "Open in browser?".localized, message: scan!, preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { (action) in
//
//                        }))
//                        alert.addAction(UIAlertAction(title: "Open".localized, style: .default, handler: { (nil) in
//                            UIApplication.shared.open(URL(string: object.stringValue!)! as URL, options: [:], completionHandler: nil)                        }))
//
//                        present(alert, animated: true, completion: nil)
//                    } else {

//                    }
                    
                    if !result.isEmpty {
                        resultValid = true

                        self.navigationController?.popViewController(animated: true)
                    } else {
                        resultValid = false
                        
                        let errorScanAlert = UIAlertController(title: "QR-Code scan".localized, message:
                            "Can't read this QR-code".localized, preferredStyle: .actionSheet)
                        
                        errorScanAlert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                            self.session.startRunning()
                        }))
                        
                        DispatchQueue.main.async {
                            self.present(errorScanAlert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}
