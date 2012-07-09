//
//  Event.m
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@implementation Event

-(void) setTitle: (NSString *) titleK{
    title = titleK;
}
-(void) setDescription: (NSString *) descriptionK{
    description = descriptionK;
}
-(void) setStart: (NSString *) startK{
    start = startK;
}
-(void) setEnd: (NSString *) endK{
    endTime = endK;
}
-(void) setVenueName: (NSString *) venueNameK{
    venueName =venueNameK;
}
-(void) setVenueAddress: (NSString *) venueAddressK{
    venueAdress =venueAddressK;
}
-(void) setVenueCity: (NSString *) venueCityK{
    venueCity =venueCityK;
}
-(void) setVenueState: (NSString *) venueStateK{
    venueState =venueStateK;
}
-(void) setVenueZip: (NSString *) venueZipK{
    venueZip =venueZipK;
}
-(void) setPrice: (NSString *) priceK{
    price =priceK;
}
-(void) setLatitude: (CLLocationDegrees) latitudeK{
    latitude =latitudeK;
}
-(void) setLongitude: (CLLocationDegrees) longitudeK{
    longitude =longitudeK;
}

-(void) setVenueID:(NSString *) venueIDK{
    venueID =venueIDK;
}

-(NSString *) getVenueID{
    return  venueID;
}

-(NSString *) getTitle{
    return title;
}
-(NSString *) getDescription{
    return description;
}
-(NSString *) getStart{
    return start;
}
-(NSString *) getEnd{
    return endTime;
}
-(NSString *) getVenueName{
    return venueName;
}
-(NSString *) getVenueAddress{
    return venueAdress;
}
-(NSString *) getVenueCity{
    return venueCity;
}
-(NSString *) getVenueState{
    return venueState;
}
-(NSString *) getVenueZip{
    return venueZip;
}
-(NSString *) getPrice{
    return price;
}
-(CLLocationDegrees) getLatitude{
    return latitude;
}
-(CLLocationDegrees) getLongitude{
    return longitude;
}

@end
