//
//  UIViewController.swift
//  PostTestBitHealth
//
//  Created by Hafied on 01/11/23.
//

import UIKit

extension UIViewController {
    func errorRequired(errorLabel: UILabel, textfield: UITextField, titlestring: String) {
        errorLabel.isHidden = false
        errorLabel.text = "\(titlestring)"
        textfield.layer.borderColor = UIColor.red.cgColor
        textfield.layer.borderWidth = 1.5
        textfield.layer.cornerRadius = 5.0
    }
    
    func hiddenErrorLabel(textfield: UITextField, label: UILabel) {
        if textfield.text?.isEmpty == nil {
            label.isHidden = false
        } else {
            label.isHidden = true
        }
    }
    
    func alertCustom(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLoading() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.view.bounds
        blurredEffectView.alpha = 0.3
        blurredEffectView.tag = 3
        self.view.addSubview(blurredEffectView)
        let activityView = UIActivityIndicatorView(style: .medium)
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
        activityView.tag = 2
    }
    
    func removeLoading() {
        if let removeable = self.view.viewWithTag(3) {
            removeable.removeFromSuperview()
        }
        
        if let removeable2 = self.view.viewWithTag(2) {
            removeable2.removeFromSuperview()
        }
    }
}
