import UIKit
import FirebaseFirestore
import FirebaseAuth

class CalorieGoalViewController: UIViewController {
    
    @IBOutlet weak var calorieBoxView: UIView!


    
   
    @IBOutlet weak var calorieStepper: UIStepper!
    @IBOutlet weak var calorieLabel: UILabel!
    override func viewDidLoad() {
        
        calorieBoxView.layer.cornerRadius = 16
        calorieBoxView.clipsToBounds = true
        super.viewDidLoad()
        
        calorieStepper.minimumValue = 0
        calorieStepper.maximumValue = 5000
        calorieStepper.stepValue = 50
        calorieLabel.text = "Kalori: \(Int(calorieStepper.value))"
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        calorieLabel.text = "Kalori: \(Int(sender.value))"
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let calorieGoal = Int(calorieStepper.value)
        
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData([
            "calorieGoal": calorieGoal
        ], merge: true) { error in
            if let error = error {
                print("Hedef kaydedilirken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Kalori hedefi başarıyla kaydedildi! ✅")
                
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let dashboardVC = storyboard.instantiateViewController(withIdentifier: "DashboardViewController") as? DashboardViewController {
                        self.navigationController?.pushViewController(dashboardVC, animated: true)
                    }
                }

            }
        }
    }
}

