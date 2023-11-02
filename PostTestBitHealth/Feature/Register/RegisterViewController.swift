//
//  RegisterViewController.swift
//  PostTestBitHealth
//
//  Created by Hafied on 01/11/23.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController {
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var confirmPasswordTextfield: UITextField!
    @IBOutlet weak var signinView: UIStackView!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var confirmErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var nameErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    func context()->NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    func setupUI() {
        nameTextfield.delegate = self
        emailTextfield.delegate = self
        passwordTextfield.delegate = self
        confirmPasswordTextfield.delegate = self
        
        signupButton.layer.cornerRadius = 5
        
        let singinGesture = UITapGestureRecognizer(target: self, action: #selector(handleToSignin))
        signinView.addGestureRecognizer(singinGesture)
    }
    
    func isInvalidEmail(_ value: String) -> Bool {
        let reqularExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reqularExpression)
        if !predicate.evaluate(with: value) {
            return false
        }
        
        return true
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        // Password length validation (at least 8 characters)
        let passwordLength = NSPredicate(format: "SELF MATCHES %@", ".{8,}")
        // Uppercase letter validation
        let uppercaseLetter = NSPredicate(format: "SELF MATCHES %@", ".*[A-Z]+.*")
        // Lowercase letter validation
        let lowercaseLetter = NSPredicate(format: "SELF MATCHES %@", ".*[a-z]+.*")
        // Number validation
        let number = NSPredicate(format: "SELF MATCHES %@", ".*[0-9]+.*")
        // Special character validation
        let specialCharacter = NSPredicate(format: "SELF MATCHES %@", ".*[^A-Za-z0-9].*")

        return passwordLength.evaluate(with: password) &&
               uppercaseLetter.evaluate(with: password) &&
               lowercaseLetter.evaluate(with: password) &&
               number.evaluate(with: password) &&
               specialCharacter.evaluate(with: password)
    }
    
    func convertToBase64(_ string: String) -> String {
        if let data = string.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return ""
    }
    
    @objc func handleToSignin() {
        UIView.animate(withDuration: 0.25) {
            self.signinView.alpha = 0.5
        } completion: { _ in
            self.signinView.alpha = 1
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func signupPressed(_ sender: Any) {
        let name = nameTextfield.text ?? ""
        let email = emailTextfield.text ?? ""
        let pass = passwordTextfield.text ?? ""
        let confirmPass = confirmPasswordTextfield.text ?? ""
        
        if name.isEmpty {
            errorRequired(errorLabel: nameErrorLabel, textfield: nameTextfield, titlestring: "This field is reqired!")
        } else if email.isEmpty {
            errorRequired(errorLabel: emailErrorLabel, textfield: emailTextfield, titlestring: "This field is reqired!")
        } else if pass.isEmpty {
            errorRequired(errorLabel: passwordErrorLabel, textfield: passwordTextfield, titlestring: "This field is reqired!")
        } else if confirmPass.isEmpty {
            errorRequired(errorLabel: confirmErrorLabel, textfield: confirmPasswordTextfield, titlestring: "This field is reqired!")
        } else {
            if !isInvalidEmail(email) {
                errorRequired(errorLabel: emailErrorLabel, textfield: emailTextfield, titlestring: "Please use a valid email address!")
            } else {
                if  pass != confirmPass {
                    errorRequired(errorLabel: confirmErrorLabel, textfield: confirmPasswordTextfield, titlestring: "Please make sure your password match!")
                } else {
                    if !isPasswordValid(pass) {
                        let errorText = " at least one lowercase latter \n at least one uppercase \n at least one number \n minimum 8 characters"
                        errorRequired(errorLabel: passwordErrorLabel, textfield: passwordTextfield, titlestring: errorText)
                    } else {
                        // register user
                        let context = context()
                        let fetchRequest : NSFetchRequest<Users> = Users.fetchRequest()
                        let predicate = NSPredicate(format: "email == %@", convertToBase64(email))
                        fetchRequest.predicate = predicate
                        
                        do {
                            showLoading()
                            let result = try context.fetch(fetchRequest)
                            
                            if result.count == 0 {
                                
                                let usersEntity = NSEntityDescription.entity(forEntityName: "Users", in: context)
                                let newRegister = NSManagedObject(entity: usersEntity!, insertInto: context)
                                
                                newRegister.setValue(convertToBase64(name), forKey: "name")
                                newRegister.setValue(convertToBase64(email), forKey: "email")
                                newRegister.setValue(convertToBase64(pass), forKey: "password")
                                
                                do {
                                    try context.save()
                                    let alert = UIAlertController(title: "Success", message: "Your account has been successfully created!", preferredStyle: .alert)
                                    let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
                                        self.removeLoading()
                                        self.navigationController?.popViewController(animated: true)
                                    }
                                    alert.addAction(alertAction)
                                    present(alert, animated: true)
                                    
                                } catch let error as NSError {
                                    removeLoading()
                                    alertCustom(title: "Error", message: error.localizedDescription)
                                    
                                }
                                
                            } else {
                                removeLoading()
                                alertCustom(title: "Error", message: "A user with this email already exists!")
                            }
                            
                        } catch let error as NSError {
                            removeLoading()
                            alertCustom(title: "Error", message: error.localizedDescription)
                        }
                        
                    }
                }
            }
        }
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        hiddenErrorLabel(textfield: nameTextfield, label: nameErrorLabel)
    }
    
    @IBAction func emailChanged(_ sender: Any) {
        hiddenErrorLabel(textfield: emailTextfield, label: emailErrorLabel)
    }
    
    @IBAction func passwordChanged(_ sender: Any) {
        hiddenErrorLabel(textfield: passwordTextfield, label: passwordErrorLabel)
    }
    
    @IBAction func confirmPasswordChanged(_ sender: Any) {
        hiddenErrorLabel(textfield: confirmPasswordTextfield, label: confirmErrorLabel)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
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
