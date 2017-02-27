//
//  ViewController.m
//  CKFormView
//
//  Created by 陈凯 on 2017/2/24.
//  Copyright © 2017年 陈凯. All rights reserved.
//

#import "ViewController.h"
#import "CKFormView.h"

@interface ViewController () <CKFormViewDelegate>

@property (strong, nonatomic) CKFormView *formView;
@property (strong, nonatomic) NSArray *orders;
@property (strong, nonatomic) NSArray *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titles = @[@"款号", @"类别", @"单价", @"颜色", @"数量", @"金额"];
    self.orders = @[
                    @{@"款号":@"JF111111", @"类别":@"短外套", @"单价":@"1000", @"颜色":@"黑色", @"数量":@"2", @"金额":@"2000"},
                    @{@"款号":@"JF111112", @"类别":@"衬衫", @"单价":@"2000", @"颜色":@"红色", @"数量":@"3", @"金额":@"6000"},
                    @{@"款号":@"JF111113", @"类别":@"衬衫", @"单价":@"3000", @"颜色":@"绿色", @"数量":@"1", @"金额":@"3000"},
                    @{@"款号":@"JF111114", @"类别":@"连衣裙", @"单价":@"4000", @"颜色":@"蓝色", @"数量":@"4", @"金额":@"16000"},
                    @{@"款号":@"JF111115", @"类别":@"风衣", @"单价":@"5000", @"颜色":@"白色", @"数量":@"5", @"金额":@"25000"},
                    @{@"款号":@"JF111116", @"类别":@"连衣裙", @"单价":@"1000", @"颜色":@"印花", @"数量":@"2", @"金额":@"2000"},
                    @{@"款号":@"JF111117", @"类别":@"西服", @"单价":@"2000", @"颜色":@"橘色", @"数量":@"3", @"金额":@"6000"},
                    @{@"款号":@"JF111118", @"类别":@"吊带", @"单价":@"300", @"颜色":@"米色", @"数量":@"1", @"金额":@"300"},
                    @{@"款号":@"JF111119", @"类别":@"T恤", @"单价":@"400", @"颜色":@"黑色", @"数量":@"4", @"金额":@"1600"},
                    @{@"款号":@"JF111120", @"类别":@"针织衫", @"单价":@"3000", @"颜色":@"白色", @"数量":@"2", @"金额":@"6000"},
                    ];
    
    self.formView = [[CKFormView alloc] initWithFrame:CGRectZero];
    self.formView.verticalLineWidth = 0.5;
    self.formView.horizontalLineWidth = 0.5;
    self.formView.borderWidth = 0.5;
    self.formView.delegate = self;
    [self.view addSubview:self.formView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.formView.frame = CGRectMake(25, 64, self.view.bounds.size.width-50, self.formView.rowHeight*(self.orders.count+1)+2*self.formView.borderWidth);
    
}

- (NSInteger)numberOfRowsInFormView:(CKFormView *)formView {
    return self.orders.count+1;
}

- (NSInteger)formView:(CKFormView *)formView numberOfColumnsForRow:(NSInteger)row {
    return 6;
}

- (NSString *)formView:(CKFormView *)formView textForPosition:(CKFormCellPosition)position {
    if (position.row==0) {
        return self.titles[position.column];
    }
    NSString *title = self.titles[position.column];
    return self.orders[position.row-1][title];
}

- (CGFloat)formView:(CKFormView *)formView widthForPosition:(CKFormCellPosition)position {
    switch (position.column) {
        case 0:
        return 0.2*formView.bounds.size.width;
        break;
        case 1:
        return 0.15*formView.bounds.size.width;
        break;
        case 2:
        return 0.15*formView.bounds.size.width;
        break;
        case 3:
        return 0.15*formView.bounds.size.width;
        break;
        case 4:
        return 0.15*formView.bounds.size.width;
        break;
        default:
        return 0.2*formView.bounds.size.width;
        break;
    }
}

- (UIColor *)formView:(CKFormView *)formView backgroundColorForPosition:(CKFormCellPosition)position {
    if (position.row==0) {
        return [UIColor colorWithWhite:0.95 alpha:1];
    }
    return [UIColor whiteColor];
}

- (BOOL)formView:(CKFormView *)formView editableForPosition:(CKFormCellPosition)position {
    if (position.row == 0) {
        return NO;
    }
    else if (position.column == 4) {
        return YES;
    }
    return NO;
}

- (BOOL)formView:(CKFormView *)formView shouldChangeCharactersWithReplacementString:(NSString *)string forPosition:(CKFormCellPosition)position {
    if ([string isEqualToString:@"\n"]) {
        [formView endEditing:YES];
        return NO;
    }
    return YES;
}

- (void)formView:(CKFormView *)formView didEndEditingForPosition:(CKFormCellPosition)position {
    NSString *text = [formView textForPosition:position];
    NSLog(@"单元格的内容为: %@", text);
}


@end
