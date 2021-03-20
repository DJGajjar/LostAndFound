//  QRScannerController.swift
//  QRCodeReader
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.

import UIKit
import AVFoundation
class QRScannerController: UIViewController {
    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var topbar: UIView!
    @IBOutlet var btnBack: UIButton!
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]

    var SelfoundItemID = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            print("Failed to get the camera device")
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
        } catch {
            print(error)
            return
        }

        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        captureSession.startRunning()
        view.bringSubviewToFront(messageLabel)
        view.bringSubviewToFront(topbar)

        qrCodeFrameView = UIView()
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func doBack() {
        constants().APPDEL.isCodeScanDone = false
        self.dismiss(animated: true, completion: nil)
    }

    //MARK:- Helper methods
    func launchApp(decodedURL: String) {
        if presentedViewController != nil {
            return
        }
        if decodedURL == self.SelfoundItemID {
            constants().APPDEL.isCodeScanDone = true
        } else {
            constants().APPDEL.ScanError = "Wrong Item Scanned"
            constants().APPDEL.isCodeScanDone = false
        }
        self.dismiss(animated: true, completion: nil)
    }

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        videoPreviewLayer?.frame = self.view.bounds
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let connection =  self.videoPreviewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                    case .portrait:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                    case .landscapeRight:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                    case .landscapeLeft:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                    case .portraitUpsideDown:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                    default:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
    }
}

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }

        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if supportedCodeTypes.contains(metadataObj.type) {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            if metadataObj.stringValue != nil {
                launchApp(decodedURL: metadataObj.stringValue!)
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
}
