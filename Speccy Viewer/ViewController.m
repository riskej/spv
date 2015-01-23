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
#import "CNPGridMenu.h"
#import <DropboxSDK/DropboxSDK.h>
#import <DBChooser/DBChooser.h>
#import <DBChooser/DBChooserResult.h>

#define is_iphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define is_iphone4 (is_iphone && [[UIScreen mainScreen] bounds].size.height == 480.0f)
#define is_iphone5 (is_iphone && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define is_ipad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);

@interface ViewController () <CNPGridMenuDelegate, DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) CNPGridMenu *gridMenu;

@end

@implementation ViewController

{
    int modeToConvertFromPNG;
    NSUInteger inputScreenHeight;
    NSUInteger inputScreenWidth;
    NSUInteger curTypeFile;
    UILabel *noDataMessage;
    UILabel *noDataMessage2;
    UILabel *noDataMessage3;
    NSData *newData;
    int kRetina;
    BOOL isLoadedFilePNG;
    BOOL isDropboxActive;
    BOOL isFlashImage;
    BOOL is6912Image;
    BOOL isMG1Image;
    DBChooserResult *givenScreen;
    UIActivityViewController *shareScoresController;
    UIButton *mainMenu;
    NSUInteger incomingFileSize;
    UIImage *image01;
    UIImage *image02;
    UIImage *imageForNoflicDemonstration01;
    UIImage *imageForNoflicDemonstration02;
    BOOL check;
    BOOL isNoflicMode;
    CADisplayLink *theTimer;
    UIPinchGestureRecognizer *pinchRecognizer;
    UIImageView *flickerImages;
    UIImageView *screenToShow;
    UIImageView *screenToShow2;
    UIImageView *borderToShow;
//    UIImageView *borderToShow2;
    UIColor *borderColorScreen01;
//    UIColor *borderColorScreen02;
    int border01, border02;
    UIView *canvas;
    CGFloat _lastScale;
    CGFloat _lastRotation;
    CGFloat _firstX;
    CGFloat _firstY;
}

@synthesize currentData, dropboxChooserInView;


- (void)viewDidLoad {
    [super viewDidLoad];
    // we are Rulez
    
    // riskej's message
    
    // Dropbox init
//    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//    self.restClient.delegate = self;
    
    // Dropbox Drop-Ins custom object
    dropboxChooserInView = [[DBChooser alloc] initWithAppKey:@"2dn2a1a9kh6xp0u"];
    
    kRetina = 2;
    curTypeFile=0;
    
    self.view.backgroundColor = [UIColor blackColor];
    
    if (!isDropboxActive) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkingForFileSize)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil];
    }

    
    [self setupTouchInterface];
    
    
}

#pragma mark - Convert methods

- (void) convert6144_n_rgb:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_scr6144_n_rgb:currentData];
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage;
    
    screenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    screenToShow.image = convertedImage.FinallyProcessedImage;
    screenToShow.transform = CGAffineTransformMakeScale(1, 1);

    screenToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    screenToShow2.image = convertedImage.FinallyProcessedImage;
    screenToShow2.transform = CGAffineTransformMakeScale(1, 1);
    curTypeFile=1;
    [self.view addSubview:screenToShow];
    [self.view insertSubview:screenToShow belowSubview:mainMenu];
    [self.view addSubview:screenToShow2];
    [self.view insertSubview:screenToShow2 belowSubview:mainMenu];
}


- (void) convert6912Screen:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);


    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_scr6912:currentData];
    
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage2;
    
    curTypeFile=1;
    isNoflicMode = NO;
    isFlashImage = YES;
    is6912Image = YES;
    isMG1Image = NO;
    [self showFlickeringPicture];
    
}

