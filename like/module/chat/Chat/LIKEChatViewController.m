//
//  LIKEChatViewController.m
//  like
//
//  Created by David Fu on 7/15/15.
//  Copyright (c) 2015 LIKE Technology. All rights reserved.
//

#import "LIKEChatViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "DXChatBarMoreView.h"
#import "DXRecordView.h"
#import "DXFaceView.h"
#import "EMChatViewCell.h"
#import "EMChatTimeCell.h"
#import "ChatSendHelper.h"
#import "MessageReadManager.h"
#import "MessageModelManager.h"
#import "LocationViewController.h"
#import "DXMessageToolBar.h"
#import "DXChatBarMoreView.h"
#import "EMCDDeviceManager.h"
#import "EMCDDeviceManagerDelegate.h"

//#import "ChatroomDetailViewController.h"
//#import "ChatGroupDetailViewController.h"

#define KPageCount 20
#define KHintAdjustY    50

@interface LIKEChatViewController () <UITableViewDelegate,
                                      UITableViewDataSource,
                                      UINavigationControllerDelegate,
                                      UIImagePickerControllerDelegate,
                                      IChatManagerDelegate,
                                      DXChatBarMoreViewDelegate,
                                      DXMessageToolBarDelegate,
                                      LocationViewDelegate,
                                      EMCDDeviceManagerDelegate ,
                                      EMCallManagerDelegate,
                                      SSPullToRefreshViewDelegate> {
    UIMenuController *_menuController;
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    NSIndexPath *_longPressIndexPath;
    
    NSInteger _recordingCount;
    
    dispatch_queue_t _messageQueue;
    
    NSMutableArray *_messages;
    BOOL _isScrollToBottom;
}

@property (readwrite, nonatomic, strong) EMConversation *conversation;

@property (nonatomic) BOOL isChatGroup;

@property (nonatomic) EMConversationType conversationType;

@property (strong, nonatomic) NSMutableArray *dataSource;//tableView数据源

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (readwrite, nonatomic, strong) SSPullToRefreshView *refreshView;

@property (strong, nonatomic) DXMessageToolBar *chatToolBar;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (strong, nonatomic) MessageReadManager *messageReadManager;//message阅读的管理者
@property (strong, nonatomic) NSDate *chatTagDate;

@property (strong, nonatomic) NSMutableArray *messages;
@property (nonatomic) BOOL isScrollToBottom;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic) BOOL isKicked;

@property (nonatomic) BOOL isInvisible;

@end

@implementation LIKEChatViewController

#pragma mark - life cycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.chatter;
    
    self.conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.chatter
                                                                    conversationType:self.type];
    [self.conversation markAllMessagesAsRead:YES];

    [self registerBecomeActive];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor like_viewBackgroundColor];
    
#warning 以下三行代码必须写，注册为SDK的ChatManager的delegate
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    // 注册为Call的Delegate
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllMessages:) name:@"RemoveAllMessages" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    
    _messageQueue = dispatch_queue_create("easemob.com", NULL);
    _isScrollToBottom = YES;
    
    [self setupBarButtonItem];
    
    [self.view addSubview:self.chatToolBar];
    
    self.tableView.backgroundColor = [UIColor like_viewBackgroundColor];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.chatToolBar.mas_top);
    }];
    
    //将self注册为chatToolBar的moreView的代理
    if ([self.chatToolBar.moreView isKindOfClass:[DXChatBarMoreView class]]) {
        [(DXChatBarMoreView *)self.chatToolBar.moreView setDelegate:self];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden)];
    [self.view addGestureRecognizer:tap];
    
    //通过会话管理者获取已收发消息
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    [self loadMoreMessagesFrom:timestamp count:KPageCount append:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
    
    if (self.conversation.conversationType == eConversationTypeChatRoom) {
        [self joinChatroom:self.conversation.chatter];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self refreshView];
}

- (void)handleCallNotification:(NSNotification *)notification {
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        //开始call
        self.isInvisible = YES;
    }
    else
    {
        //结束call
        self.isInvisible = NO;
    }
}

- (void)setupBarButtonItem {
//    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//    [backButton setImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
//    [self.navigationItem setLeftBarButtonItem:backItem];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat_back.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(back)];
    self.navigationItem.leftBarButtonItem = barButtonItem;

    
    if (self.isChatGroup) {
//        UIButton *detailButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
//        [detailButton setImage:[UIImage imageNamed:@"group_detail"] forState:UIControlStateNormal];
//        [detailButton addTarget:self action:@selector(showRoomContact:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:detailButton];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"group_detail"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(showRoomContact:)];
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    else{
//        UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        [clearButton setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
//        [clearButton addTarget:self action:@selector(removeAllMessages:) forControlEvents:UIControlEventTouchUpInside];
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:clearButton];
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self
                                                                         action:@selector(removeAllMessages:)];
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSUserDefaults standardUserDefaults] setObject:@(NO)forKey:@"isShowPicker"];
    if (_isScrollToBottom) {
        [self scrollViewToBottom:NO];
    }
    else{
        _isScrollToBottom = YES;
    }
    self.isInvisible = NO;
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    self.isInvisible = YES;
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    
    _chatToolBar.delegate = nil;
    _chatToolBar = nil;
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#warning 以下第一行代码必须写，将self从ChatManager的代理中移除
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //[[EaseMob sharedInstance].callManager removeDelegate:self];
    if (_conversation.conversationType == eConversationTypeChatRoom && !_isKicked) {
        //退出聊天室，删除会话
        NSString *chatter = [self.conversation.chatter copy];
        [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatter completion:^(EMChatroom *chatroom, EMError *error){
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatter deleteMessages:YES append2Chat:YES];
        }];
    }
    
    if (_imagePicker)
    {
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)setIsInvisible:(BOOL)isInvisible
{
    _isInvisible =isInvisible;
    if (!_isInvisible)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messages)
        {
            if ([self shouldAckMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self sendHasReadResponseForMessages:unreadMessages];
        }
        
        [_conversation markAllMessagesAsRead:YES];
    }
}


