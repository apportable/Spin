//
//  SpinViewController.m
//  Spin
//
//  Copyright (c) 2012 Apportable. All rights reserved.
//

#import "SpinViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import <QuartzCore/QuartzCore.h>
#import <GameCircle/GameCircle.h>

#define kDizzinessAchievement @"dizziness"
#define kSpinLeaderboard @"SpinLeaderboard"

@interface SpinViewController ()
@property (retain, nonatomic) IBOutlet UIButton *dizzyButton;
@property (retain, nonatomic) IBOutlet UIButton *loginButton;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UILabel *score;
@property (retain, nonatomic) IBOutlet UILabel *digestVal;

@property (assign, nonatomic) BOOL isSignedIn;
@end

static int64_t gameScore = 0LL;

@implementation SpinViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        srandom(time(NULL)); // insecure
    }
    return self;
}

- (void)dealloc {
    [_dizzyButton release];
    [_loginButton release];
    [_userName release];
    [_score release];
    [_digestVal release];
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
    [self authenticateLocalPlayer];
}

- (void)authenticateLocalPlayer
{
    // register for Whispersync events
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDataUploadedToCloud:)
                                                 name:AGWhispersyncNotificationDataUploadedToCloud
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDiskWriteComplete:)
                                                 name:AGWhispersyncNotificationDiskWriteComplete
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onFirstSynchronize:)
                                                 name:AGWhispersyncNotificationFirstSync
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNewCloudData:)
                                                 name:AGWhispersyncNotificationNewDataFromCloud
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onThrottled:)
                                                 name:AGWhispersyncNotificationThrottled
                                               object:nil];

    NSArray *features = [NSArray arrayWithObjects:AGFeatureAchievements, AGFeatureLeaderboards, AGFeatureWhispersync, nil];
    
    [AGPlayer setSignedInStateDidChangeHandler:^(BOOL isSignedIn) {
        [self setIsSignedIn:isSignedIn];
        if (isSignedIn)
        {
            [self fetchLocalPlayer];
        }
        else
        {
            [self.userName setText:@"NOT LOGGED IN"];
            [self.score setText:@"NOT LOGGED IN"];
        }
    }];
    
    [GameCircle beginWithFeatures:features completionHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"OOPS, problem starting GameCircle : %@", error);
        }
        else
        {
            NSLog(@"GameCircle is ready, fetching local player ...");
        }
    }];
}

- (void)fetchLocalPlayer
{
    if (![self isSignedIn])
    {
        return;
    }
    [AGPlayer localPlayerWithCompletionHandler:^(AGPlayer *player, NSError *error) {
        if (error || !player)
        {
            NSLog(@"OOPS, problem fetching local player : %@", error);
            NSLog(@"Will re-attempt fetch after short delay...");
            [self performSelector:@selector(fetchLocalPlayer) withObject:self afterDelay:2.0];
        }
        else
        {
            NSLog(@"Local player fetched! ... alias:%@ ID:%@ avatarURL:%@", [player alias], [player playerID], [player avatarURL]);
            [self.userName setText:[player alias]];
            [self.score setText:[NSString stringWithFormat:@"%lld", gameScore]];
            [self reportAchievementsAndScores];
        }
    }];
}

