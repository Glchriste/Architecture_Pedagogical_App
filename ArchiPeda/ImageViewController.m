//
//  ImageViewControllerViewController.m
//  AApp
//
//  Created by Jeffrey Delawder on 6/12/12.
//  Copyright (c) 2012 University of North Carolina at Charlotte. All rights reserved.
//

#import "ImageViewController.h"

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
    
    //DrawingViewController *drawController;
}
@end

@implementation ImageViewController

@synthesize imageSize = _imageSize, alert = _alert;
@synthesize imageScrollView = _imageScrollView;
@synthesize imageURL = _imageURL;
@synthesize handleSubMaster = _handleSubMaster;
@synthesize currentNumber = _currentNumber;
@synthesize paletteButton = _paletteButton;
//@synthesize drawingView = _drawingView;

#pragma mark - Managing the detail item

//Calls the trace paper animation and transitions to the drawing view controller.
-(IBAction)palettePressed:(id)sender {
    //_drawingView = [[DrawingViewController alloc] init];
    
    //[self prepareForSegue:@"drawingViewSegue" sender:sender];
    [self performSegueWithIdentifier:@"drawingViewSegue" sender:sender];
    
    
    //The Trace Paper Animation and the Segue Trigger
    //    [UIView transitionFromView:self.view
    //                        toView:nil
    //                      duration:2.0
    //                       options:UIViewAnimationOptionTransitionCurlDown
    //                    completion:^(BOOL finished) { [UIView animateWithDuration:0.5
    //                                                                   animations:^{self.view.alpha = 0.5;}
    //                                                                   completion:^(BOOL finished){ [self performSegueWithIdentifier:@"drawingViewSegue" sender:sender]; NSLog(@"Animation done.");  }]; }
    //                    ];
}
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    UIViewController *dest = [segue destinationViewController];
//    DrawingViewController *destDraw = (DrawingViewController *)dest;
//    UIImageView *newView = [[UIImageView alloc]initWithImage:imageView.image];
//    [newView setCenter:imageView.center];
//    [destDraw setImageLayer:newView];
//    
//    
//    //[destDraw setImageLayer:imageView];
//}

-(void)prepareSideImages{
    NSLog(@"%s, %i", __PRETTY_FUNCTION__, _currentNumber);
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
        //If it's cached then load from file
        if ([cachedDictionary objectForKey:previousImageURL] != nil) {
            
            //Keep Original and Resize a Copy
            UIImage *theImage = [cachedDictionary objectForKey:previousImageURL];
            UIImage *sizedImage = [self resize:theImage];
            
            previousImageView = [[UIImageView alloc]initWithImage:sizedImage];
            [previousImageView setTag:previousImageTag];
            [previousImageView sizeToFit];
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
        //If it's cached then load from file
        if ([cachedDictionary objectForKey:nextImageURL] != nil) {
            
            //Keep Original and Resize a Copy
            UIImage *theImage = [cachedDictionary objectForKey:nextImageURL];
            UIImage *sizedImage = [self resize:theImage];
            
            nextImageView = [[UIImageView alloc]initWithImage:sizedImage];
            [nextImageView setTag:nextImageTag];
            [nextImageView sizeToFit];
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
            NSLog(@"Finished Loading");
        });
    });
    
}

-(void)store: (UIImage *)image inView:(int)view forURL:(NSURL *)url{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    UIImage *sizedImage = [self resize:image];
    UIImageView *theView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, sizedImage.size.width, sizedImage.size.height)];
    [theView setImage:sizedImage];
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
    }
    @catch (NSException *exception) {
        NSLog(@"Could not cache image");
    }
    @finally {
        
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imageView;
}
- (void)setImageURL:(NSString *)imageURL
{
    if (_imageURL != imageURL)
    {
        _imageURL = imageURL;
        // [self configureView];
    }
}


