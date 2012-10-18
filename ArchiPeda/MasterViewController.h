//
//  MasterViewController.h
//  ArchiPeda
//
//  Created by Jeffrey Delawder Jr on 10/13/12.
//  Copyright (c) 2012 Jeffrey Delawder Jr. All rights reserved.
//

#import <UIKit/UIKit.h>



@class DetailViewController;
@class Helper;
@class MBProgressHUD;

@interface MasterViewController : UITableViewController{
    BOOL rowPressed;
    
    MBProgressHUD *HUD;
    NSIndexPath *globalIndex;
    
}

- (IBAction)switchView:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *BackButton;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) Helper *currentDataHelper;
@property (strong, nonatomic) NSMutableArray *previousHelpers;


@end
