//
//  BiometricVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog
import BiometricAuthentication

class BiometricVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeading1Lbl: UILabel!
    @IBOutlet weak var subHeading2Lbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var testImgView: UIImageView!
    
    var isComingFromDiagnosticTestResult = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SDKUserDefaults.setValue(false, forKey: SDK_BiometricCompleteKey)
        SDKUserDefaults.setValue(getCurrentTime(), forKey: SDK_TestLeftTimeKey)
        
        self.checkDeviceSupportOfBiometric()
        
        DispatchQueue.main.async {
            self.setUIElementsProperties()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppOrientationUtility.lockOrientation(.portrait)
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
    
        //self.testImgView.image = self.testImgView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        //self.testImgView.tintColor = SDKThemeColor
        //self.testImgView.image = #imageLiteral(resourceName: "fingerprint")
        
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Biometric Authentication")
        self.titleLbl.font = UIFont.init(name: SDKFontRegular, size: self.titleLbl.font.pointSize)
        
    }
    
    func checkDeviceSupportOfBiometric() {
        
        DispatchQueue.main.async {
            
            if BioMetricAuthenticator.canAuthenticate() {
                
                if BioMetricAuthenticator.shared.faceIDAvailable() {
                    
                    print("hello faceid available")
                    
                    self.testImgView.image = #imageLiteral(resourceName: "face-id")
                    
                    self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking Face-Id")
                    self.headingLbl.font = UIFont.init(name: SDKFontMedium, size: self.headingLbl.font.pointSize)
                    self.subHeading1Lbl.text = self.getLocalizatioStringValue(key: "First, enable the face-Id function on your phone")
                    self.subHeading1Lbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeading1Lbl.font.pointSize)
                    self.subHeading2Lbl.text = self.getLocalizatioStringValue(key: "During the test place your face on the scanner as you normally would to unlock your phone")
                    self.subHeading2Lbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeading2Lbl.font.pointSize)
                
                }else {
                    
                    self.testImgView.image = #imageLiteral(resourceName: "fingerprint")
                    
                    self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking fingerprint scanner")
                    self.headingLbl.font = UIFont.init(name: SDKFontMedium, size: self.headingLbl.font.pointSize)
                    self.subHeading1Lbl.text = self.getLocalizatioStringValue(key: "First, please enable fingerprint function")
                    self.subHeading1Lbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeading1Lbl.font.pointSize)
                    self.subHeading2Lbl.text = self.getLocalizatioStringValue(key: "Then you will place your finger on the fingerprint scanner like you normally would during unlock")
                    self.subHeading2Lbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeading2Lbl.font.pointSize)
                 
                }
            }else {
                
                DispatchQueue.main.async {
                    
                    let alertController = UIAlertController (title: self.getLocalizatioStringValue(key: "Enable Biometric") , message: self.getLocalizatioStringValue(key: "Go to Settings -> Touch ID & Passcode"), preferredStyle: .alert)
                    
                    let settingsAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Settings"), style: .default) { (_) -> Void in
                        
                        guard let settingsUrl = URL(string: "App-Prefs:root") else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                
                                UIApplication.shared.open(settingsUrl, options: [:]) { (success) in
                                    
                                }
                                
                            } else {
                                // Fallback on earlier versions
                                
                                UIApplication.shared.openURL(settingsUrl)
                            }
                        }
                    }
                    
                    alertController.addAction(settingsAction)
                    
                    let cancelAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Cancel"), style: .default) { (_) -> Void in
                        
                        SDKResultJSON[SDK_BiometricTestKey].int = 0
                        SDKUserDefaults.setValue(false, forKey: SDK_BiometricTestKey)
                         
                        if !SDKResultString.contains("CISS12;") {
                            SDKResultString = SDKResultString + "CISS12;"
                        }
                        
                        SDKUserDefaults.setValue(true, forKey: SDK_BiometricCompleteKey)
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
                    
                    alertController.addAction(cancelAction)
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.bounds
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                
                
                //*
                switch UIDevice.current.currentModelName {
                case "iPhone X","iPhone XR","iPhone XS","iPhone XS Max","iPhone 11","iPhone 11 Pro","iPhone 11 Pro Max","iPhone 12 mini","iPhone 12","iPhone 12 Pro","iPhone 12 Pro Max", "iPhone 13 Mini", "iPhone 13", "iPhone 13 Pro", "iPhone 13 Pro Max", "iPad Pro (11-inch) (1st generation)", "iPad Pro (11-inch) (2nd generation)", "iPad Pro (12.9-inch) (3rd generation)", "iPad Pro (12.9-inch) (4th generation)" :
                    
                    print("hello faceid available")
                    // device supports face id recognition.
                    
                    self.testImgView.image = #imageLiteral(resourceName: "face-id")
                    
                    self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking Face-Id")
                    self.headingLbl.font = UIFont.init(name: SDKFontMedium, size: self.headingLbl.font.pointSize)
                    self.subHeading1Lbl.text = self.getLocalizatioStringValue(key: "First, enable the face-Id function on your phone")
                    self.subHeading1Lbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeading1Lbl.font.pointSize)
                    self.subHeading2Lbl.text = self.getLocalizatioStringValue(key: "During the test place your face on the scanner as you normally would to unlock your phone")
                    self.subHeading2Lbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeading2Lbl.font.pointSize)
                    
                    break
                default:
                    
                    break
                }
                //*/
                
            }
            
        }
        
    }
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key:"Start").uppercased() {
            self.startBtn.setTitle(self.getLocalizatioStringValue(key:"Skip").uppercased(), for: .normal)
            
            self.startTest()
        }else {
            self.skipButtonPressed(sender)
        }
        
    }
    
    func startTest() {
        
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
            
            switch result {
            case .success( _):
                print("Authentication Successful")
                
                SDKResultJSON[SDK_BiometricTestKey].int = 1
                SDKUserDefaults.setValue(true, forKey: SDK_BiometricTestKey)
                
                if SDKResultString.contains("CISS12;") {
                    SDKResultString = SDKResultString.replacingOccurrences(of: "CISS12;", with: "")
                }
                
                SDKUserDefaults.setValue(true, forKey: SDK_BiometricCompleteKey)
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
                
            case .failure(let error):
                print("Authentication Failed")
                
                
                // do nothing on canceled
                if error == .canceledByUser || error == .canceledBySystem {
            
                    return
                }
                
                // device does not support biometric (face id or touch id) authentication
                else if error == .biometryNotAvailable {
                    
                    self.showaAlert(message: error.message())
                }
                
                // show alternatives on fallback button clicked
                else if error == .fallback {
                    
                    // here we're entering username and password
                    self.showaAlert(message: error.message())
                    
                }
                
                // No biometry enrolled in this device, ask user to register fingerprint or face
                else if error == .biometryNotEnrolled {
                    
                    //self!.btnScanFingerPrint.isHidden = false
                    
                    let alertController = UIAlertController (title: self.getLocalizatioStringValue(key: "Enable Biometric") , message: self.getLocalizatioStringValue(key: "Go to Settings -> Touch ID & Passcode"), preferredStyle: .alert)
                    
                    let settingsAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Settings"), style: .default) { (_) -> Void in
                        
                        guard let settingsUrl = URL(string: "App-Prefs:root") else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    
                                })
                            } else {
                                // Fallback on earlier versions
                                UIApplication.shared.openURL(settingsUrl)
                            }
                        }
                    }
                    
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: self.getLocalizatioStringValue(key: "Cancel"), style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.bounds
                    
                    self.present(alertController, animated: true, completion: nil)
                   
                }
                
                // Biometry is locked out now, because there were too many failed attempts.
                // Need to enter device passcode to unlock.
                else if error == .biometryLockedout {
                    // show passcode authentication
                    
                    self.showaAlert(message: error.message())
                }
                
                // show error on authentication failed
                else {
                    
                    // Alert.showAlert(strMessage: error.message() as NSString, Onview: self!)
                    SDKResultJSON[SDK_BiometricTestKey].int = 0
                    SDKUserDefaults.setValue(false, forKey: SDK_BiometricTestKey)
                     
                    if !SDKResultString.contains("CISS12;") {
                        SDKResultString = SDKResultString + "CISS12;"
                    }
                    
                    SDKUserDefaults.setValue(true, forKey: SDK_BiometricCompleteKey)
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
            
        }
                      
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        
        // Prepare the popup assets
        let title = self.getLocalizatioStringValue(key: "Biometric Authentication Test")
        let message = self.getLocalizatioStringValue(key: "If you skip this test there would be a substantial decline in the price offered.") + " " + self.getLocalizatioStringValue(key: "Do you still want to skip?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
            
            SDKResultJSON[SDK_BiometricTestKey].int = -1
            SDKUserDefaults.setValue(false, forKey: SDK_BiometricTestKey)
             
            if !SDKResultString.contains("CISS12;") {
                SDKResultString = SDKResultString + "CISS12;"
            }
            
            SDKUserDefaults.setValue(true, forKey: SDK_BiometricCompleteKey)
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
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key: "No")) {
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
