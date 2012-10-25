//
//  DetailViewController.m
//  AApp
//
//  Created by Jeffrey Delawder on 6/5/12.
//  Copyright (c) 2012 University of North Carolina at Charlotte. All rights reserved.
//

//
// GOAL: CLEAN UP THIS CODE
// GOAL: Implement Gallery vs. "Slideshow"
// SDWebImage Handle Thumbnail Cacheing
//

#import "DetailViewController.h"
#import "ImageViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>


@interface DetailViewController (){
    UIView *selectedView;
    MFMailComposeViewController* controller;
    int currentSelectionState;
}
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) ImageViewController *IVC;

- (void)configureView;
@end

@implementation DetailViewController


enum GridStates{
    SELECT_ONE_IMAGE,
    SELECT_MULTIPLE_IMAGES
};


@synthesize masterPopoverController = _masterPopoverController, imageDetailViewController = _imageDetailViewController;
@synthesize imageStrings = _imageStrings, imageURL = _imageURL,imageIDURL = _imageIDURL, imageIDs = _imageIDs, realURLS = _realURLS, real = _real, IVC = _IVC, selectedImages = _selectedImages, selectMultipleButton;

- (void)configureView
{
    // Update the user interface for the detail item.
    [self.tableView setDelegate:self];
    if (self) {
        //Set the title.
        [self setTitle:@"Photos"];
        //Set the selection mode.
        currentSelectionState = SELECT_ONE_IMAGE;
        //Initialize the selection array.
        _selectedImages = [[NSMutableArray alloc]init];
        //Initialize the "long press" gesture.
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPress:)];
        [self.view addGestureRecognizer:longPress];
        //Load the table.
        [self.tableView reloadData];
    }
}


//Sends an email containing URLs of the selected images with the subject: "Check out these images."
-(IBAction)sendEmail {
    controller = [[MFMailComposeViewController alloc]init];
    controller.mailComposeDelegate = self;
    
    
    [controller setSubject:@"Check out these images."];
    NSString *urlsmail = @"";
    
    for (NSNumber *num in _selectedImages) {
        int number = num.intValue;
        NSString *imageName = [_realURLS objectAtIndex:number];
        urlsmail = [[urlsmail stringByAppendingString:imageName]stringByAppendingString:@"\n"];
    }
    
    [controller setMessageBody:urlsmail isHTML:NO];
    [_selectedImages removeAllObjects];
    [self.tableView reloadData];
    
    [self presentViewController:controller animated:YES completion:nil];
}


//The old long press gesture for sending email that currently isn't being used.

//-(void)LongPress:(UIGestureRecognizer *)recognizer{
//    NSLog(@"Pressed");
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        controller = [[MFMailComposeViewController alloc]init];
//
//
//        controller.mailComposeDelegate = self;
//
//
//        [controller setSubject:@"Check out these images"];
//        NSString *urlsmail = @"";
//
//        for (NSNumber *num in _selectedImages) {
//            int number = num.intValue;
//            NSString *imageName = [_realURLS objectAtIndex:number];
//            urlsmail = [[urlsmail stringByAppendingString:imageName]stringByAppendingString:@"\n"];
//        }
//
//        [controller setMessageBody:urlsmail isHTML:NO];
//        [_selectedImages removeAllObjects];
//        [self.tableView reloadData];
//
//
//        [self presentModalViewController:controller animated:YES];
//
//    }



//}


#pragma mark - Compose Mail Controller

