//
//  Button.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit

@IBDesignable open class InstaCashButton : UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProperties()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProperties()
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
    }
    
    func setProperties() {
        /*
        if let radius = btnCornerRadius {
            self.layer.cornerRadius = CGFloat(radius)
        }
        
        self.setTitleColor(btnTitleColor, for: .normal)
        self.backgroundColor = AppThemeColor
        self.titleLabel?.font = UIFont.init(name: SDKFontMedium, size: self.titleLabel?.font.pointSize ?? 18.0)
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.shadowColor = UIColor.yellow.cgColor
        self.layer.shadowOpacity = 1.0
        */
    }
    
}
