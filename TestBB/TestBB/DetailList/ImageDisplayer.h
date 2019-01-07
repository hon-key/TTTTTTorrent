//
//  YKImagePicker.h
//  ShouYinTong
//
//  Created by Ruite Chen on 2018/8/14.
//  Copyright © 2018年 乐刷. All rights reserved.
//  图片选择器

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageDisplayer : UIViewController
@property (nonatomic,strong) UIImage *image;
/// 完成按钮回调 参数：identifier（NSString *） image（UIImage *）
- (void)addTarget:(id)target finished:(SEL)finished;
@end
