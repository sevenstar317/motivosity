//
//  CartCell.h
//  Motivosity
//
//  Created by mr on 11.11.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CartCell : UITableViewCell{

    NSDictionary *oneItem;
    id store;
}

@property (strong, nonatomic) id store;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) NSDictionary *oneItem;
@property (strong, nonatomic) IBOutlet UIImageView *img;
@property (strong, nonatomic) IBOutlet UILabel *mrTitle;
@property (strong, nonatomic) IBOutlet UITextField *countField;
@property (strong, nonatomic) IBOutlet UILabel *price;

- (void)loadCartItemsForCell;
- (IBAction)removeItemAction:(id)sender;
- (IBAction)editingEnd:(id)sender;

@end
