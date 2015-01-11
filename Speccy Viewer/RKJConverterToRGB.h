//
//  RKJConverterToRGB.h
//  SpecViewT1
//
//  Created by riskej & trefi, 2015.
//  Copyright (c) 2015 SimbolBit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKJConverterToRGB : UIImage

@property NSData* convertedSpeccyScr01;
@property int mode_scr;
@property (strong, nonatomic) UIImage *FinallyProcessedImage;
@property (strong, nonatomic) UIImage *FinallyProcessedImage2;
@property (strong, nonatomic) UIImage *FinallyProcessedImage_giga;
@property int BorderColor1;
@property int BorderColor2;

- (void) openZX_scr6144_n_rgb:(NSData*)datafile;
- (void) openZX_scr6912:(NSData*)datafile;
- (void) openZX_img_mgX:(NSData*)datafile;
- (void) openZX_img_mg1:(NSData*)datafile;
- (void) openZX_chr$:   (NSData*)datafile;
-(void) convertPNGtoSCR:(UIImage *)inputImage;

@end
