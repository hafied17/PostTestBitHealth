//
//  DetailViewController.swift
//  PostTestBitHealth
//
//  Created by Hafied on 02/11/23.
//

import UIKit
import Alamofire
import SDWebImage

class DetailViewController: UIViewController {
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    
    var idMeal: String = ""
    var urlImage: String = ""
    
    let mealService = MealService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        fetchAPI()
    }


    func setupUI() {
        let mealImageGesture = UITapGestureRecognizer(target: self, action: #selector(tapHeaderImageAction))
        mealImage.isUserInteractionEnabled = true
        mealImage.addGestureRecognizer(mealImageGesture)
    }
    
    func fetchAPI() {
        mealService.getMeal(slug: "lookup.php?i=\(idMeal)") { result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.mealImage.sd_setImage(with: URL(string: data.meals[0].strMealThumb))
                    self.titleTextLabel.text = data.meals[0].strMeal
                    self.categoryLabel.text = data.meals[0].strCategory
                    self.countryLabel.text = data.meals[0].strArea
                    self.instructionLabel.text = data.meals[0].strInstructions
                    self.urlImage = data.meals[0].strMealThumb
                }
            case .failure(let error):
                print("error \(error)")
            }
        }
        
    }
    
    @objc func tapHeaderImageAction() {
        let vc = FullScreenImageViewController()
        vc.urlImage = self.urlImage
        present(vc, animated: true)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }

}