#pragma mark - delegate methods

#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.dataSource objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[NSString class]]) {
        return 40;
    }
    else{
        return [EMChatViewCell tableView:tableView heightForRowAtIndexPath:indexPath withObject:(MessageModel *)obj];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.dataSource count]) {
        id obj = [self.dataSource objectAtIndex:indexPath.row];
        if ([obj isKindOfClass:[NSString class]]) {
            EMChatTimeCell *timeCell = (EMChatTimeCell *)[tableView dequeueReusableCellWithIdentifier:@"MessageCellTime"];
            if (timeCell == nil) {
                timeCell = [[EMChatTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MessageCellTime"];
                timeCell.backgroundColor = [UIColor clearColor];
                timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            timeCell.textLabel.text = (NSString *)obj;
            
            return timeCell;
        }
        else{
            MessageModel *model = (MessageModel *)obj;
            NSString *cellIdentifier = [EMChatViewCell cellIdentifierForMessageModel:model];
            EMChatViewCell *cell = (EMChatViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[EMChatViewCell alloc] initWithMessageModel:model reuseIdentifier:cellIdentifier];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageModel = model;
            
            return cell;
        }
    }
    
    return nil;
}

#pragma mark - IChatManagerDelegate

-(void)didSendMessage:(EMMessage *)message error:(EMError *)error
{
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MessageModel class]])
         {
             MessageModel *model = (MessageModel*)obj;
             if ([model.messageId isEqualToString:message.messageId])
             {
                 model.message.deliveryState = message.deliveryState;
                 *stop = YES;
             }
         }
     }];
    [self.tableView reloadData];
}

- (void)didReceiveHasReadResponse:(EMReceipt*)receipt
{
    [self.dataSource enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MessageModel class]])
         {
             MessageModel *model = (MessageModel*)obj;
             if ([model.messageId isEqualToString:receipt.chatId])
             {
                 model.message.isReadAcked = YES;
                 *stop = YES;
             }
         }
     }];
    [self.tableView reloadData];
}

- (void)reloadTableViewDataWithMessage:(EMMessage *)message{
    __weak typeof (self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        if ([weakSelf.conversation.chatter isEqualToString:message.conversationChatter]) {
            for (int i = 0; i < weakSelf.dataSource.count; i ++) {
                id object = [weakSelf.dataSource objectAtIndex:i];
                if ([object isKindOfClass:[MessageModel class]]) {
                    MessageModel *model = (MessageModel *)object;
                    if ([message.messageId isEqualToString:model.messageId]) {
                        MessageModel *cellModel = [MessageModelManager modelWithMessage:message];
//                        if ([weakSelf.delegate respondsToSelector:@selector(nickNameWithChatter:)]) {
//                            NSString *showName = [weakSelf.delegate nickNameWithChatter:model.username];
//                            cellModel.nickName = showName?showName:cellModel.username;
//                        }
//                        else {
                            cellModel.nickName = cellModel.username;
//                        }
                        
//                        if ([weakSelf.delegate respondsToSelector:@selector(avatarWithChatter:)]) {
//                            cellModel.headImageURL = [NSURL URLWithString:[weakSelf.delegate avatarWithChatter:cellModel.username]];
//                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.tableView beginUpdates];
                            [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                            [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.tableView endUpdates];
                        });
                        break;
                    }
                }
            }
        }
    });
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    if (!error) {
        id<IEMFileMessageBody>fileBody = (id<IEMFileMessageBody>)[message.messageBodies firstObject];
        if ([fileBody messageBodyType] == eMessageBodyType_Image) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Video){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody messageBodyType] == eMessageBodyType_Voice){
            if ([fileBody attachmentDownloadStatus] == EMAttachmentDownloadSuccessed)
            {
                [self reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

- (void)didFetchingMessageAttachments:(EMMessage *)message progress:(float)progress{
    NSLog(@"didFetchingMessageAttachment: %f", progress);
}

-(void)didReceiveMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self addMessage:message];
        if ([self shouldAckMessage:message read:NO])
        {
            [self sendHasReadResponseForMessages:@[message]];
        }
        if ([self shouldMarkMessageAsRead])
        {
            [self markMessagesAsRead:@[message]];
        }
    }
}

-(void)didReceiveCmdMessage:(EMMessage *)message
{
    if ([_conversation.chatter isEqualToString:message.conversationChatter]) {
        [self showHintHudWithMessage:NSLocalizedStringFromTable(@"receiveCmd", LIKELocalizeChat, @"receive cmd message")];
    }
}

- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error
{
    if (error && [_conversation.chatter isEqualToString:conversationChatter]) {
        
        __weak typeof(self) weakSelf = self;
        for (int i = 0; i < self.dataSource.count; i ++) {
            id object = [self.dataSource objectAtIndex:i];
            if ([object isKindOfClass:[MessageModel class]]) {
                MessageModel *currentModel = [self.dataSource objectAtIndex:i];
                EMMessage *currMsg = [currentModel message];
                if ([messageId isEqualToString:currMsg.messageId]) {
                    currMsg.deliveryState = eMessageDeliveryState_Failure;
                    MessageModel *cellModel = [MessageModelManager modelWithMessage:currMsg];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.tableView beginUpdates];
                        [weakSelf.dataSource replaceObjectAtIndex:i withObject:cellModel];
                        [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        [weakSelf.tableView endUpdates];
                        
                    });
                    
//                    if (error
//                        && error.errorCode == EMErrorMessageContainSensitiveWords) {
//                        //CGRect frame = self.chatToolBar.frame;
//                        //[self showHint:NSLocalizedStringFromTable(@"message.forbiddenWords", @"Your message contains forbidden words") yOffset:-frame.size.height + KHintAdjustY];
//                        [self showHintHudWithMessage:NSLocalizedStringFromTable(@"message.forbiddenWords", @"Your message contains forbidden words")];
//                    }
                    break;
                }
            }
        }
    }
}


- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages {
    if (![offlineMessages count])
    {
        return;
    }
    if ([self shouldMarkMessageAsRead])
    {
        [_conversation markAllMessagesAsRead:YES];
    }
    _chatTagDate = nil;
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    [self loadMoreMessagesFrom:timestamp count:[self.messages count] + [offlineMessages count] append:NO];
}

- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error {
    if (self.isChatGroup
        && [group.groupId isEqualToString:self.conversation.chatter]) {
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:NO];
    }
}

- (void)didInterruptionRecordAudio
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
    
    [self stopAudioPlayingWithChangeCategory:YES];
}

- (void)groupDidUpdateInfo:(EMGroup *)group error:(EMError *)error {
    if (!error
        && self.isChatGroup
        && [self.conversation.chatter isEqualToString:group.groupId]) {
        self.title = group.groupSubject;
    }
}

#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)didRemovedFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

#pragma mark - EMChatBarMoreViewDelegate

- (void)moreViewPhotoAction:(DXChatBarMoreView *)moreView
{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"isShowPicker"];
    // 隐藏键盘
    [self keyBoardHidden];
    
    // 弹出照片选择
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    self.isInvisible = YES;
}

- (void)moreViewTakePicAction:(DXChatBarMoreView *)moreView
{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES)forKey:@"isShowPicker"];
    [self keyBoardHidden];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHintHudWithMessage:NSLocalizedStringFromTable(@"message.simulatorNotSupportCamera", LIKELocalizeChat, @"simulator does not support taking picture")];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    self.isInvisible = YES;
#endif
}

- (void)moreViewLocationAction:(DXChatBarMoreView *)moreView
{
    // 隐藏键盘
    [self keyBoardHidden];
    
    LocationViewController *locationController = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
    locationController.delegate = self;
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)moreViewAudioCallAction:(DXChatBarMoreView *)moreView {
    // 隐藏键盘
    [self keyBoardHidden];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter"
                                                        object:@{@"chatter":self.conversation.chatter,
                                                                 @"type":@(eCallSessionTypeAudio)
                                                                 }];
}

- (void)moreViewVideoCallAction:(DXChatBarMoreView *)moreView {
    // 隐藏键盘
    [self keyBoardHidden];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callOutWithChatter"
                                                        object:@{@"chatter":self.conversation.chatter,
                                                                 @"type":@(eCallSessionTypeVideo)
                                                                 }];
}

#pragma mark LocationViewDelegate

-(void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address
{
    NSDictionary *ext = nil;
    EMMessage *locationMessage = [ChatSendHelper sendLocationLatitude:latitude longitude:longitude address:address toUsername:_conversation.chatter messageType:[self messageType] requireEncryption:NO ext:ext];
    [self addMessage:locationMessage];
}

#pragma mark DXMessageToolBarDelegate

- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
    [_menuController setMenuItems:nil];
}

- (void)didChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight;
        self.tableView.frame = rect;
    }];
    [self scrollViewToBottom:NO];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
    }
}

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    if ([self canRecord]) {
        DXRecordView *tmpView = (DXRecordView *)recordView;
        tmpView.center = self.view.center;
        [self.view addSubview:tmpView];
        [self.view bringSubviewToFront:recordView];
        int x = arc4random() % 100000;
        NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
        
        [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName
                                                                 completion:^(NSError *error)
         {
             if (error) {
                 NSLog(NSLocalizedStringFromTable(@"message.startRecordFail", LIKELocalizeChat, @"failure to start recording"));
             }
         }];
    }
}

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    __weak typeof(self) weakSelf = self;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath
                                                       displayName:@"audio"];
            voice.duration = aDuration;
            [weakSelf sendAudioMessage:voice];
        }else {
            [weakSelf showHintHudWithMessage:NSLocalizedStringFromTable(@"media.timeShort", LIKELocalizeChat, @"The recording time is too short")];
            weakSelf.chatToolBar.recordButton.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf hideHUD];
                weakSelf.chatToolBar.recordButton.enabled = YES;
            });
        }
    }];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        [picker dismissViewControllerAnimated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"isShowPicker"];
        }];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        EMChatVideo *chatVideo = [[EMChatVideo alloc] initWithFile:[mp4 relativePath] displayName:@"video.mp4"];
        [self sendVideoMessage:chatVideo];
        
    }else{
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [picker dismissViewControllerAnimated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:@"isShowPicker"];
        }];
        [self sendImageMessage:orgImage];
    }
    self.isInvisible = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[NSUserDefaults standardUserDefaults] setObject:@(NO)forKey:@"isShowPicker"];
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.isInvisible = NO;
}

