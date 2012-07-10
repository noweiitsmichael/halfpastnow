//
//  FilterViewController.m
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController
@synthesize sun;
@synthesize mon;
@synthesize tue;
@synthesize wed;
@synthesize thu;
@synthesize fri;
@synthesize sat;
@synthesize price0;
@synthesize price1;
@synthesize price2;
@synthesize price3;
@synthesize price4;
@synthesize tomorrow;
@synthesize today;
@synthesize distance0;
@synthesize distance1;
@synthesize distance2;
@synthesize distance3;
@synthesize resetButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    sun.selected = NO;
    mon.selected = NO;
    tue.selected = NO;
    wed.selected = NO;
    thu.selected = NO;
    fri.selected = NO;
    sat.selected = NO;
    price0.selected=NO;
    price1.selected=NO;
    price2.selected=NO;
    price3.selected=NO;
    price4.selected=NO;
    today.selected=NO;
    tomorrow.selected=NO;
    distance0.selected=NO;
    distance1.selected=NO;
    distance2.selected=NO;
    distance3.selected=NO;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *days = [defaults objectForKey:@"days"];
    NSString *prices = [defaults objectForKey:@"prices"];
    NSString *todayOrTomorrow = [defaults objectForKey:@"todayOrTomorrow"];
    NSString *distance = [defaults objectForKey:@"distance"];
    NSString *daysString = [defaults objectForKey:@"daysString"];
    NSString *pricesString = [defaults objectForKey:@"pricesString"];
    
    NSLog(@"Days=%@ , Prices=%@ , todayOrTomorrow=%@ , distance=%@, daysString=%@ , pricesString=%@",days,prices,todayOrTomorrow,distance,daysString,pricesString);
    
    if (![daysString isEqualToString:@""])
    {
        int length = [daysString length];
        int index = 0;
        
        while(length > 0)
        {
            NSString *tmp =[daysString substringWithRange:NSMakeRange(index, 1)];
            index++;
            length--;
            if ([tmp isEqualToString:@"0"]){
                sun.selected = YES;
                sun.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"1"]){
                mon.selected = YES;
                mon.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"2"]){
                tue.selected = YES;
                tue.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"3"]){
                wed.selected = YES;
                wed.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"4"]){
                thu.selected = YES;
                thu.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"5"]){
                fri.selected = YES;
                fri.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"6"]){
                sat.selected = YES;
                sat.backgroundColor = [UIColor blueColor];
            }
                                                                         
        }
    }
    
    if (![pricesString isEqualToString:@""])
    {
        int length = [pricesString length];
        int index = 0;
        
        while(length > 0)
        {
            NSString *tmp =[pricesString substringWithRange:NSMakeRange(index, 1)];
            index++;
            length--;
            if ([tmp isEqualToString:@"0"]){
                price0.selected = YES;
                price0.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"1"]){
                price1.selected = YES;
                price1.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"2"]){
                price2.selected = YES;
                price2.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"3"]){
                price3.selected = YES;
                price3.backgroundColor = [UIColor blueColor];
            }
            if ([tmp isEqualToString:@"4"]){
                price4.selected = YES;
                price4.backgroundColor = [UIColor blueColor];
            }
            
            
        }
    }
    
    if ([todayOrTomorrow isEqualToString:@"0"]){
        today.selected = YES;
        today.backgroundColor = [UIColor blueColor];
    }
    if ([todayOrTomorrow isEqualToString:@"1"]){
        tomorrow.selected = YES;
        tomorrow.backgroundColor = [UIColor blueColor];
    }
    if ([distance isEqualToString:@"0"]){
        distance0.selected = YES;
        distance0.backgroundColor = [UIColor blueColor];
    }
    if ([distance isEqualToString:@"1"]){
        distance1.selected = YES;
        distance1.backgroundColor = [UIColor blueColor];
    }
    if ([distance isEqualToString:@"2"]){
        distance2.selected = YES;
        distance2.backgroundColor = [UIColor blueColor];
    }
    if ([distance isEqualToString:@"3"]){
        distance3.selected = YES;
        distance3.backgroundColor = [UIColor blueColor];
    }
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) sunBtn{
    sun.selected = !sun.selected;
    if (sun.selected) {
        sun.backgroundColor = [UIColor blueColor];
    }
    else sun.backgroundColor = [UIColor grayColor];
    [self filting];
    
}
-(IBAction) monBtn{
    mon.selected = !mon.selected;
    if (mon.selected) {
        mon.backgroundColor = [UIColor blueColor];
    }
    else mon.backgroundColor = [UIColor grayColor];
    [self filting];
}

