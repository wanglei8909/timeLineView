//
//  StrategyDetailLineView.m
//  HNNniu
//
//  Created by wanglei on 2017/7/5.
//  Copyright © 2017年 HaiNa. All rights reserved.
//

#import "StrategyDetailLineView.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>
#import "SelectionButtonView.h"

@interface StrategyDetailLineView ()

@property (nonatomic, copy) NSArray<StrategyModelProfit_Data *> *dataList;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *boardColor;
@property (nonatomic, strong) UIColor *hsColor;
@property (nonatomic, strong) UIColor *clColor;
@property (nonatomic, assign) CGFloat startLeft;
@property (nonatomic, assign) CGFloat startTop;
@property (nonatomic, assign) CGFloat botomHeight;//图底距离view底部距离
//@property (nonatomic, assign) CGFloat hsMaxValue;
//@property (nonatomic, assign) CGFloat hsMinValue;
//@property (nonatomic, assign) CGFloat clMaxValue;
//@property (nonatomic, assign) CGFloat clMinValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat unitX;
@property (nonatomic, assign) CGFloat unitY;
@property (nonatomic, strong) UILabel *startTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UILabel *maxYLabel;
@property (nonatomic, strong) UILabel *minYLabel;
@property (nonatomic, strong) UIPanGestureRecognizer * panGesture;
@property (nonatomic, assign) BOOL showMidLine;
@property (nonatomic, assign) CGFloat midLineX;
@property (nonatomic, assign) CGFloat midLineY;
@property (nonatomic, strong) UILabel *dynamicXLabel;//时间
@property (nonatomic, strong) UILabel *dynamicYLabel;//净值
@property (nonatomic, copy) NSString *vValueString;
@property (nonatomic, copy) NSString *hValueString;
@property (nonatomic, strong) SelectionButtonView *seletionView;

@end

@implementation StrategyDetailLineView

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
    self.backgroundColor = [UIColor whiteColor];
    _showMidLine = NO;
    _startLeft = 20;
    _startTop = 35;
    _botomHeight = 50;
    _lineWidth = 1;
    _boardColor = [UIColor lightGrayColor];
    _hsColor = [UIColor colorWithRed:142/255.f green:150/255.f blue:255/255.f alpha:1];
    _clColor = [UIColor colorWithRed:255/255.f green:193/255.f blue:119/255.f alpha:1];
    [self setUpUI];
    
    [self addGestureRecognizer:self.panGesture];
}

- (void)reloadData{
    [self setCurrentData];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self drawBG:context];
    [self drawFrontLine:context];
}

