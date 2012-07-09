//
//  FirstViewController.m
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "CustomCell.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
//#import "SecondViewController.h"
#import "Event.h"
#import "EventViewController.h"
#import "AppDelegate.h"
#import "FilterViewController.h"
#import "MyAnnotation.h"
#define METERS_PER_MILE 1609.344

@interface FirstViewController ()

@end

@implementation FirstViewController
@synthesize myTable;
@synthesize results;
@synthesize mapView;
@synthesize locationManager;
@synthesize currentLocation;
@synthesize search;
@synthesize annotations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"half past now.", @"half past now.");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; // send loc updates to myself
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSURL *url = [NSURL URLWithString:@"http://halfpastnow.herokuapp.com"];
    ASIFormDataRequest *requestG = [ASIFormDataRequest requestWithURL:url];
    [mapView setDelegate:self];
    annotations=[[NSMutableArray alloc] init];
    [requestG addPostValue:@"json" forKey:@"format"];
    [requestG startSynchronous];
    NSString *jsonString = [[NSString alloc] initWithData:[requestG responseData] encoding:NSUTF8StringEncoding];
    results = [jsonString JSONValue] ;
    //NSLog(@"results : %@",results);
    [locationManager startUpdatingLocation];
    
    //    NSLog(@"Lat : %f Long : %f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    
    CLLocationCoordinate2D zoomLocation;
    
    currentLocation = locationManager.location ;
    zoomLocation.latitude = locationManager.location.coordinate.latitude;
    zoomLocation.longitude= locationManager.location.coordinate.longitude;
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 3.5*METERS_PER_MILE, 3.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    // 4
    
    [mapView setRegion:adjustedRegion animated:YES]; 
    
//    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
//    annotationPoint.coordinate = zoomLocation;
//    
//    
//    [mapView addAnnotation:annotationPoint]; 
    
}
//
//- (void)locationManager:(CLLocationManager *)manager
//    didUpdateToLocation:(CLLocation *)newLocation
//           fromLocation:(CLLocation *)oldLocation
//{
//    NSLog(@"Location: %@", [newLocation description]);
//}
//
//
//- (void)locationManager:(CLLocationManager *)manager
//       didFailWithError:(NSError *)error
//{
//	NSLog(@"Error: %@", [error description]);
//}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}



- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	NSLog(@"It begins");
    for (UIView *searchBarSubview in [searchBar subviews]) {    
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {    
            @try {
                // set style of keyboard
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
                
                // always force return key to be enabled
                [(UITextField *)searchBarSubview setEnablesReturnKeyAutomatically:NO];
            }
            @catch (NSException * e) {        
                // ignore exception
            }
        }
    }
    [searchBar becomeFirstResponder];
	[searchBar setShowsCancelButton:YES animated:YES];
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
    [self handleSearch:searchBar];
     }
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
	[searchBar resignFirstResponder];
	[searchBar setShowsCancelButton:NO animated:YES];
}

