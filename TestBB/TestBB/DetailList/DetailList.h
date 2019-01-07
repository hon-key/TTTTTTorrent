//
//  DetailList.h
//  TestBB
//
//  Created by Ruite Chen on 2018/9/5.
//  Copyright © 2018年 乐刷. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TorrentDownloader.h"

@interface DetailList : UITableViewController

@property (nonatomic,copy) NSString *url;

@property (nonatomic,strong) TorrentDownloader *downloader;

- (void)downloadTorrent;
- (void)downloadFileAtIndexes:(NSArray<NSNumber *> *)indexes;

@end
