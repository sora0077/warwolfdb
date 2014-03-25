//
//  User.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "User.h"

@implementation User
@dynamic auther__books, books;
@dynamic test;

+ (NSString *)tableName
{
    return @"User";
}

+ (Class)booksThroughClass
{
    return NSClassFromString(@"UserHasBooks");
}

@end
