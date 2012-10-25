//
//  Smooth_Line_ViewViewController.h
//  Smooth Line View
//
//  Created by Levi Nunnink on 8/10/11.
//  Copyright 2011 culturezoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmoothLineView.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MessageUI.h>


@interface Smooth_Line_ViewViewController : UIViewController<UISplitViewControllerDelegate>

{
    MFMailComposeViewController* controller;
}

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) SmoothLineView *drawView;
@property (nonatomic, retain) UIImage *imageToSend;
@property (strong, nonatomic) UIView *paperView;

- (IBAction)popThis:(id)sender;
- (IBAction)changeColor:(id)sender;

@end

