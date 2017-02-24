//
//  CKFormView.m
//  表格
//
//  Created by 孟另娇 on 16/8/1.
//  Copyright © 2016年 孟另娇. All rights reserved.
//

#import "CKFormView.h"
#import "CKFormRowCell.h"


@interface CKFormView () <UITableViewDataSource, UITableViewDelegate, CKFormRowCellDelegate>

@property (strong, nonatomic) CAShapeLayer *verLineLayer;

//选中框
@property (strong, nonatomic) CALayer *selectedBox;

//选中行的cell
@property (strong, nonatomic) CKFormRowCell *selectedRowCell;

@end

@implementation CKFormView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self defaultSetting];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self defaultSetting];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.frame = CGRectMake(self.borderWidth, self.borderWidth, self.bounds.size.width - 2*self.borderWidth, self.bounds.size.height - 2*self.borderWidth);
    
    CGRect rect = [self.selectedRowCell convertRect:self.selectedRowCell.selectedCellFrame toView:_tableView];
    _selectedBox.frame = rect;
}

- (void)defaultSetting {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    self.borderColor = [UIColor colorWithWhite:0.3 alpha:1];
    self.borderWidth = 1.5;
    
    self.horizontalLineColor = [UIColor colorWithWhite:0.66 alpha:1];
    self.horizontalLineWidth = 1;
    
    self.verticalLineColor = [UIColor colorWithWhite:0.66 alpha:1];
    self.verticalLineWidth = 1;
    
    self.rowHeight = 47;
    self.headerHeight = 0;
    
    self.editable = YES;
    self.bounces = NO;
    
    self.lastHorizontalLineHidden = YES;
    
    self.textFont = [UIFont systemFontOfSize:13];
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor colorWithWhite:0.2 alpha:1];
    
}

#pragma mark - 通知
- (void)keyboardWillShow:(NSNotification *)noti {
    
    CGRect keyboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect selectedCellFrame = self.selectedRowCell.selectedCellFrame;
    CGRect resultFrame = [self.selectedRowCell convertRect:selectedCellFrame toView:[UIApplication sharedApplication].keyWindow];
    CGFloat distance = keyboardFrame.origin.y - CGRectGetMaxY(resultFrame);
    if ([self.delegate respondsToSelector:@selector(formView:edittingRowBottomToKeyboardTopSpacing:)]) {
        [self.delegate formView:self edittingRowBottomToKeyboardTopSpacing:distance];
    }
}

- (void)keyboardWillHidden:(NSNotification *)noti {
    if (!self.selectedRowCell) {
        self.selectedBox.hidden = YES;
    }
}

#pragma mark - tableView 数据源和代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(numberOfRowsInFormView:)]) {
        return [self.delegate numberOfRowsInFormView:self];
    }
    return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKFormRowCell *cell = [tableView dequeueReusableCellWithIdentifier:[CKFormRowCell cellID]];
    if (!cell) {
        cell = [[CKFormRowCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[CKFormRowCell cellID]];
        cell.delegate = self;
    }
    
    NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    cell.bottomLineHidden = (indexPath.row == numberOfRows-1) ? self.lastHorizontalLineHidden : NO;
    
    if ([self.delegate respondsToSelector:@selector(formView:bottomLineColorForRow:)]) {
        cell.bottomLineColor = [self.delegate formView:self bottomLineColorForRow:indexPath.row];
    }
    else {
        cell.bottomLineColor = self.horizontalLineColor;
    }
    
    if ([self.delegate respondsToSelector:@selector(formView:bottomLineWidthForRow:)]) {
        cell.bottomLineWidth = [self.delegate formView:self bottomLineWidthForRow:indexPath.row];
    }
    else {
        cell.bottomLineWidth = self.horizontalLineWidth;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(formView:heightForRow:)]) {
        return [self.delegate formView:self heightForRow:indexPath.row];
    }
    return self.rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (self.headerHeight == 0) {
        return nil;
    }
    
    return self.headerView;
}

#pragma mark - scrollView代理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing:YES];
}

#pragma mark - cell代理

#pragma mark -- 数据源
- (NSInteger)numberOfColumnsInFormRowCell:(CKFormRowCell *)cell {
    if ([self.delegate respondsToSelector:@selector(formView:numberOfColumnsForRow:)]) {
        
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        NSInteger columnCount = [self.delegate formView:self numberOfColumnsForRow:indexPath.row];
        return columnCount;
    }
    return self.numberOfColumns;
}

- (CGFloat)formRowCell:(CKFormRowCell *)cell widthForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:widthForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self widthForPosition:position];
    }
    return self.columnWidth;
}

- (NSString *)formRowCell:(CKFormRowCell *)cell textForColumn:(NSInteger)column {
    
    if ([self.delegate respondsToSelector:@selector(formView:textForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self textForPosition:position];
    }
    return nil;
}

#pragma mark - 外观
- (NSTextAlignment)formRowCell:(CKFormRowCell *)cell textAlignmentForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:textAlignmentForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self textAlignmentForPosition:position];
    }
    return self.textAlignment;
}

- (UIFont *)formRowCell:(CKFormRowCell *)cell fontForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:fontForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self fontForPosition:position];
    }
    return self.textFont;
}

- (UIColor *)formRowCell:(CKFormRowCell *)cell textColorForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:textColorForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self textColorForPosition:position];
    }
    return self.textColor;
}

- (UIColor *)formRowCell:(CKFormRowCell *)cell backgroundColorForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:backgroundColorForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self backgroundColorForPosition:position];
    }
    return self.cellBackgroundColor;
}

