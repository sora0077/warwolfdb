//
//  WLFColumnKey.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLFColumnKey : NSObject

@property (nonatomic, readonly) id defaultValue;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) BOOL primary;
@property (nonatomic, readonly) BOOL notnull;


- (id)initWithDictionary:(NSDictionary *)dict;

@end
