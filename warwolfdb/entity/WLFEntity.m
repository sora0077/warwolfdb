//
//  WLFEntity.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/10.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFEntity.h"
#import <objc/objc-runtime.h>
#import "WLFRepository.h"
#import "WLFEntityIdentifier.h"
#import "WLFTable.h"
#import "WLFTableColumns.h"
#import "WLFColumnKey.h"
#import "WLFTableReferences.h"
#import "WLFReferenceKey.h"
#import "WLFTableReverses.h"

#import "WLFArrayProxy.h"
#import "WLFEntityReferences.h"


static Class get_item_class(Class self, NSString *propName)
{
    NSString *itemClassSelName = [propName stringByAppendingString:@"ItemClass"];
    Class itemClass = objc_msgSend(self, NSSelectorFromString(itemClassSelName));
    return itemClass;
}

static Class get_through_class(Class self, NSString *propName)
{
    NSString *throughClassSelName = [propName stringByAppendingString:@"ThroughClass"];
    SEL throughClassSel = NSSelectorFromString(throughClassSelName);
    if ([self respondsToSelector:throughClassSel]) {
        return objc_msgSend(self, throughClassSel);
    }
    return Nil;
}

@interface _WLFEntity ()
@property (nonatomic, readwrite) WLFEntityIdentifier *identifier;
@property (nonatomic, readwrite) Class entityClass;
@property (nonatomic, readwrite) NSDictionary *values;


- (id)initWithIdentifier:(WLFEntityIdentifier *)identifier entityClass:(Class)entityClass values:(NSDictionary *)values;

@end

@implementation _WLFEntity

- (id)initWithIdentifier:(WLFEntityIdentifier *)identifier entityClass:(Class)entityClass values:(NSDictionary *)values
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _entityClass = entityClass;
        _values = [values copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        if ([self isKindOfClass:[object class]]) {
            return [self.identifier isEqual:[object identifier]];
        }
        return NO;
    }
    return YES;
}

- (NSUInteger)hash
{
    return [self.identifier hash];
}

- (id)instantiate
{
    if (![self isKindOfClass:self.entityClass]) {
        return [WLFRepository entityWithClass:self.entityClass
                                   identifier:self.identifier
                                       values:self.values];
    }
    return self;
}

@end

@interface WLFEntity () <WLFDynamicObject>
@property (nonatomic, readonly) NSString *_type;
@property (nonatomic, readonly) BOOL _expire;

- (void)setRelatedEntity:(WLFEntity *)entity forKey:(NSString *)key;

@end

@implementation WLFEntity
{
    NSMutableDictionary *_dynamics;
    WLFEntityReferences *_references;
    BOOL _exists, _autosave;
    BOOL __expire;
}

- (void)dealloc
{
    NSLog(@"%@ %@", NSStringFromClass([self class]), _dynamics);
}

- (id)initWithIdentifier:(WLFEntityIdentifier *)identifier
{
    return [self initWithIdentifier:identifier values:nil];
}

- (id)initWithIdentifier:(WLFEntityIdentifier *)identifier values:(NSDictionary *)values
{
    self = [super initWithIdentifier:identifier entityClass:[self class] values:nil];
    if (self) {
        NSParameterAssert(identifier);
        _references = [[WLFEntityReferences alloc] initWithOwner:self];
        _dynamics = @{}.mutableCopy;
        _autosave = YES;
        __expire = NO;
        __type = NSStringFromClass(self.class);
        
        for (WLFColumnKey *key in self.table.columns) {
            if (values && ![values.allKeys containsObject:key.name]) {
                [self setObject:key.defaultValue forDynamicKey:key.name];
            }
        }

        [values enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSArray class]]) {
                NSArray *array = obj;
                if (array.count) {
                    id item = array[0];
                    [self setArray:array forDynamicKey:key arrayClass:[array class] itemClass:[item class]];
                }
                return;
            }
            if ([obj isKindOfClass:[WLFDynamicObject class]]) {
                [self setDynamicObject:obj forDynamicKey:key dynamicClass:[obj class]];
                return;
            }
            [self setObject:obj forDynamicKey:key];
        }];
    }
    return self;
}

- (id)symbolize
{
    if ([self isKindOfClass:self.entityClass]) {
        return [[_WLFEntity alloc] initWithIdentifier:self.identifier
                                          entityClass:self.entityClass
                                               values:_dynamics];
    }
    return self;
}

- (void)save
{

}

- (void)delete
{
    __expire = YES;
}

- (void)sync
{
    
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@,%p: %@>", NSStringFromClass([self class]), self, self.identifier.uuid];
}

- (void)setRelatedEntity:(WLFEntity *)entity forKey:(NSString *)key
{
    NSParameterAssert(entity);
    Class itemClass = [entity class];
    Class throughClass = get_through_class([self class], key);
    [self setDynamicObject:entity forDynamicKey:key dynamicClass:itemClass];
    WLFArrayProxy *proxy = [_references[itemClass] proxyForKey:key throughClass:throughClass];
    [proxy add:entity];
}

- (void)removeRelatedEntity:(WLFEntity *)entity forKey:(NSString *)key
{
    NSParameterAssert(entity);
    Class itemClass = [entity class];
    Class throughClass = get_through_class([self class], key);
    WLFArrayProxy *proxy = [_references[itemClass] proxyForKey:key throughClass:throughClass];
    [proxy remove:entity];
    [self setDynamicObject:nil forDynamicKey:key dynamicClass:[entity class]];
}

