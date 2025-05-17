import UIKit
import FirebaseFirestore
import FirebaseAuth
import DGCharts // Eğer DGCharts kullanıyorsanız

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var carbsLabel: UILabel!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var proteinLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var previousDayButton: UIButton!
    @IBOutlet weak var nextDayButton: UIButton!
    @IBOutlet weak var totalCaloriesLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView! // PieChartView IBOutlet'ı
    
    var displayedDate = Date()

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView(for: displayedDate)
    }

    func updateView(for date: Date) {
        dateLabel.text = formattedDate(date)
        fetchMacronutrients(for: date)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM.yyyy"
        return formatter.string(from: date)
    }

    func fetchMacronutrients(for date: Date) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let dateString = formattedDate(date)
        let db = Firestore.firestore()

        var totalCarbs = 0.0
        var totalFat = 0.0
        var totalProtein = 0.0
        var totalCalories = 0.0

        let mealTypes = ["Sabah", "Öğle", "Akşam", "Ara Öğün"]
        let group = DispatchGroup()

        for mealType in mealTypes {
            group.enter()
            db.collection("users").document(userID)
                .collection("meals").document(dateString)
                .collection(mealType).getDocuments { snapshot, error in
                    if let error = error {
                        print("Veri çekme hatası: \(error.localizedDescription)")
                    }

                    snapshot?.documents.forEach {
                        let data = $0.data()

                        // Besin değerlerini al
                        let carbs = data["carbs"] as? Double ?? 0
                        let fat = data["fat"] as? Double ?? 0
                        let protein = data["protein"] as? Double ?? 0
                        let calories = data["calories"] as? Double ?? 0

                        totalCarbs += carbs
                        totalFat += fat
                        totalProtein += protein
                        totalCalories += calories
                    }
                    group.leave()
                }
        }

        group.notify(queue: .main) {
            self.updateMacronutrientLabels(totalCarbs: totalCarbs, totalFat: totalFat, totalProtein: totalProtein)
            self.updatePieChart(carbs: totalCarbs, fat: totalFat, protein: totalProtein) // Pie chart'ı güncelle
            self.totalCaloriesLabel.text = "Toplam: \(Int(totalCalories)) kcal"  // Günlük toplam kalori
        }
    }

    func updateMacronutrientLabels(totalCarbs: Double, totalFat: Double, totalProtein: Double) {
        carbsLabel.text = "Karbonhidrat: \(Int(totalCarbs))g"
        fatLabel.text = "Yağ: \(Int(totalFat))g"
        proteinLabel.text = "Protein: \(Int(totalProtein))g"
    }

    func updatePieChart(carbs: Double, fat: Double, protein: Double) {
        var dataEntries: [PieChartDataEntry] = []

        let carbsEntry = PieChartDataEntry(value: carbs, label: "Karbonhidrat")
        let fatEntry = PieChartDataEntry(value: fat, label: "Yağ")
        let proteinEntry = PieChartDataEntry(value: protein, label: "Protein")
        
        dataEntries.append(carbsEntry)
        dataEntries.append(fatEntry)
        dataEntries.append(proteinEntry)
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "Makro Besinler")
        dataSet.colors = [
            UIColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0), // Pastel yeşil
            UIColor(red: 1.0, green: 0.8, blue: 0.4, alpha: 1.0), // Pastel sarı
            UIColor(red: 0.7, green: 0.6, blue: 0.9, alpha: 1.0)  // Pastel mor
        ] // Besin öğeleri için renkler
        let data = PieChartData(dataSet: dataSet)

        pieChartView.data = data
        pieChartView.notifyDataSetChanged()  // Pie chart'ı güncelle
    }

    @IBAction func previousDayTapped(_ sender: UIButton) {
        displayedDate = Calendar.current.date(byAdding: .day, value: -1, to: displayedDate) ?? displayedDate
        updateView(for: displayedDate)
    }

    @IBAction func nextDayTapped(_ sender: UIButton) {
        displayedDate = Calendar.current.date(byAdding: .day, value: 1, to: displayedDate) ?? displayedDate
        updateView(for: displayedDate)
    }
}

