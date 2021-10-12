//
//  SpeakerVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import PopupDialog
import AVKit

class SpeakerVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var numberTxtField: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var testImgView: UIImageView!
    
    var isComingFromDiagnosticTestResult = false
    var num1 = 0
    var num2 = 0
    
    var soundFiles = ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
    var audioPlayer: AVAudioPlayer!
    
    let audioSession = AVAudioSession.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SDKUserDefaults.setValue(false, forKey: SDK_SpeakerCompleteKey)
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
        
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.hideKeyboardWhenTappedAroundView()
        self.setStatusBarColor(themeColor: SDKThemeColor)
        
        self.startBtn.backgroundColor = SDKThemeColor
        self.startBtn.layer.cornerRadius = SDKBtnCornerRadius
        self.startBtn.setTitleColor(SDKBtnTitleColor, for: .normal)
        let fontSize = self.startBtn.titleLabel?.font.pointSize
        self.startBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: fontSize ?? 18.0)
        
        self.skipBtn.backgroundColor = SDKThemeColor
        self.skipBtn.layer.cornerRadius = SDKBtnCornerRadius
        self.skipBtn.setTitleColor(SDKBtnTitleColor, for: .normal)
        let skipFontSize = self.skipBtn.titleLabel?.font.pointSize
        self.skipBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: skipFontSize ?? 18.0)
        
        self.countLbl.textColor = SDKThemeColor
        self.countLbl.font = UIFont.init(name: SDKFontRegular, size: self.countLbl.font.pointSize)
        self.diagnoseProgressView.progressTintColor = SDKThemeColor
    
        //self.testImgView.image = self.testImgView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        //self.testImgView.tintColor = SDKThemeColor
        self.testImgView.image = #imageLiteral(resourceName: "speaker")
        
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        self.titleLbl.text = self.getLocalizatioStringValue(key: "Speaker")
        self.titleLbl.font = UIFont.init(name: SDKFontRegular, size: self.titleLbl.font.pointSize)
        self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking Speaker")
        self.headingLbl.font = UIFont.init(name: SDKFontMedium, size: self.headingLbl.font.pointSize)
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "Your phone will play some numbers loud, and then type it in the text box provided")
        self.subHeadingLbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeadingLbl.font.pointSize)
        self.numberTxtField.placeholder = self.getLocalizatioStringValue(key: "Type Number")
        self.numberTxtField.font = UIFont.init(name: SDKFontRegular, size: self.numberTxtField.font?.pointSize ?? 16.0)
        
    }
    
    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if sender.titleLabel?.text == self.getLocalizatioStringValue(key: "Start").uppercased() {
            sender.setTitle(self.getLocalizatioStringValue(key: "Submit").uppercased(), for: .normal)
            
            self.configureAudioSessionCategory()
            self.startTest()
          
        }else {
            
            guard !(self.numberTxtField.text?.isEmpty ?? false) else {
                self.showaAlert(message: self.getLocalizatioStringValue(key: "Enter Number"))
                return
            }
            
            if self.numberTxtField.text == String(num1) + String(num2) {
                
                SDKResultJSON[SDK_SpeakerTestKey].int = 1
                SDKUserDefaults.setValue(true, forKey: SDK_SpeakerTestKey)
                
                if SDKResultString.contains("CISS07;") {
                    SDKResultString = SDKResultString.replacingOccurrences(of: "CISS07;", with: "")
                }
                                
                self.goNext()
            }else {
                
                SDKResultJSON[SDK_SpeakerTestKey].int = 0
                SDKUserDefaults.setValue(false, forKey: SDK_SpeakerTestKey)
                
                if !SDKResultString.contains("CISS07;") {
                    SDKResultString = SDKResultString + "CISS07;"
                }
                
                self.goNext()
            }
            
            
        }
    }
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
        self.skipTest()
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
    
    //MARK:- Custom Methods
    func configureAudioSessionCategory() {
        print("Configuring audio session")
        do {
            //try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            print("AVAudio Session out options: ", audioSession.currentRoute)
            print("Successfully configured audio session.")
        } catch (let error) {
            print("Error while configuring audio session: \(error)")
        }
    }
    
    func startTest() {
        
        let randomSoundFile = Int(arc4random_uniform(UInt32(soundFiles.count)))
        print(randomSoundFile)
        self.num1 = randomSoundFile
        
        guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
            return
        }
        
        
        // This is to audio output from bottom (main) speaker
        do {
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try audioSession.setActive(true)
            print("Successfully configured audio session (SPEAKER-Bottom).", "\nCurrent audio route: ",audioSession.currentRoute.outputs)
        } catch let error as NSError {
            print("#configureAudioSessionToSpeaker Error \(error.localizedDescription)")
        }
        
        
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
            self.audioPlayer.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            let randomSoundFile = Int(arc4random_uniform(UInt32(self.soundFiles.count)))
            print(randomSoundFile)
            self.num2 = randomSoundFile
            
            guard let filePath = Bundle.main.path(forResource: self.soundFiles[randomSoundFile], ofType: "wav") else {
                return
            }
            
            do {
                self.audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                self.audioPlayer.play()
                
                self.numberTxtField.isHidden = false
                //self.txtFieldNum.delegate = self
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        
    }
    
    func goNext() {
        
        SDKUserDefaults.setValue(true, forKey: SDK_SpeakerCompleteKey)
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
        
        let title = self.getLocalizatioStringValue(key: "Speaker Test")
        let message = self.getLocalizatioStringValue(key: "If you skip this test there would be a substantial decline in the price offered.") + " " + self.getLocalizatioStringValue(key: "Do you still want to skip?")
        
        // Create the dialog
        let popup = PopupDialog(title: title, message: message,buttonAlignment: .horizontal, transitionStyle: .bounceDown, tapGestureDismissal: false, panGestureDismissal :false)
        
        // Create buttons
        let buttonOne = CancelButton(title: self.getLocalizatioStringValue(key: "Yes")) {
            
            SDKResultJSON[SDK_SpeakerTestKey].int = -1
            SDKUserDefaults.setValue(false, forKey: SDK_SpeakerTestKey)

            if !SDKResultString.contains("CISS07;") {
                SDKResultString = SDKResultString + "CISS07;"
            }
                
            self.goNext()
          
        }
        
        
        let buttonTwo = DefaultButton(title: self.getLocalizatioStringValue(key: "No")) {
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
