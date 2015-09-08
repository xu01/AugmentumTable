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
    
    _leftEditView = [[UIView alloc] initWithFrame:CGRectMake(0.0, kSubTitleHeight, kLeftViewWidth, _leftView.frame.size.height-kSubTitleHeight)];
    _leftEditView.backgroundColor = [UIColor whiteColor];
    
    UIView *editView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLeftViewWidth, 40.0)];
    editView.backgroundColor = [UIColor whiteColor];
    
    UIView *alineView = [[UIView alloc] initWithFrame:CGRectMake(0.0 , 0.0, kLeftViewWidth, kLineHeight)];
    alineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [editView addSubview:alineView];
    
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    btnCancel.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnCancel setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [btnCancel addTarget:self action:@selector(cancelEdit) forControlEvents:UIControlEventTouchUpInside];
    btnCancel.frame = CGRectMake(10.0, 5.0, 50.0, 30.0);
    [editView addSubview:btnCancel];
    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave setTitle:@"保存" forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btnSave setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [btnSave addTarget:self action:@selector(saveTableNum) forControlEvents:UIControlEventTouchUpInside];
    btnSave.frame = CGRectMake(kLeftViewWidth-60.0, 5.0, 50.0, 30.0);
    [editView addSubview:btnSave];
    
    [_leftEditView addSubview:editView];
    
    UIView *nameView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 40.0, kLeftViewWidth, 40.0)];
    nameView.backgroundColor = [UIColor whiteColor];
    
    UILabel *tableNum = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 5.0, kLeftViewWidth*0.2, 30.0)];
    tableNum.text = @"名称";
    tableNum.font = [UIFont systemFontOfSize:14.0];
    tableNum.textColor = [UIColor colorWithHexString:@"333333"];
    [nameView addSubview:tableNum];
    
    _nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(kLeftViewWidth*0.2+20.0, 5.0, kLeftViewWidth*0.5, 30.0)];
    _nameTextField.layer.borderColor = [[UIColor colorWithHexString:@"#DDDDDD"] CGColor];
    _nameTextField.layer.borderWidth = 1.0;
    [nameView addSubview:_nameTextField];
    
    UIView *blineView = [[UIView alloc] initWithFrame:CGRectMake(0.0 , 0.0, kLeftViewWidth, kLineHeight)];
    blineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [nameView addSubview:blineView];
    [_leftEditView addSubview:nameView];
    
    UIView *rotateView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, kLeftViewWidth, 160.0)];
    rotateView.backgroundColor = [UIColor whiteColor];
    
    UIView *clineView = [[UIView alloc] initWithFrame:CGRectMake(0.0 , 0.0, kLeftViewWidth, kLineHeight)];
    clineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [rotateView addSubview:clineView];
    
    UILabel *rotateTitle = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10.0, 80.0, 30.0)];
    rotateTitle.text = @"编辑方向";
    rotateTitle.font = [UIFont systemFontOfSize:14.0];
    rotateTitle.textColor = [UIColor colorWithHexString:@"#333333"];
    [rotateView addSubview:rotateTitle];
    
    UIButton *btnTurnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTurnLeft.frame = CGRectMake(60.0, 50.0, 60.0, 60.0);
    [btnTurnLeft setImage:[UIImage imageNamed:@"turnleft"] forState:UIControlStateNormal];
    [btnTurnLeft addTarget:self action:@selector(turnleftDragView:) forControlEvents:UIControlEventTouchUpInside];
    [rotateView addSubview:btnTurnLeft];
    
    UIButton *btnTurnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTurnRight.frame = CGRectMake(160.0, 50.0, 60.0, 60.0);
    [btnTurnRight setImage:[UIImage imageNamed:@"turnright"] forState:UIControlStateNormal];
    [btnTurnRight addTarget:self action:@selector(turnrightDragView:) forControlEvents:UIControlEventTouchUpInside];
    [rotateView addSubview:btnTurnRight];
    
    [_leftEditView addSubview:rotateView];
    
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 240.0, kLeftViewWidth, 80.0)];
    deleteView.backgroundColor = [UIColor whiteColor];
    
    UIView *dlineView = [[UIView alloc] initWithFrame:CGRectMake(0.0 , 0.0, kLeftViewWidth, kLineHeight)];
    dlineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [deleteView addSubview:dlineView];
    
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDelete.backgroundColor = [UIColor colorWithHexString:@"#FB4C52"];
    btnDelete.layer.cornerRadius = 4.0;
    btnDelete.frame = CGRectMake((kLeftViewWidth-150.0)/2, 20, 150.0, 40.0);
    [btnDelete setTitle:@"删除物品" forState:UIControlStateNormal];
    btnDelete.titleLabel.textColor = [UIColor whiteColor];
    [btnDelete addTarget:self action:@selector(removeTable:) forControlEvents:UIControlEventTouchUpInside];
    [deleteView addSubview:btnDelete];
    
    [_leftEditView addSubview:deleteView];
    
    [_leftView addSubview:_leftEditView];
    
    [_leftView bringSubviewToFront:_leftTableView];
    
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
    _rightScrollView.tag = 9999;
    _rightScrollView.contentSize = CGSizeMake(kGridRows*kGridWidth, kGridColumns*kGridWidth);
    [_rightView addSubview:_rightScrollView];
    
    _rightCanvas = [[ATGridView alloc] initWithFrame:CGRectMake(0.0, 0.0, kGridRows*kGridWidth, kGridColumns*kGridWidth)];
    [_rightScrollView addSubview:_rightCanvas];
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
    _editDragView.labelNum.text = _nameTextField.text;
}

- (void)cancelEdit {
    [_nameTextField resignFirstResponder];
    if (_isEdit) {
        [_leftView bringSubviewToFront:_leftTableView];
        _leftTitle.text = @"放置桌椅";
        if (_editDragView.isErrorPosition) {
            _editDragView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg_red"]];
        } else {
            _editDragView.backgroundColor = [UIColor clearColor];
        }
        _editDragView.layer.borderWidth = 0.0;
        _editDragView.isEdit = NO;
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
    //ATLeftTableViewCell *cell = (ATLeftTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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
    //[_currentSuggestView removeFromSuperview];
    //_currentSuggestView = dragView.suggestView;
    //[_rightCanvas addSubview:_currentSuggestView];
}

- (void)dragViewDidEndDragging:(ATDragView *)dragView {
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
        if (_editDragView.isErrorPosition) {
            _editDragView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg_red"]];
        } else {
            _editDragView.backgroundColor = [UIColor clearColor];
        }
        _editDragView.layer.borderWidth = 0.0;
        _editDragView.isEdit = NO;
        _editDragView = nil;
        _isEdit = NO;
    } else {
        [_leftView bringSubviewToFront:_leftEditView];
        _leftTitle.text = @"编辑物品";
        _editDragView = (ATDragView *)sender.view;
        _editDragView.isEdit = YES;
        //_editDragView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg_green"]];
        _editDragView.layer.borderWidth = 1.0;
        _editDragView.layer.borderColor = [[UIColor colorWithHexString:@"#79C23B"] CGColor];
        _nameTextField.text = _editDragView.labelNum.text;
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
