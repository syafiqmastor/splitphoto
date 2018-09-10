//
//  CameraViewController.swift
//  TestApp
//
//  Created by Syafiq Mastor on 29/01/2018.
//

import UIKit
import AVFoundation


class CameraViewController: UIViewController {
    
    //MARK:- variables
    fileprivate var buttonView: UIView!
    fileprivate var captureButton: UIButton!
    fileprivate var messageLabel: UILabel!
    fileprivate var cancelButton : UIButton!
    fileprivate var imageView : UIImageView!
    fileprivate var watermarkImageView : UIImageView!
    fileprivate var lineGuideImageView : UIImageView!
    
    //MARK:- input
    //input from cordova
    public var invalidation_code  : String = ""
    public var transaction_id  : String = ""
    public var titleText : String = ""
    public var cancelText : String = ""
    
    //MARK:- global
    
    fileprivate var captureSession : AVCaptureSession?
    fileprivate var videoPreviewLayer : AVCaptureVideoPreviewLayer?
    fileprivate var capturePhotoOutput: AVCapturePhotoOutput?
    fileprivate var barCodeFrameView : UIView = UIView()
    fileprivate var numberFrameView : UIView = UIView()
    fileprivate var numberFrame : CGRect = CGRect()
    fileprivate var barCodeFrame : CGRect = CGRect()
    
    fileprivate let startPointX : CGFloat = 40.0
    fileprivate var startPointY : CGFloat = 0.0
    fileprivate var barCodeHeight : CGFloat = 0.0
    fileprivate var numberHeight : CGFloat = 0.0
    fileprivate var barCodeWidth : CGFloat = 0.0
    fileprivate var flashView = UIView()
    
    //MARK:- view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfiguration()
        cameraConfiguration()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // start camera session everytime the page is loaded.
        if let captSession = captureSession {
            captSession.startRunning()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //stop camera session everytime the page is dismissed.
        if let captSession = captureSession {
            captSession.stopRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //layout buttonview
        buttonView.layer.cornerRadius = buttonView.bounds.size.height/2
        buttonView.clipsToBounds = true
    }
    
    //MARK:- view configuration
    private func viewConfiguration() {
        
        //add button view to view
        /// button view is the container for imageView and capture button.
        buttonView = UIView()
        
        buttonView.backgroundColor = UIColor(red: (63/255), green: (113/255), blue: (124/255), alpha: 1.0)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.layer.cornerRadius = buttonView.bounds.size.height/2
        buttonView.clipsToBounds = true
        self.view.addSubview(buttonView)
        
        //add constraint to buttonView
        buttonView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        buttonView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        /// initialize imageView
        imageView = UIImageView()
        
        /// imageView content mode.
        imageView.contentMode = .scaleAspectFit
        
        /// load bundle
        let bundlePath = Bundle.main.path(forResource: "Assets", ofType: "bundle")
        
        /// load camera image from bundle
        let imageName = Bundle(path: bundlePath!)?.path(forResource: "camera", ofType: "png")
        let image = UIImage(contentsOfFile: imageName!)
        
        imageView.image = image
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.addSubview(imageView)
        
        //add constraint to cameraImageView
        imageView.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor).isActive = true
        
        
        //create captureButton
        captureButton = UIButton()
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.setTitle("", for: .normal)
        
        captureButton.layer.cornerRadius = captureButton.frame.size.height/2
        captureButton.clipsToBounds = true
        captureButton.addTarget(self, action: #selector(handleCaptureButton(_:)), for: .touchUpInside)
        buttonView.addSubview(captureButton)
        
        //add constraint to captureButton
        captureButton.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        captureButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        captureButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor).isActive = true
        captureButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor).isActive = true
        
