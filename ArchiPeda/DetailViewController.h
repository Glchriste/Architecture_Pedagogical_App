//
//  DetailViewController.h
//  AApp
//
//  Created by Jeffrey Delawder on 6/5/12.
//  Copyright (c) 2012 University of North Carolina at Charlotte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
@class MasterViewController, ImageViewController;
@interface DetailViewController : UITableViewController <UISplitViewControllerDelegate, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate >

@property (strong, nonatomic) NSArray *imageStrings;
@property (strong, nonatomic) NSArray *imageIDs;
@property (strong, nonatomic) NSArray *realURLS;
@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *imageIDURL;
@property (strong, nonatomic) NSURL *real;

@property (strong, nonatomic) NSMutableArray *selectedImages;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *selectMultipleButton;
@property (strong, nonatomic) ImageViewController *imageDetailViewController;

- (IBAction)selectMultiple:(id)sender;
- (IBAction)selectSingle:(id)sender;
//- (IBAction)sendEmail:(id)sender;

-(void)removeDetail;
-(void)update;

@end
