//
//  CKFormRowCell.m
//  表格
//
//  Created by 孟另娇 on 16/8/1.
//  Copyright © 2016年 孟另娇. All rights reserved.
//

#import "CKFormRowCell.h"

@interface CKFormRowCell () <UITextFieldDelegate>

@property (strong, nonatomic) CALayer *bottomLineLayer;

//竖直线段重用池和显示池
@property (strong, nonatomic) NSMutableSet *reuseLinesSet;
@property (strong, nonatomic) NSMutableSet *displayLinesSet;

//textField重用池和显示池
@property (strong, nonatomic) NSMutableSet *reuseTextFieldsSet;
@property (strong, nonatomic) NSMutableSet *displayTextFieldsSet;

//处于编辑状态的textField
@property (strong, nonatomic) UITextField *edittingTextField;

@end

@implementation CKFormRowCell

+ (NSString *)cellID {
    return @"CKFormRowCellID";
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self defaultSetting];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self defaultSetting];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self updateAllTextFields];
    [self updateAllVerticalLines];
    
    [self updateBottomLineLayer];
}

- (void)defaultSetting {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:nil];
}

//准备所有的textField
- (void)prepareTextFields {
    
    NSInteger columnCount = [self columnCount];
    //当前显示的textfield个数不够则从重用池取,多了移到重用池
    if (self.displayTextFieldsSet.count < columnCount) {
        NSInteger needMoveCount = columnCount-self.displayTextFieldsSet.count;
        for (int i=0; i<needMoveCount; i++) {
            UITextField *textField = [self getTextFieldFromReuseSet];
            [self.contentView addSubview:textField];
        }
    }
    else if (self.displayTextFieldsSet.count > columnCount) {
        NSInteger needMoveCount = self.displayTextFieldsSet.count-columnCount;
        for (int i=0; i<needMoveCount; i++) {
            UITextField *textField = [self.displayTextFieldsSet anyObject];
            [textField removeFromSuperview];
            [self.displayTextFieldsSet removeObject:textField];
            [self.reuseTextFieldsSet addObject:textField];
        }
    }
}

//准备所有的竖直线条
- (void)prepareLines {
    
    NSInteger columnCount = [self columnCount]-1;
    NSInteger needMoveCount = columnCount-self.displayLinesSet.count;
    if (self.displayLinesSet.count < columnCount) {
        for (int i=0; i<needMoveCount; i++) {
            CALayer *lineLayer = [self getLineFromReuseSet];
            [self.contentView.layer addSublayer:lineLayer];
        }
    }
    else if (self.displayLinesSet.count > columnCount) {
        NSInteger needMoveCount = self.displayLinesSet.count-columnCount;
        for (int i=0; i<needMoveCount; i++) {
            CALayer *lineLayer = [self.displayLinesSet anyObject];
            [lineLayer removeFromSuperlayer];
            [self.displayLinesSet removeObject:lineLayer];
            [self.reuseLinesSet addObject:lineLayer];
        }
    }
}

//更新底部线条
- (void)updateBottomLineLayer {
    
    if (self.bottomLineHidden) {
        self.bottomLineLayer.hidden = YES;
    }
    else {
        self.bottomLineLayer.hidden = NO;
        self.bottomLineLayer.backgroundColor = self.bottomLineColor.CGColor;
        self.bottomLineLayer.frame = CGRectMake(0, self.bounds.size.height-self.bottomLineWidth, self.bounds.size.width, self.bottomLineWidth);
    }
}

#pragma mark - 更新视图
//更新所有textfield和竖直分隔线的状态
- (void)updateAllTextFields {

    [self prepareTextFields];
    
    //更新textField
    int i=0;
    for (UITextField *textField in self.displayTextFieldsSet) {
        textField.tag = 100+i;
        [self updateStateFor:textField];
        
        //更新textField的frame
        textField.frame = [self textFieldFrameForColumn:i];
        i++;
    }
}

//更新所有的线段
- (void)updateAllVerticalLines {
    [self prepareLines];
    
    int j=0;
    for (CALayer *lineLayer in self.displayLinesSet) {
        
        lineLayer.backgroundColor = [self lineColorForColumn:j].CGColor;
        
        CGFloat lineWidth = [self lineWidthForColumn:j];
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        CGFloat X = [self VerticalLineCenterXForColumn:j]-0.5*lineWidth;
        lineLayer.frame = CGRectMake(X, 0, lineWidth, self.bounds.size.height);
        [CATransaction commit];
        j++;
    }
}