-(IBAction) tueBtn{
    tue.selected = !tue.selected;
    if (tue.selected) {
        tue.backgroundColor = [UIColor blueColor];
    }
    else tue.backgroundColor = [UIColor grayColor];
    [self filting];
}
-(IBAction) wedBtn{
    wed.selected = !wed.selected;
    if (wed.selected) {
        wed.backgroundColor = [UIColor blueColor];
    }
    else wed.backgroundColor = [UIColor grayColor];
    [self filting];
}

-(IBAction) thuBtn{
    thu.selected = !thu.selected;
    if (thu.selected) {
        thu.backgroundColor = [UIColor blueColor];
    }
    else thu.backgroundColor = [UIColor grayColor];
    [self filting];
}

-(IBAction) friBtn{
    fri.selected = !fri.selected;
    if (fri.selected) {
        fri.backgroundColor = [UIColor blueColor];
    }
    else fri.backgroundColor = [UIColor grayColor];
    [self filting];
}

-(IBAction) satBtn{
    sat.selected = !sat.selected;
    if (sat.selected) {
        sat.backgroundColor = [UIColor blueColor];
    }
    else sat.backgroundColor = [UIColor grayColor];
    [self filting];
}
-(IBAction) price0Btn{
    price0.selected = !price0.selected;
    if (price0.selected) {
        price0.backgroundColor = [UIColor blueColor];
    }
    else price0.backgroundColor = [UIColor grayColor];
    [self filting];
}
-(IBAction) price1Btn{
    price1.selected = !price1.selected;
    if (price1.selected) {
        price1.backgroundColor = [UIColor blueColor];
    }
    else price1.backgroundColor = [UIColor grayColor];
    [self filting];
}

-(IBAction) price2Btn{
    price2.selected = !price2.selected;
    if (price2.selected) {
        price2.backgroundColor = [UIColor blueColor];
    }
    else price2.backgroundColor = [UIColor grayColor];
    [self filting];
}
-(IBAction) price3Btn{
    price3.selected = !price3.selected;
    if (price3.selected) {
        price3.backgroundColor = [UIColor blueColor];
    }
    else price3.backgroundColor = [UIColor grayColor];
    [self filting];
}
-(IBAction) price4Btn{
    price4.selected = !price4.selected;
    if (price4.selected) {
        price4.backgroundColor = [UIColor blueColor];
    }
    else price4.backgroundColor = [UIColor grayColor];
    [self filting];
}
-(IBAction) todayBtn{
    today.selected = !today.selected;
    
    if (today.selected) {
        today.backgroundColor = [UIColor blueColor];
        tomorrow.backgroundColor = [UIColor grayColor];
        tomorrow.selected = !today.selected;
        
    }
    else {
        today.backgroundColor = [UIColor grayColor];
       
    }
    [self filting];
}
-(IBAction) tomorrowBtn{
    tomorrow.selected = !tomorrow.selected;
    

    if (tomorrow.selected) {
        tomorrow.backgroundColor = [UIColor blueColor];
        today.backgroundColor = [UIColor grayColor];
        today.selected = !tomorrow.selected;
    }
    else {
        tomorrow.backgroundColor = [UIColor grayColor];
       
    }
    [self filting];
}

-(IBAction) distance0Btn{
    distance0.selected = !distance0.selected;
    
    if (distance0.selected) {
        distance0.backgroundColor = [UIColor blueColor];
        distance1.backgroundColor = [UIColor grayColor];
        distance2.backgroundColor = [UIColor grayColor];
        distance3.backgroundColor = [UIColor grayColor];
        distance1.selected = distance2.selected = distance3.selected  = !distance0.selected;
        
    }
    else {
        distance0.backgroundColor = [UIColor grayColor];
        
    }
    [self filting];
}

-(IBAction) distance1Btn{
    distance1.selected = !distance1.selected;
    
    if (distance1.selected) {
        distance1.backgroundColor = [UIColor blueColor];
        distance0.backgroundColor = [UIColor grayColor];
        distance2.backgroundColor = [UIColor grayColor];
        distance3.backgroundColor = [UIColor grayColor];
        distance0.selected = distance2.selected = distance3.selected  = !distance1.selected;
        
    }
    else {
        distance1.backgroundColor = [UIColor grayColor];
        
    }
    [self filting];
}

