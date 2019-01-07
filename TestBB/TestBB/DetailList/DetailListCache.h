//
//  DetailListStorage.h
//  TestBB
//
//  Created by Ruite Chen on 2018/9/6.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DetailListCache : NSObject

@property (nonatomic,copy,readonly) NSString *url;

+ (instancetype)cache:(NSString *)url;

- (NSString *)storeTorrent:(NSString *)path;
- (NSString *)storedTorrent;

- (void)storeImage:(NSString *)path forName:(NSString *)name;
- (NSString *)storedImageForName:(NSString *)name;

@end
