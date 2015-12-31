//
//  ViewController.m
//  CCModel
//
//  Created by ColeXm on 15/12/28.
//  Copyright © 2015年 ColeXm. All rights reserved.
//

#import "ViewController.h"
#import "CCGHUser.h"
#import "NSObject+CCModel.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"user" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    
    //jsonToModel
    CCGHUser *model = [CCGHUser cc_modelFromJson:data];
    
    
    //modelToDic
    NSLog(@"%@",[model cc_modelToDictionary]);
    
    
}



@end
