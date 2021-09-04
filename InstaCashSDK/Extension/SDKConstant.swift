//
//  SDKConstant.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit
import SwiftyJSON

var SDKdidFinishTestDiagnosis: (() -> Void)?
var SDKdidFinishRetryDiagnosis: (() -> Void)?

// ***** SDK Theme Color ***** //
var SDKThemeColorHexString : String?
var SDKThemeColor : UIColor = UIColor().HexToColor(hexString: SDKThemeColorHexString ?? "#4CA549", alpha: 1.0)

// ***** Font-Family ***** //
var SDKFontFamilyName : String?

var SDKFontRegular = "\(SDKFontFamilyName ?? "Roboto")-Regular"
var SDKFontMedium = "\(SDKFontFamilyName ?? "Roboto")-Medium"
var SDKFontBold = "\(SDKFontFamilyName ?? "Roboto")-Bold"

// ***** Button Properties ***** //
var SDKBtnCornerRadius : CGFloat = 0
var SDKBtnTitleColorHexString : String? 
var SDKBtnTitleColor : UIColor = UIColor().HexToColor(hexString: SDKBtnTitleColorHexString ?? "#FFFFFF", alpha: 1.0)

// ***** SDK Tests Performance ***** //
var holdSDKTestsPerformArray = [String]()
var SDKTestsPerformArray = [String]()
var SDKTestIndex : Int = 0

let SDKUserDefaults = UserDefaults.standard
var SDKResultJSON = JSON()
var SDKResultString = ""

var SDKOrientationLock = UIInterfaceOrientationMask.all

var SDKLicenseKey : String?
var SDKUserName : String?
var SDKApiKey : String?
var SDKUrl : String?
var SDKLastAdded : String?
var SDKLicenseLeft : Int?
var SDKLicenseConsumed : Int?
var SDKResultApplicableTill : Int?
var SDKResumeTestApplicableTill : Int?

var SDK_AssistedIsEnable : Bool?
var SDK_AssistedApplicableTill : Int?
var SDK_AutomatedIsEnable : Bool?
var SDK_AutomatedApplicableTill : Int?
var SDK_PhysicalIsEnable : Bool?
var SDK_PhysicalApplicableTill : Int?

// ***** SDK Test Keys ***** //
var SDK_ScreenTestKey = "Screen"
var SDK_DeadPixelTestKey = "Dead Pixels"
var SDK_SpeakerTestKey = "Speakers"
var SDK_MicrophoneTestKey = "Microphone"
var SDK_VibratorTestKey = "Vibrator"
var SDK_TorchTestKey = "Torch"
var SDK_AutorotationTestKey = "Rotation"
var SDK_ProximityTestKey = "Proximity"
var SDK_VolumeTestKey = "Hardware Buttons"
var SDK_EarphoneTestKey = "Earphone"
var SDK_ChargerTestKey = "USB"
var SDK_CameraTestKey = "Camera"
var SDK_BiometricTestKey = "Fingerprint Scanner"
var SDK_WifiTestKey = "WIFI"
var SDK_BackgroundTestKey = "SDK_Background_Test"

// ***** SDK Test Resume Keys ***** //
var SDK_ScreenCompleteKey = "Screen_Complete"
var SDK_DeadPixelCompleteKey = "Dead_Pixels_Complete"
var SDK_SpeakerCompleteKey = "Speakers_Complete"
var SDK_MicrophoneCompleteKey = "Microphone_Complete"
var SDK_VibratorCompleteKey = "Vibrator_Complete"
var SDK_TorchCompleteKey = "Torch_Complete"
var SDK_AutorotationCompleteKey = "Rotation_Complete"
var SDK_ProximityCompleteKey = "Proximity_Complete"
var SDK_VolumeCompleteKey = "Hardware_Buttons_Complete"
var SDK_EarphoneCompleteKey = "Earphone_Complete"
var SDK_ChargerCompleteKey = "USB_Complete"
var SDK_CameraCompleteKey = "Camera_Complete"
var SDK_BiometricCompleteKey = "Biometric_Complete"
var SDK_WifiCompleteKey = "WIFI_Complete"
var SDK_BackgroundCompleteKey = "Background_Complete"

var SDK_DiagnosisDataJSONKey = "Diagnosis_Result_JSON"
var SDK_DiagnosisAppCodeKey = "Diagnosis_Result_AppCode"
var SDK_ResultDataLeftTimeKey = "ResultData_Left_Time"
var SDK_TestLeftTimeKey = "Test_Left_Time"


