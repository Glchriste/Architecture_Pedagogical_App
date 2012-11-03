//
//  MasterViewController.m
//  ArchiPeda
//
//  Created by Jeffrey Delawder Jr on 10/13/12.
//  Copyright (c) 2012 Jeffrey Delawder Jr. All rights reserved.
//
#define WEBURL @"http://aswiftlytiltingplanet.net/senske/TagsWithImages.txt"
#define FILENAME @"TagData"
#define FOLDERBASEURL @"http://coaamedia.uncc.edu/ipad/PowerShot%20Folder/INDEX.txt"
#define FOLDERNAME @"BASEFOLDER.txt"

#import "Helper.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MBProgressHUD.h"

//Simple Way to Identify Viewing State
enum STATES {
    TAGSTATE = 0,
    FOLDERSTATE = 1
};

@interface MasterViewController (){
    int currentState;
    NSString *parentFolder;
}
@end

@implementation MasterViewController

@synthesize detailViewController = _detailViewController, currentDataHelper = _currentDataHelper, previousHelpers = _previousHelpers, BackButton = _BackButton;
@synthesize searchToolbar;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    displayedTags = [[NSMutableArray alloc] init];
    searchResults = [[NSMutableArray alloc] init];
    firstStarting = YES;
    searching = NO;
    _searchBar.delegate = self;
    //self.navigationController.navigationBar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"woodpattern3.png"]];
    //self.searchToolbar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"woodpattern3.png"]];
    //self.navigationController.toolbar.tintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"woodpattern3.png"]];
    //self.bottomToolbar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mahogany.png"]];
    
    //UIView *im = [[UIView alloc] init];
    //im.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"woodpattern3.png"]];
    //[self.tableView setBackgroundView:im];
	
    rowPressed = NO;
    //Initially Begin With Tag View
    currentState = TAGSTATE;
    _currentDataHelper = [[Helper alloc]init];
    [_currentDataHelper setCurrentState:currentState];
    [_currentDataHelper loadData];
    _previousHelpers = [[NSMutableArray alloc]init ];
    
    //Refresh The View
    [self.tableView reloadData];
    //Make Table BGColor white
    self.view.backgroundColor = [UIColor whiteColor];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    //self.detailViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"wood1.jpeg"]];

    //Progress Wheel
    HUD = [[MBProgressHUD alloc] initWithView:self.detailViewController.view];
    [self.detailViewController.view addSubview:HUD];
    //HUD.mode = MBProgressHUDModeAnnularDeterminate;
    
    //Gives Images to the Grid View
    [_detailViewController setImageURL:_currentDataHelper.imageURL];
    [_detailViewController setImageIDURL:_currentDataHelper.imageIDURLS];
    [_detailViewController setReal:_currentDataHelper.realURLS];
    [_detailViewController update];
    
    
}

- (IBAction)goToTop:(id)sender {
    [self.tableView scrollRectToVisible:[[self.tableView tableHeaderView] bounds] animated:YES];
}