- (void)handleSearch:(UISearchBar *)searchBar {
    NSLog(@"User searched for %@", searchBar.text);
    [searchBar resignFirstResponder]; // if you want the keyboard to go away
    results = [[NSMutableArray alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *days = [defaults objectForKey:@"days"];
    NSString *prices = [defaults objectForKey:@"prices"];
    NSString *todayOrTomorrow = [defaults objectForKey:@"todayOrTomorrow"];
    NSString *distance = [defaults objectForKey:@"distance"];
    
    
    NSURL *url = [NSURL URLWithString:@"http://halfpastnow.herokuapp.com/events"];
    ASIFormDataRequest *requestG = [ASIFormDataRequest requestWithURL:url];
    [requestG addPostValue:@"json" forKey:@"format"];
    if([searchBar.text isEqualToString:@""]) [requestG addPostValue:@"" forKey:@"search"];
    else [requestG addPostValue:searchBar.text forKey:@"search"];
    [requestG addPostValue:days forKey:@"day"];
    [requestG addPostValue:prices forKey:@"price"];
    
    NSDate *now = [NSDate date];
    NSDateComponents *offset = [[NSDateComponents alloc] init] ;
    [offset setDay:1];
    NSDate *new1 = [[NSCalendar currentCalendar] dateByAddingComponents:offset toDate:now options:0];
    [offset setDay:2];
    NSDate *new2 = [[NSCalendar currentCalendar] dateByAddingComponents:offset toDate:now options:0];
    [offset setDay:356];
    NSDate *new3 = [[NSCalendar currentCalendar] dateByAddingComponents:offset toDate:now options:0];

    NSNumber *startTime;
    NSNumber *endTime;
    if ([todayOrTomorrow isEqualToString:@"0"]){
        startTime = [NSNumber numberWithLongLong:[now timeIntervalSince1970]];
        endTime =  [NSNumber numberWithLongLong:[new1 timeIntervalSince1970]];
    }
    if ([todayOrTomorrow isEqualToString:@"1"]){
        startTime = [NSNumber numberWithLongLong:[new1 timeIntervalSince1970]];
        endTime =  [NSNumber numberWithLongLong:[new2 timeIntervalSince1970]];
    }
    if ([todayOrTomorrow isEqualToString:@""]){
        startTime = [NSNumber numberWithLongLong:[now timeIntervalSince1970]];
        endTime =  [NSNumber numberWithLongLong:[new3 timeIntervalSince1970]];
    }
    
    [requestG addPostValue:[startTime stringValue] forKey:@"start"];
    [requestG addPostValue:[endTime stringValue] forKey:@"end"];
    
    NSLog(@"Time %@",[startTime stringValue]);
     NSLog(@"Time %@",[endTime stringValue]);
    
    
    
    
    [requestG startSynchronous];
    NSString *jsonString = [[NSString alloc] initWithData:[requestG responseData] encoding:NSUTF8StringEncoding];
    NSMutableArray *JsonResult = [jsonString JSONValue] ;
    
    float theDistance = 0;
    int size = [JsonResult count];
    if ([distance isEqualToString:@"0"]) {
        theDistance = 0.5;
        for (int i=0; i<size; i++) {
            NSDictionary *event= [JsonResult objectAtIndex:i];
            NSDictionary *venueInfo = [event objectForKey:@"venue"];
            CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[venueInfo objectForKey:@"latitude"] doubleValue] longitude:[[venueInfo objectForKey:@"longitude"] doubleValue]];
            CLLocationDistance dist = [currentLocation distanceFromLocation:locB]/METERS_PER_MILE;
            if (dist<=0.5) {
                [results addObject:event];
            }
            
        }
        
    }
    else if ([distance isEqualToString:@"1"]) {
        theDistance = 1.0;
        for (int i=0; i<size; i++) {
            NSDictionary *event= [JsonResult objectAtIndex:i];
            NSDictionary *venueInfo = [event objectForKey:@"venue"];
            CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[venueInfo objectForKey:@"latitude"] doubleValue] longitude:[[venueInfo objectForKey:@"longitude"] doubleValue]];
            CLLocationDistance dist = [currentLocation distanceFromLocation:locB]/METERS_PER_MILE;
            if (dist<=1) {
                [results addObject:event];
            }
            
        }

    }
    else if ([distance isEqualToString:@"2"]) {
        theDistance = 2.0;
       
        for (int i=0; i<size; i++) {
            NSDictionary *event= [JsonResult objectAtIndex:i];
            NSDictionary *venueInfo = [event objectForKey:@"venue"];
            CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[venueInfo objectForKey:@"latitude"] doubleValue] longitude:[[venueInfo objectForKey:@"longitude"] doubleValue]];
            CLLocationDistance dist = [currentLocation distanceFromLocation:locB]/METERS_PER_MILE;
            if (dist<=2.0) {
                 NSLog(@"Choose here %d",i);
                [results addObject:event];
            }
            
        }
    }

    else if ([distance isEqualToString:@"3"]){ 
        for (int i=0; i<size; i++) {
            NSDictionary *event= [JsonResult objectAtIndex:i];
            NSDictionary *venueInfo = [event objectForKey:@"venue"];
            CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[venueInfo objectForKey:@"latitude"] doubleValue] longitude:[[venueInfo objectForKey:@"longitude"] doubleValue]];
            CLLocationDistance dist = [currentLocation distanceFromLocation:locB]/METERS_PER_MILE;
            if (dist>2.0) {
                [results addObject:event];
            }
            
        }
    }
    else results = [[NSMutableArray alloc] initWithArray:JsonResult];

    
    
    
    
    
   // NSLog(@"Search result : %@",results);
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    for (id annotation in mapView.annotations)
        if (annotation != mapView.userLocation)
            [toRemove addObject:annotation];
    [mapView removeAnnotations:toRemove];
    
    [self.myTable reloadData];

    }



