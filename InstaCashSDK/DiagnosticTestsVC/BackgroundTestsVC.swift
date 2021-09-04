//
//  BackgroundTestsVC.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import PopupDialog
import Luminous
import SwiftyJSON
import CoreBluetooth
import JGProgressHUD
import CoreTelephony
import CoreLocation
import INTULocationManager

class BackgroundTestsVC: UIViewController, CBCentralManagerDelegate {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var diagnoseProgressView: UIProgressView!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var subHeadingLbl: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    
    var isComingFromDiagnosticTestResult = false
    
    let hud = JGProgressHUD()
    var isCapableToCall: Bool = false
    var blueToothManager: CBCentralManager!
    let locationManager = CLLocationManager()
    var gpsTimer: Timer?
    var count = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        SDKUserDefaults.setValue(false, forKey: SDK_BackgroundCompleteKey)
        SDKUserDefaults.setValue(getCurrentTime(), forKey: SDK_TestLeftTimeKey)
        
        self.isLocationAccessEnabled()

        DispatchQueue.main.async {
            self.setUIElementsProperties()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppOrientationUtility.lockOrientation(.portrait)
        
        self.blueToothManager = CBCentralManager()
        self.blueToothManager.delegate = self
        
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
          
        self.countLbl.textColor = SDKThemeColor
        self.countLbl.font = UIFont.init(name: SDKFontRegular, size: self.countLbl.font.pointSize)
        self.diagnoseProgressView.progressTintColor = SDKThemeColor
        
        // MultiLingual
        self.startBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        //self.skipBtn.setTitle(self.getLocalizatioStringValue(key: "Skip").uppercased(), for: .normal)
        //self.titleLbl.text = self.getLocalizatioStringValue(key: "Wifi")
        //self.headingLbl.text = self.getLocalizatioStringValue(key: "Checking WiFi")
        self.subHeadingLbl.text = self.getLocalizatioStringValue(key: "Please make sure Bluetooth, GPS and Wifi are enabled on your device and press begin to start the tests")
        self.subHeadingLbl.font = UIFont.init(name: SDKFontRegular, size: self.subHeadingLbl.font.pointSize)
        
    }
    
    func isLocationAccessEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access of location")
                
                locationManager.requestWhenInUseAuthorization()
                
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access of location")
                
            @unknown default:
                print("Something wrong with location update")
                
