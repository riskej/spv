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

@interface ViewController () <CNPGridMenuDelegate, DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) CNPGridMenu *gridMenu;

@end

@implementation ViewController

{
    NSString *nameOfIncomingFile;
    BOOL isLoadedFileIsPNG;
    
    DBChooserResult *givenScreen;
//    DBChooser *dropboxChooserInView;
    UIActivityViewController *shareScoresController;
    UIButton *mainMenu;
    NSUInteger incomingFileSize;
    UIImage *image01;
    UIImage *image02;
    BOOL check;
    BOOL isNoflicMode;
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

@synthesize currentData, dropboxChooserInView;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Dropbox init
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    // Dropbox Drop-Ins custom object
    dropboxChooserInView = [[DBChooser alloc] initWithAppKey:@"2dn2a1a9kh6xp0u"];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkingForFileSize)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self setupTouchInterface];
    
}


- (void) convert6144Screen:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    [convertedImage openZX_scr6144:currentData];
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage;
    
    ScreenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow.image = convertedImage.FinallyProcessedImage;
    ScreenToShow.transform = CGAffineTransformMakeScale(1.3, 1.3);

    ScreenToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow2.image = convertedImage.FinallyProcessedImage;
    ScreenToShow2.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    [self.view addSubview:ScreenToShow];
    [self.view insertSubview:ScreenToShow belowSubview:mainMenu];
    [self.view addSubview:ScreenToShow2];
    [self.view insertSubview:ScreenToShow2 belowSubview:mainMenu];
}


- (void) convert6912Screen:(int) mode_scr {
    
    //    NSLog(@"URL in view: %@", currentData);
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    [convertedImage openZX_scr6912:currentData];
    
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage;
    
    ScreenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow.image = convertedImage.FinallyProcessedImage;
    ScreenToShow.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    ScreenToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow2.image = convertedImage.FinallyProcessedImage;
    ScreenToShow2.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    [self.view addSubview:ScreenToShow];
    [self.view insertSubview:ScreenToShow belowSubview:mainMenu];
    [self.view addSubview:ScreenToShow2];
    [self.view insertSubview:ScreenToShow2 belowSubview:mainMenu];
    
}


