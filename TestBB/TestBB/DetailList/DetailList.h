#import <UIKit/UIKit.h>
#import "TorrentDownloader.h"

@interface DetailList : UITableViewController

@property (nonatomic,copy) NSString *url;

@property (nonatomic,strong) TorrentDownloader *downloader;

- (void)downloadTorrent;
- (void)downloadFileAtIndexes:(NSArray<NSNumber *> *)indexes;

@end
