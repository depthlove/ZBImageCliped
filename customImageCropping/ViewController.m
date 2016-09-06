//
//  ViewController.m
//  customImageCropping
//
//  Created by tianXin on 16/9/5.
//  Copyright © 2016年 Tema. All rights reserved.
//

#import "ViewController.h"
#import "ZBImageCliped.h"

#define C_ScreenWidth         ([UIScreen mainScreen].bounds.size.width)
#define C_ScreenHeight        ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) ZBImageCliped *mView;
@property (nonatomic ,strong) UIImageView *clipedImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加imageView 就是那张照片
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20, C_ScreenWidth, C_ScreenHeight*0.38)];
    imageView.image = [UIImage imageNamed:@"image.jpg"];
    self.imageView = imageView;
    
    UIImageView *clipedImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 220, C_ScreenWidth, C_ScreenHeight*0.38)];
    self.clipedImage = clipedImage;
    
    
    //这个是截图用的视图 是自定义的 添加到上面的imageView里面 大小一样
    ZBImageCliped *mView = [[ZBImageCliped alloc] initWithFrame:imageView.frame];
    self.mView = mView;
    
    [self.view addSubview:imageView];
    [self.view addSubview:clipedImage];
    [self.view addSubview:mView];
    
    
    //添加截图按钮  绑定的方法在下面
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(50, 500, C_ScreenWidth - 100, 50)];
    [btn addTarget:self action:@selector(snip:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"截图" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor orangeColor]];
    
    [self.view addSubview:btn];
    
}


- (void)snip:(UIButton *)button {
    //下面这个方法是自定义视图MaskView里面的实例方法 作用是返回当前的截图
    UIImage *image = [self.mView getClipedImageWithImage:self.imageView.image];
    self.clipedImage.image = image;
}

@end
