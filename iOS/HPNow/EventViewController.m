//
//  EventViewControllerViewController.m
//  HPN
//
//  Created by Triet Le on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"
#import "Event.h"
#import "VenueViewController.h"
#import "AppDelegate.h"
#define METERS_PER_MILE 1609.344

@interface EventViewController ()

@end

@implementation EventViewController
@synthesize event;
@synthesize eventTitle;
@synthesize description;
@synthesize time1;
@synthesize time2;
@synthesize add1;
@synthesize add2;
@synthesize venueName;
@synthesize price;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = event.getTitle;
    //    NSLog(@"title : %@", event.getTitle);
    //    NSLog(@"Description : %@",event.getDescription);
    //    NSLog(@"start : %@", event.getStart);
    //    NSLog(@"End : %@", event.getEnd);
    //    NSLog(@"Name : %@", event.getVenueName);
    //    NSLog(@"Address : %@", event.getVenueAddress);
    //    NSLog(@"City : %@", event.getVenueCity);
    //    NSLog(@"State : %@", event.getVenueState);
    NSString *zip = event.getVenueZip;
    //    NSLog(@"Zip : %@", zip );
    //    NSLog(@"VenueID : %@", event.getVenueID);
    //    NSLog(@"Price : %@", event.getPrice);
    //    NSLog(@"Latitude : %f", event.getLatitude);
    //    NSLog(@"Longitude : %f", event.getLongitude);
    self.eventTitle.text = event.getTitle;
    self.description.text =event.getDescription;
    NSString *dateString = event.getStart;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss-ss:ss"];
    NSDate* date = [df dateFromString:dateString];
    [df setDateFormat:@"EEEE, MMMM d"];
    NSString *strDate = [df stringFromDate:date];
    self.time1.text = strDate;
    [df setDateFormat:@"hh:mm a"];
    strDate = [df stringFromDate:date];
    
    NSString *endTime = event.getEnd;
    if (![endTime isEqualToString:@""]) {
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss-ss:ss"];
        date = [df dateFromString:endTime];
        [df setDateFormat:@"hh:mm a"];
        NSString *strDateEnd = [df stringFromDate:date];
        self.time2.text = [[strDate stringByAppendingFormat:@" to "] stringByAppendingFormat: strDateEnd];
        
    }
    else{
        self.time2.text = strDate; 
        
    }
    
    self.add1.text =  event.getVenueAddress;
    self.add2.text = [[[[event.getVenueCity stringByAppendingFormat:@", "] stringByAppendingFormat: event.getVenueState] stringByAppendingFormat:@" "] stringByAppendingFormat:zip ];
    NSString *eventPrice = event.getPrice;
    if ([eventPrice isKindOfClass:[NSNull class]]) {
        
        self.price.text = @"";
    }
    else if([eventPrice isEqualToString:@"0.0"] ) {
        self.price.text = @"FREE";
        
    }
    else self.price.text =[@"Price: $" stringByAppendingFormat:eventPrice];
    
    [self.venueName setTitle:event.getVenueName forState:UIControlStateNormal] ;
    
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = event.getLatitude;
    zoomLocation.longitude= event.getLongitude;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    // 4
    
    [mapView setRegion:adjustedRegion animated:YES]; 
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = zoomLocation;
    
    [mapView addAnnotation:annotationPoint]; 
    
    
    CGRect rect = CGRectMake(20, 1, 286, 40);
    venueName = [[UIButton alloc] initWithFrame:rect];
    
    venueName = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [venueName addTarget:self 
                  action:@selector(passView:)
        forControlEvents:UIControlEventTouchUpInside];
    [venueName setTitle:event.getVenueName forState:UIControlStateNormal];
    venueName.frame = rect;
    [venueName setTag:[event.getVenueID intValue]];
    [self.view addSubview:venueName];
    
}

-(IBAction) passView:(id) sender{
	
	
	
	NSInteger tid = [sender tag];
    
    //    NSLog(@"get to passview %d",tid);
    VenueViewController *venueViewController = [[VenueViewController alloc] init];
    [venueViewController setVenueID:[NSString stringWithFormat:@"%d", tid]];
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[delegate.navController1  pushViewController:venueViewController animated:YES];
    
   
//    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [UIView setAnimationsEnabled:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    [UIView setAnimationsEnabled:NO];
    /* Your original orientation booleans*/
    return NO;
}

@end