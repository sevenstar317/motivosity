//
//  FeedCell.h
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell{
    NSDictionary *oneItem;
}

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *latoBtns;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UIView *icon;
@property (strong, nonatomic) IBOutlet UIView *whiteBox;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *autor;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIButton *likesBtn;
@property (strong, nonatomic) IBOutlet UIButton *commentsBtn;
@property (strong, nonatomic) IBOutlet UILabel *textBoxContent;
@property (strong, nonatomic) IBOutlet UIImageView *iconImg;
@property (strong, nonatomic) IBOutlet UIImageView *buttonsSep;

@property (strong, nonatomic) NSDictionary *oneItem;

- (IBAction)goToDetails:(id)sender;
- (void)setCellInfo;
- (IBAction)likeAction:(id)sender;


@end
