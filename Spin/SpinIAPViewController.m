//
//  SpinIAPViewController.m
//  Spin
//
//  Created by Glenna Buford on 8/12/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "SpinIAPViewController.h"
#import <StoreKit/StoreKit.h>

@interface SpinIAPViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, retain) SKProductsRequest *productsRequest;
@property (nonatomic, retain) SKProductsResponse *productsList;
@property (retain, nonatomic) IBOutlet UIButton *nonConsumable;
@property (retain, nonatomic) IBOutlet UILabel *consumablePrice;
@property (retain, nonatomic) IBOutlet UILabel *nonconsumablePrice;

@end

@implementation SpinIAPViewController

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
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self requestProductData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [_productsRequest release];
    [_productsList release];
    [_nonConsumable release];
    [_consumablePrice release];
    [_nonconsumablePrice release];
    [super dealloc];
}

- (void)requestProductData
{
    NSSet *productIdentifiers = [NSSet setWithObjects:@"com.apportable.spin.consumable1", @"com.apportable.spin.nonconsumable1", nil];
    [self setProductsRequest: [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers]];
    [[self productsRequest] setDelegate:self];
    
    NSLog(@"Requesting IAP product data...");
    [[self productsRequest] start];
}

- (IBAction)purchaseConsumableItem:(id)sender
{
    NSArray *products = [[self productsList] products];
    if ([products count]) {
        NSLog(@"purchasing first item");
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"com.apportable.spin.consumable1"];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        NSLog(@"NOT purchasing first item, products count:%u", [products count]);
    }
}

- (IBAction)purchaseNonConsumableItem:(id)sender
{
    NSArray *products = [[self productsList] products];
    if ([products count] > 1) {
        NSLog(@"purchasing second item");
        SKPayment *payment = [SKPayment paymentWithProductIdentifier:@"com.apportable.spin.nonconsumable1"];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        NSLog(@"NOT purchasing second item, products count:%u", [products count]);
    }
}

- (IBAction)restorePurchases:(id)sender
{
    NSLog(@"restoring purchases");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [self setProductsList:response];
    NSArray *products = response.products;
    for (int i=0; i < [products count]; ++i) {
        SKProduct *product = [products objectAtIndex:i];
        if (product) {
            NSLog(@"Product id: %@" , product.productIdentifier);
            NSLog(@"Product title: %@" , product.localizedTitle);
            NSLog(@"Product description: %@" , product.localizedDescription);
            NSLog(@"Product price: %@" , product.price);
            NSLog(@"Product price locale: %@" , product.priceLocale);
            if ([product.productIdentifier isEqualToString:@"com.apportable.spin.consumable1"]) {
                self.consumablePrice.text = [[product price] stringValue];
            } else if ([product.productIdentifier isEqualToString:@"com.apportable.spin.nonconsumable1"]) {
                self.nonconsumablePrice.text = [[product price] stringValue];
            }
        }
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        NSLog(@"INVALID PRODUCT ID: %@" , invalidProductId);
    }
}


#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSLog(@"----------------------------paymentQueue:updatedTransactions:");
    
    for (SKPaymentTransaction *txn in transactions) {
        switch (txn.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"SKPaymentTransactionStatePurchasing txn: %@", txn);
                break;
            case SKPaymentTransactionStatePurchased:
                NSLog(@"SKPaymentTransactionStatePurchased: %@", txn);
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"SKPaymentTransactionStateFailed: %@", txn);
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"SKPaymentTransactionStateRestored: %@", txn);
                NSLog(@"Original transaction: %@", [txn originalTransaction]);
                NSLog(@"Original transaction payment: %@", [[txn originalTransaction] payment]);
                if ([txn.payment.productIdentifier isEqualToString:@"com.apportable.spin.nonconsumable1"]) {
                    [self.nonConsumable setBackgroundColor:[UIColor grayColor]];
                    self.nonConsumable.enabled = NO;
                }
                break;
            default:
                NSLog(@"UNKNOWN SKPaymentTransactionState: %@", txn);
                break;
        }
        [[SKPaymentQueue defaultQueue] finishTransaction:txn];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
    NSLog(@"----------------------------paymentQueue:removedTransactions:");
    for (SKPaymentTransaction *txn in transactions) {
        NSLog(@"removed transaction: %@", txn);
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"----------------------------paymentQueue:restoreCompletedTransactionsFailedWithError: %@", error);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"----------------------------paymentQueueRestoreCompletedTransactionsFinished:");
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    NSLog(@"----------------------------paymentQueue:updatedDownloads:");
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
