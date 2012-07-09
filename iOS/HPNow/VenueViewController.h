//
//  VenueViewController.h
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface VenueViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,CLLocationManagerDelegate>{
    NSString *venueID;
    IBOutlet UIScrollView *scrollview;
    UILabel *venueName;
    UILabel *add1;
    UILabel *add2;
    UILabel *phone;
    MKMapView *mapView;
    NSDictionary *venueInfo;
    NSArray *occurrences;
    NSArray *recurrences;
    CLLocation *currentLocation;
}

@property (nonatomic, strong) CLLocationManager *locationManager;  



@property (strong, nonatomic) NSDictionary *venueEvents;
@property (nonatomic,strong) IBOutlet UILabel *venueName;
@property (nonatomic,strong) IBOutlet UILabel *add1;
@property (nonatomic,strong) IBOutlet UILabel *add2;
@property (nonatomic,strong) IBOutlet UILabel *phone;
@property (nonatomic,strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (nonatomic,strong) NSDictionary *venueInfo;
@property (nonatomic,strong) NSArray *occurrences;
@property (nonatomic,strong) NSArray *recurrences;
@property (strong, nonatomic) IBOutlet UITableView *myTable;

-(void) setVenueID:(NSString *) venueIDK;

-(NSString *) getVenueID;
@end
