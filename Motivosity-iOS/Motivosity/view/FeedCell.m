//
//  FeedCell.m
//  Motivosity
//
//  Created by mr on 24.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "FeedCell.h"

#import "DetailsVC.h"

#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"

@implementation FeedCell

@synthesize oneItem;

- (void)awakeFromNib {
    // Initialization code
    
    self.avatar.layer.cornerRadius = 2;
    self.avatar.layer.masksToBounds = YES;
     
    self.icon.layer.cornerRadius = 4;
    self.icon.layer.masksToBounds = YES;
     
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
    
    //[self.likeBtn.titleLabel setFont:[UIFont fontWithName:@"Lato" size:self.likeBtn.titleLabel.font.pointSize]];
    for (UIButton *oneB in self.latoBtns){
        [oneB.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:oneB.titleLabel.font.pointSize]];
    }
    
    [self.textBoxContent setFont:[UIFont fontWithName:@"Lato-Light" size:self.textBoxContent.font.pointSize]];
    
    self.whiteBox.layer.shadowColor = [UIColor blackColor].CGColor;
    self.whiteBox.layer.shadowOpacity = 0.4f;
    self.whiteBox.layer.shadowOffset = CGSizeMake(0, 6);
    
    [self.buttonsSep setFrame:CGRectMake(self.buttonsSep.frame.origin.x - 0.5f, self.buttonsSep.frame.origin.y, 0.5f, self.buttonsSep.frame.size.height)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCellInfo{

    NSArray *likes = [self.oneItem objectForKey:@"likes"];
    NSArray *comments = [self.oneItem objectForKey:@"commentList"];
    
    NSDictionary *subject = [self.oneItem objectForKey:@"subject"];
    //NSDictionary *source = [self.oneItem objectForKey:@"source"];
    
    NSString *realTitle = [Motivosity getTitleFromDict:self.oneItem];
   
    [self.title setText:[NSString stringWithFormat:@"%@",realTitle]];
    [self.time setText:[NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"readableDate"]]];
    [self.icon setBackgroundColor:[UIColor colorWithHexString:[self.oneItem objectForKey:@"feedIconColor"]]];
    
    [self.likesBtn setTitle:[NSString stringWithFormat:@"%d likes",(int)likes.count] forState:UIControlStateNormal];
    [self.commentsBtn setTitle:[NSString stringWithFormat:@"%d comments",(int)comments.count] forState:UIControlStateNormal];
    
    [self.iconImg setImage:[Motivosity iconFromType:[self.oneItem objectForKey:@"feedIconClass"]]];
        
    [self.autor setText:[NSString stringWithFormat:@"%@",[subject objectForKey:@"fullName"]]];
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[subject objectForKey:@"avatarUrl"]]] placeholderImage:nil];
    
    CGSize maximumLabelSize = CGSizeMake(312,9999);
    
    NSString *contentStr = @"";
    if ([self.oneItem objectForKey:@"note"] != nil && ![[self.oneItem objectForKey:@"note"] isEqual:[NSNull null]]) {
        contentStr = [NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"note"]];
    }
    
    CGSize expectedLabelSize = [contentStr sizeWithFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]
                                      constrainedToSize:maximumLabelSize
                                          lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat featureH = expectedLabelSize.height + 8.0f;
    
    
    NSString *contentStrTitle = @"";
    if (![realTitle isEqual:[NSNull null]])
    {
        contentStrTitle = [NSString stringWithFormat:@"%@",realTitle];
    }
    
    CGSize expectedLabelSizeTitle = [contentStrTitle sizeWithFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]
                                                constrainedToSize:maximumLabelSize
                                                    lineBreakMode:NSLineBreakByCharWrapping];
    
    CGFloat featureHTitle = expectedLabelSizeTitle.height;

    [self.title setFrame:CGRectMake(self.title.frame.origin.x, self.title .frame.origin.y, self.title .frame.size.width, featureHTitle )];
    
    
    [self.whiteBox setFrame:CGRectMake(self.whiteBox.frame.origin.x, self.whiteBox.frame.origin.y, self.whiteBox.frame.size.width, 106.0f + featureH + featureHTitle)];
    
    [self.textBoxContent setFrame:CGRectMake(self.textBoxContent.frame.origin.x, 52.0f + featureHTitle, self.textBoxContent.frame.size.width, featureH )];
    
//    contentStr = @"\U0001F60A";
    
//    const char* utf8 = contentStr.UTF8String;
    
    [self.textBoxContent setText:contentStr];
}

- (IBAction)likeAction:(id)sender {
    
    /*MBProgressHUD *p = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow]];
    [p setDimBackground:YES];
    [p setLabelText:@"Loading"];
    [p setMode:MBProgressHUDModeIndeterminate];
    [p show:YES];
    [p setRemoveFromSuperViewOnHide:YES];
    [[[UIApplication sharedApplication] keyWindow] addSubview:p];*/
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary *likeResp = [[mrAPI sharedInstance] postLike:[self.oneItem objectForKey:@"id"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSLog(@"-- %@",likeResp);
            
            //[p hide:YES];
            
            [APPDELEGATE.feed likeCountInc:likeResp];
        });
    });
}

- (IBAction)goToDetails:(id)sender {
    
    if(APPDELEGATE.feed.currentUserRow != nil)
    {
        DetailsVC *details = [[DetailsVC alloc] initWithNibName:@"DetailsVC" bundle:nil];
        details.currentUserRow = APPDELEGATE.feed.currentUserRow;
        details.oneItem = self.oneItem;
        [APPDELEGATE.feedNavi pushViewController:details animated:YES];
    }
}


@end