- (void) convertChr$:(int)mode_scr height:(int)height width:(int)width {
    
    //    NSLog(@"URL in view: %@", currentData);
    self.view.backgroundColor = [UIColor blackColor];
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_chr:currentData];
    
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage2;
    imageForNoflicDemonstration01 = convertedImage.FinallyProcessedImage;
    int yy = height*8;
    int xx = width*8;
    
    screenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-xx/2, self.view.center.y-yy/2, xx, yy)];
    screenToShow.image = convertedImage.FinallyProcessedImage;
    screenToShow.transform = CGAffineTransformMakeScale(1, 1);
    
    screenToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-xx/2, self.view.center.y-yy/2, xx, yy)];
    screenToShow2.image = convertedImage.FinallyProcessedImage2;
    screenToShow2.transform = CGAffineTransformMakeScale(1, 1);
    curTypeFile=1;
    [self.view addSubview:screenToShow];
    [self.view insertSubview:screenToShow belowSubview:mainMenu];
    [self.view addSubview:screenToShow2];
    [self.view insertSubview:screenToShow2 belowSubview:mainMenu];
    
    isNoflicMode = YES;
    
}


- (void) convertImgMgx:(int) mode_scr {
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr = mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_img_mgX:currentData];
    
    border01 = convertedImage.BorderColor1;
    border02 = convertedImage.BorderColor2;
    
    [self getBorderColors];
    
    if (incomingFileSize != 13824) {
        borderToShow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 2300, 2300)];
        borderToShow.backgroundColor = borderColorScreen01;
        borderToShow.alpha = 1;
//        borderToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//        borderToShow2.backgroundColor = borderColorScreen02;
//        borderToShow2.alpha = 0.5;
    
        [self.view addSubview:borderToShow];
        [self.view insertSubview:borderToShow belowSubview:mainMenu];
//        [self.view addSubview:borderToShow2];
//        [self.view insertSubview:borderToShow2 belowSubview:mainMenu];
    }
    
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage2;
    
    convertedImage.mode_scr = mode_scr;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_img_mgX_noflic:currentData];
    
    imageForNoflicDemonstration01 = convertedImage.FinallyProcessedImage;
    imageForNoflicDemonstration02 = convertedImage.FinallyProcessedImage2;
    curTypeFile=1;
    isLoadedFilePNG = NO;
    isNoflicMode = NO;
    isFlashImage = NO;
    is6912Image = NO;
    isMG1Image = NO;
    [self showFlickeringPicture];
    
}


- (void) convertImgMg1 {
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_img_mg1:currentData];
    
    border01 = convertedImage.BorderColor1;
    border02 = convertedImage.BorderColor2;
    
    [self getBorderColors];
    
    borderToShow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    borderToShow.backgroundColor = borderColorScreen01;
    borderToShow.alpha = 1;
//    borderToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    borderToShow2.backgroundColor = borderColorScreen02;
//    borderToShow2.alpha = 0.5;
    
    [self.view addSubview:borderToShow];
    [self.view insertSubview:borderToShow belowSubview:mainMenu];
//    [self.view addSubview:borderToShow2];
//    [self.view insertSubview:borderToShow2 belowSubview:mainMenu];
    
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage2;
    
    convertedImage.mode_scr = 7;
    convertedImage.kRetina = kRetina;
    [convertedImage openZX_img_mg1_noflic:currentData];
    
    imageForNoflicDemonstration01 = convertedImage.FinallyProcessedImage;
//    imageForNoflicDemonstration02 = convertedImage.FinallyProcessedImage2;
    curTypeFile=1;
    isLoadedFilePNG = NO;
    isNoflicMode = NO;
    isFlashImage = NO;
    is6912Image = NO;
    isMG1Image = YES;
    [self showFlickeringPicture];
    
}


