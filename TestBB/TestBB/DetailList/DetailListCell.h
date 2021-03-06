#import <UIKit/UIKit.h>

@class DetailList;

@interface DetailListIntroCell : UITableViewCell
@property (nonatomic,strong) NudeIn *intro;
@property (nonatomic,strong) NSArray<NSString *> *contents;
@end

@interface DetailListImageCell : UITableViewCell <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSArray<NSString *> *imageUrls;
@end

@interface DetailListFilesCell : UITableViewCell <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) UIButton *clickToLoad;
@property (nonatomic,strong) UIActivityIndicatorView *loadIndicator;
@property (nonatomic,strong) UITableView *filelist;

@property (nonatomic,weak) DetailList *detailList;

- (void)displayAndUpdateFilelist;
@end