- (MyAnnotation *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	NSLog(@"welcome into the map view annotation");
	
	// if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
	// try to dequeue an existing pin view first
	static NSString* AnnotationIdentifier = @"AnnotationIdentifier";
	MKPinAnnotationView* pinView = [[MKPinAnnotationView alloc]
                                    initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier] ;
	pinView.animatesDrop=YES;
	pinView.canShowCallout=YES;
	pinView.pinColor=MKPinAnnotationColorPurple;
    MyAnnotation* myAnnotation = (MyAnnotation *)annotation;
	
	
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	[rightButton setTitle:annotation.title forState:UIControlStateNormal];
	[rightButton addTarget:self
					action:@selector(showDetails:)
		  forControlEvents:UIControlEventTouchUpInside];
    [rightButton setTag:myAnnotation.eventID];
	pinView.rightCalloutAccessoryView = rightButton;
    
   
    NSURL* aURL = [NSURL URLWithString:myAnnotation.urlString];
    NSData* data = [[NSData alloc] initWithContentsOfURL:aURL];
    
    CGSize newSize = CGSizeMake(30.0, 30.0);
    UIGraphicsBeginImageContext( newSize );
    [[UIImage imageWithData:data] drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
	UIImageView *profileIconView = [[UIImageView alloc] initWithImage:newImage];
	pinView.leftCalloutAccessoryView = profileIconView;
	
	
	
	return pinView;
}

-(IBAction)showDetails:(id)sender{
    
	NSLog(@"Annotation Click");
    NSInteger tid = [sender tag];
    
    Event *event = [Event alloc];
    NSDictionary *eventInfo= [results objectAtIndex:tid];
    //    NSLog(@"Event info : %@",eventInfo);
    
    
    [event setTitle:[eventInfo objectForKey:@"title"]];
    NSString *description = [eventInfo objectForKey:@"description"];
    
    [event setDescription:[self stringByStrippingHTML:description]];
    NSArray *occurrences = [eventInfo objectForKey:@"occurrences"];
    NSString *start = [[occurrences objectAtIndex:0] objectForKey:@"start"];
    NSString *endTime = (NSString *)[[occurrences objectAtIndex:0] objectForKey:@"end"];
    [event setStart:start];
    
    if ([endTime isKindOfClass:[NSNull class]]) {
        
        [event setEnd:@""];
    }
    else {
        [event setEnd:endTime];
    }
    
    NSDictionary *venueInfo = [eventInfo objectForKey:@"venue"];
    //    NSLog(@"End %@",eventInfo);
    [event setLatitude:[[venueInfo objectForKey:@"latitude"] doubleValue]];
    [event setLongitude:[[venueInfo objectForKey:@"longitude"] doubleValue]];
    [event setVenueName:[venueInfo objectForKey:@"name"]];
    [event setVenueAddress:[venueInfo objectForKey:@"address"]]; 
    [event setVenueCity:[venueInfo objectForKey:@"city"]];
    [event setVenueState:[venueInfo objectForKey:@"state"]];
    [event setVenueZip:[[venueInfo objectForKey:@"zip"] stringValue]];
    [event setVenueID:[eventInfo objectForKey:@"venue_id"]];
    [event setPrice:[eventInfo objectForKey:@"price"]];
    
    
    
    
    
    
    
    
    
    [self showEvent:event animated:YES];

	
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Number of rows : %d",[results count]);
    return [results count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    NSString *CellIdentifer =@"OurCell";
    CustomCell *cell = [[CustomCell alloc] init];
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Cell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *event= [results objectAtIndex:indexPath.row];
    NSString *description =[event objectForKey:@"description"];
    NSString *title = [event objectForKey:@"title"];
    NSString *urlString = [self stringBetweenString:@"src=\"" andString:@"\"" theString:description];
    cell.ourLabel.text =title;
    //    NSLog(@"Event : %@",event);
    
    NSArray *occurrences = [event objectForKey:@"occurrences"];
    
    NSString *start = [[occurrences objectAtIndex:0] objectForKey:@"start"];
    NSString *endT = (NSString *)[[occurrences objectAtIndex:0] objectForKey:@"end"];
    
    NSString *endTime = @"";
    
    if (![endTime isKindOfClass:[NSNull class]]) {
        endTime = endT;       
    }
    
    NSString *dateString = start;
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss-ss:ss"];
    NSDate* date = [df dateFromString:dateString];
    [df setDateFormat:@"EEEE, MMMM d"];
    NSString *strDate1 = [df stringFromDate:date];
    [df setDateFormat:@"hh:mm a"];
    NSString * strDate = [df stringFromDate:date];
    
    NSString *eventTime = @"";
    if (![endTime isKindOfClass:[NSNull class]]) {
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss-ss:ss"];
        date = [df dateFromString:endTime];
        [df setDateFormat:@"hh:mm a"];
        NSString *strDateEnd = [df stringFromDate:date];
        eventTime = [[strDate1 stringByAppendingFormat:@" at "] stringByAppendingFormat: [[strDate stringByAppendingFormat:@" to "] stringByAppendingFormat: strDateEnd]];
        
    }
    else{
        eventTime = [[strDate1 stringByAppendingFormat:@" at "] stringByAppendingFormat:strDate]; 
        
    }
    
    //    NSLog(@"Event time : %@",eventTime);
    cell.timeLabel.text = eventTime;
    
    if(urlString==nil)cell.ourImage.image=[UIImage imageNamed:@"first.png"];
    else {
        NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:urlString]];
        cell.ourImage.image=[UIImage imageWithData:data];
    }
    
    NSDictionary *venueInfo = [event objectForKey:@"venue"];
    //    NSLog(@"End %@",eventInfo);
    
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:[[venueInfo objectForKey:@"latitude"] doubleValue] longitude:[[venueInfo objectForKey:@"longitude"] doubleValue]];
    CLLocationDistance distance = [currentLocation distanceFromLocation:locB];
    //    NSLog(@"Distance %.2f mi",distance/METERS_PER_MILE);
    cell.distance.text = [NSString stringWithFormat:@"%.1f mi",distance/METERS_PER_MILE];
    
    NSString *eventPrice = [event objectForKey:@"price"];
    if ([eventPrice isKindOfClass:[NSNull class]]) {
        
        cell.price.text = @"";
    }
    else if([eventPrice isEqualToString:@"0.0"] ) {
        cell.price.text = @"FREE";
        
    }
    else cell.price.text =[@"$" stringByAppendingFormat:eventPrice];
    
    CLLocationCoordinate2D zoomLocation;
    MyAnnotation* myAnnotation=[[MyAnnotation alloc] init];
    

    zoomLocation.latitude = [[venueInfo objectForKey:@"latitude"] doubleValue];
    zoomLocation.longitude= [[venueInfo objectForKey:@"longitude"] doubleValue];
    [myAnnotation setCoordinate: zoomLocation];
    [myAnnotation setTitle:title];
    [myAnnotation setSubtitle:[venueInfo objectForKey:@"name"]];
    [myAnnotation setUrlString:urlString];
    [myAnnotation setEventID:indexPath.row];
   
    [mapView addAnnotation:myAnnotation]; 
    
    [annotations addObject:myAnnotation];
    

