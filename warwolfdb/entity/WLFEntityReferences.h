//
//  WLFEntityReferences.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/23.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFEntity, WLFEntityReferenceKey;
@interface WLFEntityReferences : NSObject

- (id)initWithOwner:(WLFEntity *)owner;

- (WLFEntityReferenceKey *)objectForKeyedSubscript:(id)key;

@end

@class WLFArrayProxy;
@interface WLFEntityReferenceKey : NSObject

- (WLFArrayProxy *)proxyForKey:(id)key throughClass:(Class)throughClass;

@end
