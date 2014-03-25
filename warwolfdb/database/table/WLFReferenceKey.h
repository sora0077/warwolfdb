//
//  WLFReferenceKey.h
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/15.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WLFReferenceType){
    WLFReferenceTypeCascade,
    WLFReferenceTypeNullify,
    WLFReferenceTypeNoAction,
};

@class WLFTable;
@interface WLFReferenceKey : NSObject

@property (nonatomic, readonly) NSString *from;
@property (nonatomic, readonly) NSString *to;
@property (nonatomic, readonly) WLFTable *table;

@property (nonatomic, readonly) WLFReferenceType deleteType;
@property (nonatomic, readonly) WLFReferenceType updateType;

- (id)initWithDictionary:(NSDictionary *)dict;


@end
