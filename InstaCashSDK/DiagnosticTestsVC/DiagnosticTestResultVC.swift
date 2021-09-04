//
//  DiagnosticTestResultVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import FirebaseDatabase
import PopupDialog
import BiometricAuthentication
import LocalAuthentication
import JGProgressHUD
import SwiftyJSON

class ModelCompleteDiagnosticFlow: NSObject {
    var priority = 0
    var strTestType = ""
    var strSuccess = ""
}

class DiagnosticTestResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var testResultTestDiagnosis: (() -> Void)?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableViewTests: UITableView!
    @IBOutlet weak var btnContinue: UIButton!
    
    var arrFailedAndSkipedTest = [ModelCompleteDiagnosticFlow]()
    var arrFunctionalTest = [ModelCompleteDiagnosticFlow]()
    var section = [""]
    let hud = JGProgressHUD()
    let reachability: Reachability? = Reachability()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print(SDKResultJSON)
        print(SDKResultString)
     
        SDKUserDefaults.setValue(getCurrentTime(), forKey: SDK_ResultDataLeftTimeKey)
        SDKUserDefaults.setValue(SDKResultJSON.rawValue, forKey: SDK_DiagnosisDataJSONKey)
        SDKUserDefaults.setValue(SDKResultString, forKey: SDK_DiagnosisAppCodeKey)
        
        self.updateDataIntoFirebaseDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setUIElementsProperties()
        }
        
        
        self.tableViewTests.register(UINib(nibName: "TestResultCell", bundle: nil), forCellReuseIdentifier: "testResultCell")
        self.tableViewTests.register(UINib(nibName: "TestResultTitleCell", bundle: nil), forCellReuseIdentifier: "TestResultTitleCell")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.createTableFromPassFailedTests()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    //MARK: - Firebase Update Methods
    func updateDataIntoFirebaseDatabase() {
        
        // To update the value of License Left in Firebase Database
        let ref1 = Database.database().reference(withPath: "Organisation").child("0").child("licenseLeft")
        ref1.observeSingleEvent(of: .value) { (snapshot) in
            
            if let value = snapshot.value as? Int {
                print(value)
                
                let updateValue = value - 1
                Database.database().reference().root.child("Organisation").child("0").updateChildValues(["licenseLeft" : updateValue])
            }
        }
        
        // To update the value of License Consumed in Firebase Database
        let ref2 = Database.database().reference(withPath: "Organisation").child("0").child("licenseConsumed")
        ref2.observeSingleEvent(of: .value) { (snapshot) in
            
            if let value = snapshot.value as? Int {
                print(value)
                
                let updateValue = value + 1
                Database.database().reference().root.child("Organisation").child("0").updateChildValues(["licenseConsumed" : updateValue])
            }
        }
        
    }
    
    // MARK: Custom Methods
    func setUIElementsProperties() {
        
        self.setStatusBarColor(themeColor: SDKThemeColor)
        
        self.tableViewTests.layer.cornerRadius = SDKBtnCornerRadius
        
        self.btnContinue.backgroundColor = SDKThemeColor
        self.btnContinue.layer.cornerRadius = SDKBtnCornerRadius
        self.btnContinue.setTitleColor(SDKBtnTitleColor, for: .normal)
        let fontSizeStart = self.btnContinue.titleLabel?.font.pointSize
        self.btnContinue.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: fontSizeStart ?? 18.0)
        
        // MultiLingual
        self.titleLbl.text = self.getLocalizatioStringValue(key: "DIAGNOSTICS TEST RESULT")
        self.btnContinue.setTitle(self.getLocalizatioStringValue(key: "Continue").uppercased(), for: .normal)
    }
    
    // MARK: IBActions
    
    @IBAction func continueButtonPressed(_ sender: UIButton) {
                
        if reachability?.connection.description != "No Connection" {
                        
        }else {
            self.showaAlert(message: self.getLocalizatioStringValue(key: "Please Check Internet connection."))
        }
                
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
                //self.dismiss(animated: true) {
                    self.NavigateToHomePageOfSDK()
                //}
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
    
    //MARK:- Tableview Delegates Methods
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if arrFailedAndSkipedTest.count > 0 {
                return  arrFailedAndSkipedTest.count + 1
            }
            else {
                return arrFunctionalTest.count + 1
            }
        }
        else {
           return arrFunctionalTest.count + 1
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if arrFailedAndSkipedTest.count > 0 {
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    let cellfailed = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                    cellfailed.lblTitle.text = self.getLocalizatioStringValue(key: "Failed and Skipped Tests")
                    cellfailed.lblSeperator.isHidden = true
                    
                    return cellfailed
                }else {
                    
                    let cellfailed = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                    //cellfailed.imgReTry.image = UIImage(named: "unverified")
                    cellfailed.lblName.text = arrFailedAndSkipedTest[indexPath.row - 1].strTestType
                    cellfailed.imgReTry.isHidden = true
                    cellfailed.lblReTry.isHidden = false
                    cellfailed.lblReTry.text = self.getLocalizatioStringValue(key: "ReTry")
                    cellfailed.lblSeperator.isHidden = false
                    
                    DispatchQueue.main.async {
                        
                        cellfailed.roundCorners(corners: [.topLeft,.topRight], radius: 0.0)
                        cellfailed.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 0.0)
                        
                        if indexPath.row == 1 {
                            cellfailed.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
                        }
                        
                        if indexPath.row == self.arrFailedAndSkipedTest.count {
                            cellfailed.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
                    
                            cellfailed.lblSeperator.isHidden = true
                        }
                    }
                                
                    return cellfailed
                }
                
            }
            else{
                
                if indexPath.row == 0 {
                    
                    let cellFunction = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                    cellFunction.lblTitle.text = self.getLocalizatioStringValue(key: "Functional Checks")
                    cellFunction.lblSeperator.isHidden = true
                    
                    return cellFunction
                }else {
                    
                    let cellFunction = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                    cellFunction.imgReTry.image = UIImage(named: "rightGreen")
                    cellFunction.lblName.text = self.getLocalizatioStringValue(key: self.arrFunctionalTest[indexPath.row - 1].strTestType)
                    cellFunction.imgReTry.isHidden = false
                    cellFunction.lblReTry.isHidden = true
                    cellFunction.lblSeperator.isHidden = false
                    
                    DispatchQueue.main.async {
                        cellFunction.roundCorners(corners: [.topLeft,.topRight], radius: 0.0)
                        cellFunction.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 0.0)
                        
                        if indexPath.row == 1 {
                            cellFunction.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
                        }
                        
                        if indexPath.row == self.arrFunctionalTest.count {
                            cellFunction.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
                            
                            cellFunction.lblSeperator.isHidden = true
                        }
                    }
               
                    return cellFunction
                }
                
            }
        }
        else{
            
            if indexPath.row == 0 {
                
                let cellfailed = tableView.dequeueReusableCell(withIdentifier: "TestResultTitleCell", for: indexPath) as! TestResultTitleCell
                cellfailed.lblTitle.text = self.getLocalizatioStringValue(key: "Functional Checks")
                cellfailed.lblSeperator.isHidden = true
                
                return cellfailed
            }else {
                
                let cellFunction = tableView.dequeueReusableCell(withIdentifier: "testResultCell", for: indexPath) as! TestResultCell
                cellFunction.imgReTry.image = UIImage(named: "rightGreen")
                cellFunction.lblName.text = self.getLocalizatioStringValue(key: self.arrFunctionalTest[indexPath.row - 1].strTestType)
                cellFunction.imgReTry.isHidden = false
                cellFunction.lblReTry.isHidden = true
                cellFunction.lblSeperator.isHidden = false
                
                    
                DispatchQueue.main.async {
                    cellFunction.roundCorners(corners: [.topLeft,.topRight], radius: 0.0)
                    cellFunction.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 0.0)
                    
                    if indexPath.row == 1 {
                        cellFunction.roundCorners(corners: [.topLeft,.topRight], radius: 10.0)
                    }
                    
                    if indexPath.row == self.arrFunctionalTest.count {
                        cellFunction.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 10.0)
                
                        cellFunction.lblSeperator.isHidden = true
                    }
                }
                                
                return cellFunction
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if arrFailedAndSkipedTest.count > 0 {
            if indexPath.section == 0 {
                if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_ScreenTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "ScreenCalibrationVC") as! ScreenCalibrationVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_DeadPixelTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "DeadPixelsVC") as! DeadPixelsVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_AutorotationTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "AutoRotationVC") as! AutoRotationVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_ProximityTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "ProximityVC") as! ProximityVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_VolumeTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "VolumeButtonVC") as! VolumeButtonVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_EarphoneTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "EarphoneVC") as! EarphoneVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Charger" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "ChargerVC") as! ChargerVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_CameraTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                   
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Face-Id Scanner" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_BiometricTestKey || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Biometric Authentication" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "BiometricVC") as! BiometricVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }
                else if  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Bluetooth" ||  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "GPS" ||  arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "GSM" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "SMS Verification" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "NFC" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Battery" || arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Storage" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "BackgroundTestsVC") as! BackgroundTestsVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_WifiTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "WiFiVC") as! WiFiVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                   
                }
                else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_MicrophoneTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "MicroPhoneVC") as! MicroPhoneVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                   
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_SpeakerTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "SpeakerVC") as! SpeakerVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == SDK_VibratorTestKey {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "VibratorVC") as! VibratorVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                    
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "FlashLight" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "FlashLightVC") as! FlashLightVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                  
                }else if arrFailedAndSkipedTest[indexPath.row - 1].strTestType == "Autofocus" {
                    
                    let vc = UIStoryboard(name: "InstaCash", bundle: nil).instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
                    vc.modalPresentationStyle = .overFullScreen
                    vc.isComingFromDiagnosticTestResult = true
                    
                    SDKdidFinishRetryDiagnosis = {
                        self.createTableFromPassFailedTests()
                    }
                    self.present(vc, animated: true, completion: nil)
                   
                }
                
                
            }
        }
        
    }
    
    func createTableFromPassFailedTests() {
        
        self.arrFailedAndSkipedTest.removeAll()
        self.arrFunctionalTest.removeAll()
        
        if let val = SDKUserDefaults.value(forKey: SDK_DeadPixelTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_DeadPixelTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_ScreenTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_ScreenTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
       
        if let val = SDKUserDefaults.value(forKey: SDK_AutorotationTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_AutorotationTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_ProximityTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_ProximityTestKey
            
            if val {
                
                if SDKResultJSON[SDK_ProximityTestKey] == -2 {
                    
                }else {
                    self.arrFunctionalTest.append(model)
                }
                
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_VolumeTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_VolumeTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_EarphoneTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_EarphoneTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_ChargerTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Charger"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_CameraTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_CameraTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: "Autofocus") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Autofocus"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        var biometricTestName = ""
        if BioMetricAuthenticator.canAuthenticate() {
            
            if BioMetricAuthenticator.shared.faceIDAvailable() {
                biometricTestName = "Face-Id Scanner"
            }else {
                biometricTestName = SDK_BiometricTestKey
            }
            
            if let val = SDKUserDefaults.value(forKey: SDK_BiometricTestKey) as? Bool {
                let model = ModelCompleteDiagnosticFlow()
                model.strTestType = biometricTestName
                
                if val {
                    self.arrFunctionalTest.append(model)
                }else {
                    self.arrFailedAndSkipedTest.append(model)
                }
            }
           
        }else {
            
            if LocalAuth.shared.hasTouchId() {
                print("Has Touch Id")
            } else if LocalAuth.shared.hasFaceId() {
                print("Has Face Id")
            } else {
                print("Device does not have Biometric Authentication Method")
            }
            
            print("Device does not have Biometric Authentication Method")
            
            biometricTestName = "Biometric Authentication"
            
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = biometricTestName
            self.arrFailedAndSkipedTest.append(model)
            
        }
        
        
        if let val = SDKUserDefaults.value(forKey: SDK_WifiTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_WifiTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: "Bluetooth") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Bluetooth"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: "GSM") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "GSM"
            
            if val {
                
                if SDKResultJSON["GSM"] == -2 {
                    
                }else {
                    self.arrFunctionalTest.append(model)
                }
                
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: "GSM") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "SMS Verification"
            
            if val {
                
                if SDKResultJSON["GSM"] == -2 {
                    
                }else {
                    self.arrFunctionalTest.append(model)
                }
                
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: "GPS") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "GPS"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_MicrophoneTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_MicrophoneTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
             
        if let val = SDKUserDefaults.value(forKey: SDK_SpeakerTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_SpeakerTestKey
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_VibratorTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = SDK_VibratorTestKey
            
            if val {
                
                if SDKResultJSON[SDK_VibratorTestKey] == -2 {
                    
                }else {
                    self.arrFunctionalTest.append(model)
                }
                
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: SDK_TorchTestKey) as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "FlashLight"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: "Storage") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Storage"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
        
        if let val = SDKUserDefaults.value(forKey: "Battery") as? Bool {
            let model = ModelCompleteDiagnosticFlow()
            model.strTestType = "Battery"
            
            if val {
                self.arrFunctionalTest.append(model)
            }else {
                self.arrFailedAndSkipedTest.append(model)
            }
        }
    
        
        if self.arrFailedAndSkipedTest.count > 0 {
            self.section = ["Failed and Skipped Tests", "Functional Checks"]
        }
        else{
            self.section = ["Functional Checks"]
        }
               
        self.tableViewTests.dataSource = self
        self.tableViewTests.delegate = self
        self.tableViewTests.reloadData()
                
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

open class LocalAuth: NSObject {

    public static let shared = LocalAuth()

    private override init() {}

    var laContext = LAContext()

    func canAuthenticate() -> Bool {
        var error: NSError?
        let hasTouchId = laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return hasTouchId
    }

    func hasTouchId() -> Bool {
        if canAuthenticate() && laContext.biometryType == .touchID {
            return true
        }
        return false
    }

    func hasFaceId() -> Bool {
        if canAuthenticate() && laContext.biometryType == .faceID {
            return true
        }
        return false
    }

}
