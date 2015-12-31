//
//  NSObject+CCModel.m
//  CCModel
//
//  Created by ColeXm on 15/12/28.
//  Copyright © 2015年 ColeXm. All rights reserved.
//

#import "NSObject+CCModel.h"
#import <objc/runtime.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


const char CCPropertyTypeInt = 'i';
const char CCPropertyTypeShort = 's';
const char CCPropertyTypeLong = 'l';
const char CCPropertyTypeLongLong = 'q';
const char CCPropertyTypeFloat = 'f';
const char CCPropertyTypeDouble = 'd';
const char CCPropertyTypeBOOL1 = 'c';
const char CCPropertyTypeBOOL2 = 'B';
const char CCPropertyTypeChar = 'c';    //与CCPropertyTypeBOOL1逻辑一样
const char CCPropertyTypeUnSignedInt = 'I';
const char CCPropertyTypeUnSignedShort = 'S';
const char CCPropertyTypeUnSignedLong = 'L';
const char CCPropertyTypeUnSignedLongLong = 'Q';
const char CCPropertyTypeUnSignedChar = 'C';

const char CCPropertyTypeObject = '@';

NSString *const CCNullString = @"";


@implementation NSObject (CCModel)

inline static const char * getPropertyType(objc_property_t property)
{
    const char *attributes = property_getAttributes(property);
    
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            char *attributeTemp=(char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute)] bytes];
            char *p = strtok(attributeTemp, "\"");
            if(p) return (const char*)p;
            p = strtok(NULL, "\"");
            if(p) return  (const char*)p;
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            char *attributeTemp=(char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute)] bytes];
            char *p = strtok(attributeTemp, "\"");
            if(p) return (const char*)p;
            p = strtok(NULL, "\"");
            if(p) return  (const char*)p;
        }
        return nil;
    }
    return nil;
}




+(id)cc_modelFromJson:(id)jsonData{
    id model = self.new;
    
    NSDictionary *dict = (NSDictionary *)[jsonData cc_JSONObject];
    
    if (dict == nil || dict.count == 0) return model;
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList(self.class, &propertyCount);
    for (NSUInteger i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        NSString *keyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSObject *value;
        if ([self respondsToSelector:@selector(cc_modelMapFromJson)]) {
            NSDictionary *newDic = [self performSelector:@selector(cc_modelMapFromJson)];
            NSArray *valueArray = [newDic allKeys];
            if ([valueArray containsObject:keyName]) {
                value = (NSObject *)[dict objectForKey:[newDic objectForKey:keyName]];
            }
            else{
                value = (NSObject *)[dict objectForKey:keyName];
            }
        }
        else{
            value = (NSObject *)[dict objectForKey:keyName];
        }
        
        if (value == nil || [[value class] isSubclassOfClass:[NSNull class]]) continue;
        
        char *typeEncoding = property_copyAttributeValue(property, "T");
        
        if (typeEncoding == NULL) continue;
        
        switch (typeEncoding[0])
        {
            
            case CCPropertyTypeObject:
            {
                Class class = nil;
                if (strlen(typeEncoding) >= 3)
                {
                    char *className = strndup(typeEncoding+2, strlen(typeEncoding)-3);
                    class = NSClassFromString([NSString stringWithUTF8String:className]);
                    free(className);
                }
                
                //类型容错
                if ([class isSubclassOfClass:[NSString class]] && [value isKindOfClass:[NSNumber class]]) {
                    value = [(NSNumber *)value stringValue];
                }
                else if ([class isSubclassOfClass:[NSNumber class]] && [value isKindOfClass:[NSString class]]) {
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    value = [numberFormatter numberFromString:(NSString *)value];
                }
                //数组
                else if ([class isSubclassOfClass:[NSArray class]]&&[[value class] isSubclassOfClass:[NSArray class]])
                {
                    NSArray *arr = (NSArray *)value;
                    NSMutableArray *fieldArr = [NSMutableArray new];
                    for (NSInteger i=0; i<[arr count]; i++) {
                        NSDictionary *itemDict = [arr objectAtIndex:i];
                        if ([itemDict isKindOfClass:[NSDictionary class]] == NO) continue;
                        [fieldArr addObject:[NSClassFromString(keyName) cc_modelFromJson:itemDict]];
                    }
                    value = fieldArr;
                }
                //字典
                else if ([[value class] isSubclassOfClass:[NSDictionary class]]) {
                    value = [class cc_modelFromJson:value];
                }
                
                [model setValue:value forKey:keyName];
            }
                break;
                
                
            case CCPropertyTypeInt: //按照简单数据类型赋值
            case CCPropertyTypeShort:
            case CCPropertyTypeLong:
            case CCPropertyTypeLongLong:
            case CCPropertyTypeUnSignedInt:
            case CCPropertyTypeUnSignedShort:
            case CCPropertyTypeUnSignedLong:
            case CCPropertyTypeUnSignedLongLong:
            case CCPropertyTypeFloat:
            case CCPropertyTypeDouble:
            {
                if ([value isKindOfClass:[NSString class]]) {
                    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                    value = [numberFormatter numberFromString:(NSString *)value];
                    if (!value) value = [NSNumber numberWithInt:0];
                }
                [model setValue:value forKey:keyName];
            }
                break;
                
                
            case CCPropertyTypeBOOL1: //bool类型容错
            case CCPropertyTypeBOOL2:
            {
                if ([value isKindOfClass:[NSString class]]) {
                    NSString *str = (NSString *)value;
                    NSString *lowStr = str.lowercaseString;
                    if ([lowStr isEqualToString:@"false"]||
                        [lowStr isEqualToString:@"no"]||
                        [lowStr isEqualToString:@"nil"]||
                        [lowStr isEqualToString:@"null"]||
                        [lowStr isEqualToString:@"(null)"]) {
                        value = [NSNumber numberWithBool:0];
                    }
                    else{
                        value = [NSNumber numberWithBool:1];
                    }
                   }
                [model setValue:value forKey:keyName];
            }
                break;
            case CCPropertyTypeUnSignedChar: //如果字符取第一个
            {
                if ([value isKindOfClass:[NSString class]]) {
                    NSString *str = (NSString *)value;
                    if (!str || str.length == 0) {
                        value = [NSNumber numberWithInt:0];
                    }
                    else{
                        value = [NSNumber numberWithChar:[str characterAtIndex:0]];
                    }
                }
                [model setValue:value forKey:keyName];
            }
                break;
            default:
                break;
        }

        free(typeEncoding);
    }
    
    free(properties);
    return model;
}