//    if([indexPath row] == (results.count-1)){
//        //end of loading
//        //for example [activityIndicator stopAnimating];
//        NSLog(@"End loading %d",indexPath.row);
//            MKMapRect flyTo = MKMapRectNull;
//        	for (id <MKAnnotation> annotation in annotations) {
//        		NSLog(@"fly to on");
//                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
//                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0, 0);
//                if (MKMapRectIsNull(flyTo)) {
//                    flyTo = pointRect;
//                } else {
//                    flyTo = MKMapRectUnion(flyTo, pointRect);
//        			//NSLog(@"else-%@",annotationPoint.x);
//                }
//            }
//            
//            // Position the map so that all overlays and annotations are visible on screen.
//            mapView.visibleMapRect = flyTo;
//        
//    }

    
    
    
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 3.5*METERS_PER_MILE, 3.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    // 4
    
    [mapView setRegion:adjustedRegion animated:YES]; 
     
    return  cell;
    
}

-(NSString *) stringByStrippingHTML:(NSString *)s {
    NSRange r;
    
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    return s; 
}

-(NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end theString:(NSString *)s {
    NSRange startRange = [s rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [s length] - targetRange.location;   
        NSRange endRange = [s rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [s substringWithRange:targetRange];
        }
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Event *event = [Event alloc];
    NSDictionary *eventInfo= [results objectAtIndex:indexPath.row];
    //    NSLog(@"Event info : %@",eventInfo);
    
    
    [event setTitle:[eventInfo objectForKey:@"title"]];
    NSString *description = [eventInfo objectForKey:@"description"];
    
    [event setDescription:[self stringByStrippingHTML:description]];
    NSArray *occurrences = [eventInfo objectForKey:@"occurrences"];
    NSString *start = [[occurrences objectAtIndex:0] objectForKey:@"start"];
    NSString *endTime = (NSString *)[[occurrences objectAtIndex:0] objectForKey:@"end"];
    [event setStart:start];
    
    if ([endTime isKindOfClass:[NSNull class]]) {
        
        [event setEnd:@""];
    }
    else {
        [event setEnd:endTime];
    }
    
    NSDictionary *venueInfo = [eventInfo objectForKey:@"venue"];
    //    NSLog(@"End %@",eventInfo);
    [event setLatitude:[[venueInfo objectForKey:@"latitude"] doubleValue]];
    [event setLongitude:[[venueInfo objectForKey:@"longitude"] doubleValue]];
    [event setVenueName:[venueInfo objectForKey:@"name"]];
    [event setVenueAddress:[venueInfo objectForKey:@"address"]]; 
    [event setVenueCity:[venueInfo objectForKey:@"city"]];
    [event setVenueState:[venueInfo objectForKey:@"state"]];
    [event setVenueZip:[[venueInfo objectForKey:@"zip"] stringValue]];
    [event setVenueID:[eventInfo objectForKey:@"venue_id"]];
    [event setPrice:[eventInfo objectForKey:@"price"]];
    
    
    
    
    
    
    
    
    
    [self showEvent:event animated:YES];
    
}

- (void)showEvent:(Event *)event animated:(BOOL)animated {
    EventViewController *eventViewController = [[EventViewController alloc] init] ;//]WithNibName:@"EventViewController"  bundle:nil];
    eventViewController.event = event;
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[delegate.navController1  pushViewController:eventViewController animated:YES];
//    
//    [eventViewController release];
    
    
    
    
}
-(IBAction) setFilter{
    NSLog(@"Set filter");
    FilterViewController *filterViewController = [[FilterViewController alloc] init] ;
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[delegate.navController1  pushViewController:filterViewController animated:YES];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
