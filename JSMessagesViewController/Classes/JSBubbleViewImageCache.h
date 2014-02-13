//
//  JSBubbleViewImageCache.h
//  JSMessagesDemo
//
//  Created by Jeremy Stone on 2/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSMessageData.h"

@class JSMessagesViewController;

typedef void(^JSImageCacheImageLoadCompletionBlock)();


@interface JSBubbleViewImageCache : NSObject

+ (UIImageView *)cachedImageViewWithMessage:(id <JSMessageData>)message completionBlock:(JSImageCacheImageLoadCompletionBlock)completion;
+ (void)clearImageCache;

@end
