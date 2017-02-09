//
//  MoreVC.h
//  Motivosity
//
//  Created by mr on 07.01.15.
//  Copyright (c) 2015 MM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreVC : UIViewController{

    NSString *userAvaUrl;
    NSString *userFullName;
    UIImage *userAvatar;
}

- (IBAction)goToHomeAction:(id)sender;
- (IBAction)goToRecognitionAction:(id)sender;
- (IBAction)goToCartAction:(id)sender;
- (IBAction)goToMoreAction:(id)sender;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *oswaldLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *menuButtons;
@property (strong, nonatomic) IBOutlet UILabel *receivedLabel;
@property (strong, nonatomic) IBOutlet UILabel *givingLabel;
@property (strong, nonatomic) UIImage *userAvatar;

@property (strong, nonatomic) NSString *userAvaUrl;
@property (strong, nonatomic) NSString *userFullName;

@property (strong, nonatomic) IBOutlet UIView *tableHeader;
@property (strong, nonatomic) IBOutlet UITableView *moreTable;
@end
