//
//  UserCell.h
//  Motivosity
//
//  Created by mr on 20.10.14.
//  Copyright (c) 2014 MM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell{
    NSDictionary *oneItem;
}

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *latoLabels;

@property (strong, nonatomic) NSDictionary *oneItem;

- (void)setCellInfo;

@end