- (CGFloat)formRowCell:(CKFormRowCell *)cell verticalLineWidthForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:verticalLineWidthForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self verticalLineWidthForPosition:position];
    }
    return self.verticalLineWidth;
}

- (UIColor *)formRowCell:(CKFormRowCell *)cell verticalLineColorForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:verticalLineColorForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self verticalLineColorForPosition:position];
    }
    return self.verticalLineColor;
}

- (UIKeyboardType)formRowCell:(CKFormRowCell *)cell keyboardTypeForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:keyboardTypeForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self keyboardTypeForPosition:position];
    }
    return UIKeyboardTypeDefault;
}

#pragma mark - 编辑
- (BOOL)formRowCell:(CKFormRowCell *)cell editableForColumn:(NSInteger)column {
    
    if ([self.delegate respondsToSelector:@selector(formView:editableForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self editableForPosition:position];
    }
    return self.editable;
}

- (BOOL)formRowCell:(CKFormRowCell *)cell shouldBeginEditingForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:shouldBeginEditingForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self shouldBeginEditingForPosition:position];
    }
    return YES;
}

- (void)formRowCell:(CKFormRowCell *)formRowCell didBeginEditingForColumn:(NSInteger)column {
    self.selectedRowCell = formRowCell;
    self.isEditing = YES;
    
    CGRect rect = [formRowCell convertRect:formRowCell.selectedCellFrame toView:_tableView];
    //从隐藏变成未隐藏不需要动画
    if (_selectedBox.hidden) {
        self.selectedBox.hidden = NO;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.selectedBox.frame = rect;
        [CATransaction commit];
    }
    else {
        self.selectedBox.frame = rect;
    }
    
    if ([self.delegate respondsToSelector:@selector(formView:didBeginEditingForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:formRowCell];
        CKFormCellPosition position = {indexPath.row,column};
        [self.delegate formView:self didBeginEditingForPosition:position];
    }
}

- (void)formRowCell:(CKFormRowCell *)cell willEndEditingForColumn:(NSInteger)column {
    self.selectedRowCell = nil;
}

- (void)formRowCell:(CKFormRowCell *)formRowCell didEndEditingForColumn:(NSInteger)column {
    self.isEditing = NO;
    if ([self.delegate respondsToSelector:@selector(formView:didEndEditingForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForCell:formRowCell];
        CKFormCellPosition position = {indexPath.row,column};
        [self.delegate formView:self didEndEditingForPosition:position];
    }
}

- (void)formRowCell:(CKFormRowCell *)cell didChangeTextForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:didChangeTextForPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        [self.delegate formView:self didChangeTextForPosition:position];
    }
}

- (BOOL)formRowCell:(CKFormRowCell *)cell shouldChangeCharactersWithReplacementString:(NSString *)string ForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formView:shouldChangeCharactersWithReplacementString:forPosition:)]) {
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:cell.center];
        CKFormCellPosition position = {indexPath.row,column};
        return [self.delegate formView:self shouldChangeCharactersWithReplacementString:string forPosition:position];
    }
    return YES;
}

#pragma mark - 其他

- (NSString *)textForPosition:(CKFormCellPosition)position {
    CKFormRowCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:position.row inSection:0]];
    return [cell textForColumn:position.column];
}

- (void)setText:(NSString *)text forPosition:(CKFormCellPosition)position {
    CKFormRowCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:position.row inSection:0]];
    [cell setText:text forColumn:position.column];
}

#pragma mark - getter & setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.bounces = self.bounces;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection = NO;
        [self addSubview:_tableView];
        
    }
    return _tableView;
}

- (void)setBorderColor:(UIColor *)borderColor {
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    _borderWidth = borderWidth;
    self.layer.borderWidth = borderWidth;
}

- (void)reloadData {
    [_tableView reloadData];
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.tableView.scrollEnabled = scrollEnabled;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    _tableView.contentOffset = contentOffset;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    self.tableView.bounces = self.bounces;
}

- (CGSize)contentSize {
    return _tableView.contentSize;
}

- (CGPoint)contentOffset {
    return _tableView.contentOffset;
}

- (CGFloat)fullHeight {
    
    CGFloat totalHeight = 0;
    NSInteger numberOfRows;
    if ([self.delegate respondsToSelector:@selector(numberOfRowsInFormView:)]) {
        numberOfRows = [self.delegate numberOfRowsInFormView:self];
    }
    else {
        numberOfRows = self.numberOfRows;
    }
    
    for (int i=0; i<numberOfRows; i++) {
        CGFloat height = 0;
        if ([self.delegate respondsToSelector:@selector(formView:heightForRow:)]) {
            height = [self.delegate formView:self heightForRow:i];
        }
        else {
            height = self.rowHeight;
        }
        
        totalHeight += height;
    }
    return totalHeight+2*self.borderWidth;
}

- (CALayer *)selectedBox {
    if (!_selectedBox) {
        _selectedBox = [CALayer layer];
        _selectedBox.borderColor = [UIColor colorWithRed:0.16 green:0.5 blue:0.27 alpha:1].CGColor;
        _selectedBox.borderWidth = 2.5;
        
        CALayer *headerLayer = [_tableView headerViewForSection:0].layer;
        if (headerLayer) {
            [_tableView.layer insertSublayer:_selectedBox below:headerLayer];
        }
        else {
            [_tableView.layer addSublayer:_selectedBox];
        }
    }
    return _selectedBox;
}

@end




