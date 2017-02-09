//
//  StoreCell.h
//  Motivosity
//
//  Created by mr on 25.09.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StoreVC.h"

@interface StoreCell : UITableViewCell{
    
}

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;
@property (strong, nonatomic) IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutlet UILabel *cellTitle;
@property (strong, nonatomic) IBOutlet UIImageView *separator;

@property BOOL pageControlBeingUsed;

- (void)loadStoreItemsForCell:(NSArray *)storeArray index:(int)mrIndex sv:(id)store;
- (IBAction)changePage:(id)sender;
- (void)setTitleForCell:(NSString *)mrTitle;


@end
