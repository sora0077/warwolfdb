//
//  User.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "User.h"

@implementation User
@dynamic auther__books;
@dynamic followers, followings;
@dynamic test;

+ (NSString *)tableName
{
    return @"User";
}

+ (Class)followersThroughClass
{
    return NSClassFromString(@"Follows");
}

+ (NSString *)followersUsingKey
{
    return @"following_user_id";
}

+ (NSString *)followersWatchKey
{
    return @"follower_user_id";
}

+ (NSString *)followersAgainst
{
    return @"followings";
}

+ (Class)followingsThroughClass
{
    return NSClassFromString(@"Follows");
}

+ (NSString *)followingsUsingKey
{
    return @"follower_user_id";
}

+ (NSString *)followingsWatchKey
{
    return @"following_user_id";
}

+ (NSString *)followingsAgainst
{
    return @"followers";
}



@end