- (void) convertImgMgx:(int) mode_scr {
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    convertedImage.mode_scr=mode_scr;
    [convertedImage openZX_img_mgX:currentData];
    
    border01 = convertedImage.BorderColor1;
    border02 = convertedImage.BorderColor2;
    
    [self getBorderColors];
    
    if (incomingFileSize != 13824) {
        BorderToShow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        BorderToShow.backgroundColor = borderColorScreen01;
        BorderToShow.alpha = 1;
        BorderToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        BorderToShow2.backgroundColor = borderColorScreen02;
        BorderToShow2.alpha = 0.5;
    
        [self.view addSubview:BorderToShow];
        [self.view insertSubview:BorderToShow belowSubview:mainMenu];
        [self.view addSubview:BorderToShow2];
        [self.view insertSubview:BorderToShow2 belowSubview:mainMenu];
    }
    
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage2;
    
    isNoflicMode = NO;
    [self showFlickeringPicture];
    
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
    [self.view insertSubview:BorderToShow belowSubview:mainMenu];
    [self.view addSubview:BorderToShow2];
    [self.view insertSubview:BorderToShow2 belowSubview:mainMenu];
    
    image01 = convertedImage.FinallyProcessedImage;
    image02 = convertedImage.FinallyProcessedImage2;
    
    isNoflicMode = NO;
    [self showFlickeringPicture];
    
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
    
//    currentData =  [NSData dataWithContentsOfURL:givenScreen.link];
//    [self convert6912Screen:2];
    
    // cls
    
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
    
    else if (incomingFileSize > 19456 || isLoadedFileIsPNG) {
        
        RKJConverterToRGB *imageToConvert = [[RKJConverterToRGB alloc] init];
        UIImage *incomingImage = [UIImage imageWithData:currentData];
        [imageToConvert convertPNGtoSCR:incomingImage];
    
        currentData = imageToConvert.convertedSpeccyScr01;
        [self convert6912Screen:2];
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
    

    [self.view addSubview :ScreenToShow];
//    [ScreenToShow removeFromSuperview];
    
    [self.view addSubview:ScreenToShow2];
//    [ScreenToShow2 removeFromSuperview];
    
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

//    UITouch *touch = [[event allTouches] anyObject];
//    CGPoint touchCoordinates = [touch locationInView:self.view];
    
    if (!isNoflicMode && incomingFileSize > 12288 && image01 != nil) {
        [flickerImages removeFromSuperview];
        [self showNoflicPicture];
        isNoflicMode = YES;
    }
}


-(void)showNoflicPicture {
    
    RKJConverterToRGB *convertedImage = [[RKJConverterToRGB alloc] init];
    [convertedImage openZX_img_mgX:currentData];
    
    ScreenToShow = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow.image = image01;
    ScreenToShow.alpha = 1.0;
    ScreenToShow.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    ScreenToShow2 = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    ScreenToShow2.image = image02;
    ScreenToShow2.alpha = 0.5;
    ScreenToShow2.transform = CGAffineTransformMakeScale(1.3, 1.3);
    
    [self.view addSubview:ScreenToShow];
    [self.view insertSubview:ScreenToShow belowSubview:mainMenu];
    [self.view addSubview:ScreenToShow2];
    [self.view insertSubview:ScreenToShow2 belowSubview:mainMenu];

//    [self showMenu];
    
}


-(void) showFlickeringPicture {
    
    flickerImages = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-128, self.view.center.y-96, 256, 192)];
    flickerImages.animationImages = [NSArray arrayWithObjects:
                                     image01, image02,
                                     nil];
    
    flickerImages.animationDuration = 0.01;
    flickerImages.animationRepeatCount = 0;
    flickerImages.transform = CGAffineTransformMakeScale(1.3, 1.3);
    [flickerImages startAnimating];
    
    [self.view addSubview:flickerImages];
    
}


