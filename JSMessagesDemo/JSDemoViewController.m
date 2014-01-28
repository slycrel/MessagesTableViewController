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

@import MobileCoreServices;

#define kSubtitleJobs           @"Jobs"
#define kSubtitleWoz            @"Steve Wozniak"
#define kSubtitleCook           @"Mr. Cook"
#define kPickerCameraOption     @"Take Photo or Video"
#define kPickerLibraryOption    @"Choose a photo"
#define kPickerOptionCancel     @"Cancel"

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
                     [[JSMessage alloc] initWithText:@"Group chat. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!" sender:kSubtitleJobs date:[NSDate date]],
                     [[JSMessage alloc] initWithText:@"Group chat. Sound effects and images included. Animations are smooth. Messages can be of arbitrary size!" sender:kSubtitleWoz date:[NSDate date]],
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


#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // if this is a photo
    if (image)
    {
//        [self ]
//        [self.messages lastObject].mediaURL = nil;
//        [self.tableView reloadData];
    }
    
    [self dismissViewControllerAnimated:YES completion:^{ }];
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
    
    [self.messages addObject:[[JSMessage alloc] initWithText:text sender:sender date:date]];
    
    [self finishSend];
    [self scrollToBottomAnimated:YES];
}

- (id <JSMessageData>) attachedMediaMessage
{
    id <JSMessageData> userSelectedMediaMessage = nil;
    UIImage* image = nil;
    NSURL * moreInfoURL = [NSURL URLWithString:@"http://3.bp.blogspot.com/-haL2aRqeJjs/UcOvPjG_PXI/AAAAAAAAAf8/FQ6NNvjqhKs/s1600/Screen+Shot+2013-06-20+at+7.40.44+PM.png"];
    
    int random = (arc4random_uniform(100) % 3) + 1 ;
    image = [UIImage imageNamed:[NSString stringWithFormat:@"test%d.png" , random]];
    
    NSString *randomSender = kSubtitleCook;
    if (random == 2)
        randomSender = kSubtitleJobs;
    else if (random == 3)
        randomSender = kSubtitleWoz;
    
    NSString *description = @"Description for Image";
    random = (arc4random_uniform(100) % 2);
    if (!random)
        description = @"Description for Video";

    userSelectedMediaMessage = [[JSMessage alloc] initWithText:description sender:randomSender date:[NSDate date]];

#error you are here.  media message stuff should be set here.
    
    return userSelectedMediaMessage;
}

- (JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row % 2) ? JSBubbleMessageTypeIncoming : JSBubbleMessageTypeOutgoing;
}

- (UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type
                       forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2) {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                          color:[UIColor js_bubbleLightGrayColor]];
    }
    
    return [JSBubbleImageViewFactory bubbleImageViewForType:type
                                                      color:[UIColor js_bubbleBlueColor]];
}


- (JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat | JSMessageInputViewStyleIncludesAdornment;
}

-(void) shouldViewImageAtIndexPath:(NSIndexPath*) indexPath
{
    id<JSMessageData> imageMessage = [_messages objectAtIndex:indexPath.row];
    NSLog(@"shouldView **  Image  ** AtIndexPath with Index %d and Link: %@", indexPath.row, [imageMessage mediaURL]);
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

#pragma mark - JSMessagesViewDelegate (optional)

- (void)attachImagePressed
{
//#if TARGET_IPHONE_SIMULATOR
//    // the simulator makes the UIImagePicker fairly useless.  Ideally this would bring up the image picker UI rather than hard-coding the image chosen.
//    id<JSMessageData> message = [self attachedMediaMessage];
//    
//    [self didSendText:[[message text] js_stringByTrimingWhitespace]
//           fromSender:[message sender]
//               onDate:[message date]];
//#else
    // bring up the image picker and allow the user to choose an image.
    [self.view endEditing:YES];
    
    NSMutableArray *pickerChoices = [NSMutableArray array];    // reset the array
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        [pickerChoices addObject:kPickerCameraOption];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        [pickerChoices addObject:kPickerLibraryOption];
    
    if (pickerChoices.count)
    {
        NSString *choice1 = nil;
        NSString *choice2 = nil;
        
        if (pickerChoices.count == 2)
        {
            choice1 = pickerChoices[0];
            choice2 = pickerChoices[1];
        }
        else
        {
            choice1 = [pickerChoices firstObject];
        }
        
        UIActionSheet *actionSheet = nil;
        if (choice2)
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:kPickerOptionCancel
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:choice1, choice2, nil];
        }
        else
        {
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:kPickerOptionCancel
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:choice1, nil];
        }
        
        [actionSheet showInView:self.view];
    }

//#endif
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
