//
//  WLFDynamicObject.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/10.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFDynamicObject.h"
#import <objc/objc-runtime.h>

//https://github.com/snej/MYUtilities/blob/master/MYDynamicObject.m

@interface WLFDynamicObject () <WLFDynamicObject>

@end

@implementation WLFDynamicObject

NS_INLINE BOOL is_getter(const char *name)
{
    if (!name[0] || name[0] == '_' || name[strlen(name)-1] == ':') return NO;
    if (strncmp(name, "get", 3) == 0) return NO;
    return YES;
}

NS_INLINE BOOL is_setter(const char *name)
{
    return strncmp("set", name, 3) == 0 && name[strlen(name)-1] == ':';
}

NS_INLINE NSString *getter_key(SEL sel)
{
    return [NSString stringWithUTF8String:sel_getName(sel)];
}

NS_INLINE NSString *setter_key(SEL sel)
{
    const char *name = sel_getName(sel) +3;
    size_t length = strlen(name);
    char buffer[length +1];
    strcpy(buffer, name);
    buffer[0] = (char)tolower(buffer[0]);
    buffer[length -1] = '\0';
    return [NSString stringWithUTF8String:buffer];
}

static BOOL get_property_info(Class class, NSString *propertyName, BOOL setter, Class *declaredInClass, const char **propertyType)
{
    const char *name = [propertyName UTF8String];
    objc_property_t property = class_getProperty(class, name);
    if (!property) {
        *propertyType = NULL;
        return NO;
    }

    do {
        *declaredInClass = class;
        class = class_getSuperclass(class);
    } while (class_getProperty(class, name) == property);

    BOOL isSettable;
    *propertyType = get_property_type(property, &isSettable);
    if (setter && !isSettable) {
        *propertyType = NULL;
        return NO;
    }
    return YES;
}

static const char *get_property_type(objc_property_t property, BOOL *outIsSettable)
{
    *outIsSettable = YES;
    const char *result = "@";

    // Copy property attributes into a writeable buffer:
    const char *attributes = property_getAttributes(property);
    char buffer[strlen(attributes) +1];
    strcpy(buffer, attributes);

    // Scan the comma-delimited sections of the string:
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        switch (attribute[0]) {
            case 'T':       // Property type in @encode format
                result = (const char *)[[NSData dataWithBytes:(attribute +1)
                                                       length:strlen(attribute)] bytes];
                break;
            case 'R':       // Read-only indicator
                *outIsSettable = NO;
                break;
        }
    }
    return result;
}

static Class get_meta_class(Class class)
{
    NSString *className = NSStringFromClass(class);
    return objc_getMetaClass(className.UTF8String);
}

static Class get_primary_class(const char *propertyType)
{
    if (propertyType[0] == _C_ID && strlen(propertyType) > 1) {
        size_t length = strlen(propertyType);
        char buffer[length +1];
        strcpy(buffer, propertyType);
        buffer[length -1] = '\0';
        char *s = strstr(buffer, "<");
        if (s != NULL && s != &buffer[0]) {
            s[0] = '\0';
        }
        return objc_getClass(&buffer[2]);
    }
    return Nil;
}

static Class get_secondary_class(const char *propertyType)
{
    if (propertyType[0] == _C_ID && strlen(propertyType) > 1) {
        size_t length = strlen(propertyType);
        char buffer[length +1];
        strcpy(buffer, propertyType);
        buffer[length -1] = '\0';
        char *s = strstr(buffer, "<");
        if (s != NULL) {
            s[0] = '\0';
            s = &s[1];
            char *t = strstr(s, ",");
            if (t != NULL) {
                t[0] = '\0';
            } else {
                length = strlen(s);
                s[length -1] = '\0';
            }
        }
        return objc_getClass(s);
    }
    return Nil;
}

#pragma mark - 

static inline void set_id_property(WLFDynamicObject *self, NSString *property, id value)
{
    [self setObject:value forDynamicKey:property];
}

