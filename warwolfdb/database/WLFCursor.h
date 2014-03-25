//
//  WLFCursor.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/13.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLFCursor : NSObject
- (BOOL)next;
- (NSDictionary *)result;
- (void)close;
@end
