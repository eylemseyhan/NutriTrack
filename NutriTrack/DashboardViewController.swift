import UIKit
import FirebaseAuth
import FirebaseFirestore
import Charts

class DashboardViewController: UIViewController {
    
    // IBOutlet'lar
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var sabahImageView: UIImageView!
    @IBOutlet weak var ogleImageView: UIImageView!
    @IBOutlet weak var aksamImageView: UIImageView!
    @IBOutlet weak var araOgunImageView: UIImageView!
    @IBOutlet weak var calorieProgressView: UIProgressView!
    @IBOutlet weak var calorieProgressLabel: UILabel!
    @IBOutlet weak var todayMealsTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var calorieGoal: Int?
    var totalCalories: Int = 0 // Günlük alınan toplam kalori

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDateLabel()
        setupImageTapGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCalorieGoal()
    }

    func setupDateLabel() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy EEEE"
        dateLabel.text = formatter.string(from: Date())
    }

    func setupImageTapGestures() {
        let gestures = [
            (sabahImageView, #selector(sabahTapped)),
            (ogleImageView, #selector(ogleTapped)),
            (aksamImageView, #selector(aksamTapped)),
            (araOgunImageView, #selector(araOgunTapped))
        ]

        for (imageView, selector) in gestures {
            imageView?.isUserInteractionEnabled = true
            imageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: selector))
        }
    }

    @objc func sabahTapped() { navigateToMealDetail(mealType: "Sabah") }
    @objc func ogleTapped() { navigateToMealDetail(mealType: "Öğle") }
    @objc func aksamTapped() { navigateToMealDetail(mealType: "Akşam") }
    @objc func araOgunTapped() { navigateToMealDetail(mealType: "Ara Öğün") }

    func navigateToMealDetail(mealType: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "MealDetailViewController") as? MealDetailViewController {
            detailVC.selectedMealType = mealType
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func fetchCalorieGoal() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(userID).getDocument { doc, error in
            if let doc = doc, doc.exists, let goal = doc.data()?["calorieGoal"] as? Int {
                self.calorieGoal = goal
                self.goalLabel.text = "Hedef: \(goal) kcal"
                self.fetchDailyCalories()
            } else {
                self.goalLabel.text = "Hedef bulunamadı"
            }
        }
    }

    func fetchDailyCalories() {
        guard let userID = Auth.auth().currentUser?.uid,
              let goal = calorieGoal else { return }

        let dateKey = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let meals = ["Sabah", "Öğle", "Akşam", "Ara Öğün"]
        let db = Firestore.firestore()
        var total = 0
        let group = DispatchGroup()

        for meal in meals {
            group.enter()
            db.collection("users").document(userID)
              .collection("meals").document(dateKey)
              .collection(meal).getDocuments { snapshot, _ in
                  snapshot?.documents.forEach {
                      let data = $0.data()
                      total += Int(data["calories"] as? Double ?? 0)
                  }
                  group.leave()
              }
        }

        group.notify(queue: .main) {
            // Günlük alınan toplam kaloriyi güncelliyoruz
            self.totalCalories = total
            
            // Kalori hedefi ve günlük alınan kalori kıyaslaması
            let progress = min(Float(total) / Float(goal), 1.0)
            self.calorieProgressView.setProgress(progress, animated: true)
            self.calorieProgressLabel.text = "\(total) / \(goal) kcal"
            
            // Kalori hedefini geçtiğinde renk değişimi yapalım
            if total > goal {
                self.calorieProgressView.progressTintColor = .red
                self.calorieProgressLabel.text = "Hedefi Aştınız! \(total) kcal"
            } else {
                self.calorieProgressView.progressTintColor = .green
            }
        }
    }
}