-(IBAction) distance2Btn{
    distance2.selected = !distance2.selected;
    
    if (distance2.selected) {
        distance2.backgroundColor = [UIColor blueColor];
        distance1.backgroundColor = [UIColor grayColor];
        distance0.backgroundColor = [UIColor grayColor];
        distance3.backgroundColor = [UIColor grayColor];
        distance1.selected = distance0.selected = distance3.selected  = !distance2.selected;
        
    }
    else {
        distance2.backgroundColor = [UIColor grayColor];
        
    }
    [self filting];
}

-(IBAction) distance3Btn{
    distance3.selected = !distance3.selected;
    
    if (distance3.selected) {
        distance3.backgroundColor = [UIColor blueColor];
        distance1.backgroundColor = [UIColor grayColor];
        distance2.backgroundColor = [UIColor grayColor];
        distance0.backgroundColor = [UIColor grayColor];
        distance1.selected = distance2.selected = distance0.selected  = !today.selected;
        
    }
    else {
        distance3.backgroundColor = [UIColor grayColor];
        
    }
    [self filting];
}

-(void) filting{
    NSString *days = [[NSString alloc] initWithFormat:@""];
    NSString *prices = [[NSString alloc] initWithFormat:@""];
    NSString *todayOrTomorrow = [[NSString alloc] initWithFormat:@""];
    NSString *distance = [[NSString alloc] initWithFormat:@""];
    NSString *daysString = [[NSString alloc] initWithFormat:@""];
    NSString *pricesString = [[NSString alloc] initWithFormat:@""];
    if (sun.selected) {
        daysString = [daysString  stringByAppendingFormat:@"0"];
        if ([days isEqualToString:@""] ) {
            days = [days  stringByAppendingFormat:@"0"];
        } 
        else days = [[days stringByAppendingFormat:@","] stringByAppendingFormat:@"0"];
    }
    if (mon.selected) {
        daysString = [daysString  stringByAppendingFormat:@"1"];
        if ([days isEqualToString:@""] ) {
            days = [days  stringByAppendingFormat:@"1"];
        } 
        else days = [[days stringByAppendingFormat:@","] stringByAppendingFormat:@"1"];
    }
    if (tue.selected) {
        daysString = [daysString  stringByAppendingFormat:@"2"];
        if ([days isEqualToString:@""] ) {
            days = [days  stringByAppendingFormat:@"2"];
        } 
        else days = [[days stringByAppendingFormat:@","] stringByAppendingFormat:@"2"];
    }
    if (wed.selected) {
        daysString = [daysString  stringByAppendingFormat:@"3"];
        if ([days isEqualToString:@""] ) {
            days = [days  stringByAppendingFormat:@"3"];
        } 
        else days = [[days stringByAppendingFormat:@","] stringByAppendingFormat:@"3"];
    }
    if (thu.selected) {
        daysString = [daysString  stringByAppendingFormat:@"4"];
        if ([days isEqualToString:@""] ) {
            days = [days  stringByAppendingFormat:@"4"];
        } 
        else days = [[days stringByAppendingFormat:@","] stringByAppendingFormat:@"4"];
    }
    if (fri.selected) {
        daysString = [daysString  stringByAppendingFormat:@"5"];
        if ([days isEqualToString:@""] ) {
            days = [days  stringByAppendingFormat:@"5"];
        } 
        else days = [[days stringByAppendingFormat:@","] stringByAppendingFormat:@"5"];
    }
    if (sat.selected) {
        daysString = [daysString  stringByAppendingFormat:@"6"];
        if ([days isEqualToString:@""] ) {
            days = [days  stringByAppendingFormat:@"6"];
        } 
        else days = [[days stringByAppendingFormat:@","] stringByAppendingFormat:@"6"];
    }
    if (price0.selected) {
        pricesString = [pricesString  stringByAppendingFormat:@"0"];
        if ([prices isEqualToString:@""] ) {
            prices = [prices  stringByAppendingFormat:@"0"];
        } 
        else prices = [[prices stringByAppendingFormat:@","] stringByAppendingFormat:@"0"];
    }
    if (price1.selected) {
         pricesString = [pricesString  stringByAppendingFormat:@"1"];
        if ([prices isEqualToString:@""] ) {
            prices = [prices  stringByAppendingFormat:@"1"];
        } 
        else prices = [[prices stringByAppendingFormat:@","] stringByAppendingFormat:@"1"];
    }
    if (price2.selected) {
         pricesString = [pricesString  stringByAppendingFormat:@"2"];
        if ([prices isEqualToString:@""] ) {
            prices = [prices  stringByAppendingFormat:@"2"];
        } 
        else prices = [[prices stringByAppendingFormat:@","] stringByAppendingFormat:@"2"];
    }
    if (price3.selected) {
         pricesString = [pricesString  stringByAppendingFormat:@"3"];
        if ([prices isEqualToString:@""] ) {
            prices = [prices  stringByAppendingFormat:@"3"];
        } 
        else prices = [[prices stringByAppendingFormat:@","] stringByAppendingFormat:@"3"];
    }
    if (price4.selected) {
         pricesString = [pricesString  stringByAppendingFormat:@"4"];
        if ([prices isEqualToString:@""] ) {
            prices = [prices  stringByAppendingFormat:@"4"];
        } 
        else prices = [[prices stringByAppendingFormat:@","] stringByAppendingFormat:@"4"];
    }
    if (tomorrow.selected) {
        todayOrTomorrow = [todayOrTomorrow stringByAppendingFormat:@"1"];
    }
    if (today.selected) {
        todayOrTomorrow = [todayOrTomorrow stringByAppendingFormat:@"0"];
    }
    if (distance0.selected) {
        distance = [distance stringByAppendingFormat:@"0"];
    }
    if (distance1.selected) {
        distance = [distance stringByAppendingFormat:@"1"];
    }
    if (distance2.selected) {
        distance = [distance stringByAppendingFormat:@"2"];
    }
    if (distance3.selected) {
        distance = [distance stringByAppendingFormat:@"3"];
    }
    NSLog(@"Days %@",days);
    NSLog(@"Prices %@",prices);
    NSLog(@"today or tomorrow %@",todayOrTomorrow);
    NSLog(@"distance %@",distance);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:days forKey:@"days"];
    [defaults setObject:prices forKey:@"prices"];
    [defaults setObject:todayOrTomorrow forKey:@"todayOrTomorrow"];
    [defaults setObject:distance forKey:@"distance"];
    [defaults setObject:daysString forKey:@"daysString"];
    [defaults setObject:pricesString forKey:@"pricesString"];
    
    [defaults synchronize];
    
    
}

