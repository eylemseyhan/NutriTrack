import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func registerButtonTapped(_ sender: UIButton) {
        // Email ve şifre boş mu kontrol edelim
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            print("Email veya Şifre boş!")
            return
        }
        
        // Firebase ile kullanıcı kaydı
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Hata oluştu: \(error.localizedDescription)")
            } else {
                print("Kullanıcı başarıyla oluşturuldu!")
                
                // Kullanıcı kayıt olduysa Hedef Belirleme ekranına git
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let calorieGoalVC = storyboard.instantiateViewController(withIdentifier: "CalorieGoalViewController") as? CalorieGoalViewController {
                    self.navigationController?.pushViewController(calorieGoalVC, animated: true)
                }
            }
        }
    }

}

