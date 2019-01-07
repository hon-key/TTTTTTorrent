//
//  Cosxcox.h
//  TestBB
//
//  Created by Ruite Chen on 2018/9/4.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CosxcosRow,CosxcosDetail;

@interface Cosxcos : NSObject

@end

@interface Cosxcos (Root)
+ (void)loadPage:(int)index complete:(void(^)(NSArray<CosxcosRow *> *rows))complete;
@end

@interface Cosxcos (Detail)
+ (void)loadDetail:(NSString *)url complete:(void(^)(CosxcosDetail *detail))complete;
+ (void)downloadTorrent:(NSString *)url asName:(NSString *)name complete:(void (^)(NSString *torrentPath))complete;
@end




typedef NS_OPTIONS(NSUInteger, CosxcosRowAttr) {
    CosxcosRowAttrTop = 1ul << 0,
    CosxcosRowAttrTorrent = 1ul << 1,
    CosxcosRowAttrHot = 1ul << 2,
    CosxcosRowAttrMagnet = 1ul << 3,
    CosxcosRowAttrEd2k = 1ul << 4,
    CosxcosRowAttrBaidu = 1ul << 5,
};

@interface CosxcosRow : NSObject
@property (nonatomic,assign) CosxcosRowAttr attr;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,copy) NSString *title;
@end

@interface CosxcosDetail : NSObject
@property (nonatomic,copy) NSString *url;
@property (nonatomic,strong) NSArray<NSString *> *contents;
@property (nonatomic,strong) NSArray<NSString *> *imageUrls;
@property (nonatomic,copy) NSString *torrentUrl;
@property (nonatomic,copy) NSString *magnet;
@end
