import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
   
 
   
    @IBOutlet weak var updateProfileButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Email ve şifreyi UI'ye bağlama
        if let user = Auth.auth().currentUser {
            emailLabel.text = "E-posta: \(user.email ?? "Bilinmiyor")"
        }
        
        // Profil güncelleme ve çıkış yapma butonlarının stillerini ayarlıyoruz
        setupButtonStyles()
    }
    
    // Buton stillerini ayarlama
    func setupButtonStyles() {
        updateProfileButton.layer.cornerRadius = 8
        updateProfileButton.clipsToBounds = true
        
        logoutButton.layer.cornerRadius = 8
        logoutButton.clipsToBounds = true
        
        settingsButton.layer.cornerRadius = 8
        settingsButton.clipsToBounds = true
    }
    
    // Profil güncelleme butonuna tıklama
    @IBAction func profileUpdateTapped(_ sender: UIButton) {
        // Profil güncelleme işlemini burada başlatabiliriz. Örneğin, yeni bir ekran açılabilir.
        print("Profil güncelleme işlemi başlatıldı.")
    }
    
    // Çıkış yapma butonuna tıklama
    @IBAction func signOutTapped(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            // Çıkış yaptıktan sonra başka bir sayfaya yönlendirebilirsiniz (örneğin, login ekranı)
            print("Başarıyla çıkış yapıldı.")
            // Login ekranına yönlendirme yapılabilir:
            // self.navigationController?.popToRootViewController(animated: true)
        } catch let error {
            print("Çıkış yaparken hata oluştu: \(error.localizedDescription)")
        }
    }
    
    // Ayarlar butonuna tıklama (isteğe bağlı)
    @IBAction func settingsTapped(_ sender: UIButton) {
        // Ayarlar ekranını açabilirsiniz.
        print("Ayarlar butonuna tıklanıldı.")
    }
}


