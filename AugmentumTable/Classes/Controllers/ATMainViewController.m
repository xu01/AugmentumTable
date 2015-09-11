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
    ATGridView      *_rightCanvas;
    
    UIView          *_leftEditView;
    UITextField     *_nameTextField;
    
    ATDragView      *_editDragView;
    
    BOOL            _isEdit;
    
    UIView          *_currentSuggestView;
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
    WS(ws);
    
    /* 左侧 */
    _leftView = [[UIView alloc] init];
    _leftView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_leftView];
    
    _leftTitle = [[UILabel alloc] init];
    _leftTitle.backgroundColor = [UIColor whiteColor];
    _leftTitle.text = @"放置桌椅";
    _leftTitle.font = [UIFont systemFontOfSize:15.0];
    _leftTitle.textColor = [UIColor colorWithHexString:@"#FFBA00"];
    _leftTitle.textAlignment = NSTextAlignmentCenter;
    [_leftView addSubview:_leftTitle];
    
    /* 左侧桌子列表 */
    _leftTableView = [[UITableView alloc] init];
    _leftTableView.separatorStyle = UITableViewCellAccessoryNone;
    _leftTableView.dataSource = self;
    _leftTableView.delegate = self;
    _leftTableView.allowsSelection = NO;
    _leftTableView.bounces = NO;
    [_leftView addSubview:_leftTableView];
    
    /* 左侧编辑桌子 */
    /* Line 1 */
    _leftEditView = [[UIView alloc] init];
    _leftEditView.backgroundColor = [UIColor whiteColor];
    [_leftView addSubview:_leftEditView];
    
    UIView *saveAndCancelView = [[UIView alloc] init];
    [_leftEditView addSubview:saveAndCancelView];
    
    UIView *aLineView = [[UIView alloc] init];
    aLineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [saveAndCancelView addSubview:aLineView];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnCancel setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    [saveAndCancelView addSubview:btnCancel];
    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave setTitle:@"保存" forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnSave setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(saveTableNum) forControlEvents:UIControlEventTouchUpInside];
    [saveAndCancelView addSubview:btnSave];
    
    [_leftEditView addSubview:saveAndCancelView];
    
    /* Line 2 */
    UIView *nameView = [[UIView alloc] init];
    UIView *blineView = [[UIView alloc] init];
    blineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [nameView addSubview:blineView];
    
    UILabel *labName = [[UILabel alloc] init];
    labName.text = @"名称";
    labName.font = [UIFont systemFontOfSize:14.0];
    labName.textColor = [UIColor colorWithHexString:@"333333"];
    [nameView addSubview:labName];
    
    _nameTextField = [[UITextField alloc] init];
    _nameTextField.layer.borderColor = [[UIColor colorWithHexString:@"#DDDDDD"] CGColor];
    _nameTextField.layer.borderWidth = 1.0;
    [nameView addSubview:_nameTextField];
    
    [_leftEditView addSubview:nameView];
    
    /* Line 3 */
    UIView *rotateView = [[UIView alloc] init];
    UIView *clineView = [[UIView alloc] init];
    clineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [rotateView addSubview:clineView];
    
    UILabel *rotateTitle = [[UILabel alloc] init];
    rotateTitle.text = @"编辑方向";
    rotateTitle.font = [UIFont systemFontOfSize:14.0];
    rotateTitle.textColor = [UIColor colorWithHexString:@"#333333"];
    [rotateView addSubview:rotateTitle];
    
    UIButton *btnTurnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTurnLeft setImage:[UIImage imageNamed:@"turnleft"] forState:UIControlStateNormal];
    [btnTurnLeft addTarget:self action:@selector(turnleftDragView:) forControlEvents:UIControlEventTouchUpInside];
    [rotateView addSubview:btnTurnLeft];
    
    UIButton *btnTurnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnTurnRight setImage:[UIImage imageNamed:@"turnright"] forState:UIControlStateNormal];
    [btnTurnRight addTarget:self action:@selector(turnrightDragView:) forControlEvents:UIControlEventTouchUpInside];
    [rotateView addSubview:btnTurnRight];
    
    [_leftEditView addSubview:rotateView];
    
    /* Line 4 */
    UIView *deleteView = [[UIView alloc] init];
    UIView *dlineView = [[UIView alloc] init];
    dlineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [deleteView addSubview:dlineView];
    
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.backgroundColor = [UIColor colorWithHexString:@"#FB4C52"];
    btnDelete.layer.cornerRadius = 4.0;
    [btnDelete setTitle:@"删除物品" forState:UIControlStateNormal];
    btnDelete.titleLabel.textColor = [UIColor whiteColor];
    [btnDelete addTarget:self action:@selector(removeTable:) forControlEvents:UIControlEventTouchUpInside];
    [deleteView addSubview:btnDelete];
    
    [_leftEditView addSubview:deleteView];
    
    [_leftView bringSubviewToFront:_leftTableView];
    
    [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ws.view.mas_left);
        make.top.equalTo(ws.view.mas_top).offset(kNavigationHeight);
        make.width.mas_equalTo(kLeftViewWidth);
        make.height.equalTo(ws.view.mas_height);
    }];
    
    [_leftTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftView.mas_left);
        make.top.equalTo(_leftView.mas_top);
        make.width.equalTo(_leftView.mas_width);
        make.height.mas_equalTo(kSubTitleHeight);
    }];
    
    [_leftTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftView.mas_left);
        make.top.equalTo(_leftTitle.mas_bottom);
        make.width.equalTo(_leftView.mas_width);
        make.bottom.equalTo(ws.view.mas_bottom);
    }];
    
    [_leftEditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftTableView.mas_left);
        make.top.equalTo(_leftTableView.mas_top);
        make.width.equalTo(_leftTableView.mas_width);
        make.height.equalTo(_leftTableView.mas_height);
    }];
    
    [saveAndCancelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftEditView.mas_left);
        make.top.equalTo(_leftEditView.mas_top);
        make.width.equalTo(_leftEditView.mas_width);
        make.height.mas_equalTo(@40.0);
    }];
    
    [aLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(saveAndCancelView.mas_left);
        make.top.equalTo(saveAndCancelView.mas_top);
        make.width.equalTo(saveAndCancelView.mas_width);
        make.height.mas_equalTo(@1.0);
    }];
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(saveAndCancelView.mas_left).offset(10.0);
        make.top.equalTo(saveAndCancelView.mas_top).offset(5.0);
        make.width.mas_equalTo(@50.0);
        make.height.mas_equalTo(@30.0);
    }];
    
    [btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(saveAndCancelView.mas_right).offset(-10.0);
        make.top.equalTo(saveAndCancelView.mas_top).offset(5.0);
        make.width.mas_equalTo(@50.0);
        make.height.mas_equalTo(@30.0);
    }];
    
    [nameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftEditView.mas_left);
        make.top.equalTo(_leftEditView.mas_top).offset(40.0);
        make.width.equalTo(saveAndCancelView.mas_width);
        make.height.equalTo(saveAndCancelView.mas_height);
    }];
    
    [blineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameView.mas_left);
        make.top.equalTo(nameView.mas_top);
        make.width.equalTo(nameView.mas_width);
        make.height.mas_equalTo(@1.0);
    }];
    
    [labName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nameView.mas_left).offset(20.0);
        make.top.equalTo(nameView.mas_top).offset(5.0);
        make.width.mas_equalTo(@50.0);
        make.height.mas_equalTo(@30.0);
    }];
    
    [_nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labName.mas_right).with.offset(10.0);
        make.top.equalTo(labName.mas_top);
        make.width.mas_equalTo(@180.0);
        make.height.mas_equalTo(@30.0);
    }];
    
    [rotateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftEditView.mas_left);
        make.top.equalTo(_leftEditView.mas_top).offset(80.0);
        make.width.equalTo(_leftEditView.mas_width);
        make.height.mas_equalTo(@120.0);
    }];
    
    [clineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rotateView.mas_left);
        make.top.equalTo(rotateView.mas_top);
        make.width.equalTo(rotateView.mas_width);
        make.height.mas_equalTo(@1.0);
    }];
    
    [rotateTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rotateView.mas_left).offset(20.0);
        make.top.equalTo(rotateView.mas_top).offset(5.0);
        make.width.mas_equalTo(@80.0);
        make.height.mas_equalTo(@30.0);
    }];
    
    [btnTurnLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rotateView.mas_left).offset(60.0);
        make.top.equalTo(rotateTitle.mas_bottom).with.offset(10.0);
        make.width.mas_equalTo(@60.0);
        make.height.mas_equalTo(@60.0);
    }];
    
    [btnTurnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rotateView.mas_right).offset(-60.0);
        make.top.equalTo(btnTurnLeft.mas_top);
        make.width.mas_equalTo(@60.0);
        make.height.mas_equalTo(@60.0);
    }];
    
    [deleteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftEditView.mas_left);
        make.top.equalTo(_leftEditView.mas_top).offset(200.0);
        make.width.equalTo(_leftEditView.mas_width);
        make.height.mas_equalTo(@80.0);
    }];
    
    [dlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(deleteView.mas_left);
        make.top.equalTo(deleteView.mas_top);
        make.width.equalTo(deleteView.mas_width);
        make.height.mas_equalTo(1.0);
    }];
    
    [btnDelete mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(deleteView.mas_centerX);
        make.centerY.equalTo(deleteView.mas_centerY);
        make.width.mas_equalTo(@150.0);
        make.height.mas_equalTo(@40.0);
    }];
    
    /* Right */
    _rightView = [[UIView alloc] init];
    _rightView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_rightView];
    
    _rightTitle = [[UILabel alloc] init];
    _rightTitle.backgroundColor = [UIColor colorWithHexString:@"#555555"];
    _rightTitle.text = @"一楼平面图";
    _rightTitle.font = [UIFont systemFontOfSize:15.0];
    _rightTitle.textColor = [UIColor whiteColor];
    _rightTitle.textAlignment = NSTextAlignmentCenter;
    [_rightView addSubview:_rightTitle];
    
    _rightScrollView = [[UIScrollView alloc] init];
    _rightScrollView.scrollEnabled = YES;
    _rightScrollView.bounces = NO;
    _rightScrollView.minimumZoomScale = 0.5;
    _rightScrollView.maximumZoomScale = 3.0;
    _rightScrollView.delegate = self;
    _rightScrollView.tag = 9999;
    [_rightView addSubview:_rightScrollView];
    
    _rightCanvas = [[ATGridView alloc] init];
    [_rightScrollView addSubview:_rightCanvas];
    
    [_rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftView.mas_right);
        make.top.equalTo(_leftView.mas_top);
        make.right.equalTo(ws.view);
        make.bottom.equalTo(ws.view);
    }];
    
    [_rightTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_rightView.mas_left);
        make.top.equalTo(_rightView.mas_top);
        make.width.equalTo(_rightView.mas_width);
        make.height.mas_equalTo(kSubTitleHeight);
    }];
    
    [_rightScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftView.mas_right);
        make.top.equalTo(_rightTitle.mas_bottom);
        make.width.equalTo(_rightView.mas_width);
        make.bottom.equalTo(_rightView.mas_bottom);
    }];
    
    [_rightCanvas mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_rightScrollView.mas_left);
        make.top.equalTo(_rightScrollView.mas_top);
        make.edges.equalTo(_rightScrollView);
        make.width.mas_equalTo(kGridRows*kGridWidth);
        make.height.mas_equalTo(kGridColumns*kGridWidth);
    }];
}

