//
//  WLFDatabase+Internal.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/14.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFDatabase.h"

@interface WLFDatabase (Internal)

+ (void)setTransactionDB:(id)transactionDB;
+ (id)transactionDB;

+ (void)setNormalDB:(id)normalDB;
+ (id)normalDB;

@end
