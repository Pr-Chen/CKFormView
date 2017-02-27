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
//行数
- (NSInteger)numberOfRowsInFormView:(CKFormView *)formView;

//列数
- (NSInteger)formView:(CKFormView *)formView numberOfColumnsForRow:(NSInteger)row;

//每个单元格要显示的内容
- (NSString *)formView:(CKFormView *)formView textForPosition:(CKFormCellPosition)position;

#pragma mark - 样式
//行高
- (CGFloat)formView:(CKFormView *)formView heightForRow:(NSInteger)row;

//列宽
- (CGFloat)formView:(CKFormView *)formView widthForPosition:(CKFormCellPosition)position;

//文字对齐方式
- (NSTextAlignment)formView:(CKFormView *)formView textAlignmentForPosition:(CKFormCellPosition)position;

//每个单元格的字体
- (UIFont *)formView:(CKFormView *)formView fontForPosition:(CKFormCellPosition)position;

//文字颜色
- (UIColor *)formView:(CKFormView *)formView textColorForPosition:(CKFormCellPosition)position;

//背景颜色
- (UIColor *)formView:(CKFormView *)formView backgroundColorForPosition:(CKFormCellPosition)position;

//竖直分割线的宽度
- (CGFloat)formView:(CKFormView *)formView verticalLineWidthForPosition:(CKFormCellPosition)position;

//竖直分割线的颜色
- (UIColor *)formView:(CKFormView *)formView verticalLineColorForPosition:(CKFormCellPosition)position;

//水平分割线的宽度
- (CGFloat)formView:(CKFormView *)formView bottomLineWidthForRow:(NSInteger)row;

//水平分割线的颜色
- (UIColor *)formView:(CKFormView *)formView bottomLineColorForRow:(NSInteger)row;

//键盘类型
- (UIKeyboardType)formView:(CKFormView *)formView keyboardTypeForPosition:(CKFormCellPosition)position;

#pragma mark - 编辑
//是否可编辑
- (BOOL)formView:(CKFormView *)formView editableForPosition:(CKFormCellPosition)position;

//是否应该进入编辑状态
- (BOOL)formView:(CKFormView *)formView shouldBeginEditingForPosition:(CKFormCellPosition)position;

//已经开始编辑
- (void)formView:(CKFormView *)formView didBeginEditingForPosition:(CKFormCellPosition)position;

//结束编辑
- (void)formView:(CKFormView *)formView didEndEditingForPosition:(CKFormCellPosition)position;

//内容已改变
- (void)formView:(CKFormView *)formView didChangeTextForPosition:(CKFormCellPosition)position;

//内容是否应该变化
- (BOOL)formView:(CKFormView *)formView shouldChangeCharactersWithReplacementString:(NSString *)string forPosition:(CKFormCellPosition)position;
//键盘弹出后,编辑行与键盘顶部的距离.负数代表键盘遮挡了编辑行
- (void)formView:(CKFormView *)formView edittingRowBottomToKeyboardTopSpacing:(CGFloat)spacing;

@end

@interface CKFormView : UIView

@property (weak, nonatomic) id<CKFormViewDelegate> delegate;

@property (strong, nonatomic) UITableView *tableView;

/*
设置这4个属性,则无需在代理方法中设置
*/
@property (assign, nonatomic) NSInteger numberOfRows;
@property (assign, nonatomic) NSInteger numberOfColumns;
@property (assign, nonatomic) CGFloat rowHeight;
@property (assign, nonatomic) CGFloat columnWidth;

//可以设置一个滚动时,固定在顶部的表头
@property (assign, nonatomic) CGFloat headerHeight;
@property (strong, nonatomic) UIView *headerView;

//竖直分割线的颜色
@property (strong, nonatomic) UIColor *verticalLineColor;
//竖直分割线的宽度
@property (assign, nonatomic) CGFloat verticalLineWidth;
//水平分割线的颜色
@property (strong, nonatomic) UIColor *horizontalLineColor;
//水平分割线的宽度
@property (assign, nonatomic) CGFloat horizontalLineWidth;
//表格边框的颜色
@property (strong, nonatomic) UIColor *borderColor;
//表格边框的宽度
@property (assign, nonatomic) CGFloat borderWidth;

//单元格中文字对齐方式
@property (assign, nonatomic) NSTextAlignment textAlignment;
//单元格中文字字体
@property (strong, nonatomic) UIFont *textFont;
//单元格中文字颜色
@property (strong, nonatomic) UIColor *textColor;
//单元格背景
@property (strong, nonatomic) UIColor *cellBackgroundColor;

//是否可编辑
@property (assign, nonatomic) BOOL editable;
//是否有弹性效果(行数较少显示全部行的时候可以设置为NO)
@property (assign, nonatomic) BOOL bounces;
//是否正在编辑
@property (assign, nonatomic) BOOL isEditing;
//最后一条横线是否隐藏
@property (assign, nonatomic) BOOL lastHorizontalLineHidden;
//能否滚动
@property (nonatomic, assign) BOOL scrollEnabled;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign, readonly) CGSize contentSize;
//表格的完整高度,计算所有行高的和及所有列宽还有边框(不直接用contentSize是因为需等到内部布局完成才能使用它)
@property (nonatomic, assign, readonly) CGFloat fullHeight;

- (NSString *)textForPosition:(CKFormCellPosition)position;
- (void)setText:(NSString *)text forPosition:(CKFormCellPosition)position;
//重载数据
- (void)reloadData;

@end
