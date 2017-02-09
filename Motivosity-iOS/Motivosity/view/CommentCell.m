//
//  CommentCell.m
//  Motivosity
//
//  Created by mr on 19.10.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "CommentCell.h"

#import "UIImageView+WebCache.h"

@implementation CommentCell

@synthesize oneItem;

- (void)awakeFromNib {
    
    self.separat.frame = CGRectMake(self.separat.frame.origin.x, self.separat.frame.origin.y, self.separat.frame.size.width, 0.5f);
    
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
    
    [self.textBoxContent setFont:[UIFont fontWithName:@"Lato-Light" size:self.textBoxContent.font.pointSize]];
    
    self.avatar.layer.cornerRadius = 2;
    self.avatar.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellContent{

    NSString *content =  [NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"commentText"]];
    
    CGSize maximumLabelSize = CGSizeMake(252, CGFLOAT_MAX);
    CGRect expectedLabelSize  = [content boundingRectWithSize:maximumLabelSize
                                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                   attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Lato-Light" size:14.0f]}
                                                      context:nil];
    
    CGFloat featureH = expectedLabelSize.size.height;
    
    
    [self.separat setFrame:CGRectMake(self.separat.frame.origin.x, 44.0f + featureH - 6.0f, self.separat.frame.size.width, self.separat.frame.size.height)];
    [self.textBoxContent setFrame:CGRectMake(self.textBoxContent.frame.origin.x, self.textBoxContent.frame.origin.y, self.textBoxContent.frame.size.width, featureH )];
    [self.textBoxContent setText:content];
    [self.timeLabel setFrame:CGRectMake(self.timeLabel.frame.origin.x, 28.0f + featureH  - 6.0f, self.timeLabel.frame.size.width, self.timeLabel.frame.size.height)];
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"readableCreatedDate"]]];
    
    NSDictionary *user = [self.oneItem objectForKey:@"user"];
    [self.username setText:[NSString stringWithFormat:@"%@",[user objectForKey:@"fullName"]]];
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[user objectForKey:@"avatarUrl"]]] placeholderImage:nil];
}

@end
