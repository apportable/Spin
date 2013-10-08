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
    UIFont* font = [UIFont systemFontOfSize:16];
    
    CGSize textSize = [text sizeWithFont:font
                       constrainedToSize:rect.size
                           lineBreakMode:NSLineBreakByWordWrapping];
    NSLog(@"text size height %f, rect size height %f", textSize.height, rect.size.height);
    
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
    
    CGFloat fontSize = 20;
    UIFont *customFont = [UIFont fontWithName:@"AldotheApache" size:fontSize];
    UIFont *systemFont = [UIFont systemFontOfSize:16];
    
    [_customFont0Lines setFont:customFont];
    [_customFont1Line setFont:customFont];
    [_customFontMultiline setFont:customFont];
    
    [_systemFont0Lines setFont:systemFont];
    [_systemFont1Line setFont:systemFont];
    [_systemFontMultiline setFont:systemFont];
    
    BOOL adjustsFontSizeToFitWidth = YES;
    
    [_customFont1Line setAdjustsFontSizeToFitWidth:adjustsFontSizeToFitWidth];
//    [_systemFont1Line setAdjustsFontSizeToFitWidth:adjustsFontSizeToFitWidth];
    
    [_customFont0Lines sizeToFit];
    [_customFont1Line sizeToFit];
    [_customFontMultiline sizeToFit];
    
    [_systemFont0Lines sizeToFit];
    [_systemFont1Line sizeToFit];
    [_systemFontMultiline sizeToFit];
    
    NSLog(@"single line frame size height %f", _systemFont1Line.frame.size.height);
    
    MyView* myView = [[[MyView alloc] initWithFrame:CGRectMake(0, 0, 80, 60)] autorelease];
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