- (void)drawFrontLine:(CGContextRef)context{

    for (int i = 0; i < _dataList.count-1; i ++) {
        CGFloat preStart = _maxValue - [[_dataList[i] valueForKey:@"profit"] floatValue];
        CGFloat startY = preStart * _unitY + _startTop;
        CGFloat preEnd = _maxValue - [[_dataList[i+1] valueForKey:@"profit"] floatValue];
        CGFloat endY = preEnd * _unitY + _startTop;
        
        CGPoint startPoint = CGPointMake(i * _unitX + _startLeft, startY);
        CGPoint endPoint = CGPointMake((i+1) * _unitX + _startLeft, endY);
        [self drawline:context startPoint:startPoint stopPoint:endPoint color:_clColor lineWidth:_lineWidth];
        
        CGFloat hsPreStart = _maxValue - [[_dataList[i] valueForKey:@"zsprofit"] floatValue];
        CGFloat hsStartY = hsPreStart * _unitY + _startTop;
        CGFloat hsPreEnd = _maxValue - [[_dataList[i+1] valueForKey:@"zsprofit"] floatValue];
        CGFloat hsEndY = hsPreEnd * _unitY + _startTop;
        
        CGPoint hsStartPoint = CGPointMake(i * _unitX + _startLeft, hsStartY);
        CGPoint hsEndPoint = CGPointMake((i+1) * _unitX + _startLeft, hsEndY);
        [self drawline:context startPoint:hsStartPoint stopPoint:hsEndPoint color:_hsColor lineWidth:_lineWidth];
    }
    
    //画0线（如果在范围内）
    if (_maxValue>0 && _minValue<0) {
        CGFloat preStart = _maxValue;
        CGFloat Y = preStart * _unitY + _startTop;
        [self drawline:context startPoint:CGPointMake(_startLeft, Y) stopPoint:CGPointMake(self.frame.size.width - _startLeft, Y) color:_boardColor lineWidth:1];
        NSMutableAttributedString * zero = [[NSMutableAttributedString alloc]initWithString:@"0" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSBackgroundColorAttributeName:[UIColor clearColor]}];
        [zero drawInRect:CGRectMake(_startLeft+2, Y, 10, 10)];
        
    }
    
    //十字线
    if (_showMidLine) {
        [self drawDashline:context startPoint:CGPointMake(_startLeft, _midLineY) stopPoint:CGPointMake(self.frame.size.width - _startLeft, _midLineY) color:_boardColor lineWidth:1];
        [self drawDashline:context startPoint:CGPointMake(_midLineX, _startTop) stopPoint:CGPointMake(_midLineX, self.frame.size.height - _botomHeight) color:_boardColor lineWidth:1];
        
//        NSMutableAttributedString * hValue = [[NSMutableAttributedString alloc]initWithString:_hValueString attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSBackgroundColorAttributeName:[UIColor clearColor]}];
//        NSMutableAttributedString * vValue = [[NSMutableAttributedString alloc]initWithString:_vValueString attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSBackgroundColorAttributeName:[UIColor clearColor]}];
//        [hValue drawInRect:CGRectMake(_midLineX- 25, self.height - _botomHeight-10, 60, 13)];
//        [vValue drawInRect:CGRectMake(_startLeft, _midLineY, 100, 13)];
    }
}

- (void)setCurrentData{
    _dataList = [self.dataSoure performSelector:@selector(StrategyDetailLineViewDataList)];
    if (_dataList.count > 0) {
        _dataList = [[_dataList reverseObjectEnumerator] allObjects];
        //算最大最小值
        CGFloat _clMaxValue = [[[_dataList firstObject] valueForKey:@"profit"] floatValue];
        CGFloat _clMinValue = [[[_dataList firstObject] valueForKey:@"profit"] floatValue];
        
        CGFloat _hsMaxValue = [[[_dataList firstObject] valueForKey:@"zsprofit"] floatValue];
        CGFloat _hsMinValue = [[[_dataList firstObject] valueForKey:@"zsprofit"] floatValue];
        for (StrategyModelProfit_Data *data in _dataList) {
            CGFloat value = [data.profit floatValue];
            _clMaxValue = _clMaxValue > value?_clMaxValue:value;
            _clMinValue = _clMinValue < value?_clMinValue:value;
            CGFloat hsValue = [data.zsprofit floatValue];
            _hsMaxValue = _hsMaxValue > hsValue?_hsMaxValue:hsValue;
            _hsMinValue = _hsMinValue < hsValue?_hsMinValue:hsValue;
        }
        _maxValue = _clMaxValue > _hsMaxValue?_clMaxValue:_hsMaxValue;
        _minValue = _clMinValue < _hsMinValue?_clMinValue:_hsMinValue;
        CGFloat volume = (_maxValue - _minValue);
        _unitY = (self.frame.size.height - _startTop - _botomHeight)/volume;
        _unitX = (self.frame.size.width - _startLeft * 2)/(_dataList.count - 1);
    }
    
    self.startTimeLabel.text = [[_dataList firstObject] valueForKey:@"date"];
    self.endTimeLabel.text = [[_dataList lastObject] valueForKey:@"date"];
    self.maxYLabel.text = [NSString stringWithFormat:@"%.2f%%",_maxValue];
    self.minYLabel.text = [NSString stringWithFormat:@"%.2f%%",_minValue];
}

