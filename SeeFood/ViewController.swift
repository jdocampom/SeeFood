//
//  ViewController.swift
//  SeeFood
//
//  Created by Juan Diego Ocampo on 12/25/20.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Tag: Properties
    @IBOutlet weak var imageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    // MARK:- Methods
    
    /// Tag: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }
    
    /// Tag: didFinishPickingMediaWithInfo()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageTaken = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = imageTaken
            guard let ciImage = CIImage(image: imageTaken) else {
                fatalError("Cannot conver to CIImage")
            }
            detectImage(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    /// Tag: detectImage()
    func detectImage(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Error initialising CoreML Model")
        }
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("CoreML Model could not process imageTaken")
            }
            if let firstResult = results.first {
                if firstResult.identifier.contains("hotdog") {
                    self.navigationItem.title = "It's a Hot-Dog 🌭!"
                } else {
                    self.navigationItem.title = "It's not a Hot-Dog...🙃"
                }
            }
        }
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print("Error performing request: \(error)")
        }
    }
    
    /// Tag: cameraButtonPressed()
    @IBAction func cameraButtonPressed(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}
