
#import "DetailList.h"
#import "DetailListCell.h"
#import "Cosxcos.h"
#import "TorrentDownloader.h"
#import "DetailListCache.h"

@interface DetailList () <TorrentDownloaderDelegate>

@property (nonatomic,strong) CosxcosDetail *detail;

@property (nonatomic,strong) NudeIn *downloadSpeedLabel;
@property (nonatomic,strong) UIView *downloadProgressBar;

@property (nonatomic,strong) UIView *filesCellHeader;
@property (nonatomic,strong) DetailListFilesCell *filesCell;

@end

@implementation DetailList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 20.0f;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DetailListIntroCell class] forCellReuseIdentifier:@"intro"];
    [self.tableView registerClass:[DetailListImageCell class] forCellReuseIdentifier:@"image"];
    
    [Cosxcos loadDetail:self.url complete:^(CosxcosDetail *detail) {
        if (detail) {
            self.detail = detail;
            if (detail.url) {
                NSString *storedTorrentPath = [[DetailListCache cache:detail.url] storedTorrent];
                if (storedTorrentPath) {
                    self.downloader = [[TorrentDownloader alloc] initWithTorrent:storedTorrentPath];
                    for (BTFile *file in self.downloader.torrentInfo.files) {
                        NSString *storedFilePath = [NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),file.name];
                        file.progress = [[NSFileManager defaultManager] fileExistsAtPath:storedFilePath] ? 1 : 0;
                    }
                    [self.filesCell displayAndUpdateFilelist];
                }
            }
        }
        [self.tableView reloadData];
    }];
}

#pragma mark - 种子下载
- (void)downloadTorrent {
    if (self.detail.torrentUrl) {
        [Cosxcos downloadTorrent:self.detail.torrentUrl asName:nil complete:^(NSString *torrentPath) {
            [self parseTorrent:torrentPath];
        }];
    }else if (self.detail.magnet) {
        [TorrentMaker downloadTorrentFromMagnet:self.detail.magnet complete:^(NSString *torrentPath) {
            [self parseTorrent:torrentPath];
        }];
    }
}

- (void)parseTorrent:(NSString *)torrentPath {
    if (torrentPath) {
        NSString *newPath = [[DetailListCache cache:self.detail.url] storeTorrent:torrentPath];
        self.downloader = [[TorrentDownloader alloc] initWithTorrent:newPath];
        [self.filesCell displayAndUpdateFilelist];
    }
}

#pragma mark - Tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {return 3;}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {return 1;}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSString *identifier = section == 0 ? @"intro" : section == 1 ? @"image" : @"";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (indexPath.section == 0) {
        DetailListIntroCell *introCell = (DetailListIntroCell *)cell;
        introCell.contents = self.detail.contents;
    }else if (indexPath.section == 1) {
        DetailListImageCell *imageCell = (DetailListImageCell *)cell;
        imageCell.imageUrls = self.detail.imageUrls;
    }else if (indexPath.section == 2) {
        return self.filesCell;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 45;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 2) {
        return self.filesCellHeader;
    }
    UIView *header = [UIView new];
    header.backgroundColor = RGB(0xE7EAED);
    UILabel *title = [UILabel new];
    title.text = section == 0 ? @"简介" : section == 1 ? @"预览" : section == 2 ? @"文件列表" : @"";
    title.textColor = RGB(0x5F6368);
    [header addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header).with.offset(20);
        make.centerY.equalTo(header);
    }];
     
    return header;
}

#pragma mark - 种子内容下载
- (void)downloadFileAtIndexes:(NSArray<NSNumber *> *)indexes {
    if (!self.downloader.downloading) {
        for (int i = 0; i < self.downloader.torrentInfo.files.count; i++) {
            self.downloader.torrentInfo.files[i].selected = [indexes containsObject:@(i)];
        }
        self.downloader.delegate = self;
        [self.downloader startDownload];
    }
}
- (void)btDownloader:(TorrentDownloader *)downloader progressDidUpdate:(BTDownloadInfo *)downloadInfo {
    [self.filesCell.filelist reloadData];
    [self.downloadProgressBar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(downloadInfo.progress * [UIScreen mainScreen].bounds.size.width);
        NSLog(@"%f",downloadInfo.progress * [UIScreen mainScreen].bounds.size.width);
    }];
    [self.downloadSpeedLabel remake:^(NUDTextMaker *make) {
        make.text(@"速度:").font(15).color(RGB(0x1B6AA2)).attach();
        NSString *speed = [NSString stringWithFormat:@"%.1fkb/s ",downloadInfo.downloadSpeed / 1000.0];
        make.text(speed).font(15).bold().color(RGB(0xD93D22)).attach();
        make.text(@"连接:").font(15).color(RGB(0x1B6AA2)).attach();
        NSString *con = [NSString stringWithFormat:@"%d",downloadInfo.peer];
        make.text(con).font(15).bold().color(RGB(0xD93D22)).attach();
    }];
    [self.filesCellHeader layoutIfNeeded];
}
- (void)btDownloaderDidFinishDownload:(TorrentDownloader *)downloader {
    [self.filesCell.filelist reloadData];
    
}

#pragma mark - Lazy load
- (UIView *)filesCellHeader {
    if (!_filesCellHeader) {
        _filesCellHeader = [UIView new];
        _filesCellHeader.backgroundColor = RGB(0xE7EAED);
        UILabel *title = [UILabel new];
        title.text = @"文件列表";
        title.textColor = RGB(0x5F6368);
        [_filesCellHeader addSubview:title];
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.filesCellHeader).with.offset(20);
            make.centerY.equalTo(self.filesCellHeader);
        }];
    }
    return _filesCellHeader;
}
- (NudeIn *)downloadSpeedLabel {
    if (!_downloadSpeedLabel) {
        _downloadSpeedLabel = [NudeIn make:^(NUDTextMaker *make) {}];
        _downloadSpeedLabel.backgroundColor = [UIColor clearColor];
        [self.filesCellHeader addSubview:_downloadSpeedLabel];
        [self.downloadSpeedLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.filesCellHeader).with.offset(-8);
            make.centerY.equalTo(self.filesCellHeader);
        }];
    }
    return _downloadSpeedLabel;
}

- (UIView *)downloadProgressBar {
    if (!_downloadProgressBar) {
        _downloadProgressBar = [UIView new];
        _downloadProgressBar.backgroundColor = [UIColor greenColor];
        [self.filesCellHeader addSubview:self.downloadProgressBar];
        [self.downloadProgressBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self.filesCellHeader);
            make.width.mas_equalTo(0);
        }];
        [self.filesCellHeader sendSubviewToBack:_downloadProgressBar];
    }
    return _downloadProgressBar;
}

- (DetailListFilesCell *)filesCell {
    if (!_filesCell) {
        _filesCell = [[DetailListFilesCell alloc] init];
        _filesCell.detailList = self;
    }
    return _filesCell;
}



@end
