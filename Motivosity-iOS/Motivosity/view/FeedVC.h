//
//  FeedVC.h
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TTTAttributedLabel.h"
#import "FeedCell.h"

@interface FeedVC : UIViewController{

    NSMutableArray *feed;
    NSArray *menuTypes;
    NSString *selectedMenu;
    int currentPage;
    UIRefreshControl *refreshControl;
    NSDictionary *currentUserRow;
}

@property int currentPage;
@property (strong, nonatomic) NSMutableArray *feed;
@property (strong, nonatomic) NSArray *menuTypes;
@property (strong, nonatomic) NSString *selectedMenu;
@property (strong, nonatomic) NSDictionary *currentUserRow;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *oswaldLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *menuButtons;

@property (strong, nonatomic) IBOutlet UITableView *feedTable;
@property (strong, nonatomic) IBOutlet UIView *feedTableHeader;
@property (strong, nonatomic) IBOutlet UIImageView *userImg;

- (IBAction)goToHomeAction:(id)sender;
- (IBAction)goToRecognitionAction:(id)sender;
- (IBAction)goToCartAction:(id)sender;
- (IBAction)goToMoreAction:(id)sender;

- (void)reloadData:(BOOL)andCache;
- (void)reloadCashAndUser;
- (IBAction)selectMenuAction:(id)sender;
- (IBAction)menuCancelAction:(id)sender;
- (IBAction)menuSetAction:(id)sender;
- (void)likeCountInc:(NSDictionary *)newItem;
- (void)reloadAfterAppreciation;
- (void)reloadAfterLogin;
- (void)addCommentToFeed:(NSString *)itemID commentDist:(NSDictionary *)commentResp;

@property (strong, nonatomic) IBOutlet UILabel *receivedLabel;
@property (strong, nonatomic) IBOutlet UILabel *givingLabel;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIView *typeSelectView;
@property (strong, nonatomic) IBOutlet UIPickerView *menuPicker;

@end
