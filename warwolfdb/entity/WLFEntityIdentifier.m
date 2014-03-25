//
//  WLFEntityIdentifier.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/10.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFEntityIdentifier.h"

@implementation WLFEntityIdentifier
{
    NSString *_uuid;
    BOOL _exists;
}

+ (instancetype)identifier
{
    WLFEntityIdentifier *identifier = [[self alloc] init];
    identifier->_exists = NO;

    return identifier;
}

+ (instancetype)identifierWithUUID:(NSString *)uuid
{
    WLFEntityIdentifier *identifier = [[self alloc] initWithUUID:uuid];
    return identifier;
}

- (id)initWithUUID:(NSString *)uuid
{
    self = [super init];
    if (self) {
        _uuid = uuid;
        _exists = uuid ? YES : NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id clone = [[[self class] allocWithZone:zone] initWithUUID:self.uuid];
    return clone;
}

- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        if ([self isKindOfClass:[object class]]) {
            return [_uuid isEqualToString:[object uuid]];
        }
        return NO;
    }
    return YES;
}

- (NSUInteger)hash
{
    return [self.uuid hash];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@>", NSStringFromClass([self class]), _uuid];
}

- (NSString *)uuid
{
    if (!_uuid) {
        _uuid = [[NSUUID UUID] UUIDString];
    }
    return _uuid;
}

@end
