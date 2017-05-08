//
//  AppDelegate.swift
//  ImagePreview
//
//  Created by Renato Cordeiro on 5/3/17.
//  Copyright © 2017 Renato Cordeiro. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        //print("on app open file - filename= \(filename)")
        
        let vc = sender.mainWindow?.contentViewController as! ViewController
        let url = URL(fileURLWithPath: filename)
        vc.start(url)
        
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

