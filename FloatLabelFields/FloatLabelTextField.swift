//
//  FloatLabelTextField.swift
//  FloatLabelFields
//
//  Created by Fahim Farook on 28/11/14.
//  Copyright (c) 2014 RookSoft Ltd. All rights reserved.
//
//  Original Concept by Matt D. Smith
//  http://dribbble.com/shots/1254439--GIF-Mobile-Form-Interaction?list=users
//
//  Objective-C version by Jared Verdi
//  https://github.com/jverdi/JVFloatLabeledTextField
//

import UIKit

@IBDesignable class FloatLabelTextField: UITextField,UITextFieldDelegate {
    let animationDuration = 0.3
    var title = UILabel()
    private var hasError: Bool  = false
    private var originalPlaceHolderText: String?
    private var validators =  [String: Any]()
    
    // MARK:- Properties
    override var accessibilityLabel: String! {
        get {
            if text!.isEmpty {
                return title.text
            } else {
                return text
            }
        }
        set {
            self.accessibilityLabel = newValue
        }
    }
    
    override var placeholder: String? {
        didSet {
            if title.text == nil {
                title.text = placeholder
                title.sizeToFit()
            }
        }
    }
    
    override var attributedPlaceholder: NSAttributedString? {
        didSet {
            title.text = attributedPlaceholder?.string
            title.sizeToFit()
        }
    }
    
    var titleFont: UIFont = UIFont.systemFontOfSize(12.0) {
        didSet {
            title.font = titleFont
        }
    }
    
    @IBInspectable var hintYPadding: CGFloat = 0.0
    
    @IBInspectable var titleYPadding: CGFloat = 0.0 {
        didSet {
            var r = title.frame
            r.origin.y = titleYPadding
            title.frame = r
        }
    }
    
    @IBInspectable var titleTextColour: UIColor = UIColor.grayColor() {
        didSet {
            if !isFirstResponder() {
                title.textColor = titleTextColour
            }
        }
    }
    
    @IBInspectable var titleActiveTextColour: UIColor! {
        didSet {
            if isFirstResponder() {
                title.textColor = titleActiveTextColour
            }
        }
    }
    
