//
//  ViewController.swift
//  ImagePreview
//
//  Created by Renato Cordeiro on 5/3/17.
//  Copyright © 2017 Renato Cordeiro. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    //@IBOutlet var targetLayer: NSView!
    @IBOutlet var DestinationLayer: DestinationView!
    @IBOutlet var imgView: NSImageView!
    @IBOutlet weak var label: NSTextField!
    
    var listOfImages:[URL]!
    var currIndex: Int = 0
    var maxIndex: Int = 0
    
    var slideShowSpeed = 3.0; // 3 secs as default
    var isSlideShowOn = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DestinationLayer.delegate = self
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }
    
    
    func aspectFitSizeForMaxDimension(_ image:NSImage, _ maxDimension: CGFloat) -> NSSize {
        var width =  image.size.width
        var height = image.size.height
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let aspectRatio = image.size.width / image.size.height
            width = aspectRatio > 0 ? maxDimension : maxDimension*aspectRatio
            height = aspectRatio < 0 ? maxDimension : maxDimension/aspectRatio
        }
        return NSSize(width: width, height: height)
    }
    
    func getImageSizeToFitWindow(_ image:NSImage ) -> NSSize {
        let imgW =  image.size.width
        let imgH = image.size.height
        //print("imgW=\(imgW) |  imgH=\(imgH) ")
        
        let screen = self.view.window!
        let screenH = screen.frame.size.height
        let screenW = screen.frame.size.width
        //print("screenW=\(screenW) |  screenH=\(screenH) ")
        let scaleFactor = min(screenW / imgW, screenH / imgH)
        //print("scalef=\(scaleFactor)")
        let finalW = imgW * scaleFactor
        let finalH = imgH * scaleFactor
        //print("finalW=\(finalW) |  finalH=\(finalH) ")
        return NSSize(width: finalW, height: finalH)
    }
    
    
    
    func prepareListOfImages(_ url: URL) {
        
        listOfImages = [URL]()
        
        let currPathURL = url.deletingLastPathComponent()
        //print("currPath=\(currPathURL)")
        
        
        let filemanager:FileManager = FileManager()
        let files = filemanager.enumerator(at: currPathURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants], errorHandler: { (url, error) -> Bool in
            //print("directoryEnumerator error at \(url): ", error)
            return true
        })
        var index = 0
        while let file = files?.nextObject() {
            
            if let fileURL = file as? URL {
                let ext = fileURL.pathExtension.lowercased()
                
                if ext == "jpg" || ext == "jpeg" || ext == "png" {
                    //print(file)
                    listOfImages.append(fileURL)
                    if fileURL == url {
                        currIndex = index
                    }
                    index += 1
                }
            }
        }
        maxIndex = index
        //print("currIndex=\(currIndex) of  \(listOfImages.count)")
        //print("finished")
        //print(listOfImages)
    }
    
    func showImageAtIndex(_ index:Int){
        //print("\(index) - \(maxIndex)")
        if index >= maxIndex {
            print("no more images to show")
            return
        }
        if index < 0 {
            print("negative index is not valid")
            return
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        label.isHidden = true
        
        let url = listOfImages[index]
        
        if let image = NSImage(contentsOf:url) {
            image.size = getImageSizeToFitWindow(image)
            imgView.image = image
        }
        currIndex = index
        
        if isSlideShowOn {
            perform(#selector(showNextImage), with: nil, afterDelay: slideShowSpeed)
        }
        
    }
    
    func resizeWindow() {
        if let window = self.view.window {
            let screen = NSScreen.main!
            window.setFrame(screen.visibleFrame, display:true)
        }
    }
    
    
    func start(_ url: URL) {        
        prepareListOfImages(url)
        resizeWindow()
        showImageAtIndex(currIndex)
    }

    
    
    func increaseSlideShowSpeed() {
        slideShowSpeed -= 0.5
        slideShowSpeed = max(slideShowSpeed,1)
    }
    func decreaseSlideShowSpeed() {
        slideShowSpeed += 0.5
    }
    
    func startStopSlideShow() {
        isSlideShowOn = !isSlideShowOn
        if isSlideShowOn {
            showImageAtIndex(currIndex)
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
    }
    @objc func showNextImage (){
        showImageAtIndex(currIndex+1)
        
    }
    func showPreviousImage (){
        showImageAtIndex(currIndex-1)
    }
    
    func keyDown(with event: NSEvent) -> NSEvent? {
        //print(event.keyCode)
        
        switch event.keyCode {
        case 27: //   key +/=
            increaseSlideShowSpeed()
        case 24: // key -/_
            decreaseSlideShowSpeed()
        case 49: // key space
            startStopSlideShow()
        case 124: // key right
            showNextImage()
        case 123: // key left
            showPreviousImage()
        default:
            return event
        }

        return nil
    }
    
}

// MARK: - DestinationViewDelegate
extension ViewController: DestinationViewDelegate {
    
    func processImageURLs(_ urls: [URL], center: NSPoint) {
        let url = urls[0]
        start(url)
    }
    
}

