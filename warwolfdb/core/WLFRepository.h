//
//  WLFRepository.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFEntity, WLFEntityIdentifier;
@class WLFTable;
@interface WLFRepository : NSObject

+ (WLFEntity *)entityWithClass:(Class)class;
+ (WLFEntity *)entityWithClass:(Class)class identifier:(WLFEntityIdentifier *)identifier;
+ (WLFEntity *)entityWithClass:(Class)class identifier:(WLFEntityIdentifier *)identifier values:(NSDictionary *)values;

+ (WLFTable *)tableWithName:(NSString *)tableName;

@end

#ifdef TEST
@interface WLFRepository (TestCase)
+ (NSDictionary *)entities;
@end
#endif