- (void)pngConverter {
    
    self.view.backgroundColor = [UIColor blackColor];
    
    RKJConverterToRGB *imageToConvert = [[RKJConverterToRGB alloc] init];
    
    UIImage *incomingImage = [UIImage imageWithData:currentData];
    imageToConvert.mode_scr = modeToConvertFromPNG;
    int size=[imageToConvert convertPNGtoSCR:incomingImage];
    image02 =  imageToConvert.FinallyProcessedImage2;
    //    image01 =  imageToConvert.FinallyProcessedImage2;
    
    //    currentData = imageToConvert.convertedSpeccyScr01;
    newData = imageToConvert.convertedSpeccyScr01;
    //
    //    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    imageToConvert.kRetina = kRetina;
//    NSLog(@"Convert OK! %i", size);
    if(size==6912) [imageToConvert openZX_scr6912:newData];
    else if(size==13824 || size == 15616 || size==18688) [imageToConvert openZX_img_mgX_noflic:newData];
    else [imageToConvert openZX_chr:newData];

    
    image01 = imageToConvert.FinallyProcessedImage;
    
    inputScreenHeight = image01.size.height/2;
    inputScreenWidth = image01.size.width/2;
    
    NSLog(@"input wide width: %i", (int)inputScreenWidth);
    NSLog(@"input wide height: %i", (int)inputScreenHeight);
    curTypeFile=2;
    isNoflicMode = NO;
    isFlashImage = NO;
    is6912Image = YES;
    isMG1Image = NO;
    [self showFlickeringPicture];
    
}


#pragma mark - Menu

- (void)showMenu {
    
    CNPGridMenuItem *i01 = [[CNPGridMenuItem alloc] init];
    i01.icon = [UIImage imageNamed:@"btn_openfile@2x.png"];
    i01.title = @"Open file from Dropbox";
    
    CNPGridMenuItem *i02 = [[CNPGridMenuItem alloc] init];
    i02.icon = [UIImage imageNamed:@"btn_share@2x"];
    i02.title = @"Share Image";
    
    CNPGridMenuItem *i03 = [[CNPGridMenuItem alloc] init];
    i03.icon = [UIImage imageNamed:@"btn_menu@2x"];
    i03.title = @"About";
    
    CNPGridMenuItem *i04 = [[CNPGridMenuItem alloc] init];
    if(curTypeFile==1) {
        i04.icon = [UIImage imageNamed:@"btn_savePNG@2x"];
        i04.title = @"Save *.png \nto Dropbox";
    }
    if(curTypeFile==2) {
        i04.icon = [UIImage imageNamed:@"btn_saveSCR@2x"];
        i04.title = @"Save source \nto Dropbox";
    }
    CNPGridMenu *gridMenu;
    if(curTypeFile==0) {
        gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[i01, i03]];
    }
    else {
        gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[i01, i04, i02, i03]];
    }
    gridMenu.delegate = self;
    [self presentGridMenu:gridMenu animated:YES completion:^{
        NSLog(@"Grid Menu Presented");
    }];
}


- (void)menuForSelectingModeToConvertFromPNG {
    
    CNPGridMenuItem *i01 = [[CNPGridMenuItem alloc] init];
    i01.icon = [UIImage imageNamed:@"btn_savePNG@2x"];
    i01.title = @"Convert to SCR";
    
    CNPGridMenuItem *i02 = [[CNPGridMenuItem alloc] init];
    i02.icon = [UIImage imageNamed:@"btn_saveSCR@2x"];
    i02.title = @"Convert to IMG";
    
    CNPGridMenuItem *i03 = [[CNPGridMenuItem alloc] init];
    i03.icon = [UIImage imageNamed:@"btn_openfile@2x.png"];
    i03.title = @"Convert to MG4";
    
    CNPGridMenuItem *i04 = [[CNPGridMenuItem alloc] init];
    i04.icon = [UIImage imageNamed:@"btn_share@2x"];
    i04.title = @"Convert to MG2";
    
    CNPGridMenu *gridMenu2 = [[CNPGridMenu alloc] initWithMenuItems:@[i01, i02, i03, i04]];
    gridMenu2.delegate = self;
    [self presentGridMenu:gridMenu2 animated:YES completion:^{
        NSLog(@"Grid Menu 2 Presented");
    }];
    
}


- (void)gridMenuDidTapOnBackground:(CNPGridMenu *)menu {
    [self dismissGridMenuAnimated:YES completion:^{
        NSLog(@"Grid Menu Dismissed With Background Tap");
    }];
}


