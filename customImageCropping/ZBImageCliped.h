//
//  ZBImageCliped.h
//  customImageCropping
//
//  Created by tianXin on 16/9/5.
//  Copyright © 2016年 Tema. All rights reserved.
//

#import <UIKit/UIKit.h>


//内部类用于包含CGPoint，添加到数组中使用
@interface ZBPoint : NSObject

@property (nonatomic ,assign) CGFloat x;
@property (nonatomic ,assign) CGFloat y;

/**
 *  init
 *
 *  @param x 传入x
 *  @param y 传入y
 *
 *  @return ZBPoint Object
 */

- (instancetype)initWithX:(CGFloat)x Y:(CGFloat)y;

/**
 *  设置x、y更新位置
 *
 *  @param point 
 */
- (void)setPoint:(CGPoint)point;

/**
 *  获取 x，y
 *
 *  @return
 */

- (CGPoint)getPoint;
/**
 *  获取frame
 *
 *  @return Rect
 */
- (CGRect)getRect;

@end


@interface ZBImageCliped : UIView
- (NSArray *)getPoints;
- (UIImage *)getClipedImageWithImage:(UIImage *)image;

//+ (UIImage *)ZBImageClipedWithImage:(UIImage *)image;
@end