#pragma mark - EMCDDeviceManagerDelegate
- (void)proximitySensorChanged:(BOOL)isCloseToUser{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (!_isPlayingAudio) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - EMChatManagerChatroomDelegate

- (void)chatroom:(EMChatroom *)chatroom occupantDidJoin:(NSString *)username
{
//    CGRect frame = self.chatToolBar.frame;
//    [self showHint:[NSString stringWithFormat:NSLocalizedStringFromTable(@"chatroom.join", @"\'%@\'join chatroom\'%@\'"), username, chatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
    [self showHintHudWithMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"chatroom.join", LIKELocalizeChat, @"\'%@\'join chatroom\'%@\'"), username, chatroom.chatroomId]];
}

- (void)chatroom:(EMChatroom *)chatroom occupantDidLeave:(NSString *)username
{
//    CGRect frame = self.chatToolBar.frame;
//    [self showHint:[NSString stringWithFormat:NSLocalizedStringFromTable(@"chatroom.leave", @"\'%@\'leave chatroom\'%@\'"), username, chatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
    [self showHintHudWithMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"chatroom.leave", LIKELocalizeChat, @"\'%@\'leave chatroom\'%@\'"), username, chatroom.chatroomId]];
}

- (void)beKickedOutFromChatroom:(EMChatroom *)chatroom reason:(EMChatroomBeKickedReason)reason {
    if ([self.conversation.chatter isEqualToString:chatroom.chatroomId]) {
        _isKicked = YES;
        //CGRect frame = self.chatToolBar.frame;
        //[self showHint:[NSString stringWithFormat:NSLocalizedStringFromTable(@"chatroom.remove", @"be removed from chatroom\'%@\'"), chatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
        [self showHintHudWithMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"chatroom.remove", LIKELocalizeChat, @"be removed from chatroom\'%@\'"), chatroom.chatroomId]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark ICallManagerDelegate

- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error {
    if (reason == eCallReason_Null) {
        if ([[EMCDDeviceManager sharedInstance] isPlaying]) {
            [self stopAudioPlayingWithChangeCategory:NO];
        }
    }
}

#pragma mark SSPullToRefreshViewDelegate

- (void)pullToRefreshViewDidStartLoading:(SSPullToRefreshView *)view {
    _chatTagDate = nil;
    EMMessage *firstMessage = [self.messages firstObject];
    if (firstMessage)
    {
        [self loadMoreMessagesFrom:firstMessage.timestamp count:KPageCount append:YES];
    }
    [view finishLoading];
}


#pragma mark - event response

- (void)handleRefresh:(UIRefreshControl *)sender {
    
}

- (void)registerBecomeActive{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)didBecomeActive{
    [self reloadData];
}

#pragma mark gestureRecognizer

// 点击背景隐藏
-(void)keyBoardHidden {
    [self.chatToolBar endEditing:YES];
}

- (IBAction)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan && [self.dataSource count] > 0) {
        CGPoint location = [sender locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        id object = [self.dataSource objectAtIndex:indexPath.row];
        if ([object isKindOfClass:[MessageModel class]]) {
            EMChatViewCell *cell = (EMChatViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [cell becomeFirstResponder];
            _longPressIndexPath = indexPath;
            [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.messageModel.type];
        }
    }
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo {
    MessageModel *model = [userInfo objectForKey:KMESSAGEKEY];
    if ([eventName isEqualToString:kRouterEventTextURLTapEventName]) {
        [self chatTextCellUrlPressed:[userInfo objectForKey:@"url"]];
    }
    else if ([eventName isEqualToString:kRouterEventAudioBubbleTapEventName]) {
        [self chatAudioCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventImageBubbleTapEventName]){
        [self chatImageCellBubblePressed:model];
    }
    else if ([eventName isEqualToString:kRouterEventLocationBubbleTapEventName]){
        [self chatLocationCellBubblePressed:model];
    }
    else if([eventName isEqualToString:kResendButtonTapEventName]){
        EMChatViewCell *resendCell = [userInfo objectForKey:kShouldResendCell];
        MessageModel *messageModel = resendCell.messageModel;
        if ((messageModel.status != eMessageDeliveryState_Failure) && (messageModel.status != eMessageDeliveryState_Pending))
        {
            return;
        }
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        [chatManager asyncResendMessage:messageModel.message progress:nil];
        NSIndexPath *indexPath = [self.tableView indexPathForCell:resendCell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }else if([eventName isEqualToString:kRouterEventChatCellVideoTapEventName]){
        [self chatVideoCellPressed:model];
    }else if ([eventName isEqualToString:kRouterEventMenuTapEventName]) {
        [self sendTextMessage:[userInfo objectForKey:@"text"]];
    }
}

//链接被点击
- (void)chatTextCellUrlPressed:(NSURL *)url {
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

// 语音的bubble被点击
-(void)chatAudioCellBubblePressed:(MessageModel *)model
{
    id <IEMFileMessageBody> body = [model.message.messageBodies firstObject];
    EMAttachmentDownloadStatus downloadStatus = [body attachmentDownloadStatus];
    if (downloadStatus == EMAttachmentDownloading) {
        [self showHintHudWithMessage:NSLocalizedStringFromTable(@"message.downloadingAudio", LIKELocalizeChat, @"downloading voice, click later")];
        return;
    }
    else if (downloadStatus == EMAttachmentDownloadFailure)
    {
        [self showHintHudWithMessage:NSLocalizedStringFromTable(@"message.downloadingAudio", LIKELocalizeChat, @"downloading voice, click later")];
        [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil];
        
        return;
    }
    
    // 播放音频
    if (model.type == eMessageBodyType_Voice) {
        //发送已读回执
        if ([self shouldAckMessage:model.message read:YES])
        {
            [self sendHasReadResponseForMessages:@[model.message]];
        }
        __weak typeof (self) weakSelf = self;
        BOOL isPrepare = [self.messageReadManager prepareMessageAudioModel:model updateViewCompletion:^(MessageModel *prevAudioModel, MessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak typeof (self) weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.chatVoice.localPath completion:^(NSError *error) {
                [weakSelf.messageReadManager stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

// 位置的bubble被点击
-(void)chatLocationCellBubblePressed:(MessageModel *)model
{
    _isScrollToBottom = NO;
    LocationViewController *locationController = [[LocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)chatVideoCellPressed:(MessageModel *)model
{
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.messageBody;
    if (videoBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
    {
        NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
        if (localPath && localPath.length > 0)
        {
            //发送已读回执
            if ([self shouldAckMessage:model.message read:YES])
            {
                [self sendHasReadResponseForMessages:@[model.message]];
            }
            [self playVideoWithVideoPath:localPath];
            return;
        }
    }
    
    __weak typeof (self) weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    [weakSelf showHintHudWithMessage:NSLocalizedStringFromTable(@"message.downloadingVideo", LIKELocalizeChat, @"downloading video...")];
    [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        [weakSelf hideHUD];
        if (!error) {
            //发送已读回执
            if ([weakSelf shouldAckMessage:model.message read:YES])
            {
                [weakSelf sendHasReadResponseForMessages:@[model.message]];
            }
            NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
            if (localPath && localPath.length > 0) {
                [weakSelf playVideoWithVideoPath:localPath];
            }
        }else{
            [weakSelf showHintHudWithMessage:NSLocalizedStringFromTable(@"message.videoFail", LIKELocalizeChat, @"video for failure!")];
        }
    } onQueue:nil];
}

- (void)playVideoWithVideoPath:(NSString *)videoPath
{
    _isScrollToBottom = NO;
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerController.moviePlayer prepareToPlay];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
}

// 图片的bubble被点击
-(void)chatImageCellBubblePressed:(MessageModel *)model
{
    __weak typeof(self) weakSelf = self;
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    if ([model.messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
        if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
            if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed)
            {
                //发送已读回执
                if ([self shouldAckMessage:model.message read:YES])
                {
                    [self sendHasReadResponseForMessages:@[model.message]];
                }
                NSString *localPath = model.message == nil ? model.localPath : [[model.message.messageBodies firstObject] localPath];
                if (localPath && localPath.length > 0) {
                    UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                    self.isScrollToBottom = NO;
                    if (image)
                    {
                        [self.messageReadManager showBrowserWithImages:@[image]];
                    }
                    else
                    {
                        NSLog(@"Read %@ failed!", localPath);
                    }
                    return ;
                }
            }
            [weakSelf showHintHudWithMessage:NSLocalizedStringFromTable(@"message.downloadingImage", LIKELocalizeChat, @"downloading a image...")];
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                [weakSelf hideHUD];
                if (!error) {
                    //发送已读回执
                    if ([weakSelf shouldAckMessage:model.message read:YES])
                    {
                        [weakSelf sendHasReadResponseForMessages:@[model.message]];
                    }
                    NSString *localPath = aMessage == nil ? model.localPath : [[aMessage.messageBodies firstObject] localPath];
                    if (localPath && localPath.length > 0) {
                        UIImage *image = [UIImage imageWithContentsOfFile:localPath];
                        weakSelf.isScrollToBottom = NO;
                        if (image)
                        {
                            [weakSelf.messageReadManager showBrowserWithImages:@[image]];
                        }
                        else
                        {
                            NSLog(@"Read %@ failed!", localPath);
                        }
                        return ;
                    }
                }
                [weakSelf showHintHudWithMessage:NSLocalizedStringFromTable(@"message.imageFail", LIKELocalizeChat, @"image for failure!")];
            } onQueue:nil];
        }else{
            //获取缩略图
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHintHudWithMessage:NSLocalizedStringFromTable(@"message.thumImageFail", LIKELocalizeChat, @"thumbnail for failure!")];
                }
                
            } onQueue:nil];
        }
    }else if ([model.messageBody messageBodyType] == eMessageBodyType_Video) {
        //获取缩略图
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)model.messageBody;
        if (videoBody.thumbnailDownloadStatus != EMAttachmentDownloadSuccessed) {
            [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    [weakSelf reloadTableViewDataWithMessage:model.message];
                }else{
                    [weakSelf showHintHudWithMessage:NSLocalizedStringFromTable(@"message.thumImageFail", LIKELocalizeChat, @"thumbnail for failure!")];
                }
            } onQueue:nil];
        }
    }
}

#pragma mark MenuItem actions

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (_longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        pasteboard.string = model.content;
    }
    
    _longPressIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (_longPressIndexPath && _longPressIndexPath.row > 0) {
        MessageModel *model = [self.dataSource objectAtIndex:_longPressIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
        [_conversation removeMessage:model.message];
        [self.messages removeObject:model.message];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
        if (_longPressIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row - 1)];
            if (_longPressIndexPath.row + 1 < [self.dataSource count]) {
                nextMessage = [self.dataSource objectAtIndex:(_longPressIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:_longPressIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataSource removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    _longPressIndexPath = nil;
}


#pragma mark - private methods

- (void)saveChatroom:(EMChatroom *)chatroom {
    NSString *chatroomName = chatroom.chatroomSubject ? chatroom.chatroomSubject : @"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:@"username" ]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatroom.chatroomId]) {
        [chatRooms setObject:chatroomName forKey:chatroom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
}

- (void)joinChatroom:(NSString *)chatroomId {
    [self showHintHudWithMessage:NSLocalizedStringFromTable(@"chatroom.joining", LIKELocalizeChat, @"Joining the chatroom")];
    __weak typeof(self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncJoinChatroom:chatroomId
                                                 completion:^(EMChatroom *chatroom,
                                                              EMError *error) {
                                                     if (weakSelf) {
                                                         LIKEChatViewController *strongSelf = weakSelf;
                                                         [strongSelf hideHUD];
                                                         if (error && (error.errorCode != EMErrorChatroomJoined)) {
                                                             [strongSelf showHintHudWithMessage:[NSString stringWithFormat:NSLocalizedStringFromTable(@"chatroom.joinFailed", LIKELocalizeChat, @"join chatroom \'%@\' failed"), chatroomId]];
                                                         }
                                                         else {
                                                             [strongSelf saveChatroom:chatroom];
                                                         }
                                                     }
                                                     else {
                                                         if (!error || (error.errorCode == EMErrorChatroomJoined)) {
                                                             [[EaseMob sharedInstance].chatManager asyncLeaveChatroom:chatroomId
                                                                                                           completion:^(EMChatroom *chatroom,
                                                                                                                        EMError *error){
                                                                                                               [[EaseMob sharedInstance].chatManager removeConversationByChatter:chatroomId
                                                                                                                                                                  deleteMessages:YES
                                                                                                                                                                     append2Chat:YES];
                                                                                                           }];
                                                         }
                                                     }
                                                 }];
}

- (void)loadMoreMessagesFrom:(long long)timestamp count:(NSInteger)count append:(BOOL)append
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf.conversation loadNumbersOfMessages:count before:timestamp];
        if ([messages count] > 0) {
            NSInteger currentCount = 0;
            if (append)
            {
                [weakSelf.messages insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                NSArray *formated = [weakSelf formatMessages:messages];
                id model = [weakSelf.dataSource firstObject];
                if ([model isKindOfClass:[NSString class]])
                {
                    NSString *timestamp = model;
                    [formated enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                        if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model])
                        {
                            [weakSelf.dataSource removeObjectAtIndex:0];
                            *stop = YES;
                        }
                    }];
                }
                currentCount = [weakSelf.dataSource count];
                [weakSelf.dataSource insertObjects:formated atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formated count])]];
                
                EMMessage *latest = [weakSelf.messages lastObject];
                weakSelf.chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)latest.timestamp];
            }
            else
            {
                weakSelf.messages = [messages mutableCopy];
                weakSelf.dataSource = [[weakSelf formatMessages:messages] mutableCopy];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
                
                [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - currentCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
            
            //从数据库导入时重新下载没有下载成功的附件
            for (EMMessage *message in messages)
            {
                [weakSelf downloadMessageAttachments:message];
            }
            
            NSMutableArray *unreadMessages = [NSMutableArray array];
            for (NSInteger i = 0; i < [messages count]; i++)
            {
                EMMessage *message = messages[i];
                if ([self shouldAckMessage:message read:NO])
                {
                    [unreadMessages addObject:message];
                }
            }
            if ([unreadMessages count])
            {
                [self sendHasReadResponseForMessages:unreadMessages];
            }
        }
    });
}

