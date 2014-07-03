//
//  ViewControl.m
//  Music
//
//  Created by XiangChenyu on 14-7-2.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import "ViewControl.h"
@interface ViewControl()
{
    BOOL mulUIViewState[100];
}
@end

@implementation ViewControl
- (instancetype)init
{
    self = [super init];
    if (self) {
        for (int i = 0 ; i < sizeof(mulUIViewState)/sizeof(mulUIViewState[0]); ++i)
        {
            mulUIViewState[i] = FALSE;
        }
    };
    return self;
}

-(void) setUIViewSelected : (BOOL) bSelected index : (int) index
{
    mulUIViewState[index] = bSelected;
}
-(BOOL) getUIViewSelected : (int) index
{
    return mulUIViewState[index];
}

@end
