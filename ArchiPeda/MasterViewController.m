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
	
    rowPressed = NO;
    //Initially Begin With Tag View
    currentState = TAGSTATE;
    _currentDataHelper = [[Helper alloc]init];
    [_currentDataHelper setCurrentState:currentState];
    [_currentDataHelper loadData];
    _previousHelpers = [[NSMutableArray alloc]init ];
    
    //Refresh The View
    [self.tableView reloadData];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    
    //Gives Images to the Grid View
    [_detailViewController setImageURL:_currentDataHelper.imageURL];
    [_detailViewController setImageIDURL:_currentDataHelper.imageIDURLS];
    [_detailViewController setReal:_currentDataHelper.realURLS];
    [_detailViewController update];
    
    
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
{
    return [_currentDataHelper length];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = @"          ";
    cell.textLabel.text = [cell.textLabel.text stringByAppendingString:[_currentDataHelper nameForIndex:indexPath]];
    UIFont *textFont = [UIFont boldSystemFontOfSize:20];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    [cell.textLabel setFont:textFont];
    
    
    
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[_currentDataHelper tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    
    rowPressed = YES;
    NSString *FolderName = [_currentDataHelper nameForIndex:indexPath];
    NSString *FolderID = [_currentDataHelper idForIndex:indexPath];
    
    if (currentState == FOLDERSTATE) {
        
        [_BackButton setTitle:@"Back"];
        
        
        // _currentDataHelper.
        
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