- (void)downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHintHudWithMessage:NSLocalizedStringFromTable(@"message.thumImageFail", LIKELocalizeChat, @"thumbnail for failure!")];
        }
    };
    
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    if ([messageBody messageBodyType] == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Video)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载缩略图
            [[[EaseMob sharedInstance] chatManager] asyncFetchMessageThumbnail:message progress:nil completion:completion onQueue:nil];
        }
    }
    else if ([messageBody messageBodyType] == eMessageBodyType_Voice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.attachmentDownloadStatus > EMAttachmentDownloadSuccessed)
        {
            //下载语言
            [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil];
        }
    }
}

- (NSArray *)formatMessages:(NSArray *)messagesArray
{
    NSMutableArray *formatArray = [[NSMutableArray alloc] init];
    if ([messagesArray count] > 0) {
        for (EMMessage *message in messagesArray) {
            NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
            if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
                [formatArray addObject:[createDate formattedTime]];
                self.chatTagDate = createDate;
            }
            
            MessageModel *model = [MessageModelManager modelWithMessage:message];
//            if ([_delegate respondsToSelector:@selector(nickNameWithChatter:)]) {
//                NSString *showName = [_delegate nickNameWithChatter:model.username];
//                model.nickName = showName?showName:model.username;
//            }else {
                model.nickName = model.username;
//            }
            
//            if ([_delegate respondsToSelector:@selector(avatarWithChatter:)]) {
//                model.headImageURL = [NSURL URLWithString:[_delegate avatarWithChatter:model.username]];
//            }
            
            if (model) {
                [formatArray addObject:model];
            }
        }
    }
    
    return formatArray;
}

