//
//  Event.h
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Event : NSObject
{
    NSString *title;
    NSString *description;
    NSString *start;
    NSString *endTime;
    NSString *venueName;
    NSString *venueAdress;
    NSString *venueCity;
    NSString *venueState;
    NSString *venueZip;
    NSString *venueID;
    NSString *price;
    CLLocationDegrees latitude;
    CLLocationDegrees longitude;
}
-(void) setTitle: (NSString *) titleK;
-(void) setDescription: (NSString *) descriptionK;
-(void) setStart: (NSString *) startK;
-(void) setEnd: (NSString *) endK;
-(void) setVenueName: (NSString *) venueNameK;
-(void) setVenueAddress: (NSString *) venueAddressK;
-(void) setVenueCity: (NSString *) venueCityK;
-(void) setVenueState: (NSString *) venueStateK;
-(void) setVenueZip: (NSString *) venueZipK;
-(void) setPrice: (NSString *) priceK;
-(void) setLatitude: (CLLocationDegrees) latitudeK;
-(void) setLongitude: (CLLocationDegrees) longitudeK;
-(void) setVenueID:(NSString *) venueIDK;

-(NSString *) getVenueID;
-(NSString *) getTitle;
-(NSString *) getDescription;
-(NSString *) getStart;
-(NSString *) getEnd;
-(NSString *) getVenueName;
-(NSString *) getVenueAddress;
-(NSString *) getVenueCity;
-(NSString *) getVenueState;
-(NSString *) getVenueZip;
-(NSString *) getPrice;
-(CLLocationDegrees) getLatitude;
-(CLLocationDegrees) getLongitude;



@end