- (void)reportAchievementsAndScores
{
    // Exercise the achievements and leaderboards APIs ...
    
    [AGAchievement allDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
        if (error)
        {
            NSLog(@"OOPS, error loading achievement descriptions : %@", error);
        }
        else
        {
            NSLog(@"Loaded achievement descriptions...");
            for (AGAchievementDescription *desc in descriptions)
            {
                NSLog(@"Achievement ...");
                NSLog(@"\tachievementID : %@", [desc achievementID]);
                NSLog(@"\ttitle         : %@", [desc title]);
                NSLog(@"\tdetailText    : %@", [desc detailText]);
                NSLog(@"\tindex         : %d", [desc index]);
                NSLog(@"\tpoints        : %d", [desc points]);
                NSLog(@"\thidden        : %d", [desc hidden]);
                NSLog(@"\tprogress      : %f", [desc progress]);
                NSLog(@"\tunlocked      : %d", [desc isUnlocked]);
                NSLog(@"\tunlockedDate  : %@", [desc unlockedDate]);
                NSLog(@"\timageURL      : %@", [desc imageURL]);
            }
            AGAchievement *dizz = [AGAchievement achievementWithID:kDizzinessAchievement];
            [dizz descriptionWithCompletionHandler:^(AGAchievementDescription *description, NSError *error) {
                if (error)
                {
                    NSLog(@"OOPS, error loading '%@' achievement description : %@", kDizzinessAchievement, error);
                }
                else
                {
                    NSLog(@"Fetched '%@' achievement description : %@", kDizzinessAchievement, description);
                }
            }];
        }
    }];
    
    [AGLeaderboard allDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
        if (error)
        {
            NSLog(@"OOPS, error loading all leaderboard descriptions : %@", error);
        }
        else
        {
            NSLog(@"Loaded leaderboard descriptions...");
            for (AGLeaderboardDescription *desc in descriptions)
            {
                NSLog(@"Leaderboard ...");
                NSLog(@"\tleaderboardID : %@", [desc leaderboardID]);
                NSLog(@"\ttitle         : %@", [desc title]);
                NSLog(@"\tscoreUnit     : %@", [desc scoreUnit]);
                NSLog(@"\tscoreFormat   : %@", [desc scoreFormat]);
                NSLog(@"\timageURL      : %@", [desc imageURL]);
                
                AGLeaderboard *leaderboard = [AGLeaderboard leaderboardWithID:[desc leaderboardID]];
                if (!leaderboard)
                {
                    NSLog(@"OOPS, could not create leaderboard from ID '%@'", [desc leaderboardID]);
                }
                else
                {
                    [leaderboard scoresWithFilter:AGLeaderboardFilterGlobalAllTime completionHandler:^(NSArray *scores, AGLeaderboardDescription *description, NSError *error) {
                        if (error)
                        {
                            NSLog(@"OOPS, could not fetch scores with filter '%@' : %@", AGLeaderboardFilterGlobalAllTime, error);
                        }
                        else
                        {
                            NSLog(@"Fetched scores...");
                            for (AGScore *score in scores)
                            {
                                NSLog(@"\tleaderboardID : %@", [score leaderboardID]);
                                NSLog(@"\tplayerID      : %@", [[score player] playerID]);
                                NSLog(@"\tplayer alias  : %@", [[score player] alias]);
                                NSLog(@"\tscoreString   : %@", [score scoreString]);
                                NSLog(@"\tfilter        : %@", [score filter]);
                                NSLog(@"\trank          : %d", [score rank]);
                                NSLog(@"\tscore         : %lld", [score score]);
                            }
                        }
                    }];
                    
                    [leaderboard localPlayerScoreWithFilter:AGLeaderboardFilterGlobalDay completionHandler:^(AGScore *score, NSError *error) {
                        if (error)
                        {
                            NSLog(@"OOPS, could not fetch local player score with filter '%@' : %@", AGLeaderboardFilterGlobalDay, error);
                        }
                        else
                        {
                            NSLog(@"Fetched local player score...");
                            NSLog(@"\tleaderboardID : %@", [score leaderboardID]);
                            NSLog(@"\tplayerID      : %@", [[score player] playerID]);
                            NSLog(@"\tplayer alias  : %@", [[score player] alias]);
                            NSLog(@"\tscoreString   : %@", [score scoreString]);
                            NSLog(@"\tfilter        : %@", [score filter]);
                            NSLog(@"\trank          : %d", [score rank]);
                            NSLog(@"\tscore         : %lld", [score score]);
                        }

                    }];
                    
                    [leaderboard percentileRanksWithFilter:AGLeaderboardFilterGlobalWeek completionHandler:^(NSArray *percentiles, int playerIndex, AGLeaderboardDescription *desc, NSError *error) {
                        if (error)
                        {
                            NSLog(@"OOPS, could not fetch percentile ranks with filter '%@' : %@", AGLeaderboardFilterGlobalWeek, error);
                        }
                        else
                        {
                            NSLog(@"Fetched percentile ranks for leaderboard '%@'...", [desc leaderboardID]);
                            NSLog(@"\ttitle         : %@", [desc title]);
                            NSLog(@"\tscoreUnit     : %@", [desc scoreUnit]);
                            NSLog(@"\tscoreFormat   : %@", [desc scoreFormat]);
                            NSLog(@"\timageURL      : %@", [desc imageURL]);

                            for (AGLeaderboardPercentileItem *item in percentiles)
                            {
                                NSLog(@"percentile item...");
                                NSLog(@"\tpercentile    : %d", [item percentile]);
                                NSLog(@"\tplayerID      : %@", [[item player] playerID]);
                                NSLog(@"\tplayer alias  : %@", [[item player] alias]);
                                NSLog(@"\tscoreString   : %lld", [item score]);
                            }
                        }
                    }];
                }
            }
        }
    }];
}