                break
            }
        } else {
            print("Location services not enabled")
            
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    //MARK:- bluetooth delegates methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            
            SDKResultJSON["Bluetooth"].int = 1
            SDKUserDefaults.setValue(true, forKey: "Bluetooth")
            
            break
        case .poweredOff:
            SDKResultJSON["Bluetooth"].int = -1
            SDKUserDefaults.setValue(false, forKey: "Bluetooth")
            
            if !SDKResultString.contains("CISS04") {
                SDKResultString = SDKResultString + "CISS04;"
            }
            
            break
        case .resetting:
            SDKResultJSON["Bluetooth"].int = 0
            SDKUserDefaults.setValue(false, forKey: "Bluetooth")
            
            if !SDKResultString.contains("CISS04") {
                SDKResultString = SDKResultString + "CISS04;"
            }
            
            break
        case .unauthorized:
            SDKResultJSON["Bluetooth"].int = 0
            SDKUserDefaults.setValue(false, forKey: "Bluetooth")
            
            if !SDKResultString.contains("CISS04") {
                SDKResultString = SDKResultString + "CISS04;"
            }
            
            break
        case .unsupported:
            SDKResultJSON["Bluetooth"].int = 0
            SDKUserDefaults.setValue(false, forKey: "Bluetooth")
            
            if !SDKResultString.contains("CISS04") {
                SDKResultString = SDKResultString + "CISS04;"
            }
            
            break
        case .unknown:
            break
        @unknown default:
            break
        }
    }
    
    // MARK:- IBActions
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        // ***** STARTING ALL TESTS ***** //
        
        if SDKTestsPerformArray.contains("gsm") {
            
            SDKResultJSON["GSM"].int = 0
            SDKUserDefaults.setValue(false, forKey: "GSM")
            SDKResultString = SDKResultString + "CISS10;"
           
            
            // 1. GSM Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Network") + "..."
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.indicatorView = JGProgressHUDRingIndicatorView()
                self.hud.progress = 0.2
                self.hud.show(in: self.view)
                
                if self.checkGSM() {
                    
                    if Luminous.Carrier.mobileCountryCode != nil {
                        SDKResultJSON["GSM"].int = 1
                        SDKUserDefaults.setValue(true, forKey: "GSM")
                        
                        if SDKResultString.contains("CISS10;") {
                            SDKResultString = SDKResultString.replacingOccurrences(of: "CISS10;", with: "")
                        }
                        
                    }
                    
                    if Luminous.Carrier.mobileNetworkCode != nil {
                        SDKResultJSON["GSM"].int = 1
                        SDKUserDefaults.setValue(true, forKey: "GSM")
                        
                        if SDKResultString.contains("CISS10;") {
                            SDKResultString = SDKResultString.replacingOccurrences(of: "CISS10;", with: "")
                        }
                        
                    }
                  
                    if Luminous.Carrier.ISOCountryCode != nil {
                        SDKResultJSON["GSM"].int = 1
                        SDKUserDefaults.setValue(true, forKey: "GSM")
                        
                        if SDKResultString.contains("CISS10;") {
                            SDKResultString = SDKResultString.replacingOccurrences(of: "CISS10;", with: "")
                        }
                        
                    }
                    
                }else {
                    
                    SDKResultJSON["GSM"].int = -2
                    SDKUserDefaults.setValue(true, forKey: "GSM")
                    
                    if SDKResultString.contains("CISS10;") {
                        SDKResultString = SDKResultString.replacingOccurrences(of: "CISS10;", with: "")
                    }
                    
                }
                
                
                if let index = SDKTestsPerformArray.firstIndex(of: "gsm") {
                    SDKTestsPerformArray.remove(at: index)
                }
                
            }
            
        }
        
        
        if SDKTestsPerformArray.contains("bluetooth") {
            
            SDKResultJSON["Bluetooth"].int = 0
            SDKUserDefaults.setValue(false, forKey: "Bluetooth")
            
            
            // 2. Bluetooth Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Bluetooth") + "..."
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.indicatorView = JGProgressHUDRingIndicatorView()
                self.hud.progress = 0.4
                self.hud.show(in: self.view)
                
                switch self.blueToothManager.state {
                case .poweredOn:
                    
                    SDKResultJSON["Bluetooth"].int = 1
                    SDKUserDefaults.setValue(true, forKey: "Bluetooth")
                    
                    break
                case .poweredOff:
                    
                    SDKResultJSON["Bluetooth"].int = -1
                    SDKUserDefaults.setValue(false, forKey: "Bluetooth")
                    
                    if !SDKResultString.contains("CISS04") {
                        SDKResultString = SDKResultString + "CISS04;"
                    }
                    
                    break
                case .resetting:
                    
                    SDKResultJSON["Bluetooth"].int = 0
                    SDKUserDefaults.setValue(false, forKey: "Bluetooth")
                    
                    if !SDKResultString.contains("CISS04") {
                        SDKResultString = SDKResultString + "CISS04;"
                    }
                    
                    break
                case .unauthorized:
                    
                    SDKResultJSON["Bluetooth"].int = 0
                    SDKUserDefaults.setValue(false, forKey: "Bluetooth")
                    
                    if !SDKResultString.contains("CISS04") {
                        SDKResultString = SDKResultString + "CISS04;"
                    }
                    
                    break
                case .unsupported:
                    
                    SDKResultJSON["Bluetooth"].int = 0
                    SDKUserDefaults.setValue(false, forKey: "Bluetooth")
                    
                    if !SDKResultString.contains("CISS04") {
                        SDKResultString = SDKResultString + "CISS04;"
                    }
                    
                    break
                case .unknown:
                    break
                default:
                    break
                }
                
                
                if let index = SDKTestsPerformArray.firstIndex(of: "bluetooth") {
                    SDKTestsPerformArray.remove(at: index)
                }
                
            }
                        
        }
        
        
        if SDKTestsPerformArray.contains("storage") {
            
            SDKResultJSON["Storage"].int = 0
            SDKUserDefaults.setValue(false, forKey: "Storage")
            
            
            // 3. Storage Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking Storage") + "..."
                self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
                self.hud.indicatorView = JGProgressHUDRingIndicatorView()
                self.hud.progress = 0.6
                self.hud.show(in: self.view)
                
                if Luminous.Hardware.physicalMemory(with: .megabytes) > 1024.0 {
                    SDKResultJSON["Storage"].int = 1
                    SDKUserDefaults.setValue(true, forKey: "Storage")
                }else {
                    SDKResultJSON["Storage"].int = 0
                    SDKUserDefaults.setValue(false, forKey: "Storage")
                }
              
                
                if let index = SDKTestsPerformArray.firstIndex(of: "storage") {
                    SDKTestsPerformArray.remove(at: index)
                }
                
            }
            
        }
        
        
        if SDKTestsPerformArray.contains("gps") {
            
            SDKResultJSON["GPS"].int = 0
            SDKUserDefaults.setValue(false, forKey: "GPS")
            
            
            // 4. GPS Test
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                
                self.gpsTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.runTimedCode), userInfo: nil, repeats: true)
                
                if let index = SDKTestsPerformArray.firstIndex(of: "gps") {
                    SDKTestsPerformArray.remove(at: index)
                }
                
            }
            
        }
        
        
        if SDKTestsPerformArray.contains("battery") {
            
            SDKResultJSON["Battery"].int = 1
            SDKUserDefaults.setValue(true, forKey: "Battery")
            
            if let index = SDKTestsPerformArray.firstIndex(of: "battery") {
                SDKTestsPerformArray.remove(at: index)
            }
        }
        
        
        if SDKTestsPerformArray.contains("nfc") {
                        
            if let index = SDKTestsPerformArray.firstIndex(of: "nfc") {
                SDKTestsPerformArray.remove(at: index)
            }
        }
        
        
        if !SDKTestsPerformArray.contains("gps") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Tests Complete!")
                self.hud.progress = 1.0
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.locationManager.stopUpdatingLocation()
                    
                    self.gpsTimer?.invalidate()
                    self.navigateToTestResultScreen()
                }
                
            }
        }
    
        
        /* NFC Test
        // Check if NFC supported
        if #available(iOS 11.0, *) {
            if NFCNDEFReaderSession.readingAvailable {
                // available
                self.resultJSON["NFC"].int = 1
                userDefaults.setValue(true, forKey: "NFC")
            }
            else {
                // not
                self.resultJSON["NFC"].int = 0
                userDefaults.setValue(false, forKey: "NFC")
            }
        } else {
            //iOS don't support
            self.resultJSON["NFC"].int = -2
            userDefaults.setValue(false, forKey: "NFC")
        }
        */
    
       
    }
    
    @objc func runTimedCode() {
        
        self.count += 1
                
        self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Checking GPS") + "..."
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.indicatorView = JGProgressHUDRingIndicatorView()
        self.hud.progress = 0.8
        self.hud.show(in: self.view)
        
        
        let locationManager = INTULocationManager.sharedInstance()
        locationManager.requestLocation(withDesiredAccuracy: .city,
                                        timeout: 10.0,
                                        delayUntilAuthorized: true) { (currentLocation, achievedAccuracy, status) in
            
            if (status == INTULocationStatus.success) {
                
                // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                // currentLocation contains the device's current location
                
                SDKResultJSON["GPS"].int = 1
                SDKUserDefaults.setValue(true, forKey: "GPS")
                
            }
            else if (status == INTULocationStatus.timedOut) {
                                
                // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                // However, currentLocation contains the best location available (if any) as of right now,
                // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                
                SDKResultJSON["GPS"].int = 0
                SDKUserDefaults.setValue(false, forKey: "GPS")
                
                if !SDKResultString.contains("CISS04") {
                    SDKResultString = SDKResultString + "CISS04;"
                }
                
            }
            else {
                // An error occurred, more info is available by looking at the specific status returned.
                
                SDKResultJSON["GPS"].int = 0
                SDKUserDefaults.setValue(false, forKey: "GPS")
                
                if !SDKResultString.contains("CISS04") {
                    SDKResultString = SDKResultString + "CISS04;"
                }
                
            }
            
        }
        
        if count > 2 {
            DispatchQueue.main.async {
                
                self.hud.textLabel.text = self.getLocalizatioStringValue(key: "Tests Complete!")
                self.hud.progress = 1.0
                
            }
        }
        
        if count > 3 {
            locationManager.cancelLocationRequest(INTULocationRequestID.init())
            
            self.gpsTimer?.invalidate()
            self.locationManager.stopUpdatingLocation()
            
            self.navigateToTestResultScreen()
        }
        
    }
    
    func navigateToTestResultScreen() {
        
        // ***** FINALISING ALL TESTS ***** //

        DispatchQueue.main.async {
            
            self.hud.dismiss()
            
            //self.NavigateToDiagnoseTestResultVC()
            self.gpsTimer?.invalidate()
            self.locationManager.stopUpdatingLocation()
            
            SDKUserDefaults.setValue(true, forKey: SDK_BackgroundCompleteKey)
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
    
    @IBAction func skipButtonPressed(_ sender: UIButton) {
    
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

extension BackgroundTestsVC {

    func checkGSM() -> Bool {
        
        if UIApplication.shared.canOpenURL(NSURL(string: "tel://")! as URL) {
            // Check if iOS Device supports phone calls
            // User will get an alert error when they will try to make a phone call in airplane mode
            
            
            if let mnc = CTTelephonyNetworkInfo().subscriberCellularProvider?.mobileNetworkCode, !mnc.isEmpty {
                // iOS Device is capable for making calls
                self.isCapableToCall = true
            } else {
                // Device cannot place a call at this time. SIM might be removed
                //self.isCapableToCall = false
                self.isCapableToCall = true
            }
        } else {
            // iOS Device is not capable for making calls
            self.isCapableToCall = false
        }
        
        print(isCapableToCall)
        return self.isCapableToCall
        
    }
    
}
