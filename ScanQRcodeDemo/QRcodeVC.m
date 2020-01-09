//
//  QRcodeVC.m
//  ScanQRcodeDemo
//
//  Created by 党玉华 on 2020/1/8.
//  Copyright © 2020 Linkdom. All rights reserved.
//

#import "QRcodeVC.h"
#import "Macros.h"
#import <Photos/Photos.h>
#import "UIImage+QRCode.h"
#import "UIImageView+ImageContent.h"

@interface QRcodeVC ()<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIImageView *scanImage;//扫描框图片
@property(nonatomic,strong)UIImageView *activeImage;//扫描条图片
@property(nonatomic,strong)UIImagePickerController *photoLibraryVC;
@property(nonatomic,strong)AVCaptureSession *session;
@property(nonatomic,strong)AVCaptureDevice *device;
@property(nonatomic,strong)AVCaptureDeviceInput *input;
@property(nonatomic,strong)AVCaptureMetadataOutput *output;
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *layer;
@property(nonatomic,assign)CGFloat currentZoomFactor;

//临时占位图
@property(nonatomic,strong)UIImageView *codeImageView;
@property(nonatomic,strong)UIImageView *logoCodeImageView;

@end

@implementation QRcodeVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sessionStartRunning];//开始捕获
    [self startImgBaseAnimation];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.session stopRunning];//停止捕获
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NotificationCenter addObserver:self selector:@selector(sessionStartRunning) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self setupUI];
    [self temporaryUI];
}
-(void)setupUI{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"相册" style:UIBarButtonItemStylePlain target:self action:@selector(openCamera)];
    
    CGFloat imageW = ScreenW;
    CGFloat imageX = (ScreenW-imageW)/2;
    CGFloat imageY = ScreenW*0.15+64;
    
    self.scanImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao"]];
    self.scanImage.frame = CGRectMake(imageX, imageY, imageW, imageW);
    [self.view addSubview:self.scanImage];
    self.activeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao-3"]];
    self.activeImage.frame = CGRectMake(imageX, imageY, imageW, 4);
    [self.view addSubview:self.activeImage];
    
    //添加全屏的黑色半透明蒙版
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:maskView];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(imageX, imageY, imageW, imageW)] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    maskView.layer.mask = maskLayer;
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    self.output = [[AVCaptureMetadataOutput alloc]init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    self.session = [[AVCaptureSession alloc]init];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    self.output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    self.layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    self.layer.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.layer atIndex:0];
    [self.session startRunning];
    CGRect intertRect = [self.layer metadataOutputRectOfInterestForRect:CGRectMake(ScreenW*0.15, ScreenW*0.15+64, imageW, imageW)];
    self.output.rectOfInterest = intertRect;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(zoomChangePinchGestureRecognizerClick:)];
    pinchGesture.delegate = self;
    [self.view addGestureRecognizer:pinchGesture];
    self.currentZoomFactor = 1;
    
    [self startImgBaseAnimation];
}
//⚠️临时
-(void)temporaryUI{
    self.codeImageView = [[UIImageView alloc]initWithFrame:Frame(50, ScreenH-200, 100, 100)];
    [self.view addSubview:self.codeImageView];
    self.logoCodeImageView = [[UIImageView alloc]initWithFrame:Frame(180, ScreenH-200, 100, 100)];
    [self.view addSubview:self.logoCodeImageView];
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress)];
    self.codeImageView.userInteractionEnabled = YES;
    [self.codeImageView addGestureRecognizer:press];
}
//⚠️临时
-(void)longPress{
    NSString *content = [UIImageView getImageContent:self.codeImageView.image];
    [self handleQRcodeAction:content];
}
//最小缩放值
- (CGFloat)minZoomFactor{
    CGFloat minZoomFactor = 1.0;
    if (@available(iOS 11.0, *)) {
        minZoomFactor = self.device.minAvailableVideoZoomFactor;
    }
    return minZoomFactor;
}
//最大缩放值
- (CGFloat)maxZoomFactor{
    CGFloat maxZoomFactor = self.device.activeFormat.videoMaxZoomFactor;
    if (@available(iOS 11.0, *)) {
        maxZoomFactor = self.device.maxAvailableVideoZoomFactor;
    }
    if (maxZoomFactor > 6.0) {
        maxZoomFactor = 6.0;
    }
    return maxZoomFactor;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]]){
        self.currentZoomFactor = self.device.videoZoomFactor;
    }
    return YES;
}
//缩放手势
- (void)zoomChangePinchGestureRecognizerClick:(UIPinchGestureRecognizer *)pinchGestureRecognizer{
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||pinchGestureRecognizer.state == UIGestureRecognizerStateChanged){
        CGFloat currentZoomFactor = self.currentZoomFactor * pinchGestureRecognizer.scale;
        
        [self changeFactor:currentZoomFactor];
    }
    else{
    }
}
-(void) changeFactor:(CGFloat)currentZoomFactor{
    if (currentZoomFactor < self.maxZoomFactor &&
        currentZoomFactor > self.minZoomFactor){
        NSError *error = nil;
        if ([self.device lockForConfiguration:&error] ) {
            [self.device rampToVideoZoomFactor:currentZoomFactor withRate:3];//rate越大，动画越慢
            [self.device unlockForConfiguration];
        }else {
            DLog( @"Could not lock device for configuration: %@", error );
        }
    }
}
- (void)sessionStartRunning{
    if (self.session != nil) {
        [self.session startRunning];
        [self startImgBaseAnimation];
    }
}
//打开相册
-(void)openCamera{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.allowsEditing = YES;
        picker.delegate = self;
        picker.navigationBar.translucent = NO;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请在您的iPhone设置中允许此应用访问相机以扫描二维码" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:actionCancel];
        UIAlertAction *actionSet = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertVC addAction:actionSet];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
-(void)startImgBaseAnimation{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath : @"position.y" ];
    animation.toValue = @(self.scanImage.frame.origin.y+self.scanImage.frame.size.height);
    animation.fromValue = @(self.scanImage.frame.origin.y);
    animation.duration = 2;
    animation.removedOnCompletion = YES ;
    animation.repeatCount = MAXFLOAT ;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.activeImage.layer addAnimation:animation forKey:@"AnimationMoveY"];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [self.session stopRunning];
    [self.activeImage.layer removeAllAnimations];
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        NSString *content = metadataObject.stringValue;
        if ([[metadataObject type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self handleQRcodeAction:content];
        }
    }
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.session stopRunning];
    [self.activeImage.layer removeAllAnimations];
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        UIImage *pickImage = [info objectForKey:UIImagePickerControllerEditedImage];
        NSString *content = [UIImageView getImageContent:pickImage];
        [self handleQRcodeAction:content];
    }
}
//识别后的处理
-(void)handleQRcodeAction:(NSString *)content{
    DLog(@"%@",content);
    if (content.length!=0) {
        self.codeImageView.image = [UIImage createQRCodeImageFromString:content withSize:self.codeImageView.bounds.size.width];
        self.logoCodeImageView.image = [UIImage createQRCodeImageFromString:content withSize:self.codeImageView.bounds.size.width withLogo:[UIImage imageNamed:@"centerIcon"] withIconSize:CGSizeMake(40, 40)];
    }else{
        [self sessionStartRunning];//开始捕获
        [self startImgBaseAnimation];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"很抱歉，未能识别到二维码，请重试" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:actionCancel];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
- (void)dealloc{
    DLog(@"%@释放",[self class]);
}
@end
