//
//  Book.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFEntity.h"
#import <Objective-C-Generics/ObjectiveCGenerics.h>

GENERICSABLE(User);

@class User;
@interface Book : WLFEntity


@property (nonatomic) User *auther;
@end
