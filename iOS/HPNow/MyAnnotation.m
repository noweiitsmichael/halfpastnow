//
//  MyAnnotation.m
//  HPNow
//
//  Created by Triet Le on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize annotationType;
@synthesize urlString;
@synthesize eventID;

-init
{
	return self;
}

-initWithCoordinate:(CLLocationCoordinate2D)inCoord
{
	coordinate = inCoord;
	return self;
}

@end