- (void)drawBG: (CGContextRef)context{
    [self drawDashline:context startPoint:CGPointMake(_startLeft, self.frame.size.height - _botomHeight) stopPoint:CGPointMake(_startLeft, _startTop) color:_boardColor lineWidth:1];
    [self drawDashline:context startPoint:CGPointMake(_startLeft, self.frame.size.height - _botomHeight) stopPoint:CGPointMake(self.frame.size.width - _startLeft, self.frame.size.height - _botomHeight) color:_boardColor lineWidth:1];
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

- (void)setUpUI{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, _startTop)];
    label.textColor = [UIColor colorWithRGB:0xB7B7B7];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.text = @"— 收益曲线 —";
    [self addSubview:label];
    
    UIImageView *light_wl = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"light_wl"]];
    light_wl.left = _startLeft;
    light_wl.top = self.height - 23;
    [self addSubview:light_wl];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(light_wl.right+5, light_wl.top, self.width - 60, 11)];
    label.centerY = light_wl.centerY;
    label.textColor = [UIColor colorWithRGB:0xB7B7B7];
    label.font = [UIFont systemFontOfSize:11];
    label.text = @"历史业绩仅为说明产品功能，不构成未来投资建议或保证。";
    [self addSubview:label];
    
    UIView *tipsView = [[UIView alloc] initWithFrame:CGRectMake(self.width*0.5-50, self.height - _botomHeight + 8, 6, 6)];
    tipsView.backgroundColor = _hsColor;
    [self addSubview:tipsView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(tipsView.right+5, light_wl.top, 60, 11)];
    label.centerY = tipsView.centerY;
    label.textColor = [UIColor colorWithRGB:0xB7B7B7];
    label.font = [UIFont systemFontOfSize:11];
    label.text = @"沪深300";
    [self addSubview:label];
    
    tipsView = [[UIView alloc] initWithFrame:CGRectMake(self.width*0.5+10, self.height - _botomHeight + 8, 6, 6)];
    tipsView.backgroundColor = _clColor;
    [self addSubview:tipsView];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(tipsView.right+5, light_wl.top, 60, 11)];
    label.centerY = tipsView.centerY;
    label.textColor = [UIColor colorWithRGB:0xB7B7B7];
    label.font = [UIFont systemFontOfSize:11];
    label.text = @"策略";
    [self addSubview:label];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.width - 54 - _startLeft, 10, 54, 22);
    [button setImage:[UIImage imageNamed:@"Group 15"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showSelectionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)showSelectionClick:(UIButton *)sender{
    if (!_seletionView) {
        _seletionView= [[SelectionButtonView alloc] initWithPosition:sender.frame.origin];
        _seletionView.clickBlock = ^(NSInteger index){
            
        };
        [self addSubview:_seletionView];
    }
    _seletionView.hidden = NO;
}

- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureAction:)];
    }
    return _panGesture;
}
- (void)handlePanGestureAction:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self];
//    if (!CGRectContainsPoint(CGRectMake(_startLeft, _startTop, self.width - 2*_startLeft, self.height-_startTop-_botomHeight), point)) {
//        return;
//    }
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _showMidLine = YES;
        _dynamicXLabel.hidden = NO;
        _dynamicYLabel.hidden = NO;
    }
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
    }
    _midLineX = point.x;
    _midLineY = point.y;
    if (point.x < _startLeft)                   _midLineX = _startLeft;
    if (point.x > self.width - _startLeft)      _midLineX = self.width - _startLeft;
    if (point.y < _startTop)                    _midLineY = _startTop;
    if (point.y > self.height-_botomHeight)     _midLineY = self.height-_botomHeight;
    
    CGPoint localPoint = CGPointMake(_midLineX - _startLeft, _midLineY - _startTop);
    _vValueString = [NSString stringWithFormat:@"%.2f%%",_maxValue - localPoint.y/_unitY];
    
    NSInteger dateIndex = localPoint.x/(self.width/_dataList.count);
    if (dateIndex<0)                dateIndex = 0;
    if (dateIndex>_dataList.count)  dateIndex=_dataList.count;
    _hValueString = [_dataList[dateIndex] valueForKey:@"date"];
    
    self.dynamicXLabel.text = _hValueString;
    self.dynamicYLabel.text = _vValueString;
    //计算滑动时显示文本的位置
    if (_midLineX > self.width * 0.5) _dynamicYLabel.left = _startLeft;
    if (_midLineX < self.width * 0.5) _dynamicYLabel.right = self.width - _startLeft;
    
    CGFloat textX = _midLineX;
    CGFloat textY = _midLineY;
    if (textX - _startLeft < _dynamicXLabel.width * 0.5) {
        textX = _startLeft + _dynamicXLabel.width * 0.5;
    }
    if ((self.width - _startLeft) - textX < _dynamicXLabel.width * 0.5) {
        textX = (self.width - _startLeft) - _dynamicXLabel.width * 0.5;
    }
    if (textY - _startTop < _dynamicYLabel.height * 0.5) {
        textY = _startTop + _dynamicYLabel.height * 0.5;
    }
    if ((self.height - _botomHeight) - textY < _dynamicYLabel.height * 0.5) {
        textY = (self.height - _botomHeight) - _dynamicYLabel.height * 0.5;
    }
    _dynamicXLabel.centerX = textX;
    _dynamicYLabel.centerY = textY;
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _showMidLine = NO;
        _dynamicXLabel.hidden = YES;
        _dynamicYLabel.hidden = YES;
    }
    [self setNeedsDisplay];
