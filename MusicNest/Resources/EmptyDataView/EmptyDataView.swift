//
//  EmptyDataView.swift
//  AIChatBot
//
//  Created by EMP on 25/04/2024.
//

import Foundation
import UIKit

class EmptyDataView: UIView {
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "No record found on this date"
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
//        label.font = AppFonts.secondary(ofSize: 14)//UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    private func setupViews() {
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 16), // Adjust constant as needed
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16) // Adjust constant as needed
        ])
    }
    
    func updateLabel(text: String, color: UIColor) {
        messageLabel.alpha = 0 // Start transparent
        messageLabel.text = text
        messageLabel.textColor = color
        
        UIView.animate(withDuration: 0.3) {
            self.messageLabel.alpha = 1 // Fade in
        }
    }
}
