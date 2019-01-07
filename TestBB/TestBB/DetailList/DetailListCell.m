#import "DetailListCell.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Custom.h"
#import "TorrentDownloader.h"
#import "Cosxcos.h"
#import "DetailListCache.h"
#import "DetailList.h"
#import "ImageDisplayer.h"
#import "UIViewController+Custom.h"

@implementation DetailListIntroCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.intro mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self.contentView).with.offset(8);
            make.bottom.right.equalTo(self.contentView).with.offset(-8);
        }];
    }
    return self;
}
- (NudeIn *)intro {
    if (!_intro) {
        _intro = [NudeIn make:^(NUDTextMaker *make) {}];
        _intro.selectable = YES;
        [self.contentView addSubview:_intro];
    }
    return _intro;
}
- (void)setContents:(NSArray<NSString *> *)contents {
    _contents = contents;
    [self.intro remake:^(NUDTextMaker *make) {
        for (NSString *text in self.contents) {
            if (![text isEqualToString:@"上一页"] &&
                ![text isEqualToString:@"下载资源"] &&
                ![text isEqualToString:@"下一页"]) {
                make.text(text).color(RGB(0x333333)).font(17).ln(1).attach();
            }
        }
    }];
}
@end

@implementation DetailListImageCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.left.equalTo(self.contentView);
        }];
    }
    return self;
}
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        [self.contentView addSubview:_collectionView];
    }
    return _collectionView;
}
- (void)browzeImage:(UITapGestureRecognizer *)tap {
    ImageDisplayer *imgDisplayer = [ImageDisplayer new];
    imgDisplayer.image = ((UIImageView *)tap.view).image;
    [[UIViewController topController].navigationController pushViewController:imgDisplayer animated:YES];
}
#define EDGE (([UIScreen mainScreen].bounds.size.width - 4 - 4) / 3)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageUrls.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    UIImageView *imgView = [cell.contentView viewWithTag:666];
    if (!imgView) {
        imgView = [[UIImageView alloc] init];
        imgView.tag = 666;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.layer.masksToBounds = YES;
        [cell.contentView addSubview:imgView];
        [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(cell.contentView);
        }];
        [imgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(browzeImage:)]];
        imgView.userInteractionEnabled = YES;
    }
    [imgView sd_setImageWithURL:[NSURL URLWithString:self.imageUrls[indexPath.row]]
               placeholderImage:[UIImage imageWithColor:[UIColor grayColor]]
                        options:SDWebImageProgressiveDownload];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(EDGE, EDGE);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2,2,2,2);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 2;
}
- (void)setImageUrls:(NSArray<NSString *> *)imageUrls {
    _imageUrls = imageUrls;
    [self.collectionView reloadData];
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.equalTo(self.contentView);
        int rowCount = (self.imageUrls.count / 3) + (self.imageUrls.count % 3 > 0 ? 1:0);
        make.height.mas_equalTo(2 + rowCount * EDGE + (rowCount-1)*2 + 2).priorityMedium();
    }];
}
@end

@interface DetailListFilesCell ()

@end

@implementation DetailListFilesCell
- (instancetype)init {
    if (self = [super init]) {
        [self.clickToLoad mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.contentView);
            make.top.equalTo(self.contentView).with.offset(20);
            make.bottom.equalTo(self.contentView).with.offset(-20);
        }];
        [self.loadIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.clickToLoad);
        }];
    }
    return self;
}

- (void)downloadTorrent {
    self.clickToLoad.hidden = YES;
    [self.loadIndicator startAnimating];
    [self.detailList downloadTorrent];

}

