//
//  ViewController.m
//  Music
//
//  Created by XiangChenyu on 14-6-30.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import "ViewController.h"
#import "ViewControl.h"
#import <AudioToolbox/AudioToolbox.h>
#include <AVFoundation/AVFoundation.h>

static  int const Cols_Sum  = 8;
static  int const Lines_Sum = 12;
static  int const View_Height = (320-89) * 1.f / 8;

@interface ViewController ()<AVAudioPlayerDelegate>
{
    NSTimer * timer;
    ViewControl * viewControl;
    NSMutableArray *arrayCells;
    AVAudioPlayer* playerr;
//    dispatch_source_t gcdTimer;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;

	// Do any additional setup after loading the view, typically from a nib.
    [self initCollectview];
    [self initData];
}

- (void) initCollectview
{
    _psCollectionView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0 , 20, self.view.frame.size.height, self.view.frame.size.width - 20)];
    self.psCollectionView.delegate = self;
    self.psCollectionView.collectionTouchDelegate = self;
    self.psCollectionView.collectionViewDelegate = self;
    self.psCollectionView.collectionViewDataSource = self;
    self.psCollectionView.backgroundColor = [UIColor grayColor];
    self.psCollectionView.autoresizingMask = UIViewAutoresizingNone;
    
    self.psCollectionView.numColsPortrait = Cols_Sum;
    self.psCollectionView.numColsLandscape = Lines_Sum;
    
    self.psCollectionView.scrollEnabled = FALSE;
    [self.view addSubview:self.psCollectionView];
}

//页面开启
-(void)viewWillAppear:(BOOL)animated
{
    //开启定时器
//    [timer setFireDate:[NSDate distantPast]];
}

//页面消失，进入后台不显示该页面，关闭定时器
-(void) viewDidDisappear : (BOOL)animated
{
//    [timer setFireDate:[NSDate distantFuture]];
//    timer = nil;
}
- (void)dealloc
{
    //取消定时器
    [timer invalidate];
    timer = nil;
}
- (void) playSound : (int) soundIdx
{
    NSString *path = [[NSBundle mainBundle] pathForResource : [NSString stringWithFormat:@"%d",soundIdx+1] ofType:@"mp3"]; //音乐文件路径
    NSError* err;
    playerr = [[AVAudioPlayer alloc]
                             initWithContentsOfURL:[NSURL fileURLWithPath:path]
                             error:&err ];//使用本地URL创建
    [playerr prepareToPlay];//分配播放所需的资源，并将其加入内部播放队列
    [playerr play];
}

- (void) initData
{
    NSThread* timerThread = [[NSThread alloc] initWithTarget:self selector:@selector(timerStart) object:nil];
    [timerThread start];
    
    viewControl = [[ViewControl alloc] init];
    arrayCells = [NSMutableArray array];
}

- (void)timerStart
{
    @autoreleasepool {
        NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setEvent) userInfo:nil repeats:YES];
        [runLoop run];
    }
}
- (void)timerFire
{
    [self setEvent];
    [timer invalidate];
    timer = nil;
}


- (void) setEvent
{
    for(int i = 0 ;i < 12; ++i)
    {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        for(int j = 0; j < 8; ++j)
        {
            int index = i + j * 12;
            if([viewControl getUIViewSelected:index])
            {
                [dic setValue:@"true" forKey:[NSString stringWithFormat:@"%d",index]];
            }
        }
        
        __block bool isPlayCol = false;
        __weak typeof(self) myself = self;
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            PSCollectionViewCell *cell = [arrayCells objectAtIndex : [key intValue]];
            isPlayCol = [myself setCellState:cell index:[key intValue]];
        }];
        if(isPlayCol == true)
            [NSThread  sleepForTimeInterval:.5f];
    }
    
    [self.psCollectionView reloadData];
}

-(bool) setCellState : (PSCollectionViewCell *) cell index : (int) index
{
    __weak UIView *view = [cell.subviews objectAtIndex:0];
    NSLog(@"index-->%d",index);
    if([viewControl getUIViewSelected : index])
    {
        __weak typeof(self) myself = self;
        [myself playSound : index/ 8];
        dispatch_async(dispatch_get_main_queue(), ^{
            [myself addAnimation:view];
            [myself setViewState : view index:index];
        });
        
        return true;
    }
    return false;
}
-(void) addAnimation : (UIView*) hintView
{
    /* 出现动画 */
    CATransform3D transform = CATransform3DMakeScale(0.001, 0.001, 1.0);
    hintView.layer.transform = transform;
    hintView.alpha = 0;
    transform = CATransform3DMakeScale(1.0, 1.0, 1.0);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    hintView.layer.transform = transform;
    hintView.alpha = 1;
    [UIView commitAnimations];
//    /* 消失动画 */
//    CATransform3D transform2 = CATransform3DMakeScale(0.001, 0.001, 0.001);
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelay:0.0];
//    [UIView setAnimationDuration:.5];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    hintView.layer.transform = transform2;
//    hintView.alpha = 0;
//    [UIView commitAnimations];
}
#pragma mark -- psCollectionView delegate
- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView cellForRowAtIndex:(NSInteger)index
{
    PSCollectionViewCell *cell = nil;
    if (arrayCells.count > index)
    {
         cell = [arrayCells objectAtIndex:index];
    }
    
    
    if (!cell) {
        cell = [[PSCollectionViewCell alloc] initWithFrame:CGRectZero];
        [arrayCells addObject : cell];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,0,43,33)];
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black"]];
        [cell addSubview : view];


        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        view.tag = index;
        [view addGestureRecognizer:tap];
    }
    return cell;
}

- (CGFloat)collectionView:(PSCollectionView *)collectionView heightForRowAtIndex:(NSInteger)index
{
    return View_Height;
}

-(NSInteger)numberOfRowsInCollectionView:(PSCollectionView *)collectionView
{
    return Cols_Sum * Lines_Sum;

}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void) tapView : (UIGestureRecognizer*) ges
{
    int index = (int)ges.view.tag;
    BOOL isSelected = ![viewControl getUIViewSelected:index];
    [viewControl setUIViewSelected : isSelected index:index];
    [self setViewState : ges.view index:index];
}

//ges tap
- (void) setViewState : (UIView*) view index : (int) index
{
    BOOL isSelected = [viewControl getUIViewSelected:index];
    if(isSelected)
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white"]];
    else
        view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"black"]];

    view.layer.cornerRadius = 5;//设置那个圆角的有多圆
}


//touch
- (void) setViewSelected : (UIView*) view index : (int) index
{
    [viewControl setUIViewSelected:YES index:index];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"white"]];
    view.layer.cornerRadius = 5;//设置那个圆角的有多圆
}
#pragma mark--touchmove delegate
- (void)collectionTouchMove:(PSCollectionView *)collectionView touchPoint: (CGPoint) point
{
    typeof(self) myself = self;
    [arrayCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PSCollectionViewCell *cell = [arrayCells objectAtIndex : idx];
        if(CGRectContainsPoint(cell.frame, point))
        {
            [myself setViewSelected : [cell.subviews objectAtIndex:0] index:(int)idx];
        }
    }];
}



@end
