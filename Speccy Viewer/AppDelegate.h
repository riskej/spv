//
//  AppDelegate.h
//  SpecViewT1
//
//  Created by riskej & trefi, 2015.
//  Copyright (c) 2015 SimbolBit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DBChooser/DBChooser.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSURL *IncomingURL;
@property (strong, nonatomic) DBChooser *dropboxChooser;

@end