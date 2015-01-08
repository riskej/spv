//
//  ViewController.m
//  SpecViewT1
//
//  Created by riskej & trefi, 2015.
//  Copyright (c) 2015 SimbolBit. All rights reserved.
//

#import "ViewController.h"
#import "RKJConverterToRGB.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

{
    BOOL check;
    CADisplayLink *theTimer;
    UIPinchGestureRecognizer *pinchRecognizer;
    UIImageView *flickerImages;
    UIImageView *ScreenToShow;
    UIImageView *ScreenToShow2;
    UIImageView *BorderToShow;
    UIImageView *BorderToShow2;
    UIColor *borderColorScreen01;
    UIColor *borderColorScreen02;
    int border01, border02;
    UIView *canvas;
    CGFloat _lastScale;
    CGFloat _lastRotation;
    CGFloat _firstX;
    CGFloat _firstY;
}

@synthesize currentData;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkingForFileSize)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self setupTouchInterface];
    
    //    currentData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://dl.dropboxusercontent.com/u/36464659/_apptest/stl13824.img"]];
    
}


- (void) convert6144Screen:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    [convertedImage openZX_scr6144:currentData];
    
    ScreenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow.image = convertedImage.FinallyProcessedImage;
    
    ScreenToShow.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    [self.view addSubview:ScreenToShow];
}


- (void) convert6912Screen:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    [convertedImage openZX_scr6912:currentData];
    
    ScreenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow.image = convertedImage.FinallyProcessedImage;
    
    ScreenToShow.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    [self.view addSubview:ScreenToShow];
}


- (void) convertImgMgx:(int) mode_scr {
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    [convertedImage openZX_img_mgX:currentData];
    
    border01 = convertedImage.BorderColor1;
    border02 = convertedImage.BorderColor2;
    
    [self getBorderColors];
    
    BorderToShow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    BorderToShow.backgroundColor = borderColorScreen01;
    BorderToShow.alpha = 1;
    BorderToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    BorderToShow2.backgroundColor = borderColorScreen02;
    BorderToShow2.alpha = 0.5;
    
    [self.view addSubview:BorderToShow];
    [self.view addSubview:BorderToShow2];
    
//    ScreenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
//    ScreenToShow.image = convertedImage.FinallyProcessedImage;
//    ScreenToShow.alpha = 1.0;
//    ScreenToShow.transform = CGAffineTransformMakeScale(1, 1);
//    
//    
//    ScreenToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
//    ScreenToShow2.image = convertedImage.FinallyProcessedImage2;
//    ScreenToShow2.alpha = 0.5;
//    ScreenToShow2.transform = CGAffineTransformMakeScale(1, 1);
//    
//    [self.view addSubview:ScreenToShow];
//    [self.view addSubview:ScreenToShow2];
    
        [self initializeTimer];
    
}


- (void) convertImgMg1 {
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    [convertedImage openZX_img_mg1:currentData];
    
    border01 = convertedImage.BorderColor1;
    border02 = convertedImage.BorderColor2;
    
    [self getBorderColors];
    
    BorderToShow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    BorderToShow.backgroundColor = borderColorScreen01;
    BorderToShow.alpha = 1;
    BorderToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    BorderToShow2.backgroundColor = borderColorScreen02;
    BorderToShow2.alpha = 0.5;
    
    [self.view addSubview:BorderToShow];
    [self.view addSubview:BorderToShow2];
    
    ScreenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow.image = convertedImage.FinallyProcessedImage;
    ScreenToShow.alpha = 1.0;
    ScreenToShow.transform = CGAffineTransformMakeScale(1, 1);
    
    
    ScreenToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow2.image = convertedImage.FinallyProcessedImage2;
    ScreenToShow2.alpha = 0.5;
    ScreenToShow2.transform = CGAffineTransformMakeScale(1, 1);
    
    [self.view addSubview:ScreenToShow];
    [self.view addSubview:ScreenToShow2];
    
//        [self initializeTimer];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}


-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    CGAffineTransform currentTransform = ScreenToShow.transform;
    CGAffineTransform currentTransform2 = ScreenToShow2.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    CGAffineTransform newTransform2 = CGAffineTransformScale(currentTransform2, scale, scale);
    
    [ScreenToShow setTransform:newTransform];
    [ScreenToShow2 setTransform:newTransform2];
    //    ScreenToShow.center = pinchRecognizer.view.center;
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
}


-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:canvas];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = [ScreenToShow center].x;
        _firstY = [ScreenToShow center].y;
    }
    
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    
    [ScreenToShow setCenter:translatedPoint];
    [ScreenToShow2 setCenter:translatedPoint];
}


