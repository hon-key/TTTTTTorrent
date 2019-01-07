//
//  UIViewController+Custom.m
//  TestBB
//
//  Created by Ruite Chen on 2018/9/12.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import "UIViewController+Custom.h"

@implementation UIViewController(Custom)
+ (UIViewController *)topController {
    
    UIViewController *topC = [self topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (topC.presentedViewController) {
        topC = [self topViewController:topC.presentedViewController];
    }
    return topC;
}

+ (UIViewController *)topViewController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self topViewController:[(UINavigationController *)controller topViewController]];
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        return [self topViewController:[(UITabBarController *)controller selectedViewController]];
    } else {
        return controller;
    }
}
@end
