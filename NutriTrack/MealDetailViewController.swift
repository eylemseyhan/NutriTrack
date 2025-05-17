
import UIKit
import FirebaseFirestore
import FirebaseAuth

class MealDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var totalCaloriesLabel: UILabel!

    @IBOutlet weak var addMealButton: UIButton!

    var selectedMealType: String = ""
    var meals: [QueryDocumentSnapshot] = []
    var totalCalories: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = selectedMealType
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMealData()
    }

    @IBAction func addFoodTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let foodVC = storyboard.instantiateViewController(withIdentifier: "FoodSelectionViewController") as? FoodSelectionViewController {
            foodVC.selectedMealType = selectedMealType // Meal type bilgisi aktarılır
            self.navigationController?.pushViewController(foodVC, animated: true)
        }
    }


    func fetchMealData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let db = Firestore.firestore()

        db.collection("users").document(userID)
            .collection("meals").document(today)
            .collection(selectedMealType).getDocuments { snapshot, error in
                if let error = error {
                    print("❌ Firestore hatası: \(error.localizedDescription)")
                    return
                }

                self.meals = snapshot?.documents ?? []
                self.totalCalories = self.meals.reduce(0) {
                    $0 + Int($1.data()["calories"] as? Double ?? 0)
                }

                DispatchQueue.main.async {
                    self.totalCaloriesLabel.text = "Toplam: \(self.totalCalories) kcal"
                    self.tableView.reloadData()
                }
            }
    }

    func deleteMeal(at index: Int) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let docID = meals[index].documentID

        Firestore.firestore()
            .collection("users").document(userID)
            .collection("meals").document(today)
            .collection(selectedMealType).document(docID).delete { error in
                if let error = error {
                    print("Silme hatası: \(error.localizedDescription)")
                } else {
                    self.fetchMealData()
                }
            }
    }

    func editMeal(at index: Int) {
        let meal = meals[index]
        let data = meal.data()

        let alert = UIAlertController(title: "Yemeği Düzenle", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = "\(data["amount"] ?? 1)"; $0.keyboardType = .decimalPad }
        alert.addTextField { $0.text = data["unit"] as? String ?? "Gram" }

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Kaydet", style: .default, handler: { _ in
            guard let newAmount = Double(alert.textFields?[0].text ?? "1"),
                  let newUnit = alert.textFields?[1].text else { return }

            let multiplierMap: [String: Double] = ["Gram": 1, "Tabak": 250, "Bardak": 200, "Adet": 100]
            let gram = (multiplierMap[newUnit] ?? 1.0) * newAmount
            let mult = gram / 100.0

            let cal = (data["calories_per_100g"] as? Double ?? 0) * mult
            let prot = (data["protein_per_100g"] as? Double ?? 0) * mult
            let fat = (data["fat_per_100g"] as? Double ?? 0) * mult
            let carb = (data["carbs_per_100g"] as? Double ?? 0) * mult

            let update: [String: Any] = [
                "amount": newAmount,
                "unit": newUnit,
                "calories": cal,
                "protein": prot,
                "fat": fat,
                "carbs": carb
            ]

            Firestore.firestore()
                .collection("users").document(Auth.auth().currentUser!.uid)
                .collection("meals").document(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))
                .collection(self.selectedMealType)
                .document(meal.documentID)
                .updateData(update) { error in
                    if error == nil {
                        self.fetchMealData()
                    }
                }
        }))

        self.present(alert, animated: true)
    }
}

extension MealDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let meal = meals[indexPath.row].data()
        let amount = (meal["amount"] as? Double)?.cleanString() ?? "1"
        let unit = meal["unit"] as? String ?? "Gram"
        let food = meal["food"] as? String ?? "?"
        let cal = Int(meal["calories"] as? Double ?? 0)

        let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath)
        cell.textLabel?.text = "\(amount) \(unit) \(food) - \(cal) kcal"
        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Sil") { _, _, _ in
            self.deleteMeal(at: indexPath.row)
        }

        let edit = UIContextualAction(style: .normal, title: "Düzenle") { _, _, _ in
            self.editMeal(at: indexPath.row)
        }
        edit.backgroundColor = .orange

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
}

extension Double {
    func cleanString() -> String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(Int(self)) : String(self)
    }
}

