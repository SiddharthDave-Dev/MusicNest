//
//  CustomLoader.swift
//  BusinessAI
//
//  Created by Mac Mini M2 Pro on 16/05/25.
//

import UIKit
import Reusable

class CustomLoader: UIView {

    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var percentageView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var loaderView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.loaderView.cornerRadius = 10
    }

    func showLoader() {
        self.loader.startAnimating()
    }
    
    func hideLoader() {
        self.loader.stopAnimating()
    }
    
    func showPrecentage(percentage: Int) {
        self.percentageLabel.text = "\(percentage)%"
        self.percentageView.isHidden = false
    }
    
    func hidePrecentage() {
        self.percentageView.isHidden = true
    }

}