        //create messageLabel
        messageLabel = UILabel()
        messageLabel.textColor = UIColor.white
        messageLabel.text = titleText
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageLabel)
        
        //add constraint to messageLabel
        messageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        //create cancelButton
        cancelButton = UIButton()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle(cancelText, for: .normal)
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        cancelButton.addTarget(self, action: #selector(handleCanceleButton(_:)), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        //add constraint to captureButton
        cancelButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
    }
    //MARK:- camera configuration
    private func cameraConfiguration() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video as the media type parameter.
        
        guard let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else {
            fatalError("No vidoe device found")
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous deivce object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Initialize the captureSession object
            captureSession = AVCaptureSession()
            
            // Set the input devcie on the capture session
            captureSession?.addInput(input)
            
            // set the photo output on the capture session
            capturePhotoOutput = AVCapturePhotoOutput()
            // sete the output to high resolution
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            captureSession?.addOutput(capturePhotoOutput!)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            videoPreviewLayer?.frame = view.layer.bounds
            
            view.layer.addSublayer(videoPreviewLayer!)
            
            // start session
            captureSession?.startRunning()
            
            // Initialize QR Code Frame to highlight the QR code
            barCodeFrameView = UIView()
            numberFrameView = UIView()
            watermarkImageView = UIImageView()
            lineGuideImageView = UIImageView()
            
            /// barcode and number layout sizing.
            let viewSize = view.frame.size
            barCodeHeight = viewSize.height/6
            numberHeight = barCodeHeight/2
            barCodeWidth = viewSize.width - 80
            
            /// creating barcode frame based on the calculation.
            barCodeFrameView.frame = CGRect(x: 0, y: 0, width: barCodeWidth, height: barCodeHeight)
            /// location barcodeframeView to center
            barCodeFrameView.center = view.center
            barCodeFrameView.layer.borderColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.60).cgColor
            barCodeFrameView.layer.borderWidth = 2
            
            // set barCodeFrameView frame to barcodeframe
            barCodeFrame = barCodeFrameView.frame
            
            /// create number frame
            numberFrameView.layer.borderColor = UIColor(red: 1.0, green: 0, blue: 0, alpha: 0.60).cgColor
            
            ///
            numberFrameView.layer.borderWidth = 2
            numberFrameView.frame = CGRect(x: 0, y: 0, width: barCodeWidth, height: numberHeight)
            numberFrameView.center = view.center
            let qrframe = (barCodeFrameView.center.y) + barCodeHeight/2
            numberFrameView.frame.origin.y = qrframe
            numberFrame = numberFrameView.frame
            
            /// create water mark frame
            let watermarkFrame = CGRect(x: barCodeFrame.origin.x,
                                        y: barCodeFrame.origin.y,
                                        width: barCodeFrame.size.width,
                                        height: barCodeFrame.size.height + numberFrame.size.height)
            
            watermarkImageView.frame = watermarkFrame
            watermarkImageView.contentMode = .scaleToFill
            
            /// load bundle
            let bundlePath = Bundle.main.path(forResource: "Assets", ofType: "bundle")
            /// load barcode image from the bundle
            let imageName = Bundle(path: bundlePath!)?.path(forResource: "barcode", ofType: "png")
            /// create image from imageBundle
            let image = UIImage(contentsOfFile: imageName!)
            watermarkImageView.image = image
            watermarkImageView.alpha = 0.5
            watermarkImageView.clipsToBounds = true
            
            view.addSubview(watermarkImageView)
            
            // create line guide frame
            let lineGuideFrame = numberFrameView.frame
            
            lineGuideImageView.frame = lineGuideFrame
            lineGuideImageView.contentMode = .scaleToFill
            
            /// load line guide image from bundle
            let lineGuideImageName = Bundle(path: bundlePath!)?.path(forResource: "lineGuide", ofType: "png")
            let lineGuideImage = UIImage(contentsOfFile: lineGuideImageName!)
            lineGuideImageView.image = lineGuideImage
            lineGuideImageView.alpha = 0.85
            lineGuideImageView.clipsToBounds = true
            
            view.addSubview(lineGuideImageView)
            
            /// create a view to imitate the captured flash when taking photos.
            flashView = UIView(frame: view.frame)
            flashView.alpha = 0
            flashView.backgroundColor = UIColor.black
            view.addSubview(flashView)
            
            // rearrange view layers in the order.
            view.bringSubview(toFront: watermarkImageView)
            view.bringSubview(toFront: barCodeFrameView)
            view.bringSubview(toFront: numberFrameView)
            view.bringSubview(toFront: messageLabel)
            view.bringSubview(toFront: buttonView)
            view.bringSubview(toFront: cancelButton)
            view.bringSubview(toFront: imageView)
            view.bringSubview(toFront: captureButton)
            view.bringSubview(toFront: lineGuideImageView)
            
        } catch {
            print(error)
            return
        }
    }
    
    //MARK:- send image for cropping process.
    fileprivate func cropBarcodeImage(image : UIImage) {
        var frame = barCodeFrame
        frame.size.height = barCodeFrame.size.height + numberFrame.size.height
        
        /// perform cropping for barcode image
        performCrop(frame: frame, image: image) { (barcodeImage) in
            /// save image to device local
            saveImage(image: barcodeImage, Key: "barcode")
            /// perform cropping for number image
            performCrop(frame: numberFrame, image: image, callback: { (numberImage) in
                /// save image to device local
                saveImage(image: numberImage, Key: "textImage")
                /// send image to verify
                self.verify()
            })
        }
    }
    
    //MARK:- perform crop process
    /**
     Crop captured image to an output photo
     
     - returns:
     Callback with cropped image
     
     - parameters:
     - frame: Size of image to crop
     - image: image input to crop.
     */
    private func performCrop(frame  :CGRect, image : UIImage, callback : (_ croppedImage : UIImage) -> ()) {
        // get image to view ratio
        let widthRatio =  image.size.width / view.frame.size.width
        let heightRatio = image.size.height / view.frame.size.height
        
        // reorganised cropped point and size.
        let xpoint = frame.origin.x*widthRatio
        let ypoint = frame.origin.y*heightRatio
        let width = frame.height*heightRatio
        let height = frame.width*widthRatio
        
        //create frame for cropped image
        let rect = CGRect(x: ypoint,
                          y: xpoint,
                          width: width,
                          height: height)
        
        //perform crop process
        if let imageRef = image.cgImage?.cropping(to: rect) {
            let croppedImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: UIImageOrientation.up)
            callback(croppedImage)
        }
    }
    
    //MARK:- Local Storage
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    fileprivate func saveImage(image: UIImage, Key: String) {
        if let data = UIImagePNGRepresentation(image) {
            let filename = getDocumentsDirectory().appendingPathComponent("\(Key).png")
            print(filename)
            try? data.write(to: filename)
        }
    }
    
    fileprivate func getImage(Key: String) -> UIImage?{
        let fileManager = FileManager.default
        let filename = getDocumentsDirectory().appendingPathComponent("\(Key).png")
        if fileManager.fileExists(atPath: filename.path) {
            return UIImage(contentsOfFile: filename.path)
        }
        return nil
    }
    
    //MARK:- Verify
    
    ///send all photos using up orientation
    fileprivate func verify() {
        /// up orientation
        let barcodeImg = UIImage(cgImage: (getImage(Key: "barcode")?.cgImage)!, scale: 1.0, orientation: UIImageOrientation.up)
        let txtImg = UIImage(cgImage: (getImage(Key: "textImage")?.cgImage)!, scale: 1.0, orientation: UIImageOrientation.up)
        
        //TO DO :- Do next process with the image
        
    }
    ///send all photos using right orientation if the first one failed
    fileprivate func retryVerify() {
        guard let barcodeImg = getImage(Key: "barcode")?.cgImage, let numImg = getImage(Key: "textImage")?.cgImage else { return }
        let rotatedBarCode = UIImage(cgImage: barcodeImg, scale: 1.0, orientation: UIImageOrientation.right)
        let rotatedNumber = UIImage(cgImage: numImg, scale: 1.0, orientation: UIImageOrientation.right)
        //TO DO :- Do next process with the image
    }
    
    @objc func handleCaptureButton(_ sender: UIButton) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc func handleCanceleButton(_ sender: UIButton) {
        //TO DO :- handle when user click cancel
    }
}

//MARK:- AVCapturePhotoCaptureDelegate
extension CameraViewController : AVCapturePhotoCaptureDelegate {
    
    func capture(_ output: AVCapturePhotoOutput,
                 didCapturePhotoForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings) {
        //animate flash view to mimic the capture image.
        UIView.animateKeyframes(withDuration: 0.1, delay: 0, options: .autoreverse, animations: {
            self.flashView.alpha = 1
        }, completion: { (complete) in
            self.flashView.alpha = 0
        })
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
                 previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        
        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            cropBarcodeImage(image: image)
        }
    }
}

