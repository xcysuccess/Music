//
//  ViewControl.h
//  Music
//
//  Created by XiangChenyu on 14-7-2.
//  Copyright (c) 2014年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ViewControl : NSObject

-(void) setUIViewSelected : (BOOL) bSelected index : (int) index;
-(BOOL) getUIViewSelected : (int) index;


@end