-(void)checkingForFileSize {
    
    // cls
    
    for (UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
    
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    currentData = [NSData dataWithContentsOfURL:appDelegate.IncomingURL];
    
    //    NSData *data = currentData;
    
    //    NSUInteger len = [data length];
    //    Byte *byteData = (Byte*)malloc(len);
    //    memcpy(byteData, [data bytes], len);
    
    NSUInteger incomingFileSize = [currentData length];
    
    //    NSLog(@"Incfileszie: %i", (int)incomingFileSize);
    
    if (incomingFileSize == 0) {
        
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.79 alpha:1];
        
        UILabel *noDataMessage;
        noDataMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        noDataMessage.textColor = [UIColor whiteColor];
        noDataMessage.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        noDataMessage.textAlignment = NSTextAlignmentCenter;
        noDataMessage.numberOfLines = 0;
        noDataMessage.text = [NSString stringWithFormat:@"Please use 'Open in...' menu in order to open an ZX Spectrum image."];
        [self.view addSubview:noDataMessage];
        
        UILabel *noDataMessage2;
        noDataMessage2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+80)];
        noDataMessage2.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
        noDataMessage2.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
        noDataMessage2.textAlignment = NSTextAlignmentCenter;
        noDataMessage2.numberOfLines = 0;
        noDataMessage2.text = [NSString stringWithFormat:@"You can view standard modes \nas well as multicolor, gigascreen & multigigascreen."];
        [self.view addSubview:noDataMessage2];
        
        // modes =  1 - 6144
        //          2 - 6912
        //          3 - img(gsc)
        //          4 - mg8
        //          5 - mg4
        //          6 - mg2
        //          7 – mg1
        //          8 - mc
    }
    
    else if (incomingFileSize == 6144) {
        self.view.backgroundColor = [UIColor blackColor];
        [self convert6144Screen:1];
    }
    
    else if (incomingFileSize == 6912) {
        self.view.backgroundColor = [UIColor blackColor];
        [self convert6912Screen:2];
    }
    else if (incomingFileSize == 12288) {
        self.view.backgroundColor = [UIColor blackColor];
        [self convert6912Screen:8];
    }
    else if (incomingFileSize == 13824) {
        self.view.backgroundColor = [UIColor blackColor];
        [self convertImgMgx:3];
    }
    
    else if (incomingFileSize == 14080) {
        self.view.backgroundColor = [UIColor blackColor];
        [self convertImgMgx:4];
    }
    
    else if (incomingFileSize == 15616) {
        [self convertImgMgx:5];
    }
    
    else if (incomingFileSize == 18688) {
        [self convertImgMgx:6];
    }
    
    else if (incomingFileSize == 19456) {
        [self convertImgMg1];
    }
    
    else {
        
        self.view.backgroundColor = [UIColor colorWithRed:0.79 green:0 blue:0.79 alpha:1];
        
        UILabel *noDataMessage;
        noDataMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        noDataMessage.textColor = [UIColor whiteColor];
        noDataMessage.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        noDataMessage.textAlignment = NSTextAlignmentCenter;
        noDataMessage.numberOfLines = 0;
        noDataMessage.text = [NSString stringWithFormat:@"Seems like the image you're loading \nis not a valid ZX Spectrum image"];
        [self.view addSubview:noDataMessage];
    }
    
    //    [[NSNotificationCenter defaultCenter] removeObserver:self
    //                                                    name:UIApplicationDidBecomeActiveNotification
    //                                                  object:nil];
    
}


-(void)setupTouchInterface {
    
    pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [self.view addGestureRecognizer:pinchRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.view addGestureRecognizer:panRecognizer];
    
}


-(void)getBorderColors {
    
    float colRed = border01 & 2 ? 0.79 : 0;
    float colGreen = border01 & 4 ? 0.79 : 0;
    float colBlue = border01 & 1 ? 0.79 : 0;
    borderColorScreen01 = [UIColor colorWithRed:colRed green:colGreen blue:colBlue alpha:1];
    
    //    NSLog(@"red: %f, green: %f, blue: %f", colRed, colGreen, colBlue);
    
    float colRed2 = border02 & 2 ? 0.79 : 0;
    float colGreen2 = border02 & 4 ? 0.79 : 0;
    float colBlue2 = border02 & 1 ? 0.79 : 0;
    borderColorScreen02 = [UIColor colorWithRed:colRed2 green:colGreen2 blue:colBlue2 alpha:1];
    
    //    NSLog(@"red2: %f, green2: %f, blue2: %f", colRed2, colGreen2, colBlue2);
    
}


- (void)initializeTimer
{
    if (theTimer == nil)
    {
        theTimer = [CADisplayLink displayLinkWithTarget:self
                                               selector:@selector(flickerMode)];
        theTimer.frameInterval = 1;
        [theTimer addToRunLoop: [NSRunLoop currentRunLoop]
                       forMode: NSDefaultRunLoopMode];
    }
}


-(void)flickerMode {
    
    if (!check) {
        
        RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
        [convertedImage openZX_img_mgX:currentData];
        
        UIImage *image01 = convertedImage.FinallyProcessedImage;
        UIImage *image02 = convertedImage.FinallyProcessedImage2;
        
        flickerImages = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
        flickerImages.animationImages = [NSArray arrayWithObjects:
                                         image01, image02,
                                         nil];
        
        flickerImages.animationDuration = 0.01;
        flickerImages.animationRepeatCount = 0;
        [flickerImages startAnimating];
        
        [self.view addSubview:flickerImages];
        
        check = YES;
    }
//    HI Riskeyushka!
}

@end
