//
//  ViewController.m
//  QRCodeCodevog
//
//  Created by Dmytro Logvinenko on 2/24/15.
//  Copyright (c) 2015 Codevog. All rights reserved.
//

#import "ViewController.h"
#import <CVQRCode/QRCodeCodevogViewController.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    QRCodeCodevogViewController *code = [[QRCodeCodevogViewController alloc] init];//WithHeight:self.view.frame.size.height andWidth:self.view.frame.size.height];
    //code.doneImage = [UIImage imageNamed:@"done"];
    //code.logoImage = [UIImage imageNamed:@"Image"];
    [self presentViewController:code animated:YES completion:nil];
    //[self.navigationController pushViewController:code animated:YES];
}




@end
