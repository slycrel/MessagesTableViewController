//
//  Created by Jesse Squires
//  http://www.hexedbits.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSMessagesViewController
//
//
//  The MIT License
//  Copyright (c) 2013 Jesse Squires
//  http://opensource.org/licenses/MIT
//

#import "JSBubbleView.h"

#import "JSMessageInputView.h"
#import "JSAvatarImageFactory.h"
#import "NSString+JSMessagesView.h"
#import "UIImage+JSMessagesView.h"
#import <objc/runtime.h>

#define kMarginTop 8.0f
#define kMarginBottom 4.0f
#define kPaddingTop 4.0f
#define kPaddingBottom 8.0f
#define kBubblePaddingRight 35.0f

#define IMAGE_BUBBLE_CORNER_SIZE_IN_PIXELS 8.0f

@interface JSBubbleView()

- (void)setup;

- (void)addTextViewObservers;
- (void)removeTextViewObservers;

+ (CGSize)textSizeForText:(NSString *)txt;
+ (CGSize)imageSizeForMessage:(id <JSMessageData>)message;

@end


@implementation JSBubbleView

@synthesize font = _font;

#pragma mark - Setup

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
                   bubbleType:(JSBubbleMessageType)bubleType
              bubbleImageView:(UIImageView *)bubbleImageView
                  messageData:(id <JSMessageData>)message
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        
        _type = bubleType;
        _message = message;
        
        bubbleImageView.userInteractionEnabled = YES;
        [self addSubview:bubbleImageView];
        _bubbleImageView = bubbleImageView;
        
        UITextView *textView = [[UITextView alloc] init];
        textView.font = [UIFont systemFontOfSize:16.0f];
        textView.textColor = [UIColor blackColor];
        textView.editable = NO;
        textView.userInteractionEnabled = YES;
        textView.showsHorizontalScrollIndicator = NO;
        textView.showsVerticalScrollIndicator = NO;
        textView.scrollEnabled = NO;
        textView.backgroundColor = [UIColor clearColor];
        textView.contentInset = UIEdgeInsetsZero;
        textView.scrollIndicatorInsets = UIEdgeInsetsZero;
        textView.contentOffset = CGPointZero;
        textView.dataDetectorTypes = UIDataDetectorTypeNone;
        [self addSubview:textView];
        [self bringSubviewToFront:textView];
        _textView = textView;
        
        if ([_textView respondsToSelector:@selector(textContainerInset)]) {
            _textView.textContainerInset = UIEdgeInsetsMake(8.0f, 4.0f, 2.0f, 4.0f);
        }
        
        [self addTextViewObservers];
        
        _attachedImageView = nil;
        
//        NOTE: TODO: textView frame & text inset
//        --------------------
//        future implementation for textView frame
//        in layoutSubviews : "self.textView.frame = textFrame;" is not needed
//        when setting the property : "_textView.textContainerInset = UIEdgeInsetsZero;"
//        unfortunately, this API is available in iOS 7.0+
//        update after dropping support for iOS 6.0
//        --------------------
    }
    return self;
}

- (void)dealloc
{
    [self removeTextViewObservers];
    _bubbleImageView = nil;
    _textView = nil;

    [self removeMessageImage];
}

- (void)removeMessageImage
{
    [_attachedImageView removeFromSuperview];
    _attachedImageView = nil;
}

#pragma mark - KVO

