//
//  Smooth_Line_ViewViewController.m
//  Smooth Line View
//
//  Created by Levi Nunnink on 8/10/11.
//  Copyright 2011 culturezoo. All rights reserved.
//

#import "Smooth_Line_ViewViewController.h"
#import <QuartzCore/QuartzCore.h>
@implementation Smooth_Line_ViewViewController
@synthesize imageView = _imageView, drawView = _drawView, imageToSend = _imageToSend, paperView = _paperView;


//Merges two images into one UIImage.
- (UIImage * ) mergeImage: (UIImage *) imageA withImage:  (UIImage *) imageB
{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageB.size.width, imageB.size.height), YES, 0.0);
    
    //Origin point of top left corner of current image.
    //Note: There's an offset by a pixel or so.
    [imageA drawAtPoint: CGPointMake(33,290)];
    
    [imageB drawAtPoint: CGPointMake(0,0)
              blendMode: kCGBlendModeNormal // you can play with this
                  alpha: 1]; // 0 - 1
    
    UIImage *answer = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return answer;
    
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
    //_imageToSend = [self mergeImage:_drawView.drawingImage withImage:_imageView.image];
    
    UIGraphicsBeginImageContext(_drawView.bounds.size);
    [_drawView.layer renderInContext:UIGraphicsGetCurrentContext()];
    _imageToSend = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     _imageToSend = [self mergeImage:_imageView.image withImage:_imageToSend];
    
    NSData *data = UIImagePNGRepresentation(_imageToSend);
    
    
    
    controller = [[MFMailComposeViewController alloc]init];
    
    [controller addAttachmentData:data mimeType:@"image/png" fileName:@"annotatedImage.png"];
    
    controller.mailComposeDelegate = self;
    
    
    [controller setSubject:@"Check out my annotated image"];
    NSString *urlsmail = @"";
    
    //urlsmail = [_handleSubMaster.realURLS objectAtIndex:_currentNumber];
    
    [controller setMessageBody:urlsmail isHTML:NO];
    
    [self presentViewController:controller animated:YES completion:nil];
    
}



- (void)viewDidLoad
{

}

- (void)viewWillAppear:(BOOL)animated{
    _drawView = [[SmoothLineView alloc]initWithFrame:self.view.frame];
    [_drawView setBackgroundColor:[UIColor clearColor]];
    //_drawView.alpha = .5;
    _paperView = [ [UIView alloc]initWithFrame:self.view.frame];
    [_paperView setBackgroundColor:[UIColor whiteColor]];
    [_paperView setAlpha:.5];
    [self.view addSubview:_imageView];
    //[self.view addSubview:_drawView];
    [self.view setBackgroundColor:[UIColor blackColor]];
    NSLog(@"After");
    
    //Disable right swipe for table when drawing.
    self.splitViewController.presentsWithGesture = NO; 
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSArray *views = [self.view subviews];
    
    
    UIView *newView = [[UIView alloc]initWithFrame:self.view.frame];
    [newView addSubview:self.imageView];
    [newView addSubview:_paperView];
    [newView addSubview:self.drawView];
   
    for (UIView *view in views) {
        if (view != self.imageView && view != self.drawView && view != self.imageView) {
            [newView addSubview:view];
        }
    }
    
    [UIView transitionFromView:self.view
                        toView:newView
                      duration:2.0
                       options:UIViewAnimationOptionTransitionCurlDown
                    completion:^(BOOL finished) { [UIView animateWithDuration:0.5
                                                                   animations:^{}
                                                                   completion:^(BOOL finished){
                                                                       self.view = newView;
                                                                       NSLog(@"Animation done.");  }]; }
     ];
    
}


//- (IBAction)changeColor:(id)sender {
//    if (_drawView.lineColor == [UIColor blueColor]) {
//        _drawView.lineColor = [UIColor redColor];
//        [sender setTitle:@"Blue"];
//    }
//    else{
//        _drawView.lineColor = [UIColor blueColor];
//        [sender setTitle:@"Red"];
//    }
//}

- (IBAction)changeRedColor:(id)sender {
        _drawView.lineColor = [UIColor redColor];
}

- (IBAction)changeBlueColor:(id)sender {
        _drawView.lineColor = [UIColor blueColor];
    
}

- (IBAction)changeGreenColor:(id)sender {
        _drawView.lineColor = [UIColor greenColor];
    
}

- (IBAction)changeBlackColor:(id)sender {
        _drawView.lineColor = [UIColor blackColor];
    
}

@end


