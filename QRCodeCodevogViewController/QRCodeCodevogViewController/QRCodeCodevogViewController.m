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

#import "QRCodeCodevogViewController.h"

@interface QRCodeCodevogViewController ()
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) BOOL isReading;
-(BOOL)startReading;
-(void)stopReading;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation QRCodeCodevogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadBeepSound];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    _keyboardShow = NO;
    _captureSession = nil;
    _isReading = NO;
    _codeFounded = NO;
    _textField.delegate = self;
    [self addForms];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(addLineAnimation)
                                                name:UIApplicationWillEnterForegroundNotification //DidBecomeActiveNotification
                                              object:nil];
}

-(void)loadBeepSound{
    NSString *beepFilePath = [[NSBundle mainBundle] pathForResource:@"shutter" ofType:@"mp3"];
    NSURL *beepURL = [NSURL URLWithString:beepFilePath];
    
    NSError *error;
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:beepURL error:&error];
    if (error) {
        NSLog(@"Could not play beep file.");
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        [_audioPlayer prepareToPlay];
    }
}

- (void) addForms
{
    //scroll settings
    _scrollView = [[UIScrollView alloc] init];//WithFrame:self.view.frame];
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_scrollView];
    
    //add constraints to _scrollView
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_scrollView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    NSString *visualFormat = [[NSString alloc] initWithFormat:@"V:|[view]|"];
    [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:visualFormat
                                                                       options:0
                                                                       metrics:nil
                                                                         views:@{@"view":_scrollView}]];
    //add textField
    _textField = [[UITextField alloc] init];
    [_textField setFrame:CGRectMake(0, 0, 0, 35)];
    _textField.font = [UIFont systemFontOfSize:16];
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.delegate = self;
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    
    //add right button
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [sendBtn setFrame:CGRectMake(0,0,70,50)];
    [sendBtn setTitle:@"send" forState:UIControlStateNormal];
    [sendBtn setTintColor:[UIColor blackColor]];
    [sendBtn addTarget:self action:@selector(sendCode) forControlEvents:UIControlEventTouchUpInside];
    [_textField setRightView:sendBtn];
    [_textField setRightViewMode:UITextFieldViewModeAlways];
    [_scrollView addSubview:_textField];
    
    //add constraints to textField
    _textField.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_textField attribute:NSLayoutAttributeWidth multiplier:1.1 constant:0.0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_textField attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    int i = (int) self.view.frame.size.height - 30;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) i+= 250;
    NSString *visualFormat2 = [[NSString alloc] initWithFormat:@"V:[view(35)]-(%i)-|", -i];
    [_scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:visualFormat2
                                                                         options:0
                                                                         metrics:nil
                                                                           views:@{@"view":_textField}]];
    
    //add Rezult label
    _textLabel = [[UILabel alloc] init];
    [_textLabel setFrame:CGRectMake(0, 0, 50, 50)];
    _textLabel.text = @"QR Code Rezult:";
    _textLabel.clipsToBounds = YES;
    _textLabel.textColor = [UIColor blackColor];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    [_scrollView addSubview:_textLabel];
    
    //add constraints to Rezult label
    _textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_textLabel attribute:NSLayoutAttributeWidth multiplier:1.1 constant:0.0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_textLabel attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    int il = (int) self.view.frame.size.height - 30-35-15;
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) il +=250;
    NSString *visualFormatLabel = [[NSString alloc] initWithFormat:@"V:[view(50)]-(%i)-|", -il];
    [_scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:visualFormatLabel
                                                                         options:0
                                                                         metrics:nil
                                                                           views:@{@"view":_textLabel}]];
    
    //add view with buttons
    UIView *view = [[UIView alloc] init];
    view.tag = 12345;
    [_scrollView addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        int iView = (int) self.view.frame.size.height - 30-35-15-60;
        int hightView = (int) self.view.frame.size.width*0.95;
        NSString *visualFormatView = [[NSString alloc] initWithFormat:@"V:[view(%i)]-(%i)-|",hightView ,-iView];
        [_scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:visualFormatView
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"view":view}]];
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+5)];
    }
    else if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        int iView = (int) self.view.frame.size.width - 30-35-15-60;
        int hightView = (int) self.view.frame.size.height*0.95;
        NSString *visualFormatView = [[NSString alloc] initWithFormat:@"V:[view(%i)]-(%i)-|",hightView ,-iView];
        [_scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:visualFormatView
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"view":view}]];
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+250)];
    }
    
    _lightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_lightButton setFrame:CGRectMake(25,0,70,50)];
    [_lightButton setTitle:@"ON" forState:UIControlStateNormal];
    [_lightButton setTintColor:[UIColor blackColor]];
    [_lightButton addTarget:self action:@selector(changeLigthState) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:_lightButton];
    
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [imageBtn setFrame:CGRectMake(100,0,50,50)];
    [imageBtn setTitle:@"Image" forState:UIControlStateNormal];
    [imageBtn setTintColor:[UIColor blackColor]];
    [imageBtn addTarget:self action:@selector(getPhoto) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:imageBtn];
    
    //add constraint to imageBtn
    imageBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(70)]-25-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:@{@"view":imageBtn}]];
    [view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view(50)]"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:@{@"view":imageBtn}]];
    
    //add viewPreview
    _viewPreview = [[UIImageView alloc] init];
    [_viewPreview setImage:[UIImage imageNamed:@"Image"]];
    [_viewPreview setFrame:CGRectMake(0, 70, 320, 213)];
    [view addSubview:_viewPreview];
    _viewPreview.translatesAutoresizingMaskIntoConstraints = NO;
    
    //add constr
    [view addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_viewPreview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    int widht = (int) self.view.frame.size.width;
    if (self.view.frame.size.width >  self.view.frame.size.height){widht = (int) self.view.frame.size.height;}
    
    [view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[view(%i)]", widht]
                                                                  options:0
                                                                  metrics:nil
                                                                    views:@{@"view":_viewPreview}]];
    
    int height = (int) widht*0.75;
    if ([[UIDevice currentDevice].model hasPrefix:@"iPad"]){height = (int) widht*0.85;  }
    [view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:[view(%i)]-|", height]
                                                                  options:0
                                                                  metrics:nil
                                                                    views:@{@"view":_viewPreview}]];
    
    //add Label with logo
    UIImageView *viewLogo = [[UIImageView alloc] init];
    if (_logoImage){viewLogo.image = _logoImage;viewLogo.contentMode = UIViewContentModeScaleAspectFit;}
    [_scrollView addSubview:viewLogo];
    viewLogo.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:viewLogo attribute:NSLayoutAttributeWidth multiplier:1.1 constant:0.0]];
    [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_scrollView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewLogo attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    
    [_scrollView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-20-[view(100)]"]
                                                                         options:0
                                                                         metrics:nil
                                                                           views:@{@"view":viewLogo}]];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    if (!_isReading)
    {
        if ([self startReading])
        {
            
        }
    }
    else{[self stopReading];}
    _isReading = !_isReading;
    [self setVideoOrientation];
    [self visibleScaner];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+250)];
    }
    else
    {
        [_scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    }
    [self setVideoOrientation];
    [self visibleScaner];
}

