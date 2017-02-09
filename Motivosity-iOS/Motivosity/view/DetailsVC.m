//
//  DetailsVC.m
//  Motivosity
//
//  Created by mr on 05.10.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "DetailsVC.h"

#import "CommentCell.h"
#import "CommentLike.h"

#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"

@interface DetailsVC ()

@end

@implementation DetailsVC

@synthesize oneItem;
@synthesize comments;
@synthesize currentUserRow;

- (void)handleTap:(UITapGestureRecognizer*)recognizer {

    [self.commentField resignFirstResponder];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(handleTap:)];
    
    [self.view addGestureRecognizer:tap];
    
    self.avatar.layer.cornerRadius = 2;
    self.avatar.layer.masksToBounds = YES;
    
    self.icon.layer.cornerRadius = 4;
    self.icon.layer.masksToBounds = YES;
    
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
    
    [self.textBoxContent setFont:[UIFont fontWithName:@"Lato-Light" size:self.textBoxContent.font.pointSize]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:@"UIKeyboardWillShowNotification"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:@"UIKeyboardWillHideNotification"
                                               object:nil];
    

    [self.commentField setFont:[UIFont fontWithName:@"Lato-Bold" size:self.commentField.font.pointSize]];
    [self.postBtn.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:self.postBtn.titleLabel.font.pointSize]];
    
    self.commentBox.layer.borderColor = [UIColor colorWithRed:215/255.0f green:215/255.0f blue:215/255.0f alpha:1.0f].CGColor;
    self.commentBox.layer.borderWidth = 1.0f;
    self.commentBox.layer.cornerRadius = 6;
    self.commentBox.layer.masksToBounds = YES;
    
    [self.commentsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self reloadData];
}

- (void)reloadData{
    
    MBProgressHUD *p = [[MBProgressHUD alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow] ];
    [p setDimBackground:YES];
    [p setLabelText:@"Loading"];
    [p setMode:MBProgressHUDModeIndeterminate];
    [p show:YES];
    [p setRemoveFromSuperViewOnHide:YES];
    [[[UIApplication sharedApplication] keyWindow] addSubview:p];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
       self.oneItem = [[mrAPI sharedInstance] getOneFeedItem:[self.oneItem objectForKey:@"id"]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //NSLog(@"------ %@", self.oneItem);
            [p hide:YES];
            
            NSDictionary *subject = [self.oneItem objectForKey:@"subject"];
            //NSDictionary *source = [self.oneItem objectForKey:@"source"];
            
            NSString *realTitle = [Motivosity getTitleFromDict:self.oneItem];
            
            [self.mrTitle setText:[NSString stringWithFormat:@"%@",realTitle]];
            [self.time setText:[NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"readableDate"]]];
            [self.icon setBackgroundColor:[UIColor colorWithHexString:[self.oneItem objectForKey:@"feedIconColor"]]];
            
            [self.iconImg setImage:[Motivosity iconFromType:[self.oneItem objectForKey:@"feedIconClass"]]];
            
            [self.autor setText:[NSString stringWithFormat:@"%@",[subject objectForKey:@"fullName"]]];
            [self.avatar sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[Motivosity getAmazonURL],[subject objectForKey:@"avatarUrl"]]] placeholderImage:nil];
            
            CGSize maximumLabelSize = CGSizeMake(312,9999);
            
            NSString *contentStr = @" ";
            if ([self.oneItem objectForKey:@"note"] != nil && ![[self.oneItem objectForKey:@"note"] isEqual:[NSNull null]]) {
                contentStr = [NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"note"]];
            }
            
            CGSize expectedLabelSize = [contentStr sizeWithFont:[UIFont fontWithName:@"Lato-Light" size:14.0f]
                                              constrainedToSize:maximumLabelSize
                                                  lineBreakMode:NSLineBreakByCharWrapping];
            CGFloat featureH = 0.0f;
            if([contentStr isEqualToString:@""])
                featureH = 10.0f;
            else
                featureH = expectedLabelSize.height + 8.0f;
            
            contentH = featureH;
            
            NSString *contentStrTitle = @"";
            if (![realTitle isEqual:[NSNull null]])
            {
                contentStrTitle = [NSString stringWithFormat:@"%@",realTitle];
            }
            
            CGSize expectedLabelSizeTitle = [contentStrTitle sizeWithFont:[UIFont fontWithName:@"Lato-Bold" size:14.0f]
                                                        constrainedToSize:maximumLabelSize
                                                            lineBreakMode:NSLineBreakByCharWrapping];
            
            CGFloat featureHTitle = expectedLabelSizeTitle.height;
            
            [self.mrTitle setFrame:CGRectMake(self.mrTitle.frame.origin.x, self.mrTitle.frame.origin.y, self.mrTitle.frame.size.width, featureHTitle )];
            
            [self.textBoxContent setFrame:CGRectMake(self.textBoxContent.frame.origin.x, 52.0f + featureHTitle, self.textBoxContent.frame.size.width, featureH )];
            [self.textBoxContent setText:contentStr];
            
            
            [self.commentsTable setFrame:CGRectMake(self.commentsTable.frame.origin.x, 52.0f + featureH + featureHTitle, self.commentsTable.frame.size.width, self.commentsTable.frame.size.height - featureH -  featureHTitle)];
            
            self.comments = [self.oneItem objectForKey:@"commentList"];
            [self.commentsTable reloadData];

        });
    });
}

