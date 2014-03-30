//
//  WLFArrayProxy.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFArrayProxy.h"
#import <objc/message.h>
#import "WLFTable.h"
#import "WLFEntity.h"
#import "WLFEntityIdentifier.h"

@interface WLFEntity (WLFArrayProxy)

- (void)setRelatedEntity:(WLFEntity *)entity forKey:(NSString *)key;
- (void)removeRelatedEntity:(WLFEntity *)entity forKey:(NSString *)key;
@end

@implementation WLFArrayProxy
{
    NSString *_key;
    NSMutableOrderedSet *_array;
    NSMutableDictionary *_throughs;
    __weak WLFEntity *_owner;
    Class _itemClass, _throughClass;
}

- (id)initWithItemClass:(Class)itemClass throughClass:(Class)throughClass owner:(WLFEntity *)owner key:(NSString *)key
{
    self = [super init];
    if (self) {
        NSLog(@"%s %@", __func__, owner);
        _array = [NSMutableOrderedSet orderedSet];
        _itemClass = itemClass;
        _throughClass = throughClass;
        _owner = owner;
        _key = key;
    }
    return self;
}

- (void)dealloc
{
    
}

- (NSMutableDictionary *)throughs
{
    if (_throughs == nil) {
        _throughs = @{}.mutableCopy;
    }
    return _throughs;
}

- (NSUInteger)count
{
    return _array.count;
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [[_array objectAtIndex:index] instantiate];
}

- (NSString *)description
{
    return [_array description];
}

- (void)add:(WLFEntity *)entity
{
    id symbol = entity.symbolize;
    if (entity == nil || [_array containsObject:symbol]) return;

    NSString *name = _key;
    if (_throughClass) {
        NSString *usingKey = ({
            NSString *usingKey = [_key stringByAppendingString:@"UsingKey"];
            usingKey = objc_msgSend(_owner.class, NSSelectorFromString(usingKey));
            usingKey;
        });
        NSString *watchKey = ({
            NSString *watchKey = [_key stringByAppendingString:@"WatchKey"];
            watchKey = objc_msgSend(_owner.class, NSSelectorFromString(watchKey));
            watchKey;
        });
        WLFTable *table = [_throughClass table];
        id usingValue = [_owner objectForReverse:table key:usingKey];
        id watchValue = [entity objectForReverse:table key:watchKey];

        NSParameterAssert(usingValue);
        NSParameterAssert(watchValue);

        WLFEntity *t_entity = [_throughs[entity.identifier] instantiate] ?: [_throughClass entity];
        [t_entity setObject:usingValue forKey:usingKey];
        [t_entity setObject:watchValue forKey:watchKey];

        [self.throughs setObject:t_entity.symbolize forKey:entity.identifier];
        name = objc_msgSend([_owner class], NSSelectorFromString([name stringByAppendingString:@"Against"]));
    }
    [_array addObject:symbol];
    [entity setRelatedEntity:_owner forKey:name];
}

- (void)remove:(WLFEntity *)entity
{
    id symbol = entity.symbolize;
    if (entity == nil || ![_array containsObject:symbol]) return;

    NSString *name = _key;
    if (_throughClass) {
        WLFEntity *t_entity = [_throughs[entity.identifier] instantiate] ?: [_throughClass entity];
        [t_entity delete];
        [_throughs removeObjectForKey:entity.identifier];
        name = objc_msgSend([_owner class], NSSelectorFromString([name stringByAppendingString:@"Against"]));
    }
    [_array removeObject:symbol];
    [entity removeRelatedEntity:_owner forKey:name];
}

- (void)removeAll
{
    for (WLFEntity *entity in self) {
        [entity removeRelatedEntity:_owner forKey:_key];
        [self remove:entity];
    }
}

@end
