//
//  SelectionButtonView.h
//  text
//
//  Created by wanglei on 2017/7/5.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectionButtonViewBlock)(NSInteger index); //@[@"全部",@"近一年",@"近一月",@"近一周"]

@interface SelectionButtonView : UIView


@property (nonatomic, copy) SelectionButtonViewBlock clickBlock;

@end
