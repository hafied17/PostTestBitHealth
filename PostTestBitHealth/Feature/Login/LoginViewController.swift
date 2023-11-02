//
//  LoginViewController.swift
//  PostTestBitHealth
//
//  Created by Hafied on 01/11/23.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        if isLogin {
            let vc = HomeViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setupUI() {
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        
        signinButton.layer.cornerRadius = 5
        
        let singupGesture = UITapGestureRecognizer(target: self, action: #selector(handleToSignup))
        signupView.addGestureRecognizer(singupGesture)
    }
    
    func context()->NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    func convertToBase64(_ string: String) -> String {
        if let data = string.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return ""
    }
    
    func convertBase64ToString(_ base64String: String) -> String? {
        if let data = Data(base64Encoded: base64String) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func isInvalidEmail(_ value: String) -> Bool {
        let reqularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        if !predicate.evaluate(with: value) {
            return false
        }
        
        return true
    }
    
    @IBAction func emailChanged(_ sender: Any) {
        hiddenErrorLabel(textfield: emailTextfield, label: emailErrorLabel)
    }
    
    @IBAction func passwordChanged(_ sender: Any) {
        hiddenErrorLabel(textfield: passwordTextfield, label: passwordErrorLabel)
    }
    
    @IBAction func signinPressed(_ sender: Any) {
        let email = emailTextfield.text ?? ""
        let pass = passwordTextfield.text ?? ""
        if email.isEmpty {
            errorRequired(errorLabel: emailErrorLabel, textfield: emailTextfield, titlestring: "This field is reqired!")
        } else if pass.isEmpty {
            errorRequired(errorLabel: passwordErrorLabel, textfield: passwordTextfield, titlestring: "This field is reqired!")
        } else {
            if !isInvalidEmail(email) {
                errorRequired(errorLabel: emailErrorLabel, textfield: emailTextfield, titlestring: "Please use a valid email address!")
            } else {
                let context = context()
                let fetchRequest : NSFetchRequest<Users> = Users.fetchRequest()
                let predicate = NSPredicate(format: "email == %@ AND password == %@", convertToBase64(email), convertToBase64(pass))
                fetchRequest.predicate = predicate
                
                do {
                    let result = try context.fetch(fetchRequest)
                    
                    if result.count == 1 {
                        for res in result {
                            let email = res.value(forKey: "email")
                            let name = res.value(forKey: "name")
                            UserDefaults.standard.set(convertBase64ToString(email as! String), forKey: "emailUser")
                            UserDefaults.standard.set(convertBase64ToString(name as! String), forKey: "nameUser")

                        }
                        UserDefaults.standard.set(true, forKey: "isLogin")
                        let vc = HomeViewController()
                        navigationController?.pushViewController(vc, animated: true)
                        
                    } else {
                        alertCustom(title: "Error", message: "Make sure your email address or password is correct")
                    }
                    
                } catch let error as NSError {
                    alertCustom(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc func handleToSignup() {
        UIView.animate(withDuration: 0.25) {
            self.signupView.alpha = 0.5
        } completion: { _ in
            self.signupView.alpha = 1
            
            let vc = RegisterViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 101.0/255.0, green: 184.0/255.0, blue: 76.0/255.0, alpha: 1.0).cgColor
        textField.layer.borderWidth = 1.5
        textField.layer.cornerRadius = 5.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor(red: 204.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5.0
    }
    
}
