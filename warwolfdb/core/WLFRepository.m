//
//  WLFRepository.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFRepository.h"
#import "WLFEntity.h"
#import "WLFEntityIdentifier.h"

#import "WLFTable.h"

//#define TEST 1

@interface WLFEntity (WLFRepository)
@property (nonatomic, readonly) BOOL _expire;
@end

@interface WLFRepository ()
#ifdef TEST
@property (nonatomic, readonly) NSMapTable *entities;
//@property (nonatomic, readonly) NSMutableDictionary *entities;
#else
@property (nonatomic, readonly) NSMutableDictionary *entities;
#endif
@property (nonatomic, readonly) NSMutableDictionary *tables;
@end

@implementation WLFRepository
{
    NSMutableDictionary *_tables;
//    NSMutableDictionary *_entities;
}

+ (instancetype)sharedRepository
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {

#ifdef TEST
        _entities = [NSMapTable strongToWeakObjectsMapTable];
//        _entities = @{}.mutableCopy;
#else
        _entities = @{}.mutableCopy;
#endif
        _tables = @{}.mutableCopy;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finalizeEntityState:)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finalizeEntityState:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)finalizeEntityState:(NSNotification *)notification
{
#ifdef TEST
    for (NSString *aKey in _entities) {
#else
    for (NSString *aKey in _entities.allKeys) {
#endif
        __weak WLFEntity *obj;
        @autoreleasepool {
            obj = [_entities objectForKey:aKey];
            [obj sync];
            [_entities removeObjectForKey:aKey];
        }
        if (obj && !obj._expire) {
            __strong id sobj = obj;
            [_entities setObject:sobj forKey:aKey];
        }
    }
}

+ (WLFEntity *)entityWithClass:(Class)class
{
    WLFEntityIdentifier *identifier = [WLFEntityIdentifier identifier];
    return [self entityWithClass:class identifier:identifier];
}

+ (WLFEntity *)entityWithClass:(Class)class identifier:(WLFEntityIdentifier *)identifier
{
    return [self entityWithClass:class identifier:identifier values:nil];
}

+ (WLFEntity *)entityWithClass:(Class)class identifier:(WLFEntityIdentifier *)identifier values:(NSDictionary *)values
{
    WLFEntity *entity = [[[self sharedRepository] entities] objectForKey:identifier];
    if (entity == nil) {
        entity = [[class alloc] initWithIdentifier:identifier values:values];
        [[[self sharedRepository] entities] setObject:entity
                                               forKey:identifier];
    }
    return entity;
}

+ (WLFTable *)tableWithName:(NSString *)tableName
{
    NSParameterAssert(tableName);
    tableName = tableName.lowercaseString;
    WLFTable *table = [[self sharedRepository] tables][tableName];
    if (table == nil) {
        table = [[WLFTable alloc] initWithName:tableName];
        [[self sharedRepository] tables][tableName] = table;

        [table setupRelations];

        NSLog(@"%@", [[self sharedRepository] tables]);
    }
    return table;
}

@end


//#ifdef TEST

@implementation WLFRepository (TestCase)

+ (void)sync
{
    [[self sharedRepository] finalizeEntityState:nil];
}

+ (id)entities
{
    id entities = [[self sharedRepository] entities];
    if ([entities isKindOfClass:[NSMapTable class]]) {
        entities = [entities dictionaryRepresentation];
    }
    return entities;
}

@end

//#endif
