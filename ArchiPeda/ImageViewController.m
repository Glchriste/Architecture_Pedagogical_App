//
//  ImageViewControllerViewController.m
//  AApp
//
//  Created by Jeffrey Delawder on 6/12/12.
//  Copyright (c) 2012 University of North Carolina at Charlotte. All rights reserved.
//

#import "ImageViewController.h"
#import "Smooth_Line_ViewViewController.h"
#import "MBProgressHUD.h"
#define SAVEDIMAGES @"SaveData"

@interface ImageViewController (){
    //Signals if the user has slid the image to the point where it should change
    bool changingImage;
    //The view that holds the image
    UIImageView *imageView;
    UIImageView *previousImageView;
    UIImageView *nextImageView;
    
    //A set of cahced images for switching quickly, the amount, and a dictionary
    NSMutableSet *cachedImages;
    int numOfCachedImages;
    NSMutableDictionary *cachedDictionary;
    
    CGPoint tapPoint;
    MFMailComposeViewController* controller;
    
    //A loading view
    UIActivityIndicatorView * loadingView;
    
    float width, height;

}
@end

@implementation ImageViewController

@synthesize imageSize = _imageSize, alert = _alert;
@synthesize imageScrollView = _imageScrollView;
@synthesize imageURL = _imageURL;
@synthesize handleSubMaster = _handleSubMaster;
@synthesize currentNumber = _currentNumber;
@synthesize paletteButton = _paletteButton;

#pragma mark - Managing the detail item

-(void)viewWillAppear:(BOOL)animated {
    
}


-(void)prepareSideImages{
    int previousImageTag;
    int nextImageTag;
    if (_currentNumber == _handleSubMaster.imageStrings.count -2) {
        nextImageTag = 0;
    }
    else {
        nextImageTag = _currentNumber + 1;
    }
    if (_currentNumber == 0) {
        previousImageTag = _handleSubMaster.imageStrings.count -2;
    }
    else {
        previousImageTag = _currentNumber - 1;
    }
    NSURL *previousImageURL = [_handleSubMaster.realURLS objectAtIndex:previousImageTag];
    NSURL *nextImageURL = [_handleSubMaster.realURLS objectAtIndex:nextImageTag];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //If it's cached then load from file for left image
        if ([cachedDictionary objectForKey:previousImageURL] != nil) {
            
            //Keep Original and Resize a Copy
            UIImage *theImage = [cachedDictionary objectForKey:previousImageURL];
            
            previousImageView = [self resize:theImage];
            [previousImageView setTag:previousImageTag];
            //[previousImageView sizeToFit];
        }
        else {
            
            //Have to download the image then call fixScroll
            previousImageView = [[UIImageView alloc]init];
            [previousImageView setTag:previousImageTag];
            void (^store)(UIImage *, BOOL);
            ImageViewController *handle = self;
            store = ^(UIImage *image, BOOL y) {
                [handle store:image inView: 0 forURL:previousImageURL];
            };
            [previousImageView setImageWithURL:previousImageURL placeholderImage:nil
                                       success:store
                                       failure:^(NSError *error) {
                                           NSLog(@"FAiled Prev");
                                       }];
        }
        //If it's cached then load from file for right Image
        if ([cachedDictionary objectForKey:nextImageURL] != nil) {
            
            //Keep Original and Resize a Copy
            UIImage *theImage = [cachedDictionary objectForKey:nextImageURL];
            
            
            nextImageView = [self resize:theImage];
            [nextImageView setTag:nextImageTag];
            //[nextImageView sizeToFit];
        }
        else {
            
            //Have to download the image then call fixScroll
            nextImageView = [[UIImageView alloc]init];
            [nextImageView setTag:nextImageTag];
            void (^store)(UIImage *, BOOL);
            ImageViewController *handle = self;
            store = ^(UIImage *image, BOOL y) {
                [handle store:image inView:1 forURL:nextImageURL];
            };
            [nextImageView setImageWithURL:nextImageURL placeholderImage:nil
                                   success:store
                                   failure:^(NSError *error) {
                                       NSLog(@"FAiled NExt");
                                   }];
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{

        });
    });
    
}//End of prepare side images

