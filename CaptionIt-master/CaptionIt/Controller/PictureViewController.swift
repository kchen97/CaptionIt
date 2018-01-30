//
//  ViewController.swift
//  CaptionIt
//
//  Created by Korman Chen on 1/20/18.
//  Copyright © 2018 Korman Chen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    let microsoftURL = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/describe?"
    
    let captionDataModel = CaptionDataModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Actions
    func accessCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .camera
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func accessPhotoLibrary() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            present(myPickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Open Camera", style: .default, handler: { (alert:UIAlertAction!) in
            self.accessCamera()
        }) )
        alert.addAction(UIAlertAction(title: "Open Photo Library", style: .default, handler: { (alert:UIAlertAction!) in
            self.accessPhotoLibrary()
        }) )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        userImageView.image = image
        getImageData()
        
        dismiss(animated:true, completion: nil)
    }
    
    
    //MARK: Alamofire
    func getImageData() {
        
    let headers: HTTPHeaders = ["Ocp-Apim-Subscription-Key" : "", "Content-Type" : "application/octet-stream"]
    let imageData  = UIImageJPEGRepresentation(userImageView.image!, 1.0)!

        Alamofire.upload(imageData, to: microsoftURL, method: .post, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                print(response)
            }
        }
        
    }
    
    //JSON Parsing
    func updateCaption(json: JSON) {
        if let temp = json["description"]["captions"][0]["text"].string {
            captionDataModel.caption = json["description"]["captions"][0]["text"].stringValue
            captionDataModel.tags.append(json["description"]["tags"][0].stringValue)
            captionDataModel.tags.append(json["description"]["tags"][4].stringValue)
            print(captionDataModel.tags[1])
            updateUIWithCaptionData()
            print("hello")
        }
        else {
            print("Hello222")
            captionLabel.text = "Image too large"
        }
    }
    
    func updateUIWithCaptionData() {
        captionLabel.text = captionDataModel.caption
    }
}

