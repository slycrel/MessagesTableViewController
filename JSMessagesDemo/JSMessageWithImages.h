//
//  JSMessageWithImages.h
//  JSMessagesDemo
//
//  Created by Jeremy Stone on 1/28/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessage.h"

@class JSDemoViewController;

typedef void(^JSMessageWithImagesCachedImageCallback)(JSDemoViewController *controller, UIImageView* imageView);


@interface JSMessageWithImages : JSMessage <JSMessageData>

@property (strong, nonatomic) NSURL *mediaURL;
@property (strong, nonatomic) JSMessageWithImagesCachedImageCallback callback;
@property (strong, nonatomic) JSDemoViewController *parentController;

- (instancetype)initWithText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date mediaURL:(NSURL *)mediaURL;
- (UIImageView *)thumbnailImageView;

@end
