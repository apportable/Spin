//
//  SpinParseView.h
//  Spin
//
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinParseView : UIView

@property (retain, nonatomic) IBOutlet UILabel *aBoolValue;
@property (retain, nonatomic) IBOutlet UILabel *anIntegerValue;
@property (retain, nonatomic) IBOutlet UILabel *aFloatValue;
@property (retain, nonatomic) IBOutlet UITextField *cloudValueInput;
@property (retain, nonatomic) IBOutlet UISwitch *booleanSwitch;
@property (retain, nonatomic) IBOutlet UISlider *floatSlider;
@property (retain, nonatomic) IBOutlet UITextField *objectIdValue;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spinney;

- (void)setupView;

- (IBAction)setBooleanValue:(id)sender;
- (IBAction)decrementValue:(id)sender;
- (IBAction)incrementValue:(id)sender;
- (IBAction)setFloatValue:(id)sender;

- (IBAction)saveCloudObject:(id)sender;
- (IBAction)reloadCloudObject:(id)sender;
- (IBAction)newCloudObject:(id)sender;
- (IBAction)deleteCloudObject:(id)sender;

@end
