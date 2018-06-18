//
//  GTClassInfo.m
//  GTModel
//
//  Created by 吴华林 on 2018/6/9.
//  Copyright © 2018年 吴华林. All rights reserved.
//

#import "GTClassInfo.h"
GTEncodingType GTEncodingGetType(const char *typeEncoding) {
    
    char *type = (char *)typeEncoding;
    if(!type) return GTEncodingTypeUnknown;
    size_t len = strlen(type);
    if(len == 0) return GTEncodingTypeUnknown;
    //c 语言的类型（例如：const,in,inout,out,bycopy,byref,oneway）
    GTEncodingType qualifier = 0;
    BOOL perfix = true;
    while (perfix) {
        switch (*type) {
            case 'r':{
                qualifier |= GTEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n':{
                qualifier |= GTEncodingTypeQualifierIn;
                type++;
            } break;
                
            case 'N':{
                qualifier |= GTEncodingTypeQualifierInout;
                type++;
            } break;
                
            case 'o':{
                qualifier |= GTEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O':{
                qualifier |= GTEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R':{
                qualifier |= GTEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V':{
                qualifier |= GTEncodingTypeQualifierOneway;
                type++;
            } break;
            default: {
                perfix = false;
            }
                break;
        }
    }
    len = strlen(type);
    if(len ==0) return GTEncodingTypeUnknown | qualifier;
    switch (*type) {
        case 'v': return GTEncodingTypeVoid | qualifier;
        case 'B': return GTEncodingTypeBool | qualifier;
        case 'c': return GTEncodingTypeInt8 | qualifier;
        case 'C': return GTEncodingTypeUInt8 | qualifier;
        case 's': return GTEncodingTypeInt16 | qualifier;
        case 'S': return GTEncodingTypeUInt16 | qualifier;
        case 'i': return GTEncodingTypeInt32 | qualifier;
        case 'I': return GTEncodingTypeUInt32 | qualifier;
        case 'l': return GTEncodingTypeInt32 | qualifier;
        case 'L': return GTEncodingTypeUInt32 | qualifier;
        case 'q': return GTEncodingTypeInt64 | qualifier;
        case 'Q': return GTEncodingTypeUInt64 | qualifier;
        case 'f': return GTEncodingTypeFloat | qualifier;
        case 'd': return GTEncodingTypeDouble | qualifier;
        case 'D': return GTEncodingTypeLongDouble | qualifier;
        case '#': return GTEncodingTypeClass | qualifier;
        case ':': return GTEncodingTypeSEL | qualifier;
        case '*': return GTEncodingTypeCString | qualifier;
        case '^': return GTEncodingTypePointer | qualifier;
        case '[': return GTEncodingTypeCArray | qualifier;
        case '(': return GTEncodingTypeUnion | qualifier;
        case '{': return GTEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return GTEncodingTypeBlock | qualifier;
            else
                return GTEncodingTypeObject | qualifier;
        }
        default: return GTEncodingTypeUnknown | qualifier;
    }
}

@implementation  GTIVarInfo
- (instancetype)initWithIvar:(Ivar)ivar {
    if(!ivar) return nil;
    self = [super init];
    if(self) {
        _ivar = ivar;
        const char *name = ivar_getName(ivar);
        if(name) {
            _name = [NSString stringWithUTF8String:name];
        }
        _offset = ivar_getOffset(ivar);
        const char *typeEncoding = ivar_getTypeEncoding(ivar);
        if(typeEncoding) {
            _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
            _type = GTEncodingGetType(typeEncoding);
        }
    }
    return self;
}
@end

