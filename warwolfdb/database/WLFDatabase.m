//
//  WLFDatabase.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/13.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFDatabase.h"
#import "WLFDatabase+Internal.h"
#import "WLFCursor+Internal.h"
#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseQueue.h>

static id _transactionDB, _normalDB;

@interface WLFDatabase ()
@property (nonatomic) FMDatabaseQueue *queue;
@end

@implementation WLFDatabase
{
}

+ (WLFDatabase *)sharedDatabase
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

    }
    return self;
}

+ (void)setTransactionDB:(id)transactionDB
{
    _transactionDB = transactionDB;
}

+ (id)transactionDB
{
    return _transactionDB;
}

+ (void)setNormalDB:(id)normalDB
{
    _normalDB = normalDB;
}

+ (id)normalDB
{
    return _normalDB;
}

+ (BOOL)connect:(NSURL *)fileURL
{
    WLFDatabase *database = [WLFDatabase sharedDatabase];
    database.queue = [FMDatabaseQueue databaseQueueWithPath:fileURL.path];
    return YES;
}

+ (void)inTransaction:(void (^)())block
{
    if ([WLFDatabase transactionDB]) {
        block();
    } else {
        [[self sharedDatabase].queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [self setTransactionDB:db];
            @try {
                block();
            }
            @catch (NSException *exception) {
                *rollback = YES;
            }
            @finally {
                [self setTransactionDB:nil];
            }
        }];
    }
}

+ (id)findSQL:(NSString *)sql process:(id (^)(WLFCursor *))process
{
    return [self findSQL:sql args:nil process:process];
}

+ (id)findSQL:(NSString *)sql args:(NSDictionary *)args process:(id (^)(WLFCursor *))process
{
    __block id ret;
    void (^block)(FMDatabase *) = ^(FMDatabase *db) {
        WLFCursor *cursor = ({
            FMResultSet *resultSet = [db executeQuery:sql withParameterDictionary:args];

            [[WLFCursor alloc] initWithResultSet:resultSet];
        });
        ret = process(cursor);
    };
    FMDatabase *db = [WLFDatabase transactionDB] ?: [WLFDatabase normalDB];
    if (db) {
        block(db);
    } else {
        [[self sharedDatabase].queue inDatabase:^(FMDatabase *db) {
            [self setNormalDB:db];
            block(db);
            [self setNormalDB:nil];
        }];
    }
    return ret;
}

+ (BOOL)executeSQL:(NSString *)sql
{
    return [self executeSQL:sql args:nil];
}

+ (BOOL)executeSQL:(NSString *)sql args:(NSDictionary *)args
{
    __block BOOL ret = NO;
    void (^block)(FMDatabase *) = ^(FMDatabase *db) {
        ret = [db executeUpdate:sql withParameterDictionary:args];
    };
    FMDatabase *db = [WLFDatabase transactionDB] ?: [WLFDatabase normalDB];
    if (db) {
        block(db);
    } else {
        [[self sharedDatabase].queue inDatabase:^(FMDatabase *db) {
            [self setNormalDB:db];
            block(db);
            [self setNormalDB:nil];
        }];
    }
    return ret;
}

@end
