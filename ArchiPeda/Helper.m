//
//  TagHelper.m
//  ArchiPeda
//
//  Created by Jeffrey Delawder Jr on 10/14/12.
//  Copyright (c) 2012 Jeffrey Delawder Jr. All rights reserved.
//

#import "Helper.h"

@implementation Helper

enum STATE {
    TAG = 0,
    FOLDER = 1
};

@synthesize imageIDURLS = _imageIDURLS, currentDirectoryContentsNames = _currentDirectoryContentsNames, name = _name, currentStateIDS =_currentStateIDS, currentState = _currentState;
@synthesize imageURL = _imageURL, realURLS = _realURLS;
//URL for all the tags
#define BASETAGNAMESURL @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=7"

//URL for all the tag ids
#define BASETAGIDSURL @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=8"

//URL for Base Folder
#define BASEFOLDERNAMESURL @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=1"

-(void)loadData{
    //Implement actions to load initial Tag State
    if (_currentState == TAG) {
        NSURL *_currentTagURL = [NSURL URLWithString:BASETAGNAMESURL];
        _name = @"Tags";
        //Retrieve Names
        NSData *data = [NSData dataWithContentsOfURL:_currentTagURL];
        NSString *url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@""];
        _currentDirectoryContentsNames = [NSMutableArray arrayWithArray:[url componentsSeparatedByString:@","]];
        
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:BASETAGIDSURL]];
        url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        _currentStateIDS = [NSMutableArray arrayWithArray: [url componentsSeparatedByString:@","]];
        
        url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=9&TagID=";
        url = [url stringByAppendingString:@"0"];
        _imageURL = [NSURL URLWithString:url];
        
        url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=10&TagID=";
        url = [url stringByAppendingString:@"0"];
        _imageIDURLS = [NSURL URLWithString:url];
        
        url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=11&TagID=";
        url = [url stringByAppendingString:@"0"];
        _realURLS = [NSURL URLWithString:url];
        
    }
    else{
        NSURL *_currentDirectoryURL = [NSURL URLWithString:BASEFOLDERNAMESURL];
        _name = @"Base";
        //Retrieve Names
        NSData *data = [NSData dataWithContentsOfURL:_currentDirectoryURL];
        NSString *url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        _currentDirectoryContentsNames = [NSMutableArray arrayWithArray:[url componentsSeparatedByString:@","]];
        for (NSString* lab in _currentDirectoryContentsNames) {
            NSLog(@"%@", lab);
        }
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=4"]];
        url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
        url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        _currentStateIDS = [NSMutableArray arrayWithArray: [url componentsSeparatedByString:@","]];
        
        _imageURL = nil;
        _imageIDURLS = nil;
        _realURLS =nil;
    }
   
}
-(id)init:(NSString *)StateID :(NSString *)Name: (int)CurrentState{
    self = [super init];
    
    if (self) {
        _currentState = CurrentState;
        if (_currentState == TAG) {
            NSURL *_currentTagURL = [NSURL URLWithString:BASETAGNAMESURL];
            _name = @"Tags";
            //Retrieve Names
            NSData *data = [NSData dataWithContentsOfURL:_currentTagURL];
            NSString *url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            _currentDirectoryContentsNames = [NSMutableArray arrayWithArray:[url componentsSeparatedByString:@","]];
            
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:BASETAGIDSURL]];
            url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            _currentStateIDS = [NSMutableArray arrayWithArray: [url componentsSeparatedByString:@","]];
            
            url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=9&TagID=";
            url = [url stringByAppendingString:StateID];
            _imageURL = [NSURL URLWithString:url];
            
            url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=10&TagID=";
            url = [url stringByAppendingString:StateID];
            _imageIDURLS = [NSURL URLWithString:url];
            
            url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=11&TagID=";
            url = [url stringByAppendingString:StateID];
            _realURLS = [NSURL URLWithString:url];
        }
        else{
            NSString *url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=2&ParentID=";
            url = [url stringByAppendingString:StateID];
            _name = Name;
            
            //Retrieve IDS
            url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=5&ParentID=";
            url = [url stringByAppendingString:StateID];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            _currentStateIDS = [NSMutableArray arrayWithArray:[url componentsSeparatedByString:@","]];
            //Retrieve Names
            url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=2&ParentID=";
            url = [url stringByAppendingString:StateID];
            data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            url = [url stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            _currentDirectoryContentsNames =  [NSMutableArray arrayWithArray:[url componentsSeparatedByString:@","]];;
            
            url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=3&FolderID=";
            url = [url stringByAppendingString:StateID];
            _imageURL = [NSURL URLWithString:url];
            
            url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=6&FolderID=";
            url = [url stringByAppendingString:StateID];
            _imageIDURLS = [NSURL URLWithString:url];
            
            url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=12&FolderID=";
            url = [url stringByAppendingString:StateID];
            _realURLS = [NSURL URLWithString:url];
        }
    }
    return self;
}
-(NSString *)nameForIndex:(NSIndexPath *)indexPath{
    return [_currentDirectoryContentsNames objectAtIndex:indexPath.row];
}
-(NSString *)idForIndex:(NSIndexPath *)indexPath{
    return [_currentStateIDS objectAtIndex:indexPath.row];
}
-(int)length{
    return _currentStateIDS.count;
}
-(NSString *)numberOfImages: (int) ID{
    NSString *url;
    if (_currentState == FOLDER) {
        url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=15&ParentID=";
        url = [url stringByAppendingFormat:@"%@", [_currentStateIDS objectAtIndex:ID]];
    }
    else {
        url = @"http://aswiftlytiltingplanet.net/senske/index.php?requestNum=16&TagID=";
        url = [url stringByAppendingFormat:@"%@", [_currentStateIDS objectAtIndex:ID]];
    }
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    url = [url stringByReplacingOccurrencesOfString:@"[" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"]" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    return url;
}
@end
