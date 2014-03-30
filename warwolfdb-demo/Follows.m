//
//  Follows.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/26.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "Follows.h"

@implementation Follows
@dynamic following_user, follower_user;

+ (NSString *)tableName
{
    return @"Follows";
}


@end
