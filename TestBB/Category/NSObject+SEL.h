//
//  NSObject+SEL.h
//  LeFenKa
//
//  Created by Ruite Chen on 2018/7/19.
//  Copyright © 2018年 乐刷. All rights reserved.
//  允许你添加 SEL 方法而不需要额外的成员变量的便利方法，SEL 方法比 block 安全，并且 SEL 方法比 block 容易阅读

#import <Foundation/Foundation.h>

@interface YKSelector : NSObject
@property (nonatomic,weak) id target;
@property (nonatomic) SEL action;
- (void)perform:(id)obj id:(NSString *)identifier;
@end

@interface NSObject(Selector)

/// 添加一个SEL方法，默认 identifier 为 NSStringFromSlector(sel)
- (void)yk_addTarget:(id)target sel:(SEL)sel;
/// 添加一个SEL方法，identifier 为 identifier
- (void)yk_addTarget:(id)target sel:(SEL)sel identifier:(NSString *)identifer;
/// 通过 identifier 取出一个 sel
- (YKSelector *)yk_target:(NSString *)identifier;
/// 删除 sel
- (void)yk_removeTarget:(NSString *)identifier;
/// 调用sel
- (void)yk_callSel:(NSString *)identifier obj:(id)obj;


@end
