//
//  WLFTableColumns.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFTableColumns.h"
#import "WLFTableColumns+Internal.h"
#import "WLFColumnKey.h"

@implementation WLFTableColumns
{
    WLFColumnKey *_primarykey;
    NSMutableDictionary *_columns;
}

- (id)init
{
    self = [super init];
    if (self) {
        _columns = @{}.mutableCopy;
    }
    return self;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    return [_columns.allValues countByEnumeratingWithState:state objects:buffer count:len];
}

- (WLFColumnKey *)objectForKeyedSubscript:(id)key
{
    return [_columns objectForKeyedSubscript:key];
}

- (BOOL)containsKey:(NSString *)aKey
{
    return [_columns objectForKey:aKey] != nil;
}

- (void)addColumn:(WLFColumnKey *)columnkey
{
    if (columnkey.primary) {
        _primarykey = columnkey;
    }
    [_columns setObject:columnkey forKey:columnkey.name];
}

@end
