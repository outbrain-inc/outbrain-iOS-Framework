//
//  RecommendationView.swift
//  demo
//
//  Created by Leonid Lemesev on 15/08/2024.
//

import Foundation
import UIKit
import SwiftUI
import OutbrainSDK


class RecommendationView: UIView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    
    init(rec: OBRecommendation) {
        super.init(frame: .zero)
        
        setupViews()
        
        
        titleLabel.text = rec.content
        descriptionLabel.text = rec.source
        loadImage(imageURL: rec.image?.url)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    

    private func setupViews() {
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 8
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(imageView)
        addSubview(textStackView)
        
        NSLayoutConstraint.activate([
            // Image View Constraints
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100),
            
            // Text StackView Constraints
            textStackView.topAnchor.constraint(equalTo: topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            textStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            textStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor)
        ])
    }
    
    
    private func loadImage(imageURL: URL?) {
        guard let imageURL else { return }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let imageData = data, let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }.resume()
    }
}
