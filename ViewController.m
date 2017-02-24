//
//  ViewController.m
//  CKFormView
//
//  Created by 陈凯 on 2017/2/24.
//  Copyright © 2017年 陈凯. All rights reserved.
//

#import "ViewController.h"
#import "CKFormView.h"

@interface ViewController ()

@property (strong, nonatomic) CKFormView *formView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formView = [[CKFormView alloc] initWithFrame:CGRectZero];
    self.formView.numberOfRows = 15;
    self.formView.numberOfColumns = 5;
    self.formView.verticalLineWidth = 0.5;
    self.formView.horizontalLineWidth = 0.5;
    self.formView.borderWidth = 0.5;
    [self.view addSubview:self.formView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.formView.frame = CGRectInset(self.view.bounds, 25, 25);
    self.formView.columnWidth = self.formView.frame.size.width/5;
    self.formView.rowHeight = self.formView.frame.size.height/15;
}


@end
