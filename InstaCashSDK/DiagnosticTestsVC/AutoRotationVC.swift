//
//  AutoRotationVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog

class AutoRotationVC: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var testImgView: UIImageView!
    
    @IBOutlet weak var viewGuide: UIView!
    @IBOutlet weak var rotateImageView: UIImageView!
    @IBOutlet weak var guideBtn: UIButton!
    @IBOutlet weak var startGuideBtn: UIButton!
    
    var isComingFromDiagnosticTestResult = false
    var hasStarted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SDKUserDefaults.setValue(false, forKey: SDK_AutorotationCompleteKey)
        SDKUserDefaults.setValue(getCurrentTime(), forKey: SDK_TestLeftTimeKey)
        
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
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
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
        self.testImgView.image = #imageLiteral(resourceName: "rotation")
        
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Auto Rotation")
        self.titleLbl.font = UIFont.init(name: SDKFontRegular, size: self.titleLbl.font.pointSize)
        self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking Device Rotation")
        self.headingLbl.font = UIFont.init(name: SDKFontMedium, size: self.headingLbl.font.pointSize)
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "Please ensure device rotation option is enabled. Press “START“ and rotate your device as seen below")
        self.subHeadingLbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeadingLbl.font.pointSize)
        
        
        self.rotateImageView.loadGif(name: "rotation")
        
        self.guideBtn.setTitle(self.getLocalizatioStringValue(key: "Guide me").uppercased(), for: .normal)
        self.guideBtn.setTitleColor(SDKThemeColor, for: .normal)
        let guideBtnFontSize = self.guideBtn.titleLabel?.font.pointSize
        self.guideBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: guideBtnFontSize ?? 18.0)
        
        self.startGuideBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.startGuideBtn.backgroundColor = SDKThemeColor
        self.startGuideBtn.layer.cornerRadius = SDKBtnCornerRadius
        self.startGuideBtn.setTitleColor(SDKBtnTitleColor, for: .normal)
        let startGuideBtnFontSize = self.startGuideBtn.titleLabel?.font.pointSize
        self.startGuideBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: startGuideBtnFontSize ?? 18.0)
        
    }
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if hasStarted {
            
            // Prepare the popup assets
            let title = self.getLocalizatioStringValue(key: "Auto Rotation Diagnosis")
            let message = self.getLocalizatioStringValue(key: "If you skip this test there would be a substantial decline in the price offered.") + " " + self.getLocalizatioStringValue(key: "Do you still want to skip?")
            
            // Create the dialog
            let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
            
            // Create buttons
            let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
                
                SDKUserDefaults.setValue(false, forKey: SDK_AutorotationTestKey)
                SDKResultJSON[SDK_AutorotationTestKey].int = -1
                 
                if !SDKResultString.contains("CISS14;") {
                    SDKResultString = SDKResultString + "CISS14;"
                }

                SDKUserDefaults.setValue(true, forKey: SDK_AutorotationCompleteKey)
                SDKUserDefaults.removeObject(forKey: SDK_TestLeftTimeKey)

                if self.isComingFromDiagnosticTestResult {
                    
                    self.hasStarted = false
                    
                    guard let didFinishRetryDiagnosis = SDKdidFinishRetryDiagnosis else { return }
                    didFinishRetryDiagnosis()
                    self.dismiss(animated: false, completion: nil)
                    
                }
                else{
                    
                    self.hasStarted = false
                    
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
            
        }else{
            
            hasStarted = true
            AppOrientationUtility.lockOrientation(.all)

            //AutoRotationText.text = "Please Tilt your Phone to Landscape mode."
            self.startBtn.setTitle(self.getLocalizatioStringValue(key:"Skip").uppercased(),for: .normal)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
            
            
        }
    }
    
    @objc func rotated()
    {
        if (UIDevice.current.orientation.isLandscape)
        {
            //AutoRotationText.text = "Please Tilt your Phone back to Portrait mode."
            //AutoRotationImageView.image = UIImage(named: "portrait_image")!
        }
        
        if hasStarted == true {
            
            if(UIDevice.current.orientation.isPortrait)
            {
                hasStarted = false
                
                SDKUserDefaults.setValue(true, forKey: SDK_AutorotationTestKey)
                SDKResultJSON[SDK_AutorotationTestKey].int = 1
                
                if SDKResultString.contains("CISS14;") {
                    SDKResultString = SDKResultString.replacingOccurrences(of: "CISS14;", with: "")
                }
                
                SDKUserDefaults.setValue(true, forKey: SDK_AutorotationCompleteKey)
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
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
    
    }
        
    @IBAction func onClickGuide(_ sender: UIButton) {
        self.viewGuide.isHidden = false
    }
    
    @IBAction func onClickStart(_ sender: UIButton) {
        self.viewGuide.isHidden = true
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
