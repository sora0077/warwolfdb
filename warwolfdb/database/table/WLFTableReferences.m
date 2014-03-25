//
//  WLFTableReferences.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFTableReferences.h"
#import "WLFTableReferences+Internal.h"
#import "WLFReferenceKey.h"


@implementation WLFTableReferences
{
    NSMutableDictionary *_references;
}

- (id)init
{
    self = [super init];
    if (self) {
        _references = @{}.mutableCopy;
    }
    return self;
}

- (NSString *)description
{
    return [_references description];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    return [_references.allValues countByEnumeratingWithState:state objects:buffer count:len];
}

- (WLFReferenceKey *)objectForKeyedSubscript:(id)key
{
    return [_references objectForKeyedSubscript:key];
}

- (void)addReference:(WLFReferenceKey *)referencekey
{
    NSString *key = [referencekey.from componentsSeparatedByString:@"_id"][0];
    [_references setObject:referencekey forKey:key];
}

@end