//The "compose mail" controller. Used for sending mail.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    //If the message sent, log "It's away!"
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
    //Todo: Implement error handling for if it doesn't or can't send...
    
   [self dismissViewControllerAnimated:controller completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    //Set the selection array to nil.
    _selectedImages = nil;
    [self setSelectMultipleButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
-(void) viewWillDisappear:(BOOL)animated{
    //Clear the selection array.
    [_selectedImages removeAllObjects];
}

//Should the view rotate? Yes.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    //Set the title.
    barButtonItem.title = NSLocalizedString(@"Tags", @"Tags");
    //Set the left bar button item.
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    //Set the master popover controller.
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //How many sections in the table view? 1.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    //Number of rows for thumbnails.
    
    //The current iPad orientation.
    //Sets the row numbers based on the current iPad orientation.
    if (_imageStrings.count > 0) {
        //It displays better this way in a split view.
        return (_imageStrings.count)/3+1;
    }
    return _imageStrings.count;
}

//Loading the images into thumbnail "image views."
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithFrame:CGRectMake(0, 22 + indexPath.row * 200, 703, 200)];
    
    if (indexPath.row * 3 + 0 < _imageStrings.count) {
        
        NSString *tempString = [_realURLS objectAtIndex:indexPath.row*3];
        NSString *imageName = [_imageStrings objectAtIndex:indexPath.row*3];
        NSString *replacement = [@"SMALL." stringByAppendingString:imageName];
        tempString = [tempString stringByReplacingOccurrencesOfString:imageName withString:replacement];
        NSURL *tempURL = [NSURL URLWithString:tempString];
        UIImageView *thumbView;
        int x0;
        //Create the thumbnail view.
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            
            x0 = 80+0*196;
            thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(x0, 5, 192, 192)];
        }
        else {
            x0 = 10+0*102;
            thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(x0, 5, 106, 106)];
        }
        //Center / create the thumbnail based on the current orientation.
        
        
        //Set up the one finger tap gesture.
        UITapGestureRecognizer *oneFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
        
        [oneFingerTap setNumberOfTapsRequired:1];
        [oneFingerTap setNumberOfTouchesRequired:1];
        
        // Add the "one finger tap" gesture to the view.
        [thumbView addGestureRecognizer:oneFingerTap];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView setTag:indexPath.row*3];
        
        [thumbView setImageWithURL:tempURL];
        //[thumbView setImageWithURL:tempURL placeholderImage:[UIImage imageNamed:@"placeholder.jpeg"]];
        
        //Set the border color and width of the thumbnails.
        [thumbView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [thumbView.layer setBorderWidth: 1.0];
        
        //If an image is selected, make the border color to be red and the width 3x greater.
        for (NSNumber *num in _selectedImages) {
            if (num.intValue == indexPath.row*3+0) {
                [thumbView.layer setBorderColor: [[UIColor redColor] CGColor]];
                [thumbView.layer setBorderWidth: 3.0];
                
            }
        }
        
        
        //Add the thumbnail view to the cell.
        [cell addSubview:thumbView];
    }
    if (indexPath.row * 3 + 1 < _imageStrings.count) {
        NSString *tempString = [_realURLS objectAtIndex:indexPath.row * 3 + 1];
        NSString *imageName = [_imageStrings objectAtIndex:indexPath.row * 3 + 1];
        NSString *replacement = [@"SMALL." stringByAppendingString:imageName];
        tempString = [tempString stringByReplacingOccurrencesOfString:imageName withString:replacement];
        NSURL *tempURL = [NSURL URLWithString:tempString];
        UIImageView *thumbView;
        int x0;
        //Create the thumbnail view.
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            
            x0 = 80+1*196;
            thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(x0, 5, 192, 192)];
        }
        else {
            x0 = 10+1*102;
            thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(x0, 5, 106, 106)];
        }
        //Center / create the thumbnail based on the current orientation.
        
        UITapGestureRecognizer *oneFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
        
        [oneFingerTap setNumberOfTapsRequired:1];
        [oneFingerTap setNumberOfTouchesRequired:1];
        
        // Add the gesture to the view
        [thumbView addGestureRecognizer:oneFingerTap];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView setTag:indexPath.row * 3 + 1];
        
        [thumbView setImageWithURL:tempURL placeholderImage:[UIImage imageNamed:@"placeholder.jpeg"]];
        
        [thumbView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [thumbView.layer setBorderWidth: 1.0];
        
        for (NSNumber *num in _selectedImages) {
            if (num.intValue == indexPath.row*3+1) {
                [thumbView.layer setBorderColor: [[UIColor redColor] CGColor]];
                [thumbView.layer setBorderWidth: 3.0];
                
            }
        }
        
        //Add the thumbnail view to the cell.
        [cell addSubview:thumbView];
    }
    if (indexPath.row * 3 + 2 < _imageStrings.count) {
        NSString *tempString = [_realURLS objectAtIndex:indexPath.row * 3 + 2 ];
        NSString *imageName = [_imageStrings objectAtIndex:indexPath.row * 3 + 2 ];
        NSString *replacement = [@"SMALL." stringByAppendingString:imageName];
        tempString = [tempString stringByReplacingOccurrencesOfString:imageName withString:replacement];
        NSURL *tempURL = [NSURL URLWithString:tempString];
        UIImageView *thumbView;
        int x0;
        //Create the thumbnail view.
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            
            x0 = 80+2*196;
            thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(x0, 5, 192, 192)];
        }
        else {
            x0 = 10+2*102;
            thumbView = [[UIImageView alloc] initWithFrame:CGRectMake(x0, 5, 106, 106)];
        }
        //Center / create the thumbnail based on the current orientation.
        
        UITapGestureRecognizer *oneFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerTap:)];
        
        [oneFingerTap setNumberOfTapsRequired:1];
        [oneFingerTap setNumberOfTouchesRequired:1];
        
        // Add the gesture to the view
        [thumbView addGestureRecognizer:oneFingerTap];
        [thumbView setUserInteractionEnabled:YES];
        [thumbView setTag:indexPath.row * 3 + 2 ];
        [thumbView setImageWithURL:tempURL placeholderImage:[UIImage imageNamed:@"placeholder.jpeg"]];
        
        [thumbView.layer setBorderColor: [[UIColor whiteColor] CGColor]];
        [thumbView.layer setBorderWidth: 1.0];
        
        for (NSNumber *num in _selectedImages) {
            if (num.intValue == indexPath.row*3+2) {
                [thumbView.layer setBorderColor: [[UIColor redColor] CGColor]];
                [thumbView.layer setBorderWidth: 3.0];
                
            }
        }
        
        //Add the thumbnail view to the cell.
        [cell addSubview:thumbView];
    }
    
    [cell setUserInteractionEnabled:YES];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

