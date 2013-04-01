//
//  SpinIAPView.h
//  Spin
//
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface SpinIAPView : UIView <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end
