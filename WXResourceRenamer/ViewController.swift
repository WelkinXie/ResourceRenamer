//
//  ViewController.swift
//  WXResourceRenamer
//
//  Created by Welkin Xie on 3/22/16.
//  Copyright © 2016 WelkinXie. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var pathView: NSTextView!
    
    @IBOutlet weak var selectButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    
    var filePaths: [NSURL] = []
    
    @IBOutlet weak var prefixButton: NSButton!
    @IBOutlet weak var subfixButton: NSButton!
    
    @IBOutlet weak var prefixField: NSTextField!
    @IBOutlet weak var subfixField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "WXRenamer"
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
            
            self.filePaths.removeAll()
            
            for url in openPanel.URLs {
                self.filePaths.append(url)
            }
            
        }
        self.pathView.string = self.filePathsString()
    }
    
    @IBAction func startPressed(sender: NSButton) {
        
        self.switchState(false)
        self.startButton.title = "请稍候"
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            
            let fileManager = NSFileManager.defaultManager()

            for path in self.filePaths {
                
                var newfileName = path.URLByDeletingPathExtension!.lastPathComponent!
                
                if self.prefixButton.state == NSOnState {
                    newfileName = self.prefixField.stringValue + newfileName
                }
                if self.subfixButton.state == NSOnState {
                    newfileName = newfileName + self.subfixField.stringValue
                }
                
                let directoryPath = path.URLByDeletingLastPathComponent!.relativePath! + "/renamed"
                if !fileManager.fileExistsAtPath(directoryPath) {
                    let fileDirectory = NSURL.init(fileURLWithPath: directoryPath)
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
                self.startButton.title = "开始"
                if !self.pathView.string!.hasSuffix("\n\n完成") {
                    self.pathView.string = self.pathView.string! + "\n\n完成"
                }
            })
        }
    }
    
    func filePathsString() -> String {
        var pathString = ""
        for path in self.filePaths {
            let addedPath = path.relativePath!.stringByRemovingPercentEncoding
            pathString = pathString + addedPath! + "\n\n"
        }
        return pathString
    }
    
    func switchState(flag: Bool) {
        self.selectButton.enabled = flag
        self.prefixButton.enabled = flag
        self.prefixField.editable = flag
        self.subfixButton.enabled = flag
        self.subfixField.editable = flag
        self.startButton.enabled = flag
    }
}

