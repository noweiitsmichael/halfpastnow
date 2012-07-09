//
//  SecondViewController.h
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ASIFormDataRequest;

@class ASIS3ObjectRequest;

@interface SecondViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    ASIFormDataRequest *request;
    ASIS3ObjectRequest *objectRequest;
}

@property(nonatomic,retain)IBOutlet UIImageView *imageView;
@property(nonatomic,retain)IBOutlet UIBarButtonItem *saveImageBotton;
@property (retain, nonatomic) ASIFormDataRequest *request;
@property (retain, nonatomic)  ASIS3ObjectRequest *objectRequest;

-(IBAction)showCameraAction:(id)sender;
-(IBAction)saveImageAction:(id)sender;

@end