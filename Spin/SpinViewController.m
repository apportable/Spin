//
//  SpinViewController.m
//  Spin
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SpinViewController ()

@end

@interface MyView: UIView
@end

@implementation MyView

- (void)drawRect:(CGRect)rect
{
    [[UIColor blackColor] set];
    UIRectFill(rect);
    
    NSString* text = @"Testing";
    UIFont* font = [UIFont systemFontOfSize:12];
    
    CGSize textSize = [text sizeWithFont:font
                       constrainedToSize:rect.size
                           lineBreakMode:NSLineBreakByWordWrapping];
    
    rect.origin.x = (rect.size.width - textSize.width) / 2;
    rect.origin.y = (rect.size.height - textSize.height) / 2;
    
    [[UIColor whiteColor] set];
    [text drawInRect:rect
            withFont:font
       lineBreakMode:NSLineBreakByWordWrapping
           alignment:NSTextAlignmentLeft];
}

@end

@implementation SpinViewController

@synthesize singleLineLabel = _singleLineLabel;
@synthesize multiLineLabel = _multiLineLabel;

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
    
    [_singleLineLabel setFont:[UIFont fontWithName:@"AldotheApache.ttf" size:25]];
//    [_singleLineLabel setFont:[UIFont systemFontOfSize:17]];
    [_multiLineLabel setFont:[UIFont fontWithName:@"vag_rounded_pro.ttf" size:26]];
    
    [_multiLineLabel setAdjustsFontSizeToFitWidth:YES];
    [_singleLineLabel setAdjustsFontSizeToFitWidth:YES];
    
    [_singleLineLabel sizeToFit];
    [_multiLineLabel sizeToFit];
    
    MyView* myView = [[[MyView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)] autorelease];
    myView.frame = CGRectOffset(myView.frame, self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    [self.view addSubview:myView];
    
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
