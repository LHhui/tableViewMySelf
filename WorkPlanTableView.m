//
//  WorkPlanTableView.m
//  Naton
//
//  Created by nato on 16/5/20.
//  Copyright © 2016年 naton. All rights reserved.
//

#import "WorkPlanTableView.h"
#import "Masonry.h"
#import "WorkPlanTableViewCell.h"
#import "WorkPlanHeaderFooterView.h"
#import "CalendarListModel.h"
#import "UITableView+FDTemplateLayoutCell.h"



@implementation WorkPlanTableView
{
    /**
     *  tableview的headerView
     */
    UIView * _headerView;
    /**
     *  tableView
     */
    UITableView * _tableView;
    /**
     *  数据源字典__
     */
    NSMutableDictionary * _dataDictionary;
    /**
     *  数据源数组__section上的数组
     */
    NSMutableArray * _sectionArray;
    /**
     *  数据源 session的typeArray;
     */
    NSMutableArray * _sectionTypeArray;
    /**
     *  下拉刷新
     */
    MJRefreshHeaderView * _header;
}

static NSString * const CellIdentifier = @"Cell";
static NSString * const HeaderFooterViewIdentifier = @"SectionView";

- (instancetype)initAndWithHeaderView:(UIView *)headerView
{
    if (self == [super init]) {
        
        _headerView = headerView;
        
        [self setSubViews];
    }
    return self;
}

/**
 *  创建布局
 */
- (void)setSubViews{
    
    //创建tableView
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = _headerView;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    [_tableView registerClass:[WorkPlanTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [_tableView registerClass:[WorkPlanHeaderFooterView class] forHeaderFooterViewReuseIdentifier:HeaderFooterViewIdentifier];
    [self addSubview:_tableView];
    
    //下拉刷新头的定义
    if (_header!=nil) {
        [_header removeFromSuperview];
        _header=nil;
    }
    _header = [MJRefreshHeaderView header];
    _header.scrollView = _tableView;
    _header.delegate = self;
    
    
    __weak typeof(self) WeekSelf = self;
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(WeekSelf);
    }];
    
    
//    [self getdate];
    
}

- (void)dealloc{
    [_header free];
}

- (void)setTableViewHeaderWith:(UIView *)headerView{
    
    _tableView.tableHeaderView = headerView;
}


//刷新数据的方法
- (void)reloadWorkPlanTableViewWithDataArray:(NSMutableDictionary *)dataDictionary{
    
    [self dataSourceOptionWith:dataDictionary];
    [_tableView reloadData];
}

- (void)dataSourceOptionWith:(NSDictionary *)dataResource{
    
    _sectionArray = [dataResource objectForKey:@"USERNAME"];
    _sectionTypeArray = [dataResource objectForKey:@"USERNAMETYPE"];
    _dataDictionary = [dataResource objectForKey:@"CALENDDICTIONARY"];
    
    
}

#pragma mark tableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[_dataDictionary objectForKey:_sectionTypeArray[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WorkPlanTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell unCommitImageShow:YES];
    [self setupModelOfCell:cell AtIndexPath:indexPath];

    return cell;
}

- (void)setupModelOfCell:(WorkPlanTableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    CalendarListModel * model = [_dataDictionary objectForKey:_sectionTypeArray[indexPath.section]][indexPath.row];
    [cell uploadDateForCellWith:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [tableView fd_heightForCellWithIdentifier:CellIdentifier cacheByIndexPath:indexPath configuration:^(id cell) {
        [self setupModelOfCell:cell AtIndexPath:indexPath];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 20;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    
    WorkPlanHeaderFooterView * headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:HeaderFooterViewIdentifier];
    headerView.delegate = self;
    headerView.tag = section;
    NTUserLevel * userLevel = [_sectionArray objectAtIndex:section];
    [headerView reloadHeaderFooterViewWithDateString:userLevel.user2Name];
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    //取消被选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    CalendarListModel * model = [_dataDictionary objectForKey:_sectionTypeArray[indexPath.section]][indexPath.row];
    if ([self.delegate respondsToSelector:@selector(workPlaneTableViewCellDidSelectWith:)]) {
        [self.delegate workPlaneTableViewCellDidSelectWith:model];
    }
}
#pragma mark --设置尾视图的样式--
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 10)];
    bgView.backgroundColor=[UIColor colorWithRed:244/255.0 green:247/255.0 blue:251/255.0 alpha:1.0];
    return bgView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return 5;
    }
    NSArray * dataArr = [_dataDictionary objectForKey:_sectionTypeArray[section]];
    if (dataArr.count <= 0) {
        return 0;
    }
    return 5;
}

#pragma mark WorkPlanHeaderFooterViewDelegate headerFooterView被点击
- (void)headerViewButtonDidClickDelegate:(WorkPlanHeaderFooterView *)headerFooterView{
    
    //对于tableView的headerView被点击的行数为
    NSInteger section = headerFooterView.tag;
    
    NTUserLevel * model = [_sectionArray objectAtIndex:section];
    
    if ([self.delegate respondsToSelector:@selector(workPlaneTableViewSectionDidSelectWith:)]) {
        [self.delegate workPlaneTableViewSectionDidSelectWith:model];
    }
}

#pragma mark --下拉刷新开始时调用此方法--
-(void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"下拉刷新开始时调用此方法");
    if ([self.delegate respondsToSelector:@selector(refreshTheDateSource)]) {
        [self.delegate refreshTheDateSource];
    }
}
//结束下拉刷新
- (void)endRefresh{
    [_header endRefreshing];
}

#pragma mark --下拉刷新结束时调用此代理方法--
-(void)refreshViewEndRefreshing:(MJRefreshBaseView *)refreshView
{
    NSLog(@"下拉刷新结束时调用此代理方法");
}

@end
