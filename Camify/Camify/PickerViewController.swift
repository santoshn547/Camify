//
//  PickerViewController.swift
//  Camify
//
//  Created by Santosh on 03/12/18.
//  Copyright © 2018 iwabsolutions. All rights reserved.
//

import UIKit
import AVFoundation
import ImagePicker


class PickerViewController: UIViewController,ImagePickerDelegate {
    
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let configuration = Configuration()
        configuration.doneButtonTitle = "Done"
        configuration.noImagesTitle = "Sorry! There are no images here!"
        configuration.cancelButtonTitle = ""
        configuration.recordLocation = false
        
        let imagePicker = ImagePickerController(configuration: configuration)
        imagePicker.delegate = self
        imagePicker.imageLimit = 10
        present(imagePicker, animated: false, completion: nil)
    }
    
    
    @IBAction func pick(_ sender: Any) {
      //  setupPicker()
        
    }
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        print("didPressLeftOption")
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {        
        var topController = UIApplication.shared.keyWindow!.rootViewController
        
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController!;
        }
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
        vc.image = images[0]
        vc.imagesArray = images
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        UIApplication.shared.keyWindow!.layer.add(transition, forKey: kCATransition)
        topController?.present(vc, animated:false, completion:nil)
        //self.dismiss(animated: true, completion: nil)

    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        print("cancel")
        //self.dismiss(animated: false, completion: nil)
    }
}
