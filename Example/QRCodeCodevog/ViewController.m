//
//  ViewController.m
//  QRCodeCodevog
//
//  Created by Dmytro Logvinenko on 2/24/15.
//  Copyright (c) 2015 Codevog. All rights reserved.
//

#import "ViewController.h"
#import <QRCodeCodevogViewController.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notification:) name:@"QRCodeReceived" object:nil];
}

- (void) notification: (NSNotification*) notification
{
    NSLog(@"%@", [notification object]);
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    QRCodeCodevogViewController *code = [[QRCodeCodevogViewController alloc] init];
    code.doneImage = [UIImage imageNamed:@"done"];
    [self presentViewController:code animated:YES completion:nil];
    //[self.navigationController pushViewController:code animated:YES];
}




@end
