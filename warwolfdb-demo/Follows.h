//
//  Follows.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/26.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFEntity.h"
#import "User.h"

@interface Follows : WLFEntity

@property (nonatomic) User *following_user;
@property (nonatomic) User *follower_user;

@end