//Set up the gesture recognizer for a one finger tap.
-(void)oneFingerTap:(UIGestureRecognizer *)recognizer{
    selectedView = [recognizer view];
    switch (currentSelectionState) {
        case SELECT_ONE_IMAGE:
            
            [self performSegueWithIdentifier:@"ImageSegue" sender:self];
            break;
            
        case SELECT_MULTIPLE_IMAGES:{
            
            
            
            NSNumber *num = [NSNumber numberWithInt:selectedView.tag];
            bool found = false;
            for (NSNumber *thenum in _selectedImages) {
                if (thenum.intValue == selectedView.tag) {
                    [_selectedImages removeObject:thenum];
                    found = true;
                }
            }
            if (!found) {
                [_selectedImages addObject:num];
            }
            
            
            
            [self.tableView reloadData];
            
            
            
            break;
        }
        default:
            break;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    ImageViewController *imageController = [segue destinationViewController];
    imageController.imageURL = [_realURLS objectAtIndex:selectedView.tag];
    imageController.handleSubMaster = self;
    imageController.currentNumber = selectedView.tag;
    _imageDetailViewController = imageController;
    NSLog(@"%@", imageController.imageURL);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)removeDetail{
    //[_imageDetailViewController.navigationController popViewControllerAnimated:YES];
}

- (IBAction)selectMultiple:(id)sender {
    if(currentSelectionState != SELECT_MULTIPLE_IMAGES)
    {
        //If set to UIBarBUttonItemStyleDone, makes the "select multiple" button highlight when selected.
        //selectMultipleButton.style = UIBarButtonItemStyleDone;
        selectMultipleButton.style = UIBarButtonItemStyleBordered;
        currentSelectionState = SELECT_MULTIPLE_IMAGES;
    }
    else
    {
        selectMultipleButton.style = UIBarButtonItemStyleBordered;
        currentSelectionState = SELECT_ONE_IMAGE;
        [_selectedImages removeAllObjects];
        [self.tableView reloadData];
    }
    
    
    
    
}

- (IBAction)selectSingle:(id)sender {
    
    [_selectedImages removeAllObjects];
    [self.tableView reloadData];
    selectMultipleButton.style = UIBarButtonItemStyleBordered;
    currentSelectionState = SELECT_ONE_IMAGE;
}



-(void)update{
    NSData *data = [NSData dataWithContentsOfURL:_imageURL];
    NSString *url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    _imageStrings = [url componentsSeparatedByString:@","];
    
    data = [NSData dataWithContentsOfURL:_imageIDURL];
    url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    _imageIDs = [url componentsSeparatedByString:@","];
    
    data = [NSData dataWithContentsOfURL:_real];
    url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    _realURLS = [url componentsSeparatedByString:@","];
    
    [self.tableView reloadData];
}

@end
