//
//  FullScreenImageViewController.swift
//  PostTestBitHealth
//
//  Created by Investo Medika Asia on 02/11/23.
//

import UIKit
import SDWebImage

class FullScreenImageViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mealImage: UIImageView!
    
    var urlImage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        let viewGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(viewGesture)
    }

    func setupUI() {
        mealImage.sd_setImage(with: URL(string: urlImage))
        scrollView.delegate = self
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }

}

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mealImage
    }
}
