#import "RootList.h"
#import "RootListCell.h"
#import "DetailList.h"
#import "Cosxcos.h"

@interface RootList ()

@property (nonatomic,strong) NSArray<CosxcosRow *> *rows;

@property (nonatomic,assign) int nextPage;

@end

@implementation RootList

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[RootListCell class] forCellReuseIdentifier:@"cell"];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [Cosxcos loadPage:1 complete:^(NSArray<CosxcosRow *> *rows) {
            self.rows = rows;
            [self.tableView reloadData];
            self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            [self.tableView.mj_header endRefreshing];
        }];
    }];

    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [Cosxcos loadPage:self.nextPage complete:^(NSArray<CosxcosRow *> *rows) {
            if (rows) {
                self.rows = [self.rows arrayByAddingObjectsFromArray:rows];
                self.nextPage++;
            }
            [self.tableView reloadData];
            [self.tableView.mj_footer endRefreshing];
        }];
    }];
    
    [self.tableView.mj_header beginRefreshing];
    self.nextPage = 2;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RootListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.title.text = self.rows[indexPath.row].title;
    cell.attr = self.rows[indexPath.row].attr;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DetailList *detailList = [[DetailList alloc] init];
    detailList.url = self.rows[indexPath.row].url;
    [self.navigationController pushViewController:detailList animated:YES];
}

- (NSArray<CosxcosRow *> *)rows {
    if (!_rows) {
        _rows = @[];
    }
    return _rows;
}


@end
