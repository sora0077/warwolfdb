//
//  WLFArrayProxy.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/11.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFEntity, WLFEntityIdentifier;
@interface WLFArrayProxy : NSArray <NSFastEnumeration>

@property (nonatomic, readonly) WLFEntity *owner;
@property (nonatomic, readonly) NSString *key;

- (id)initWithItemClass:(Class)itemClass throughClass:(Class)throughClass owner:(WLFEntity *)owner key:(NSString *)key;

- (NSUInteger)count;
- (id)objectAtIndex:(NSUInteger)index;

- (void)add:(WLFEntity *)anObject;
- (void)remove:(WLFEntity *)anObject;

- (void)removeAll;

@end


//@interface WLFArrayProxy (WLFEntity)
//- (BOOL)save;
//@end

