//
//  NSObject+GTModel.m
//  GTModel
//
//  Created by 吴华林 on 2018/6/11.
//  Copyright © 2018年 吴华林. All rights reserved.
//

#import "NSObject+GTModel.h"
#import <objc/message.h>
@interface _GTModelMeta : NSObject
@end
@implementation _GTModelMeta

@end

@interface NSObject()<GTModel>
@end
@implementation NSObject (GTModel)
+ (instancetype)gt_modelWithJson:(id)json {
    NSDictionary *dict = [self gt_dictionaryWithJson:json];
    return [self gt_modelWithDictionary:dict];
}
+ (instancetype)gt_modelWithDictionary:(NSDictionary *)dicationary {
    if(!dicationary || ![dicationary isKindOfClass:[NSDictionary class]]) return nil;
    Class cls = nil;
    if([self respondsToSelector:@selector(modelCustomClassWithDictionary:)]) {
        cls = [self modelCustomClassWithDictionary:dicationary];
    }
    cls == nil ?[self class]:cls;
    id model = [[cls alloc] init];
    [model gt_modelSetWithDictionary:dicationary];
    return model;

}

#pragma mark private_method

- (BOOL)gt_modelSetWithDictionary:(NSDictionary *)dict {
    
    return YES;
}

+ (NSDictionary *)gt_dictionaryWithJson:(id)json {
    if(json) return nil;
    NSDictionary *jsonDict = nil;
    NSData *tempJsonData  = nil;
    if([json isKindOfClass:[NSDictionary class]]) {
        jsonDict = json;
    } else if ([json isKindOfClass:[NSData class]]) {
        tempJsonData = json;
    } else if ([json  isKindOfClass:[NSString class]]) {
        tempJsonData = [(NSString *)json dataUsingEncoding:NSUTF8StringEncoding];
        
    }
    if(tempJsonData) {
        id jsonObject = [NSJSONSerialization JSONObjectWithData:tempJsonData options:NSJSONReadingAllowFragments error:NULL];
        if([jsonObject isKindOfClass:[NSDictionary class]]) {
            jsonDict = jsonObject;
        }
    }
    return jsonDict;
}
@end