- (void)gridMenu:(CNPGridMenu *)menu didTapOnItem:(CNPGridMenuItem *)item {
    [self dismissGridMenuAnimated:YES completion:^{
        NSLog(@"Grid Menu Did Tap On Item: %@", item.title);
        
        // Handling Menu to Convert From PNG
        
        if ([item.title isEqual: @"Convert to SCR"]) {
            modeToConvertFromPNG = 2;
            [self pngConverter];
        }
        
        if ([item.title isEqual: @"Convert to IMG"]) {
            modeToConvertFromPNG = 3;
            [self pngConverter];
        }
        
        if ([item.title isEqual: @"Convert to MG4"]) {
            modeToConvertFromPNG = 5;
            [self pngConverter];
        }
        
        if ([item.title isEqual: @"Convert to MG2"]) {
            modeToConvertFromPNG = 6;
            [self pngConverter];
        }
        
        
        // Handling Main Menu
        
        if ([item.title isEqual: @"Open file from Dropbox"]) {
            [self didPressChoose];
        }
        
        else if ([item.title isEqual: @"Share Image"])
            [self shareImage];
        
        else if ([item.title isEqual: @"Save *.png \nto Dropbox"]) {
            
            [self didPressLink];
            
            if (image01 != nil) {
                
                //            CGSize newSize = CGSizeMake(inputScreenWidth*2, inputScreenHeight*2);
                //            UIGraphicsBeginImageContext( newSize );
                //
                //            [image01 drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                //
                //                if (!isLoadedFilePNG) {
                //                    [image02 drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.5];
                //                }
                //
                //            UIImage *noflicImage = UIGraphicsGetImageFromCurrentImageContext();
                //            UIGraphicsEndImageContext();
                
                //            NSData *noflicImageData = UIImagePNGRepresentation(noflicImage);
                NSData *noflicImageData;
                
                if (!is6912Image) {
                    noflicImageData = UIImagePNGRepresentation(imageForNoflicDemonstration01);
                }
                
                else {
                    noflicImageData = UIImagePNGRepresentation(image01);
                }
                
                NSString *filename = @"Picture.png";
                NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *localPath = [localDir stringByAppendingPathComponent:filename];
                [noflicImageData writeToFile:localPath atomically:YES];
                
                NSString *destDir = @"/SpeccyViewer/";
                [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
            }
        }
        
        else if ([item.title isEqual: @"Save source \nto Dropbox"]) {
            
            [self didPressLink];
            
            if (newData != nil) {
                
                NSData *noflicImageData = newData;
                NSUInteger imageSize = [newData length];
                
                if (imageSize >= 6912 && imageSize <= 18688) {
                    
                    NSString *filename;
                    
                    if (modeToConvertFromPNG == 2) {
                        filename = @"Picture.scr";
                    }
                    
                    else if (modeToConvertFromPNG == 3) {
                        filename = @"Picture.img";
                    }
                    
                    else if (modeToConvertFromPNG == 5) {
                        filename = @"Picture.mg4";
                    }
                    
                    else if (modeToConvertFromPNG == 6) {
                        filename = @"Picture.mg2";
                    }
                    
                    
                    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
                    [noflicImageData writeToFile:localPath atomically:YES];
                    
                    NSString *destDir = @"/SpeccyViewer/";
                    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
                    
                }
                
                else if ((inputScreenWidth > 240) || (inputScreenHeight > 160)) { /* !!!!!!!!!!!!!!*/
                    
                    NSString *filename = @"Picture.ch$";
                    NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *localPath = [localDir stringByAppendingPathComponent:filename];
                    [noflicImageData writeToFile:localPath atomically:YES];
                    
                    NSString *destDir = @"/SpeccyViewer/";
                    [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
                    
                }
                
                else {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No-No-No!"
                                                                    message:@"You can't save this type of image."
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                
            }
        }
        
        
    }];
}


#pragma mark - The Rest

-(void)checkingForFileSize {
    
    //    currentData =  [NSData dataWithContentsOfURL:givenScreen.link];
//    isLoadedFilePNG=YES;
//    currentData =  [NSData dataWithContentsOfURL:[NSURL URLWithString :@"https://www.dropbox.com/s/b0nhclsiujcdbxp/13.png?raw=1"]];
    //    [self convert6912Screen:2];
    
    // cls
    inputScreenWidth = 256;
    inputScreenHeight = 192;
    for (UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
    
    [self addButtons];
    
    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.IncomingURL != nil) {
        currentData = [NSData dataWithContentsOfURL:appDelegate.IncomingURL];
    }
    
    incomingFileSize = [currentData length];
    
    NSUInteger len = 7;
    Byte *ident = (Byte*)malloc(len);
    
    if (incomingFileSize > 15) {
        NSData *data = currentData;
        memcpy(ident, [data bytes], len);
    }
    //    NSLog(@"Incfileszie: %i", (int)incomingFileSize);
    
    if (incomingFileSize == 0) {
        
        self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0.79 alpha:1];
        

        noDataMessage = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        noDataMessage.textColor = [UIColor whiteColor];
        noDataMessage.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        noDataMessage.textAlignment = NSTextAlignmentCenter;
        noDataMessage.numberOfLines = 0;
        noDataMessage.text = [NSString stringWithFormat:@"Please use 'Open in...' menu \nin order to open an ZX Spectrum image."];
        [self.view addSubview:noDataMessage];
        

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
        //          9 - chr$
    }
//    else if (ident[0]=='c' && ident[1]=='h' && ident[2]=='r' && ident[3]=='$') {
//        [self convertChr$:9 height:ident[5] width:ident[4]];
//    }
    
    else if (incomingFileSize == 6144) {
        self.view.backgroundColor = [UIColor blackColor];
        [self convert6144_n_rgb:1];
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
    
    else if (incomingFileSize == 18432) {
        [self convert6144_n_rgb:10];
    }
    
    else if (incomingFileSize == 36871) {
        if (ident[0]=='M' && ident[1]=='G' && ident[2]=='S') [self convertImgMgx:11];
    }
    
    else if (ident[0]=='c' && ident[1]=='h' && ident[2]=='r' && ident[3]=='$') {
        [self convertChr$:9 height:ident[5] width:ident[4]];
    }
    
    else if (isLoadedFilePNG) {
//        [self pngConverter];
        [self menuForSelectingModeToConvertFromPNG];
    }
    
    else {
        curTypeFile=0;
        self.view.backgroundColor = [UIColor colorWithRed:0.79 green:0 blue:0.79 alpha:1];
        
        noDataMessage3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        noDataMessage3.textColor = [UIColor whiteColor];
        noDataMessage3.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        noDataMessage3.textAlignment = NSTextAlignmentCenter;
        noDataMessage3.numberOfLines = 0;
        noDataMessage3.text = [NSString stringWithFormat:@"Seems like the image you're loading \nis not a valid ZX Spectrum image"];
//        screenToShow= nil;
//        screenToShow2= nil;
        [self.view addSubview:noDataMessage3];
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
    
    float border[3]={0,0.4609375,0.8039};
    float colRed = border[((border01 & 2) + (border02 & 2)) >>1];
    float colGreen = border[((border01 & 4) + (border02 & 4)) >>2];
    float colBlue = border[(border01 & 1) + (border02 & 1)];
    borderColorScreen01 = [UIColor colorWithRed:colRed green:colGreen blue:colBlue alpha:1];
    
    //    NSLog(@"red: %f, green: %f, blue: %f", colRed, colGreen, colBlue);
    
//    float colRed2 = border02 & 2 ? 0.79 : 0;
//    float colGreen2 = border02 & 4 ? 0.79 : 0;
//    float colBlue2 = border02 & 1 ? 0.79 : 0;
//    borderColorScreen02 = [UIColor colorWithRed:colRed2 green:colGreen2 blue:colBlue2 alpha:1];
    
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
    

    [self.view addSubview :screenToShow];
//    [ScreenToShow removeFromSuperview];
    
    [self.view addSubview:screenToShow2];
//    [ScreenToShow2 removeFromSuperview];
    
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint touchCoordinates = [touch locationInView:self.view];
    
    if (!isNoflicMode && image01 != nil) {
        [flickerImages removeFromSuperview];
        [self showNoflicPicture];
        isNoflicMode = YES;
    }
}


-(void)showNoflicPicture {
    
//    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
//    convertedImage.mode_scr=6;
//    convertedImage.kRetina = kRetina;
//    [convertedImage openZX_img_mgX_noflic:currentData];
//    
//    UIImage *newNoflicImage = convertedImage.FinallyProcessedImage;
//    UIImage *newNoflicImage2 = convertedImage.FinallyProcessedImage2;
    
//    image01 = imageForNoflicDemonstration01;
//    image02 = imageForNoflicDemonstration02;
    
    if (isLoadedFilePNG) {
        currentData = newData;
    }
    
    screenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-inputScreenWidth/2, self.view.center.y-inputScreenHeight/2, inputScreenWidth, inputScreenHeight)];
    if (!is6912Image)
        screenToShow.image = imageForNoflicDemonstration01;
    else {
        screenToShow.image = image01;
    }
    screenToShow.alpha = 1.0;
    screenToShow.transform = CGAffineTransformMakeScale(1, 1);
    
    [self.view addSubview:screenToShow];
    [self.view insertSubview:screenToShow belowSubview:mainMenu];
    
    if (!isMG1Image) {
        screenToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-inputScreenWidth/2, self.view.center.y-inputScreenHeight/2, inputScreenWidth, inputScreenHeight)];
        if (!is6912Image)
            screenToShow2.image = imageForNoflicDemonstration02;
        
        else if (!isLoadedFilePNG) {
            screenToShow2.image = image02;
            is6912Image = NO;
        }
        
        else {
            screenToShow2.image = image01;
            is6912Image = NO;
        }
        
        screenToShow2.alpha = 1.0;
        screenToShow2.transform = CGAffineTransformMakeScale(1, 1);
        
        [self.view addSubview:screenToShow2];
        [self.view insertSubview:screenToShow2 belowSubview:mainMenu];
    }

//    [self showMenu];
    
}


