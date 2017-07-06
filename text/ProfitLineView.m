//
//  ProfitLineView.m
//  HNNniu
//
//  Created by wanglei on 2017/7/5.
//  Copyright © 2017年 HaiNa. All rights reserved.
//

#import "ProfitLineView.h"

@interface ProfitLineView()

@property (nonatomic, copy) NSArray *dataList;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat unitX;
@property (nonatomic, assign) CGFloat unitY;

@end

@implementation ProfitLineView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
    
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup{
    _startLeft = 0;
    _startTop = 0;
    _boardColor = [UIColor colorWithRed:249/255.f green:249/255.f blue:249/255.f alpha:1];
    _lineWidth = 1;
    _lineColor = [UIColor colorWithRed:138/255.f green:153/255.f blue:235/255.f alpha:1];
    _shadowColor = [UIColor colorWithRed:24/255.0 green:96/255.0 blue:254/255.0 alpha:1.0];;
    _backLineWidth = 1;
    _boardLineWidth = 1;
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawGridBackground:context];
    [self drawFrontLine:context];
}

- (void)drawFrontLine:(CGContextRef)context{
    CGMutablePathRef fillPath = CGPathCreateMutable();
    for (int i = 0; i < _dataList.count-1; i ++) {
        CGFloat preStart = _maxValue - [[_dataList[i] valueForKey:@"profit"] floatValue];
        CGFloat startY = preStart * _unitY + _startTop;
        CGFloat preEnd = _maxValue - [[_dataList[i+1] valueForKey:@"profit"] floatValue];
        CGFloat endY = preEnd * _unitY + _startTop;

        CGPoint startPoint = CGPointMake(i * _unitX + _startLeft, startY);
        CGPoint endPoint = CGPointMake((i+1) * _unitX + _startLeft, endY);
        [self drawline:context startPoint:startPoint stopPoint:endPoint color:_lineColor lineWidth:_lineWidth];
        
        if (0 == i) {
            CGPathMoveToPoint(fillPath, NULL, _startLeft, self.frame.size.height);
            CGPathAddLineToPoint(fillPath, NULL, startPoint.x,startPoint.y);
            CGPathAddLineToPoint(fillPath, NULL, endPoint.x, endPoint.y);
        }else{
            CGPathAddLineToPoint(fillPath, NULL, endPoint.x, endPoint.y);
        }
        if ((_dataList.count-2) == i) {
            CGPathAddLineToPoint(fillPath, NULL, endPoint.x, self.frame.size.height);
            CGPathCloseSubpath(fillPath);
        }
    }
    
    [self drawLinearGradient:context path:fillPath alpha:0.5f startColor:_shadowColor.CGColor endColor:[UIColor whiteColor].CGColor];
    
    CGPathRelease(fillPath);
}

- (void)drawLinearGradient:(CGContextRef)context
                      path:(CGPathRef)path
                     alpha:(CGFloat)alpha
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGRect pathRect = CGPathGetBoundingBox(path);
    //具体方向可根据需求修改
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClip(context);
    CGContextSetAlpha(context, alpha);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)reloadData{
    [self setCurrentData];
    [self setNeedsDisplay];
}

- (void)setCurrentData{
    _dataList = [self.dataSoure performSelector:@selector(ProfitLineViewDataList)];
    //算最大最小值
    _maxValue = [[[_dataList firstObject] valueForKey:@"profit"] floatValue];
    _minValue = [[[_dataList firstObject] valueForKey:@"profit"] floatValue];
    for (StrategyModelProfit_Data *data in _dataList) {
        CGFloat value = [data.profit floatValue];
        _maxValue = _maxValue > value?_maxValue:value;
        _minValue = _minValue < value?_minValue:value;
    }

    CGFloat volume = (_maxValue - _minValue);
    _unitY = (self.frame.size.height - _startTop)/volume;
    _unitX = (self.frame.size.width - _startLeft)/(_dataList.count - 1);
}

- (void)drawGridBackground:(CGContextRef)context{
    [self drawline:context startPoint:CGPointMake(_startLeft, _startTop) stopPoint:CGPointMake(self.size.width, _startTop) color:_boardColor lineWidth:_boardLineWidth];
    [self drawline:context startPoint:CGPointMake(self.size.width, _startTop) stopPoint:CGPointMake(self.size.width, self.frame.size.height) color:_boardColor lineWidth:_boardLineWidth];
    [self drawline:context startPoint:CGPointMake(self.size.width, self.frame.size.height) stopPoint:CGPointMake(_startLeft, self.frame.size.height) color:_boardColor lineWidth:_boardLineWidth];
    [self drawline:context startPoint:CGPointMake(_startLeft, self.frame.size.height) stopPoint:CGPointMake(_startLeft, _startTop) color:_boardColor lineWidth:_boardLineWidth];
    for (int i = 0 ; i < 3; i++) {
        [self drawDashline:context startPoint:CGPointMake(_startLeft, _startTop + (i + 1)*(self.frame.size.height - _startTop)/4) stopPoint:CGPointMake(self.frame.size.width, _startTop + (i + 1)*(self.frame.size.height - _startTop)/4) color:_boardColor lineWidth:_backLineWidth];
    }
    for (int i = 0; i < 7; i ++) {
        [self drawDashline:context startPoint:CGPointMake(_startLeft + (i + 1) * (self.frame.size.width - _startLeft)/8, _startTop) stopPoint:CGPointMake(_startLeft + (i + 1) * (self.frame.size.width - _startLeft)/8, self.frame.size.height) color:_boardColor lineWidth:_backLineWidth];
    }
}

- (void)drawline:(CGContextRef)context
      startPoint:(CGPoint)startPoint
       stopPoint:(CGPoint)stopPoint
           color:(UIColor *)color
       lineWidth:(CGFloat)lineWitdth
{
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWitdth);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, stopPoint.x,stopPoint.y);
    CGContextSetLineDash(context, 0, NULL, 0);
    CGContextStrokePath(context);
}

- (void)drawDashline:(CGContextRef)context
      startPoint:(CGPoint)startPoint
       stopPoint:(CGPoint)stopPoint
           color:(UIColor *)color
       lineWidth:(CGFloat)lineWitdth
{
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, lineWitdth);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, startPoint.x, startPoint.y);
    CGContextAddLineToPoint(context, stopPoint.x,stopPoint.y);
    CGContextSetLineJoin(context,kCGLineJoinMiter);
    CGFloat lengths[] = {2,1};
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextStrokePath(context);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
