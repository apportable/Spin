//
//  SpinViewController.m
//  Spin
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>

#ifdef APPORTABLE
// GameKit Providers on the Apportable Android platform
#define kGameKitProviderGoogle @"GooglePlay"
#define kGameKitProviderAmazon @"AmazonGameCircle"
extern NSString *gkProviderName;
#endif

// NOTE: Amazon GameCircle allows you to name achievements and leaderboards the same as their iOS/GameCenter counterparts...
#define kDizzinessAchievement @"dizziness"
#define kReverseAchievement @"reversespin"
#define kSpinLeaderboard @"SpinLeaderboard"
#define kSpinAltLeaderboard @"AnotherLeaderboard"

// ... but on Google Play you need to use the IDs generated for you in your developer console
#define kGPGDizzinessAchievement @"ENTER-THE-VALUE-FROM-YOUR-GOOGLE-DEVELOPER-CONSOLE"
#define kGPGReverseAchievement @"ENTER-THE-VALUE-FROM-YOUR-GOOGLE-DEVELOPER-CONSOLE"
#define kGPGSpinLeaderboard @"ENTER-THE-VALUE-FROM-YOUR-GOOGLE-DEVELOPER-CONSOLE"
#define kGPGSpinAltLeaderboard @"ENTER-THE-VALUE-FROM-YOUR-GOOGLE-DEVELOPER-CONSOLE"

@interface SpinViewController () <GKGameCenterControllerDelegate, GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate>
@property (retain, nonatomic) IBOutlet UIButton *dizzyButton;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UILabel *score;

@property (copy, nonatomic) NSString *dizzyAchivement;
@property (copy, nonatomic) NSString *spinLeaderboard;
@end

static int64_t gameScore = 0LL;

@implementation SpinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_dizzyButton release];
    [_loginButton release];
    [_userName release];
    [_score release];
    [_dizzyAchivement release];
    [_spinLeaderboard release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self.view selector:@selector(render:)];
    link.frameInterval = 1;
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	// Do any additional setup after loading the view.
    [self becomeFirstResponder];
    
    [self setDizzyAchivement:kDizzinessAchievement];
    [self setSpinLeaderboard:kSpinLeaderboard];
#ifdef APPORTABLE
    if ([gkProviderName isEqualToString:kGameKitProviderGoogle])
    {
        [_loginButton setTitle:kGameKitProviderGoogle forState:UIControlStateNormal];
        [_loginButton setEnabled:NO];
        [self setDizzyAchivement:kGPGDizzinessAchievement];
        [self setSpinLeaderboard:kGPGSpinLeaderboard];
    }
    else if ([gkProviderName isEqualToString:kGameKitProviderAmazon])
    {
        [_loginButton setTitle:kGameKitProviderAmazon forState:UIControlStateNormal];
    }
    else
    {
        NSLog(@"OOPS : no GameKit backend provider specified, expect a null implementation on Android!");
    }
#endif
    
    [self authenticateLocalPlayer];
}

- (void)authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            NSLog(@"player is authenticated");
            [self.userName setText:[localPlayer alias]];
            [self.score setText:[NSString stringWithFormat:@"%lld", gameScore]];
            [self reportAchievements];
        }
        else
        {
            NSLog(@"player is not authenticated");
        }
    }];
}

- (void)reportAchievements
{
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (error)
        {
            NSLog(@"OOPS, error loading achievements : %@", [error description]);
        }
        else
        {
            NSLog(@"loaded achievements...");
        }
        for (NSObject *obj in achievements)
        {
            NSLog(@"current player has achieved : %@", obj);
        }
    }];
}

- (IBAction)awardDizzy:(id)sender
{
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier:[self dizzyAchivement]] autorelease];
    if (achievement)
    {
        achievement.percentComplete = 100.0;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (error)
            {
                NSLog(@"OOPS, could not award dizzy achievement: %@", error);
            }
            else
            {
                NSLog(@"CONGRATULATIONS! you were awarded the dizzy achievement");
                self.dizzyButton.enabled = NO;
                NSString *awarded = @"(awarded)";
                [self.dizzyButton setTitle:awarded forState:UIControlStateNormal];
                [self.dizzyButton setTitle:awarded forState:UIControlStateDisabled];
                [self.dizzyButton setTitle:awarded forState:UIControlStateSelected];
                [self.dizzyButton setTitle:awarded forState:UIControlStateHighlighted];
            }
        }];
    }
}

- (IBAction)increaseScore:(id)sender
{
    gameScore += 10;
    GKScore *gkScore = [[GKScore alloc] initWithCategory:[self spinLeaderboard]];
    gkScore.value = gameScore;
    [self.score setText:[NSString stringWithFormat:@"%lld", gameScore]];
    [gkScore reportScoreWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"OOPS, error reporting score : %@", error);
        }
        else
        {
            NSLog(@"reported score %lld", gameScore);
        }
    }];
    [gkScore release];
}

- (IBAction)showPseudoGameCenterOverlay:(id)sender
{
    GKGameCenterViewController *gameCenterController = [[GKGameCenterViewController alloc] init]; // released in callback
    if (gameCenterController != nil)
    {
        gameCenterController.gameCenterDelegate = self;
        [self presentViewController:gameCenterController animated:YES completion:nil];
    }
}

- (IBAction)showAchievements:(id)sender
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            [self.userName setText:[localPlayer alias]];
            GKAchievementViewController *achievementViewController = [[GKAchievementViewController alloc] init]; // released in callback
            if (achievementViewController != nil)
            {
                achievementViewController.achievementDelegate = self;
                [self presentViewController:achievementViewController animated:YES completion:nil];
            }
        }
        else
        {
            [self showPseudoGameCenterOverlay:sender];
        }
    }];
}

- (IBAction)showLeaderboards:(id)sender
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            [self.userName setText:[localPlayer alias]];
            GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init]; // released in callback
            if (leaderboardViewController != nil)
            {
                leaderboardViewController.leaderboardDelegate = self;
                [self presentViewController:leaderboardViewController animated:YES completion:nil];
            }
        }
        else
        {
            [self showPseudoGameCenterOverlay:sender];
        }
    }];
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

- (BOOL)canBecomeFirstResponder
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

#pragma mark -
#pragma mark various GKGameCenterControllerDelegate methods

// NOTE: with Amazon GameCircle backend on Android, these may be called before overlay dismissal ...

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    NSLog(@"gameCenterViewControllerDidFinish ...");
    [self dismissViewControllerAnimated:YES completion:nil];
    [gameCenterViewController release];
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)leaderboardViewController
{
    NSLog(@"leaderboardViewControllerDidFinish ...");
    [self dismissViewControllerAnimated:YES completion:nil];
    [leaderboardViewController release];
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)achievementViewController
{
    NSLog(@"achievementViewControllerDidFinish ...");
    [self dismissViewControllerAnimated:YES completion:nil];
    [achievementViewController release];
}

@end
