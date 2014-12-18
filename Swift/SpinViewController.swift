//
//  SpinViewController.swift
//  Spin
//
//  Created by Paul Beusterien on 12/18/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

import UIKit

class SpinViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var link = CADisplayLink(target: self.view, selector: Selector("render:"))
        link.frameInterval = 1
        link.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.becomeFirstResponder()
    }
    
//    
//    - (void)didReceiveMemoryWarning
//    {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//    }
//    
//    - (BOOL)shouldAutorotate
//    {
//    return YES;
//    }
//    
//    - (NSUInteger)supportedInterfaceOrientations
//    {
//    return UIInterfaceOrientationMaskAll;
//    }
//    
//    //Back button support
//    #ifdef APPORTABLE
//    
//    - (BOOL) canBecomeFirstResponder
//    {
//    return YES;
//    }
//    
//    - (void)buttonUpWithEvent:(UIEvent *)event
//    {
//    switch (event.buttonCode)
//    {
//    case UIEventButtonCodeBack:
//    // handle back button if possible, otherwise exit(0)
//    exit(0);
//    break;
//    case UIEventButtonCodeMenu:
//    // show menu if possible.
//    break;
//    default:
//    break;
//    }
//    }
//    
//    #endif
    
}
