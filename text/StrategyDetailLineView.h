//
//  StrategyDetailLineView.h
//  HNNniu
//
//  Created by wanglei on 2017/7/5.
//  Copyright © 2017年 HaiNa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrategyModelProfit_Data.h"

@protocol StrategyDetailLineViewDataSource<NSObject>

@required

- (NSArray<StrategyModelProfit_Data *> *)StrategyDetailLineViewDataList;


@end

@interface StrategyDetailLineView : UIView

@property (nonatomic, weak) id<StrategyDetailLineViewDataSource> dataSoure;

- (void)reloadData;


@end
