//
//  SpinIAPView.m
//  Spin
//
//  Copyright (c) 2013 Apportable. All rights reserved.
//

// For testing IAP

#import "SpinIAPView.h"

@interface SpinIAPView()
    
@property (nonatomic, retain) SKProductsRequest *productsRequest;
@property (nonatomic, retain) SKProductsResponse *productsList;

@end

@implementation SpinIAPView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        // Initialization code
        [self initView];
    }
    return self;
}

- (void)dealloc {
    [_productsRequest release];
    [_productsList release];
    [super dealloc];
}

- (void)initView
{    
    [self setBackgroundColor:[UIColor grayColor]];
    NSLog(@"-------------------------initWithView");
    
    UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *str1 = @"restore purchases";
    [restoreButton setTitle:str1 forState:UIControlStateNormal];
    [restoreButton setTitle:str1 forState:UIControlStateHighlighted];
    [restoreButton setTitle:str1 forState:UIControlStateSelected];
    [restoreButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [restoreButton setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [restoreButton setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [restoreButton setFrame:CGRectMake(10.0, 10.0, 150, 44)];
    [restoreButton setBackgroundColor:[UIColor redColor]];
    [self addSubview:restoreButton];
    [restoreButton addTarget:self action:@selector(restorePurchases) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *purchaseFirst = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *str2 = @"purchase item 1";
    [purchaseFirst setTitle:str2 forState:UIControlStateNormal];
    [purchaseFirst setTitle:str2 forState:UIControlStateHighlighted];
    [purchaseFirst setTitle:str2 forState:UIControlStateSelected];
    [purchaseFirst setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [purchaseFirst setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [purchaseFirst setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [purchaseFirst setFrame:CGRectMake(10.0, 70.0, 150, 44)];
    [purchaseFirst setBackgroundColor:[UIColor redColor]];
    [self addSubview:purchaseFirst];
    [purchaseFirst addTarget:self action:@selector(purchaseFirstItem) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *purchaseSecond = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *str3 = @"purchase item 2";
    [purchaseSecond setTitle:str3 forState:UIControlStateNormal];
    [purchaseSecond setTitle:str3 forState:UIControlStateHighlighted];
    [purchaseSecond setTitle:str3 forState:UIControlStateSelected];
    [purchaseSecond setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [purchaseSecond setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
    [purchaseSecond setTitleColor:[UIColor greenColor] forState:UIControlStateSelected];
    [purchaseSecond setFrame:CGRectMake(10.0, 130.0, 150, 44)];
    [purchaseSecond setBackgroundColor:[UIColor redColor]];
    [self addSubview:purchaseSecond];
    [purchaseSecond addTarget:self action:@selector(purchaseSecondItem) forControlEvents:UIControlEventTouchUpInside];
    
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [self requestProductData];
    });
}

- (void)requestProductData
{
    NSSet *productIdentifiers = [NSSet setWithObjects:@"com.apportable.spin.consumable1", @"com.apportable.spin.nonconsumable1", nil];
    [self setProductsRequest: [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers]];
    [[self productsRequest] setDelegate:self];
    
    NSLog(@"Requesting IAP product data...");
    [[self productsRequest] start];
}

- (void)purchaseFirstItem
{
    NSArray *products = [[self productsList] products];
    if ([products count]) {
        NSLog(@"purchasing first item");
        SKPayment *payment = [SKPayment paymentWithProduct:[products objectAtIndex:0]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        NSLog(@"NOT purchasing first item, products count:%u", [products count]);
    }
}

- (void)purchaseSecondItem
{
    NSArray *products = [[self productsList] products];
    if ([products count] > 1) {
        NSLog(@"purchasing second item");
        SKPayment *payment = [SKPayment paymentWithProduct:[products objectAtIndex:1]];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    } else {
        NSLog(@"NOT purchasing second item, products count:%u", [products count]);
    }
}

- (void)restorePurchases
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
