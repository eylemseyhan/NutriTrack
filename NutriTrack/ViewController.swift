//
//  ViewController.swift
//  NutriTrack
//
//  Created by Eylem Seyhan on 28.04.2025.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Şifre alanını yıldızlı (secure) hale getirelim
        passwordTextField.isSecureTextEntry = true
    }

    @IBOutlet weak var loginTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        // Email ve şifre boş mu kontrol edelim
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email veya Şifre boş!")
            return
        }
        
        // Firebase ile giriş yap
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Giriş Hatası: \(error.localizedDescription)")
            } else {
                print("Giriş Başarılı!")
                
                // Giriş başarılıysa Hedef Belirleme ekranına geçelim
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                        // Dashboard sekmesi seçili
                        tabBarVC.selectedIndex = 0
                        self.navigationController?.pushViewController(tabBarVC, animated: true)
                    
                    }
                }

            }
        }
    }

    @IBAction func registerButtonTapped(_ sender: UIButton) {
        // Storyboard'dan RegisterViewController'ı bul
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as? RegisterViewController {
            navigationController?.pushViewController(registerVC, animated: true)
        }
    }

    
}

