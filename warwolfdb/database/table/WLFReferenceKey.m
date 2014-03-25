//
//  WLFReferenceKey.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFReferenceKey.h"
#import "WLFRepository.h"

@implementation WLFReferenceKey
{
    NSString *_tableName;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _from = dict[@"from"];
        _to = dict[@"to"];
        _tableName = dict[@"table"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: from:%@, to:%@, table:%@>", NSStringFromClass([self class]), _from, _to, self.table];
}

- (WLFTable *)table
{
    return [WLFRepository tableWithName:_tableName];
}

@end
