//
//  CustomCell.h
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell
@property (nonatomic,retain) IBOutlet UILabel *ourLabel;
@property (nonatomic,retain) IBOutlet UIImageView *ourImage;
@property (nonatomic,retain) IBOutlet UILabel *distance;
@property (nonatomic,retain) IBOutlet UILabel *timeLabel;
@property (nonatomic,retain) IBOutlet UILabel *price;
@end
