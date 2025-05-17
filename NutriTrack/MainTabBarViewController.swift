import UIKit

class MainTabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TabBar rengi ve diğer özellikleri ayarlama
        tabBar.tintColor = .systemGreen  // Seçili item rengi
        tabBar.unselectedItemTintColor = .gray  // Seçili olmayan item rengi
        tabBar.backgroundColor = .white  // TabBar'ın arka plan rengi
        
        // Sistem ikonlarıyla tab bar item'larını ayarlama
        setupTabBarItems()
    }

    // Sistem ikonlarıyla TabBarItem ikonları ve başlıkları ayarlama
    func setupTabBarItems() {
        // Ana Sayfa tab item'ı
        if let homeVC = self.viewControllers?[0] {
            homeVC.tabBarItem = UITabBarItem(
                title: "Ana Sayfa",
                image: UIImage(systemName: "house.fill"),  // Sistem ikonu
                selectedImage: UIImage(systemName: "house.fill")  // Seçili ikonu
            )
        }
        
        // Hedef tab item'ı
        if let targetVC = self.viewControllers?[1] {
            targetVC.tabBarItem = UITabBarItem(
                title: "Hedef",
                image: UIImage(systemName: "target"),  // Sistem ikonu
                selectedImage: UIImage(systemName: "target.fill")  // Seçili ikonu
            )
        }
        
        // Geçmiş tab item'ı
        if let historyVC = self.viewControllers?[2] {
            historyVC.tabBarItem = UITabBarItem(
                title: "Geçmiş",
                image: UIImage(systemName: "clock.fill"),  // Sistem ikonu
                selectedImage: UIImage(systemName: "clock.fill")  // Seçili ikonu
            )
        }
    }

    // Tab item'ına tıklanıldığında yapılacak işlemleri burada tanımlıyoruz
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Hangi tab item'ına tıklanıldığını kontrol et
        if let selectedIndex = tabBar.items?.firstIndex(of: item) {
            switch selectedIndex {
            case 0:
                print("Ana Sayfa seçildi")
            case 1:
                print("Hedef seçildi")
            case 2:
                print("Geçmiş seçildi")
            default:
                break
            }
        }
    }
}

