//
//  WLFEntityReferences.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/23.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFEntityReferences.h"
#import "WLFEntity.h"
#import "WLFArrayProxy.h"

@interface WLFEntityReferenceKey ()

- (id)initWithOwner:(WLFEntity *)owner itemClass:(Class)class;
@end

@implementation WLFEntityReferences
{
    __weak WLFEntity *_owner;
    NSMutableDictionary *_references;
}

- (id)initWithOwner:(WLFEntity *)owner
{
    self = [super init];
    if (self) {
        _owner = owner;
        _references = @{}.mutableCopy;
    }
    return self;
}

- (WLFEntityReferenceKey *)objectForKeyedSubscript:(Class)class
{
    NSString *key = NSStringFromClass(class);
    WLFEntityReferenceKey *relations = _references[key];
    if (relations == nil) {
        relations = [[WLFEntityReferenceKey alloc] initWithOwner:_owner itemClass:class];
        _references[key] = relations;
    }
    return relations;
}

@end

@implementation WLFEntityReferenceKey
{
    __weak WLFEntity *_owner;
    Class _itemClass;
    NSMutableDictionary *_reference;
}

- (id)initWithOwner:(WLFEntity *)owner itemClass:(Class)class
{
    self = [super init];
    if (self) {
        _owner = owner;
        _itemClass = class;
        _reference = @{}.mutableCopy;
    }
    return self;
}

- (WLFArrayProxy *)objectForKeyedSubscript:(id)key
{
    WLFArrayProxy *proxy = _reference[key];
    if (proxy == nil) {
        proxy = [[WLFArrayProxy alloc] initWithArray:nil itemClass:_itemClass owner:_owner key:key];
        _reference[key] = proxy;
    }
    return proxy;
}

@end

