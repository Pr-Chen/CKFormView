//
//  CKFormView.h
//  表格
//
//  Created by 孟另娇 on 16/8/1.
//  Copyright © 2016年 孟另娇. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    NSInteger row;
    NSInteger column;
} CKFormCellPosition;

@class CKFormView;
@protocol CKFormViewDelegate <NSObject>

@optional
#pragma mark - 数据源
- (NSInteger)numberOfRowsInFormView:(CKFormView *)formView;
- (NSInteger)formView:(CKFormView *)formView numberOfColumnsForRow:(NSInteger)row;
- (CGFloat)formView:(CKFormView *)formView heightForRow:(NSInteger)row;
- (CGFloat)formView:(CKFormView *)formView widthForPosition:(CKFormCellPosition)position;

- (NSString *)formView:(CKFormView *)formView textForPosition:(CKFormCellPosition)position;
#pragma mark - 样式
- (NSTextAlignment)formView:(CKFormView *)formView textAlignmentForPosition:(CKFormCellPosition)position;
- (UIFont *)formView:(CKFormView *)formView fontForPosition:(CKFormCellPosition)position;
- (UIColor *)formView:(CKFormView *)formView textColorForPosition:(CKFormCellPosition)position;
- (UIColor *)formView:(CKFormView *)formView backgroundColorForPosition:(CKFormCellPosition)position;

- (CGFloat)formView:(CKFormView *)formView verticalLineWidthForPosition:(CKFormCellPosition)position;
- (UIColor *)formView:(CKFormView *)formView verticalLineColorForPosition:(CKFormCellPosition)position;
- (CGFloat)formView:(CKFormView *)formView bottomLineWidthForRow:(NSInteger)row;
- (UIColor *)formView:(CKFormView *)formView bottomLineColorForRow:(NSInteger)row;

- (UIKeyboardType)formView:(CKFormView *)formView keyboardTypeForPosition:(CKFormCellPosition)position;

#pragma mark - 编辑
- (BOOL)formView:(CKFormView *)formView editableForPosition:(CKFormCellPosition)position;
- (BOOL)formView:(CKFormView *)formView shouldBeginEditingForPosition:(CKFormCellPosition)position;
- (void)formView:(CKFormView *)formView didBeginEditingForPosition:(CKFormCellPosition)position;
- (void)formView:(CKFormView *)formView didEndEditingForPosition:(CKFormCellPosition)position;
- (void)formView:(CKFormView *)formView didChangeTextForPosition:(CKFormCellPosition)position;
- (BOOL)formView:(CKFormView *)formView shouldChangeCharactersWithReplacementString:(NSString *)string forPosition:(CKFormCellPosition)position;
//键盘弹出后,编辑行与键盘顶部的距离.负数代表键盘遮挡了编辑行
- (void)formView:(CKFormView *)formView edittingRowBottomToKeyboardTopSpacing:(CGFloat)spacing;

@end

@interface CKFormView : UIView

@property (weak, nonatomic) id<CKFormViewDelegate> delegate;

@property (strong, nonatomic) UITableView *tableView;

@property (assign, nonatomic) NSInteger numberOfRows;
@property (assign, nonatomic) NSInteger numberOfColumns;
@property (assign, nonatomic) CGFloat rowHeight;
@property (assign, nonatomic) CGFloat columnWidth;
//表头的高
@property (assign, nonatomic) CGFloat headerHeight;
@property (strong, nonatomic) UIView *headerView;

@property (strong, nonatomic) UIColor *verticalLineColor;
@property (assign, nonatomic) CGFloat verticalLineWidth;

@property (strong, nonatomic) UIColor *horizontalLineColor;
@property (assign, nonatomic) CGFloat horizontalLineWidth;

@property (strong, nonatomic) UIColor *borderColor;
@property (assign, nonatomic) CGFloat borderWidth;

@property (assign, nonatomic) NSTextAlignment textAlignment;
@property (strong, nonatomic) UIFont *textFont;
@property (strong, nonatomic) UIColor *textColor;
//单元格背景
@property (strong, nonatomic) UIColor *cellBackgroundColor;

//是否可编辑
@property (assign, nonatomic) BOOL editable;
@property (assign, nonatomic) BOOL bounces;
@property (assign, nonatomic) BOOL isEditing;
//最后一条横线是否隐藏
@property (assign, nonatomic) BOOL lastHorizontalLineHidden;

@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign, readonly) CGSize contentSize;
//表格的完整高度,计算所有行高的和及所有列宽还有边框(不直接用contentSize是因为需等到内部布局完成才能使用它)
@property (nonatomic, assign, readonly) CGFloat fullHeight;

- (NSString *)textForPosition:(CKFormCellPosition)position;
- (void)setText:(NSString *)text forPosition:(CKFormCellPosition)position;

- (void)reloadData;

@end