-(NSMutableArray *)formatMessage:(EMMessage *)message
{
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    NSDate *createDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
    NSTimeInterval tempDate = [createDate timeIntervalSinceDate:self.chatTagDate];
    if (tempDate > 60 || tempDate < -60 || (self.chatTagDate == nil)) {
        [ret addObject:[createDate formattedTime]];
        self.chatTagDate = createDate;
    }
    
    MessageModel *model = [MessageModelManager modelWithMessage:message];
//    if ([_delegate respondsToSelector:@selector(nickNameWithChatter:)]) {
//        NSString *showName = [_delegate nickNameWithChatter:model.username];
//        model.nickName = showName?showName:model.username;
//    }else {
        model.nickName = model.username;
//    }
    
//    if ([_delegate respondsToSelector:@selector(avatarWithChatter:)]) {
//        model.headImageURL = [NSURL URLWithString:[_delegate avatarWithChatter:model.username]];
//    }
    
    if (model) {
        [ret addObject:model];
    }
    
    return ret;
}

-(void)addMessage:(EMMessage *)message
{
    [_messages addObject:message];
    __weak typeof(self) weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessage:message];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataSource count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (IBAction)back {
    //判断当前会话是否为空，若符合则删除该会话
    EMMessage *message = [_conversation latestMessage];
    if (message == nil) {
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:_conversation.chatter deleteMessages:NO append2Chat:YES];
    }
    
    [self performSegueWithIdentifier:@"chatUnwindSegue" sender:self];
}