//获取对应位置的竖直线宽
- (CGFloat)lineWidthForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formRowCell:verticalLineWidthForColumn:)]) {
        return [self.delegate formRowCell:self verticalLineWidthForColumn:column];
    }
    return self.verticalLineWidth;
}

////获取对应位置的竖直线颜色
- (UIColor *)lineColorForColumn:(NSInteger)column {
    if ([self.delegate respondsToSelector:@selector(formRowCell:verticalLineColorForColumn:)]) {
        return [self.delegate formRowCell:self verticalLineColorForColumn:column];
    }
    return self.verticalLineColor;
}

//获取某根竖线的centerX
- (CGFloat)VerticalLineCenterXForColumn:(NSInteger)column {
    CGFloat centerX = 0.0;
    for (int i=0; i<=column; i++) {
        CGFloat width = [self cellWidthForColumn:i];
        centerX += width;
    }
    return centerX;
}

//更新某个textField的各种属性
- (void)updateStateFor:(UITextField *)textField {
    NSInteger column = textField.tag-100;
    
    //更新textField的对其方式
    if ([self.delegate respondsToSelector:@selector(formRowCell:textAlignmentForColumn:)]) {
        textField.textAlignment = [self.delegate formRowCell:self textAlignmentForColumn:column];
    }
    
    //更新textField的可编辑状态
    if ([self.delegate respondsToSelector:@selector(formRowCell:editableForColumn:)]) {
        textField.enabled = [self.delegate formRowCell:self editableForColumn:column];
    }
    else {
        textField.enabled = self.editable;
    }
    
    //更新键盘类型
    if ([self.delegate respondsToSelector:@selector(formRowCell:keyboardTypeForColumn:)]) {
        textField.keyboardType = [self.delegate formRowCell:self keyboardTypeForColumn:column];
    }
    
    //更新textField的文本
    if ([self.delegate respondsToSelector:@selector(formRowCell:textForColumn:)]) {
        textField.text = [self.delegate formRowCell:self textForColumn:column];
    }
    
    //更新textField字体
    if ([self.delegate respondsToSelector:@selector(formRowCell:fontForColumn:)]) {
        textField.font = [self.delegate formRowCell:self fontForColumn:column];
    }
    
    //更新textField字体颜色
    if ([self.delegate respondsToSelector:@selector(formRowCell:textColorForColumn:)]) {
        textField.textColor = [self.delegate formRowCell:self textColorForColumn:column];
    }
    
    //更新textField背景颜色
    if ([self.delegate respondsToSelector:@selector(formRowCell:backgroundColorForColumn:)]) {
        textField.backgroundColor = [self.delegate formRowCell:self backgroundColorForColumn:column];
    }
}

#pragma mark - 通知
- (void)textFieldTextDidChangeNotification:(NSNotification *)noti {
    UITextField *textField = noti.object;
    if (![self.displayTextFieldsSet containsObject:textField]) {
        return;
    }
    NSInteger column = textField.tag-100;
    if([self.delegate respondsToSelector:@selector(formRowCell:didChangeTextForColumn:)]) {
        [self.delegate formRowCell:self didChangeTextForColumn:column];
    }
}

#pragma mark - textField代理
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(formRowCell:shouldBeginEditingForColumn:)]) {
        return [self.delegate formRowCell:self shouldBeginEditingForColumn:textField.tag-100];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.edittingTextField = textField;
    
    if ([self.delegate respondsToSelector:@selector(formRowCell:didBeginEditingForColumn:)]) {
        NSInteger column = textField.tag-100;
        [self.delegate formRowCell:self didBeginEditingForColumn:column];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(formRowCell:willEndEditingForColumn:)]) {
        NSInteger column = textField.tag-100;
        [self.delegate formRowCell:self willEndEditingForColumn:column];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.edittingTextField = nil;
    if ([self.delegate respondsToSelector:@selector(formRowCell:didEndEditingForColumn:)]) {
        NSInteger column = textField.tag-100;
        [self.delegate formRowCell:self didEndEditingForColumn:column];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(formRowCell:shouldChangeCharactersWithReplacementString:ForColumn:)]) {
        NSInteger column = textField.tag-100;
        return [self.delegate formRowCell:self shouldChangeCharactersWithReplacementString:string ForColumn:column];
    }
    return YES;
}

#pragma mark - 其他方法
- (CAShapeLayer *)creratLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint lineColor:(UIColor *)lineColor lineWidth:(CGFloat)lineWidth {
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:fromPoint];
    [linePath addLineToPoint:toPoint];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.lineWidth = lineWidth;
    lineLayer.strokeColor = lineColor.CGColor;
    
    return lineLayer;
}

