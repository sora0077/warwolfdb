//
//  WLFColumnKey.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFColumnKey.h"

@implementation WLFColumnKey

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _defaultValue = [self parseDefaultValue:dict[@"dflt_value"]];
        _name = dict[@"name"];
        _type = dict[@"type"];
        _primary = [dict[@"pk"] boolValue];
        _notnull = [dict[@"notnull"] boolValue];
    }
    return self;
}

- (id)parseDefaultValue:(id)val
{
    if (val == [NSNull null]) {
        return nil;
    }
    return val;
}

@end