-(void)store: (UIImage *)image inView:(int)view forURL:(NSURL *)url{
    //First instance of being resized 
    UIImageView *theView = [self resize:image];
    
    if (view == 0) {
        int tag = previousImageView.tag;
        previousImageView = theView;
        [previousImageView setTag:tag];
    }
    else {
        int tag = nextImageView.tag;
        nextImageView = theView;
        [nextImageView setTag:tag];
    }
    
    @try {
        [cachedDictionary setObject:image forKey:url];
        NSLog(@"Cached Image");
    }
    @catch (NSException *exception) {
        NSLog(@"Could not cache image");
    }
    @finally {
        
    }
}


- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL != imageURL)
    {
        _imageURL = imageURL;
    }
}

- (void)configureView
{
    [self prepareSideImages];
    if (self.imageURL)
    {

        [self startLoaderAnimation];
        [self setTitle:@"Close Up"];
        [_imageScrollView setAlpha:0];
        for (UIView* view in [imageView subviews]) {
            [view removeFromSuperview];
        }
        if (imageView != nil) {
            [imageView removeFromSuperview];
        }
        
        //If it's cached then load from file
        if ([cachedDictionary objectForKey:self.imageURL] != nil) {
            
            //Keep Original and Resize a Copy
            UIImage *theImage = [cachedDictionary objectForKey:self.imageURL];
            
            imageView = [self resize:theImage];
            _imageScrollView.contentSize = theImage.size;
            [loadingView removeFromSuperview];
            [_imageScrollView addSubview:imageView];
            NSTimeInterval time = .5;
            [UIView animateWithDuration:time animations:^{
                [_imageScrollView setAlpha:1.0];
            }];
        }
        else {
            
            //Have to download the image then call fixScroll
            imageView = [[UIImageView alloc]init];
            [_imageScrollView addSubview:imageView];
            UIImage *tempImage = [UIImage imageNamed:@"TagAlbumIcon.png"];
            void (^fix)(UIImage *, BOOL);
            ImageViewController *handle = self;
            fix = ^(UIImage *image, BOOL y) {
                [handle fixScroll];
            };
            [imageView setImageWithURL:[NSURL URLWithString:_imageURL] placeholderImage:tempImage
                               success:fix
                               failure:^(NSError *error) {
                                   
                               }];
        }
    }
}

-(void)fixScroll{
    UIImage *image = imageView.image;
    for (UIView* view in [imageView subviews]) {
        [view removeFromSuperview];
    }
    imageView = [self resize:image];
    [_imageScrollView addSubview:imageView];
    width = imageView.frame.size.width;
    height = imageView.frame.size.height;
    //CGAffineTransform rotate = CGAffineTransformMakeRotation( -90);
    //[_imageScrollView setTransform:rotate];
    
    @try {
        [cachedDictionary setObject:image forKey:self.imageURL];
    }
    @catch (NSException *exception) {
        NSLog(@"Could not cache image");
    }
    @finally {
        
    }
    [_imageScrollView setContentSize:imageView.image.size];
    [_imageScrollView setCenter:self.view.center];
    
    if (imageView.image.size.height > imageView.image.size.width) {
        NSLog(@"Should be vertical");
    }
    
    [imageView setCenter:self.view.center];
    NSTimeInterval time = .5;
    [UIView animateWithDuration:time animations:^{
        [_imageScrollView setAlpha:1.0];
    }];
    [loadingView removeFromSuperview];
}

-(UIImageView *)resize: (UIImage*)image{
    UIImageView *returnView;
    _imageSize = image.size;
    float originalWidth = image.size.width;
    float originalHeight = image.size.height;
    NSLog(@"%f, %f", originalHeight, originalWidth);
    float wScale = originalWidth/703;
    float hScale = originalHeight/660;
    
    if (originalWidth > 703 || originalHeight > 660) {
        if (hScale > wScale) {
            image = [UIImage imageWithCGImage:image.CGImage scale:hScale orientation:image.imageOrientation];
            returnView = [[UIImageView alloc]initWithImage:image];
            //CGAffineTransform rotate = CGAffineTransformMakeRotation(90);
            //[returnView setTransform:rotate];
            NSLog(@"Should Rotate");
            
        }
        else {
            image = [UIImage imageWithCGImage:image.CGImage scale:wScale orientation:image.imageOrientation];
            returnView = [[UIImageView alloc]initWithImage:image];
        }
    }
    else
        returnView = [[UIImageView alloc]initWithImage:image];
    return returnView;
}

