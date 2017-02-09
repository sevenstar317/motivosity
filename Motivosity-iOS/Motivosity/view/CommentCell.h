//
//  CommentCell.h
//  Motivosity
//
//  Created by mr on 19.10.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell{
    NSDictionary *oneItem;
}

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *textBoxContent;
@property (strong, nonatomic) NSDictionary *oneItem;
@property (strong, nonatomic) IBOutlet UIImageView *separat;

- (void)setCellContent;

@end
