//
//  JSBubbleViewImageCache.m
//  JSMessagesDemo
//
//  Created by Jeremy Stone on 2/13/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "JSBubbleViewImageCache.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+JSMessagesView.h"


@import MobileCoreServices;

#define kJSImageDefaultRect         CGRectMake(0, 0, 150, 150)
#define kPlaceholderSubviewTag      999

static NSMutableDictionary *imageCache;


@implementation JSBubbleViewImageCache

+ (UIImageView *)placeholderForType:(JSBubbleMessageType)type frame:(CGRect)maskFrame
{
    static UIImage *leftPlaceholderImage = nil;
    static UIImage *rightPlaceholderImage = nil;
    
    if (!leftPlaceholderImage) {
      UIGraphicsBeginImageContext(kJSImageDefaultRect.size);
      CGContextRef context = UIGraphicsGetCurrentContext();
      
      CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
      CGContextFillRect(context, kJSImageDefaultRect);
      
      leftPlaceholderImage = [UIGraphicsGetImageFromCurrentImageContext() js_imageMaskWithImageView:[self maskForType:JSBubbleMessageTypeIncoming withFrame:maskFrame]];
      UIGraphicsEndImageContext();
    }
    
    if (!rightPlaceholderImage) {
      UIGraphicsBeginImageContext(kJSImageDefaultRect.size);
      CGContextRef context = UIGraphicsGetCurrentContext();
      
      CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
      CGContextFillRect(context, kJSImageDefaultRect);
      
      rightPlaceholderImage = [UIGraphicsGetImageFromCurrentImageContext() js_imageMaskWithImageView:[self maskForType:JSBubbleMessageTypeOutgoing withFrame:maskFrame]];
      UIGraphicsEndImageContext();
    }
  
    UIImage *image = rightPlaceholderImage;
    if (type == JSBubbleMessageTypeIncoming)
        image = leftPlaceholderImage;
    
    return [[UIImageView alloc] initWithImage:image];
}


+ (UIImageView *)maskForType:(JSBubbleMessageType)type withFrame:(CGRect)maskFrame
{
  // only build the masks once and reuse them for performance reasons.
    static UIImageView* leftMaskView = nil;
    static UIImageView* rightMaskView = nil;
    
    if (!leftMaskView) {
      leftMaskView = [JSBubbleImageViewFactory bubbleImageViewForType:JSBubbleMessageTypeIncoming color:[UIColor whiteColor]];
      leftMaskView.frame = maskFrame;
    }
    if (!rightMaskView) {
      rightMaskView = [JSBubbleImageViewFactory bubbleImageViewForType:JSBubbleMessageTypeOutgoing color:[UIColor whiteColor]];
      rightMaskView.frame = maskFrame;
    }
    
    if (type == JSBubbleMessageTypeOutgoing)
      return rightMaskView;
    
    return leftMaskView;
}


#pragma mark -


+ (UIImageView *)cachedImageViewWithKey:(NSString *)key type:(JSBubbleMessageType)type frame:(CGRect)maskFrame
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
        UIImageView *placeholder = [JSBubbleViewImageCache placeholderForType:type frame:maskFrame];
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
    return [NSString stringWithFormat:@"%@_%lu", [[message mediaURL] absoluteString], (unsigned long)[message hash]];
}


+ (UIImageView *)cachedImageViewWithMessage:(id <JSMessageData>)message
{
    // type is unused if there is no completion block
    CGRect frame = CGRectMake(0, 0, 250, 250);
    return  [self cachedImageViewWithMessage:message type:0 maskFrame:frame completionBlock:nil];
}


+ (UIImageView *)cachedImageViewWithMessage:(id <JSMessageData>)message type:(JSBubbleMessageType)type maskFrame:(CGRect)maskFrame completionBlock:(JSImageCacheImageLoadCompletionBlock)completion
{
    NSAssert([message respondsToSelector:@selector(mediaURL)], @"Unexpectedly trying to cache an image on an unsupported message type!");
    NSURL* url = [message mediaURL];
    NSString* messageKey = [self imageKey:message];
    
    // get the cached image view
    UIImageView *imageView = [JSBubbleViewImageCache cachedImageViewWithKey:messageKey type:type frame:maskFrame];
  
    // Check to see if the URL can support an image.
    NSString *UTIType =(__bridge_transfer NSString*)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[[url absoluteString] pathExtension], NULL);
    if (!UTTypeConformsTo((__bridge CFStringRef)UTIType, (__bridge CFStringRef)@"public.image"))
    {
        // if not, return the placeholder image.  We will never go further (yet)
        return imageView;
    }
    
    if (completion && !imageView.image) {
      
        UIImageView *placeholderImageView = [self placeholderForType:type frame:maskFrame];
      
        // set up the image with a placeholder and the passed URL
        [imageView setImageWithURL:url
                  placeholderImage:placeholderImageView.image
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             @synchronized(self)
                             {
                                 // update the image
                                 UIImageView *blockImageView = [self cachedImageViewWithKey:messageKey type:type frame:maskFrame];
                                 UIImageView *maskView = [self maskForType:type withFrame:maskFrame];

                               NSLog(@"returning image view %@ (image %@)", blockImageView, blockImageView.image);

                                 // mask the image with the placeholder
                                 UIImage *imageResult = [image js_imageMaskWithImageView:maskView];
                                 blockImageView.image = imageResult;
                               
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
