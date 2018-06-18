//
//  GTClassInfo.h
//  GTModel
//
//  Created by 吴华林 on 2018/6/9.
//  Copyright © 2018年 吴华林. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, GTEncodingType) {
    
    GTEncodingTypeMask       = 0xFF, ///< mask of type value
    GTEncodingTypeUnknown    = 0, ///< unknown
    GTEncodingTypeVoid       = 1, ///< void
    GTEncodingTypeBool       = 2, ///< bool
    GTEncodingTypeInt8       = 3, ///< char / BOOL
    GTEncodingTypeUInt8      = 4, ///< unsigned char
    GTEncodingTypeInt16      = 5, ///< short
    GTEncodingTypeUInt16     = 6, ///< unsigned short
    GTEncodingTypeInt32      = 7, ///< int
    GTEncodingTypeUInt32     = 8, ///< unsigned int
    GTEncodingTypeInt64      = 9, ///< long long
    GTEncodingTypeUInt64     = 10, ///< unsigned long long
    GTEncodingTypeFloat      = 11, ///< float
    GTEncodingTypeDouble     = 12, ///< double
    GTEncodingTypeLongDouble = 13, ///< long double
    GTEncodingTypeObject     = 14, ///< id
    GTEncodingTypeClass      = 15, ///< Class
    GTEncodingTypeSEL        = 16, ///< SEL
    GTEncodingTypeBlock      = 17, ///< block
    GTEncodingTypePointer    = 18, ///< void*
    GTEncodingTypeStruct     = 19, ///< struct
    GTEncodingTypeUnion      = 20, ///< union
    GTEncodingTypeCString    = 21, ///< char*
    GTEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    GTEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    GTEncodingTypeQualifierConst  = 1 << 8,  ///< const
    GTEncodingTypeQualifierIn     = 1 << 9,  ///< in
    GTEncodingTypeQualifierInout  = 1 << 10, ///< inout
    GTEncodingTypeQualifierOut    = 1 << 11, ///< out
    GTEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    GTEncodingTypeQualifierByref  = 1 << 13, ///< byref
    GTEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    GTEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    GTEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    GTEncodingTypePropertyCopy         = 1 << 17, ///< copy
    GTEncodingTypePropertyRetain       = 1 << 18, ///< retain
    GTEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    GTEncodingTypePropertyWeak         = 1 << 20, ///< weak
    GTEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    GTEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    GTEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};
/**
 Instance variable information.
 */
@interface GTIVarInfo :NSObject

@property(nonatomic, assign, readonly) Ivar ivar;

@property(nonatomic, strong, readonly) NSString *name;

@property(nonatomic, assign, readonly) ptrdiff_t offset;

@property(nonatomic, strong, readonly) NSString *typeEncoding;

@property(nonatomic, assign, readonly) GTEncodingType type;

- (instancetype)initWithIvar:(Ivar)ivar;
@end

@interface GTPropertyInfo :NSObject

@property(nonatomic, assign, readonly) objc_property_t property;

@property(nonatomic, strong, readonly) NSString *name;

@property(nonatomic, assign,readonly) GTEncodingType type;

@property(nonatomic, strong, readonly) NSString *typeEncoding;

@property(nonatomic, strong, readonly) NSString *ivarName;

@property(nonatomic, assign, readonly) Class cls;

@property(nonatomic, strong, readonly) NSArray<NSString *> *protocols;

@property(nonatomic, assign, readonly) SEL getter;

@property(nonatomic, assign, readonly) SEL setter;
- (instancetype)initWithProperty:(objc_property_t)property;
@end

@interface GTMethodInfo : NSObject
@property(nonatomic, assign, readonly)Method method;
@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic,assign, readonly)SEL seletor;
@property(nonatomic,assign, readonly) IMP imp;
@property(nonatomic, strong, readonly) NSString *returnTypeEncoding;
@property(nonatomic, strong, readonly) NSString *typeEncoding;
@property(nonatomic, strong, readonly) NSArray<NSString *> *argumentTypeEncodings;
- (instancetype)initWithMethod:(Method)method;
@end

@interface GTClassInfo : NSObject
@property(nonatomic,assign, readonly)Class cls;
@property(nonatomic,assign, readonly)Class superClass;
@property(nonatomic,assign,readonly) Class metaClass;
@property(nonatomic,assign, readonly) BOOL isMetaClass;
@property(nonatomic,assign, readonly) GTClassInfo  *superClassInfo;
@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic,strong,readonly) NSDictionary<NSString *,GTMethodInfo *> *methodInfoDict;
@property(nonatomic,strong, readonly) NSDictionary<NSString *,GTPropertyInfo *> *propertyInfoDict;
@property(nonatomic, strong, readonly) NSDictionary<NSString *,GTIVarInfo *> *ivarInfoDict;
- (void)setNeedUpdate;
- (BOOL)needUpdate;
+ (instancetype)classInfoWithClass:(Class)cls;
+ (instancetype)classInfoWithClassName:(NSString *)className;
@end