- (void) setVideoOrientation
{
    if (self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        [_videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait)
        [_videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        [_videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        [_videoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
}

- (void) visibleScaner
{
    CGRect rc = [[self.view viewWithTag:12345] bounds];
    rc = [[self.view viewWithTag:12345] convertRect:rc toView:_scrollView];
    rc.origin.x = 0 ;
    rc.origin.y += 10 ;
    [_scrollView scrollRectToVisible:rc animated:YES];
}

- (void)keyboardShow:(NSNotification*)notification
{
    _keyboardShow = YES;
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    [self shiftTextFieldHeight:keyboardFrameBeginRect.size.height up:YES];
}

- (void)keyboardHide:(NSNotification*)notification
{
    if (_keyboardShow) {
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        [self shiftTextFieldHeight:keyboardFrameBeginRect.size.height up:NO];
        _keyboardShow = NO;
    }
}

- (void) shiftTextFieldHeight: (float) height up: (BOOL) up
{
    const int movementDistance = height;
    const float movementDuration = 0.3f;
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}

#pragma mark - IBAction LIGHT
- (void)changeLigthState
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch]) {
        [captureDevice lockForConfiguration:nil];
        if (captureDevice.torchMode == AVCaptureTorchModeOn)
        {
            [captureDevice setTorchMode:AVCaptureTorchModeOff];  // use AVCaptureTorchModeOff to turn off
            [_lightButton setTitle:@"ON" forState:UIControlStateNormal];
        }
        else
        {
            [captureDevice setTorchMode:AVCaptureTorchModeOn];
            [_lightButton setTitle:@"OFF" forState:UIControlStateNormal];
        }
        [captureDevice unlockForConfiguration];
    }
}

- (void)offLight
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([captureDevice hasTorch]) {
        [captureDevice lockForConfiguration:nil];
        if (captureDevice.torchMode == AVCaptureTorchModeOn)
        {
            [captureDevice setTorchMode:AVCaptureTorchModeOff];  // use AVCaptureTorchModeOff to turn off
            [_lightButton setTitle:@"ON" forState:UIControlStateNormal];
        }
        [captureDevice unlockForConfiguration];
    }
}

