//
//  CartCell.m
//  Motivosity
//
//  Created by mr on 11.11.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import "CartCell.h"

#import "UIImageView+WebCache.h"

#include "StoreVC.h"

@implementation CartCell

@synthesize oneItem;
@synthesize store;

- (void)awakeFromNib {
    // Initialization code
    
    self.img.layer.borderColor = [UIColor colorWithRed:189/255.0f green:189/255.0f blue:189/255.0f alpha:1.0f].CGColor;
    self.img.layer.borderWidth = 0.6f;
    self.img.layer.cornerRadius = 4;
    self.img.layer.masksToBounds = YES;
    
    self.countField.layer.borderColor = [UIColor colorWithRed:189/255.0f green:189/255.0f blue:189/255.0f alpha:1.0f].CGColor;
    self.countField.layer.borderWidth = 0.6f;
    self.countField.layer.cornerRadius = 4;
    self.countField.layer.masksToBounds = YES;

    [self.countField setFont:[UIFont fontWithName:@"Lato-Bold" size:self.countField.font.pointSize]];
    
    for (UILabel *oneL in self.latoLabels){
        [oneL setFont:[UIFont fontWithName:@"Lato-Bold" size:oneL.font.pointSize]];
    }
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0]];
    nextButton.frame = CGRectMake(0.0f, 0.0f, 60, 30);
    [nextButton setTitle:@"Done" forState:UIControlStateNormal];
    nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [nextButton setTitleColor:[UIColor colorWithRed:39/255.0f green:119/255.0f blue:154/255.0f alpha:1.0f] forState:UIControlStateNormal];
    
    [nextButton addTarget:self
                   action:@selector(doneWithNumberPad)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [Motivosity getScreenWidth], 50)];
    [numberToolbar insertSubview:[[UIImageView alloc] initWithImage:[Motivosity imageWithColor:[UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f]]] atIndex:0];
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithCustomView:nil],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithCustomView:nextButton],
                           nil];
    [numberToolbar sizeToFit];
    self.countField.inputAccessoryView = numberToolbar;
}

- (void)doneWithNumberPad{
    [self.countField resignFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadCartItemsForCell{

     [self.img sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"image"]]] placeholderImage:nil];
     self.mrTitle.text = [NSString stringWithFormat:@"%@",[self.oneItem objectForKey:@"name"]];
    
     self.price.text = [NSString stringWithFormat:@"$%.1f",(float)[[self.oneItem objectForKey:@"price"]floatValue]];
     self.countField.text = [NSString stringWithFormat:@"%d",(int)[[self.oneItem objectForKey:@"currentQty"]intValue]];
}

- (IBAction)removeItemAction:(id)sender {
    
    StoreVC *storeScreen = (StoreVC *)store;
    [storeScreen removeCartItemByID:[self.oneItem objectForKey:@"id"]];
}

- (IBAction)editingEnd:(id)sender{
    
    UITextField *field = (UITextField *)sender;
    int count = (int)[[NSString stringWithFormat:@"%@",field.text]intValue];
    
    if(count < 1)
        count = 1;
    
    field.text = [NSString stringWithFormat:@"%d",count];
    
    StoreVC *storeScreen = (StoreVC *)store;
    
    [storeScreen updateCountForItem:[self.oneItem objectForKey:@"id"] count:count];
}

@end
