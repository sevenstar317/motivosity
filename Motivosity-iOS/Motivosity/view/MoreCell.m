//
//  MoreCell.m
//  Motivosity
//
//  Created by mr on 07.01.15.
//  Copyright (c) 2015 MM. All rights reserved.
//

#import "MoreCell.h"

@implementation MoreCell

- (void)awakeFromNib {
    
    self.img.layer.cornerRadius = 2;
    self.img.layer.masksToBounds = YES;
    
    self.imgBG.layer.cornerRadius = 2;
    self.imgBG.layer.masksToBounds = YES;
    
    [self.cellTitle setFont:[UIFont fontWithName:@"Lato-Bold" size:self.cellTitle.font.pointSize]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
