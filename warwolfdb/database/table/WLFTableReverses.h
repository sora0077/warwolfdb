//
//  WLFTableReverses.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/18.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFTable, WLFReferenceKey;
@class WLFTableReferences;
@interface WLFTableReverses : NSObject

- (void)addReference:(WLFReferenceKey *)reference fromTable:(WLFTable *)table;

- (WLFTableReferences *)objectForKeyedSubscript:(id)key;
@end
