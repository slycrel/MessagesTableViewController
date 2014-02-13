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

#import "JSMessageTableView.h"
#import "JSBubbleViewImageCache.h"


@implementation JSMessageTableView

- (void)dealloc
{
    // clean up our in-memory disk cache when we discard the table.
    [JSBubbleViewImageCache clearImageCache];
}

@end
