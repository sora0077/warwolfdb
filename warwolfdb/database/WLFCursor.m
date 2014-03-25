//
//  WLFCursor.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/13.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFCursor.h"
#import "WLFCursor+Internal.h"
#import <FMDB/FMResultSet.h>

@implementation WLFCursor
{
    FMResultSet *_resultSet;
}

- (id)initWithResultSet:(id)resultSet
{
    self = [super init];
    if (self) {
        _resultSet = resultSet;
    }
    return self;
}

- (void)dealloc
{
    [self close];
}

- (BOOL)next
{
    return _resultSet.next;
}

- (NSDictionary *)result
{
    return _resultSet.resultDictionary;
}

- (void)close
{
    [_resultSet close];
}

@end
