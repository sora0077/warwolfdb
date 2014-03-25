//
//  WLFTableReferences.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WLFReferenceKey;
@interface WLFTableReferences : NSObject <NSFastEnumeration>

- (WLFReferenceKey *)objectForKeyedSubscript:(id)key;

@end
