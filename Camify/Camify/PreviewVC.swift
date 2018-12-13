//
//  PreviewVC.swift
//  Camify
//
//  Created by Santosh on 30/11/18.
//  Copyright © 2018 iwabsolutions. All rights reserved.
//

import UIKit


class PreviewVC: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var imageToFilter: UIImageView!
    
    @IBOutlet weak var filtersScrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageScrollView: UIScrollView!
    
    var image = UIImage()
    var imagesArray = [UIImage]()
    var filteredImagesArray = [UIImage]()
    var imageViewArray = [UIImageView]()
    var labelArray = [UILabel]()
    var buttonArray = [UIButton]()
    
    var buttonIndex = 0
    
    
    
    let Filters = [
        "Normal",
        "applyNashvilleFilter",
        "applyToasterFilter",
        "apply1977Filter",
        "applyClarendonFilter",
        "applyHazeRemovalFilter",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CILinearToSRGBToneCurve"   ]
    
    let filterNames = [
        "Normal",
        "Nashville",
        "Toaster",
        "1977",
        "Clarendon",
        "HazeRemoval",
        "Chrome",
        "Fade",
        "Instant",
        "Mono",
        "Noir",
        "Process",
        "Tonal",
        "Transfer",
        "Brighten"  ]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let album = CustomAlbum.sharedInstance.fetchAssetCollectionForAlbum()
        if album == nil {
            if self.imagesArray.count == 0{
                CustomAlbum.sharedInstance.save(image: self.image)
            } else {
            CustomAlbum.sharedInstance.save(image: self.imagesArray[0])
        }
        }
        imageScrollView.delegate = self
        pageControl.numberOfPages = imagesArray.count
        if imagesArray.count > 1{
            self.addFiltersToMultipleImages()
        } else {
            self.addFilterToImage()
        }
    }
    
    
    func addFiltersToMultipleImages(){
        let coreImage = CIImage(image: self.imagesArray.first!)
        
        // Set label Properties
        let labelYCoord: CGFloat = 5
        var labelXCoord : CGFloat = 5
        let labelHeight : CGFloat = 12
        
        // Set Filter Buttons Properties
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 23
        let buttonWidth:CGFloat = 80
        let buttonHeight: CGFloat = 85
        let gapBetweenButtons: CGFloat = 8
        var itemCount = 0

        // Set image Properties
        var imageXCoord = self.originalImage.frame.minX
        let imageYCoord : CGFloat = 5
        //let gapBetweenImages: CGFloat = 10
        let imageWidth = self.originalImage.frame.width
        let imageHeight = self.originalImage.frame.height
        var imagesScrollViewWidth : CGFloat = 0
            
        
        // Add images to view for multiple images.
        if self.imagesArray.count > 1 {
            self.originalImage.removeFromSuperview()
            self.imageToFilter.removeFromSuperview()
            for i in 0..<self.imagesArray.count{
                let ogImage = UIImageView()
                let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PreviewVC.longPressedMultipleImg(sender:)))
                longPressRecognizer.minimumPressDuration = 1
                ogImage.contentMode = .scaleAspectFit
                ogImage.frame = CGRect(x: imageXCoord, y: imageYCoord, width: self.view.frame.size.width, height: imageHeight)
                ogImage.addGestureRecognizer(longPressRecognizer)
                ogImage.isUserInteractionEnabled = true
                ogImage.image = self.imagesArray[i]
                imagesScrollViewWidth += imageXCoord
                imageXCoord += imageWidth
                self.imageScrollView.addSubview(ogImage)
                self.imageViewArray.append(ogImage)
                self.filteredImagesArray.append(ogImage.image!)
                self.imageScrollView.contentSize = CGSize(width: self.imageScrollView.frame.width * CGFloat(i + 1),height: imageHeight)
            }
           
            // Add filters for each button
            @available(iOS, deprecated: 12.0)
            let openGLContext = EAGLContext(api: .openGLES2)
            @available(iOS, deprecated: 12.0)
            let context = CIContext(eaglContext: openGLContext!)
            DispatchQueue.global(qos: .background).async {
                for i in 0..<self.Filters.count {
                    itemCount = i
                    // Filter Button properties
                    let filterButton = UIButton(type: .custom)
                    filterButton.frame = CGRect(x:xCoord,y: yCoord,width: buttonWidth,height: buttonHeight)
                    filterButton.tag = itemCount
                    filterButton.addTarget(self, action: #selector(PreviewVC.addFilterToAllImages(sender:)), for: .touchUpInside)
                    filterButton.layer.cornerRadius = 6
                    filterButton.clipsToBounds = true
                    var imageForButton = UIImage()
                    if (i == 0){
                        imageForButton = self.imagesArray.first!
                    } else if (i == 1){
                        let filter = ImageHelper.applyNashvilleFilter(foregroundImage: coreImage!)
                        imageForButton = UIImage.init(ciImage : filter!)
                    } else if (i == 2){
                        let filter = ImageHelper.applyToasterFilter(ciImage: coreImage!)
                        imageForButton = UIImage.init(ciImage : filter!)
                    } else if (i == 3){
                        let filter = ImageHelper.apply1977Filter(ciImage: coreImage!)
                        imageForButton = UIImage.init(ciImage : filter!)
                    } else if (i == 4){
                        let filter = ImageHelper.applyClarendonFilter(foregroundImage: coreImage!)
                        imageForButton = UIImage.init(ciImage : filter!)
                    } else if (i == 5){
                        let filter = ImageHelper.applyHazeRemovalFilter(image: coreImage!)
                        imageForButton = UIImage.init(ciImage : filter!)
                    } else {
                        let filter = CIFilter(name: "\(self.Filters[i])" )
                        filter!.setDefaults()
                        filter!.setValue(coreImage, forKey: kCIInputImageKey)
                        let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
                        let filteredImageRef = context.createCGImage(filteredImageData, from: filteredImageData.extent)
                        imageForButton = UIImage.init(cgImage: filteredImageRef!)
                    }
                    xCoord +=  buttonWidth + gapBetweenButtons
                    DispatchQueue.main.async {
                        filterButton.setImage(imageForButton, for: .normal)
                        filterButton.imageView?.contentMode = .scaleAspectFill
                        
                        self.filtersScrollView.addSubview(filterButton)
                        //Label properties
                        let filterNameLabel = UILabel()
                        
                        
                        filterNameLabel.frame = CGRect(x:labelXCoord,y: labelYCoord,width: buttonWidth,height: labelHeight)
                        filterNameLabel.text = self.filterNames[i]
                        filterNameLabel.textAlignment = .center
                        filterNameLabel.font = UIFont.italicSystemFont(ofSize: 11)
                        if (i == 0){
                        filterNameLabel.textColor = UIColor.white
                        } else {
                        filterNameLabel.textColor = UIColor(hexString: "#999DA2")
                        }
                        self.labelArray.append(filterNameLabel)
                        
                        labelXCoord += buttonWidth + gapBetweenButtons
                        self.filtersScrollView.addSubview(filterNameLabel)
                    }
                }
                
                
                // Resize Scroll View
                DispatchQueue.main.async {
                    self.filtersScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(self.Filters.count+2),height: 115)
                }
            }
            
        }
    }
    
    @objc func addFilterToAllImages(sender: UIButton) {
        let button = sender as UIButton
        let tag = button.tag
        buttonIndex = tag
        for label in labelArray{
            label.textColor = UIColor(hexString: "#999DA2")
        }
        
        labelArray[tag].textColor = UIColor.white
        if (tag == 0) {
            // Remove the filtered images and set normal images.
            for i in 0..<imagesArray.count{
                let imageView  = self.imageViewArray[i]
                imageView.image = self.imagesArray[i]
            }

        } else if (tag == 1){
            self.filteredImagesArray.removeAll()
            for i in 0..<self.imagesArray.count{
                let coreImage  =  CIImage(image: self.imagesArray[i])
                DispatchQueue.global(qos: .background).async {
                    let filter = ImageHelper.applyNashvilleFilter(foregroundImage: coreImage!)
                    let filteredImage = UIImage.init(ciImage: filter!)
                    let imageView  = self.imageViewArray[i]
                    self.filteredImagesArray.append(filteredImage)
                    DispatchQueue.main.async {
                        imageView.image = filteredImage
                    }
                }
            }
        } else if (tag == 2){
            self.filteredImagesArray.removeAll()
            for i in 0..<self.imagesArray.count{
                let coreImage  =  CIImage(image: self.imagesArray[i])
                DispatchQueue.global(qos: .background).async {
                    let filter = ImageHelper.applyToasterFilter(ciImage: coreImage!)
                    let filteredImage = UIImage.init(ciImage: filter!)
                    let imageView  = self.imageViewArray[i]
                    self.filteredImagesArray.append(filteredImage)
                    DispatchQueue.main.async {
                        imageView.image = filteredImage
                    }
                }
            }
        } else if (tag == 3){
            self.filteredImagesArray.removeAll()
            for i in 0..<self.imagesArray.count{
                let coreImage  =  CIImage(image: self.imagesArray[i])
                DispatchQueue.global(qos: .background).async {
                    let filter = ImageHelper.apply1977Filter(ciImage: coreImage!)
                    let filteredImage = UIImage.init(ciImage: filter!)
                    let imageView  = self.imageViewArray[i]
                    self.filteredImagesArray.append(filteredImage)
                    DispatchQueue.main.async {
                        imageView.image = filteredImage
                    }
                }
            }
        } else if (tag == 4){
            self.filteredImagesArray.removeAll()
            for i in 0..<self.imagesArray.count{
                let coreImage  =  CIImage(image: self.imagesArray[i])
                DispatchQueue.global(qos: .background).async {
                    let filter = ImageHelper.applyHazeRemovalFilter(image: coreImage!)
                    let filteredImage = UIImage.init(ciImage: filter!)
                    let imageView  = self.imageViewArray[i]
                    self.filteredImagesArray.append(filteredImage)
                    DispatchQueue.main.async {
                        imageView.image = filteredImage
                    }
                }
            }
        } else if (tag == 5){
            self.filteredImagesArray.removeAll()
            for i in 0..<self.imagesArray.count{
                let coreImage  =  CIImage(image: self.imagesArray[i])
                DispatchQueue.global(qos: .background).async {
                    let filter = ImageHelper.applyClarendonFilter(foregroundImage: coreImage!)
                    let filteredImage = UIImage.init(ciImage: filter!)
                    let imageView  = self.imageViewArray[i]
                    self.filteredImagesArray.append(filteredImage)
                    DispatchQueue.main.async {
                        imageView.image = filteredImage
                    }
                }
            }
        } else {
            // Set same filters to all images.
            // Add filters for each button
            self.filteredImagesArray.removeAll()
            @available(iOS, deprecated: 12.0)
            let openGLContext = EAGLContext(api: .openGLES2)
            @available(iOS, deprecated: 12.0)
            let context = CIContext(eaglContext: openGLContext!)
                
            for i in 0..<self.imagesArray.count{
                let coreImage  =  CIImage(image: self.imagesArray[i])
                DispatchQueue.global(qos: .background).async {
            let filter = CIFilter(name: "\(self.Filters[tag])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = context.createCGImage(filteredImageData, from: filteredImageData.extent)
            let filteredImage = UIImage.init(cgImage: filteredImageRef!)
            let imageView  = self.imageViewArray[i]
            self.filteredImagesArray.append(filteredImage)
                DispatchQueue.main.async {
                    imageView.image = filteredImage
                }

        }
        }
        }
    }
    
    @objc func filterButtonTapped(sender: UIButton) {
        let button = sender as UIButton
        let tag = button.tag
        buttonIndex = tag
        for label in labelArray{
            label.textColor = UIColor(hexString: "#999DA2")
        }
        labelArray[tag].textColor = UIColor.white
        imageToFilter.image = button.imageView?.image
    }
    
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        var image = UIImage()
        image = (buttonArray[buttonIndex].imageView?.image)!
        if sender.state == .began{
        self.imageToFilter.image = self.imagesArray[0]
        }
        if sender.state == .ended{
            self.imageToFilter.image = image
        }
    }
    
    @objc func longPressedMultipleImg(sender: UILongPressGestureRecognizer)
    {
        let index = self.pageControl.currentPage
        let image = filteredImagesArray[index]
        if buttonIndex == 0{
            return
        } else{
        if sender.state == .began{
            //Show original image
            self.imageViewArray[index].image = self.imagesArray[index]
        }
        if sender.state == .ended{
            //Show filtered image
            self.imageViewArray[index].image = image
        }
    }
    }
    
    func addFilterToImage(){
        self.originalImage.image = self.image
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PreviewVC.longPressed(sender:)))
        longPressRecognizer.minimumPressDuration = 1
        self.imageToFilter.addGestureRecognizer(longPressRecognizer)
        self.imageToFilter.isUserInteractionEnabled = true

        let coreImage = CIImage(image: self.originalImage.image!)
        let labelYCoord: CGFloat = 5
        var labelXCoord : CGFloat = 5
        let labelHeight : CGFloat = 12
        
        var xCoord: CGFloat = 5
        let yCoord: CGFloat = 23
        let buttonWidth:CGFloat = 80
        let buttonHeight: CGFloat = 85
        let gapBetweenButtons: CGFloat = 8
        var itemCount = 0
        
        // Create filters for each button
        @available(iOS, deprecated: 12.0)
        let openGLContext = EAGLContext(api: .openGLES2)
        @available(iOS, deprecated: 12.0)
        let context = CIContext(eaglContext: openGLContext!)
        DispatchQueue.global(qos: .background).async {
            for i in 0..<self.Filters.count {
                itemCount = i
                
                
                // Button properties
                let filterButton = UIButton(type: .custom)
                filterButton.frame = CGRect(x:xCoord,y: yCoord,width: buttonWidth,height: buttonHeight)
                filterButton.tag = itemCount
                filterButton.addTarget(self, action: #selector(PreviewVC.filterButtonTapped(sender:)), for: .touchUpInside)
                filterButton.layer.cornerRadius = 6
                filterButton.clipsToBounds = true
                self.buttonArray.append(filterButton)
                var imageForButton = UIImage()
                
                if (i == 0){
                    imageForButton = self.originalImage.image!
                } else if (i == 1){
                    let filter = ImageHelper.applyNashvilleFilter(foregroundImage: coreImage!)
                    imageForButton = UIImage.init(ciImage : filter!)
                } else if (i == 2){
                    let filter = ImageHelper.applyToasterFilter(ciImage: coreImage!)
                    imageForButton = UIImage.init(ciImage : filter!)
                } else if (i == 3){
                    let filter = ImageHelper.apply1977Filter(ciImage: coreImage!)
                    imageForButton = UIImage.init(ciImage : filter!)
                } else if (i == 4){
                    let filter = ImageHelper.applyClarendonFilter(foregroundImage: coreImage!)
                    imageForButton = UIImage.init(ciImage : filter!)
                } else if (i == 5){
                    let filter = ImageHelper.applyHazeRemovalFilter(image: coreImage!)
                    imageForButton = UIImage.init(ciImage : filter!)
                } else {
                    let filter = CIFilter(name: "\(self.Filters[i])" )
                    filter!.setDefaults()
                    filter!.setValue(coreImage, forKey: kCIInputImageKey)
                    let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
                    let filteredImageRef = context.createCGImage(filteredImageData, from: filteredImageData.extent)
                    imageForButton = UIImage.init(cgImage: filteredImageRef!)
                }
                xCoord +=  buttonWidth + gapBetweenButtons
                DispatchQueue.main.async {
                    filterButton.setImage(imageForButton, for: .normal)
                    filterButton.imageView?.contentMode = .scaleAspectFill
                    
                    self.filtersScrollView.addSubview(filterButton)
                    //Label properties
                    let filterNameLabel = UILabel()
                    filterNameLabel.frame = CGRect(x:labelXCoord,y: labelYCoord,width: buttonWidth,height: labelHeight)
                    filterNameLabel.text = self.filterNames[i]
                    filterNameLabel.textAlignment = .center
                    filterNameLabel.font = UIFont.italicSystemFont(ofSize: 11)
                    if (i == 0){
                        filterNameLabel.textColor = UIColor.white
                    } else {
                        filterNameLabel.textColor = UIColor(hexString: "#999DA2")
                    }
                    self.labelArray.append(filterNameLabel)
                    labelXCoord += buttonWidth + gapBetweenButtons
                    self.filtersScrollView.addSubview(filterNameLabel)
                }
            }
            
            
            // Resize Scroll View
            DispatchQueue.main.async {
                self.filtersScrollView.contentSize = CGSize(width: buttonWidth * CGFloat(self.Filters.count+2),height: 115)
            }
        }
    }
    
    //Scroll View Delegate Method
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        let page = sender.currentPage
        var frame: CGRect = self.imageScrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.imageScrollView.scrollRectToVisible(frame, animated: true)
    }
    
    @IBAction func savePicButton(_ sender: Any) {
        // Save the image into camera roll
        if imageViewArray.count > 1{
            for i in 0..<filteredImagesArray.count{
                CustomAlbum.sharedInstance.save(image: filteredImagesArray[i])
            }
        } else {
            CustomAlbum.sharedInstance.save(image: imageToFilter.image!)
        }
        
        let alert = UIAlertView(title: "Filters",
                                message: "Your image has been saved to Photo Library",
                                delegate: nil,
                                cancelButtonTitle: "OK")
        
        alert.show()
        
    }
    
    
    @IBAction func cancelButton(_ sender: Any) {
        rightToLeft()
        self.dismiss(animated: false, completion: nil)
    }
}


