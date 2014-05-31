//
//  SpinViewController.m
//  Spin
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinViewController.h"
#import <QuartzCore/QuartzCore.h>


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
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self.view selector:@selector(render:)];
    link.frameInterval = 1;
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	// Do any additional setup after loading the view.
    [self becomeFirstResponder];
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

- (void)buttonUpWithEvent:(UIEvent *)event
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

@end
