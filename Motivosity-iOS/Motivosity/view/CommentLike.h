//
//  CommentLike.h
//  Motivosity
//
//  Created by mr on 19.10.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CommentLike : UITableViewCell{
    NSDictionary *oneItem;
    id detailsScreen;
}

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UIButton *likeBtn;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *latoBtns;
@property (strong, nonatomic) IBOutlet UIImageView *separat;
@property (strong, nonatomic) IBOutlet UIImageView *topSeparat;
@property (strong, nonatomic) NSDictionary *oneItem;
@property (strong, nonatomic) id detailsScreen;

- (IBAction)likeAction:(id)sender;
- (void)setCellContent;
@end
