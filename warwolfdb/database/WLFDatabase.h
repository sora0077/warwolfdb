//
//  WLFDatabase.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/13.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFCursor;
@interface WLFDatabase : NSObject

+ (BOOL)connect:(NSURL *)fileURL;

+ (void)inTransaction:(void (^)())block;
//+ (void)inTransaction:(void (^)())block exception:(NSException **)exception;

+ (id)findSQL:(NSString *)sql process:(id (^)(WLFCursor *))process;
+ (id)findSQL:(NSString *)sql args:(NSDictionary *)args process:(id (^)(WLFCursor *cursor))process;
+ (BOOL)executeSQL:(NSString *)sql;
+ (BOOL)executeSQL:(NSString *)sql args:(NSDictionary *)args;

@end
