//
//  ViewController.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 05/07/21.
//

import UIKit
import SwiftyJSON
import FirebaseDatabase
import JGProgressHUD

class DiagnoseVC: UIViewController {
    
    open var didFinishDiagnosis: ((_ resultString: String, _ metadata: JSON) -> Void)?

    
    @IBOutlet weak var diagnoseStartBtn: UIButton!
    @IBOutlet weak var diagnoseResumeBtn: UIButton!
    
    let hud = JGProgressHUD()
    
    // Inputs from beckend to Apply into the SDK
    var inputThemeColor : String?
    var inputFontFamilyName : String?
    var inputBtnCornerRadius : CGFloat?
    var inputBtnTitleColor : String?
    var inputJSONOfTests : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.fetchDataFromFirebase()
        self.setInputPropertiesIntoSDK()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppOrientationUtility.lockOrientation(.portrait)
        
        DispatchQueue.main.async {
            self.setUIElementsProperties()
        }
        
        SDKTestsPerformArray = holdSDKTestsPerformArray
        SDKTestIndex = 0
        
        SDKResultJSON = JSON()
        SDKResultString = ""
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    func setInputPropertiesIntoSDK() {
        
        //self.inputThemeColor = "#591091"
        //self.inputFontFamilyName = "Supply"
        self.inputBtnCornerRadius = 5.0
        self.inputBtnTitleColor = "#FFFFFF"
        
        //self.inputJSONOfTests = "{ \"questions\": [\"screen\", \"deadpixel\", \"speaker\", \"mic\", \"vibrator\", \"flashlight\", \"rotation\", \"proximity\", \"volumebutton\", \"earphone\", \"charger\", \"camera\", \"biometric\", \"wifi\", \"battery\", \"bluetooth\", \"gps\", \"gsm\", \"autofocus\", \"storage\"] }"
        
        self.inputJSONOfTests = "{ \"questions\": [ \"speaker\", \"volumebutton\"] }"
        
        
        if let strTheme = self.inputThemeColor {
            SDKThemeColorHexString = strTheme
        }
        
        if let strFontFamily = self.inputFontFamilyName {
            SDKFontFamilyName = strFontFamily
        }
        
        if let corner = self.inputBtnCornerRadius {
            SDKBtnCornerRadius = corner
        }
        
        if let strBtnTitle = self.inputBtnTitleColor {
            SDKBtnTitleColorHexString = strBtnTitle
        }
        
        if let testJson = self.inputJSONOfTests {
            
            let jsonText = testJson
            var dictonary : NSDictionary?
            
            if let data = jsonText.data(using: String.Encoding.utf8) {
                do {
                    dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    
                    if let myDictionary = dictonary
                    {
                        //print(" test name is: \(myDictionary["questions"] ?? "")")
                        let testArray = myDictionary["questions"] as? [String]
                        SDKTestsPerformArray = testArray ?? []
                        holdSDKTestsPerformArray = SDKTestsPerformArray
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
        }else {
            
            let jsonText = "{ \"questions\": [\"screen\", \"deadpixel\", \"speaker\", \"mic\", \"vibrator\", \"flashlight\", \"rotation\", \"proximity\", \"volumebutton\", \"earphone\", \"charger\", \"camera\", \"biometric\", \"wifi\", \"battery\", \"bluetooth\", \"gps\", \"gsm\", \"autofocus\", \"storage\"] }"
            
            var dictonary : NSDictionary?
            
            if let data = jsonText.data(using: String.Encoding.utf8) {
                do {
                    dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                    
                    if let myDictionary = dictonary
                    {
                        //print(" test name is: \(myDictionary["questions"] ?? "")")
                        let testArray = myDictionary["questions"] as? [String]
                        SDKTestsPerformArray = testArray ?? []
                        holdSDKTestsPerformArray = SDKTestsPerformArray
                    }
                    
                } catch let error as NSError {
                    print(error)
                }
            }
            
        }
        
    }
    
    // MARK:- Firebase Data Fetch Methods
    func fetchDataFromFirebase() {
        
        self.hud.textLabel.text = ""
        self.hud.backgroundColor = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 0.4)
        self.hud.show(in: self.view)
        
        let ref = Database.database().reference(withPath: "Organisation")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            
            self.hud.dismiss()
            
            if !snapshot.exists() { return }
            let sdkArr = snapshot.value as? NSArray ?? []
            
            print(sdkArr)
            let SDK_Data = sdkArr[0] as? [String:Any] ?? [:]
           
            if let licenseKey = SDK_Data["licenseKey"] as? String {
                SDKLicenseKey = licenseKey
            }

            if let UserName = SDK_Data["userName"] as? String {
                SDKUserName = UserName
            }
            
            if let Apikey = SDK_Data["apiKey"] as? String {
                SDKApiKey = Apikey
            }
            
            if let url = SDK_Data["url"] as? String {
                SDKUrl = url
            }
            
            if let licenseAdd = SDK_Data["licenseLastAdded"] as? String {
                SDKLastAdded = licenseAdd
            }
            
            if let licenseLeft = SDK_Data["licenseLeft"] as? Int {
                SDKLicenseLeft = licenseLeft
            }
            
            if let licenseConsumed = SDK_Data["licenseConsumed"] as? Int {
                SDKLicenseConsumed = licenseConsumed
            }
            
            if let resultApplicableTill = SDK_Data["ResultApplicableTill"] as? Int {
                SDKResultApplicableTill = resultApplicableTill
            }
            
            if let resumeTestApplicableTill = SDK_Data["ResumeTestApplicableTill"] as? Int {
                SDKResumeTestApplicableTill = resumeTestApplicableTill
            }
            
          
            
            if let assistedDict = SDK_Data["Assisted"] as? [String:Any] {
                
                if let enable = assistedDict["isEnable"] as? Bool {
                    SDK_AssistedIsEnable = enable
                }
                
                if let applicable = assistedDict["ApplicableTill"] as? Int {
                    SDK_AssistedApplicableTill = applicable
                }
                
            }
            
            if let automatedDict = SDK_Data["Automated"] as? [String:Any] {
                
                if let enable = automatedDict["isEnable"] as? Bool {
                    SDK_AutomatedIsEnable = enable
                }
                
                if let applicable = automatedDict["ApplicableTill"] as? Int {
                    SDK_AutomatedApplicableTill = applicable
                }
                                
            }
            
            if let physicalDict = SDK_Data["Physical"] as? [String:Any] {
                
                if let enable = physicalDict["isEnable"] as? Bool {
                    SDK_PhysicalIsEnable = enable
                }
                
                if let applicable = physicalDict["ApplicableTill"] as? Int {
                    SDK_PhysicalApplicableTill = applicable
                }
                
            }
            
            // To Handle Resume Button Show/Hide
            if let isLastTestTime = SDKUserDefaults.value(forKey: SDK_TestLeftTimeKey) as? String {
                
                let timeDiff = findTimeDiff(testLeftTimeStr: isLastTestTime, currentTimeStr: getCurrentTime())
                //let timeDiff = findTimeDiff(testLeftTimeStr: "03/08/2021 09:02", currentTimeStr: getCurrentTime())
                print(timeDiff)
                
                if timeDiff >= SDKResumeTestApplicableTill ?? 0 {
                    self.diagnoseResumeBtn.isHidden = true
                }else {
                    self.diagnoseResumeBtn.isHidden = false
                }
                
            }else {
                
            }
            
            // To Handle test Result JSON Save/Delete
            if let isResultTestTime = SDKUserDefaults.value(forKey: SDK_ResultDataLeftTimeKey) as? String {
                let timeDiff = findTimeDiff(testLeftTimeStr: isResultTestTime, currentTimeStr: getCurrentTime())
                print(timeDiff)
                
                if timeDiff >= SDKResultApplicableTill ?? 0 {
                    SDKUserDefaults.removeObject(forKey: SDK_ResultDataLeftTimeKey)
                    SDKUserDefaults.removeObject(forKey: SDK_DiagnosisDataJSONKey)
                    SDKUserDefaults.removeObject(forKey: SDK_DiagnosisAppCodeKey)
                }else {
                    
                    if let resultAppCodeStr = SDKUserDefaults.object(forKey: SDK_DiagnosisAppCodeKey) as? String {
                        SDKResultString = resultAppCodeStr
                    }
                    
                    if let resultJson = SDKUserDefaults.object(forKey: SDK_DiagnosisDataJSONKey) as? String {
                        SDKResultJSON = JSON.init(parseJSON: resultJson)
                    }

                    print(SDKResultString)
                    
                }
                
            }else {
                
            }
            
            
        })
        
    }
    
