//
//  ViewController.swift
//  AsyncAwaitQueue
//
//  Created by Orlando Ortega on 04/10/21.
//

import UIKit

let apiCall = "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/"

class ViewController: UIViewController {
    
    //MARK: - Properties
    private let imgView: UIImageView = {
        let image = UIImage()
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    private let imageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        execute()
    }
    
    //MARK: - Configurations
    func configureUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(imgView)
        imgView.centerX(inView: view)
        imgView.setDimensions(height: 500, width: view.frame.width - 64)
        imgView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)

        view.addSubview(imageLabel)
        imageLabel.centerX(inView: view)
        imageLabel.anchor(top: imgView.bottomAnchor, paddingTop: 24)
    }
    
    //MARK: - Functions
    
    func downloadImageAndMetadata(imageNumber: Int,
        completionHandler: @escaping (_ detailedImage: DetailedImage?, _ error: Error?) -> Void) {
        
        let imageUrl = URL(string: apiCall + "\(imageNumber).png")!
        
        DispatchQueue.global(qos: .background).async {
            let imageTask = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                guard let data = data, let image = UIImage(data: data), (response as? HTTPURLResponse)?.statusCode == 200 else {
                    completionHandler(nil, ImageDownloadError.badImage)
                    return
                }
                let metadataUrl = URL(string: apiCall + "\(imageNumber).json")!
                let metadataTask = URLSession.shared.dataTask(with: metadataUrl) { data, response, error in
                    guard let data = data, let metadata = try? JSONDecoder().decode(ImageMetadata.self, from: data),
                            (response as? HTTPURLResponse)?.statusCode == 200 else {
                        completionHandler(nil, ImageDownloadError.invalidMetadata)
                        return
                    }
                    let detailedImage = DetailedImage(image: image, metadata: metadata)
                    completionHandler(detailedImage, nil)
                }
                metadataTask.resume()
            }
            imageTask.resume()
        }
    }
    
    func execute() {
        downloadImageAndMetadata(imageNumber: 1) { detailedImage, error in
            if let detailedImage = detailedImage {
                DispatchQueue.main.async {
                    self.imgView.image = detailedImage.image
                    self.imageLabel.text = "\(detailedImage.metadata.name), \(detailedImage.metadata.firstAppearance), \(detailedImage.metadata.year)"
                }
            }
        }
    }
}