#pragma mark - add LINE && Rectangle
- (void) addRect
{
    int indent = 90;
    if ([[UIDevice currentDevice].model hasPrefix:@"iPad"])
    {
        indent = 169; //338/2
    }
    CGRect rectFrame =  CGRectMake(_viewPreview.frame.size.width/2 - indent, _viewPreview.frame.size.height/2-indent+34, 2*indent, 2*indent);
    
    UIImage *rect = [UIImage imageNamed:@"rect"];
    UIImageView *rectView = [[UIImageView alloc] initWithImage:rect];
    [rectView setFrame:rectFrame];
    rectView.tag = 222;
    
    [[self.view viewWithTag:12345] addSubview:rectView];
    
    rectView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[self.view viewWithTag:12345] addConstraint:[NSLayoutConstraint constraintWithItem:_viewPreview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:rectView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [[self.view viewWithTag:12345] addConstraint:[NSLayoutConstraint constraintWithItem:_viewPreview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:rectView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    [self addLineAnimation];
}

- (void) addLineAnimation
{
    int indent = 90;
    if ([[UIDevice currentDevice].model hasPrefix:@"iPad"])
    {
        indent = 169; //338/2
    }
    
    UIImage *line = [UIImage imageNamed:@"line"];
    UIImageView *scanLine = [[UIImageView alloc] initWithImage:line];
    [scanLine setFrame:CGRectMake(0, 0, 2*indent, line.size.height)];
    scanLine.tag = 111;
    [[self.view viewWithTag:222] addSubview:scanLine];
    
    CGPoint endPoint = (CGPoint){27, 0};
    CGPoint startPoint = (CGPoint){[self.view viewWithTag:222].frame.size.height+27, 0};
    
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathMoveToPoint(thePath, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(thePath, NULL, endPoint.x, endPoint.y);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    animation.duration = 3.f;
    animation.path = thePath;
    animation.autoreverses = YES;
    animation.repeatCount = INFINITY;
    [scanLine.layer addAnimation:animation forKey:@"position.y"];
}

#pragma mark - IBAction START && STOP scanning
- (BOOL)startReading
{
    [self addRect];
    
    NSError *error;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        return NO;
    }
    _captureSession = [[AVCaptureSession alloc] init];
    [_captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [_captureSession addOutput:captureMetadataOutput];
    
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:_viewPreview.layer.bounds];
    [_viewPreview.layer addSublayer:_videoPreviewLayer];
    
    [_captureSession startRunning];
    
    return YES;
}

-(void)stopReading{
    [[self.view viewWithTag:111] removeFromSuperview];//delete line
    [[self.view viewWithTag:222] removeFromSuperview];//delete rectangle
    [_captureSession stopRunning];
    _captureSession = nil;
    _isReading = NO;
    [_videoPreviewLayer removeFromSuperlayer];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate method implementation
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (_codeFounded) return;
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            if (_audioPlayer) {
                [_audioPlayer play];
            }
            [self performSelectorOnMainThread:@selector(codeFound) withObject:nil waitUntilDone:NO];
            [_textField performSelectorOnMainThread:@selector(setText:) withObject:[metadataObj stringValue] waitUntilDone:NO];
        }
    }
}

- (void) codeFound
{
    _codeFounded = YES;
    [[self.view viewWithTag:111] removeFromSuperview];
    
    UIImageView *view = (UIImageView*)[self.view viewWithTag:222];
    
    
    CAKeyframeAnimation *colorsAnimation = [CAKeyframeAnimation animationWithKeyPath:@"backgroundColor"];
    colorsAnimation.values = [NSArray arrayWithObjects: (id)[UIColor redColor].CGColor,
                              (id)[UIColor clearColor].CGColor, nil];
    colorsAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:3.0], [NSNumber numberWithFloat:0.5], nil];
    colorsAnimation.calculationMode = kCAAnimationPaced;
    colorsAnimation.removedOnCompletion = NO;
    colorsAnimation.fillMode = kCAFillModeForwards;
    colorsAnimation.duration = 3.0f;
    
    [view.layer addAnimation:colorsAnimation forKey:nil];
    
    //add done image
    if (_doneImage)
    {
        UIImageView *doneView = [[UIImageView alloc] initWithImage:_doneImage];
        [doneView setFrame:CGRectMake(0, 0, 128, 128)];
        doneView.tag = 333;
        [[self.view viewWithTag:222] addSubview:doneView];
        
        doneView.translatesAutoresizingMaskIntoConstraints = NO;
        [[self.view viewWithTag:12345] addConstraint:[NSLayoutConstraint constraintWithItem:[self.view viewWithTag:222] attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:doneView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [[self.view viewWithTag:12345] addConstraint:[NSLayoutConstraint constraintWithItem:[self.view viewWithTag:222] attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:doneView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:4.0
                                     target:self
                                   selector:@selector(showAnimation)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void)showAnimation
{
    [[self.view viewWithTag:333] removeFromSuperview];
    [self addLineAnimation];
    [NSTimer scheduledTimerWithTimeInterval:3.0
                                     target:self
                                   selector:@selector(startScanAgain)
                                   userInfo:nil
                                    repeats:NO];
}

- (void) startScanAgain
{
    _codeFounded = NO;
}

- (void) sendCode
{
    [_textField endEditing:YES];
    if (_isReading) {
        [self stopReading]; _isReading = !_isReading;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName: @"QRCodeReceived" object: _textField.text];
}

#pragma mark - Scan QRCode from gallery with ZBarReader
- (void)getPhoto
{
    if (_isReading) {_isReading = !_isReading;
        [self stopReading];
    }
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self scanForQR:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
}

- (NSString *)scanForQR:(UIImage *)image
{
    
    ZBarReaderController *imageReader = [ZBarReaderController new];
    [imageReader.scanner setSymbology: ZBAR_I25
                               config: ZBAR_CFG_ENABLE
                                   to: 0];
    id <NSFastEnumeration> results = [imageReader scanImage:image.CGImage];
    ZBarSymbol *sym = nil;
    for(sym in results) {
        break;
    }
    if (!sym) {
        return nil;
    }
    _textField.text = sym.data;
    return sym.data;
}

@end
