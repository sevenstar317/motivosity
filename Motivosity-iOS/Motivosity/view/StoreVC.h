//
//  StoreVC.h
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StoreCell.h"
#import "CartCell.h"

#import "MBProgressHUD.h"

@interface StoreVC : UIViewController<UIAlertViewDelegate>{

    NSArray *storeDigital;
    NSArray *storeLocal;
    NSArray *storeCharity;
    NSDictionary *selectedCartItem;
    NSMutableArray *countFields;
    
    CGFloat cashReceivedBalance;
    MBProgressHUD *p;
}

@property CGFloat cashReceivedBalance;

@property (strong, nonatomic) NSArray *storeDigital;
@property (strong, nonatomic) NSArray *storeLocal;
@property (strong, nonatomic) NSArray *storeCharity;

@property (strong, nonatomic)  NSMutableArray *countFields;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *oswaldLabels;
@property (strong, nonatomic) IBOutlet UIView *storeTableHeader;
@property (strong, nonatomic) IBOutlet UITableView *storeTable;
@property (strong, nonatomic) IBOutlet UIButton *cartBtn;
@property (strong, nonatomic) IBOutlet UILabel *givingLabel;
@property (strong, nonatomic) IBOutlet UILabel *receivedLabel;

@property (strong, nonatomic) IBOutlet UIView *cartView;
@property (strong, nonatomic) NSDictionary *selectedCartItem;
@property (strong, nonatomic) IBOutlet UITableView *cartTable;

- (IBAction)goToHomeAction:(id)sender;
- (IBAction)goToRecognitionAction:(id)sender;
- (IBAction)goToCartAction:(id)sender;
- (IBAction)goToMoreAction:(id)sender;

- (void)addToCartDigitalAction:(id)sender;
- (void)addToCartLocalAction:(id)sender;
- (void)addToCartCauseAction:(id)sender;
- (void)afterPurchaseResponse:(NSDictionary *)resp;
- (void)afterPurchaseResponseError;

@property (strong, nonatomic) IBOutlet UIButton *orderBtn;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *latoBtns;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *cartTableSeparators;
@property (strong, nonatomic) IBOutlet UILabel *cartTotal;
@property (strong, nonatomic) IBOutlet UILabel *noItemsLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *menuButtons;

- (IBAction)clearCartAction:(id)sender;
- (void)showCartAlert;
- (void)addItemToCart:(CGFloat)price itemID:(NSString *)storeItemID;
- (IBAction)viewCartAction:(id)sender;
- (void)reloadCartInformation;
- (void)removeCartItemByID:(NSString *)itemID;
- (void)updateCountForItem:(NSString *)itemID count:(int)count;
- (CGFloat)getCartTotal;
- (IBAction)placeOrderAction:(id)sender;
- (void)reloadCashInfo;

@end