- (void)configureView
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [self prepareSideImages];
    if (self.imageURL)
    {
        //        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(LongPress:)];
        //  [self.view addGestureRecognizer:longPress];
        
        
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
            UIImage *sizedImage = [self resize:theImage];
            
            imageView = [[UIImageView alloc]initWithImage:sizedImage];
            [imageView sizeToFit];
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
    UIImage *sizedImage = [self resize:image];
    for (UIView* view in [imageView subviews]) {
        [view removeFromSuperview];
    }
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, sizedImage.size.width, sizedImage.size.height)];
    [imageView setImage:sizedImage];
    [_imageScrollView addSubview:imageView];
    
    @try {
        [cachedDictionary setObject:image forKey:self.imageURL];
    }
    @catch (NSException *exception) {
        NSLog(@"Could not cache image");
    }
    @finally {
        
    }
    [_imageScrollView setContentSize:sizedImage.size];
    
    [imageView setCenter:self.view.center];
    NSTimeInterval time = .5;
    [UIView animateWithDuration:time animations:^{
        [_imageScrollView setAlpha:1.0];
    }];
    [loadingView removeFromSuperview];
}

-(IBAction)sendEmail {
    controller = [[MFMailComposeViewController alloc]init];
    controller.mailComposeDelegate = self;
    
    
    [controller setSubject:@"Check out these images"];
    NSString *urlsmail = @"";
    
    urlsmail = [_handleSubMaster.realURLS objectAtIndex:_currentNumber];
    
    [controller setMessageBody:urlsmail isHTML:NO];
    
    
   // [self presentModalViewController:controller animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"It's away!");
    }
   // [self dismissModalViewControllerAnimated:YES];
}


-(UIImage *)resize: (UIImage*)image{
    _imageSize = image.size;
    float originalWidth = image.size.width;
    float originalHeight = image.size.height;
    
    float wScale = originalWidth/703;
    float hScale = originalHeight/660;
    
    if (originalWidth > 703 || originalHeight > 660) {
        if (hScale > wScale) {
            image = [UIImage imageWithCGImage:image.CGImage scale:hScale orientation:image.imageOrientation];
        }
        else {
            image = [UIImage imageWithCGImage:image.CGImage scale:wScale orientation:image.imageOrientation];
        }
    }
    return image;
}



-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    //Test for orientation changes.
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    cachedImages = [[NSMutableSet alloc]initWithCapacity:10];
    cachedDictionary = [[NSMutableDictionary alloc]initWithCapacity:10];
    
    [self configureView];
    _imageScrollView.minimumZoomScale=1;
    _imageScrollView.maximumZoomScale=10.0;
    [_imageScrollView setDelegate:self];
    changingImage = false;
    self.view.backgroundColor = [UIColor blackColor];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(drag:)];
    
    [self.view addGestureRecognizer:pan];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoom:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.view addGestureRecognizer:doubleTap];
}
-(void)zoom: (UITapGestureRecognizer *)tap{
    [self.imageScrollView setZoomScale:_imageScrollView.minimumZoomScale];
}
-(void)drag: (UIPanGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Trying to drag");
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
            NSLog(@"Not Changing");
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



////Prepare for segue to drawing board / view.
//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    DrawingViewController *drawVC = [segue destinationViewController];
//    drawVC.imageView = imageView;
//    _drawingView = drawVC;
//
//    SharedSingleton *shared = [SharedSingleton sharedSingleton];
//    [shared setCurrentImageView:imageView];
//
//
//}


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

//-(void)LongPress:(UIGestureRecognizer *)recognizer{
//    NSLog(@"Pressed");
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc]init];
//        controller.mailComposeDelegate = self;
//        [controller setSubject:@"Check out these images"];
//        [controller setMessageBody:_imageURL isHTML:NO];
//        [self presentModalViewController:controller animated:YES];
//    }
//}

//- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
//{
//    if (result == MFMailComposeResultSent) {
//        NSLog(@"It's away!");
//    }
//    [self dismissModalViewControllerAnimated:YES];
//}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [imageView setCenter:self.view.center];
}

@end