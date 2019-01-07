//
//  RootListCell.h
//  TestBB
//
//  Created by Ruite Chen on 2018/9/4.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cosxcos.h"

@interface RootListCell : UITableViewCell

@property (nonatomic,strong) UILabel *title;
@property (nonatomic,strong) NudeIn *attrLabel;
@property (nonatomic,assign) CosxcosRowAttr attr;

@end
