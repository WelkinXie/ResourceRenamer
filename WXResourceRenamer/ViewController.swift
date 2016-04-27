//
//  ViewController.swift
//  WXResourceRenamer
//
//  Created by Welkin Xie on 3/22/16.
//  Copyright © 2016 WelkinXie. All rights reserved.
//
//  Github: https://github.com/WelkinXie/WXResourceRenamer
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var pathView: NSTextView!
    
    @IBOutlet weak var selectButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    
    var filePaths = [NSURL]()
    
    @IBOutlet weak var prefixButton: NSButton!
    @IBOutlet weak var subfixButton: NSButton!
    
    @IBOutlet weak var prefixField: NSTextField!
    @IBOutlet weak var subfixField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Resources Renamer"
        
        startButton.title = NSLocalizedString("Start", comment: "")
        selectButton.title = NSLocalizedString("Select", comment: "")
        prefixButton.title = NSLocalizedString("AddPrefix", comment: "")
        subfixButton.title = NSLocalizedString("AddSuffix", comment: "")
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func selectPressed(sender: NSButton) {
        
        let openPanel = NSOpenPanel.init()
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseFiles = true
        
        if openPanel.runModal() == NSModalResponseOK {
            
            filePaths.removeAll()
            
            for url in openPanel.URLs {
                filePaths.append(url)
            }
            
        }
        pathView.string = filePathsString()
    }
    
    @IBAction func startPressed(sender: NSButton) {
        
        switchState(false)
        startButton.title = NSLocalizedString("Wait", comment: "")
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            let fileManager = NSFileManager.defaultManager()

            for path in self.filePaths {
                
                var newfileName = path.URLByDeletingPathExtension!.lastPathComponent!
                
                if self.prefixButton.state == NSOnState && !newfileName.hasPrefix(self.prefixField.stringValue) {
                    newfileName = self.prefixField.stringValue + newfileName
                }
                if self.subfixButton.state == NSOnState && !newfileName.hasSuffix(self.subfixField.stringValue)  {
                    newfileName = newfileName + self.subfixField.stringValue
                }
                
                let directoryPath = path.URLByDeletingLastPathComponent!.relativePath! + "/renamed"
                if !fileManager.fileExistsAtPath(directoryPath) {
                    let fileDirectory = NSURL(fileURLWithPath: directoryPath)
                    do {
                        try fileManager.createDirectoryAtURL(fileDirectory, withIntermediateDirectories: false, attributes: nil)
                    } catch {
                        print(error)
                    }
                }
                let newFilePath = directoryPath + "/" + newfileName + "." + path.pathExtension!
                
                do {
                    try fileManager.copyItemAtPath(path.relativePath!, toPath: newFilePath)
                } catch {
                    print(error)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.switchState(true)
                self.startButton.title = NSLocalizedString("Start", comment: "")
                if !self.pathView.string!.hasSuffix(NSLocalizedString("Finished", comment: "")) {
                    self.pathView.string = self.pathView.string! + NSLocalizedString("Finished", comment: "")
                }
            })
        }
    }
    
    func filePathsString() -> String {
        var pathString = ""
        for path in filePaths {
            let addedPath = path.relativePath!.stringByRemovingPercentEncoding
            pathString = pathString + addedPath! + "\n\n"
        }
        return pathString
    }
    
    func switchState(flag: Bool) {
        selectButton.enabled = flag
        prefixButton.enabled = flag
        prefixField.editable = flag
        subfixButton.enabled = flag
        subfixField.editable = flag
        startButton.enabled = flag
    }
}