#pragma mark Mail
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
     //Todo: Implement error handling for if it doesn't or can't send...
    [self dismissViewControllerAnimated:controller completion:nil];
}

-(IBAction)sendEmail {
    controller = [[MFMailComposeViewController alloc]init];
    controller.mailComposeDelegate = self;
    
    
    [controller setSubject:@"Check out these images"];
    NSString *urlsmail = @"";
    
    urlsmail = [_handleSubMaster.realURLS objectAtIndex:_currentNumber];
    
    [controller setMessageBody:urlsmail isHTML:NO];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}
#pragma mark viewDidLoad

-(void)progress {
    
        float progress = 0.0;
        while (progress < 100.0) {
            progress += 0.01;
            HUD.progress = progress;
        }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageScrollView.minimumZoomScale=1;
    _imageScrollView.maximumZoomScale=10.0;
    [_imageScrollView setDelegate:self];
    changingImage = false;
    
    //Progress Wheel
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    //HUD.mode = MBProgressHUDModeAnnularDeterminate;
    [self.view addSubview:HUD];

//    [MBProgressHUD showHUDAddedTo:[self.view.subviews objectAtIndex:0] animated:YES];
//    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//        // Do something...
//        [self progress];
////        [HUD showWhileExecuting:@selector(progress) onTarget:self withObject:nil animated:YES];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MBProgressHUD hideHUDForView:self.view animated:YES];
//        });
//    });

    
    cachedImages = [[NSMutableSet alloc]initWithCapacity:10];
    cachedDictionary = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self configureView];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

 

    self.view.backgroundColor = [UIColor blackColor];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(drag:)];
    [self.view addGestureRecognizer:pan];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoom:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
}

#pragma mark User Interactions

//Calls the trace paper animation and transitions to the drawing view controller.
-(IBAction)palettePressed:(id)sender {
    
    [self performSegueWithIdentifier:@"drawingViewSegue" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    Smooth_Line_ViewViewController *contr = [segue destinationViewController];
    UIImageView *view = [[_imageScrollView subviews]objectAtIndex:0];
    UIImageView *copy = [[UIImageView alloc]initWithFrame:view.frame];
    [copy setImage:view.image];
    [copy setFrame: CGRectMake(0, 0, width, height)];
    [copy setCenter:self.view.center];
    NSLog(@"%f, %f", width, height);
    
    [contr setImageView:copy];
}

-(void)zoom: (UITapGestureRecognizer *)tap{
    [self.imageScrollView setZoomScale:_imageScrollView.minimumZoomScale];
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}

-(void)drag: (UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"Trying to drag");
        [previousImageView setBackgroundColor:[UIColor whiteColor]];
        [nextImageView setBackgroundColor:[UIColor whiteColor]];
        
        //[_imageScrollView removeFromSuperview];
        [previousImageView setCenter:CGPointMake(imageView.center.x - imageView.bounds.size.width/2 - previousImageView.bounds.size.width/2, imageView.center.y)];
        
        [nextImageView setCenter:CGPointMake(imageView.center.x + imageView.bounds.size.width/2 + nextImageView.bounds.size.width/2, imageView.center.y)];
        
        
        [self.view addSubview:previousImageView];
        [self.view addSubview:nextImageView];
        tapPoint = [recognizer locationInView:self.view];
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ) {
        bool changing = NO;
        if (imageView.center.x - self.view.center.x > 300) {
            changing = YES;
            //Animate
            NSTimeInterval delay = 1;
            
            [UIView animateWithDuration:delay animations:^{
                previousImageView.center = self.view.center;
                imageView.center = nextImageView.center;
            }completion:^(BOOL v){
                _currentNumber = previousImageView.tag;
                
                [imageView removeFromSuperview];
                [previousImageView removeFromSuperview];
                [nextImageView removeFromSuperview];
                
                imageView = [[UIImageView alloc]initWithImage:previousImageView.image];
                [imageView setCenter:self.view.center];
                [imageView setTag:previousImageView.tag];
                
                [_imageScrollView addSubview:imageView];
                [_imageScrollView setContentSize:imageView.image.size];
                
                previousImageView = nil;
                nextImageView = nil;
                
                [self prepareSideImages];
            }];
        }
        else if(imageView.center.x - self.view.center.y < -300){
            changing = YES;
            //Animate
            NSTimeInterval delay = 1;
            [UIView animateWithDuration:delay animations:^{
                nextImageView.center = self.view.center;
                imageView.center = previousImageView.center;
            }completion:^(BOOL v){
                _currentNumber = nextImageView.tag;
                
                [imageView removeFromSuperview];
                [previousImageView removeFromSuperview];
                [nextImageView removeFromSuperview];
                
                imageView = [[UIImageView alloc]initWithImage:nextImageView.image];
                [imageView setCenter:self.view.center];
                [imageView setTag:nextImageView.tag];
                
                [_imageScrollView addSubview:imageView];
                [_imageScrollView setContentSize:imageView.image.size];
                
                previousImageView = nil;
                nextImageView = nil;
                
                [self prepareSideImages];
            }];
        }
        if (!changing) {
            //NSLog(@"Not Changing");
            [imageView setCenter:self.view.center];
            [previousImageView removeFromSuperview];
            [nextImageView removeFromSuperview];
        }
        
        
        
    }
    else {
        CGPoint newPoint = [recognizer locationInView:self.view];
        int xChange = newPoint.x - tapPoint.x;
        [imageView setCenter:CGPointMake(imageView.center.x + xChange, imageView.center.y)];
        
        [previousImageView setCenter:CGPointMake(imageView.center.x - imageView.bounds.size.width/2 - previousImageView.bounds.size.width/2, imageView.center.y)];
        
        [nextImageView setCenter:CGPointMake(imageView.center.x + imageView.bounds.size.width/2 + nextImageView.bounds.size.width/2, imageView.center.y)];
        
        tapPoint = newPoint;
    }
    
}

