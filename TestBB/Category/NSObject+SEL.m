//
//  NSObject+SEL.m
//  LeFenKa
//
//  Created by Ruite Chen on 2018/7/19.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import "NSObject+SEL.h"

@implementation YKSelector

- (void)perform:(id)obj id:(NSString *)identifier {
    if ([self.target respondsToSelector:self.action]) {
        IMP p = [self.target methodForSelector:self.action];
        if (obj) {
            void (*method)(id,SEL,NSString *,id) = (void *)p;
            method(self.target,self.action,identifier,obj);
        }else {
            void (*method)(id,SEL,NSString *) = (void *)p;
            method(self.target,self.action,identifier);
        }
    }
}

@end

@implementation NSObject(Selector)

- (void)yk_addTarget:(id)target sel:(SEL)sel identifier:(NSString *)identifer {
    if (!target || !sel) return;
    YKSelector *s = [YKSelector new];
    s.target = target;
    s.action = sel;
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(identifer), s, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)yk_addTarget:(id)target sel:(SEL)sel {
    [self yk_addTarget:target sel:sel identifier:NSStringFromSelector(sel)];
}

- (YKSelector *)yk_target:(NSString *)identifier {
    return objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(identifier));
}

- (void)yk_callSel:(NSString *)identifier obj:(id)obj {
    YKSelector *s = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(identifier));
    [s perform:obj id:identifier];
}

- (void)yk_removeTarget:(NSString *)identifier {
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(identifier), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
