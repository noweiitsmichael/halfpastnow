//
//  SecondViewController.m
//  HPNow
//
//  Created by Triet Le on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"
#import "ASIFormDataRequest.h"
#import "ASIS3ObjectRequest.h"

@interface SecondViewController ()

@end





@implementation SecondViewController
@synthesize imageView;
@synthesize saveImageBotton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Second", @"Second");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}
	
#pragma mark - Show camera

-(IBAction)showCameraAction:(id)sender
{
    

    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
    imagePickController.delegate=self;
    imagePickController.allowsEditing=TRUE;
    [self presentModalViewController:imagePickController animated:YES];
    
}

#pragma mark - Save photo

-(IBAction)saveImageAction:(id)sender
{
    NSString *secretAccessKey = @"sGl4J/tMjKx8TyqfBGi95drdWSohWIw5GYv5pzig";
    NSString *accessKey = @"AKIAJ7DK3A7EKGE7CEQA";
    NSString *bucket = @"my-unique-name-akiaj7dk3a7ekge7ceqapicture-bucket";
    UIImage *image=imageView.image;
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent: @"test.jpg"];

    [UIImageJPEGRepresentation(image, 1.0) writeToFile:path atomically:YES];
    
    objectRequest = [ASIS3ObjectRequest PUTRequestForFile:path withBucket:bucket key:@"test.jpg"];
    [objectRequest setSecretAccessKey:secretAccessKey];
    [objectRequest 
setAccessPolicy:@"public-read"]; 
    [objectRequest setAccessKey:accessKey];
    [objectRequest startSynchronous];
    if ([objectRequest error]) {
        NSLog(@"%@",[[objectRequest error] localizedDescription]);
    }    

    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    saveImageBotton.enabled=FALSE;
}

#pragma mark - When finish shoot

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    imageView.image=image;
    saveImageBotton.enabled=TRUE;
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Release object


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
