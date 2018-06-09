//
//  ViewController.m
//  GTModel
//
//  Created by 吴华林 on 2018/6/9.
//  Copyright © 2018年 吴华林. All rights reserved.
//

#import "ViewController.h"
#import "GTClassInfo.h"
@interface ViewController ()
@property(nonatomic,copy)NSString *str;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    unsigned int outCount = 0;
   objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    for(int i=0;i <outCount ;i++) {
        objc_property_t property = propertyList[i];
        GTPropertyInfo *propertyInfo = [[GTPropertyInfo alloc] initWithProperty:property];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