- (void)turnleftDragView:(UIButton *)sender {
    if (_editDragView) {
        [_editDragView rotateLeft];
    }
}

- (void)turnrightDragView:(UIButton *)sender {
    if (_editDragView) {
        [_editDragView rotateRight];
    }
}

- (void)removeTable:(UIButton *)sender {
    if (_editDragView) {
        [[ATGlobal shareGlobal] removeTableById:_editDragView.tableId];
        [_editDragView removeFromSuperview];
        [_leftView bringSubviewToFront:_leftTableView];
        _leftTitle.text = @"放置桌椅";
        _editDragView = nil;
        _isEdit = NO;
    }
}

- (void)saveTableNum {
    [_nameTextField resignFirstResponder];
    _editDragView.labTableName.text = _nameTextField.text;
}

- (void)cancelEdit {
    [_nameTextField resignFirstResponder];
    if (_isEdit) {
        [_leftView bringSubviewToFront:_leftTableView];
        _leftTitle.text = @"放置桌椅";
        if (_editDragView.isAtErrorPosition) {
            _editDragView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg_red"]];
        } else {
            _editDragView.backgroundColor = [UIColor clearColor];
        }
        _editDragView.layer.borderWidth = 0.0;
        _editDragView.isEditing = NO;
        _editDragView = nil;
        _isEdit = NO;
    }
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (([_tableData[indexPath.row][@"items"] count]+1)/2)*135+40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _tableData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"_LeftTableViewCell_%ld", (long)indexPath.row];
    ATLeftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[ATLeftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withDragViewDelegate:self];
        cell.tableItems = _tableData[indexPath.row][@"items"];
        cell.labTableType.text = _tableData[indexPath.row][@"name"];
        [cell buildTablesWithParent];
    }

    return cell;
}