    @IBInspectable var errorTextColor: UIColor = UIColor.redColor()
    @IBInspectable var errorFontSize: CGFloat = 7.5
    @IBInspectable var isRequired: Bool = false
    @IBInspectable var isEmail: Bool = false
    
    
    
    
    // MARK:- Init
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.delegate  = self
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate  = self
        setup()
    }
    
    // MARK:- Overrides
    override func layoutSubviews() {
        super.layoutSubviews()
        let isResp = isFirstResponder()
        setTitlePositionForTextAlignment()
        if !text!.isEmpty && !hasError {
            placeholder = originalPlaceHolderText
            title.textColor = titleTextColour
            showTitle(isResp)
        }
        
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var r = super.editingRectForBounds(bounds)
        var top = ceil(title.font.lineHeight + hintYPadding)
        top = min(top, maxTopInset())
        r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top, 0.0, 0.0, 0.0))
        return CGRectIntegral(r)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        var r = super.editingRectForBounds(bounds)
        var top = ceil(title.font.lineHeight + hintYPadding)
        top = min(top, maxTopInset())
        r = UIEdgeInsetsInsetRect(r, UIEdgeInsetsMake(top, 0.0, 0.0, 0.0))
        return CGRectIntegral(r)
    }
    
    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var r = super.clearButtonRectForBounds(bounds)
        var top = ceil(title.font.lineHeight + hintYPadding)
        top = min(top, maxTopInset())
        r = CGRect(x: r.origin.x, y: r.origin.y + (top * 0.5), width: r.size.width, height: r.size.height)
        return CGRectIntegral(r)
    }
    
    // MARK:- Public Methods
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        clearError()
        let isResp = isFirstResponder()
        showTitle(isResp)
        if originalPlaceHolderText == nil {
            if let pHolder = placeholder {
                originalPlaceHolderText = pHolder
            }
        }
        placeholder = ""
    }
    
    
    func textFieldDidEndEditing(textField: UITextField) {
        placeholder = originalPlaceHolderText
        hideTitle(false)
        //        validateAllRules()
    }
    
    func addValidator(message:String,regex:NSRegularExpression) {
        validators[message] = regex
    }
    
    func addValidator(message:String,validator condtion:  () -> Bool) {
        validators[message] = condtion
    }
    
    func validate() -> Bool {
        validateAllRules()
        return hasError
    }
    
    // MARK:- Private Methods
    private func setup() {
        borderStyle = UITextBorderStyle.None
        titleActiveTextColour = tintColor
        // Set up title label
        title.alpha = 0.0
        title.font = titleFont
        title.textColor = titleTextColour
        if let str = placeholder {
            if !str.isEmpty {
                title.text = str
                title.sizeToFit()
            }
        }
        self.addSubview(title)
    }
    
    private func maxTopInset() -> CGFloat {
        return max(0, floor(bounds.size.height - font!.lineHeight - 4.0))
    }
    
    private func setTitlePositionForTextAlignment() {
        let r = textRectForBounds(bounds)
        var x = r.origin.x
        if textAlignment == NSTextAlignment.Center {
            x = r.origin.x + (r.size.width * 0.5) - title.frame.size.width
        } else if textAlignment == NSTextAlignment.Right {
            x = r.origin.x + r.size.width - title.frame.size.width
        }
        
        let frameToSet = CGRect(x: x, y: title.frame.origin.y, width: frame.size.width, height: title.frame.size.height)

        if CGRectEqualToRect(title.frame, frameToSet) == false {
            title.frame = frameToSet
        }
    }
    
    private func showTitle(animated: Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animateWithDuration(dur, delay: 0, options: [.BeginFromCurrentState, .CurveEaseOut], animations: {
            // Animation
            self.title.alpha = 1.0
            var r = self.title.frame
            r.origin.y = self.titleYPadding
            self.title.frame = r
            }, completion: nil)
    }
    
    private func hideTitle(animated: Bool) {
        let dur = animated ? animationDuration : 0
        UIView.animateWithDuration(dur, delay: 0, options: [.BeginFromCurrentState, .CurveEaseIn], animations: {
            // Animation
            self.title.alpha = 0.0
            var r = self.title.frame
            r.origin.y = self.title.font.lineHeight + self.hintYPadding
            self.title.frame = r
            }, completion: nil)
    }
    
    
    
    private func validateAllRules() {
        // Check required field rule
        if isRequired && text!.isEmpty {
            setRequiredError()
            return
        }
        // Check if its a email field
        if isEmail && !text!.isEmail() {
            setEmailError()
            return
        }
        
        // check all the custom validators
        
        for (message,validator) in validators {
            //  check the predicate
            if (validator as? (() -> Bool) != nil) {
                hasError = !(validator as! () -> Bool)()
            } else {
                // check the regex
                let regex = validator as? NSRegularExpression
                hasError = !(regex?.matchesInString(self.text!, options: NSMatchingOptions.ReportProgress, range: NSMakeRange(0, self.text!.length)) != nil)
            }
            if hasError {
                setCustomError(message)
                return
            }
            
        }
        
        
        let isResp = isFirstResponder()
        if hasError {
            showTitle(isResp)
        }else {
            clearError()
            if text!.isEmpty {
                hideTitle(isResp)
            }
        }
    }
    
    
    private func setRequiredError () {
        var fieldName = ""
        if let pHolder = placeholder {
            if pHolder != "" {
                fieldName = pHolder
            }
            else if let orgHolder = originalPlaceHolderText {
                fieldName = orgHolder
            }
        }
        title.text = "\(fieldName) can't be blank"
        showError()
    }
    
    private func setEmailError() {
        title.text = "Invalid Email"
        showError()
    }
    
    private func setCustomError(error: String) {
        title.text = error
        showError()
    }
    
    
    private func showError() {
        title.font = self.font!.fontWithSize(errorFontSize)
        title.textColor = errorTextColor
        hasError = true
        let isResp = isFirstResponder()
        showTitle(isResp)
        
    }
    
    private func clearError() {
        
        if let pHolder = placeholder {
            if pHolder != "" {
                title.text = pHolder
            }
            else if let orgHolder = originalPlaceHolderText {
                title.text = orgHolder
            }
        }
        title.textColor = titleTextColour
        title.font = self.font
        hasError = false
    }
    
    
    
}
