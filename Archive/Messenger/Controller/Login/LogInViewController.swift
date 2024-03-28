//
//  LogInViewController.swift
//  Messenger
//
//  Created by Apple on 02.08.1444 (AH).
//

import UIKit
import FirebaseAuth
import Firebase
import FBSDKLoginKit
import JGProgressHUD
import GoogleSignIn

class LogInViewController: UIViewController {
    
    private let googlesignInButton = GIDSignInButton()
    
    private let spinner = JGProgressHUD(style: .dark)
     
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo")
        return imageView
    }()
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email.."
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        textField.leftViewMode = UITextField.ViewMode.always
        textField.backgroundColor = .systemGray6
        return textField
    }()
    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Passowrd.."
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        textField.leftViewMode = UITextField.ViewMode.always
        textField.backgroundColor = .systemGray6
        textField.isSecureTextEntry = true
        return textField
    }()
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 19, weight: .medium)
        return button
    }()
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Don't you have an accaunt ? Register", for: .normal)
        button.backgroundColor = .systemBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 19, weight: .medium)
        return button
    }()
    
    private let facebookLogin: FBLoginButton = {
       let button = FBLoginButton()
        button.permissions = ["email"]
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log In"
        emailField.delegate = self
        passwordField.delegate = self
        facebookLogin.delegate = self
        googlesignInButton.addTarget(self, action: #selector(ddigoogleSigninButtonTapped), for: .touchUpInside)
      
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        setUpScrollView()
        setUpButtons()
    }
    
    @objc private func ddigoogleSigninButtonTapped() {
        let actionSheet = UIAlertController(title: "Oops", message: "This app couldn't support by google please try with email or facebook", preferredStyle: .alert)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
       present(actionSheet, animated: true)
        
    }
    
    private func setUpScrollView() {
        scrollView.addSubview(emailField)
        scrollView.addSubview(imageView)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(registerButton)
        scrollView.addSubview(facebookLogin)
        scrollView.addSubview(googlesignInButton)

    }
    private func setUpButtons(){
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        navigationItem.titleView?.tintColor = .label
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
    }
    @objc private func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create an Accaunt"
        navigationController?.pushViewController(vc, animated: true)
    }
  
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/2
        imageView.frame = CGRect(x: (scrollView.width - size)/1.5, y: 30, width: size/1.5, height: size/1.5)
        emailField.frame = CGRect(x: 20, y: imageView.bottom + 20, width: scrollView.width - 40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom + 15, width: scrollView.width - 40, height: 50)
        loginButton.frame = CGRect(x: 20, y: passwordField.bottom + 15, width: scrollView.width - 40, height: 50)
        facebookLogin.frame = CGRect(x: 20, y: loginButton.bottom + 15, width: scrollView.width - 40, height: 50)
        googlesignInButton.frame = CGRect(x: 20, y: facebookLogin.bottom + 15, width: scrollView.width - 40, height: 50)
        registerButton.frame = CGRect(x: 20, y: googlesignInButton.bottom + 15, width: scrollView.width - 40, height: 50)
        
    }
    
    @objc private func didTapLogin() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty
                , !password.isEmpty,
              password.count >= 6 else {
            alertLoginError()
            return
        }
        spinner.show(in: view)
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self ] authResult, error in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            guard let result = authResult, error == nil else {
                print("Failed to sign in user with email: \(email)")
                return
            }
            let user = result.user
            print("Logged in user: \(user)")
            
            UserDefaults.standard.set(email, forKey: "email")
            
            strongSelf.navigationController?.dismiss(animated: true)
        }
    }
    @objc private func alertLoginError() {
        let alert = UIAlertController(title: "Something went wrong", message: " Looks like email or password is uncurrect", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .cancel))
        present(alert, animated: true)
    }
    
}

extension LogInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }  else if textField == passwordField {
            didTapLogin()
        }
        return true
    }
}
extension LogInViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        // no operation
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Failed to log in with facebook")
            return
        }
        
        let faceBookRequest = FBSDKLoginKit.GraphRequest(
            graphPath: "me",
            parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
            tokenString: token,
            version: nil,
            httpMethod: .get)
        
        faceBookRequest.start { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Faild to creat facebook Requslt ")
                return
            }
            print(result)
            
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String: Any],
                  let data = picture["data"] as? [String: Any],
                  let pictureUrl = data["url"] as? String
            else {
                print("Failed to get email and name from result")
                return
            }
            UserDefaults.standard.set(email, forKey: "email")
            DatabaseManager.shared.userExist(with: email) { exists in
                if !exists {
                    let chatUser = ChatAppUser(
                    firstName: firstName,
                    lastName: lastName,
                    emailAdress: email)
                 DatabaseManager.shared.insertUser(with: chatUser ) { success in
                     if success {
                         // upload image
                         guard let url = URL(string: pictureUrl) else {
                             return
                         }
                         print("Downloading data from facebook")
                         URLSession.shared.dataTask(with: url) { data, _, _ in
                             guard let data = data else {
                                 print("Failed to get data from FB")
                                 return
                             }
                             print("got data from FB uploading ... ")
                             let fileName = chatUser.profilePictureFileName
                             StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName) { result in
                                 switch result {
                                 case .success(let downloadUrl):
                                     UserDefaults.standard.setValue(downloadUrl, forKey: "profile_picture.png")
                                     print(downloadUrl)
                                 case .failure(let error):
                                     print( "Failed to download \(error)")
                                 }
                             }
                         }.resume()
                     }
                 }
             }
            }
            let credention = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credention) { [weak self] authREsults, error in
                guard let strongSelf = self else {
                    return
                }
                guard authREsults != nil,  error == nil else {
                    if let error = error {
                        print("facebook credential login failed \(error)")
                    }
                    
                    return
                }
                print("Succeessfully loged in with facebook")
                strongSelf.navigationController?.dismiss(animated: true)
            }
            
        }
        
    }
    
}
