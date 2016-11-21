//
//  ViewController.m
//  NumKeyBoard
//
//  Created by zm on 2016/11/21.
//  Copyright © 2016年 zmMac. All rights reserved.
//

#import "ViewController.h"
#import "ZZNumberField.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    ZZNumberField * f = [[ZZNumberField alloc] initWithFrame:CGRectMake(100, 100, 100, 30)];
    f.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:f];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