//
- (IBAction)searchButtonClicked:(id)sender
{
    int len = [ [_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
    
    if (len > 0)
    {
        [self searchTableView];
    }
    else
    {
        [_searchBar resignFirstResponder ];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey now"
                                                        message:@"Search term needs to be at least 3 characters in length."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    [self.tableView reloadData];
}

- (void) searchTableView
{
    //Remove results.
    [searchResults removeAllObjects];
    NSString *searchText = _searchBar.text;
    searchText = [searchText lowercaseString];
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    searchTerm = searchText;
    
    if ([searchText length] > 0)
    {
        //Implement search
        searching = YES;
        for(NSString *string in [_currentDataHelper currentDirectoryContentsNames]) {
            NSString *temp = [[string lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([temp isEqualToString:searchText] || (([temp rangeOfString:searchText].location != NSNotFound) && ([[temp substringToIndex:1] isEqualToString:[searchText substringToIndex:1]]))) {
                
                NSLog([[string lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]);
                [searchResults addObject:[[string lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
        
    }
}

//Real-time searching.
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    int len = [ [_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
    
    if (len > 0)
    {
        [self searchTableView];
    }
    [self.tableView reloadData];
    NSLog(@"Real-time searching...");
    
}

//When the user presses "Search" on the keyboard.
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"Search Entered");
    int len = [ [_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
    
    if (len > 0)
    {
        [self searchTableView];
    }
    [_searchBar resignFirstResponder];
}

- (void)viewDidUnload
{
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{   if(searching) {
        return searchResults.count;
    }
    else {
        return [_currentDataHelper length];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    

    //Write the tag name in the row.
    
    UIFont *textFont = [UIFont boldSystemFontOfSize:20];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    if(currentState == FOLDERSTATE) {
        cell.textLabel.text = @"          ";
    }
    else {
        cell.textLabel.text = @"     ";
    }
    //If not searching, load all tags alphabetically.
    if(!searching){
        cell.textLabel.text = [cell.textLabel.text stringByAppendingString:[_currentDataHelper nameForIndex:indexPath]];
        //cell.textLabel.textColor = [UIColor blackColor];
        
        //Temporarily commented tag # due to slowness.
        cell.detailTextLabel.text = @"#";
        cell.detailTextLabel.textColor = [UIColor blackColor];
        //Image count is placed in the subtitle.
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            cell.detailTextLabel.text = [NSString stringWithFormat:@"       %@", [_currentDataHelper numberOfImages:indexPath.row] ];
        });
    } else {
        //Load search results.
        NSArray *searchArray = [[NSArray alloc] initWithArray:searchResults];
        //Sort the array alphabetically.
        searchArray = [searchArray sortedArrayUsingSelector:
                         @selector(localizedCaseInsensitiveCompare:)];
        //Load the results into the tableview.
            cell.textLabel.text = @"     ";
        if(searchArray.count > 1) {
                cell.textLabel.text = [cell.textLabel.text stringByAppendingString:[searchArray objectAtIndex:indexPath.row]];
        }
        else if(searchArray.count == 1 && indexPath.row == 0){
            cell.textLabel.text = [cell.textLabel.text stringByAppendingString:[searchArray objectAtIndex:0]];
        } else {
            cell.textLabel.text = @"";
        }

    
    }
    //Set the font of the text.
    [cell.textLabel setFont:textFont];
    
    //Code that simulates folder browsing.
    if (currentState == FOLDERSTATE) {
        if(indexPath.row == 0 && rowPressed == YES)
        {
            //Parent Folder
            for(UIButton* button in cell.contentView.subviews)
            {
                [button removeFromSuperview];
            }
            
            [[cell.contentView.subviews lastObject] removeFromSuperview];
            UIButton *myAccessoryButton =[[UIButton alloc] init];
            myAccessoryButton =[self makeAccessoryButton: @"FolderDownArrow.png"];
            CGRect buttonFrame = myAccessoryButton.frame;
            buttonFrame.origin.y = 10;
            buttonFrame.origin.x = 5;
            buttonFrame.size = CGSizeMake(50, 32);
            myAccessoryButton.frame = buttonFrame;
            [cell.contentView addSubview:myAccessoryButton];
        }
        else if(indexPath != 0 && rowPressed == YES){
            
            for(UIButton* button in cell.contentView.subviews)
            {
                [button removeFromSuperview];
            }
            
            [[cell.contentView.subviews lastObject] removeFromSuperview];
            UIButton *myAccessoryButton =[[UIButton alloc] init];
            myAccessoryButton =[self makeAccessoryButton: @"FolderRightArrow.png"];
            CGRect buttonFrame = myAccessoryButton.frame;
            buttonFrame.origin.y = 10;
            buttonFrame.origin.x = 15;
            buttonFrame.size = CGSizeMake(50, 32);
            myAccessoryButton.frame = buttonFrame;
            [cell.contentView addSubview:myAccessoryButton];
        }
        
        
        else if (indexPath != 0 && rowPressed == NO){
            for(UIButton* button in cell.contentView.subviews)
            {
                [button removeFromSuperview];
            }
            
            [[cell.contentView.subviews lastObject] removeFromSuperview];
            UIButton *myAccessoryButton =[[UIButton alloc] init];
            myAccessoryButton =[self makeAccessoryButton: @"FolderRightArrow.png"];
            CGRect buttonFrame = myAccessoryButton.frame;
            buttonFrame.origin.y = 10;
            buttonFrame.origin.x = 5;
            buttonFrame.size = CGSizeMake(50, 32);
            myAccessoryButton.frame = buttonFrame;
            [cell.contentView addSubview:myAccessoryButton];
            
        }
    }
    else
    {
        for(UIButton* button in cell.contentView.subviews)
        {
            [button removeFromSuperview];
        }
        
        UIButton *myAccessoryButton =[[UIButton alloc] init];
        myAccessoryButton =[self makeAccessoryButton: @"15-tags.png"];
        CGRect buttonFrame = myAccessoryButton.frame;
        buttonFrame.origin.y = 10;
        buttonFrame.origin.x = 5;
        buttonFrame.size = CGSizeMake(24, 25);
        myAccessoryButton.frame = buttonFrame;
        [cell.contentView addSubview:myAccessoryButton];
    }
    
    return cell;
}

//Load the images from the selected tag.
- (void)loadTagsSelected {

    
    NSString *FolderName = [_currentDataHelper nameForIndex:globalIndex];
    NSString *FolderID = [_currentDataHelper idForIndex:globalIndex];
    
    if (currentState == FOLDERSTATE) {
        
        [_BackButton setTitle:@"Back"];
        
        
        Helper *tempHelper = _currentDataHelper;
        [_previousHelpers insertObject:tempHelper atIndex:_previousHelpers.count];
        _currentDataHelper = [[Helper alloc]init:FolderID :FolderName :currentState];
        [_currentDataHelper.currentDirectoryContentsNames insertObject:FolderName atIndex:0];
    }
    else {
        _currentDataHelper = [[Helper alloc]init:FolderID :FolderName :currentState];
    }
    [self.tableView reloadData];
    [_detailViewController setImageURL:_currentDataHelper.imageURL];
    [_detailViewController setImageIDURL:_currentDataHelper.imageIDURLS];
    [_detailViewController setReal:_currentDataHelper.realURLS];
    [_detailViewController update];
    [_detailViewController removeDetail];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    rowPressed = YES;
    globalIndex = indexPath;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"rowselection4.png"]];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

        //Return to grid view if on a close up.
        if([_detailViewController.navigationController.topViewController.title isEqualToString:@"Close Up"])
        {
            [_detailViewController.navigationController popViewControllerAnimated:YES];
        }
        else if([_detailViewController.navigationController.topViewController.title isEqualToString:@"Drawing Board"])
        {
            [_detailViewController.navigationController popViewControllerAnimated:NO];
            [_detailViewController.navigationController popViewControllerAnimated:YES];
        }
        
    });
    
    //Load Tags On Selection
    if([_detailViewController.navigationController.topViewController.title isEqualToString:@"Close Up"])
    {
        
        [MBProgressHUD showHUDAddedTo:_detailViewController.navigationController.topViewController.view animated:YES];
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadTagsSelected];
            
            [MBProgressHUD hideHUDForView:_detailViewController.navigationController.topViewController.view animated:YES];
        });
    }
    else if([_detailViewController.navigationController.topViewController.title isEqualToString:@"Drawing Board"]) {
        [MBProgressHUD showHUDAddedTo:self.detailViewController.view animated:YES];
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadTagsSelected];
            UIViewController *cont = (UIViewController *)self.detailViewController.imageDetailViewController;
            [MBProgressHUD hideHUDForView:cont.view animated:YES];
        });
        
    }
    else {
        [MBProgressHUD showHUDAddedTo:self.detailViewController.view animated:YES];
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self loadTagsSelected];
            
            [MBProgressHUD hideHUDForView:self.detailViewController.view animated:YES];
        });
    }

}