- (void)showMenu {
    
    CNPGridMenuItem *i01 = [[CNPGridMenuItem alloc] init];
    i01.icon = [UIImage imageNamed:@"btn_savePNG@2x"];
    i01.title = @"Save *.png \nto Dropbox";
    
    CNPGridMenuItem *i02 = [[CNPGridMenuItem alloc] init];
    i02.icon = [UIImage imageNamed:@"btn_saveSCR@2x"];
    i02.title = @"Save *.scr \nto Dropbox";
    
    CNPGridMenuItem *i03 = [[CNPGridMenuItem alloc] init];
    i03.icon = [UIImage imageNamed:@"btn_openfile@2x.png"];
    i03.title = @"Open file from Dropbox";
    
    CNPGridMenuItem *i04 = [[CNPGridMenuItem alloc] init];
    i04.icon = [UIImage imageNamed:@"btn_share@2x"];
    i04.title = @"Share Image";
    
    CNPGridMenuItem *i05 = [[CNPGridMenuItem alloc] init];
    i05.icon = [UIImage imageNamed:@"btn_menu@2x"];
    i05.title = @"About";
    
    CNPGridMenu *gridMenu = [[CNPGridMenu alloc] initWithMenuItems:@[i03, i01, i02, i04, i05]];
    gridMenu.delegate = self;
    [self presentGridMenu:gridMenu animated:YES completion:^{
        NSLog(@"Grid Menu Presented");
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
        
        if ([item.title isEqual: @"Open file from Dropbox"]) {
         
            [self didPressChoose];
            
        }
        
        else if ([item.title isEqual: @"Share Image"])
            [self shareImage];
        
        else if ([item.title isEqual: @"Save *.png \nto Dropbox"]) {
            
            [self didPressLink];
        
            if (image01 != nil) {

            CGSize newSize = CGSizeMake(512, 384);
            UIGraphicsBeginImageContext( newSize );
        
            [image01 drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
            [image02 drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.5];
        
            UIImage *noflicImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            NSData *noflicImageData = UIImagePNGRepresentation(noflicImage);
        
            NSString *filename = @"Picture.png";
            NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
            NSString *localPath = [localDir stringByAppendingPathComponent:filename];
            [noflicImageData writeToFile:localPath atomically:YES];
        
            NSString *destDir = @"/SpeccyViewer/";
            [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
        }
        }
        
        else if ([item.title isEqual: @"Save *.scr \nto Dropbox"]) {
            
            [self didPressLink];
            
            if (currentData != nil) {
                
                NSData *noflicImageData = currentData;
                NSUInteger imageSize = [currentData length];
                
                if (imageSize == 6912) {
                    
                NSString *filename = @"Picture.scr";
                NSString *localDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                NSString *localPath = [localDir stringByAppendingPathComponent:filename];
                [noflicImageData writeToFile:localPath atomically:YES];
                
                NSString *destDir = @"/SpeccyViewer/";
                [self.restClient uploadFile:filename toPath:destDir withParentRev:nil fromPath:localPath];
                    
                }
                
                else {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No way!"
                                                                    message:@"You can only save *.scr \n(6912 bytes) images"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                }
                
            }
        }
        
        
    }];
}


-(void) addButtons {
    
    mainMenu = [UIButton buttonWithType:UIButtonTypeCustom];
    [mainMenu addTarget:self
               action:@selector(showMenu)
     forControlEvents:UIControlEventTouchUpInside];
   
    [mainMenu setImage:[UIImage imageNamed:@"btn_menu.png"] forState:UIControlStateNormal];
    mainMenu.frame = CGRectMake(0, 0, 80.0, 60.0);
    
    [self.view addSubview:mainMenu];
    [self.view insertSubview:mainMenu aboveSubview:BorderToShow2];
    
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
        
        CGSize newSize = CGSizeMake(512, 384);
        UIGraphicsBeginImageContext( newSize );
        
        [image01 drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        [image02 drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:0.5];
        
        UIImage *noflicImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    
    
    if (!shareScoresController)
    {
        UIImage * shareImage = noflicImage;
        NSArray * shareItems = [NSArray arrayWithObjects: [NSString stringWithFormat: @"Hey! Take a look at this great picrure!"], shareImage, currentData, nil];
        
        shareScoresController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
        shareScoresController.excludedActivityTypes = [NSArray arrayWithObjects: UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, nil];
    }
    
    [self presentViewController: shareScoresController animated:YES completion:nil];

    }

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
         if ([results count]) {
             
             // url
             givenScreen = results[0];
             
             // filename
//             nameOfIncomingFile = results[2];
//             
//             NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:@"png"];
//             NSRange range = [nameOfIncomingFile rangeOfCharacterFromSet:cset];
//             if (range.location == NSNotFound) {
//                 isLoadedFileIsPNG = NO;
//             } else {
//                 isLoadedFileIsPNG = YES;
//             }
//
//             NSCharacterSet *cset2 = [NSCharacterSet characterSetWithCharactersInString:@"PNG"];
//             NSRange range2 = [nameOfIncomingFile rangeOfCharacterFromSet:cset2];
//             if (range2.location == NSNotFound) {
//                 isLoadedFileIsPNG = NO;
//             } else {
//                 isLoadedFileIsPNG = YES;
//             }
             
//             NSString *incomingString = [givenScreen.link absoluteString];
//             NSLog(@"Link: %@", incomingString);
//             
//             NSString *fixedURL = [incomingString stringByReplacingOccurrencesOfString:@"?dl=0" withString:@"?raw=1"];
//             NSLog(@"FXLink: %@", fixedURL);
             
             currentData = [NSData dataWithContentsOfURL:givenScreen.link];
             [self checkingForFileSize];
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


@end
