//
//  ImageViewController.h
//  ArchiPeda
//
//  Created by Jeffrey Delawder Jr on 10/14/12.
//  Copyright (c) 2012 Jeffrey Delawder Jr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h> 
#import "DetailViewController.h"

@class MBProgressHUD;

@interface ImageViewController : UIViewController <UIScrollViewDelegate, SDWebImageManagerDelegate, UISplitViewControllerDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate >
{
    //Drawing variables.
    CGPoint previousPoint;
    NSMutableArray *drawnPoints;
    UIImage *cleanImage;
    
    
    //Loading Wheel
    MBProgressHUD *HUD;
}
//@property (strong, nonatomic) DrawingViewController *drawingView;

//The imageScrollView is required for image zooming
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;

//imageURL stores the current image being displayed url
@property (strong, nonatomic) NSString *imageURL;

//A handle to the gridViewController aka DetailViewController
@property (strong, nonatomic) DetailViewController *handleSubMaster;

//Image's size
@property CGSize imageSize;

//Place holder for email alertView
@property UIAlertView *alert;

//The Bar Button Icon that turns "on" drawing mode.
@property (strong, nonatomic) IBOutlet UIBarButtonItem *paletteButton;
- (IBAction)palettePressed:(id)sender;

//Index of current image
@property int currentNumber;

- (void)configureView;
-(IBAction)sendEmail;


@end