//
//  SpinParseView.m
//  Spin
//
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "SpinParseView.h"

#import <Parse/Parse.h>

#define SPIN_OBJECT @"SpinTestObject"

#define kObjectIdKey @"objectId"
#define kStringKey @"stringValue"
#define kFloatKey @"floatValue"
#define kIntegerKey @"intValue"
#define kBoolKey @"boolValue"
#define kBlobKey @"blobValue"
#define kArrayKey @"arrayValue"
#define kDictKey @"dictValue"

@interface SpinParseView()

@property (nonatomic, retain) PFObject *theObj;

@end

@implementation SpinParseView
{
    int _intValue;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [_cloudValueInput release]; _cloudValueInput=nil;
    [_theObj release]; _theObj=nil;
    [_aBoolValue release]; _aBoolValue=nil;
    [_anIntegerValue release]; _anIntegerValue=nil;
    [_aFloatValue release]; _aFloatValue=nil;
    [_booleanSwitch release]; _booleanSwitch=nil;
    [_floatSlider release]; _floatSlider=nil;
    [_objectIdValue release]; _objectIdValue=nil;
    [_spinney release]; _spinney=nil;
    [super dealloc];
}

- (void)setupView
{    
    [self setBackgroundColor:[UIColor grayColor]];
    NSLog(@"-------------------------initWithView");
    
    [_spinney startAnimating];
    [self reloadCloudObject:nil];
}

- (IBAction)saveCloudObject:(id)sender {
    NSLog(@"-------------------------saveCloudValue");
    
    [_spinney setHidden:NO];
    
    if (!_theObj)
    {
        NSLog(@"Creating new cloud object...");
        [self newCloudObject:nil];
    }
    
    NSString *val = [_cloudValueInput text];
    [_theObj setObject:val forKey:kStringKey];
    
    NSNumber *boolNumber = [NSNumber numberWithBool:[_booleanSwitch isOn]];
    NSNumber *intNumber = [NSNumber numberWithInt:_intValue];
    NSNumber *floatNumber = [NSNumber numberWithFloat:[_floatSlider value]];
    
    [_theObj setObject:boolNumber forKey:kBoolKey];
    [_theObj setObject:floatNumber forKey:kFloatKey];
    [_theObj setObject:intNumber forKey:kIntegerKey];
    
    char buf[4];
    buf[0] = (_intValue << 24) & 0xff;
    buf[1] = (_intValue << 16) & 0xff;
    buf[2] = (_intValue << 8) & 0xff;
    buf[3] = _intValue & 0xff;
    NSData *blob = [NSData dataWithBytes:buf length:4];
    [_theObj setObject:blob forKey:kBlobKey];
    
    // Also save array and dictionary to the cloud...
    NSArray *array = [NSArray arrayWithObjects:val, boolNumber, intNumber, floatNumber, nil];
    [_theObj setObject:array forKey:kArrayKey];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:42], @"theAnswer", array, @"encapsulatedArray", nil];
    NSDictionary *superDict = [NSDictionary dictionaryWithObjectsAndKeys:dict, @"subdict", nil];
    [_theObj setObject:superDict forKey:kDictKey];

    BOOL isNew = [_theObj objectId] == nil;
    [_theObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_spinney setHidden:YES];
        if (succeeded)
        {
            NSLog(@"cloud save completed successfully");
            if (isNew)
            {
                [self reloadCloudObject:nil];
            }
        }
        else
        {
            NSLog(@"oops, did not save!");
        }
    }];
    
    // Block save (in foreground)
    //[_theObj save];
}

- (void)reloadedObject:(PFObject*)obj error:(NSError*)error
{
    [_spinney setHidden:YES];
    if (error)
    {
        NSLog(@"reload cloud object error : %@", error);
    }
    
    if (!obj)
    {
        NSLog(@"no object(s) returned");
        return;
    }
    
    [self setTheObj:obj];
    [_objectIdValue setText:[obj objectId]];
    
    NSData *blob = [obj objectForKey:kBlobKey];
    NSLog(@"blob data received : %@", [blob description]);
    
    NSArray *array = [obj objectForKey:kArrayKey];
    NSLog(@"array received : %@", [array description]);
    
    NSDictionary *dict = [obj objectForKey:kDictKey];
    NSLog(@"dict received : %@", [dict description]);
    
    NSString *str = [obj objectForKey:kStringKey];
    [_cloudValueInput setText:str];
    
    NSNumber *number = [obj objectForKey:kIntegerKey];
    _intValue = [number integerValue];
    [_anIntegerValue setText:[number description]];
    
    number = [obj objectForKey:kFloatKey];
    [_floatSlider setValue:[number floatValue]];
    [_aFloatValue setText:[number description]];
    
    number = [obj objectForKey:kBoolKey];
    [_booleanSwitch setOn:[number boolValue]];
    [_aBoolValue setText:[number description]];
}

- (IBAction)reloadCloudObject:(id)sender {
    NSLog(@"-------------------------reloadCloudValue");
    
    [_spinney setHidden:NO];
    
    // background fetch:
    PFQuery *query = [PFQuery queryWithClassName:SPIN_OBJECT];
    NSString *objId = [_theObj objectId];
    if (objId)
    {
        [query whereKey:kObjectIdKey equalTo:objId];
    }
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *obj, NSError *error) {
        [self reloadedObject:obj error:error];
    }];
    
    // -- OR --
    // foreground fetch:
    //PFObject *obj = [PFQuery getObjectOfClass:@"TestObject" objectId:@"b5Ha2cyj3C"];
    //[self reloadedObject:obj error:nil];
}

- (IBAction)newCloudObject:(id)sender {
    PFObject *obj = [[PFObject alloc] initWithClassName:SPIN_OBJECT];
    [self setTheObj:obj];
    [obj release];
    [_objectIdValue setText:@"(none)"];
}

- (IBAction)deleteCloudObject:(id)sender {
    [_spinney setHidden:NO];
    [_theObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_spinney setHidden:YES];
        if (succeeded)
        {
            NSLog(@"deleted object %@ in background", [_theObj objectId]);
            [self setTheObj:nil];
            [_objectIdValue setText:@"(none)"];
            [self reloadCloudObject:nil];
        }
        else
        {
            NSLog(@"problem deleting object %@ in background : %@", [_theObj objectId], error);
            return;
        }
    }];
}

- (IBAction)setBooleanValue:(id)sender {
    BOOL isOn = [_booleanSwitch isOn];
    [_aBoolValue setText:isOn ? @"1" : @"0"];
}

- (IBAction)decrementValue:(id)sender {
    _intValue-=1;
    [_anIntegerValue setText:[[NSNumber numberWithInt:_intValue] description]];
}

- (IBAction)incrementValue:(id)sender {
    _intValue+=1;
    [_anIntegerValue setText:[[NSNumber numberWithInt:_intValue] description]];
}

- (IBAction)setFloatValue:(id)sender {
    [_aFloatValue setText:[[NSNumber numberWithFloat:[_floatSlider value]] description]];
}

@end
