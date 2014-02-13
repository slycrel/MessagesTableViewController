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
#import "NSString+JSMessagesView.h"
#import "JSMessageWithImages.h"

@import MobileCoreServices;

#define kPickerCameraOption     @"Take Photo or Video"
#define kPickerLibraryOption    @"Choose a photo"
#define kPickerOptionCancel     @"Cancel"

#define kSenderKey              @"Sender"
#define KTextKey                @"Text"
#define kDateKey                @"Date"
#define kMediaURLKey            @"MediaURL"

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
    self.sender = @"Jobs";
    
    [self setBackgroundColor:[UIColor whiteColor]];
        
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     [[JSMessage alloc] initWithText:@"JSMessagesViewController is simple and easy to use." sender:kSubtitleJobs date:[NSDate distantPast]],
                     [[JSMessage alloc] initWithText:@"It's highly customizable." sender:kSubtitleWoz date:[NSDate distantPast]],
                     [[JSMessage alloc] initWithText:@"It even has data detectors. You can call me tonight. My cell number is 452-123-4567. \nMy website is www.hexedbits.com." sender:kSubtitleJobs date:[NSDate distantPast]],
                     [[JSMessage alloc] initWithText:@"Group chat. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!" sender:kSubtitleCook date:[NSDate distantPast]],
                     [[JSMessage alloc] initWithText:@"Group chat. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!" sender:kSubtitleJobs date:[NSDate distantPast]],
                     [[JSMessageWithImages alloc] initWithText:@"This is a large fish." sender:kSubtitleWoz date:[NSDate date] mediaURL:[NSURL URLWithString:@"http://newswatch.nationalgeographic.com/files/2012/11/Blue-Marlin-Crittercam-600x423.jpg"]],
                     [[JSMessageWithImages alloc] initWithText:@"That is a large fish!" sender:kSubtitleCook date:[NSDate date] mediaURL:[NSURL URLWithString:@"http://newswatch.nationalgeographic.com/files/2012/11/Black-Jump-Sequence-2e-950x633.jpg"]],
                     [[JSMessageWithImages alloc] initWithText:@"Small flower." sender:kSubtitleWoz date:[NSDate date] mediaURL:[NSURL URLWithString:@"http://www.birdmom.net/WildflowersBlue/Blue-Dick3-18-05(small).jpg"]],
                     [[JSMessageWithImages alloc] initWithText:@"I like small flowers." sender:kSubtitleCook date:[NSDate date] mediaURL:[NSURL URLWithString:@"http://www.birdmom.net/WildflowersBlue/Blue-Dick3-18-05(small).jpg"]],
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

#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.numberOfButtons - 1)     // cancel is always last
        return;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    UIImagePickerControllerSourceType pickerSource;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:kPickerCameraOption])
        pickerSource = UIImagePickerControllerSourceTypeCamera;
    else
        pickerSource = UIImagePickerControllerSourceTypePhotoLibrary;   // default
    
    picker.sourceType = pickerSource;
    picker.delegate = self;
    picker.mediaTypes = @[(__bridge NSString*)kUTTypeMovie, (__bridge NSString*)kUTTypeImage];
    [self presentViewController:picker animated:YES completion:^{ }];
}


#pragma mark - Messages view delegate: REQUIRED


- (void)didSendText:(NSString *)text fromSender:(NSString *)sender onDate:(NSDate *)date
{
    if ((self.messages.count - 1) % 2) {
        [JSMessageSoundEffect playMessageSentSound];
    }
    else {
        // for demo purposes only, mimicing received messages
        [JSMessageSoundEffect playMessageReceivedSound];
        sender = arc4random_uniform(10) % 2 ? kSubtitleCook : kSubtitleWoz;
    }
    
    // cover for optional params.
    if (!sender)
        sender = @"";
    if (!date)
        date = [NSDate date];
    
    [self.messages addObject:[[JSMessage alloc] initWithText:text sender:sender date:date]];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}


- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // note that this method will not get called for image rows!
    
    if (indexPath.row % 2) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleBlueColor]];
}


- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

- (BOOL)shouldDisplayTimestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 3 == 0) {
        return YES;
    }
    return NO;
}

//
//  *** Implement to customize cell further
//
- (void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing) {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    
        if ([cell.bubbleView.textView respondsToSelector:@selector(linkTextAttributes)]) {
            NSMutableDictionary *attrs = [cell.bubbleView.textView.linkTextAttributes mutableCopy];
            [attrs setValue:[UIColor blueColor] forKey:UITextAttributeTextColor];
            
            cell.bubbleView.textView.linkTextAttributes = attrs;
        }
    }
    
    if (cell.timestampLabel) {
        cell.timestampLabel.textColor = [UIColor lightGrayColor];
        cell.timestampLabel.shadowOffset = CGSizeZero;
    }
    
    if (cell.subtitleLabel) {
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

// *** Implemnt to enable/disable pan/tap todismiss keyboard
//
- (BOOL)allowsPanToDismissKeyboard
{
    return YES;
}

#pragma mark - Messages view data source: REQUIRED

- (JSMessage *)messageForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.row];
}

- (UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath sender:(NSString *)sender
{
    UIImage *image = [self.avatars objectForKey:sender];
    return [[UIImageView alloc] initWithImage:image];
}

@end
