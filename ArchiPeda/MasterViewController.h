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

@interface MasterViewController : UITableViewController <UISearchBarDelegate> {
    BOOL rowPressed;
    
    MBProgressHUD *HUD;
    NSIndexPath *globalIndex;
    BOOL searching;
    BOOL firstStarting;
    NSMutableArray *displayedTags;
    NSMutableArray *searchResults;
    NSString *searchTerm;
}

- (IBAction)switchView:(id)sender;
- (IBAction)searchButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *BackButton;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) Helper *currentDataHelper;
@property (strong, nonatomic) NSMutableArray *previousHelpers;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) BOOL searching;
@property (strong, nonatomic) IBOutlet UIToolbar *searchToolbar;


//- (void) searchTableView;
//- (void) doneSearching_Clicked:(id)sender;


@end
