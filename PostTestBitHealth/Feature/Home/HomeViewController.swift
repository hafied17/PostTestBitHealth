//
//  HomeViewController.swift
//  PostTestBitHealth
//
//  Created by Hafied on 01/11/23.
//

import UIKit
import Alamofire
import SDWebImage

class HomeViewController: UIViewController {

    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var contentTable: UITableView!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    
    var meals = [DataMealModel]()
    var mealsFiltered = [DataMealModel]()
    let searchController = UISearchController()
    let mealService = MealService()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        navBarAppearance.backgroundColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = UIColor.black
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.isNavigationBarHidden = false
        navigationItem.setHidesBackButton(true, animated: true)

    }


    func setupUI() {
        fetchAPI(nameOfMeal: "a")
        let name = UserDefaults.standard.string(forKey: "nameUser") ?? ""
        userLabel.text = "Hi, \(name)"

        
        contentTable.register(UINib(nibName: "ContentCell", bundle: nil), forCellReuseIdentifier: "cell")
        contentTable.delegate = self
        contentTable.dataSource = self
        contentTable.rowHeight = 130
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.barTintColor = UIColor.gray
        searchController.searchBar.backgroundColor = UIColor.white
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.searchController = searchController
        navigationItem.title = "List of Meals"
    }
    
    func fetchAPI(nameOfMeal: String) {
        mealService.getMeal(slug: "search.php?f=\(nameOfMeal)") { result in
            switch result {
            case .success(let data):
                self.meals = data.meals
                self.mealsFiltered = data.meals
                DispatchQueue.main.async {
                    self.contentTable.reloadData()
                    self.checkNoData()
                }
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
    func checkNoData() {
        if mealsFiltered.isEmpty {
            noDataView.isHidden = false
        } else {
            noDataView.isHidden = true
        }
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Logout?", message: "Are you sure you want to log out? You can access your content by logging in", preferredStyle: .actionSheet)
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .default)
        let alertActionLogout = UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.resetDefaults()
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(alertActionLogout)
        alert.addAction(alertActionCancel)

        present(alert, animated: true)
        
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mealsFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContentCell
        cell.imageFood.layer.cornerRadius = 8
        cell.imageFood.sd_setImage(with: URL(string: mealsFiltered[indexPath.row].strMealThumb))
        cell.titleTextLabel.text = mealsFiltered[indexPath.row].strMeal
        cell.descLabel.text = mealsFiltered[indexPath.row].strCategory
        cell.countryLabel.text = mealsFiltered[indexPath.row].strArea
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contentTable.deselectRow(at: indexPath, animated: true)
        let vc = DetailViewController()
        vc.idMeal = mealsFiltered[indexPath.row].idMeal
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text == "" {
            fetchAPI(nameOfMeal: "a")

        } else {
            fetchAPI(nameOfMeal: (text.first!.lowercased()))

        }
        checkNoData()
        contentTable.reloadData()
    }
    
}
