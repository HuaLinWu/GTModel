//
//  NSObject+GTModel.h
//  GTModel
//
//  Created by 吴华林 on 2018/6/11.
//  Copyright © 2018年 吴华林. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (GTModel)


@end

@protocol GTModel <NSObject>
@optional

/**
 用户根据dictionary 自定义的model 的class

 @param dictionary 待转化的 dictionary
 @return 需要转化的目标model 的class
 */
+ (Class)modelCustomClassWithDictionary:(NSDictionary *)dictionary;

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass;

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper;

+ (NSArray<NSString *> *)blackPropertyList;

+ (NSArray<NSString *> *)whitePropertyList;
/**
 在自定义转化model 之前，如果需要对源dictionary 进行处理的，请实现这个方法

 @param dictionary 源dictionary
 @return 转化过后的dictionary
 */
- (NSDictionary *)modelCustomWillTransformFromDictionary:(NSDictionary *)dictionary;
- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dictionary;
@end
