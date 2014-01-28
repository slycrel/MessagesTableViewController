//
//  JSMessageWithImages.m
//  JSMessagesDemo
//
//  Created by Jeremy Stone on 1/28/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSMessageWithImages.h"

@implementation JSMessageWithImages

- (instancetype)initWithText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date mediaURL:(NSURL *)mediaURL
{
    self = [super initWithText:text sender:sender date:date];
    if (self)
    {
        self.mediaURL = mediaURL;
    }
    
    return self;
}

@end
