//
//  SelectionButtonView.m
//  text
//
//  Created by wanglei on 2017/7/5.
//  Copyright © 2017年 wanglei. All rights reserved.
//

#import "SelectionButtonView.h"

@implementation SelectionButtonView

- (instancetype) init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(100, 100, 54, 34);
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 11;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:255/255.f green:115/255.f blue:62/255.f alpha:1].CGColor;
        
        NSArray *array = @[@"全部",@"近一年",@"近一月",@"近一周"];
        for (int i = 0; i < 4; i ++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 34 * i, 54, 34);
            [button setTitle:array[i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithRed:255/255.f green:115/255.f blue:62/255.f alpha:1] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            button.tag = 1000 + i;
            [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            if (i != 3) {
                UIView *line = [[UIView alloc] initWithFrame:CGRectMake(5, 34 * (i + 1), 44, 1)];
                line.backgroundColor = [UIColor colorWithRed:255/255.f green:115/255.f blue:62/255.f alpha:1];
                [self addSubview:line];
            }
        }
        
        [UIView animateWithDuration:2 animations:^{
            CGRect frame = self.frame;
            frame.size.height = 134;
            self.frame = frame;
        }];
    }
    return self;
}

- (void)buttonClick:(UIButton *)sender{
    if (self.clickBlock) {
        self.clickBlock(sender.tag - 1000);
    }
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
