//
//  ViewController.m
//  ScanQRcodeDemo
//
//  Created by 党玉华 on 2020/1/8.
//  Copyright © 2020 Linkdom. All rights reserved.
//

#import "ViewController.h"
#import "QRcodeVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor  = [UIColor whiteColor];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.navigationController pushViewController:QRcodeVC.new animated:YES];
}

@end
