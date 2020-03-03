//
//  ViewController.m
//  JERFrame
//
//  Created by super on 17/12/2017.
//  Copyright © 2017 Jeremy. All rights reserved.
//

#import "ViewController.h"
#import "UIView+JER_Frame.h"
#import <objc/runtime.h>
#import <GLKit/GLKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    OBJC_EXTERN void _objc_autoreleasePoolPrint();
    _objc_autoreleasePoolPrint();
//    OBJC_EXTERN uintptr_t _objc_rootRetainCount(id);
//    uintptr_t count = _objc_rootRetainCount(self.view);
//    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    view.backgroundColor = [UIColor redColor];
//    [self.view addSubview:view];
//    if (1) {
//        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//        view.backgroundColor = [UIColor blackColor];
//        view.left = 50;
//        view.top = 50;
//        [self.view addSubview:view];
//    }
    
    EAGLContext * context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView * view = (GLKView *)self.view;
    view.context = context;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    [EAGLContext setCurrentContext:context];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
