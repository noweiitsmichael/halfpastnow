//
//  VenueViewController.m
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VenueViewController.h"
#import "JSON.h"
#import "ASIFormDataRequest.h"
#import "CustomCell.h"
#import "EventViewController.h"
#import "AppDelegate.h"
#import "Event.h"
#define METERS_PER_MILE 1609.344

@interface VenueViewController ()

@end

@implementation VenueViewController
@synthesize venueEvents;
@synthesize venueName;
@synthesize add1;
@synthesize add2;
@synthesize phone;
@synthesize mapView;
@synthesize venueInfo;
@synthesize occurrences;
@synthesize recurrences;
@synthesize myTable;
@synthesize currentLocation;
@synthesize locationManager;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.locationManager = [[CLLocationManager alloc] init] ;
        self.locationManager.delegate = self; // send loc updates to myself
    }
    return self;
}

-(void) setVenueID:(NSString *) venueIDK{
    venueID = venueIDK;
}

-(NSString *) getVenueID{
    return venueID ;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [scrollview setScrollEnabled:YES];
	[scrollview setContentSize:CGSizeMake(320, 4000)];
    NSLog(@"Venue id %@",venueID);
    NSString *str = [[@"http://halfpastnow.herokuapp.com/venues/show/" stringByAppendingFormat:venueID] stringByAppendingFormat:@".json"];
    NSURL *url = [NSURL URLWithString:str];
    ASIFormDataRequest *requestG = [ASIFormDataRequest requestWithURL:url];
    [requestG startSynchronous];
    NSString *jsonString = [[NSString alloc] initWithData:[requestG responseData] encoding:NSUTF8StringEncoding];
    venueEvents = [jsonString JSONValue] ;
    NSString *occurrencesString = [venueEvents objectForKey:@"occurrences"];
    NSString *recurrencesString = [venueEvents objectForKey:@"recurrences"];
    NSString *venueString = [venueEvents objectForKey:@"venue"];
    NSDictionary *venue = [venueString JSONValue];
    occurrences = [occurrencesString JSONValue] ;
    recurrences = [recurrencesString JSONValue] ;
    venueInfo =[venueString JSONValue] ;
    //    NSLog(@"results :@",venue);
    
    self.venueName.text = [venueInfo objectForKey:@"name"];
    self.add1.text = [venueInfo objectForKey:@"address"];
    self.add2.text = [[[[[venueInfo objectForKey:@"city"] stringByAppendingFormat:@" "] stringByAppendingFormat:[venue objectForKey:@"state"]] stringByAppendingFormat:@", "] stringByAppendingFormat:[[venue objectForKey:@"zip"] stringValue]];
    self.phone.text = [@"Phone: " stringByAppendingFormat:[venue objectForKey:@"phonenumber"]];
    CLLocationCoordinate2D zoomLocation;
    zoomLocation.latitude = [[venueInfo objectForKey:@"latitude"] doubleValue] ;
    zoomLocation.longitude= [[venueInfo objectForKey:@"longitude"] doubleValue];
    // 2
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    // 3
    MKCoordinateRegion adjustedRegion = [mapView regionThatFits:viewRegion];                
    // 4
    [locationManager startUpdatingLocation];
    
    //    NSLog(@"Lat : %f Long : %f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    
    currentLocation = locationManager.location ;
    
    currentLocation = locationManager.location ;
    [mapView setRegion:adjustedRegion animated:YES]; 
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = zoomLocation;
    
    [mapView addAnnotation:annotationPoint]; 
    
    //    NSDictionary *rec =[recurrences objectAtIndex:1];
    //    int mod = [[rec objectForKey:@"every_other"] intValue];
    //    NSString *temp = (mod==0)?@"":( (mod==1)? @"OTHER" :[self to_ordinal:mod]  );
    //    NSLog(@"mod=%d temp : %@",mod,[@"EVERY " stringByAppendingFormat:temp]);
    //    id day_of_week = [rec objectForKey:@"day_of_week"];
    //    id week_of_month =[rec objectForKey:@"week_of_month"];
    //    id day_of_month =[rec objectForKey:@"day_of_month"];
    //    NSArray *array = [NSArray arrayWithObjects:@"SUN",@"MON",@"TUE",@"WED",@"THU",@"FRI",@"SAT",nil];
    //    NSString *day=@"";
    //    if (![day_of_week isKindOfClass:[NSNull class]] && ![week_of_month isKindOfClass:[NSNull class]]) {
    //        day = [[[self to_ordinal:[week_of_month intValue]] stringByAppendingFormat:@" "] stringByAppendingFormat:[array objectAtIndex:[day_of_week intValue]]];
    //    
    //    }
    //    else {
    //        if (![day_of_month isKindOfClass:[NSNull class]]) {
    //            day = [self to_ordinal:[day_of_month intValue]];
    //        }
    //        else if(![day_of_week isKindOfClass:[NSNull class]]){
    //            day = [array objectAtIndex:[day_of_week intValue]];
    //        }
    //        else {
    //            day =@"DAY";
    //        }
    //    }
    //    NSLog(@"DAY=%@",day);
    //    
    //    NSString *dateString = [rec objectForKey:@"start"];
    //    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    //    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss-ss:ss"];
    //    NSDate* date = [df dateFromString:dateString];
    //    [df setDateFormat:@"hh:mma"];
    //    NSString *strDate = [df stringFromDate:date];
    //    NSLog(@"Time : %@",strDate);
    //    NSLog(@"Number of rows here : %d",[recurrences count] + [occurrences count]);
    
    
}
-(NSString *) to_ordinal:(int) num{
    NSArray *array = [NSArray arrayWithObjects:@"th",@"st",@"nd",@"rd",@"th",@"th",@"th",@"th",@"th",@"th", nil];
    int n = num % 10;
    NSString *tmp = [array objectAtIndex:n];
    return [[NSString stringWithFormat:@"%d",num] stringByAppendingFormat: tmp];
}
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Number of rows %d",[recurrences count]+[occurrences count]);
    return [occurrences count] + [recurrences count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifer =@"OurCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifer];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Cell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    int recCount = [recurrences count];
    NSLog(@"#recs %d",recCount);
    NSLog(@"indexpath.row %d",indexPath.row);
    NSDictionary *timeInfo = [[NSDictionary alloc] init];
    if (indexPath.row < recCount) {
        timeInfo = [recurrences objectAtIndex:indexPath.row];
    }
    else timeInfo = [occurrences objectAtIndex:(indexPath.row - recCount)];
    
    NSLog(@"timeInfo %@",timeInfo);
    
    NSDictionary *event= [timeInfo objectForKey:@"event"];
    NSString *description =[event objectForKey:@"description"];
    NSString *title = [event objectForKey:@"title"];
    NSString *urlString = [self stringBetweenString:@"src=\"" andString:@"\"" theString:description];
    cell.ourLabel.text =title;
    //    NSLog(@"Event : %@",event);
    
    
    
    NSString *start = [timeInfo objectForKey:@"start"];
    NSString *endT = (NSString *)[timeInfo objectForKey:@"end"];
    
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
    
    
    NSString *eventPrice = [event objectForKey:@"price"];
    if ([eventPrice isKindOfClass:[NSNull class]]) {
        
        cell.price.text = @"";
    }
    else if([eventPrice isEqualToString:@"0.0"] ) {
        cell.price.text = @"FREE";
        
    }
    else cell.price.text =[@"$" stringByAppendingFormat:eventPrice];
    cell.distance.text=@"";
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Event *event = [Event alloc];
    
    //    NSLog(@"Event info : %@",eventInfo);
    int recCount = [recurrences count];
    NSLog(@"#recs %d",recCount);
    NSLog(@"indexpath.row %d",indexPath.row);
    NSDictionary *timeInfo = [[NSDictionary alloc] init];
    if (indexPath.row < recCount) {
        timeInfo = [recurrences objectAtIndex:indexPath.row];
    }
    else timeInfo = [occurrences objectAtIndex:(indexPath.row - recCount)];
    
    NSDictionary *eventInfo = [timeInfo objectForKey:@"event"];
    [event setTitle:[eventInfo objectForKey:@"title"]];
    NSString *description = [eventInfo objectForKey:@"description"];
    
    [event setDescription:[self stringByStrippingHTML:description]];
    
    NSString *start = [timeInfo objectForKey:@"start"];
    NSString *endTime = (NSString *)[timeInfo objectForKey:@"end"];
    [event setStart:start];
    
    if ([endTime isKindOfClass:[NSNull class]]) {
        
        [event setEnd:@""];
    }
    else {
        [event setEnd:endTime];
    }
    
    
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
    
    //    NSString *title;
    //    
    //    NSDate *start;
    //    NSDate *end;
    //    NSString *venueName;
    //    NSString *venueAdress;
    //    NSString *venueCity;
    //    NSString *venueState;
    //    NSString *venueZip;
    //    NSString *venueID;
    //    float price;
    //    CLLocationDegrees latitude;
    //    CLLocationDegrees longitude;
    //    NSLog(@"title : %@", event.getTitle);
    //    NSLog(@"Description : %@",event.getDescription);
    //    NSLog(@"start : %@", event.getStart);
    //    NSLog(@"End : %@", event.getEnd);
    //    NSLog(@"Name : %@", event.getVenueName);
    //    NSLog(@"Address : %@", event.getVenueAddress);
    //    NSLog(@"City : %@", event.getVenueCity);
    //    NSLog(@"State : %@", event.getVenueState);
    //    NSLog(@"Zip : %@", event.getVenueZip);
    //    NSLog(@"VenueID : %@", event.getVenueID);
    //    NSLog(@"Price : %@", event.getPrice);
    //    NSLog(@"Latitude : %f", event.getLatitude);
    //    NSLog(@"Longitude : %f", event.getLongitude);
    EventViewController *eventViewController = [[EventViewController alloc] init] ;//]WithNibName:@"EventViewController"  bundle:nil];
    eventViewController.event = event;
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	
	[delegate.navController1  pushViewController:eventViewController animated:YES];
    
   
    
    
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
