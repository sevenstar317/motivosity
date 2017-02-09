//
//  RecognitionVC.h
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "UIApplication+PopUp.h"

@interface RecognitionVC : UIViewController{

    UITextField *_activeField;
    NSTimer *listTimer;
    NSArray *companies;
    NSString *companyValueID;
    NSArray *users;
    NSDictionary *toUser;
    
    CGFloat cashGivingBalance;
}

@property CGFloat cashGivingBalance;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *roundedBoxes;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *oswaldLabels;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutlet UIView *searchBox;
@property (strong, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet UIView *commentBox;
@property (strong, nonatomic) IBOutlet UIButton *postBtn;
@property (strong, nonatomic) IBOutlet UITextField *commentField;
@property (strong, nonatomic) IBOutlet UIView *mainCanteiner;
@property (strong, nonatomic) IBOutlet UILabel *selectedCompanyLabel;
@property (strong, nonatomic) IBOutlet UIImageView *userToAvatar;
@property (strong, nonatomic) IBOutlet UITextField *amount;

@property (nonatomic, retain) NSDictionary *toUser;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSString *companyValueID;
@property (nonatomic, retain) NSArray *companies;
@property (nonatomic, retain) NSTimer *listTimer;
@property (strong, nonatomic) IBOutlet UIView *bottomInputBox;
@property (strong, nonatomic) IBOutlet UIView *bottomMenuBar;
@property (strong, nonatomic) IBOutlet UIView *companySelectView;
@property (strong, nonatomic) IBOutlet UIPickerView *companyPicker;
@property (strong, nonatomic) IBOutlet UITableView *usersTable;
@property (strong, nonatomic) IBOutlet UILabel *receivedLabel;
@property (strong, nonatomic) IBOutlet UILabel *givingLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *menuButtons;

- (IBAction)editingBegin:(id)sender;
- (IBAction)goToHomeAction:(id)sender;
- (IBAction)goToRecognitionAction:(id)sender;
- (IBAction)goToCartAction:(id)sender;
- (IBAction)goToMoreAction:(id)sender;

- (IBAction)postAction:(id)sender;
- (IBAction)companySelectAction:(id)sender;
- (IBAction)companyCancelAction:(id)sender;
- (IBAction)companySetAction:(id)sender;


- (IBAction)fieldChange:(id)sender;

- (void)startTimer;
- (void)stopTimer;

- (void)dataRefresh;

@end
