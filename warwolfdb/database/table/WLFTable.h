//
//  WLFTable.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/12.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFColumnKey, WLFReferenceKey;
@class WLFTableColumns, WLFTableReferences, WLFTableReverses;
@interface WLFTable : NSObject
+ (instancetype)tableWithName:(NSString *)tableName;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) WLFTableColumns *columns;
@property (nonatomic, readonly) WLFTableReferences *references;
@property (nonatomic, readonly) WLFTableReverses *reverses;

- (id)initWithName:(NSString *)tableName;
- (void)setupRelations;

@end
