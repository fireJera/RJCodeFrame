//
//  ViewController.m
//  JERFrame
//
//  Created by super on 17/12/2017.
//  Copyright © 2017 Jeremy. All rights reserved.
//

#import "ViewController.h"
#import "UIView+JER_Frame.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    if (1) {
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        view.backgroundColor = [UIColor blackColor];
        view.left = 50;
        view.top = 50;
        [self.view addSubview:view];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
