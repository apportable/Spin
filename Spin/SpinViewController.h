//
//  SpinViewController.h
//  Spin
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinViewController : UIViewController
{
    UILabel* _singleLineLabel;
    UILabel* _multiLineLabel;
}

@property (nonatomic, retain) IBOutlet UILabel* singleLineLabel;
@property (nonatomic, retain) IBOutlet UILabel* multiLineLabel;

@end
