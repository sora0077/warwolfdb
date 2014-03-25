//
//  WLFEntityIdentifier.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/10.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLFEntityIdentifier : NSObject <NSCopying>

+ (instancetype)identifier;
+ (instancetype)identifierWithUUID:(NSString *)uuid;

@property (nonatomic, readonly) NSString *uuid;
@property (nonatomic, readonly) BOOL exists;

@end
