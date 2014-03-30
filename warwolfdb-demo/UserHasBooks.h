//
//  UserHasBooks.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/18.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFEntity.h"

@class User, Book;
@interface UserHasBooks : WLFEntity
@property (nonatomic) User *user;
@property (nonatomic) Book *book;
@end
