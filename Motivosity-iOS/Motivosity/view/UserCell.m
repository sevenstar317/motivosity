//
//  UserCell.m
//  Motivosity
//
//  Created by mr on 20.10.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "UserCell.h"

#import "UIImageView+WebCache.h"

@implementation UserCell

@synthesize oneItem;

- (void)awakeFromNib {
    // Initialization code
    
    self.avatar.layer.cornerRadius = 2;
    self.avatar.layer.masksToBounds = YES;
    
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo{
    
    [self.name setText:[NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"fullName"]]];
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[self.oneItem objectForKey:@"avatarUrl"]]] placeholderImage:nil];
}

@end