-(void) showFlickeringPicture {
    
    flickerImages = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-inputScreenWidth/2, self.view.center.y-inputScreenHeight/2, inputScreenWidth, inputScreenHeight)];

    flickerImages.animationImages = [NSArray arrayWithObjects:
                                     image01, image02,
                                     nil];
    if (!isFlashImage)
        flickerImages.animationDuration = 0.01;
    
    else
        flickerImages.animationDuration = 0.83;
    
    flickerImages.animationRepeatCount = 0;
    flickerImages.transform = CGAffineTransformMakeScale(1, 1);
    [flickerImages startAnimating];
    
    [self.view addSubview:flickerImages];
    
}


-(void) addButtons {
    
    mainMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [mainMenu addTarget:self
               action:@selector(showMenu)
     forControlEvents:UIControlEventTouchUpInside];
   
    [mainMenu setImage:[UIImage imageNamed:@"btn_menu.png"] forState:UIControlStateNormal];
    mainMenu.frame = CGRectMake(0, 0, 80.0, 60.0);
    
    [self.view addSubview:mainMenu];
    [self.view insertSubview:mainMenu aboveSubview:borderToShow];
    
}


-(void) saveImageToCameraRoll {
    
    if (image01 != nil) {
    
    CGSize newSize = CGSizeMake(256, 192);
    UIGraphicsBeginImageContext( newSize );
    
    [image01 drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    [image02 drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.5];
    
    UIImage *noflicImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(noflicImage, nil, nil, nil);
        
    }
}


-(void) shareImage {
    
    if (image01 != nil) {
        
//        CGSize newSize = CGSizeMake(512, 384);
//        UIGraphicsBeginImageContext( newSize );
//        
//        [image01 drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//        [image02 drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.5];
//        
//        UIImage *noflicImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
    
        UIImage *noflicImageData;
        
        if (!is6912Image) {
            noflicImageData = imageForNoflicDemonstration01;
        }
        
        else {
            noflicImageData = image01;
        }

        NSArray * shareItems = [NSArray arrayWithObjects: [NSString stringWithFormat: @"Hey! Take a look at this great picture!"], noflicImageData, nil];
        
//        if (!shareScoresController)
//        {
        shareScoresController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
        shareScoresController.excludedActivityTypes = [NSArray arrayWithObjects: UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, nil];
//        }
    
    [self presentViewController: shareScoresController animated:YES completion:nil];

    }

}


-(void)scale:(id)sender {
    
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _lastScale = 1.0;
    }
    
    CGFloat scale = 1.0 - (_lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    
    CGAffineTransform currentTransform = screenToShow.transform;
    CGAffineTransform currentTransform2 = screenToShow2.transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    CGAffineTransform newTransform2 = CGAffineTransformScale(currentTransform2, scale, scale);
    
    [screenToShow setTransform:newTransform];
    [screenToShow2 setTransform:newTransform2];
    //    ScreenToShow.center = pinchRecognizer.view.center;
    _lastScale = [(UIPinchGestureRecognizer*)sender scale];
}


-(void)move:(id)sender {
    
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:canvas];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        _firstX = [screenToShow center].x;
        _firstY = [screenToShow center].y;
    }
    translatedPoint = CGPointMake(_firstX+translatedPoint.x, _firstY+translatedPoint.y);
    
    [screenToShow setCenter:translatedPoint];
    [screenToShow2 setCenter:translatedPoint];
}


