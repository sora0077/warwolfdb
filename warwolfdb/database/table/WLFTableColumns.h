//
//  WLFTableColumns.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFColumnKey;
@interface WLFTableColumns : NSObject <NSFastEnumeration>

@property (nonatomic, readonly) WLFColumnKey *primarykey;

- (WLFColumnKey *)objectForKeyedSubscript:(id)key;

- (BOOL)containsKey:(NSString *)aKey;

@end
