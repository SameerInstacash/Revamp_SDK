//
//  Label.swift
//  InstaCashSDK
//
//  Created by Sameer Khan on 06/07/21.
//

import UIKit

@IBDesignable open class InstaCashLabel : UILabel {

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
        self.font = UIFont.init(name: SDKFontRegular, size: self.font.pointSize)
        self.textColor = btnTitleColor
        
        self.layer.cornerRadius = CGFloat(appDelegate.apdelCornerRadius)
        self.layer.borderWidth = 1.0
        self.backgroundColor = UIColor().HexToColor(hexString: appDelegate.apdelBackColor, alpha: 1.0)
        self.layer.borderColor = UIColor.green.cgColor
        self.layer.shadowColor = UIColor.yellow.cgColor
        self.layer.shadowOpacity = 1.0
        */
    }
    
}
