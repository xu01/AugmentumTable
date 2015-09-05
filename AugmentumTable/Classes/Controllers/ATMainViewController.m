//
//  ATMainViewController.m
//  AugmentumTable
//
//  Created by user on 8/27/15.
//  Copyright (c) 2015 xu lingyi. All rights reserved.
//

#import "ATMainViewController.h"
#import "ATLeftTableViewCell.h"

@interface ATMainViewController ()
{
    NSArray         *_tableData;
    
    UIView          *_leftView;
    UILabel         *_leftTitle;
    UITableView     *_leftTableView;
    
    UIView          *_rightView;
    UILabel         *_rightTitle;
    UIScrollView    *_rightScrollView;
    //ATGridView      *_rightCanvas;
}

@end

@implementation ATMainViewController

#pragma mark - Default Methods

- (instancetype)init {
    if (self = [super init]) {
        _tableData = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TableData" ofType:@"plist"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildNavigationController];
    [self buildMainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Methods
// 构造Navigation
- (void)buildNavigationController {
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"#FFBA00"];
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationItem.title = @"店铺编辑模式";
}

// 构造界面
- (void)buildMainView {
    /* Left */
    _leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kNavigationHeight, kLeftViewWidth, self.view.frame.size.height-kNavigationHeight)];
    _leftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_leftView];
    
    _leftTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kLeftViewWidth, kSubTitleHeight)];
    _leftTitle.backgroundColor = [UIColor whiteColor];
    _leftTitle.text = @"放置桌椅";
    _leftTitle.font = [UIFont systemFontOfSize:15.0];
    _leftTitle.textColor = [UIColor colorWithHexString:@"#FFBA00"];
    _leftTitle.textAlignment = NSTextAlignmentCenter;
    [_leftView addSubview:_leftTitle];
    
    _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, kSubTitleHeight, kLeftViewWidth, _leftView.frame.size.height-kSubTitleHeight) style:UITableViewStylePlain];
    _leftTableView.separatorStyle = UITableViewCellAccessoryNone;
    _leftTableView.dataSource = self;
    _leftTableView.delegate = self;
    _leftTableView.allowsSelection = NO;
    _leftTableView.bounces = NO;
    [_leftView addSubview:_leftTableView];
    
    /* Right */
    _rightView = [[UIView alloc] initWithFrame:CGRectMake(kLeftViewWidth, kNavigationHeight, kRightViewWidth, self.view.frame.size.height-kNavigationHeight)];
    _rightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_rightView];
    
    _rightTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, kRightViewWidth, kSubTitleHeight)];
    _rightTitle.backgroundColor = [UIColor colorWithHexString:@"#555555"];
    _rightTitle.text = @"一楼平面图";
    _rightTitle.font = [UIFont systemFontOfSize:15.0];
    _rightTitle.textColor = [UIColor whiteColor];
    _rightTitle.textAlignment = NSTextAlignmentCenter;
    [_rightView addSubview:_rightTitle];
    
    _rightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, kSubTitleHeight, kRightViewWidth, _rightView.frame.size.height-kSubTitleHeight)];
    _rightScrollView.scrollEnabled = YES;
    _rightScrollView.bounces = NO;
    _rightScrollView.minimumZoomScale = 0.5;
    _rightScrollView.maximumZoomScale = 3.0;
    _rightScrollView.delegate = self;
    _rightScrollView.contentSize = CGSizeMake(kGridRows*kGridWidth, kGridColumns*kGridWidth);
    [_rightView addSubview:_rightScrollView];
    
    _rightCanvas = [[ATGridView alloc] initWithFrame:CGRectMake(0.0, 0.0, kGridRows*kGridWidth, kGridColumns*kGridWidth)];
    [_rightScrollView addSubview:_rightCanvas];
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (([_tableData[indexPath.row][@"items"] count]+1)/2)*135+40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"_LeftTableViewCell";
    //ATLeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    ATLeftTableViewCell *cell = (ATLeftTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(cell == nil){
        cell = [[ATLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.tableItems = _tableData[indexPath.row][@"items"];
        cell.tableType.text = _tableData[indexPath.row][@"name"];
        [cell buildTablesWithParent:self];
    }

    return cell;
}

#pragma mark - ATDragViewDelegate
- (void)dragViewDidStartDragging:(ATDragView *)dragView {
    
}

- (void)dragViewDidMoveDragging:(ATDragView *)dragView {
    if (![dragView isDescendantOfView:_rightCanvas]) {
        [_rightCanvas addSubview:dragView];
    }
}

- (void)dragViewDidEndDragging:(ATDragView *)dragView {
    if (![dragView isDescendantOfView:_rightCanvas]) {
        [_rightCanvas addSubview:dragView];
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _rightCanvas;
}

@end