- (void) keyboardWillShow:(NSNotification *)note {
    
    if(self.bottomInputBox.frame.origin.y == [Motivosity getScreenHeigh] - self.bottomInputBox.frame.size.height - self.mainCanteiner.frame.origin.y)
    {
        NSDictionary *userInfo = [note userInfo];
        CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        
        //NSLog(@"Keyboard Height: %f Width: %f", kbSize.height, kbSize.width);
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.bottomInputBox setFrame:CGRectMake(self.bottomInputBox.frame.origin.x, [Motivosity getScreenHeigh] - self.bottomInputBox.frame.size.height - self.mainCanteiner.frame.origin.y - kbSize.height, self.bottomInputBox.frame.size.width, self.bottomInputBox.frame.size.height)];
        }];
    }
}

- (void) keyboardWillHide:(NSNotification *)note {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self.bottomInputBox setFrame:CGRectMake(self.bottomInputBox.frame.origin.x, [Motivosity getScreenHeigh] - self.bottomInputBox.frame.size.height - self.mainCanteiner.frame.origin.y, self.bottomInputBox.frame.size.width, self.bottomInputBox.frame.size.height)];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)backAction:(id)sender {
    [APPDELEGATE.feedNavi popViewControllerAnimated:YES];
}

- (IBAction)commentPostAction:(id)sender {
    
    NSString *comment =  [self.commentField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(comment.length > 0)
    {
        self.commentField.text = @"";
        [self.commentField resignFirstResponder];
    
        MBProgressHUD *p = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [p setDimBackground:YES];
        [p setLabelText:@"Loading"];
        [p setMode:MBProgressHUDModeIndeterminate];
        [p show:YES];
        [p setRemoveFromSuperViewOnHide:YES];
        [self.view.window addSubview:p];
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            NSDictionary *commentResp = [[mrAPI sharedInstance] postComment:comment feedId:[self.oneItem objectForKey:@"id"]];
        
            dispatch_async(dispatch_get_main_queue(), ^{
            
                [p hide:YES];
            
                //NSLog(@"--- %@",commentResp);
                
                if (![[commentResp objectForKey:@"id"] isEqual:[NSNull null]])
                {
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.comments];
                    [tempArray insertObject:commentResp atIndex:0];
                    self.comments = [NSArray arrayWithArray:tempArray];
                
                    [self.commentsTable reloadData];
                    [self.commentsTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    
                    [APPDELEGATE.feed addCommentToFeed:[self.oneItem objectForKey:@"id"] commentDist:commentResp];
                 }
            });
        });
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.commentField resignFirstResponder];
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.comments.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        //NSString *content =  @"Ann Perkins, Leslie Knope, and Ron Swanson like this.";
        NSString *content = [Motivosity getLikeStrFromDict:self.oneItem];
        
        CGSize maximumLabelSize = CGSizeMake(220, CGFLOAT_MAX);
        CGRect expectedLabelSize  = [content boundingRectWithSize:maximumLabelSize
                                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Lato-Light" size:14.0f]}
                                                             context:nil];
        
        
        CGFloat featureH = expectedLabelSize.size.height + 5.0f;
        
        //NSLog(@" ---- %f", expectedLabelSize.size.height);
        
        if(featureH > 24)
            return featureH + 10;
        else
            return 34.0f;
    }
    else
    {
        NSDictionary *oneItemLocal = [self.comments objectAtIndex:(indexPath.row - 1)];
        NSString *content =  [NSString stringWithFormat:@"%@",[oneItemLocal objectForKey:@"commentText"]];
        
        CGSize maximumLabelSize = CGSizeMake(252, CGFLOAT_MAX);
        CGRect expectedLabelSize  = [content boundingRectWithSize:maximumLabelSize
                                                          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                       attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Lato-Light" size:14.0f]}
                                                          context:nil];
        
        CGFloat featureH = expectedLabelSize.size.height;
        
         return 44.0f + featureH - 6.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        static NSString *CellIdentifier = @"CommentLikeID";
        
        CommentLike *cell = (CommentLike *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentLike" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.detailsScreen = self;
        cell.oneItem = self.oneItem;
        [cell setCellContent];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else
    {
        static NSString *CellIdentifier = @"CommentCellID";
        
        CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        
        cell.oneItem = [self.comments objectAtIndex:(indexPath.row - 1)];
        [cell setCellContent];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)likeCountInc:(NSDictionary *)newItem
{
    self.oneItem = newItem;
}



@end
