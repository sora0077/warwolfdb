//
//  WLFTableReverses.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/18.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFTableReverses.h"
#import "WLFTable.h"
#import "WLFTableReferences.h"
#import "WLFTableReferences+Internal.h"
#import "WLFReferenceKey.h"
#import "WLFRepository.h"

@implementation WLFTableReverses
{
    NSMutableDictionary *_reverses;
}

- (id)init
{
    self = [super init];
    if (self) {
        _reverses = @{}.mutableCopy;
    }
    return self;
}

- (NSString *)description
{
    return [[[_reverses description] stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n    "] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

- (void)addReference:(WLFReferenceKey *)reference fromTable:(WLFTable *)table
{
    WLFTableReferences *tables = _reverses[table.name.lowercaseString];
    if (tables == nil) {
        tables = [[WLFTableReferences alloc] init];
        _reverses[table.name.lowercaseString] = tables;
    }
    [tables addReference:reference];
}

- (WLFTableReferences *)objectForKeyedSubscript:(id)key
{
    [WLFRepository tableWithName:key];
    return [_reverses objectForKeyedSubscript:[key lowercaseString]];
}

@end