- (IBAction)awardDizzy:(id)sender
{
    AGAchievement *achievement = [AGAchievement achievementWithID:kDizzinessAchievement];
    if (!achievement)
    {
        NSLog(@"OOPS, could not create '%@' achievement", kDizzinessAchievement);
    }
    else
    {
        [achievement updateWithProgress:100.f completionHandler:^(BOOL newlyUnlocked, NSError *error) {
            if (error)
            {
                NSLog(@"OOPS, could not award dizzy achievement: %@", error);
            }
            else
            {
                NSLog(@"CONGRATULATIONS! you were awarded the dizzy achievement");
                if (newlyUnlocked)
                {
                    NSLog(@"AND... it was newly unlocked, w00t!");
                }
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
    AGLeaderboard *leaderboard = [AGLeaderboard leaderboardWithID:kSpinLeaderboard];
    [leaderboard submitWithScore:gameScore completionHandler:^(NSDictionary *rank, NSDictionary *rankImproved, NSError *error) {
        if (error)
        {
            NSLog(@"OOPS, could not submit new score for leaderboard '%@' : %@", kSpinLeaderboard, error);
        }
        else
        {
            NSLog(@"Successfully increased score...");
            [self.score setText:[NSString stringWithFormat:@"%lld", gameScore]];
            NSArray *keys = [rank allKeys];
            NSLog(@"rank dictionary...");
            for (NSString *key in keys)
            {
                NSNumber *number = [rank objectForKey:key];
                NSLog(@"\tkey:%@ value:%@", key, number);
            }
            
            keys = [rankImproved allKeys];
            NSLog(@"rankImproved dictionary...");
            for (NSString *key in keys)
            {
                NSNumber *number = [rankImproved objectForKey:key];
                NSLog(@"\tkey:%@ value:%@", key, number);
            }
        }
    }];
}

- (IBAction)showGameCircle:(id)sender
{
    if ([self isSignedIn])
    {
        [[AGOverlay sharedOverlay] showGameCircle:YES];
    }
    else
    {
        [[AGOverlay sharedOverlay] showWithState:AGOverlaySignIn animated:YES];
    }
}

- (IBAction)showAchievements:(id)sender
{
    if ([self isSignedIn])
    {
        [[AGOverlay sharedOverlay] showWithState:AGOverlayAchievements animated:YES];
    }
    else
    {
        [[AGOverlay sharedOverlay] showWithState:AGOverlaySignIn animated:YES];
    }
}

- (IBAction)showLeaderboards:(id)sender
{
    if ([self isSignedIn])
    {
        [[AGOverlay sharedOverlay] showWithState:AGOverlayLeaderboards animated:YES];
    }
    else
    {
        [[AGOverlay sharedOverlay] showWithState:AGOverlaySignIn animated:YES];
    }
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

- (NSString *)_md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[16];
    CC_MD5(cStr, strlen(cStr), digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i=0; i<CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

#define kNumberKey0 @"NumberKey0"
#define kNumberKey1 @"NumberKey1"
#define kNumberKey2 @"NumberKey2"
#define kAccumulatingNumberKey @"AccumulatingNumberKey"
#define kStringKey @"StringKey"
#define kDeveloperStringKey @"kDeveloperStringKey"

#define kSubGameMapKey @"SubGameMapKey"

#define kNumberListKey @"NumberListKey0"
#define kSyncableStringList @"SyncableStringList"
#define kSyncableStringSet @"SyncableStringSet"

- (NSString *)_digestForCurrentData:(AGGameDataMap *)gameData
{
    AGSyncableNumber *syncableNum = nil;
    
    AGSyncableAccumulatingNumber *accumNum = [gameData accumulatingNumberForKey:kAccumulatingNumberKey];
    int32_t aNum = [[accumNum value] intValue];
    
    AGSyncableString *syncableString = [gameData latestStringForKey:kStringKey];
    AGSyncableDeveloperString *devString = [gameData developerStringForKey:kDeveloperStringKey];
    
    AGGameDataMap *subMap = [gameData mapForKey:kSubGameMapKey];
    AGSyncableString *subString = [subMap latestStringForKey:kStringKey];
    
    syncableNum = [gameData latestNumberForKey:kNumberKey0];
    int32_t intNumber = [[syncableNum value] intValue];
    syncableNum = [gameData latestNumberForKey:kNumberKey1];
    int64_t longLongNumber = [[syncableNum value] longLongValue];
    syncableNum = [gameData latestNumberForKey:kNumberKey2];
    double doubleNumber = [[syncableNum value] doubleValue];
    
    syncableNum = [gameData highestNumberForKey:kNumberKey0];
    int32_t intNumberHI = [[syncableNum value] intValue];
    syncableNum = [gameData highestNumberForKey:kNumberKey1];
    int64_t longLongNumberHI = [[syncableNum value] longLongValue];
    syncableNum = [gameData highestNumberForKey:kNumberKey2];
    double doubleNumberHI = [[syncableNum value] doubleValue];
    
    syncableNum = [gameData lowestNumberForKey:kNumberKey0];
    int32_t intNumberLO = [[syncableNum value] intValue];
    syncableNum = [gameData lowestNumberForKey:kNumberKey1];
    int64_t longLongNumberLO = [[syncableNum value] longLongValue];
    syncableNum = [gameData lowestNumberForKey:kNumberKey2];
    double doubleNumberLO = [[syncableNum value] doubleValue];
    
    NSString *data = [NSString stringWithFormat:@"%@ %@ %@ %d -- %@:%d %@:%lld %@:%lf -- %@:%d %@:%lld %@:%lf -- %@:%d %@:%lld %@:%lf",
                      [syncableString value], [devString value], [subString value], aNum,
                      kNumberKey0, intNumber,   kNumberKey1, longLongNumber,   kNumberKey2, doubleNumber,
                      kNumberKey0, intNumberHI, kNumberKey1, longLongNumberHI, kNumberKey2, doubleNumberHI,
                      kNumberKey0, intNumberLO, kNumberKey1, longLongNumberLO, kNumberKey2, doubleNumberLO];
    
    NSString *digest = [self _md5:data];
    NSLog(@"----------------------------------------------------- DATA : %@", data);
    NSLog(@"----------------------------------------------------DIGEST : %@", digest);

    return digest;
}

#define RESET_METADATA() \
metadata = nil; \
if ((random() % 2) == 0) \
{ \
    metadata = [NSMutableDictionary dictionaryWithObject:[NSString stringWithFormat:@"metaobj %ld", random()] forKey:[NSString stringWithFormat:@"metakey %ld", random()]]; \
}

- (void)_printNumberList:(AGSyncableNumberList *)numberList type:(NSString *)type
{
    NSLog(@"Fetched Number list '%@' ...", type);
    NSLog(@"isSet     : %d", [numberList isSet]);
    NSLog(@"capacity  : %d", [numberList capacity]);
    NSLog(@"values...");
    NSArray *values = [numberList values];
    for (NSNumber *number in values)
    {
        NSLog(@"\tvalue : %@", number);
    }
}

- (void)_printStringList:(AGSyncableStringList *)syncableStringList type:(NSString *)type
{
    NSLog(@"Fetched String list '%@' ...", type);
    NSLog(@"isSet     : %d", [syncableStringList isSet]);
    NSLog(@"capacity  : %d", [syncableStringList capacity]);
    NSLog(@"values...");
    NSArray *values = [syncableStringList values];
    for (NSString *str in values)
    {
        NSLog(@"\tvalue : %@", str);
    }
}

- (void)_printStringSet:(AGSyncableStringSet *)syncableStringSet
{
    NSLog(@"Fetched String set ...");
    NSLog(@"isSet        : %d", [syncableStringSet isSet]);
    NSLog(@"contains foo : %d (should be 0)", [syncableStringSet contains:@"foo"]);
    NSLog(@"values...");
    NSArray *values = [syncableStringSet values];
    for (NSString *str in values)
    {
        NSLog(@"\tvalue : %@", str);
    }
}

- (void)_testOutputCurrentData
{
    AGGameDataMap *gameData = [[AGWhispersync sharedInstance] gameData];
    NSArray *keys = nil;
    
    keys = [gameData allLatestNumberKeys];
    NSLog(@"Fetched allLatestNumberKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allHighestNumberKeys];
    NSLog(@"Fetched allHighestNumberKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allLowestNumberKeys];
    NSLog(@"Fetched allLowestNumberKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allAccumulatingNumberKeys];
    NSLog(@"Fetched allAccumulatingNumberKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allLatestStringKeys];
    NSLog(@"Fetched allLatestStringKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allDeveloperStringKeys];
    NSLog(@"Fetched allDeveloperStringKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allMapKeys];
    NSLog(@"Fetched allMapKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    // ---
    
    keys = [gameData allHighNumberListKeys];
    NSLog(@"Fetched allHighNumberListKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allLowNumberListKeys];
    NSLog(@"Fetched allLowNumberListKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allLatestNumberListKeys];
    NSLog(@"Fetched allLatestNumberListKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allLatestStringListKeys];
    NSLog(@"Fetched allLatestStringListKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    keys = [gameData allStringSetKeys];
    NSLog(@"Fetched allStringSetKeys:");
    for (NSString *key in keys)
    {
        NSLog(@"\tkey : %@", key);
    }
    
    // ---
    // NOTE: printing AND setting values here...changes are not accounted for in data digest
    
    [self _printNumberList:[gameData highNumberListForKey:kNumberListKey] type:@"HighNumberList"];
    [self _printNumberList:[gameData lowNumberListForKey:kNumberListKey] type:@"LowNumberList"];
    [self _printNumberList:[gameData latestNumberListForKey:kNumberListKey] type:@"LatestNumberList"];
    
    [self _printStringList:[gameData latestStringListForKey:kSyncableStringList] type:@"LatestStringList"];
    [self _printStringSet:[gameData stringSetForKey:kSyncableStringSet]];
}

- (IBAction)whispersyncUpdate:(id)sender
{
    AGGameDataMap *gameData = [[AGWhispersync sharedInstance] gameData];
    NSMutableDictionary *metadata = nil;
    AGSyncableNumberList *numberList = nil;
    AGSyncableStringList *stringList = nil;
    AGSyncableStringSet *stringSet = nil;
    
    // Reset a bunch of Whispersync data ...

    // ---
    
    RESET_METADATA();
    
    numberList = [gameData highNumberListForKey:kNumberListKey];
    [numberList setCapacity:[numberList capacity]+1];
    [numberList addValue:[NSNumber numberWithInt:random()] withMetadata:metadata];
    
    RESET_METADATA();
    
    numberList = [gameData lowNumberListForKey:kNumberListKey];
    [numberList setCapacity:[numberList capacity]+1];
    [numberList addValue:[NSNumber numberWithInt:random()] withMetadata:metadata];
    
    RESET_METADATA();
    
    numberList = [gameData latestNumberListForKey:kNumberListKey];
    [numberList setCapacity:[numberList capacity]+1];
    [numberList addValue:[NSNumber numberWithInt:random()] withMetadata:metadata];
    
    RESET_METADATA();

    stringList = [gameData latestStringListForKey:kSyncableStringList];
    [stringList setCapacity:[stringList capacity]+1];
    [stringList addValue:[NSString stringWithFormat:@"string %ld", random()] withMetadata:metadata];

    RESET_METADATA();

    stringSet = [gameData stringSetForKey:kSyncableStringSet];
    NSString *fooVal = [NSString stringWithFormat:@"foo %ld", random()];
    AGSyncableStringElement *element = [stringSet valueWithName:fooVal];
    NSAssert([[element value] isEqualToString:fooVal], @"Value should be same as what was just set...");
    [stringSet addValue:[NSString stringWithFormat:@"string %ld", random()] withMetadata:metadata];
    
    // ---
    
    RESET_METADATA();
    
    AGSyncableNumber *syncableNumber0 = [gameData latestNumberForKey:kNumberKey0];
    [syncableNumber0 setValue:[NSNumber numberWithInt:(int32_t)random()] withMetadata:metadata];
    NSAssert([[syncableNumber0 metadata] isEqual:metadata], @"metadata should be the same");
    
    RESET_METADATA();
    
    AGSyncableNumber *syncableNumber1 = [gameData latestNumberForKey:kNumberKey1];
    [syncableNumber1 setValue:[NSNumber numberWithLongLong:(int64_t)random()] withMetadata:metadata];
    NSAssert([[syncableNumber1 metadata] isEqual:metadata], @"metadata should be the same");
    
    RESET_METADATA();
    
    AGSyncableNumber *syncableNumber2 = [gameData latestNumberForKey:kNumberKey1];
    [syncableNumber2 setValue:[NSNumber numberWithLongLong:(double)random()] withMetadata:metadata];
    NSAssert([[syncableNumber2 metadata] isEqual:metadata], @"metadata should be the same");
    
    RESET_METADATA();

    AGSyncableAccumulatingNumber *aNumber = [gameData accumulatingNumberForKey:kAccumulatingNumberKey];
    if ((random() % 4) == 0)
    {
        [aNumber incrementValue:[NSNumber numberWithInt:1]];
    }
    else
    {
        [aNumber decrementValue:[NSNumber numberWithInt:1]];
    }

    // ---
    
    RESET_METADATA();
    
    AGSyncableString *syncableString = [gameData latestStringForKey:kStringKey];
    [syncableString setValue:[NSString stringWithFormat:@"Random String %ld", random()] withMetadata:metadata];
    NSAssert([[syncableNumber2 metadata] isEqual:metadata], @"metadata should be the same");
    
    AGSyncableDeveloperString *developerString = [gameData developerStringForKey:kDeveloperStringKey];
    [developerString setValue:[NSString stringWithFormat:@"Random String %ld", random()]];
    NSLog(@"Developer String:");
    NSLog(@"inConflict : %d", [developerString inConflict]);
    NSLog(@"isSet      : %d", [developerString isSet]);
    NSLog(@"cloudValue : %@", [developerString cloudValue]);
    NSLog(@"cloudTimestamp : %lf", [developerString cloudTimestamp]);
    NSLog(@"timeimestamp : %lf", [developerString timestamp]);
    NSLog(@"value      : %@", [developerString value]);
    [developerString markAsResolved];

    RESET_METADATA();

    AGGameDataMap *subMap = [gameData mapForKey:kSubGameMapKey];
    AGSyncableString *subString = [subMap latestStringForKey:kStringKey];
    [subString setValue:[NSString stringWithFormat:@"Random Substring %ld", random()] withMetadata:metadata];

    // ---
    
    //[[AGWhispersync sharedInstance] synchronize];
}

#pragma mark -
#pragma mark Whispersync notifications

- (void)onDataUploadedToCloud:(NSNotification *)notification
{
    NSLog(@"onDataUploadedToCloud...");
    [self _testOutputCurrentData];
    NSString *digest = [self _digestForCurrentData:[[AGWhispersync sharedInstance] gameData]];
    [self.digestVal setText:digest];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"onDataUploadedToCloud..." message:@"New data uploaded to cloud (digest changed)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)onDiskWriteComplete:(NSNotification *)notification
{
    NSLog(@"onDiskWriteComplete...");
}

- (void)onFirstSynchronize:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"onFirstSynchronize..." message:@"onFirstSynchronize invoked ..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)onNewCloudData:(NSNotification *)notification
{
    NSLog(@"onNewCloudData...");
    [self _testOutputCurrentData];
    NSString *digest = [self _digestForCurrentData:[[AGWhispersync sharedInstance] gameData]];
    [self.digestVal setText:digest];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"onNewCloudData..." message:@"Received new cloud data (digest changed)..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)onThrottled:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"onThrottled..." message:@"GameCircle throttled you!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