-(IBAction) reset{
    NSLog(@"reset clicked !!!");
    resetButton.backgroundColor = [UIColor blueColor];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(changeBtn:)
                                   userInfo:nil
                                    repeats:NO];  
    
}

-(void) changeBtn:(NSTimer *)timer{
    sun.selected = NO;
    mon.selected = NO;
    tue.selected = NO;
    wed.selected = NO;
    thu.selected = NO;
    fri.selected = NO;
    sat.selected = NO;
    price0.selected = NO;
    price1.selected = NO;
    price2.selected = NO;
    price3.selected = NO;
    price4.selected = NO;
    today.selected = NO;
    tomorrow.selected = NO;
    distance0.selected = NO;
    distance1.selected = NO;
    distance2.selected = NO;
    distance3.selected = NO;
    resetButton.selected = NO;
    sun.backgroundColor = [UIColor grayColor];
    mon.backgroundColor = [UIColor grayColor];
    tue.backgroundColor = [UIColor grayColor];
    wed.backgroundColor = [UIColor grayColor];
    thu.backgroundColor = [UIColor grayColor];
    fri.backgroundColor = [UIColor grayColor];
    sat.backgroundColor = [UIColor grayColor];
    price0.backgroundColor = [UIColor grayColor];
    price1.backgroundColor = [UIColor grayColor];
    price2.backgroundColor = [UIColor grayColor];
    price3.backgroundColor = [UIColor grayColor];
    price4.backgroundColor = [UIColor grayColor];
    today.backgroundColor = [UIColor grayColor];
    tomorrow.backgroundColor = [UIColor grayColor];
    distance0.backgroundColor = [UIColor grayColor];
    distance1.backgroundColor = [UIColor grayColor];
    distance2.backgroundColor = [UIColor grayColor];
    distance3.backgroundColor = [UIColor grayColor];
    resetButton.backgroundColor = [UIColor grayColor];

}


@end
