//
//  SpinViewController.m
//  Spin
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinViewController.h"
#import "SpinParseView.h"

@interface SpinViewController () <UITextFieldDelegate>

@end

@implementation SpinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self becomeFirstResponder];
    
    SpinParseView *view = (SpinParseView*)[self view];
    [[view cloudValueInput] setDelegate:self];
    [view setupView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

//Back button support
#ifdef APPORTABLE

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (void) buttonUpWithEvent:(UIEvent *)event
{
    switch (event.buttonCode)
    {
        case UIEventButtonCodeBack:
            // handle back button if possible, otherwise exit(0)
            exit(0);
            break;
        case UIEventButtonCodeMenu:
            // show menu if possible.
            break;
        default:
            break;
    }
}

#endif

#pragma -
#pragma UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    SpinParseView *view = (SpinParseView*)[self view];
    [[view cloudValueInput] resignFirstResponder];
    return NO;
}
@end
