//
//  TagHelper.h
//  ArchiPeda
//
//  Created by Jeffrey Delawder Jr on 10/14/12.
//  Copyright (c) 2012 Jeffrey Delawder Jr. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Helper : NSObject

//PROPERTIES

//This will hold the ids of the current state
@property (strong, nonatomic) NSMutableArray *currentStateIDS;

//This will hold the url to retrieve all the image IDs related to the current state of the helper
@property (strong, nonatomic) NSURL *imageIDURLS;

//This will hold any strings related to the current state of the helper
@property (strong, nonatomic) NSMutableArray *currentDirectoryContentsNames;

//Holds name of current state
@property (strong, nonatomic) NSString* name;

//Determines whether to find folders or tags
@property int currentState;

@property (strong, nonatomic) NSURL *imageURL;
@property (strong, nonatomic) NSURL *realURLS;


//METHODS


//To load the helper to base state
-(void)loadData;

//To load the folder to a specific state
-(id)init:(NSString *)StateID :(NSString *)Name: (int)CurrentState;

//Returns a String for a specific index number
-(NSString *)nameForIndex:(NSIndexPath *)indexPath;

//Returns an ID for a  specific index number
-(NSString *)idForIndex:(NSIndexPath *)indexPath;

//The number of items in the current state
-(int)length;

-(NSString *)numberOfImages: (int)ID;
@end
