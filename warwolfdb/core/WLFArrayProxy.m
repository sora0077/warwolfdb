//
//  WLFArrayProxy.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFArrayProxy.h"
#import "WLFEntity.h"
#import "WLFEntityIdentifier.h"

@implementation WLFArrayProxy
{
    NSString *_key;
    NSMutableOrderedSet *_array;
    __weak WLFEntity *_owner;
    Class _itemClass;
}

- (id)initWithArray:(NSArray *)array itemClass:(__unsafe_unretained Class)itemClass owner:(WLFEntity *)owner key:(NSString *)key
{
    self = [super init];
    if (self) {
        NSLog(@"%s %@", __func__, owner);
        NSMutableArray *skeltonArray = @[].mutableCopy;
        for (WLFEntity *entity in array) {
            [skeltonArray addObject:entity.symbolize];
        }
        _array = [NSMutableOrderedSet orderedSetWithArray:skeltonArray];
        _itemClass = itemClass;
        _owner = owner;
        _key = key;
    }
    return self;
}

- (void)dealloc
{
    
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

- (NSArray *)array
{
    return [_array array];
}

- (void)add:(WLFEntity *)entity
{
    [_array addObject:entity.symbolize];
}

- (void)remove:(WLFEntity *)entity
{
    [_array removeObject:entity.symbolize];
}

@end