- (IBAction)showRoomContact:(id)sender {
    [self.view endEditing:YES];
//    if (self.conversationType == eConversationTypeGroupChat) {
//        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:_chatter];
//        [self.navigationController pushViewController:detailController animated:YES];
//    }
//    else if (self.conversationType == eConversationTypeChatRoom) {
//        ChatroomDetailViewController *detailController = [[ChatroomDetailViewController alloc] initWithChatroomId:_chatter];
//        [self.navigationController pushViewController:detailController animated:YES];
//    }
}

- (IBAction)removeAllMessages:(id)sender {
    if (_dataSource.count == 0) {
        [self showHintHudWithMessage:NSLocalizedStringFromTable(@"message.noMessage", LIKELocalizeChat, @"no messages")];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        if (self.isChatGroup && [groupId isEqualToString:_conversation.chatter]) {
            [_conversation removeAllMessages];
            [_messages removeAllObjects];
            _chatTagDate = nil;
            [_dataSource removeAllObjects];
            [_tableView reloadData];
            [self showHintHudWithMessage:NSLocalizedStringFromTable(@"message.noMessage", LIKELocalizeChat, @"no messages")];
        }
    }
    else{
        __weak typeof(self) weakSelf = self;
        
        [EMAlertView showAlertWithTitle:NSLocalizedStringFromTable(@"prompt", LIKELocalizeChat, @"Prompt")
                                message:NSLocalizedStringFromTable(@"sureToDelete", LIKELocalizeChat, @"please make sure to delete")
                        completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                            if (buttonIndex == 1) {
                                [weakSelf.conversation removeAllMessages];
                                [weakSelf.messages removeAllObjects];
                                weakSelf.chatTagDate = nil;
                                [weakSelf.dataSource removeAllObjects];
                                [weakSelf.tableView reloadData];
                            }
                        } cancelButtonTitle:NSLocalizedStringFromTable(@"cancel", LIKELocalizeChat, @"Cancel")
                      otherButtonTitles:NSLocalizedStringFromTable(@"ok", LIKELocalizeChat, @"OK"), nil];
    }
}

#pragma mark - helper
- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

- (void)stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    MessageModel *playingModel = [self.messageReadManager stopMessageAudioModel];
    NSIndexPath *indexPath = nil;
    if (playingModel) {
        indexPath = [NSIndexPath indexPathForRow:[self.dataSource indexOfObject:playingModel] inSection:0];
    }
    
    if (indexPath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
        });
    }
}

#pragma mark send message

