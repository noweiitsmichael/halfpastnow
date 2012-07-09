//
//  EventViewController.h
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class Event;
@interface EventViewController : UIViewController{
    Event *event;
    UILabel *eventTitle;
    UITextView *description;
    UILabel *time1;
    UILabel *time2;
    UILabel *add1;
    UILabel *add2;
    UIButton *venueName;
    UILabel *price;
    MKMapView *mapView;
    
    
    
    
    
}
@property (nonatomic,strong) Event *event;
@property (nonatomic,strong) IBOutlet UILabel *eventTitle;
@property (nonatomic,strong) IBOutlet UITextView *description;
@property (nonatomic,strong) IBOutlet UILabel *time1;
@property (nonatomic,strong) IBOutlet UILabel *time2;
@property (nonatomic,strong) IBOutlet UILabel *add1;
@property (nonatomic,strong) IBOutlet UILabel *add2;
@property (nonatomic,strong) UIButton *venueName;
@property (nonatomic,strong) IBOutlet UILabel *price;
@property (nonatomic,strong) IBOutlet MKMapView *mapView;

-(IBAction) passView:(id) sender;
@end
