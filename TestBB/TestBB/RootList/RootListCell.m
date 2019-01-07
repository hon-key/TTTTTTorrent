//
//  RootListCell.m
//  TestBB
//
//  Created by Ruite Chen on 2018/9/4.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import "RootListCell.h"

@implementation RootListCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.attrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).with.offset(10);
            make.centerY.equalTo(self.contentView);
        }];
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.attrLabel.mas_right).with.offset(5);
            make.right.equalTo(self.contentView).with.offset(-10);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:15];
        _title.numberOfLines = 3;
        [self.contentView addSubview:_title];
    }
    return _title;
}
- (NudeIn *)attrLabel {
    if (!_attrLabel) {
        _attrLabel = [NudeIn make:^(NUDTextMaker *make) {}];
        _attrLabel.userInteractionEnabled = NO;
        [self.contentView addSubview:_attrLabel];
    }
    return _attrLabel;
}

- (void)setAttr:(CosxcosRowAttr)attr {
    if (attr == 0) {
        [self.attrLabel remake:^(NUDTextMaker *make) {
            make.text(@" ").color([UIColor blackColor]).attach();
        }];
        return;
    }
    [self.attrLabel remake:^(NUDTextMaker *make) {
        make.textTemplate(@"attr").font(15).color([UIColor whiteColor]).attach();
        make.textTemplate(@"blank").font(15).attach();
        if (attr & CosxcosRowAttrTop) {
            make.text(@"置顶").mark(RGB(0XB93E14)).nud_attachWith(@"attr");
            make.text(@" ").nud_attachWith(@"blank");
        }
        if (attr & CosxcosRowAttrTorrent) {
            make.text(@"种子").mark(RGB(0X1B6AA2)).nud_attachWith(@"attr");
            make.text(@" ").nud_attachWith(@"blank");
        }
        if (attr & CosxcosRowAttrHot) {
            make.text(@"热门").mark(RGB(0X7D3F75)).nud_attachWith(@"attr");
            make.text(@" ").nud_attachWith(@"blank");
        }
        if (attr & CosxcosRowAttrMagnet) {
            make.text(@"磁力").mark(RGB(0XFC6621)).nud_attachWith(@"attr");
            make.text(@" ").nud_attachWith(@"blank");
        }
        if (attr & CosxcosRowAttrEd2k) {
            make.text(@"电驴").mark(RGB(0XED1EB9)).nud_attachWith(@"attr");
            make.text(@" ").nud_attachWith(@"blank");
        }
        if (attr & CosxcosRowAttrBaidu) {
            make.text(@"百度").mark(RGB(0X477411)).nud_attachWith(@"attr");
            make.text(@" ").nud_attachWith(@"blank");
        }
    }];
    
}


@end
