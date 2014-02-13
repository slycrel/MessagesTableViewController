//
//  JSMessageWithImages.m
//  JSMessagesDemo
//
//  Created by Jeremy Stone on 1/28/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSMessageWithImages.h"
#import "JSDemoViewController.h"    // for #define constants


static NSMutableDictionary *mediaData;

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


// Implement to have a thumbnail view for a given message
//- (UIImageView *)thumbnailImageView
//{
//    // lazy init our storage
//    if (!mediaData)
//        mediaData = [NSMutableDictionary dictionary];
//    
//    // simple caching of media URL data.  This can, and likely should, be improved within your own app.
//    if (self.mediaURL)
//    {
//        UIImageView* imageView = [mediaData objectForKey:[self.mediaURL absoluteString]];
//        if (!imageView)
//        {
//            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.mediaURL]];
//            imageView = [[UIImageView alloc] initWithImage:image];
//            imageView.contentMode = UIViewContentModeScaleToFill;
//            [mediaData setObject:imageView forKey:[self.mediaURL absoluteString]];
//        }
//        
//        if (imageView)
//        {
//            if (self.callback)
//                self.callback(self.parentController, imageView);
//            return imageView;
//        }
//    }
//    
//    return nil;
//}


@end