- (NSInteger)columnCount {
    NSInteger columnCount = 0;
    if ([self.delegate respondsToSelector:@selector(numberOfColumnsInFormRowCell:)]) {
        columnCount = [self.delegate numberOfColumnsInFormRowCell:self];
    }
    else {
        columnCount = self.numberOfColumns;
    }
    return columnCount;
}

//获取一条线
- (CALayer *)getLineFromReuseSet {
    CALayer *lineLayer = [self.reuseLinesSet anyObject];
    if (!lineLayer) {
        lineLayer = [CALayer layer];
    }
    else {
        [self.reuseLinesSet removeObject:lineLayer];
    }
    [self.displayLinesSet addObject:lineLayer];
    return lineLayer;
}

- (UITextField *)getTextFieldFromReuseSet {
    UITextField *textField = [self.reuseTextFieldsSet anyObject];
    if (!textField) {
        textField = [UITextField new];
        textField.delegate = self;
        textField.returnKeyType = UIReturnKeyDone;
    }
    else {
        [self.reuseTextFieldsSet removeObject:textField];
    }
    [self.displayTextFieldsSet addObject:textField];
    return textField;
}

//获取对应位置单元格的宽度(textField的宽度)
- (CGFloat)cellWidthForColumn:(NSInteger)column {
    
    if ([self.delegate respondsToSelector:@selector(formRowCell:widthForColumn:)]) {
        return [self.delegate formRowCell:self widthForColumn:column];
    }
    else {
        return self.columnWidth;
    }
}

//获取对应位置的textfield的frame
- (CGRect)textFieldFrameForColumn:(NSInteger)column {
    
    CGFloat leftLineTrailing;
    if (column==0) {
        leftLineTrailing = 0;
    }
    else {
        leftLineTrailing = [self VerticalLineCenterXForColumn:column-1] + 0.5*[self lineWidthForColumn:column-1];
    }
    
    CGFloat rightLineLeading = [self VerticalLineCenterXForColumn:column]-0.5*[self lineWidthForColumn:column];
    return CGRectMake(leftLineTrailing, 0, rightLineLeading-leftLineTrailing, self.bounds.size.height-self.bottomLineWidth);
}

#pragma mark - 外部方法
- (NSString *)textForColumn:(NSInteger)column {
    UITextField *textField = [self.contentView viewWithTag:100+column];
    return textField.text;
}

- (void)setText:(NSString *)text forColumn:(NSInteger)column {
    UITextField *textField = [self.contentView viewWithTag:100+column];
    textField.text = text;
}

- (UITextField *)textFieldForColumn:(NSInteger)column {
    return [self.contentView viewWithTag:100+column];
}

#pragma mark - getter & setter

- (CALayer *)bottomLineLayer {
    if (!_bottomLineLayer) {
        _bottomLineLayer = [CALayer layer];
        [self.contentView.layer addSublayer:_bottomLineLayer];
    }
    return _bottomLineLayer;
}

- (NSMutableSet *)reuseLinesSet {
    if (!_reuseLinesSet) {
        _reuseLinesSet = [NSMutableSet set];
    }
    return _reuseLinesSet;
}

- (NSMutableSet *)displayLinesSet {
    if (!_displayLinesSet) {
        _displayLinesSet = [NSMutableSet set];
    }
    return _displayLinesSet;
}

- (NSMutableSet *)reuseTextFieldsSet {
    if (!_reuseTextFieldsSet) {
        _reuseTextFieldsSet = [NSMutableSet set];
    }
    return _reuseTextFieldsSet;
}

- (NSMutableSet *)displayTextFieldsSet {
    if (!_displayTextFieldsSet) {
        _displayTextFieldsSet = [NSMutableSet set];
    }
    return _displayTextFieldsSet;
}

//- (void)setBottomLineHidden:(BOOL)bottomLineHidden {
//    _bottomLineHidden = bottomLineHidden;
//    self.bottomLineLayer.hidden = bottomLineHidden;
//}

//选中单元格的frame(画选中框时用到)
- (CGRect)selectedCellFrame {
    NSInteger column = self.edittingTextField.tag-100;
    CGFloat leftLineLeading;
    if (column==0) {
        leftLineLeading = 0;
    }
    else {
        leftLineLeading = floorf([self VerticalLineCenterXForColumn:column-1]-0.5*[self lineWidthForColumn:column-1]+0.5);
    }
    
    CGFloat rightLineTrailing = floorf([self VerticalLineCenterXForColumn:column]+0.5*[self lineWidthForColumn:column]+0.5);
    return CGRectMake(leftLineLeading, -self.bottomLineWidth, rightLineTrailing-leftLineLeading, self.bounds.size.height+self.bottomLineWidth);
}


@end
