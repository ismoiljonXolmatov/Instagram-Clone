//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Apple on 02.08.1444 (AH).
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class RegisterViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray 
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
       private let firstNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "First name.."
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
    
    private let lastNameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Last name.."
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
    
    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email.."
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
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
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        textField.leftViewMode = UITextField.ViewMode.always
        textField.backgroundColor = .systemGray6
        textField.isSecureTextEntry = true
        return textField
    }()
    
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 19, weight: .medium)
        return button
    }()
    
    private let backToLoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Aready have an accaunt ? Sign in", for: .normal)
        button.backgroundColor = .systemBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 19, weight: .bold)
        return button
    }()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Registeration"
        emailField.delegate = self
        passwordField.delegate = self
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        setUpScrollView()
        setUpButtons()
        userImageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapchangeProfilePic))
        userImageView.addGestureRecognizer(gesture)
        
    }
    @objc private func didTapchangeProfilePic() {
        presentPhotoAtionSheet()
    }
    
    private func setUpScrollView() {
        scrollView.addSubview(emailField)
        scrollView.addSubview(userImageView)
        scrollView.addSubview(firstNameField) 
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        scrollView.addSubview(backToLoginButton)
    }

    private func setUpButtons() {
        registerButton.addTarget(self, action: #selector(didTapRegister), for: .touchUpInside)
        backToLoginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        navigationItem.titleView?.tintColor = .label
    }
    @objc private func didTapLogin() {
        let vc = LogInViewController()
        vc.title = "Create an Accaunt"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/2
        userImageView.layer.cornerRadius = size/4
        userImageView.frame = CGRect(x: size/2*1.5, y: 30, width: size/2, height: size/2)
        firstNameField.frame = CGRect(x: 20, y: userImageView.bottom + 15, width: scrollView.width - 40, height: 52)
        lastNameField.frame = CGRect(x: 20, y: firstNameField.bottom + 15, width: scrollView.width - 40, height: 52)
        emailField.frame = CGRect(x: 20, y: lastNameField.bottom + 22, width: scrollView.width - 40, height: 52)
        passwordField.frame = CGRect(x: 20, y: emailField.bottom + 15, width: scrollView.width - 40, height: 52)
        registerButton.frame = CGRect(x: 20, y: passwordField.bottom + 22, width: scrollView.width - 40, height: 52)
        backToLoginButton.frame = CGRect(x: 20, y: registerButton.bottom + 22, width: scrollView.width - 40, height: 52)
    }
    
       
    @objc private func didTapRegister() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
       
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertRgisterError()
            return
        }
        spinner.show(in: view)
        DatabaseManager.shared.userExist(with: email) { [weak self]  exists in
            guard let strongSelf = self else {
                return
            }
            guard !exists else  {
                // user already exists
                strongSelf.alertRgisterError(message: "Looks like a user accaunt for that email address already exists.")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) {  athResults, error in
                 DispatchQueue.main.async {
                    strongSelf.spinner.dismiss(animated: true)
                }
                
                
                guard athResults != nil , error == nil else {
                    print("Error creating accaunt")
                    return
                }
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAdress: email)
                DatabaseManager.shared.insertUser(with:  chatUser) { success in
                    if success {
                        // upload image
                        guard let image = strongSelf.userImageView.image,
                              let data = image.pngData() else {
                            return
                        }
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
                    }
                    
                }
                strongSelf.navigationController?.dismiss(animated: true)
                
            }
        }
        
    }
    @objc private func alertRgisterError(
        title: String =  "Something went wrong" ,
        message: String = "Please enter all information to create a new accaunt") {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(
            title: "Try again",
            style: .cancel))
        present(alert, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if firstNameField == emailField {
            lastNameField.becomeFirstResponder()
        }
        else if lastNameField == passwordField {
            emailField.becomeFirstResponder()
        }
        else if emailField == passwordField {
            passwordField.becomeFirstResponder()
        }
        else if passwordField == passwordField {
            didTapRegister()
        }
        return true
    }
  
}
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoAtionSheet() {
        let actiomSheet = UIAlertController(title: "Profile picture",
                                            message: "How would you like to select a picture",
                                            preferredStyle: .actionSheet)
        actiomSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actiomSheet.addAction(UIAlertAction(title: "Take a photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actiomSheet.addAction(UIAlertAction(title: "Choose a photo from galery ", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actiomSheet, animated: true)
    }
    
    func presentCamera() {
      let vc  = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    func presentPhotoPicker() {
        let vc  = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        userImageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