@implementation  GTPropertyInfo
- (instancetype)initWithProperty:(objc_property_t)property {
    if(!property) return nil;
    _property = property;
    self = [super init];
    if(self) {
        const char *name = property_getName(property);
        if(name) {
            _name = [NSString stringWithUTF8String:name];
        }
        GTEncodingType type = 0;
        unsigned int outCount = 0;
        objc_property_attribute_t *attributeList = property_copyAttributeList(property, &outCount);
        for(unsigned int i=0;i<outCount;i++) {
            objc_property_attribute_t attribute = attributeList[i];
            const char *attributeName = attribute.name;
            const char *attributeValue = attribute.value;
            if(attributeName && strlen(attributeName)>0) {
                switch (attributeName[0]) {
                    case 'T': {
                        //类型
                        if(attributeValue) {
                            _typeEncoding = [NSString stringWithUTF8String:attributeValue];
                            type = GTEncodingGetType(attributeValue);
                            if((type & GTEncodingTypeMask) == GTEncodingTypeObject) {
                                //如果数据类为id 类型的时候
                                NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                                if(![scanner scanString:@"@\"" intoString:NULL]) {
                                    continue;
                                }
                                NSString *className = nil;
                                [scanner scanUpToString:@"<" intoString:&className];
                                if(className) {
                                    _cls = objc_getClass(className.UTF8String);
                                }
                                NSMutableArray *ayProtocol = nil;
                                while ([scanner scanString:@"<" intoString:NULL]) {
                                    NSString *protocolName = nil;
                                    [scanner scanUpToString:@">" intoString:&protocolName];
                                    if(protocolName) {
                                        if(!ayProtocol) {
                                            ayProtocol = [[NSMutableArray alloc] init];
                                        }
                                        [ayProtocol addObject:protocolName];
                                    }
                                    [scanner scanString:@">" intoString:NULL];
                                }
                                _protocols = ayProtocol;
                            }
                            
                        }
                        break;
                    }
                    case 'R': type |= GTEncodingTypePropertyReadonly; break;
                    case 'C': type |= GTEncodingTypePropertyCopy; break;
                    case '&': type |= GTEncodingTypePropertyRetain; break;
                    case 'N': type |= GTEncodingTypePropertyNonatomic; break;
                    case 'D': type |= GTEncodingTypePropertyDynamic; break;
                    case 'W': type |= GTEncodingTypePropertyWeak; break;
                        
                    case 'V': {
                        //ivar 属性
                        if(attributeValue) {
                            _ivarName = [NSString stringWithUTF8String:attributeValue];
                        }
                        break;
                    }
                    case 'G': {
                        //get 方法
                        if(attributeValue) {
                            _getter = NSSelectorFromString([NSString stringWithUTF8String:attributeValue]);
                        }
                        break;
                    }
                    case 'S': {
                        //set 方法
                        if(attributeValue) {
                            _setter = NSSelectorFromString([NSString stringWithUTF8String:attributeValue]);
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            
        }
        if(attributeList) {
            free(attributeList);
        }
        _type = type;
        if(!_setter) {
            NSString *setterSeletorName = [NSString stringWithFormat:@"set%@%@:",[[_name substringToIndex:1] uppercaseString],[_name substringFromIndex:1]];
            _setter = NSSelectorFromString(setterSeletorName);
        }
        if(!_getter) {
            _getter = NSSelectorFromString(_name);
        }
    }
    return self;
}
@end

@implementation  GTMethodInfo
- (instancetype)initWithMethod:(Method)method {
    if(!method) return nil;
    self = [super init];
    _method = method;
    _seletor = method_getName(method);
    _imp = method_getImplementation(method);
    const char *name = sel_getName(_seletor);
    _name = [NSString stringWithUTF8String:name];
     char *returnType = (char *)method_copyReturnType(method);
    if(returnType) {
        _returnTypeEncoding = [NSString stringWithUTF8String:returnType];
        free(returnType);
    }
    char *typeEncoding = (char *)method_getTypeEncoding(method);
    if(typeEncoding) {
        _typeEncoding = [NSString stringWithUTF8String:typeEncoding];
        free(typeEncoding);
    }
    int numberOfArguments = method_getNumberOfArguments(method);
    NSMutableArray *ayArgumentTypeEncodings = nil;
    for(int i=0;i<numberOfArguments;i++) {
       char *argumentType = method_copyArgumentType(method, i);
        if(!ayArgumentTypeEncodings) {
            ayArgumentTypeEncodings = [[NSMutableArray alloc] init];
        }
        NSString *strArgumentType =argumentType?[NSString stringWithUTF8String:argumentType]:@"";
        if(strArgumentType) {
            [ayArgumentTypeEncodings addObject:strArgumentType];
        }
        if(argumentType) {
            free(argumentType);
        }
        
    }
    _argumentTypeEncodings = ayArgumentTypeEncodings;
    
    return self;
}
@end
@interface GTClassInfo()
{
    BOOL _needUpdate;
}
@end
@implementation GTClassInfo
- (void)setNeedUpdate {
    _needUpdate = YES;
}
- (BOOL)needUpdate {
    return _needUpdate;
}
+ (instancetype)classInfoWithClass:(Class)cls {
    if(!cls) return nil;
    static dispatch_once_t onceToken;
    static CFMutableDictionaryRef classCache;
    static CFMutableDictionaryRef metaClassCache;
    static dispatch_semaphore_t semaphore;
    dispatch_once(&onceToken, ^{
        classCache = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        metaClassCache = CFDictionaryCreateMutable(kCFAllocatorSystemDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
       semaphore= dispatch_semaphore_create(1);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    CFMutableDictionaryRef cache = class_isMetaClass(cls)?metaClassCache:classCache;
   GTClassInfo *classInfo = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    if(classInfo && classInfo.needUpdate) {
        [classInfo _update];
    }
     dispatch_semaphore_signal(semaphore);
    if(!classInfo) {
         classInfo = [[self alloc] initWithClass:cls];
        if(classInfo) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(classInfo));
            dispatch_semaphore_signal(semaphore);
        }
    }
  
    return classInfo;
}
+ (instancetype)classInfoWithClassName:(NSString *)className {
    if(!className) return nil;
    Class cls = objc_getClass(className.UTF8String);
    return [self classInfoWithClass:cls];
}
#pragma mark private_method
- (instancetype)initWithClass:(Class)cls {
    if(!cls) return nil;
    self = [super init];
    _cls = cls;
    _isMetaClass = class_isMetaClass(cls);
  
    _superClass = class_getSuperclass(cls);
    _name = [NSString stringWithUTF8String:class_getName(cls)];
    if(!_isMetaClass) {
        _metaClass = objc_getMetaClass(class_getName(cls));
    }
    [self _update];
    _superClassInfo = [[self class] classInfoWithClass:_superClass];
    return self;
}
- (void)_update {
    unsigned int outCount;
    //property
   NSMutableDictionary *propertyDict = [[NSMutableDictionary alloc] init];
   objc_property_t *propertyList = class_copyPropertyList(self.class, &outCount);
    
    for(int i=0;i<outCount;i++) {
        objc_property_t property = propertyList[i];
        GTPropertyInfo *propertyInfo = [[GTPropertyInfo alloc] initWithProperty:property];
        [propertyDict setObject:propertyInfo forKey:propertyInfo.name];
    }
    _propertyInfoDict = propertyDict;
    free(propertyList);
    //Ivar
    NSMutableDictionary *ivarDict = [[NSMutableDictionary alloc] init];
    Ivar *ivarList = class_copyIvarList(self.class, &outCount);
    for(int i=0;i<outCount;i++) {
        Ivar ivar = ivarList[i];
        GTIVarInfo *ivarInfo = [[GTIVarInfo alloc] initWithIvar:ivar];
        [ivarDict setObject:ivarInfo forKey:ivarInfo.name];
    }
    _ivarInfoDict = ivarDict;
     free(ivarList);
    //method
    NSMutableDictionary *methodDict = [[NSMutableDictionary alloc] init];
    Method *methodList = class_copyMethodList(self.class, &outCount);
    for(int i=0;i<outCount;i++) {
        Method method = methodList[i];
        GTMethodInfo *methodInfo = [[GTMethodInfo alloc] initWithMethod:method];
        [methodDict setObject:methodInfo forKey:methodInfo.name];
    }
    _methodInfoDict = methodDict;
    free(methodList);
   
}
@end

