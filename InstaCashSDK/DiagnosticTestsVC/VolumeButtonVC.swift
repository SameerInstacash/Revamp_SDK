//
//  VolumeButtonVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog
import AVKit

class VolumeButtonVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var volUpLbl: UILabel!
    @IBOutlet weak var volUpImgView: UIImageView!
    @IBOutlet weak var volDownLbl: UILabel!
    @IBOutlet weak var volDownImgView: UIImageView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!

    var isComingFromDiagnosticTestResult = false
    var volumeUp = false
    var volumeDown = false
    
    private var audioLevel : Float = 0.0
    var audioSession = AVAudioSession.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SDKUserDefaults.setValue(false, forKey: SDK_VolumeCompleteKey)
        SDKUserDefaults.setValue(getCurrentTime(), forKey: SDK_TestLeftTimeKey)
        
        DispatchQueue.main.async {
            self.setUIElementsProperties()
            self.listenVolumeButton()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppOrientationUtility.lockOrientation(.portrait)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.audioSession.removeObserver(self, forKeyPath: "outputVolume", context: nil)
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.setStatusBarColor(themeColor: SDKThemeColor)
        
        self.startBtn.backgroundColor = SDKThemeColor
        self.startBtn.layer.cornerRadius = SDKBtnCornerRadius
        self.startBtn.setTitleColor(SDKBtnTitleColor, for: .normal)
        let fontSizeStart = self.startBtn.titleLabel?.font.pointSize
        self.startBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: fontSizeStart ?? 18.0)
        
        self.skipBtn.backgroundColor = SDKThemeColor
        self.skipBtn.layer.cornerRadius = SDKBtnCornerRadius
        self.skipBtn.setTitleColor(SDKBtnTitleColor, for: .normal)
        let fontSizeSkip = self.skipBtn.titleLabel?.font.pointSize
        self.skipBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: fontSizeSkip ?? 18.0)
        
        self.countLbl.textColor = SDKThemeColor
        self.countLbl.font = UIFont.init(name: SDKFontRegular, size: self.countLbl.font.pointSize)
        self.diagnoseProgressView.progressTintColor = SDKThemeColor
    
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Volume Button")
        self.titleLbl.font = UIFont.init(name: SDKFontRegular, size: self.titleLbl.font.pointSize)
        self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking Volume Buttons")
        self.headingLbl.font = UIFont.init(name: SDKFontMedium, size: self.headingLbl.font.pointSize)
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "Follow the instructions below to complete check")
        self.subHeadingLbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeadingLbl.font.pointSize)
        
        self.volUpLbl.text = self.getLocalizatioStringValue(key: "Press volume up button")
        self.volUpLbl.font = UIFont.init(name: SDKFontRegular, size: self.volUpLbl.font.pointSize)
        self.volDownLbl.text = self.getLocalizatioStringValue(key: "Press volume down button")
        self.volDownLbl.font = UIFont.init(name: SDKFontRegular, size: self.volDownLbl.font.pointSize)
                
    }
    
    func listenVolumeButton() {
        
        //let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try self.audioSession.setActive(true, options: [])
            self.audioSession.addObserver(self, forKeyPath: "outputVolume",
                                     options: NSKeyValueObservingOptions.new, context: nil)
            
            self.audioLevel = self.audioSession.outputVolume
        } catch {
            print("Error")
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        DispatchQueue.main.async {
            
            if keyPath == "outputVolume" {
                
                //self.audioSession = AVAudioSession.sharedInstance()
                
                if self.audioSession.outputVolume > self.audioLevel {
                    
                    print("Volume up pressed")
                    self.volUpImgView.image = UIImage(named: "volume_up_green")
                    self.volumeUp = true
                    
                    if (self.volumeDown == true) {
                                                
                        SDKUserDefaults.setValue(true, forKey: SDK_VolumeTestKey)
                        SDKResultJSON[SDK_VolumeTestKey].int = 1
                        
                        if SDKResultString.contains("CISS02;") {
                            SDKResultString = SDKResultString.replacingOccurrences(of: "CISS02;", with: "")
                        }
                      
                        SDKUserDefaults.setValue(true, forKey: SDK_VolumeCompleteKey)
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
                    
                }
                
                if self.audioSession.outputVolume < self.audioLevel {
                    
                    print("Volume down pressed")
                    self.volDownImgView.image = UIImage(named: "volume_down_green")
                    self.volumeDown = true
                    
                    if (self.volumeUp == true) {
                                                
                        SDKUserDefaults.setValue(true, forKey: SDK_VolumeTestKey)
                        SDKResultJSON[SDK_VolumeTestKey].int = 1
                        
                        if SDKResultString.contains("CISS02;") {
                            SDKResultString = SDKResultString.replacingOccurrences(of: "CISS02;", with: "")
                        }
                        
                        SDKUserDefaults.setValue(true, forKey: SDK_VolumeCompleteKey)
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
                    
                }
                
                self.audioLevel = self.audioSession.outputVolume
                print(self.audioSession.outputVolume)
                
            }
            
        }
    }
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Hardware Button Test")
        let message = self.getLocalizatioStringValue(key: "If you skip this test there would be a substantial decline in the price offered.") + " " + self.getLocalizatioStringValue(key: "Do you still want to skip?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key:"Yes")) {
            
            SDKUserDefaults.setValue(false, forKey: SDK_VolumeTestKey)
            SDKResultJSON[SDK_VolumeTestKey].int = -1
             
            if !SDKResultString.contains("CISS02;") {
                SDKResultString = SDKResultString + "CISS02;"
            }
            
            SDKUserDefaults.setValue(true, forKey: SDK_VolumeCompleteKey)
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
