//
//  ViewController.h
//  Music
//
//  Created by XiangChenyu on 14-6-30.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"

@interface ViewController : UIViewController<UIScrollViewDelegate,PSCollectionViewDataSource,PSCollectionViewDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong) PSCollectionView *psCollectionView;

@end