#pragma mark - ATDragViewDelegate
- (void)dragViewDidStartDragging:(ATDragView *)dragView {
    
}

- (void)dragViewDidMoveDragging:(ATDragView *)dragView {
    [_currentSuggestView removeFromSuperview];
    _currentSuggestView = dragView.suggestView;
    [_rightCanvas addSubview:_currentSuggestView];
    [_rightCanvas bringSubviewToFront:dragView];
}

- (void)dragViewDidEndDragging:(ATDragView *)dragView {
    [_currentSuggestView removeFromSuperview];
    if (![dragView isDescendantOfView:_rightCanvas]) {
        [_rightCanvas addSubview:dragView];
    }
    dragView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dragViewSingleTap:)];
    [dragView addGestureRecognizer:singleTap];
}

- (void)dragViewSingleTap:(UITapGestureRecognizer *)sender
{
    [_nameTextField resignFirstResponder];
    if (_isEdit) {
        [_leftView bringSubviewToFront:_leftTableView];
        _leftTitle.text = @"放置桌椅";
        _editDragView.layer.borderWidth = 0.0;
        _editDragView.isEditing = NO;
        _editDragView = nil;
        _isEdit = NO;
    } else {
        [_leftView bringSubviewToFront:_leftEditView];
        _leftTitle.text = @"编辑物品";
        _editDragView = (ATDragView *)sender.view;
        _editDragView.isEditing = YES;
        //_editDragView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg_green"]];
        _editDragView.layer.borderWidth = 1.0;
        _editDragView.layer.borderColor = [[UIColor colorWithHexString:@"#79C23B"] CGColor];
        _nameTextField.text = _editDragView.labTableName.text;
        _isEdit = YES;
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [ATGlobal shareGlobal].scrollViewZoomScale = scrollView.zoomScale;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _rightCanvas;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 9999) {
        [ATGlobal shareGlobal].scrollViewOffset = scrollView.contentOffset;
    }
}

@end
