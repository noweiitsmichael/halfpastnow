//
//  FirstViewController.h
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface FirstViewController : UIViewController<UITableViewDelegate,MKMapViewDelegate,UISearchBarDelegate, UITableViewDataSource,CLLocationManagerDelegate>{
    MKMapView *mapView;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    UISearchBar *search;
    
	NSMutableArray* annotations;
}

@property (nonatomic, strong) CLLocationManager *locationManager;  
@property (nonatomic, strong) IBOutlet UISearchBar *search;
@property (strong, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) NSMutableArray *results;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (nonatomic,strong) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray* annotations;;

-(IBAction) setFilter;
@end
