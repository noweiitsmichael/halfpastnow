//
//  MyAnnotation.h
//  HPNow
//
//  Created by Triet Le on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef enum {
	iCodeBlogAnnotationTypeApple = 0,
	iCodeBlogAnnotationTypeEDU = 1,
	iCodeBlogAnnotationTypeTaco = 2
} iCodeMapAnnotationType;

@interface MyAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	iCodeMapAnnotationType annotationType;
    NSString *urlString;
    int eventID;
}

@property (nonatomic,assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic) iCodeMapAnnotationType annotationType;
@property (nonatomic) int eventID;

@end
