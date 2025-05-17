import UIKit
import FirebaseFirestore
import FirebaseAuth

class FoodSelectionViewController: UIViewController {

    @IBOutlet weak var categorySegmentedControl: UISegmentedControl!
    @IBOutlet weak var foodTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    var selectedMealType: String?
    var selectedCategory: String = "Yemekler"
    var allFoods: [String: [String: Any]] = [:]
    var filteredFoods: [(name: String, data: [String: Any])] = []
    var selectedUnit = "Gram"
    var searchText: String = ""  // Arama metni

    override func viewDidLoad() {
        super.viewDidLoad()
        foodTableView.delegate = self
        foodTableView.dataSource = self
        loadFoodData()
        filterFoods()
    }

    // Kategori değiştirme
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0:
                selectedCategory = "Yemekler"
            case 1:
                selectedCategory = "Tatlılar"
            case 2:
                selectedCategory = "Atıştırmalıklar"
            case 3:
                selectedCategory = "İçecek"
            default:
                selectedCategory = "Yemekler"
        }
        filterFoods()
    }

    // JSON'dan yemekleri yükleme
    func loadFoodData() {
        if let url = Bundle.main.url(forResource: "foodData", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
            self.allFoods = json
        }
    }

    // Yemekleri filtreleme
    func filterFoods() {
        filteredFoods = allFoods.compactMap { (key, value) -> (String, [String: Any])? in
            guard let category = value["category"] as? String else { return nil }

            let isIncluded: Bool
            switch selectedCategory {
            case "Yemekler":
                isIncluded = ["Ana Yemek", "Çorba", "Salata", "Kahvaltılık", "Vegan"].contains(category)
            case "Tatlılar":
                isIncluded = category == "Tatlı"
            case "Atıştırmalıklar":
                isIncluded = category == "Ara Öğün"
            case "İçecek":
                isIncluded = category == "İçecek"
            default:
                isIncluded = false
            }

            if !searchText.isEmpty {
                let lowercasedSearchText = searchText.lowercased()
                let foodName = key.lowercased()
                if !foodName.contains(lowercasedSearchText) {
                    return nil
                }
            }

            return isIncluded ? (key, value) : nil
        }
        foodTableView.reloadData()
    }

    // Yemek ekleme formu
    func showAmountInput(for foodName: String, foodData: [String: Any]) {
        let alert = UIAlertController(title: foodName, message: nil, preferredStyle: .alert)

        let units = ["Gram", "Tabak", "Bardak", "Adet"]
        let selectedUnit = units[0]

        alert.addTextField { textField in
            textField.placeholder = "Miktar (örn: 1)"
            textField.keyboardType = .decimalPad
        }

        alert.addTextField { textField in
            textField.placeholder = "Birim Seç"
            textField.text = selectedUnit

            let pickerView = UIPickerView()
            pickerView.delegate = self
            pickerView.dataSource = self
            pickerView.tag = 1000
            textField.inputView = pickerView
        }

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Kaydet", style: .default, handler: { _ in
            guard let amountText = alert.textFields?[0].text,
                  let amount = Double(amountText),
                  let unit = alert.textFields?[1].text else { return }
            self.saveFoodToFirebase(foodName: foodName, foodData: foodData, amount: amount, unit: unit)
        }))

        self.present(alert, animated: true)
    }

    func saveFoodToFirebase(foodName: String, foodData: [String: Any], amount: Double, unit: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let unitMultipliers: [String: Double] = ["Gram": 1.0, "Tabak": 250.0, "Bardak": 200.0, "Adet": 100.0]
        let gram = (unitMultipliers[unit] ?? 1.0) * amount
        let multiplier = gram / 100.0

        let calories = (foodData["calories_per_100g"] as? Double ?? 0) * multiplier
        let protein = (foodData["protein_per_100g"] as? Double ?? 0) * multiplier
        let fat = (foodData["fat_per_100g"] as? Double ?? 0) * multiplier
        let carbs = (foodData["carbs_per_100g"] as? Double ?? 0) * multiplier

        let db = Firestore.firestore()
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)

        let foodEntry: [String: Any] = [
            "food": foodName,
            "amount": amount,
            "unit": unit,
            "calories": calories,
            "protein": protein,
            "fat": fat,
            "carbs": carbs,
            "timestamp": FieldValue.serverTimestamp()
        ]

        db.collection("users").document(userID)
            .collection("meals").document(today)
            .collection(selectedMealType ?? "Öğün")
            .addDocument(data: foodEntry) { error in
                if let error = error {
                    print("Hata: \(error.localizedDescription)")
                } else {
                    print("✅ Yiyecek kaydedildi!")
                    self.navigationController?.popViewController(animated: true)
                }
            }
    }
}

extension FoodSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFoods.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let food = filteredFoods[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FoodCell", for: indexPath)
        cell.textLabel?.text = food.name
        if let calories = food.data["calories_per_100g"] as? Double {
            cell.detailTextLabel?.text = "\(calories) kcal / 100g"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let food = filteredFoods[indexPath.row]
        showAmountInput(for: food.name, foodData: food.data)
    }
}

extension FoodSelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filterFoods()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        filterFoods()
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}

extension FoodSelectionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { return 4 }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return ["Gram", "Tabak", "Bardak", "Adet"][row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let unit = ["Gram", "Tabak", "Bardak", "Adet"][row]
        if let alert = self.presentedViewController as? UIAlertController,
           let unitField = alert.textFields?[1] {
            unitField.text = unit
        }
    }
}

