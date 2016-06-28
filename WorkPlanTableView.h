//
//  WorkPlanTableView.h
//  Naton
//
//  Created by nato on 16/5/20.
//  Copyright © 2016年 naton. All rights reserved.
//
/**
 *  行程列表View
 */
#import <UIKit/UIKit.h>
#import "WorkPlanHeaderFooterView.h"
#import "MJRefreshHeaderView.h"
@class CalendarListModel;

@protocol WorkPlanTableViewDelegate <NSObject>
/**
 * WorkPlanTableView内的tableView的cell点击事件
 *
 *  @param model 反传回所被点击的数据model
 */
- (void)workPlaneTableViewCellDidSelectWith:(CalendarListModel *)model;
/**
 *  WorkPlanTableView内的tableView的section点击事件
 *
 *  @param model 反传回所被点击的数据model
 */
- (void)workPlaneTableViewSectionDidSelectWith:(NTUserLevel *)model;
/**
 *  下拉刷新调用
 */
- (void)refreshTheDateSource;

@end

@interface WorkPlanTableView : UIView<UITableViewDelegate,UITableViewDataSource,WorkPlanHeaderFooterViewDelegate,MJRefreshBaseViewDelegate>

@property (nonatomic,assign)id<WorkPlanTableViewDelegate>delegate;

/**
 *  重写构造函数
 *
 *  @param headerView 传入tableView的headerView
 *
 */
- (instancetype)initAndWithHeaderView:(UIView *)headerView;
/**
 *  刷新tableView
 *
 *  @param dataArray 数据源数组
 */
- (void)reloadWorkPlanTableViewWithDataArray:(NSDictionary *)dataDictionary;
/**
 *  为tableView的hea重新赋值
 *
 *  @param headerView headerView
 */
- (void)setTableViewHeaderWith:(UIView *)headerView;
/**
 *  下拉刷新结束调用
 */
- (void)endRefresh;

@end
