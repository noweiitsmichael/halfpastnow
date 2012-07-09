//
//  FilterViewController.h
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController{
    UIButton *sun;
    UIButton *mon;
    UIButton *tue;
    UIButton *wed;
    UIButton *thu;
    UIButton *fri;
    UIButton *sat;
    UIButton *price0;
    UIButton *price1;
    UIButton *price2;
    UIButton *price3;
    UIButton *price4;
    UIButton *today;
    UIButton *tomorrow;
    UIButton *distance0;
    UIButton *distance1;
    UIButton *distance2;
    UIButton *distance3;
    UIButton *resetButton;
}
@property (strong,nonatomic) IBOutlet UIButton *resetButton;
@property (strong,nonatomic) IBOutlet UIButton *sun;
@property (strong,nonatomic) IBOutlet UIButton *mon;
@property (strong,nonatomic) IBOutlet UIButton *tue;
@property (strong,nonatomic) IBOutlet UIButton *wed;
@property (strong,nonatomic) IBOutlet UIButton *thu;
@property (strong,nonatomic) IBOutlet UIButton *fri;
@property (strong,nonatomic) IBOutlet UIButton *sat;
@property (strong,nonatomic) IBOutlet UIButton *price0;
@property (strong,nonatomic) IBOutlet UIButton *price1;
@property (strong,nonatomic) IBOutlet UIButton *price2;
@property (strong,nonatomic) IBOutlet UIButton *price3;
@property (strong,nonatomic) IBOutlet UIButton *price4;
@property (strong,nonatomic) IBOutlet UIButton *today;
@property (strong,nonatomic) IBOutlet UIButton *tomorrow;
@property (strong,nonatomic) IBOutlet UIButton *distance0;
@property (strong,nonatomic) IBOutlet UIButton *distance1;
@property (strong,nonatomic) IBOutlet UIButton *distance2;
@property (strong,nonatomic) IBOutlet UIButton *distance3;



-(IBAction) sunBtn;
-(IBAction) monBtn;
-(IBAction) tueBtn;
-(IBAction) wedBtn;
-(IBAction) thuBtn;
-(IBAction) friBtn;
-(IBAction) satBtn;

-(IBAction) price0Btn;
-(IBAction) price1Btn;
-(IBAction) price2Btn;
-(IBAction) price3Btn;
-(IBAction) price4Btn;

-(IBAction) todayBtn;
-(IBAction) tomorrowBtn;

-(IBAction) distance0Btn;
-(IBAction) distance1Btn;
-(IBAction) distance2Btn;
-(IBAction) distance3Btn;
-(IBAction) reset;



@end
