//
//  UserHasBooks.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/18.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "UserHasBooks.h"

@implementation UserHasBooks
@dynamic user, book;

+ (NSString *)tableName
{
    return @"User_has_Books";
}

+ (NSString *)booksAgainstProperty
{
    return @"users";
}

+ (NSString *)usersAgainstProperty
{
    return @"books";
}

@end