- (void)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
}


- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File saved succesfully!"
                                                    message:@"Please check \nDropbox/SpeccyViewer folder."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}


- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
}


- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
        }
    }
}


- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}


- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
    NSLog(@"File loaded into path: %@", localPath);
}


- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
}


- (void)didPressChoose
{
//    AppDelegate * appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    dropboxChooserInView = appDelegate.dropboxChooser;

    [[DBChooser defaultChooser] openChooserForLinkType:DBChooserLinkTypeDirect fromViewController:self
                                            completion:^(NSArray *results)
     {
         isDropboxActive=YES;
         if ([results count]) {
             
             // url
             givenScreen = results[0];
             
             // filename
//             nameOfIncomingFile = results[2];
             
             NSString *cset = @".png";
             NSRange range = [givenScreen.name rangeOfString:cset];
             NSString *cset2 = @".PNG";
             NSRange range2 = [givenScreen.name rangeOfString:cset2];
             if (range.location == NSNotFound && range2.location == NSNotFound) {
                 isLoadedFilePNG = NO;
             } else {
                 isLoadedFilePNG = YES;
             }

             
//             NSString *incomingString = [givenScreen.link absoluteString];
//             NSLog(@"Link: %@", incomingString);
//             
//             NSString *fixedURL = [incomingString stringByReplacingOccurrencesOfString:@"?dl=0" withString:@"?raw=1"];
//             NSLog(@"FXLink: %@", fixedURL);
             
             if([[DBSession sharedSession] isLinked])
             {
                 self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
                 self.restClient.delegate = self;
                 
                 currentData = [NSData dataWithContentsOfURL:givenScreen.link];
                 NSLog(@"DBLink: %@", givenScreen.name);
                 [self checkingForFileSize];
                 isDropboxActive=NO;
             }
             else
             {
                 //If not linked then start linking here..
                 [[DBSession sharedSession] linkFromController:self];
             }

             
            
             
//
//             NSLog(@"Link: %@", givenScreen.link);
             
         } else {
             givenScreen = nil;
//             [[[UIAlertView alloc] initWithTitle:@"CANCELLED" message:@"user cancelled!"
//                                        delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil]
//              show];
         }

     }];
}


- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    noDataMessage.center = CGPointMake(size.width/2, size.height/2);
    noDataMessage2.center = CGPointMake(size.width/2, size.height/2+40);
    noDataMessage3.center = CGPointMake(size.width/2, size.height/2);
    flickerImages.center = CGPointMake(size.width/2, size.height/2);
    screenToShow.center = CGPointMake(size.width/2, size.height/2);
    screenToShow2.center = CGPointMake(size.width/2, size.height/2);
//    borderToShow.center = CGPointMake(size.width/2, size.height/2);
//    borderToShow.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}


@end