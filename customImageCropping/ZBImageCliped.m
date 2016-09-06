//
//  ZBImageCliped.m
//  customImageCropping
//
//  Created by tianXin on 16/9/5.
//  Copyright © 2016年 Tema. All rights reserved.
//

#import "ZBImageCliped.h"

#define C_ZBHeight                40
#define C_ZBItemColGap            10
#define C_ZMargin                 20


@implementation ZBPoint

- (instancetype)initWithX:(CGFloat)x Y:(CGFloat)y{
    if (self = [super init]) {
        self.x = x;
        self.y = y;
    }
    return self;
}

- (void)setPoint:(CGPoint)point{
    self.x = point.x;
    self.y = point.y;
}

- (CGPoint)getPoint{
    return CGPointMake(self.x, self.y);
}

- (CGRect)getRect{
    return CGRectMake(MAX(self.x - C_ZBHeight, 0), MAX(self.y - C_ZBHeight, 0), self.x + C_ZBHeight, self.y + C_ZBHeight);
}

@end


@interface ZBImageCliped ()

@property (nonatomic ,strong) NSArray *arrayPoints;

@end


@implementation ZBImageCliped

{
    CGContextRef _ctx;
    BOOL         _isMove;
    CGPoint      _offset;
    ZBPoint     *_movePoint;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        UIGraphicsBeginImageContext(self.bounds.size);
        _isMove = NO;
    }
    return self;
}

- (NSArray *)arrayPoints{
    if (!_arrayPoints) {
        CGFloat width = CGRectGetWidth(self.bounds) *0.25f;
        CGFloat heigth = CGRectGetHeight(self.bounds) *0.25f;
        ZBPoint *point1 = [[ZBPoint alloc] initWithX:width Y:heigth];
        ZBPoint *point2 = [[ZBPoint alloc] initWithX:width * 3 Y:heigth];
        ZBPoint *point3 = [[ZBPoint alloc] initWithX:width * 3 Y:heigth*3];
        ZBPoint *point4 = [[ZBPoint alloc] initWithX:width Y:heigth * 3];
        _arrayPoints =  [NSArray arrayWithObjects:point1, point2, point3, point4, nil];
    }
    return _arrayPoints;
}



- (NSArray *)getPoints {
    return [self.arrayPoints copy];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    _ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(_ctx);
    CGContextSetLineWidth(_ctx, 1);
    CGContextSetLineJoin(_ctx, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(_ctx, [UIColor blackColor].CGColor);
    [self.arrayPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [obj getPoint];
        if (idx == 0) {
            CGContextMoveToPoint(_ctx, point.x, point.y);
        }else{
            CGContextAddLineToPoint(_ctx, point.x, point.y);
        }
    }];
    CGContextClosePath(_ctx);
    CGContextStrokePath(_ctx);
    
    CGContextSetStrokeColorWithColor(_ctx, [UIColor whiteColor].CGColor);
    for (ZBPoint *point in self.arrayPoints) {
        CGContextStrokeEllipseInRect(_ctx, CGRectMake(point.x - C_ZBItemColGap, point.y - C_ZBItemColGap, C_ZMargin, C_ZMargin));
        CGContextFillEllipseInRect(_ctx, CGRectMake(point.x - C_ZBItemColGap, point.y - C_ZBItemColGap, C_ZMargin, C_ZMargin));
    }
    
    CGContextBeginPath(_ctx);
    [self.arrayPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = [obj getPoint];
        if (idx == 0) {
            CGContextMoveToPoint(_ctx, point.x, point.y);
        }else{
            CGContextAddLineToPoint(_ctx, point.x, point.y);
        }
    }];
    
    CGContextAddRect(_ctx, self.bounds);
    CGContextClosePath(_ctx);
    CGContextEOClip(_ctx);
    CGContextSetFillColorWithColor(_ctx, [[UIColor blackColor]colorWithAlphaComponent:0.3].CGColor);
    CGContextFillRect(_ctx, self.bounds);
}

/// ========================================
/// @name  移动锚点
/// ========================================


- (CGFloat)distancePythagoreanTheoremFunctionPoint:(CGPoint )point ToPoint:(CGPoint)purPoint{
    return sqrt(pow(purPoint.x - point.x, 2) + pow(purPoint.y - point.y,2));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    _movePoint = nil;
    __block CGFloat distance = 100.0f;
    [self.arrayPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint([obj getRect], [touch locationInView:self])) {
            _isMove = YES;
            if ([self distancePythagoreanTheoremFunctionPoint:[obj getPoint] ToPoint:[touch locationInView:self]] < distance) {
                distance = [self distancePythagoreanTheoremFunctionPoint:[obj getPoint] ToPoint:[touch locationInView:self]];
                _offset = CGPointMake([obj getPoint].x-[touch locationInView:self].x, [obj getPoint].y-[touch locationInView:self].y);

                _movePoint = obj;
            }
        }
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self moveWithTouch:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self moveWithTouch:touches withEvent:event];
    _isMove = NO;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self moveWithTouch:touches withEvent:event];
    _isMove = NO;
}

- (void)moveWithTouch:(NSSet<UITouch *> *)touchs withEvent:(UIEvent *)event{
    /**
     *  确保四条边不相交
     */
    if (_isMove) {
        UITouch *touch = [touchs anyObject];
        CGFloat x = MIN(MAX([touch locationInView:self].x + _offset.x, 0), CGRectGetWidth(self.bounds));
        CGFloat y = MIN(MAX([touch locationInView:self].y + _offset.y, 0), CGRectGetHeight(self.bounds));
        [_movePoint setPoint:CGPointMake(x, y)];
    }
    //刷新绘图
    [self setNeedsDisplay];
}


/// ========================================
/// @name 裁剪图片
/// ========================================

- (UIImage *)getClipedImageWithImage:(UIImage *)image{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    [self.arrayPoints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint point = CGPointMake([obj getPoint].x, [obj getPoint].y);
        if (idx == 0) {
            CGContextMoveToPoint(ctx, point.x, point.y);
        }else{
            CGContextAddLineToPoint(ctx, point.x, point.y);
        }
    }];
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    [image drawInRect:self.bounds];
    UIImage *clipedImage = UIGraphicsGetImageFromCurrentImageContext();
    return clipedImage;
}



@end
