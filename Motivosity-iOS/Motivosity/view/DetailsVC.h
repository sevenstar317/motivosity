//
//  DetailsVC.h
//  Motivosity
//
//  Created by mr on 05.10.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"

@interface DetailsVC : UIViewController{

    CGFloat contentH;
    NSDictionary *oneItem;
    NSArray *comments;
    NSDictionary *currentUserRow;
}

@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UIView *icon;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutlet UIView *bottomInputBox;
@property (strong, nonatomic) IBOutlet UIView *mainCanteiner;
@property (strong, nonatomic) IBOutlet UIButton *postBtn;
@property (strong, nonatomic) IBOutlet UITextField *commentField;
@property (strong, nonatomic) IBOutlet UIView *commentBox;
@property (strong, nonatomic) IBOutlet UITableView *commentsTable;
@property (strong, nonatomic) IBOutlet UIImageView *iconImg;
@property (strong, nonatomic) IBOutlet UILabel *autor;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *mrTitle;
@property (strong, nonatomic) IBOutlet UILabel *textBoxContent;

@property (strong, nonatomic) NSArray *comments;
@property (strong, nonatomic) NSDictionary *oneItem;
@property (strong, nonatomic) NSDictionary *currentUserRow;


- (IBAction)backAction:(id)sender;
- (IBAction)commentPostAction:(id)sender;

- (void)reloadData;
- (void)likeCountInc:(NSDictionary *)newItem;

@end
