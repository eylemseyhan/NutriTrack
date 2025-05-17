import UIKit
import FirebaseAuth
import FirebaseFirestore

class GoalViewController: UIViewController {
    
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
   

    @IBOutlet weak var calorieValueLabel: UILabel!
    var currentGoal: Int = 1000 {
        didSet {
            calorieValueLabel.text = "Kalori: \(currentGoal)"
        }
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            setupStepper()
            fetchCurrentGoal()
            calorieValueLabel.text = "Kalori: \(currentGoal)" // ✅ Ekran ilk yüklendiğinde göster
        }


    func setupStepper() {
        stepper.minimumValue = 100
        stepper.maximumValue = 10000
        stepper.stepValue = 50
    }

    func fetchCurrentGoal() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(userID).getDocument { snapshot, error in
            if let data = snapshot?.data(), let goal = data["calorieGoal"] as? Int {
                self.currentGoal = goal
                self.stepper.value = Double(goal)
            }
        }
    }

    @IBAction func stepperChanged(_ sender: UIStepper) {
        currentGoal = Int(sender.value)
    }

    @IBAction func saveGoalTapped(_ sender: UIButton) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore().collection("users").document(userID).setData([
            "calorieGoal": currentGoal
        ], merge: true) { error in
            if let error = error {
                print("❌ Güncelleme hatası: \(error.localizedDescription)")
            } else {
                print("✅ Hedef başarıyla güncellendi: \(self.currentGoal) kcal")
                // 🎉 Başarı alerti
                            let alert = UIAlertController(title: "🎯 Güncellendi!", message: "Hedefiniz başarıyla güncellendi.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                            self.present(alert, animated: true)
                
                
            }
        }
    }
}

