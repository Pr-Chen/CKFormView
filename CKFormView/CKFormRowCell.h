//
//  CKFormRowCell.h
//  表格
//
//  Created by 孟另娇 on 16/8/1.
//  Copyright © 2016年 孟另娇. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKFormRowCell;
@protocol CKFormRowCellDelegate <NSObject>

@optional
- (NSInteger)numberOfColumnsInFormRowCell:(CKFormRowCell *)cell;
- (CGFloat)formRowCell:(CKFormRowCell *)cell widthForColumn:(NSInteger)column;
- (BOOL)formRowCell:(CKFormRowCell *)cell editableForColumn:(NSInteger)column;
- (NSString *)formRowCell:(CKFormRowCell *)cell textForColumn:(NSInteger)column;
- (CGFloat)formRowCell:(CKFormRowCell *)cell verticalLineWidthForColumn:(NSInteger)column;
- (UIColor *)formRowCell:(CKFormRowCell *)cell verticalLineColorForColumn:(NSInteger)column;

- (NSTextAlignment)formRowCell:(CKFormRowCell *)cell textAlignmentForColumn:(NSInteger)column;
- (UIFont *)formRowCell:(CKFormRowCell *)cell fontForColumn:(NSInteger)column;
- (UIColor *)formRowCell:(CKFormRowCell *)cell textColorForColumn:(NSInteger)column;
- (UIColor *)formRowCell:(CKFormRowCell *)cell backgroundColorForColumn:(NSInteger)column;
- (UIKeyboardType)formRowCell:(CKFormRowCell *)cell keyboardTypeForColumn:(NSInteger)column;

- (BOOL)formRowCell:(CKFormRowCell *)cell shouldBeginEditingForColumn:(NSInteger)column;
- (void)formRowCell:(CKFormRowCell *)cell didBeginEditingForColumn:(NSInteger)column;
- (void)formRowCell:(CKFormRowCell *)cell willEndEditingForColumn:(NSInteger)column;
- (void)formRowCell:(CKFormRowCell *)cell didEndEditingForColumn:(NSInteger)column;
- (void)formRowCell:(CKFormRowCell *)cell didChangeTextForColumn:(NSInteger)column;
- (BOOL)formRowCell:(CKFormRowCell *)cell shouldChangeCharactersWithReplacementString:(NSString *)string ForColumn:(NSInteger)column;

@end

@interface CKFormRowCell : UITableViewCell

//列数
@property (assign, nonatomic) NSInteger numberOfColumns;

//列宽
@property (assign, nonatomic) CGFloat columnWidth;

//竖直分隔线的颜色
@property (strong, nonatomic) UIColor *verticalLineColor;

//竖直分割线的粗细
@property (assign, nonatomic) CGFloat verticalLineWidth;

//是否需要底部分隔线
@property (assign, nonatomic) BOOL bottomLineHidden;

//底部分隔线的颜色
@property (strong, nonatomic) UIColor *bottomLineColor;

//底部分割线的粗细
@property (assign, nonatomic) CGFloat bottomLineWidth;

//当前选中单元格的frame
@property (assign, nonatomic) CGRect selectedCellFrame;

//是否可编辑
@property (assign, nonatomic) BOOL editable;

@property (weak, nonatomic) id<CKFormRowCellDelegate> delegate;

+ (NSString *)cellID;
- (NSString *)textForColumn:(NSInteger)column;
- (void)setText:(NSString *)text forColumn:(NSInteger)column;
- (UITextField *)textFieldForColumn:(NSInteger)column;

@end