- (NSDictionary *)cc_modelToDictionary{
    
    NSMutableDictionary *finalDict=nil;
    @synchronized(self)
    {
        NSString *className = NSStringFromClass([self class]);
        const char *cClassName = [className UTF8String];
        id theClass = objc_getClass(cClassName);
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
        finalDict = [NSMutableDictionary new];
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *name = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
            NSString *type = [[NSString alloc] initWithCString:getPropertyType(property) encoding:NSUTF8StringEncoding];
            if (!type) type= [[NSString alloc] initWithCString:getPropertyType(property) encoding:NSASCIIStringEncoding];
            
            SEL selector = NSSelectorFromString(name);
            
            NSString *lowTypeStr = type.lowercaseString;
            
            if ([lowTypeStr isEqualToString:@"i"] ||
                [lowTypeStr isEqualToString:@"l"] ||
                [lowTypeStr isEqualToString:@"s"] ||
                [lowTypeStr isEqualToString:@"q"] ||
                [lowTypeStr isEqualToString:@"b"] )
            {
                NSInteger value;
                SuppressPerformSelectorLeakWarning (value = (NSInteger)[self performSelector:selector]);
                [finalDict setObject:[NSNumber numberWithInteger:value] forKey:name];
            }
            else if ([lowTypeStr isEqualToString:@"f"] || [lowTypeStr isEqualToString:@"d"]) {

                Ivar *ivar = class_copyIvarList(self.class, nil);
                float newFloat;
#warning This file must be compiled with Non_ARC.
                object_getInstanceVariable(self, ivar_getName(ivar[0]), (void*)&newFloat);
                [finalDict setObject:[NSNumber numberWithFloat:newFloat] forKey:name];
            }
            else if ([lowTypeStr isEqualToString:@"c"]) {
                char value;
                SuppressPerformSelectorLeakWarning (value = (char)[self performSelector:selector]);
                [finalDict setObject:[NSString stringWithFormat:@"%c",value] forKey:name];
            }
            else {
                id value;
                SuppressPerformSelectorLeakWarning(value = [self performSelector:selector]);
                
                if ([type isEqualToString:@"NSString"]) {
                    if (value) [finalDict setObject:[NSString stringWithFormat:@"%@", value] forKey:name];
                }
                else if ([type isEqualToString:@"NSMutableArray"]||[type isEqualToString:@"NSArray"]) {   //数组
                    if (![value isKindOfClass:[NSArray class]]) continue;
                    
                    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:value];
                    NSMutableArray *results = [[NSMutableArray alloc] init];
                    for (id onceId in array) {
                        [results addObject:[onceId cc_modelToDictionary]];
                    }
                    
                    if (results) {
                        [finalDict setObject:results forKey:name];
                    }
                }
                else  //对象
                {
                    NSDictionary *dic = [value cc_modelToDictionary];
                    if (dic) {
                        [finalDict setObject:dic forKey:name];
                    }
                    
                }
            }
        }
        free(properties);
    }
    return finalDict;
    
}


-(id)cc_JSONObject{
    if ([self isKindOfClass:[NSString class]]) {
        return  [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    }
    else if ([self isKindOfClass:[NSData class]]) {
        return  [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
    }
    return self;
}


@end