    // MARK:- Diagnose Data Methods
    func setResults() {
        guard let didFinishDiagnosis = self.didFinishDiagnosis else { return }
        didFinishDiagnosis(SDKResultString, SDKResultJSON)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Custom Methods
    func setUIElementsProperties() {
        
        self.setStatusBarColor(themeColor: SDKThemeColor)
        
        self.diagnoseStartBtn.backgroundColor = SDKThemeColor
        self.diagnoseStartBtn.layer.cornerRadius = SDKBtnCornerRadius
        self.diagnoseStartBtn.setTitleColor(SDKBtnTitleColor, for: .normal)
        let fontSize1 = self.diagnoseStartBtn.titleLabel?.font.pointSize
        self.diagnoseStartBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: fontSize1 ?? 18.0)
        self.diagnoseStartBtn.setTitle(self.getLocalizatioStringValue(key: "Start").uppercased(), for: .normal)
        
        self.diagnoseResumeBtn.backgroundColor = SDKThemeColor
        self.diagnoseResumeBtn.layer.cornerRadius = SDKBtnCornerRadius
        self.diagnoseResumeBtn.setTitleColor(SDKBtnTitleColor, for: .normal)
        let fontSize2 = self.diagnoseResumeBtn.titleLabel?.font.pointSize
        self.diagnoseResumeBtn.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: fontSize2 ?? 18.0)
        self.diagnoseResumeBtn.setTitle(self.getLocalizatioStringValue(key: "Resume").uppercased(), for: .normal)
        
    }

    // MARK:- IBActions
    @IBAction func startButtonPressed(_ sender: UIButton) {
      
        if let SDKExpire = SDKLicenseLeft {
            if SDKExpire > 0 {
                self.NavigateToNextTestVC()
            }else {
                self.showaAlert(title: "502", message: self.getLocalizatioStringValue(key: "Some Error Occurred, Please Check Back After Sometime"))
            }
        }
        
    }
    
    @IBAction func resumeButtonPressed(_ sender: UIButton) {
        
    }

}

