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
            NSLog(@"---%s--->%s",attributeName,attributeValue);
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
                                    _cls = NSClassFromString(className);
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
@end

@implementation GTClassInfo

@end

