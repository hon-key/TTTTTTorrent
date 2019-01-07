//
//  UIImage+Custom.m
//  TestBB
//
//  Created by Ruite Chen on 2018/9/5.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import "UIImage+Custom.h"

@implementation UIImage(Custom)
+ (UIImage*)imageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
