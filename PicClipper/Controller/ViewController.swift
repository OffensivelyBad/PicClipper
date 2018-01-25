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
    @IBOutlet weak var blurSlider: UISlider!
    var inputImage: UIImage?
    var detectedFaces = [(observation: VNFaceObservation, blur: Bool)]()
    var isShowingFaceRects = true
    var blurValue: NSNumber = 12.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        addBlurRects()
    }

    func setupView() {
        // Create bar button items
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(ViewController.importPhoto))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(ViewController.shareImage))
        
        // Add a gesture to hide the red rects
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ViewController.showFaceRects))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func showFaceRects() {
        self.isShowingFaceRects = !self.isShowingFaceRects
        for subview in self.imageView.subviews {
            subview.isHidden = !self.isShowingFaceRects
        }
    }
    
    @objc func importPhoto() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        // Only redraw the image if the change in value is more than 1
        guard let blurFloat = self.blurValue as? Float else { return }
        guard sender.value > blurFloat + 1 || sender.value < blurFloat - 1 else { return }
        self.blurValue = sender.value as NSNumber
        guard let image = self.inputImage else { return }
        displayBlurredImage(from: image)
    }

}

// MARK: - Facial detection
extension ViewController {
    
    func detectFaces(in image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }
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
            let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.faceTapped(_:)))
            newView.addGestureRecognizer(tap)
        }
    }
    
    func renderBlurredImage(from image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(self.blurValue, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return nil }
        return UIImage(ciImage: outputImage)
    }
    
    func displayBlurredImage(from image: UIImage) {
        guard let blurredImage = renderBlurredImage(from: image) else { return }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let result = renderer.image { ctx in
            // Draw the original image first
            image.draw(at: .zero)
            
            // Create an empty clipping path to hold the cutouts
            let path = UIBezierPath()
            
            for face in self.detectedFaces {
                guard face.blur else { continue }
                
                // Get the position of this face in the image coordinates
                let boundingBox = face.observation.boundingBox
                let size = CGSize(width: boundingBox.width * image.size.width, height: boundingBox.height * image.size.height)
                let origin = CGPoint(x: boundingBox.minX * image.size.width, y: (1 - face.observation.boundingBox.minY) * image.size.height - size.height)
                let rect = CGRect(origin: origin, size: size)
                
                // Convert the coordinates to a path and add to the clipping path
                let miniPath = UIBezierPath(rect: rect)
                path.append(miniPath)
            }
            
            if !path.isEmpty {
                path.addClip()
                blurredImage.draw(at: .zero)
            }
        }
        
        self.imageView.image = result
    }
    
    @objc func faceTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view, let image = self.inputImage else { return }
        self.detectedFaces[tappedView.tag].blur = !detectedFaces[tappedView.tag].blur
        displayBlurredImage(from: image)
    }
    
}

// MARK: - Sharing
extension ViewController {
    
    @objc func shareImage() {
        guard let image = self.imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        self.imageView.image = image
        self.inputImage = image
        dismiss(animated: true) {
            self.detectFaces(in: image)
        }
    }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
    
}