- (void)setObject:(id)anObject forDynamicKey:(NSString *)aKey
{
    if (![self.table.columns containsKey:aKey]) return;
    NSLog(@"%@ %s %@ %@", self, __func__, aKey, anObject);
    if (anObject) {
        [_dynamics setObject:anObject forKey:aKey];
    } else {
        [_dynamics removeObjectForKey:aKey];
    }
}

- (id)objectForDynamicKey:(id)aKey
{
    id value = [_dynamics objectForKey:aKey];
    if (value == nil && [aKey isEqualToString:self.table.columns.primarykey.name]) {
        value = self.identifier.uuid;
        [self setObject:value forDynamicKey:aKey];
    }
    return value;
}

- (void)setArray:(NSArray *)anObject forDynamicKey:(NSString *)aKey arrayClass:(Class)arrayClass itemClass:(Class)itemClass
{
    if (itemClass == Nil) itemClass = get_item_class([self class], aKey);
    NSString *name = [aKey componentsSeparatedByString:@"__"][0];

    Class throughClass = get_through_class([self class], name);

    WLFArrayProxy *proxy = [_references[itemClass] proxyForKey:name throughClass:throughClass];
    [proxy removeAll];
    for (WLFEntity *entity in anObject) {
        [proxy add:entity];
    }
}

- (id)arrayForDynamicKey:(NSString *)aKey arrayClass:(Class)arrayClass itemClass:(Class)itemClass
{
    if (itemClass == Nil) itemClass = get_item_class([self class], aKey);
    NSString *name = [aKey componentsSeparatedByString:@"__"][0];
    Class throughClass = get_through_class([self class], name);

    WLFArrayProxy *proxy = [_references[itemClass] proxyForKey:name throughClass:throughClass];
    return proxy;
}

- (void)setDynamicObject:(id)anObject forDynamicKey:(NSString *)aKey dynamicClass:(Class)dynamicClass
{
    WLFReferenceKey *refKey = self.table.references[aKey];
    if (refKey) {
        WLFEntity *entity = anObject;
        WLFArrayProxy *proxy = [_references[dynamicClass] proxyForKey:aKey throughClass:Nil];
        WLFEntity *prevEntity = [self dynamicObjectForDynamicKey:aKey dynamicClass:dynamicClass];

        if (entity == nil || ![entity isEqual:prevEntity]) {
            [self setObject:[entity objectForDynamicKey:refKey.to] forDynamicKey:refKey.from];
            [proxy remove:prevEntity];
            [proxy add:entity];
        }
    }
}

- (id)dynamicObjectForDynamicKey:(NSString *)aKey dynamicClass:(Class)dynamicClass
{
    WLFReferenceKey *refKey = self.table.references[aKey];
    if (refKey) {
        NSString *tableName = [dynamicClass tableName].lowercaseString;
        NSParameterAssert([refKey.table.name isEqualToString:tableName]);
        id refId = [self objectForDynamicKey:refKey.from];
        if (refId) {
            WLFEntityIdentifier *identifier = [WLFEntityIdentifier identifierWithUUID:refId];
            WLFEntity *entity = [WLFRepository entityWithClass:dynamicClass identifier:identifier];
            WLFArrayProxy *proxy = [_references[dynamicClass] proxyForKey:aKey throughClass:Nil];
            [proxy add:entity];
            return entity;
        }
    }
    return nil;
}

- (void)setCache:(id)obj forKey:(NSString *)aKey
{

}

@end

@implementation WLFEntity (WLFRepository)

+ (instancetype)entity
{
    return [WLFRepository entityWithClass:[self class]];
}

+ (instancetype)entity:(WLFEntityIdentifier *)identifier
{
    return [self entity:identifier values:nil];
}

+ (instancetype)entity:(WLFEntityIdentifier *)identifier values:(NSDictionary *)values
{
    return [WLFRepository entityWithClass:[self class]
                               identifier:identifier
                                   values:values];
}

+ (NSArray *)entityAll
{
//    NSLog(@"%@", [WLFRepository entities]);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_type = %@", NSStringFromClass(self)];
    return [[WLFRepository entities].allValues filteredArrayUsingPredicate:predicate];
}

@end



@implementation WLFEntity (WLFTable)

+ (NSString *)tableName
{
    NSAssert(NO, @"");
    return nil;
}

- (WLFTable *)table
{
    return [WLFTable tableWithName:[[self class] tableName]];
}

+ (WLFTable *)table
{
    return [WLFTable tableWithName:[self tableName]];
}

- (id)primarykey
{
    return [self objectForDynamicKey:self.table.columns.primarykey.name];
}

- (id)objectForReverse:(WLFTable *)table key:(NSString *)revKey
{
    revKey = [revKey componentsSeparatedByString:@"_id"][0];
    NSString *tableName = table.name.lowercaseString;
    NSString *aKey = self.table.reverses[tableName][revKey].to;
    return [self objectForDynamicKey:aKey];
}

- (void)setObject:(id)anObject forReverse:(WLFTable *)table key:(NSString *)revKey
{
    NSString *tableName = table.name.lowercaseString;
    NSString *aKey = self.table.reverses[tableName][revKey].to;
    [self setObject:anObject forDynamicKey:aKey];
}

@end


@implementation WLFEntity (WLFEntity)

- (id)objectForKey:(NSString *)aKey
{
    return [self objectForDynamicKey:aKey];
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey
{
    [self setObject:anObject forDynamicKey:aKey];
}

- (id)valueForKey:(NSString *)key
{
    if ([self.table.columns containsKey:key]) {
        return [self objectForKey:key];
    }
    return [super valueForKey:key];
}

@end


