//
//  QRCodeCodevogViewController.h
//  QRScanner
//
//  Created by Dmytro Logvinenko on 2/11/15.
//  Copyright (c) 2015 Dmytro Logvinenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ZBarReaderViewController.h"
#import "ZBarSymbol.h"
//#import "Libs/zbarSDK/iphone/include/ZBarSDK/ZBarReaderController.h"
//#import "Libs/zbarSDK/iphone/include/ZBarSDK/ZBarSymbol.h"

@interface QRCodeCodevogViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *viewPreview;
//- (id)initWithHeight: (float) height andWidth: (float) width;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (nonatomic, retain) UIImage *doneImage;
@property (nonatomic, retain) UIImage *logoImage;
@property BOOL keyboardShow;
@property BOOL codeFounded;


@end
