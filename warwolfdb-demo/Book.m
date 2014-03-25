//
//  Book.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "Book.h"

@implementation Book
@dynamic auther;

+ (NSString *)tableName
{
    return @"Book";
}

@end
