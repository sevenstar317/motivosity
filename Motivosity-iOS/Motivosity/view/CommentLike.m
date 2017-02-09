//
//  CommentLike.m
//  Motivosity
//
//  Created by mr on 19.10.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "CommentLike.h"

#import "DetailsVC.h"

@implementation CommentLike

@synthesize oneItem;
@synthesize detailsScreen;

- (void)awakeFromNib {
    // Initialization code
    
    self.separat.frame = CGRectMake(self.separat.frame.origin.x, self.separat.frame.origin.y, self.separat.frame.size.width, 0.5f);
    self.topSeparat.frame = CGRectMake(self.topSeparat.frame.origin.x, self.topSeparat.frame.origin.y, self.topSeparat.frame.size.width, 0.5f);
    
    /*for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato" size:oneL.font.pointSize]];
    }*/
    
    [self.content setFont:[UIFont fontWithName:@"Lato-Light" size:self.content.font.pointSize]];
    
    for (UIButton *oneB in self.latoBtns){
        [oneB.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:oneB.titleLabel.font.pointSize]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
            
            //[p hide:YES];
            
            //NSLog(@"----!!! %@",likeResp);
        
            [APPDELEGATE.feed likeCountInc:likeResp];
                
            DetailsVC *details = (DetailsVC *)self.detailsScreen;
            [details likeCountInc:likeResp];
            
            [details.commentsTable reloadData];
        });
    });
}

- (void)setCellContent{

    //NSString *content =  @"Ann Perkins, Leslie Knope, and Ron Swanson like this.";
    NSString *content = [Motivosity getLikeStrFromDict:self.oneItem];
    
    CGSize maximumLabelSize = CGSizeMake(220, CGFLOAT_MAX);
    CGRect expectedLabelSize  = [content boundingRectWithSize:maximumLabelSize
                                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                   attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Lato-Light" size:14.0f]}
                                                      context:nil];
    
    CGFloat featureH = expectedLabelSize.size.height + 5.0f;
    
    if(featureH > 24)
    {
         [self.content setFrame:CGRectMake(self.content.frame.origin.x, self.content.frame.origin.y, self.content.frame.size.width, featureH)];
         [self.likeBtn setFrame:CGRectMake(self.likeBtn.frame.origin.x, (featureH - 16), self.likeBtn.frame.size.width, self.likeBtn.frame.size.height)];
         [self.separat setFrame:CGRectMake(self.separat.frame.origin.x, (featureH + 10) - 1, self.separat.frame.size.width, self.separat.frame.size.height)];
    }
    
    self.content.text = content;
}

@end