- (UIButton *) makeAccessoryButton: (NSString *) imageName
{
    
    UIButton *myAccessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0, 0, 24, 24);
    myAccessoryButton.frame = frame;
    [myAccessoryButton setBackgroundColor:[UIColor clearColor]];
    [myAccessoryButton setImage:[UIImage imageNamed:imageName] forState: UIControlStateNormal];
    [myAccessoryButton addTarget: self
                          action: @selector(accessoryButtonTapped:withEvent:)
                forControlEvents: UIControlEventTouchUpInside];
    //myAccessoryButton.userInteractionEnabled = YES;
    return ( myAccessoryButton );
    
}

#pragma mark - Download Data for Tag View
-(void)loadData{
    
}

- (IBAction)switchView:(id)sender {
    searching = NO;
    [searchResults removeAllObjects];
    [self.tableView reloadData];
    NSLog(@"HELLO");
    UIBarButtonItem *button = (UIBarButtonItem *)sender;
    switch (button.tag) {
        case FOLDERSTATE:
            if (currentState != FOLDERSTATE){
                currentState = FOLDERSTATE;
                _currentDataHelper = [[Helper alloc]init];
                [_currentDataHelper setCurrentState:currentState];
                self.title = @"Folders";
                [_currentDataHelper loadData];
                if (_previousHelpers.count > 0) {
                    button.title = @"Back";
                    [button setTitle:@"Back"];
                    
                }
                [self.tableView reloadData];
            }
            else {
                if (_previousHelpers.count > 0) {
                    int a = _previousHelpers.count;
                    a = a-1;
                    Helper *tempHelper = [_previousHelpers objectAtIndex:a];
                    _currentDataHelper = tempHelper;
                    [_previousHelpers removeObjectAtIndex:a];
                    if (_previousHelpers.count == 0) {
                        button.title = @"Folders";
                        [button setTitle:@"Folders"];
                        rowPressed = NO;
                    }
                    [self.tableView reloadData];
                }
            }
            break;
        case TAGSTATE:
            if (currentState != TAGSTATE) {
                currentState = TAGSTATE;
                self.title = @"Tags";
                Helper *tempHelper = _currentDataHelper;
                [_previousHelpers addObject:tempHelper];
                _currentDataHelper = [[Helper alloc]init];
                [_currentDataHelper setCurrentState:currentState];
                [_currentDataHelper loadData];
                
                [self.tableView reloadData];
            }
            break;
        default:
            break;
    }
}

@end
