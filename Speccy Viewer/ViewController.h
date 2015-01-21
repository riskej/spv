//
//  ViewController.h
//  SpecViewT1
//
//  Created by riskej & trefi, 2015.
//  Copyright (c) 2015 SimbolBit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DBChooser/DBChooser.h>

@interface ViewController : UIViewController

//- (void)handleOpenURL:(NSURL *)url;
//- (void)convert6912Screen;

@property NSData *currentData;
@property (strong, nonatomic) DBChooser *dropboxChooserInView;


@end

