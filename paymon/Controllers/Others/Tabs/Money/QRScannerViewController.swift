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
    var currency = ""
    
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
        if currency == Money.eth {
            guard let ethTransferVC = viewController as? EthereumTransferViewController else {return}
            ethTransferVC.address.text = result
            ethTransferVC.toAddress = result
            ethTransferVC.addressIsNotEmpty = resultValid
            ethTransferVC.showSendButton()
        } else if currency == Money.btc {
            guard let btcTransferVC = viewController as? BitcoinTransferViewController else {return}
            btcTransferVC.address.text = result
            btcTransferVC.toAddress = result
            btcTransferVC.showSendButton()
            btcTransferVC.addressIsNotEmpty = resultValid
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count != 0 && !metadataObjects.isEmpty {
            if let object = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if object.type == .qr {
                    guard let scan = object.stringValue else {return}
                    
                    session.stopRunning()
                    result = CryptoManager.shared.cutWallet(scan: scan, currency: currency)
                    
                    if !result.isEmpty {
                        resultValid = true
                        print("Result valid \(result)")
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