- (void)displayAndUpdateFilelist {
    [self.loadIndicator stopAnimating];
    [self.loadIndicator removeFromSuperview];
    [self.clickToLoad removeFromSuperview];
    [self.filelist mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.contentView);
        CGFloat sumHeight = 0;
        for (BTFile *file in self.detailList.downloader.torrentInfo.files) {
            
            NudeIn *nud = [NudeIn make:^(NUDTextMaker *make) {
                [self makeNude:make file:[file.name lastPathComponent]];
            }];
            sumHeight += [nud sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, MAXFLOAT)].height + 18;
        }
        make.height.mas_equalTo(8 + sumHeight + 8).priorityMedium();
    }];
    [self.filelist reloadData];
    [self.detailList.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.detailList.downloader.torrentInfo.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    NudeIn *nud = [cell.contentView viewWithTag:777];
    if (!nud) {
        nud = [NudeIn make:^(NUDTextMaker *make) {}];
        nud.backgroundColor = [UIColor clearColor];
        nud.userInteractionEnabled = NO;
        nud.tag = 777;
        [cell.contentView addSubview:nud];
        [nud mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).with.offset(9);
            make.bottom.equalTo(cell.contentView).with.offset(-9);
            make.left.equalTo(cell.contentView).with.offset(15);
            make.right.equalTo(cell.contentView).with.offset(-15);
        }];
    }
    
    UIView *progressBar = [cell.contentView viewWithTag:888];
    if (!progressBar) {
        progressBar = [UIView new];
        progressBar.backgroundColor = [UIColor greenColor];
        progressBar.tag = 888;
        [cell.contentView addSubview:progressBar];
        [progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.top.equalTo(cell.contentView);
            make.width.mas_equalTo(0);
        }];
        [cell.contentView sendSubviewToBack:progressBar];
    }
    [progressBar mas_updateConstraints:^(MASConstraintMaker *make) {
        BTFile *file = self.detailList.downloader.torrentInfo.files[indexPath.row];
        make.width.mas_equalTo(file.progress * [UIScreen mainScreen].bounds.size.width);
    }];
    
    [nud remake:^(NUDTextMaker *make) {
        [self makeNude:make file: [self.detailList.downloader.torrentInfo.files[indexPath.row].name lastPathComponent]];
    }];
    
    return cell;
}

- (void)makeNude:(NUDTextMaker *)make file:(NSString *)fileName {
    NSString *imgType = [fileName hasSuffix:@".png"] ? @"[PNG]" : [fileName hasSuffix:@".jpg"] ? @"[JPG]" : nil;
    if (imgType) {
        make.text(imgType).font(15).fontStyle(NUDMedium).color(RGB(0xD93D22)).attach();
    }
    make.text(fileName).color(RGB(0x1B6AA2)).font(15).attach();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BTFile *file = self.detailList.downloader.torrentInfo.files[indexPath.row];
    if (file.progress == 1.0) {
        ImageDisplayer *imgDisplayer = [ImageDisplayer new];
        imgDisplayer.image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@",NSTemporaryDirectory(),file.name]];
        [[UIViewController topController].navigationController pushViewController:imgDisplayer animated:YES];
    }else {
        [self.detailList downloadFileAtIndexes:@[@(indexPath.row)]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {return 8;}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {return [UIView new];}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {return 8;}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {return [UIView new];}

- (UITableView *)filelist {
    if (!_filelist) {
        _filelist = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _filelist.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_filelist registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _filelist.backgroundColor = [UIColor whiteColor];
        _filelist.rowHeight = UITableViewAutomaticDimension;
        _filelist.scrollEnabled = NO;
        _filelist.estimatedRowHeight = 44;
        _filelist.dataSource = self;
        _filelist.delegate = self;
        [self.contentView addSubview:_filelist];
    }
    return _filelist;
}

- (UIButton *)clickToLoad {
    if (!_clickToLoad) {
        _clickToLoad = [[UIButton alloc] init];
        [_clickToLoad setTitle:@"点击加载" forState:UIControlStateNormal];
        [_clickToLoad setTitleColor:RGB(0x1B6AA2) forState:UIControlStateNormal];
        [_clickToLoad addTarget:self action:@selector(downloadTorrent) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_clickToLoad];
    }
    return _clickToLoad;
}

- (UIActivityIndicatorView *)loadIndicator {
    if (!_loadIndicator) {
        _loadIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_loadIndicator];
    }
    return _loadIndicator;
}

@end