#ifdef TEST
static inline BOOL is_subclass_of_class(Class class, Class target)
{
    while (class) {
        if (strcmp(class_getName(class), class_getName(target)) == 0) {
            return YES;
        }
        class = class_getSuperclass(class);
    }
    return NO;
}
#endif

#pragma mark -

+ (IMP)impForIdGetterOfProperty:(NSString *)property ofType:(const char *)propertyType
{
    Class primaryClass = get_primary_class(propertyType);
    if ([primaryClass isSubclassOfClass:[NSArray class]]) {
        Class metaClass = get_meta_class(self);
        Class secondaryClass = get_secondary_class(propertyType);

        return imp_implementationWithBlock(^id (WLFDynamicObject *receiver) {
            return [receiver arrayForDynamicKey:property
                                     arrayClass:primaryClass
                                      itemClass:secondaryClass];
        });
#ifdef TEST
    } else if (is_subclass_of_class(primaryClass, [WLFDynamicObject class])) {
#else
    } else if ([primaryClass isSubclassOfClass:[WLFDynamicObject class]]) {
#endif
        return imp_implementationWithBlock(^id (WLFDynamicObject *receiver) {
            return [receiver dynamicObjectForDynamicKey:property
                                           dynamicClass:primaryClass];
        });
    } else {
        return imp_implementationWithBlock(^id (WLFDynamicObject *receiver) {
            return [receiver objectForDynamicKey:property];
        });
    }
}

+ (IMP)impForGetterOfProperty:(NSString *)property ofType:(const char *)propertyType
{
    switch (propertyType[0]) {
        case _C_ID:
            return [self impForIdGetterOfProperty:property ofType:propertyType];
        case _C_INT:
        case _C_SHT:
        case _C_USHT:
        case _C_CHR:
        case _C_UCHR:
            return imp_implementationWithBlock(^int (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] intValue];
            });
        case _C_UINT:
            return imp_implementationWithBlock(^unsigned int (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] unsignedIntValue];
            });
        case _C_LNG:
            return imp_implementationWithBlock(^long (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] longValue];
            });
        case _C_ULNG:
            return imp_implementationWithBlock(^unsigned long (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] unsignedLongValue];
            });
        case _C_LNG_LNG:
            return imp_implementationWithBlock(^long long (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] longLongValue];
            });
        case _C_ULNG_LNG:
            return imp_implementationWithBlock(^unsigned long long (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] unsignedLongLongValue];
            });
        case _C_BOOL:
            return imp_implementationWithBlock(^bool (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] boolValue];
            });
        case _C_FLT:
            return imp_implementationWithBlock(^float (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] floatValue];
            });
        case _C_DBL:
            return imp_implementationWithBlock(^double (WLFDynamicObject *receiver) {
                return [[receiver objectForDynamicKey:property] doubleValue];
            });
        default:
            return NULL;
    }
}


+ (IMP)impForIdSetterOfProperty:(NSString *)property ofType:(const char *)propertyType
{
    Class primaryClass = get_primary_class(propertyType);
    if ([primaryClass isSubclassOfClass:[NSArray class]]) {
        Class secondaryClass = get_secondary_class(propertyType);

        return imp_implementationWithBlock(^void (WLFDynamicObject *receiver, id value) {
            [receiver setArray:value forDynamicKey:property
                    arrayClass:primaryClass itemClass:secondaryClass];
        });
#ifdef TEST
    } else if (is_subclass_of_class(primaryClass, [WLFDynamicObject class])) {
#else
    } else if ([primaryClass isSubclassOfClass:[WLFDynamicObject class]]) {
#endif
        return imp_implementationWithBlock(^void (WLFDynamicObject *receiver, id value) {
            [receiver setDynamicObject:value forDynamicKey:property dynamicClass:primaryClass];
        });
    } else {
        return imp_implementationWithBlock(^(WLFDynamicObject *receiver, id value) {
            set_id_property(receiver, property, value);
        });
    }
}


