//
//  WLFEntity.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/10.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFDynamicObject.h"

@class WLFEntityIdentifier;

/**
 *  _WLFEntity
 */
@interface _WLFEntity : WLFDynamicObject
@property (nonatomic, readonly) WLFEntityIdentifier *identifier;
@property (nonatomic, readonly) Class entityClass;
- (id)instantiate;
@end


/**
 *  WLFEntity
 */
@interface WLFEntity : _WLFEntity
@property (nonatomic, readonly) BOOL dirty;

- (id)init __attribute__((unavailable("initWithIdentifier")));
- (id)initWithIdentifier:(WLFEntityIdentifier *)identifier;
- (id)initWithIdentifier:(WLFEntityIdentifier *)identifier values:(NSDictionary *)values;


- (id)symbolize;

- (void)save;
- (void)delete;

- (void)sync;

@end

@interface WLFEntity (WLFRepository)
+ (instancetype)entity;
+ (instancetype)entity:(WLFEntityIdentifier *)identifier;
+ (instancetype)entity:(WLFEntityIdentifier *)identifier values:(NSDictionary *)values;

+ (NSArray *)entityAll;
+ (NSArray *)find:(NSString *)key value:(id)value;

@end


@class WLFTable;
@interface WLFEntity (WLFTable)
+ (NSString *)tableName;
+ (WLFTable *)table;

@property (nonatomic, readonly) WLFTable *table;
@property (nonatomic, readonly) id primarykey;

- (id)objectForReverse:(WLFTable *)table key:(NSString *)revKey;
- (void)setObject:(id)anObject forReverse:(WLFTable *)table key:(NSString *)revKey;

@end


@interface WLFEntity (WLFEntity)

- (void)setObject:(id)anObject forKey:(NSString *)aKey;
- (id)objectForKey:(NSString *)aKey;

@end


@interface NSArray (WLFEntity)
- (BOOL)save;
- (void)add:(WLFEntity *)anObject;
- (void)remove:(WLFEntity *)anObject;

- (NSArray *)wlf_map:(id (^)(id val))block;

@end
