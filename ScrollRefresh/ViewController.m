//
//  ViewController.m
//  ScrollRefresh
//
//  Created by p2p on 15-4-4.
//  Copyright (c) 2015年 kxcd. All rights reserved.
//

#import "ViewController.h"
#import "EGOViewCommon.h"
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

const CGFloat kTableHeaderViewHeight = 65.f;
const CGFloat kTableFooterViewHeight = 65.f;

@interface ViewController () <EGORefreshTableDelegate>

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, retain) NSMutableArray *tableDataSource;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, retain) EGORefreshTableFooterView *refreshFooterView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _isLoading = NO;
    self.tableDataSource = [@[@"路飞", @"索隆", @"娜美", @"山治"] mutableCopy];
    [self setHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"mainCellIdentifier";
    UITableViewCell *viewCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (viewCell == nil)
    {
        viewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *text = [self.tableDataSource objectAtIndex:indexPath.row];
    viewCell.textLabel.text = text;
    
    return viewCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.tableDataSource.count - 1)// && self.tableView.contentOffset.y > self.view.bounds.size.height)
    {
        [self setFooterView];
        if ([self canLoadMore])
        {
            [self loadMore];
        }
        else
        {
            [self removeFooterView];
        }
    }
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableView Delegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    [self beginReloadData];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view
{
    return _isLoading;
}

#pragma mark - Private Methods
- (void)setHeaderView
{
    if (_refreshHeaderView == nil)
    {
        // create the header view
        UIColor *viewTextColoer = [UIColor colorWithRed:216.0/255.0 green:196.0/255.0 blue:172.0/255.0 alpha:0.7f];
        UIColor *viewBackgroundColor = [UIColor colorWithRed:251.0/255.0 green:243.0/255.0 blue:231.0/255.0 alpha:1.0f];
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -kTableHeaderViewHeight, self.tableView.frame.size.width, kTableFooterViewHeight)
                                                               arrowImageName:@"refresh_up_arrow"
                                                             loadingImageNmae:@"refresh_loading"
                                                                    textColor:viewTextColoer];
        _refreshHeaderView.backgroundColor = viewBackgroundColor;
        _refreshHeaderView.delegate = self;
        [self.tableView addSubview:_refreshHeaderView];
    }
}

- (void)setFooterView
{
    UIColor *footerViewTextColoer = [UIColor colorWithRed:216.0/255.0 green:196.0/255.0 blue:172.0/255.0 alpha:0.7f];
    UIColor *footerViewBackgroundColor = [UIColor colorWithRed:251.0/255.0 green:243.0/255.0 blue:231.0/255.0 alpha:1.0f];
    
    CGFloat height = MAX(self.tableView.contentSize.height, self.tableView.frame.size.height);
    if (_refreshFooterView && [_refreshFooterView superview])
    {
        // reset position
        _refreshFooterView.frame = CGRectMake(0.0f, height, self.tableView.frame.size.width, kTableFooterViewHeight);
    }
    else
    {
        // create the footerView
        _refreshFooterView = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, height, self.tableView.frame.size.width, kTableFooterViewHeight)
                                                               arrowImageName:@"refresh_down_arrow"
                                                             loadingImageNmae:@"refresh_loading"
                                                                    textColor:footerViewTextColoer];
        _refreshFooterView.delegate = self;
        _refreshFooterView.backgroundColor = footerViewBackgroundColor;
    }
    
    if (_refreshFooterView)
    {
        // always show loading and add to table view
        [_refreshFooterView egoRefreshAlwaysShowLoading];
        [self.tableView setTableFooterView:_refreshFooterView];
        [_refreshFooterView refreshLastUpdatedDate];
    }
}

- (void)removeFooterView
{
    if (_refreshFooterView && [_refreshFooterView superview])
    {
        [_refreshFooterView removeFromSuperview];
    }
    _refreshFooterView = nil;
    [self.tableView setTableFooterView:nil];
}

- (void)beginReloadData
{
    _isLoading = YES;
    
    // 模拟异步请求刷新数据
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *newArray = @[@"路飞", @"索隆", @"乌索普", @"山治", @"娜美", @"乔巴", @"罗宾", @"弗兰奇"];
        _tableDataSource = [newArray mutableCopy];
        [self.tableView reloadData];
        _isLoading = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    });
}

- (BOOL)canLoadMore
{
    static int count = 0;
    
    return count++ < 5;
}

- (void)loadMore
{
    // 模拟加载更多
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *newArray = @[@"乌索普", @"乔巴", @"罗宾", @"弗兰奇"];
        [_tableDataSource addObjectsFromArray:newArray];
        [self.tableView reloadData];
        _isLoading = NO;
        [_refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    });
}

@end
