//
//  MicroPhoneVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog
import AVKit

class MicroPhoneVC: UIViewController, AVAudioRecorderDelegate, RecorderDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var speechImgView: UIImageView!
    @IBOutlet weak var testImgView: UIImageView!
    
    var isComingFromDiagnosticTestResult = false
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var recording: Recording!
    var recordDuration = 0
    var isBitRate = false
    var runCount = 0
    var gameTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SDKUserDefaults.setValue(false, forKey: SDK_MicrophoneCompleteKey)
        SDKUserDefaults.setValue(getCurrentTime(), forKey: SDK_TestLeftTimeKey)
        
        DispatchQueue.main.async {
            self.setUIElementsProperties()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppOrientationUtility.lockOrientation(.portrait)
        
        self.recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(AVAudioSession.Category.playAndRecord)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        //self.loadRecordingUI()
                        
                        self.startBtn.isHidden = false
                        self.createRecorder()
                        
                    } else {
                        // failed to record!
                        
                        self.showAlert(title: self.getLocalizatioStringValue(key: "Error"), message: self.getLocalizatioStringValue(key: "failed to record!"), alertButtonTitles: [self.getLocalizatioStringValue(key: "OK")], alertButtonStyles: [.default], vc: self) { (index) in
                            
                            SDKResultJSON[SDK_MicrophoneTestKey].int = 0
                            SDKUserDefaults.setValue(false, forKey: SDK_MicrophoneTestKey)
                             
                            if !SDKResultString.contains("CISS08;") {
                                SDKResultString = SDKResultString + "CISS08;"
                            }
                            
                            self.goNext()
                            
                        }
                        
                    }
                }
            }
        } catch {
            // failed to record!
            
            self.showAlert(title: self.getLocalizatioStringValue(key: "Error"), message: self.getLocalizatioStringValue(key: "failed to record!"), alertButtonTitles: [self.getLocalizatioStringValue(key: "OK")], alertButtonStyles: [.default], vc: self) { (index) in
                
                SDKResultJSON[SDK_MicrophoneTestKey].int = 0
                SDKUserDefaults.setValue(false, forKey: SDK_MicrophoneTestKey)
                 
                if !SDKResultString.contains("CISS08;") {
                    SDKResultString = SDKResultString + "CISS08;"
                }
                
                self.goNext()
                
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.setStatusBarColor(themeColor: SDKThemeColor)
        
        self.startBtn.backgroundColor = SDKThemeColor
        self.startBtn.layer.cornerRadius = SDKBtnCornerRadius
        self.startBtn.setTitleColor(SDKBtnTitleColor, for: .normal)
        let fontSize = self.startBtn.titleLabel?.font.pointSize
        self.startBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: fontSize ?? 18.0)
        
        self.countLbl.textColor = SDKThemeColor
        self.countLbl.font = UIFont.init(name: SDKFontRegular, size: self.countLbl.font.pointSize)
        self.diagnoseProgressView.progressTintColor = SDKThemeColor
    
        //self.testImgView.image = self.testImgView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        //self.testImgView.tintColor = SDKThemeColor
        self.testImgView.image = #imageLiteral(resourceName: "mic")
        
        
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Microphone")
        self.titleLbl.font = UIFont.init(name: SDKFontRegular, size: self.titleLbl.font.pointSize)
        self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking Microphone")
        self.headingLbl.font = UIFont.init(name: SDKFontMedium, size: self.headingLbl.font.pointSize)
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "Your microphone will listen your voice for 4 seconds to check your microphone is working or not")
        self.subHeadingLbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeadingLbl.font.pointSize)
        
    }
    
    open func createRecorder() {
        recording = Recording(to: "recording.m4a")
        recording.delegate = self
        
        // Optionally, you can prepare the recording in the background to
        // make it start recording faster when you hit `record()`.
        
        DispatchQueue.global().async {
            // Background thread
            do {
                try self.recording.prepare()
            } catch {
                
            }
        }
    }
    
    open func startRecording(url: URL) {
        recordDuration = 0
        do {
            Timer.scheduledTimer(timeInterval: 5,
                                 target: self,
                                 selector: #selector(self.stopRecording),
                                 userInfo: nil,
                                 repeats: false)
            
            try recording.record()
            //self.playUsingAVAudioPlayer(url: url)
        } catch {
        }
    }
    
    @objc func stopRecording() {
        recordDuration = 0
        recording.stop()
        
        if isBitRate {
            self.finishRecording(success: isBitRate)
        }else {
            self.finishRecording(success: isBitRate)
        }
        
    }
        
    func audioMeterDidUpdate(_ db: Float) {
        self.recording.recorder?.updateMeters()
        let ALPHA = 0.05
        let peakPower = pow(10, (ALPHA * Double((self.recording.recorder?.peakPower(forChannel: 0))!)))
        var rate: Double = 0.0
        if (peakPower <= 0.2) {
            rate = 0.2
        } else if (peakPower > 0.9) {
            rate = 1.0
            self.isBitRate = true
        } else {
            rate = peakPower
        }
        
        print(rate)
        recordDuration += 1
    }
    
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key: "Start").uppercased() {
            //sender.setTitle("SKIP", for: .normal)
            //self.startTest()
            
            sender.isHidden = true
            self.speechImgView.isHidden = false
            
            // Load GIF In Image view
            let jeremyGif = UIImage.gifImageWithName("speech")
            self.speechImgView.image = jeremyGif
            self.speechImgView.stopAnimating()
            self.speechImgView.startAnimating()
            
            
            let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            self.startRecording(url: audioFilename)
            
        }else {
            self.skipTest()
        }
        
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        self.skipTest()
    }
    
    func startTest() {
        
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: false)
        }
        
        
        //Run Timer for 4 Seconds to record the audio
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
     
    }
    
    @objc func runTimedCode() {
        runCount += 1
        
        if runCount > 4 {
            self.finishRecording(success: self.isBitRate)
        }
    }
    
    func finishRecording(success: Bool) {
        //audioRecorder.stop()
        audioRecorder = nil
        
        self.gameTimer?.invalidate()
        recording.recorder?.deleteRecording()

        if success {
            
            SDKResultJSON[SDK_MicrophoneTestKey].int = 1
            SDKUserDefaults.setValue(true, forKey: SDK_MicrophoneTestKey)
            
            if SDKResultString.contains("CISS08;") {
                SDKResultString = SDKResultString.replacingOccurrences(of: "CISS08;", with: "")
            }
                        
            self.goNext()
            
        } else {
            
            SDKResultJSON[SDK_MicrophoneTestKey].int = 0
            SDKUserDefaults.setValue(false, forKey: SDK_MicrophoneTestKey)
             
            if !SDKResultString.contains("CISS08;") {
                SDKResultString = SDKResultString + "CISS08;"
            }
            
            self.goNext()
            
        }
        
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder.delegate = self
            self.audioRecorder.record()

        } catch {
            self.finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func goNext() {
        
        SDKUserDefaults.setValue(true, forKey: SDK_MicrophoneCompleteKey)
        SDKUserDefaults.removeObject(forKey: SDK_TestLeftTimeKey)
        
        if self.isComingFromDiagnosticTestResult {
                        
            guard let didFinishRetryDiagnosis = SDKdidFinishRetryDiagnosis else { return }
            didFinishRetryDiagnosis()
            self.dismiss(animated: false, completion: nil)
        }
        else{
                        
            guard let didFinishTestDiagnosis = SDKdidFinishTestDiagnosis else { return }
            didFinishTestDiagnosis()
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    func skipTest() {
        
        // Prepare the popup assets
        
        let title = self.getLocalizatioStringValue(key: "Microphone Test")
        let message = self.getLocalizatioStringValue(key: "If you skip this test there would be a substantial decline in the price offered.") + " " + self.getLocalizatioStringValue(key: "Do you still want to skip?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key:"Yes")) {

            SDKResultJSON[SDK_MicrophoneTestKey].int = -1
            SDKUserDefaults.setValue(false, forKey: SDK_MicrophoneTestKey)
             
            if !SDKResultString.contains("CISS08;") {
                SDKResultString = SDKResultString + "CISS08;"
            }
                
            self.goNext()
          
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key:"No")) {
            //Do Nothing
            self.startBtn.setTitle(self.getLocalizatioStringValue(key:"Start").uppercased(), for: .normal)
            popup.dismiss(animated: true, completion: nil)
        }
        
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo])
        popup.dismiss(animated: true, completion: nil)
        
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            pv.titleFont    = UIFont(name: SDKFontMedium, size: 26)!
            pv.messageFont  = UIFont(name: SDKFontRegular, size: 22)!
        }else {
            pv.titleFont    = UIFont(name: SDKFontMedium, size: 20)!
            pv.messageFont  = UIFont(name: SDKFontRegular, size: 16)!
        }
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.cornerRadius    = 10
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.opacity         = 0.7
        ov.color           = .black
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            db.titleFont      = UIFont(name: SDKFontMedium, size: 22)!
        }else {
            db.titleFont      = UIFont(name: SDKFontMedium, size: 16)!
        }
                
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            cb.titleFont      = UIFont(name: SDKFontMedium, size: 22)!
        }else {
            cb.titleFont      = UIFont(name: SDKFontMedium, size: 16)!
        }
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key:"Quit Diagnosis")
        let message = self.getLocalizatioStringValue(key:"Are you sure you want to quit?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key:"Yes")) {
            DispatchQueue.main.async() {
                SDKUserDefaults.setValue(getCurrentTime(), forKey: SDK_TestLeftTimeKey)
                self.NavigateToHomePageOfSDK()
            }
        }
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key:"No")) {
            //Do Nothing
            popup.dismiss(animated: true, completion: nil)
        }
        
        // Add buttons to dialog
        // Alternatively, you can use popup.addButton(buttonOne)
        // to add a single button
        popup.addButtons([buttonOne, buttonTwo])
        popup.dismiss(animated: true, completion: nil)
        
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            pv.titleFont    = UIFont(name: SDKFontMedium, size: 26)!
            pv.messageFont  = UIFont(name: SDKFontRegular, size: 22)!
        }else {
            pv.titleFont    = UIFont(name: SDKFontMedium, size: 20)!
            pv.messageFont  = UIFont(name: SDKFontRegular, size: 16)!
        }
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.cornerRadius    = 10
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.opacity         = 0.7
        ov.color           = .black
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            db.titleFont      = UIFont(name: SDKFontMedium, size: 22)!
        }else {
            db.titleFont      = UIFont(name: SDKFontMedium, size: 16)!
        }
                
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        if UIDevice.current.model.hasPrefix("iPad") {
            cb.titleFont      = UIFont(name: SDKFontMedium, size: 22)!
        }else {
            cb.titleFont      = UIFont(name: SDKFontMedium, size: 16)!
        }
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
        
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