-(void)sendTextMessage:(NSString *)textMessage
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendTextMessageWithString:textMessage
                                                            toUsername:_conversation.chatter
                                                           messageType:[self messageType]
                                                     requireEncryption:NO
                                                                   ext:ext];
    [self addMessage:tempMessage];
}

-(void)sendImageMessage:(UIImage *)image
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendImageMessageWithImage:image
                                                            toUsername:_conversation.chatter
                                                           messageType:[self messageType]
                                                     requireEncryption:NO
                                                                   ext:ext];
    [self addMessage:tempMessage];
}

-(void)sendAudioMessage:(EMChatVoice *)voice
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendVoice:voice
                                            toUsername:_conversation.chatter
                                           messageType:[self messageType]
                                     requireEncryption:NO ext:ext];
    [self addMessage:tempMessage];
}

-(void)sendVideoMessage:(EMChatVideo *)video
{
    NSDictionary *ext = nil;
    EMMessage *tempMessage = [ChatSendHelper sendVideo:video
                                            toUsername:_conversation.chatter
                                           messageType:[self messageType]
                                     requireEncryption:NO ext:ext];
    [self addMessage:tempMessage];
}

- (void)sendHasReadResponseForMessages:(NSArray*)messages
{
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:message];
        }
    });
}

- (void)markMessagesAsRead:(NSArray*)messages
{
    EMConversation *conversation = _conversation;
    dispatch_async(_messageQueue, ^{
        for (EMMessage *message in messages)
        {
            [conversation markMessageWithId:message.messageId asRead:YES];
        }
    });
}


- (void)showMenuViewController:(UIView *)showInView andIndexPath:(NSIndexPath *)indexPath messageType:(MessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"copy", LIKELocalizeChat, @"Copy") action:@selector(copyMenuAction:)];
    }
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedStringFromTable(@"delete", LIKELocalizeChat, @"Delete") action:@selector(deleteMenuAction:)];
    }
    
    if (messageType == eMessageBodyType_Text) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    }
    else{
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self addMessage:message];
        [[EaseMob sharedInstance].chatManager insertMessageToDB:message append2Chat:YES];
    }
}

- (void)applicationDidEnterBackground
{
    [_chatToolBar cancelTouchRecord];
    
    // 设置当前conversation的所有message为已读
    [_conversation markAllMessagesAsRead:YES];
}

- (BOOL)shouldAckMessage:(EMMessage *)message read:(BOOL)read
{
    NSString *account = [[EaseMob sharedInstance].chatManager loginInfo][kSDKUsername];
    if (message.messageType != eMessageTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible)
    {
        return NO;
    }
    
    id<IEMMessageBody> body = [message.messageBodies firstObject];
    if (((body.messageBodyType == eMessageBodyType_Video) ||
         (body.messageBodyType == eMessageBodyType_Voice) ||
         (body.messageBodyType == eMessageBodyType_Image)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)shouldMarkMessageAsRead
{
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || self.isInvisible)
    {
        return NO;
    }
    
    return YES;
}

- (EMMessageType)messageType
{
    EMMessageType type = eMessageTypeChat;
    switch (_conversationType) {
        case eConversationTypeChat:
            type = eMessageTypeChat;
            break;
        case eConversationTypeGroupChat:
            type = eMessageTypeGroupChat;
            break;
        case eConversationTypeChatRoom:
            type = eMessageTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

#pragma mark - accessor methods

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (SSPullToRefreshView *)refreshView {
    if (!_refreshView) {
        _refreshView = [[SSPullToRefreshView alloc] initWithScrollView:self.tableView delegate:self];
    }
    return _refreshView;
}

- (DXMessageToolBar *)chatToolBar {
    if (_chatToolBar == nil) {
        _chatToolBar = [[DXMessageToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [DXMessageToolBar defaultHeight], self.view.frame.size.width, [DXMessageToolBar defaultHeight])];
        _chatToolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
        _chatToolBar.delegate = self;
        
        ChatMoreType type = self.isChatGroup == YES ? ChatMoreTypeGroupChat : ChatMoreTypeChat;
        _chatToolBar.moreView = [[DXChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), _chatToolBar.frame.size.width, 80) type:type];
        _chatToolBar.moreView.backgroundColor = [UIColor like_moreViewBackgroundColor];
        _chatToolBar.moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    return _chatToolBar;
}

- (UIImagePickerController *)imagePicker {
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (MessageReadManager *)messageReadManager {
    if (_messageReadManager == nil) {
        _messageReadManager = [MessageReadManager defaultManager];
    }
    
    return _messageReadManager;
}

- (NSDate *)chatTagDate {
    if (_chatTagDate == nil) {
        _chatTagDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:0];
    }
    
    return _chatTagDate;
}

#pragma mark - api methods

- (void)hideImagePicker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    self.isInvisible = NO;
}

- (void)reloadData {
    _chatTagDate = nil;
    self.dataSource = [[self formatMessages:self.messages] mutableCopy];
    [self.tableView reloadData];
    
    //回到前台时
    if (!self.isInvisible)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messages)
        {
            if ([self shouldAckMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self sendHasReadResponseForMessages:unreadMessages];
        }
        
        [_conversation markAllMessagesAsRead:YES];
    }
}

@end
