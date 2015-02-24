//------------------------------------------------------------------------
//  Copyright 20015 (c) Codevog.com
//
//  This file is part of the QRCodeCodevogViewController.
//
//  The QRCodeCodevogViewController is free software; you can redistribute it
//  and/or modify it under the terms of the GNU Lesser Public License as
//  published by the Free Software Foundation; either version 2.1 of
//  the License, or (at your option) any later version.
//
//  The QRCodeCodevogViewController is distributed in the hope that it will be
//  useful, but WITHOUT ANY WARRANTY; without even the implied warranty
//  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Lesser Public License for more details.
//
//  You should have received a copy of the GNU Lesser Public License
//  along with the QRCodeCodevogViewController; if not, write to the Free
//  Software Foundation, Inc., 51 Franklin St, Fifth Floor,
//  Boston, MA  02110-1301  USA
//
//  http://codevog.com/
//------------------------------------------------------------------------

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ZBarReaderViewController.h"
#import "ZBarSymbol.h"

@interface QRCodeCodevogViewController : UIViewController <AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *viewPreview;
@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (nonatomic, retain) UIImage *doneImage;
@property (nonatomic, retain) UIImage *logoImage;
@property BOOL keyboardShow;
@property BOOL codeFounded;

@end
