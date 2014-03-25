//
//  WLFDynamicObject.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/10.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WLFDynamicObject <NSObject>

/**
 *
 **/
- (void)setObject:(id)anObject forDynamicKey:(NSString *)aKey;
- (id)objectForDynamicKey:(NSString *)aKey;

/**
 *
 **/
- (void)setArray:(id)anObject forDynamicKey:(NSString *)aKey arrayClass:(Class)arrayClass itemClass:(Class)itemClass;

- (id)arrayForDynamicKey:(NSString *)aKey arrayClass:(Class)arrayClass itemClass:(Class)itemClass;

/**
 * dynamicClass is subclassed WLFDynamicObject
 **/
- (void)setDynamicObject:(id)anObject forDynamicKey:(NSString *)aKey dynamicClass:(Class)dynamicClass;
- (id)dynamicObjectForDynamicKey:(NSString *)aKey dynamicClass:(Class)dynamicClass;

@end

@interface WLFDynamicObject : NSObject

@end
