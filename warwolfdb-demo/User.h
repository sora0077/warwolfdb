//
//  User.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFEntity.h"
#import <Objective-C-Generics/ObjectiveCGenerics.h>

GENERICSABLE(Book);
GENERICSABLE(User);

@interface User : WLFEntity

@property (nonatomic) NSArray<User> *followings;
@property (nonatomic) NSArray<User> *followers;

@property (nonatomic) NSArray<Book> *auther__books;


@property (nonatomic) BOOL test;

@end