+ (IMP)impForSetterOfProperty:(NSString *)property ofType:(const char *)propertyType
{
    switch (propertyType[0]) {
        case _C_ID:
            return [self impForIdSetterOfProperty:property ofType:propertyType];
        case _C_INT:
        case _C_SHT:
        case _C_USHT:
        case _C_CHR:
        case _C_UCHR:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, int value) {
                set_id_property(receiver, property, [NSNumber numberWithInt:value]);
            });
        case _C_UINT:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, unsigned int value) {
                set_id_property(receiver, property, [NSNumber numberWithUnsignedInt:value]);
            });
        case _C_LNG:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, long value) {
                set_id_property(receiver, property, [NSNumber numberWithLong:value]);
            });
        case _C_ULNG:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, unsigned long value) {
                set_id_property(receiver, property, [NSNumber numberWithUnsignedLong:value]);
            });
        case _C_LNG_LNG:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, long long value) {
                set_id_property(receiver, property, [NSNumber numberWithLongLong:value]);
            });
        case _C_ULNG_LNG:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, unsigned long long value) {
                set_id_property(receiver, property, [NSNumber numberWithUnsignedLongLong:value]);
            });
        case _C_BOOL:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, bool value) {
                set_id_property(receiver, property, [NSNumber numberWithBool:value]);
            });
        case _C_FLT:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, float value) {
                set_id_property(receiver, property, [NSNumber numberWithFloat:value]);
            });
        case _C_DBL:
            return imp_implementationWithBlock(^(WLFDynamicObject *receiver, double value) {
                set_id_property(receiver, property, [NSNumber numberWithDouble:value]);
            });
        default:
            return NULL;
    }
}

#pragma mark -

- (void)setObject:(id)anObject forDynamicKey:(id<NSCopying>)aKey
{
    NSAssert(NO, (NSString *)aKey);
}

- (id)objectForDynamicKey:(id)aKey
{
    NSAssert(NO, (NSString *)aKey);
    return nil;
}

- (void)setArray:(id)anObject forDynamicKey:(NSString *)aKey arrayClass:(Class)arrayClass itemClass:(Class)innerClass
{
    NSAssert(NO, (NSString *)aKey);
}

- (id)arrayForDynamicKey:(NSString *)aKey arrayClass:(Class)arrayClass itemClass:(Class)innerClass
{
    NSAssert(NO, (NSString *)aKey);
    return nil;
}

- (void)setDynamicObject:(id)anObject forDynamicKey:(NSString *)aKey dynamicClass:(Class)dynamicClass
{
    NSAssert(NO, (NSString *)aKey);
}

- (id)dynamicObjectForDynamicKey:(NSString *)aKey dynamicClass:(Class)dynamicClass
{
    NSAssert(NO, (NSString *)aKey);
    return nil;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    const char *name = sel_getName(sel);
    Class declaredInClass = Nil;
    const char *propertyType = NULL;
    char signature[5] = {0};
    IMP accessor = NULL;

    if (is_setter(name)) {
        NSString *key = setter_key(sel);
        if (get_property_info(self, key, YES, &declaredInClass, &propertyType)) {
            strcpy(signature, "v@: ");
            signature[3] = propertyType[0];
            accessor = [self impForSetterOfProperty:key ofType:propertyType];
        }
    } else if (is_getter(name)) {
        NSString *key = getter_key(sel);
        if (get_property_info(self, key, NO, &declaredInClass, &propertyType)) {
            strcpy(signature, " @:");
            signature[0] = propertyType[0];
            accessor = [self impForGetterOfProperty:key ofType:propertyType];
        }
    }

    if (accessor) {
        class_addMethod(self, sel, accessor, signature);
        return YES;
    }
    return NO;
}


@end
