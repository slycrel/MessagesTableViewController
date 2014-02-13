//
//  JSBubbleViewImageCache.m
//  JSMessagesDemo
//
//  Created by Jeremy Stone on 2/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSBubbleViewImageCache.h"
#import <SDWebImage/UIImageView+WebCache.h>


@import MobileCoreServices;

#define kJSImageDefaultRect         CGRectMake(0, 0, 150, 150)
#define kPlaceholderSubviewTag      999

static NSMutableDictionary *imageCache;


@implementation JSBubbleViewImageCache

+ (UIImageView *)placeholder
{
    UIGraphicsBeginImageContext(CGSizeMake(150, 150));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextFillRect(context, kJSImageDefaultRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    return imageView;
}

+ (void)clearImageCache
{
    [imageCache removeAllObjects];
}


+ (UIImageView *)cachedImageViewWithKey:(NSString *)key
{
    // lazy load the image view cache dictionary.
    if (!imageCache)
        imageCache = [NSMutableDictionary dictionary];

    // get or create the image view
    UIImageView *imageView = [imageCache objectForKey:key];
    if (!imageView)
    {
        // if it doesn't exist, create it and add a placeholder view on it.
        imageView = [[UIImageView alloc] initWithFrame:kJSImageDefaultRect];
        UIImageView *placeholder = [JSBubbleViewImageCache placeholder];
        placeholder.tag = kPlaceholderSubviewTag;
        [imageView addSubview:placeholder];

        // remember this image view
        [imageCache setObject:imageView forKey:key];
    }
    
    return imageView;
}


+ (NSString *)imageKey:(id<JSMessageData>)message
{
    NSAssert([message respondsToSelector:@selector(mediaURL)], @"Unexpectedly trying to key an image on an unsupported message type!");
    return [NSString stringWithFormat:@"%@_%lu", [[message mediaURL] absoluteString], [message hash]];
}


+ (UIImageView *)cachedImageViewWithMessage:(id <JSMessageData>)message completionBlock:(JSImageCacheImageLoadCompletionBlock)completion
{
    NSAssert([message respondsToSelector:@selector(mediaURL)], @"Unexpectedly trying to cache an image on an unsupported message type!");
    NSURL* url = [message mediaURL];
    NSString* messageKey = [self imageKey:message];
    
    // get the cached image view
    UIImageView *imageView = [JSBubbleViewImageCache cachedImageViewWithKey:messageKey];
    
    // Check to see if the URL can support an image.
    NSString *type =(__bridge_transfer NSString*)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[[url absoluteString] pathExtension], NULL);
    if (!UTTypeConformsTo((__bridge CFStringRef)type, (__bridge CFStringRef)@"public.image"))
    {
        // if not, return the placeholder image.  We will never go further (yet)
        return imageView;
    }
    
    if (completion && !imageView.image) {
        // set up the image with a placeholder and the passed URL
        [imageView setImageWithURL:url
                  placeholderImage:[self placeholder].image
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             @synchronized(self)
                             {
                                 // update the image
                                 UIImageView *blockImageView = [self cachedImageViewWithKey:messageKey];
                                 blockImageView.image = image;
                                 
                                 // remove the placeholder
                                 [[blockImageView viewWithTag:kPlaceholderSubviewTag] removeFromSuperview];
                                 
                                 // run the completion block
                                 if (completion)
                                     completion();  // refresh the table via the completion block
                             }
                         }];
    }
    
    return imageView;
}


@end
