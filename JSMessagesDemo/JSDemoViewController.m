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

#import "JSDemoViewController.h"

#define kSubtitleJobs @"Jobs"
#define kSubtitleWoz @"Steve Wozniak"
#define kSubtitleCook @"Mr. Cook"

@implementation JSDemoViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.delegate = self;
    self.dataSource = self;
    [super viewDidLoad];
    
    [[JSBubbleView appearance] setFont:[UIFont systemFontOfSize:16.0f]];
    
    self.title = @"Messages";
    
    self.messageInputView.textView.placeHolder = @"New Message";
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     [[JSMessage alloc] initWithTextMessage:@"JSMessagesViewController is simple and easy to use."],
                     [[JSMessage alloc] initWithTextMessage:@"It's highly customizable."],
                     [[JSMessage alloc] initWithTextMessage:@"It even has data detectors. You can call me tonight. My cell number is 452-123-4567. \nMy website is www.hexedbits.com."],
                     [[JSMessage alloc] initWithTextMessage:@"Group chat is possible. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!"],
                     [[JSMessage alloc] initWithTextMessage:@"Group chat is possible. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!"],
                     [[JSMessage alloc] initWithVideoMessage:[UIImage imageNamed:@"test3.png"] descrption:@"Apple WWDC 2011: Steve Jobs' keynote" linkedToURL:[NSURL URLWithString:@"http://www.apple.com"]],
                     nil];
    
    self.timestamps = [[NSMutableArray alloc] initWithObjects:
                       [NSDate distantPast],
                       [NSDate distantPast],
                       [NSDate distantPast],
                       [NSDate distantPast],
                       [NSDate date],
                       [NSDate date],
                       [NSDate date],
                       nil];
    
    self.subtitles = [[NSMutableArray alloc] initWithObjects:
                      kSubtitleJobs,
                      kSubtitleWoz,
                      kSubtitleJobs,
                      kSubtitleCook,
                      kSubtitleJobs,
                      kSubtitleCook,
                      nil];
    
    self.avatars = [[NSDictionary alloc] initWithObjectsAndKeys:
                    [JSAvatarImageFactory avatarImageNamed:@"demo-avatar-jobs" croppedToCircle:YES], kSubtitleJobs,
                    [JSAvatarImageFactory avatarImageNamed:@"demo-avatar-woz" croppedToCircle:YES], kSubtitleWoz,
                    [JSAvatarImageFactory avatarImageNamed:@"demo-avatar-cook" croppedToCircle:YES], kSubtitleCook,
                    nil];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
//                                                                                           target:self
//                                                                                           action:@selector(buttonPressed:)];
}

- (void)buttonPressed:(UIButton *)sender
{
    // Testing pushing/popping messages view
    JSDemoViewController *vc = [[JSDemoViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

#pragma mark - Messages view delegate: REQUIRED

- (void)didSendMessageData:(JSMessage *)message
{
    [self.messages addObject:message];
    
    [self.timestamps addObject:[NSDate date]];
    
    if((self.messages.count - 1) % 2) {
        [JSMessageSoundEffect playMessageSentSound];
        
        [self.subtitles addObject:arc4random_uniform(100) % 2 ? kSubtitleCook : kSubtitleWoz];
    }
    else {
        [JSMessageSoundEffect playMessageReceivedSound];
        
        [self.subtitles addObject:kSubtitleJobs];
    }
    
    
    [self finishSendingMessage:(message.type == JSTextMessage)];
    
    [self scrollToBottomAnimated:YES];
}

- (JSMessage*) attachedMediaMessage
{
    JSMessage* userSelectedMediaMessage = nil;
    UIImage* image = nil;
    NSURL * moreInfoURL = [NSURL URLWithString:@"http://www.github.com"];
    
    int random = (arc4random_uniform(100) % 3) + 1 ;
    image = [UIImage imageNamed:[NSString stringWithFormat:@"test%d.png" , random]];
  
    
    random = (arc4random_uniform(100) % 2);
    if (random)
        userSelectedMediaMessage = [[JSMessage alloc] initWithImageMessage:image descrption:@"Description for Image" linkedToURL:moreInfoURL];
    else
        userSelectedMediaMessage = [[JSMessage alloc] initWithVideoMessage:image descrption:@"Description for Video" linkedToURL:moreInfoURL];
    
    return userSelectedMediaMessage;
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row % 2) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleBlueColor]];
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyEveryThree;
}

- (JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyAll;
}

- (JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyAll;
}

- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat | JSMessageInputViewStyleIncludesAdornment;
}

-(void) shouldViewImageAtIndexPath:(NSIndexPath*) indexPath
{
    JSMessage* imageMessage = [_messages objectAtIndex:indexPath.row];
    NSLog(@"shouldView **  Image  ** AtIndexPath with Index %d and Link: %@" , indexPath.row , imageMessage.mediaURL );
}

-(void) shouldViewVideoAtIndexPath:(NSIndexPath*) indexPath
{
    JSMessage* imageMessage = [_messages objectAtIndex:indexPath.row];
    NSLog(@"shouldView **  Video  ** AtIndexPath with Index %d and Link: %@" , indexPath.row , imageMessage.mediaURL );
}


#pragma mark - Messages view delegate: OPTIONAL

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    
        if([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if(cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if(cell.subtitleLabel) {
        cell.subtitleLabel.textColor = [UIColor lightGrayColor];
    }
    
    if (cell.bubbleView.attachedImageView) {
        
        if([cell messageType] == JSBubbleMessageTypeOutgoing) {
            [cell.bubbleView.textView setTextColor:[UIColor whiteColor]];
        }else
        {
            [cell.bubbleView.textView setTextColor:[UIColor darkGrayColor]];
        }
    }
}

//  *** Required if using `JSMessagesViewTimestampPolicyCustom`
//
//  - (BOOL)hasTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
//

//  *** Implement to use a custom send button
//
//  The button's frame is set automatically for you
//
//  - (UIButton *)sendButtonForInputView
//

//  *** Implement to prevent auto-scrolling when message is added
//
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}


#pragma mark - Messages view data source: REQUIRED

- (JSMessage*) messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.timestamps objectAtIndex:indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *subtitle = [self.subtitles objectAtIndex:indexPath.row];
    UIImage *image = [self.avatars objectForKey:subtitle];
    return [[UIImageView alloc] initWithImage:image];
}

- (NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.subtitles objectAtIndex:indexPath.row];
}

@end
