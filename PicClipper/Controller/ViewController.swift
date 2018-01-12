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
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch {
            print(error.localizedDescription)
        }
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