- (void)viewDidUnload
{
    [self setImageScrollView:nil];
    [self setPaletteButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (_imageSize.width > _imageSize.height && (interfaceOrientation == UIInterfaceOrientationPortrait ||UIInterfaceOrientationPortraitUpsideDown == interfaceOrientation)) {
        return YES;
    }
    else if (_imageSize.width < _imageSize.height && (interfaceOrientation == UIInterfaceOrientationLandscapeLeft || UIInterfaceOrientationLandscapeRight == interfaceOrientation)){
        return YES;
    }
    return YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (changingImage) {
        changingImage = false;
        [self configureView];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
}

#pragma mark SDWebImageDownloaderDelegate Methods
- (void)imageDownloaderDidFinish:(SDWebImageDownloader *)downloader{
    
}




/**
 * Called repeatedly while the image is downloading when [SDWebImageDownloader progressive] is enabled.
 *
 * @param downloader The SDWebImageDownloader instance
 * @param image The partial image representing the currently download portion of the image
 */
- (void)imageDownloader:(SDWebImageDownloader *)downloader didUpdatePartialImage:(UIImage *)image{

}

/**
 * Called when download completed successfuly.
 *
 * @param downloader The SDWebImageDownloader instance
 * @param image The downloaded image object
 */
- (void)imageDownloader:(SDWebImageDownloader *)downloader didFinishWithImage:(UIImage *)image{
    
}

/**
 * Called when an error occurred
 *
 * @param downloader The SDWebImageDownloader instance
 * @param error The error details
 */
- (void)imageDownloader:(SDWebImageDownloader *)downloader didFailWithError:(NSError *)error{
    
    
}



-(BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation{
    if (UIDeviceOrientationIsLandscape(orientation)) {
        return YES;
    }
    return NO;
}
-(void)startLoaderAnimation{
    //This Section Customizes the Appearance of the Initial Loading Screen
    loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingView setFrame:CGRectMake(0, 0, 200, 200)];
    [loadingView setCenter:[_imageScrollView center]];
    [loadingView setColor: [UIColor grayColor]];
    [loadingView startAnimating];
    [self.view addSubview:loadingView];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [imageView setCenter:self.view.center];
}

@end