- (void)addTextViewObservers
{
    [_textView addObserver:self
                forKeyPath:@"text"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [_textView addObserver:self
                forKeyPath:@"font"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
    
    [_textView addObserver:self
                forKeyPath:@"textColor"
                   options:NSKeyValueObservingOptionNew
                   context:nil];
}

- (void)removeTextViewObservers
{
    [_textView removeObserver:self forKeyPath:@"text"];
    [_textView removeObserver:self forKeyPath:@"font"];
    [_textView removeObserver:self forKeyPath:@"textColor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (object == self.textView) {
        if ([keyPath isEqualToString:@"text"]
           || [keyPath isEqualToString:@"font"]
           || [keyPath isEqualToString:@"textColor"]) {
            [self setNeedsLayout];
        }
    }
}

#pragma mark - Setters


- (void)setMessageImageViewWithMessage:(id<JSMessageData>)message
{
    [self removeMessageImage];
    _bubbleImageView.hidden = NO;
    
    UIImageView *imageView = nil;
    if ([message respondsToSelector:@selector(thumbnailImageView)])
        imageView = [message thumbnailImageView];

    if (imageView) {
        // inline or mask the image to the full cell
        if ([message respondsToSelector:@selector(inlineThumbnailImage)] && [message inlineThumbnailImage]) {
            _attachedImageView = imageView;
        }
        else {
            _bubbleImageView.frame = [self bubbleFrame];    // this needs to be updated here or the mask is incorrect.
            UIImage *image = [imageView.image js_imageMaskWithImageView:_bubbleImageView];
            _attachedImageView = [[UIImageView alloc] initWithImage:image];
            _bubbleImageView.hidden = YES;
        }

        [self addSubview:_attachedImageView];
    }
}


- (void)setFont:(UIFont *)font
{
    _font = font;
    _textView.font = font;
}


#pragma mark - UIAppearance Getters

- (UIFont *)font
{
    if (_font == nil) {
        _font = [[[self class] appearance] font];
    }
    
    if (_font != nil) {
        return _font;
    }
    
    return [UIFont systemFontOfSize:16.0f];
}

#pragma mark - Getters

- (BOOL)isImageMessage
{
    return (_attachedImageView != nil);
}

- (CGRect)bubbleFrame
{
    CGSize bubbleSize = [JSBubbleView bubbleSizeForText:self.textView.text withMessage:self.message];
    CGSize imageSize = [JSBubbleView imageSizeForMessage:self.message];

    if ([self.message respondsToSelector:@selector(inlineThumbnailImage)] && ![self.message inlineThumbnailImage] && imageSize.height) {
        if (imageSize.height < bubbleSize.height || imageSize.width < bubbleSize.width)
            bubbleSize = imageSize;
    }

    return CGRectIntegral(CGRectMake((self.type == JSBubbleMessageTypeOutgoing ? self.frame.size.width - bubbleSize.width : 0.0f),
                                     kMarginTop,
                                     bubbleSize.width,
                                     bubbleSize.height + kMarginTop));
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bubbleImageView.frame = [self bubbleFrame];
    int imageSmallShift = (self.type == JSBubbleMessageTypeIncoming) ? 3 : -3;
    int imageHeightForDescription = 3.0f;
    
    // if There is an inline image attached that needs to be displayed, tweak the frame
    if (_attachedImageView) {
        if ([self.message respondsToSelector:@selector(inlineThumbnailImage)] && [self.message inlineThumbnailImage]) {
            CGRect imageFrame = CGRectMake( self.bubbleImageView.frame.origin.x + imageSmallShift + round( (self.bubbleImageView.frame.size.width /2 ) - ( _attachedImageView.frame.size.width / 2.0 ) ),
                                           17,
                                           _attachedImageView.frame.size.width,
                                           _attachedImageView.frame.size.height);
            
            self.attachedImageView.frame = imageFrame;

            // Set rounded Corners for Image Message View
            [self setMaskTo:_attachedImageView byRoundingCorners:UIRectCornerAllCorners ];
        }
        else {
            self.attachedImageView.frame = self.bubbleImageView.frame;
        }
        
        imageHeightForDescription = _attachedImageView.frame.size.height + 5;
    }
    
    CGFloat textX = self.bubbleImageView.frame.origin.x;
    
    if (self.type == JSBubbleMessageTypeIncoming) {
        textX += (self.bubbleImageView.image.capInsets.left / 2.0f);
    }
    
    CGRect textFrame = CGRectMake(textX,
                                  self.bubbleImageView.frame.origin.y + imageHeightForDescription,
                                  self.bubbleImageView.frame.size.width - (self.bubbleImageView.image.capInsets.right / 2.0f),
                                  self.bubbleImageView.frame.size.height - kMarginTop);
    
    self.textView.frame = CGRectIntegral(textFrame);
}

#pragma mark - Bubble view


- (void)setMaskTo:(UIView*)view byRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                  byRoundingCorners:corners
                                                        cornerRadii:CGSizeMake(IMAGE_BUBBLE_CORNER_SIZE_IN_PIXELS, IMAGE_BUBBLE_CORNER_SIZE_IN_PIXELS)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    view.layer.mask = shape;
}


+ (CGSize)textSizeForText:(NSString *)text
{
    CGFloat maxWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.70f;
    CGFloat maxHeight = MAX([JSMessageTextView numberOfLinesForMessage:text],
                            [text js_numberOfLines]) * [JSMessageInputView textViewLineHeight];
    maxHeight += kJSAvatarImageSize;
    
    CGSize stringSize;

    // check for blank messages, and return a 0 text height for those.
    if (![text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length)
      return CGSizeZero;

    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_0) {
        CGRect stringRect = [text boundingRectWithSize:CGSizeMake(maxWidth, maxHeight)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{ NSFontAttributeName : [[JSBubbleView appearance] font] }
                                              context:nil];
        
        stringSize = CGRectIntegral(stringRect).size;
    }
    else {
        stringSize = [text sizeWithFont:[[JSBubbleView appearance] font]
                     constrainedToSize:CGSizeMake(maxWidth, maxHeight)];
    }
    
    return CGSizeMake(roundf(stringSize.width), roundf(stringSize.height));
}


+ (CGSize)imageSizeForMessage:(id<JSMessageData>)message
{
    CGSize imageSize = CGSizeZero;
    UIImageView *imageView = nil;
    if ([message respondsToSelector:@selector(thumbnailImageView)])
        imageView = [message thumbnailImageView];
    if (imageView.frame.size.height) {
        
        CGFloat cellAvailableImageWidth = [UIScreen mainScreen].applicationFrame.size.width * 0.70f;
        CGSize actualImageSize = imageView.frame.size;
        
        // adjust smaller to fit as needed.
        if (actualImageSize.width > cellAvailableImageWidth ) {
            imageSize = CGSizeMake(cellAvailableImageWidth, actualImageSize.height * cellAvailableImageWidth / actualImageSize.width);
            imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageSize.width, imageSize.height);
        }
        else {
            imageSize = actualImageSize;
        }
    }
    
    return imageSize;
}


