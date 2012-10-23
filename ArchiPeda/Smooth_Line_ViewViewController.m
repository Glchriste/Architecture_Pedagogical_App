//
//  Smooth_Line_ViewViewController.m
//  Smooth Line View
//
//  Created by Levi Nunnink on 8/10/11.
//  Copyright 2011 culturezoo. All rights reserved.
//

#import "Smooth_Line_ViewViewController.h"

@implementation Smooth_Line_ViewViewController
@synthesize imageView = _imageView, drawView = _drawView;
- (void)viewDidLoad
{

}

- (void)viewWillAppear:(BOOL)animated{
    _drawView = [[SmoothLineView alloc]initWithFrame:self.view.bounds];
    [_drawView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_imageView];
    [self.view addSubview:_drawView];
    NSLog(@"After");
}
-(void)viewDidAppear:(BOOL)animated{
    //[self.view addSubview:_imageView];
}

@end


