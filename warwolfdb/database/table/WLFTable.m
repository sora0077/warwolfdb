//
//  WLFTable.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/12.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFTable.h"
#import "WLFDatabase.h"
#import "WLFCursor.h"

#import "WLFRepository.h"

#import "WLFTableColumns.h"
#import "WLFTableColumns+Internal.h"
#import "WLFColumnKey.h"

#import "WLFTableReferences.h"
#import "WLFTableReferences+Internal.h"
#import "WLFReferenceKey.h"

#import "WLFTableReverses.h"

@implementation WLFTable
{
    NSString *_name;
    WLFTableColumns *_columns;
    WLFTableReferences *_references;
    WLFTableReverses *_reverses;
}

+ (instancetype)tableWithName:(NSString *)tableName
{
    return [WLFRepository tableWithName:tableName];
}

- (id)initWithName:(NSString *)tableName
{
    self = [super init];
    if (self) {
        _name = tableName;

        NSString *sql;
        sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];

        _columns = [[WLFTableColumns alloc] init];
        [WLFDatabase findSQL:sql process:^id(WLFCursor *cursor) {
            while (cursor.next) {
                WLFColumnKey *key = [[WLFColumnKey alloc] initWithDictionary:cursor.result];
                [_columns addColumn:key];
            }
            return nil;
        }];

        sql = [NSString stringWithFormat:@"PRAGMA foreign_key_list(%@)", tableName];

        _references = [[WLFTableReferences alloc] init];
        [WLFDatabase findSQL:sql process:^id(WLFCursor *cursor) {
            while (cursor.next) {
                WLFReferenceKey *key = [[WLFReferenceKey alloc] initWithDictionary:cursor.result];
                [_references addReference:key];
            }
            return nil;
        }];

        _reverses = [[WLFTableReverses alloc] init];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), _name];
}

- (void)setupRelations
{
    for (WLFReferenceKey *key in _references) {
        [key.table.reverses addReference:key fromTable:self];
    }
}

@end