+ (CGSize)bubbleSizeForText:(NSString *)text withMessage:(id <JSMessageData>)message
{
    CGSize textSize = [self textSizeForText:text];
    CGSize imageSize = [self imageSizeForMessage:message];
    
    // if we are sending an image that fills the chat bubble, ignore any message text
    BOOL responds = [message respondsToSelector:@selector(inlineThumbnailImage)];
    BOOL imageFilledBubble = !responds || (responds && ![message inlineThumbnailImage]);
    
    if (imageSize.height > 0 && imageFilledBubble)
        textSize = CGSizeZero;
    
    // Check If there is an image attached , or It is Just a regular text Message.
    CGSize bubbleSize = CGSizeMake( MAX(imageSize.width, textSize.width), round (imageSize.height + textSize.height));
    
    return CGSizeMake(bubbleSize.width + kBubblePaddingRight,
                      bubbleSize.height + kPaddingTop + kPaddingBottom);
}


+ (CGSize)bubbleSizeForMessage:(id <JSMessageData>)message
{
    return [self bubbleSizeForText:message.text withMessage:message];
}


+ (CGFloat)neededHeightForMessage:(id <JSMessageData>)message
{
    CGSize size = [self bubbleSizeForMessage:message];

    return size.height + kMarginTop + kMarginBottom;;
}


@end

