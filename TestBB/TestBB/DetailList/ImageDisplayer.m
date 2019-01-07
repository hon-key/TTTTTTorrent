//
//  YKImagePicker.m
//  ShouYinTong
//
//  Created by Ruite Chen on 2018/8/14.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import "ImageDisplayer.h"
#import "NSObject+SEL.h"
#import <Photos/Photos.h>


@interface ImageDisplayer() <UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation ImageDisplayer
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.equalTo(self.view);
    }];
}

- (void)setImage:(UIImage *)image {
    _image = self.imageView.image = image;
}
- (void)addTarget:(id)target finished:(SEL)finished {
    [self yk_addTarget:target sel:finished identifier:@"display"];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;

}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
        _imageView.image = self.image;
    }
    return _imageView;
}
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.scrollEnabled = YES;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        [_scrollView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.scrollView);
            make.height.equalTo(self.scrollView);
            make.width.equalTo(self.scrollView);
        }];
        [self.view addSubview:_scrollView];
        
    }
    return _scrollView;
}
@end
