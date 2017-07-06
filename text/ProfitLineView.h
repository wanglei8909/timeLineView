//
//  ProfitLineView.h
//  HNNniu
//
//  Created by wanglei on 2017/7/5.
//  Copyright © 2017年 HaiNa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrategyModelProfit_Data.h"

@protocol ProfitLineViewDataSource<NSObject>

@required

- (NSArray<StrategyModelProfit_Data *> *)ProfitLineViewDataList;


@end


@interface ProfitLineView : UIView

@property (nonatomic, assign) CGFloat lineWidth; //主线宽
@property (nonatomic, assign) CGFloat boardLineWidth; //背景边框线宽
@property (nonatomic, assign) CGFloat backLineWidth; //网格线宽
@property (nonatomic, strong) UIColor *boardColor; //背景线条颜色
@property (nonatomic, strong) UIColor *lineColor; //主线颜色
@property (nonatomic, strong) UIColor *shadowColor; // 阴影颜色
@property (nonatomic, assign) CGFloat startLeft;
@property (nonatomic, assign) CGFloat startTop;

@property (nonatomic, weak) id<ProfitLineViewDataSource> dataSoure;


- (void)reloadData;


@end