//    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
}

- (UILabel *)maxYLabel{
    if (!_maxYLabel) {
        _maxYLabel = [[UILabel alloc] initWithFrame:CGRectMake(_startLeft, _startTop, 100, 11)];
        _maxYLabel.textColor = [UIColor colorWithRGB:0xA9A9A9];
        _maxYLabel.font = [UIFont systemFontOfSize:11];
        [_maxYLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:_maxYLabel];
    }
    return _maxYLabel;
}

- (UILabel *)minYLabel{
    if (!_minYLabel) {
        _minYLabel = [[UILabel alloc] initWithFrame:CGRectMake(_startLeft, self.height - _botomHeight-15, 100, 11)];
        _minYLabel.textColor = [UIColor colorWithRGB:0xA9A9A9];
        _minYLabel.font = [UIFont systemFontOfSize:11];
        [_minYLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:_minYLabel];
    }
    return _minYLabel;
}

- (UILabel *)startTimeLabel{
    if (!_startTimeLabel) {
        _startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_startLeft, self.height - _botomHeight + 5, 100, 11)];
        _startTimeLabel.textColor = [UIColor colorWithRGB:0xA9A9A9];
        _startTimeLabel.font = [UIFont systemFontOfSize:11];
        [_startTimeLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:_startTimeLabel];
    }
    return _startTimeLabel;
}

- (UILabel *)endTimeLabel{
    if (!_endTimeLabel) {
        _endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height - _botomHeight + 5, 100, 11)];
        _endTimeLabel.textColor = [UIColor colorWithRGB:0xA9A9A9];
        _endTimeLabel.right = self.width - _startLeft;
        _endTimeLabel.font = [UIFont systemFontOfSize:11];
        [_endTimeLabel setAdjustsFontSizeToFitWidth:YES];
        _endTimeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_endTimeLabel];
    }
    return _endTimeLabel;
}

- (UILabel *)dynamicXLabel{
    if (!_dynamicXLabel) {
        _dynamicXLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 44, 11)];
        _dynamicXLabel.top = self.height - _botomHeight - 11;
        _dynamicXLabel.textColor = [UIColor colorWithRGB:0xA9A9A9];
        _dynamicXLabel.font = [UIFont systemFontOfSize:8];
        _dynamicXLabel.textAlignment = NSTextAlignmentCenter;
        _dynamicXLabel.layer.borderWidth = 0.5;
        _dynamicXLabel.layer.borderColor = [UIColor redColor].CGColor;
        _dynamicXLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_dynamicXLabel];
    }
    return _dynamicXLabel;
}

- (UILabel *)dynamicYLabel{
    if (!_dynamicYLabel) {
        _dynamicYLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 11)];
        _dynamicYLabel.left = _startLeft;
        _dynamicYLabel.textColor = [UIColor colorWithRGB:0xA9A9A9];
        _dynamicYLabel.font = [UIFont systemFontOfSize:8];
        _dynamicYLabel.textAlignment = NSTextAlignmentCenter;
        _dynamicYLabel.layer.borderWidth = 0.5;
        _dynamicYLabel.layer.borderColor = [UIColor redColor].CGColor;
        _dynamicYLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:_dynamicYLabel];
    }
    return _dynamicYLabel;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
