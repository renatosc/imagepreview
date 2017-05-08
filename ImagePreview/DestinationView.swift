//
//  DestinationView.swift
//  ImagePreview
//
//  Created by Renato Cordeiro on 5/3/17.
//  Copyright © 2017 Renato Cordeiro. All rights reserved.
//  Inspired by https://www.raywenderlich.com/136272/drag-and-drop-tutorial-for-macos

import Cocoa

// this protocol will be implemented by the ViewController
protocol DestinationViewDelegate {
    func processImageURLs(_ urls: [URL], center: NSPoint)
}


class DestinationView: NSView {
    
    var delegate: DestinationViewDelegate?
    
    override func awakeFromNib() {
        setup()
    }
    
    //we override hitTest so that this view which sits at the top of the view hierachy
    //appears transparent to mouse clicks
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
    
    
    
    // specifying that we want only to accept URL types
    var acceptableTypes: Set<String> { return [NSURLPboardType] }
    
    func setup() {
        // registering the types that this view will accept for dragging
        register(forDraggedTypes: Array(acceptableTypes))
    }
    
    // drawing a blue rectangle around the view when the user is inside the view witht he dragged image
    override func draw(_ dirtyRect: NSRect) {
        if isReceivingDrag {
            NSColor.selectedControlColor.set()
            let path = NSBezierPath(rect:bounds)
            path.lineWidth = 10
            path.stroke()
        }
    }
    
    
    
    
    
    let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey:NSImage.imageTypes()]
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        // getting the current pasteboard session
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        // cehcking if the object being dragged is acceptable for us
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            return true
        }
        return false
        
    }
    
    
    var isReceivingDrag = false {
        didSet {
            // let's flag that this view need to be redrawn
            needsDisplay = true
        }
    }
    
    
    
    
    // - - - - - - - - - - - - - - - - -
    // NSDraggingDestination functions
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()  // the NSDragOperation.copy that we return is what makes the mouse pointer appears with the '+' symbol
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    // called when user released the dragged object inside our view. We return if the dragged object is acceptable or not
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    // called after we accepted the dragged object on the function above (prepareForDragOperation)
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        
        //1.
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        
        //2.
        let point = convert(draggingInfo.draggingLocation(), from: nil)
        //3.
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            delegate?.processImageURLs(urls, center: point)
            return true
        }
        return false
        
    }

    
}
