//
//  WLFTableReferences+Internal.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFTableReferences.h"

@class WLFReferenceKey;
@interface WLFTableReferences (Internal)

- (void)addReference:(WLFReferenceKey *)referencekey;

@end
