//
//  WLFArray.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/25.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFEntity;
@interface WLFArray : NSArray

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (NSUInteger)fetchedCount;

#
- (void)add:(WLFEntity *)entity;
- (void)remove:(WLFEntity *)entity;

#

- (BOOL)fetch;
//- (BOOL)fetchBy;

@end

@interface NSArray (WLFArrayDummy)

- (NSUInteger)fetchedCount;

#
- (void)add:(WLFEntity *)entity;
- (void)remove:(WLFEntity *)entity;

#

- (BOOL)fetch;
@end
