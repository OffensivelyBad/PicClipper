//
//  ViewController.swift
//  PicClipper
//
//  Created by Shawn Roller on 1/12/18.
//  Copyright © 2018 Shawn Roller. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var inputImage: UIImage?
    var detectedFaces = [(observation: VNFaceObservation, blur: Bool)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBlurRects()
    }

    func setupView() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(ViewController.importPhoto))
    }
    
    @objc func importPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

}

// MARK: - Facial detection
extension ViewController {
    
    func detectFaces() {
        guard let inputImage = self.inputImage else { return }
        guard let ciImage = CIImage(image: inputImage) else { return }
        let request = VNDetectFaceRectanglesRequest { [unowned self] request, error in
            guard error == nil else {
                print(error?.localizedDescription ?? "An Error Occurred")
                return
            }
            guard let observations = request.results as? [VNFaceObservation] else { return }
            self.detectedFaces = Array(zip(observations, [Bool](repeating: false, count: observations.count)))
            self.addBlurRects()
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addBlurRects() {
        // Remove existing face rectangles
        self.imageView.subviews.forEach { $0.removeFromSuperview() }
        
        // Find the size of the image inside the imageview
        let imageRect = self.imageView.contentClippingRect
        
        // Loop over the faces that were detected
        for (index, face) in self.detectedFaces.enumerated() {
            // Get the face position
            let boundingBox = face.observation.boundingBox
            
            // Calculate its size
            let size = CGSize(width: boundingBox.width * imageRect.width, height: boundingBox.height * imageRect.height)
            
            // Calculate its position
            var origin = CGPoint(x: boundingBox.minX * imageRect.width, y: (1 - face.observation.boundingBox.minY) * imageRect.height - size.height)
            
            // Offset the position based on the content clipping rect
            origin.y += imageRect.minY
            
            // Place a view there
            let newView = UIView(frame: CGRect(origin: origin, size: size))
            
            // Store the face number as its tag
            newView.tag = index
            
            // Color the border red and add the new view
            newView.layer.borderColor = UIColor.red.cgColor
            newView.layer.borderWidth = 2
            self.imageView.addSubview(newView)
        }
    }
    
    func renderBlurredFaces() {
        guard let inputImage = self.inputImage else { return }
        guard let ciImage = CIImage(image: inputImage) else { return }
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(12, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return }
        let blurredImage = UIImage(ciImage: outputImage)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        self.imageView.image = image
        self.inputImage = image
        dismiss(animated: true) {
            self.detectFaces()
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
    
}
