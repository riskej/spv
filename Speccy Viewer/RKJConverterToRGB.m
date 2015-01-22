//
//  RKJConverterToRGB.m
//  SpecViewT1
//
//  Created by riskej & trefi, 2015.
//  Copyright (c) 2015 SimbolBit. All rights reserved.
//

#import "RKJConverterToRGB.h"

@implementation RKJConverterToRGB

{
    NSUInteger shiftPixelAdress;
    NSUInteger shiftZxcharAdress;
    NSUInteger screenPartPixelMax;
    NSUInteger thePixelIsExist;
    NSUInteger screenPart;
    BOOL firstByte;
    BOOL third1, third2, third3;
    int byteNumber;
    BOOL nextLineForAttrs;
}

@synthesize convertedSpeccyScr01;
@synthesize mode_scr;
@synthesize kRetina;
@synthesize FinallyProcessedImage;
@synthesize FinallyProcessedImage2;
@synthesize FinallyProcessedImage_giga;
@synthesize BorderColor1;
@synthesize BorderColor2;

//#define Mask8(x) ( (x) & 0xFF )
//#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )
//#define RGBMake(r, g, b) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 )
//#define BlackColor = 0;

- (void) openZX_scr6144_n_rgb:(NSData*)datafile {
    
    UInt32 * inputPixels;
    
    NSUInteger inputWidth = 256*2;
    NSUInteger inputHeight = 192*2;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    
    
    for (NSUInteger yRetina = 0; yRetina < 2; yRetina++) {
        for (int line = 0; line < 192; line++) {
            [self calculateAddressForPixel:line andMode:mode_scr];
            for (int xchar = 0; xchar < 32; xchar++) {
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                if(mode_scr==1){
                    NSUInteger byte = byteData[shiftPixelAdress + xchar];
                    for (int xBit=128;xBit>0; xBit/=2) {
                        *inputPixel++ = byte & xBit ? 0xffffff : 0;
                        *inputPixel++ = byte & xBit ? 0xffffff : 0;
                    }
                }
                if(mode_scr==10) {
                    NSUInteger byteR = byteData[shiftPixelAdress + xchar];
                    NSUInteger byteG = byteData[shiftPixelAdress + xchar+6144];
                    NSUInteger byteB = byteData[shiftPixelAdress + xchar+12288];
                    
                    for (int xBit=128;xBit>0; xBit/=2) {
                        int pix = byteR & xBit ? 0xff : 0;
                        pix|= byteG & xBit ? 0xff00 : 0;
                        pix|= byteB & xBit ? 0xff0000 : 0;
                        *inputPixel++=pix;
                        *inputPixel++=pix;
                    }
                }
                
               
            }
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    free(inputPixels);
    
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    FinallyProcessedImage = processedImage;
    
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newCGImage);
    CGContextRelease(context);
}


- (void) openZX_scr6912:(NSData*)datafile {
    
    UInt32 * inputPixels_firstImage_noFlash;
    UInt32 * inputPixels_firstImage_invertedFlash;
    NSUInteger colorPalettePulsar [16] = {0x0, 0xca0000, 0x0000ca, 0xca00ca, 0x00ca00, 0xcaca00, 0x00caca, 0xcacaca,
        0x0, 0xfe0000, 0x0000fe, 0xfe00fe, 0x00fe00, 0xfefe00, 0x00fefe, 0xfefefe};
    
    
    
    NSUInteger inputWidth = 256*kRetina;
    NSUInteger inputHeight = 192*kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels_firstImage_noFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_firstImage_invertedFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    //    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString :@"https://dl.dropboxusercontent.com/u/36464659/_apptest/nday6144.scr"]];
    
    //    NSData *data = [NSData dataWithContentsOfFile:@"/Users/riskej/Documents/Developing/SpecViewT1/Files/nday6144.scr"];
    
    NSData *data = datafile;
    
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    
    // Draw Screen
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen = 0;
    NSUInteger firstByteOfCharsArrayOfFirstScreen = 6144;
    
    for (NSUInteger yRetina = 0; yRetina < kRetina; yRetina++) {
        
        for (int line=0; line<192; line++) {
            
            [self calculateAddressForPixel:line andMode:mode_scr];
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel_firstImage_noFlash = inputPixels_firstImage_noFlash + (line * kRetina + yRetina) * inputWidth + (xchar*8*kRetina);
                UInt32 * inputPixel_firstImage_invertedFlash = inputPixels_firstImage_invertedFlash + (line * kRetina + yRetina) * inputWidth + (xchar*8*kRetina);
                NSUInteger byte = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
                NSUInteger atr= byteData[firstByteOfCharsArrayOfFirstScreen + shiftZxcharAdress + xchar];
                bool flash = atr & 128;
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                
                for (int xBit=128;xBit>0; xBit/=2) {
                    UInt32 valNoFlash= byte & xBit ? (int)ink : (int)paper;
                    UInt32 valFlash= (bool) (byte & xBit) ^ flash ? (int)ink : (int)paper;
                    for(int xRetina=0;xRetina<kRetina;xRetina++) {
                        *inputPixel_firstImage_noFlash++ = valNoFlash;
                        *inputPixel_firstImage_invertedFlash++ = valFlash;
                    }
                }
            }
        }
    }
    CGContextRef context = CGBitmapContextCreate(inputPixels_firstImage_noFlash, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    
    
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    FinallyProcessedImage = processedImage;
    
    free(byteData);
    //    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newCGImage);
    CGContextRelease(context);
    
    CGContextRef context2 = CGBitmapContextCreate(inputPixels_firstImage_invertedFlash, inputWidth, inputHeight,
                                                  bitsPerComponent, inputBytesPerRow, colorSpace,
                                                  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage2 = CGBitmapContextCreateImage(context2);
    CGContextDrawImage(context2, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage2);
    
    free(inputPixels_firstImage_noFlash);
    free(inputPixels_firstImage_invertedFlash);
    
    UIImage * processedImage2 = [UIImage imageWithCGImage:newCGImage2];
    FinallyProcessedImage2 = processedImage2;
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newCGImage2);
    CGContextRelease(context2);
    
}


- (void) openZX_chr:(NSData*)datafile {
    
    //    NSUInteger testArray[15] = [1, 2, 3];
    
    UInt32 * inputPixels;
    UInt32 * inputPixels2;
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    NSUInteger colorPalettePulsar [16] = {0x0, 0xca0000, 0x0000ca, 0xca00ca, 0x00ca00, 0xcaca00, 0x00caca, 0xcacaca,
        0x0, 0xfe0000, 0x0000fe, 0xfe00fe, 0x00fe00, 0xfefe00, 0x00fefe, 0xfefefe};
    
    
    int xMax=byteData[4];
    int yMax=byteData[5];
    int mode=byteData[6];
    int mode05=9;
    int modeY=8;
    if(mode>17) mode05=mode/2;
    switch (mode) {
        case 18:
            modeY=8;
            break;
        case 20:
            modeY=4;
            break;
        case 24:
            modeY=2;
            break;
        default:
            break;
    }
    
    NSUInteger inputWidth = xMax * 8 * kRetina;
    NSUInteger inputHeight =yMax * 8 * kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    
    inputPixels =  (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels2 = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    NSLog(@"Width: %i", xMax);
    NSLog(@"Height: %i", yMax);
    
    UInt32 iipp[4];
    for (int ychar=0; ychar<yMax; ychar++) {
        
        for (int xchar=0; xchar<xMax; xchar++) {
            
            NSUInteger nchar = ychar * xMax + xchar;
            
            if (mode==8) {
                for(int ypix=0;ypix<8;ypix++) {
                    NSUInteger adr = ((ychar * 8 + ypix) * kRetina) * inputWidth  + (xchar*8*kRetina);
                    NSUInteger byte = byteData[7+nchar*8+ypix];
                    int xpix=0;
                    for(int xBit=128;xBit>0;xBit/=2) {
                        UInt32 val= byte & xBit ? 0xffffff : 0;
                        for(int yRetina=0;yRetina<kRetina;yRetina++) {
                            UInt32 * inputPixel=inputPixels + adr + yRetina * inputWidth + xpix * kRetina;
                            UInt32 * inputPixel2=inputPixels2 + adr + yRetina * inputWidth + xpix * kRetina;
                            xpix++;
                            for(int xRetina=0;xRetina<kRetina;xRetina++) {
                                *inputPixel++=val;
                                *inputPixel2++=val;
                            }
                        }
                    }
                }
            }

            if (mode==9) {
                for(int ypix=0;ypix<8;ypix++) {
                    NSUInteger adr = ((ychar * 8 + ypix) * kRetina) * inputWidth  + (xchar*8*kRetina);
                    NSUInteger atr = byteData[7+nchar*9+8];
                    NSUInteger bright = atr & 64 ? 8 : 0;
                    NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                    NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                    NSUInteger byte = byteData[7+nchar*9+ypix];
                    int xpix=0;
                    for(int xBit=128;xBit>0;xBit/=2,xpix++) {
                        UInt32 val= byte & xBit ? (int)ink : (int)paper;
                        for(int yRetina=0;yRetina<kRetina;yRetina++) {
                            UInt32 * inputPixel=inputPixels + adr + yRetina * inputWidth + xpix * kRetina;
                            UInt32 * inputPixel2=inputPixels2 + adr + yRetina * inputWidth + xpix * kRetina;
                            
                            for(int xRetina=0;xRetina<kRetina;xRetina++) {
                                *inputPixel++=val;
                                *inputPixel2++=val;
                            }
                        }
                    }
                }
            }
            
            if (mode>17) {
                for(int ypix=0;ypix<8;ypix++) {
                    NSUInteger adr = ((ychar * 8 + ypix) * kRetina) * inputWidth  + (xchar*8*kRetina);
                    NSUInteger byte1 = byteData[7 + nchar*mode + ypix];
                    NSUInteger atr1 = byteData[7 + nchar*mode + 8 + ypix/modeY];
                    NSUInteger flash1 = atr1 & 128;
                    NSUInteger bright1 = atr1 & 64;
    
                    NSUInteger byte2 = byteData[7 + nchar*mode + mode05 + ypix];
                    NSUInteger atr2 = byteData[7 + nchar*mode + mode05+8 + ypix/modeY];
                    NSUInteger flash2 = atr2 & 128;
                    NSUInteger bright2 = atr2 & 64;
                    
                    // i - ink , p - paper     // p0p1 - 1   i0i1 - 2  i0p1 - 3   p0i1 - 4
                    iipp[3]=[self calculateColorForGiga:atr1 :atr2];
                    iipp[1]=[self calculateColorForGiga:atr1 :(bright2|((atr2>>3)&7))];
                    iipp[2]=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :atr2];
                    iipp[0]=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :(bright2|((atr2>>3)&7))];
                    
                    NSUInteger xpix=0;
                    for (int xBit=128; xBit>0; xBit/=2,xpix++) {
                        NSUInteger val1=byte1 & xBit ? 1 : 0;
                        val1+=byte2 & xBit ? 2 : 0;
                        NSUInteger val2=val1 ^ (flash1>>7) ^ (flash2>>6);
                        for(int yRetina=0;yRetina<kRetina;yRetina++)
                        {
                            UInt32 * inputPixel_noFlash = inputPixels + adr + yRetina * inputWidth + xpix * kRetina;
                            UInt32 * inputPixel_invertedFlash = inputPixels2 + + adr + yRetina * inputWidth + xpix * kRetina;
                            for(int xRetina=0;xRetina<kRetina;xRetina++) {
                                *inputPixel_noFlash++ =iipp[val1];
                                *inputPixel_invertedFlash++ = iipp[val2];
                            }
                        }
                    }
                }
            }
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    FinallyProcessedImage = processedImage;
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    //
    CGContextRef context2 = CGBitmapContextCreate(inputPixels2, inputWidth, inputHeight,
                                                  bitsPerComponent, inputBytesPerRow, colorSpace,
                                                  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage2 = CGBitmapContextCreateImage(context2);
    CGContextDrawImage(context2, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage2);
    
    UIImage * processedImage2 = [UIImage imageWithCGImage:newCGImage2];
    FinallyProcessedImage2 = processedImage2;
    
    free(inputPixels);
    free(inputPixels2);
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context2);
    CGImageRelease(newCGImage);
    CGImageRelease(newCGImage2);
}


- (void) openZX_img_mgX:(NSData*)datafile {
    
    UInt32 * inputPixels_firstImage_noFlash;
    UInt32 * inputPixels_firstImage_invertedFlash;
    UInt32 * inputPixels_secondImage_noFlash;
    UInt32 * inputPixels_secondImage_invertedFlash;

    NSUInteger colorPalettePulsar [16] = {0x0, 0xca0000, 0x0000ca, 0xca00ca, 0x00ca00, 0xcaca00, 0x00caca, 0xcacaca,
        0x0, 0xfe0000, 0x0000fe, 0xfe00fe, 0x00fe00, 0xfefe00, 0x00fefe, 0xfefefe};
    
    bool isInterlaceMode=true;
    
    NSUInteger inputWidth = 256*kRetina;
    NSUInteger inputHeight = 192*kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels_firstImage_noFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_firstImage_invertedFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_secondImage_noFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_secondImage_invertedFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen=0;
    NSUInteger firstByteOfPixelArrayOfSecondScreen=0;
    NSUInteger firstByteOfCharsArrayOfFirstScreen=0;
    NSUInteger firstByteOfCharsArrayOfSecondScreen=0;
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    BorderColor1 = byteData [5];
    BorderColor2 = byteData [6];
    NSLog(@"border1: %i", BorderColor1);
    NSLog(@"border2: %i", BorderColor2);
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    
    if (mode_scr==3) {
        firstByteOfPixelArrayOfFirstScreen = 0;
        firstByteOfCharsArrayOfFirstScreen = 6144;
        firstByteOfPixelArrayOfSecondScreen = 6912;
        firstByteOfCharsArrayOfSecondScreen = 6912+6144;
    }
    
    if (mode_scr==4) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+768;
    }
    
    if (mode_scr==5) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+1536;
    }
    
    if (mode_scr==6) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+3072;
    }
        
    for (int line=0; line<192; line++) {
        
        [self calculateAddressForPixel:line andMode:mode_scr];
        
        for (int xchar=0; xchar<32; xchar++) {

            NSUInteger byte1 = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
            NSUInteger atr1= byteData[firstByteOfCharsArrayOfFirstScreen + shiftZxcharAdress + xchar];
            bool flash1 = atr1 & 128;
            NSUInteger bright1 = atr1 & 64 ? 8 : 0;
            NSUInteger ink1=(UInt32)colorPalettePulsar [(atr1 & 7) + bright1];
            NSUInteger paper1=(UInt32)colorPalettePulsar [(atr1 >> 3) & 7 + bright1];
            
            NSUInteger byte2 = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
            NSUInteger atr2= byteData[firstByteOfCharsArrayOfSecondScreen + shiftZxcharAdress + xchar];
            bool flash2 = atr2 & 128;
            NSUInteger bright2 = atr2 & 64 ? 8 : 0;
            NSUInteger ink2=(UInt32)colorPalettePulsar [(atr2 & 7) + bright2];
            NSUInteger paper2=(UInt32)colorPalettePulsar [(atr2 >> 3) & 7 + bright2];
            int xx=0;
            for (int xBit=128; xBit>0; xBit/=2,xx++) {
                UInt32 val_1_0=byte1 & xBit ? (int)ink1 : (int)paper1;
                UInt32 val_1_1=(bool) (byte1 & xBit) ^ flash1 ? (int)ink1 : (int)paper1;
                UInt32 val_2_0=byte2 & xBit ? (int)ink2 : (int)paper2;
                UInt32 val_2_1=(bool) (byte2 & xBit) ^ flash2 ? (int)ink2 : (int)paper2;
                for(int yRetina=0;yRetina<kRetina;yRetina++)
                {
                    NSUInteger adr = (line * kRetina + yRetina) * inputWidth + (xchar * 8 +xx) * kRetina;
                    UInt32 * inputPixel_firstImage_noFlash = inputPixels_firstImage_noFlash +adr;
                    UInt32 * inputPixel_firstImage_invertedFlash = inputPixels_firstImage_invertedFlash +adr;
                    UInt32 * inputPixel_secondImage_noFlash = inputPixels_secondImage_noFlash +adr;
                    UInt32 * inputPixel_secondImage_invertedFlash = inputPixels_secondImage_invertedFlash +adr;
                    for(int xRetina=0;xRetina<kRetina;xRetina++) {
                        *inputPixel_firstImage_noFlash++ = val_1_0;
                        *inputPixel_firstImage_invertedFlash++ = val_1_1;
                        *inputPixel_secondImage_noFlash++ = val_2_0;
                        *inputPixel_secondImage_invertedFlash++ = val_2_1;
                    }
                }
            }
        }
    }
    
    if (isInterlaceMode==true) {
        NSLog(@"Interlace");
        NSUInteger numberLines=96;
        NSUInteger numberBytes=inputWidth*kRetina;
        if(mode_scr==6) numberLines=48,numberBytes=inputWidth*2*kRetina;
        for (int line=0;line<numberLines;line++) {
            NSUInteger adr = line * numberBytes * 2;
            UInt32 * inputPixel_firstImage_noFlash = inputPixels_firstImage_noFlash + adr;
            UInt32 * inputPixel_firstImage_invertedFlash = inputPixels_firstImage_invertedFlash + adr;
            UInt32 * inputPixel_secondImage_noFlash = inputPixels_secondImage_noFlash + adr;
            UInt32 * inputPixel_secondImage_invertedFlash = inputPixels_secondImage_invertedFlash + adr;
            for(int i=0;i<numberBytes;i++) {
                UInt32 a=*inputPixel_firstImage_noFlash;// ^ 0xffffff;
                *inputPixel_firstImage_noFlash=*inputPixel_secondImage_noFlash;
                *inputPixel_secondImage_noFlash=a;
                
                a=*inputPixel_firstImage_invertedFlash;
                *inputPixel_firstImage_invertedFlash=*inputPixel_secondImage_invertedFlash;
                *inputPixel_secondImage_invertedFlash=a;
                
                inputPixel_firstImage_noFlash++;
                inputPixel_firstImage_invertedFlash++;
                inputPixel_secondImage_noFlash++;
                inputPixel_secondImage_invertedFlash++;
            }
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(inputPixels_firstImage_noFlash, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    FinallyProcessedImage = processedImage;
    
    CGContextRef context2 = CGBitmapContextCreate(inputPixels_secondImage_noFlash, inputWidth, inputHeight,
                                                  bitsPerComponent, inputBytesPerRow, colorSpace,
                                                  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage2 = CGBitmapContextCreateImage(context2);
    CGContextDrawImage(context2, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage2);
    
    UIImage * processedImage2 = [UIImage imageWithCGImage:newCGImage2];
    FinallyProcessedImage2 = processedImage2;
    
    free(inputPixels_firstImage_noFlash);
    free(inputPixels_secondImage_noFlash);
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context2);
    CGImageRelease(newCGImage);
    CGImageRelease(newCGImage2);
}

- (void) openZX_img_mgX_noflic:(NSData*)datafile {
    
    UInt32 * inputPixels_firstImage_noFlash;
    UInt32 * inputPixels_firstImage_invertedFlash;
    
    NSUInteger inputWidth = 256*kRetina;
    NSUInteger inputHeight = 192*kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels_firstImage_noFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    inputPixels_firstImage_invertedFlash = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen=0;
    NSUInteger firstByteOfPixelArrayOfSecondScreen=0;
    NSUInteger firstByteOfCharsArrayOfFirstScreen=0;
    NSUInteger firstByteOfCharsArrayOfSecondScreen=0;
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    BorderColor1 = byteData [5];
    BorderColor2 = byteData [6];
    NSLog(@"border1: %i", BorderColor1);
    NSLog(@"border2: %i", BorderColor2);
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    
    if (mode_scr==3) {
        firstByteOfPixelArrayOfFirstScreen = 0;
        firstByteOfCharsArrayOfFirstScreen = 6144;
        firstByteOfPixelArrayOfSecondScreen = 6912;
        firstByteOfCharsArrayOfSecondScreen = 6912+6144;
    }
    
    if (mode_scr==4) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+768;
    }
    
    if (mode_scr==5) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+1536;
    }
    
    if (mode_scr==6) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+3072;
    }
    
    for (int line=0; line<192; line++) {
        
        [self calculateAddressForPixel:line andMode:mode_scr];
        
        for (int xchar=0; xchar<32; xchar++) {
            
            int byte1 = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
            int atr1= byteData[firstByteOfCharsArrayOfFirstScreen + shiftZxcharAdress + xchar];
            int flash1 = atr1 & 128;
            int bright1 = atr1 & 64;
            
            int byte2 = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
            int atr2= byteData[firstByteOfCharsArrayOfSecondScreen + shiftZxcharAdress + xchar];
            int flash2 = atr2 & 128;
            int bright2 = atr2 & 64;
            
            // i - ink , p - paper
            UInt32 i1i2=[self calculateColorForGiga:atr1 :atr2];
            UInt32 i1p2=[self calculateColorForGiga:atr1 :(bright2|((atr2>>3)&7))];
            UInt32 p1i2=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :atr2];
            UInt32 p1p2=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :(bright2|((atr2>>3)&7))];
            
            int xx=0;
            for (int xBit=128; xBit>0; xBit/=2,xx++) {
                UInt32 val1 = 0;
                UInt32 val2 = 0;
                int px=byte1 & xBit ? 1 : 0;
                px+=byte2 & xBit ? 2 : 0;
                switch(px){
                    case 0: val1=p1p2;
                        break;
                    case 1: val1=i1p2;
                        break;
                    case 2: val1=p1i2;
                        break;
                    case 3: val1=i1i2;
                        break;
                }
                px=px ^ (flash1>>7) ^ (flash2>>6);
                switch(px){
                    case 0: val2=p1p2;
                        break;
                    case 1: val2=i1p2;
                        break;
                    case 2: val2=p1i2;
                        break;
                    case 3: val2=i1i2;
                        break;
                }
                for(int yRetina=0;yRetina<kRetina;yRetina++)
                {
                    NSUInteger adr = (line * kRetina + yRetina) * inputWidth + (xchar * 8 +xx) * kRetina;
                    UInt32 * inputPixel_firstImage_noFlash = inputPixels_firstImage_noFlash +adr;
                    UInt32 * inputPixel_firstImage_invertedFlash = inputPixels_firstImage_invertedFlash +adr;
                    for(int xRetina=0;xRetina<kRetina;xRetina++) {
                        *inputPixel_firstImage_noFlash++ = val1;
                        *inputPixel_firstImage_invertedFlash++ = val2;
                    }
                }
            }
        }
    }
    
    CGContextRef context = CGBitmapContextCreate(inputPixels_firstImage_noFlash, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    FinallyProcessedImage = processedImage;
    
    CGContextRef context2 = CGBitmapContextCreate(inputPixels_firstImage_invertedFlash, inputWidth, inputHeight,
                                                  bitsPerComponent, inputBytesPerRow, colorSpace,
                                                  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage2 = CGBitmapContextCreateImage(context2);
    CGContextDrawImage(context2, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage2);
    
    UIImage * processedImage2 = [UIImage imageWithCGImage:newCGImage2];
    FinallyProcessedImage2 = processedImage2;
    
    free(inputPixels_firstImage_noFlash);
    free(inputPixels_firstImage_invertedFlash);
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context2);
    CGImageRelease(newCGImage);
    CGImageRelease(newCGImage2);
}


- (void) openZX_img_mg1:(NSData*)datafile {
    
    //    NSUInteger testArray[15] = [1, 2, 3];
    
    UInt32 * inputPixels;
    
    NSUInteger colorPalettePulsar [16] = {0x0, 0xca0000, 0x0000ca, 0xca00ca, 0x00ca00, 0xcaca00, 0x00caca, 0xcacaca,
        0x0, 0xfe0000, 0x0000fe, 0xfe00fe, 0x00fe00, 0xfefe00, 0x00fefe, 0xfefefe};
    
    //    NSUInteger colorPalettePulsar [16] = {0x0, 0x0000ea, 0xea0000, 0xea00ea, 0x00ea00, 0x00eaea, 0xeaea00, 0xeaeaea,
    //        0x0, 0x0000fe, 0xfe0000, 0xfe00fe, 0x00fe00, 0x00fefe, 0xfefe00, 0xfefefe};
    
    NSUInteger inputWidth = 256*2;
    NSUInteger inputHeight = 192*2;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen=256;
    NSUInteger firstByteOfPixelArrayOfSecondScreen=256+6144;
    NSUInteger firstByteOf_1_CharsArrayOfFirstScreen=256+6144*2;
    NSUInteger firstByteOf_1_CharsArrayOfSecondScreen=256+6144*2+3072;
    NSUInteger firstByteOf_8_CharsArrayOfFirstScreen=256+6144*3;
    NSUInteger firstByteOf_8_CharsArrayOfSecondScreen=256+6144*3+384;
    
    
    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    BorderColor1 = byteData [5];
    BorderColor2 = byteData [6];
    //    NSLog(@"border1: %i", BorderColor1);
    //    NSLog(@"border2: %i", BorderColor2);
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    
    mode_scr = 7;
    
    NSUInteger shift_1_Zxchar=0;
    NSUInteger shift_8_Zxchar=0;
    
    NSUInteger atr=0;
    
    for (NSUInteger yRetina = 0; yRetina < 2; yRetina++) {
        
        for (int line=0; line<192; line++) {
            
            [self calculateAddressForPixel:line andMode:mode_scr];
            shift_8_Zxchar = (line>>3) * 16;
            shift_1_Zxchar = line * 16;
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                
                if (xchar>7 && xchar<24) atr = byteData[firstByteOf_1_CharsArrayOfFirstScreen + shift_1_Zxchar + xchar-8];
                else atr = byteData[firstByteOf_8_CharsArrayOfFirstScreen + shift_8_Zxchar + (xchar & 15)];
                
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                NSUInteger byte = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
                
                for (int xBit=128; xBit>0; xBit/=2) {
                    *inputPixel++ = byte & xBit ? (int)ink : (int)paper;
                    *inputPixel++ = byte & xBit ? (int)ink : (int)paper;
                }
            }
        }
    }
    
    
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    //    free(inputPixels);
    
    FinallyProcessedImage = processedImage;
    
    for (NSUInteger yRetina = 0; yRetina < 2; yRetina++) {
        
        for (int line=0; line<192; line++) {
            
            [self calculateAddressForPixel:line andMode:mode_scr];
            shift_8_Zxchar = (line>>3) * 16;
            shift_1_Zxchar = line * 16;
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                
                if (xchar>7 && xchar<24) atr= byteData[firstByteOf_1_CharsArrayOfSecondScreen + shift_1_Zxchar + xchar-8];
                else atr= byteData[firstByteOf_8_CharsArrayOfSecondScreen + shift_8_Zxchar + (xchar & 15)];
                
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                NSUInteger byte = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
                
                for (int xBit=128; xBit>0; xBit/=2) {
                    *inputPixel++ = byte & xBit ? (int)ink : (int)paper;
                    *inputPixel++ = byte & xBit ? (int)ink : (int)paper;
                }
            }
        }
    }
    
    CGContextRef context2 = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                  bitsPerComponent, inputBytesPerRow, colorSpace,
                                                  kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage2 = CGBitmapContextCreateImage(context2);
    CGContextDrawImage(context2, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage2);
    
    UIImage * processedImage2 = [UIImage imageWithCGImage:newCGImage2];
    FinallyProcessedImage2 = processedImage2;
    
    free(inputPixels);
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context2);
    CGImageRelease(newCGImage);
    CGImageRelease(newCGImage2);
    
}

- (void) openZX_img_mg1_noflic:(NSData*)datafile {
    
    UInt32 * inputPixels;
    
    NSUInteger inputWidth = 256*kRetina;
    NSUInteger inputHeight = 192*kRetina;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen=256;
    NSUInteger firstByteOfPixelArrayOfSecondScreen=256+6144;
    NSUInteger firstByteOf_1_CharsArrayOfFirstScreen=256+6144*2;
    NSUInteger firstByteOf_1_CharsArrayOfSecondScreen=256+6144*2+3072;
    NSUInteger firstByteOf_8_CharsArrayOfFirstScreen=256+6144*3;
    NSUInteger firstByteOf_8_CharsArrayOfSecondScreen=256+6144*3+384;

    NSData *data = datafile;
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    BorderColor1 = byteData [5];
    BorderColor2 = byteData [6];
    //    NSLog(@"border1: %i", BorderColor1);
    //    NSLog(@"border2: %i", BorderColor2);
    NSLog(@"screen length: %lu", (unsigned long)data.length);
    
    mode_scr = 7;
    
    NSUInteger shift_1_Zxchar=0;
    NSUInteger shift_8_Zxchar=0;
    int atr1=0;
    int atr2=0;
    
    for (int line=0; line<192; line++) {
        
        [self calculateAddressForPixel:line andMode:mode_scr];
        shift_8_Zxchar = (line>>3) * 16;
        shift_1_Zxchar = line * 16;
        
        for (int xchar=0; xchar<32; xchar++) {
            
            if (xchar>7 && xchar<24) {
                atr1 = byteData[firstByteOf_1_CharsArrayOfFirstScreen + shift_1_Zxchar + xchar-8];
                atr2 = byteData[firstByteOf_1_CharsArrayOfSecondScreen + shift_1_Zxchar + xchar-8];
            }
            else {
                atr1 = byteData[firstByteOf_8_CharsArrayOfFirstScreen + shift_8_Zxchar + (xchar & 15)];
                atr2 = byteData[firstByteOf_8_CharsArrayOfSecondScreen + shift_8_Zxchar + (xchar & 15)];
            }
            int byte1 = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
            int bright1 = atr1 & 64;
            
            int byte2 = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
            int bright2 = atr2 & 64;
            
            // i - ink , p - paper
            UInt32 i1i2=[self calculateColorForGiga:atr1 :atr2];
            UInt32 i1p2=[self calculateColorForGiga:atr1 :(bright2|((atr2>>3)&7))];
            UInt32 p1i2=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :atr2];
            UInt32 p1p2=[self calculateColorForGiga:(bright1|((atr1>>3)&7)) :(bright2|((atr2>>3)&7))];
            
            int xx=0;
            for (int xBit=128; xBit>0; xBit/=2,xx++) {
                UInt32 val1 = 0;
                int px=byte1 & xBit ? 1 : 0;
                px+=byte2 & xBit ? 2 : 0;
                switch(px){
                    case 0: val1=p1p2;
                        break;
                    case 1: val1=i1p2;
                        break;
                    case 2: val1=p1i2;
                        break;
                    case 3: val1=i1i2;
                        break;
                }
                for(int yRetina=0;yRetina<kRetina;yRetina++)
                {
                    NSUInteger adr = (line * kRetina + yRetina) * inputWidth + (xchar * 8 +xx) * kRetina;
                    UInt32 * inputPixel_firstImage_noFlash = inputPixels +adr;
                    for(int xRetina=0;xRetina<kRetina;xRetina++) {
                        *inputPixel_firstImage_noFlash++ = val1;
                    }
                }
            }
        }
    }
 
    CGContextRef context = CGBitmapContextCreate(inputPixels, inputWidth, inputHeight,
                                                 bitsPerComponent, inputBytesPerRow, colorSpace,
                                                 kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    CGContextDrawImage(context, CGRectMake(0, 0, inputWidth, inputHeight), newCGImage);
    
    free(inputPixels);
    
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    FinallyProcessedImage = processedImage;
    
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newCGImage);
    CGContextRelease(context);
}


-(int)calculateColorForGiga:(NSUInteger)col1 :(NSUInteger)col2 {
    
    int colorGigaPalettePulsar [16] = {0x0, 0x76, 0x00, 0x9f, 0x76, 0xcd, 0x76, 0xe9, 0x00, 0x76, 0x00, 0x9f, 0x9f, 0xe9, 0x9f, 0xff};
    
    int r=colorGigaPalettePulsar[4*(((col1&64)>>5) + ((col1>>1) & 1)) + ((col2&64)>>5) + ((col2>>1) & 1)];
    int g=colorGigaPalettePulsar[4*(((col1&64)>>5) + ((col1>>2) & 1)) + ((col2&64)>>5) + ((col2>>2) & 1)];
    int b=colorGigaPalettePulsar[4*(((col1&64)>>5) + (col1 & 1)) + ((col2&64)>>5) + (col2 & 1)];
    int rgb=(b<<16) | (g<<8) | r;
    return rgb;
}

-(int)calculateColorForMetaGiga:(NSUInteger)col1 :(NSUInteger)col2 {
    
    int colorGigaPalettePulsar [16] = {0, 1, 0, 2, 1, 3, 1, 4, 0, 1, 0, 2, 2, 4, 2, 5};
    int r=colorGigaPalettePulsar[4*(((col1&64)>>5) + ((col1>>1) & 1)) + ((col2&64)>>5) + ((col2>>1) & 1)];
    int g=colorGigaPalettePulsar[4*(((col1&64)>>5) + ((col1>>2) & 1)) + ((col2&64)>>5) + ((col2>>2) & 1)];
    int b=colorGigaPalettePulsar[4*(((col1&64)>>5) + (col1 & 1)) + ((col2&64)>>5) + (col2 & 1)];
    int rgb=(b<<6) | (g<<3) | r;
    return rgb;
}



-(void)calculateAddressForPixel:(int)line andMode:(int)mode {
    
    shiftPixelAdress = 2048*((line & 192) >> 6) + 32* ((line >> 3) & 7) + 256 * (line & 7);
    
    // modes =  1 - 6144
    //          2 - 6912
    //          3 - img(gsc)
    //          4 - mg8
    //          5 - mg4
    //          6 - mg2
    //          7 – mg1
    //          8 - mc
    //          9 - chr$
    //          10- rgb(3color)
    switch (mode) {
        case 2:
        case 3:
        case 4:
            shiftZxcharAdress = (line >> 3) * 32;
            break;
        case 5:
            shiftZxcharAdress  = (line >> 2)* 32;
            break;
        case 6:
            shiftZxcharAdress  = (line >> 1)* 32;
            break;
        case 7:
            shiftZxcharAdress  = line *16;
            break;
        case 8:
            shiftZxcharAdress = shiftPixelAdress = line * 32;
            break;
        default:
            break;
    }
//    from Trefyushka
}


- (int) convertPNGtoSCR:(UIImage *)inputImage {
    
    CGImageRef inputCGImage = [inputImage CGImage];
    NSUInteger width = CGImageGetWidth(inputCGImage);
    NSUInteger height = CGImageGetHeight(inputCGImage);
    
    float k=1;
    NSUInteger zxWidth=(width / 8) / k;
    NSUInteger zxHeight=(height / 8) /k;
    // 2.
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    UInt32 * pixels;
    pixels = (UInt32 *) calloc(height * width, sizeof(UInt32));
    
    // 3.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    // 4.
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), inputCGImage);
    
    NSLog(@"mode_scr=%i", mode_scr);
    NSUInteger chrMode=9;
    if(mode_scr==3) chrMode=18;
    if(mode_scr==5) chrMode=20;
    if(mode_scr==6) chrMode=24;
    
    NSUInteger mode05=chrMode/2;
    
    int atrOffSet=8;
    int chSize=8;
    
    // code routine here
    NSUInteger *colBuf = (NSUInteger*)malloc(64*sizeof(NSUInteger));
    NSUInteger *sortCol = (NSUInteger*)malloc(64*sizeof(NSUInteger));
    Byte *cntCol = (Byte*)malloc(64);
    NSUInteger len = 7 + zxHeight * zxWidth * chrMode;
    Byte *byteData = (Byte*)malloc(len);
    byteData[0]='c';
    byteData[1]='h';
    byteData[2]='r';
    byteData[3]='$';
    byteData[4]=zxWidth;
    byteData[5]=zxHeight;
    byteData[6]=chrMode;
    
    NSUInteger col=0;
    int colR,colG,colB;
    //converter
    if(chrMode<18) {
        
        //   -===- no Giga mode -===-
        
        for (int chars=0; chars<zxWidth*zxHeight; chars++) {
            NSUInteger pixs=7 + chars*chrMode;
            NSUInteger atr=pixs+atrOffSet;
            NSUInteger png=(int)(((int)(chars /zxWidth)) * width * chSize * k) + (int)((chars % zxWidth) * 8 * k);
            int ix=0;
            for (int ypix=0; ypix<8;ypix++) {
                
                for (int xpix=0; xpix<8;xpix++) {
                    int pix=pixels[png+(int)(ypix*k) * width+(int)(xpix*k)];
                    colR=pix & 255;
                    colG=(pix>>8)&255;
                    colB=(pix>>16)&255;
                    col= colR > 0xf0 ? 64 + 2: colR < 0x80 ? 0 : 2;
                    col|= colG > 0xf0 ? 64 + 4: colG < 0x80 ? 0 : 4;
                    col|= colB > 0xf0 ? 64 + 1: colB < 0x80 ? 0 : 1;
                    colBuf[ix]=col;
                    ix++;
                }
            }
            //        Sort colors & counting;
            int carry=1;
            
            for(int i=0;i<64;sortCol[i]=0,cntCol[i++]=0);
            sortCol[0]=colBuf[0];
            
            for (int i=0;i<64;i++) {
                BOOL flag=false;
                for (int curCar=0;curCar<carry;curCar++) {
                    if(colBuf[i]==sortCol[curCar]) {
                        cntCol[curCar]++;
                        flag=true;
                        break;
                    }
                }
                if(!flag) sortCol[carry]=colBuf[i], cntCol[carry++]++;
            }
            //          find 2 most meeted colors
            int paperVal=0;
            int paperCnt=0;
            int inkVal=0;
            int inkCnt=0;
            
            for (int i=0;i<carry;i++)
                if(paperVal<cntCol[i]) paperCnt=i,paperVal=cntCol[i];
            
            if (paperVal!=64)
            {
                cntCol[paperCnt]=0;
                for (int i=0;i<carry;i++) {
                    if(inkVal<cntCol[i]) inkCnt=i,inkVal=cntCol[i];
                }
            }
//            if(paperVal==64) {
//                sortCol[inkCnt]=sortCol[paperCnt];
//            }
            //          set color in char
            if(sortCol[paperCnt]<=sortCol[inkCnt]) {
                byteData[atr]=((64 & sortCol[paperCnt]) + ((sortCol[paperCnt]&7)<<3)) | sortCol[inkCnt];
                //            set pixels
                for(int yy=0;yy<8;yy++) {
                    int byte_l=0;
                    for (int xx=0;xx<8;xx++) {
                        if(colBuf[yy*8+xx]==sortCol[inkCnt]) byte_l=byte_l*2+1;
                        else byte_l*=2;
                    }
                    byteData[pixs+yy]=byte_l;
                }
            }
            else {
                byteData[atr]=((64 & sortCol[inkCnt]) + ((sortCol[inkCnt]&7)<<3)) | sortCol[paperCnt];
                //            set pixels
                for(int yy=0;yy<8;yy++) {
                    int byte_l=0;
                    for (int xx=0;xx<8;xx++) {
                        if(colBuf[yy*8+xx]==sortCol[paperCnt]) byte_l=byte_l*2+1;
                        else byte_l*=2;
                    }
                    byteData[pixs+yy]=byte_l;
                }
            }
        }
        
        //      Optimizing SCR
        
        for (NSUInteger ychar=0 ;ychar<zxHeight; ychar++) {
            
            if(ychar>0) {
                if([self compare:byteData Old:(ychar-1) * zxWidth New:ychar*zxWidth charMode:chrMode]) {
                    [self reverse:byteData withCharN:ychar*zxWidth charMode:chrMode];
                }
            }
            for(NSUInteger xchar=1; xchar<zxWidth; xchar++) {
                if([self compareHorizontal:byteData Old:(ychar * zxWidth + xchar - 1) New:ychar * zxWidth + xchar charMode:chrMode]) {
                    [self reverse:byteData withCharN:ychar*zxWidth+xchar charMode:chrMode];
                }
            }
        }
        
//        for (int chars=0; chars<zxWidth*zxHeight; chars++) {
//            int pixs=7 + chars * chrMode;
//            int atr=pixs+atrOffSet;
//            byteData[atr]=7;
//        }
    }
    else {
        
        //   -===- GIGA & multiGIGA mode -===-
        NSUInteger sizeBufs=64;
        NSUInteger yInChr=8;
        NSUInteger mChar=1;
        switch (chrMode) {
            case 20:
                sizeBufs=32;
                yInChr=4;
                mChar=2;
                break;
            case 24:
                sizeBufs=16;
                yInChr=2;
                mChar=4;
                break;
            default:
                break;
        }
        
        // Prepape color tables
        
         NSLog(@"Convert PNG > GIGA Begin! %i", 0);

        int * iipp = (int *) calloc(65536, sizeof(int));
        
        for(int atr1=0, initadr=0; atr1<128; atr1++) {
            for (int atr2=0; atr2<128; atr2++) {
                iipp[initadr++]=[self calculateColorForMetaGiga:((atr1 & 64) | ((atr1 >> 3) & 7))   :((atr2 & 64) | ((atr2 >> 3) & 7))];
                iipp[initadr++]=[self calculateColorForMetaGiga:atr1                                :atr2];
                iipp[initadr++]=[self calculateColorForMetaGiga:atr1                                :((atr2 & 64) | ((atr2 >> 3) & 7))];
                iipp[initadr++]=[self calculateColorForMetaGiga:((atr1 & 64) | ((atr1 >> 3) & 7))   :atr2];
            }
        }
        
        NSUInteger diff [4] = {0,0,0,0};
        
        for (int chars=0; chars<zxWidth*zxHeight; chars++) {
            NSUInteger pixs1=7 + chars * chrMode;
            NSUInteger pixs2=pixs1 + mode05;
            for(int iterY=0;iterY<mChar;iterY++) {
                NSUInteger yy_com=yInChr*iterY;
               
                NSUInteger atr1=pixs1+8+iterY;
                NSUInteger atr2=pixs2+8+iterY;
                
                NSUInteger png=((int)(chars /zxWidth)) * width * chSize * k + (chars % zxWidth) * 8 * k;
                int ix=0;
                for (int ypix=0; ypix<yInChr;ypix++) {
                    
                    for (int xpix=0; xpix<8;xpix++) {
                        UInt32 pix=pixels[png+(iterY*yInChr+ypix)*(int)(width*k)+(int)(xpix*k)];
                        
                        colR=[self calculateBright:pix & 255];
                        colG=[self calculateBright:(pix>>8) & 255];
                        colB=[self calculateBright:(pix>>16) & 255];
                        col= (colB<<6) | (colG<<3) | colR;
                        colBuf[ix]=col;
                        ix++;
                    }
                }
                //        Sort colors & counting;
                NSUInteger carry=1;
                
                for(int i=0;i<sizeBufs;sortCol[i]=0,cntCol[i++]=0);
                sortCol[0]=colBuf[0];
                
                for(int i=0;i<sizeBufs;i++) {
                    BOOL flag=false;
                    for (int curCar=0;curCar<carry;curCar++) {
                        if(colBuf[i]==sortCol[curCar]) {
                            cntCol[curCar]++;
                            flag=true;
                            break;
                        }
                    }
                    if(!flag) sortCol[carry]=colBuf[i], cntCol[carry++]++;
                }
                //          find 4 most meeted colors
                for (int iter=0; iter<4; iter++) {
                    int big=cntCol[iter];
                    int iBig=iter;
                    for (int i=iter; i<carry; i++) {
                        if(cntCol[i]>big) iBig=i, big=cntCol[i];
                    }
                    NSUInteger temp=cntCol[iter];
                    cntCol[iter]=cntCol[iBig];
                    cntCol[iBig]=temp;
                    temp=sortCol[iter];
                    sortCol[iter]=sortCol[iBig];
                    sortCol[iBig]=temp;
                }
                // Подгонка остальных цветов в один из 4-х основных
                if(carry>4)
                {
                    for (int i=4; i<carry; i++ ) {
                        NSUInteger invalidColor=sortCol[i];
                        for(int a=0; a<4; a++) {
                            diff[a]=invalidColor ^ sortCol[a];
                            int xDiff=0;
                            for(int bits=512; bits>0; bits/=2) {
                                if (diff[a] & bits) xDiff++;
                            }
                            diff[a]=xDiff;
                        }
                        NSUInteger cntDiff=0;
                        NSUInteger valDiff=diff[0];
                        for (int b=1; b<4;b++) {
                            if (diff[b]<valDiff) valDiff=diff[b], cntDiff=b;
                        }
                        for(int c=0; c<64; c++) {
                            if (colBuf[c]==invalidColor) colBuf[c]=sortCol[cntDiff];
                        }
                    }
                }
                //
                NSUInteger gigaColor=[self calculateGiga_colorMetaTable:iipp colors:sortCol amount:carry];
                
                NSUInteger p0p1=sortCol[(gigaColor>>16) & 3]; // p0p1 - 1   i0i1 - 2  i0p1 - 3   p0i1 - 4
                NSUInteger i0i1=sortCol[(gigaColor>>18) & 3];
                NSUInteger i0p1=sortCol[(gigaColor>>20) & 3];
                NSUInteger p0i1=sortCol[(gigaColor>>22) & 3];
                
                //          set color in char
                byteData[atr1]=gigaColor & 127;
                byteData[atr2]=(gigaColor>>8) & 127;
                
                //            set pixels
                for(int yy=0;yy<yInChr;yy++) {
                    Byte byte_0=0;
                    Byte byte_1=0;
                    for (int xx=0,xBit=128; xx<8; xx++,xBit/=2) {
                        if(colBuf[yy*8+xx]==p0p1) continue;
                        if(colBuf[yy*8+xx]==i0i1) {byte_0+=xBit; byte_1+=xBit; continue;}
                        if(colBuf[yy*8+xx]==i0p1) {byte_0+=xBit; continue;}
                        if(colBuf[yy*8+xx]==p0i1) {byte_1+=xBit; continue;}
                    }
                    byteData[pixs1+yy_com+yy]=byte_0;
                    byteData[pixs2+yy_com+yy]=byte_1;
                }
                
            }
        }
        
        free(iipp);
        NSLog(@"Convert PNG > GIGA End! %i", 0);
    }
    
    if(zxWidth==32 && zxHeight==24) {
        if(chrMode==9) {
        
        [self convChr6912:byteData];
            len=6912;
        }
        if(chrMode==18) {
            [self convChr2Img:byteData];
            len=6912*2;
        }
        if(chrMode==20 || chrMode==24) {
            len=[self convChr2Mgx:byteData mode:chrMode];
        }
    }
    
    // create new image based on new data
    convertedSpeccyScr01 = [NSData dataWithBytes:(const void *)byteData length:len];
    
    
    UIImage * processedImage = [UIImage imageWithCGImage:inputCGImage];
    FinallyProcessedImage2 = processedImage;

    // 5. Cleanup
    free(colBuf);
    free(sortCol);
    free(cntCol);
    free(byteData);
    
    CGColorSpaceRelease(colorSpace);
//    CGImageRelease(inputCGImage);
    CGContextRelease(context);
//    NSLog(@"Convert OK! %i", 0);
    return len;
}


-(void)reverse:(Byte*)byteData withCharN:(NSUInteger)ch charMode:(NSUInteger)chrMode {
    NSUInteger pixs=7 + ch * chrMode;
    int col=byteData[pixs+ chrMode-1];
    byteData[pixs + chrMode-1]=(col&64)+((col&7)<<3)+((col>>3)&7);
    for(int y=0;y<8;y++) byteData[pixs+y]^=255;
}

-(BOOL)compare:(Byte*)byteData Old:(NSUInteger)old New:(NSUInteger)new charMode:(NSUInteger)chrMode {
    
    int atrOld=byteData[7+ old * chrMode + chrMode-1];
    int atrNew=byteData[7+ new * chrMode + chrMode-1];
    int ink1=atrOld&7;
    int paper1=(atrOld>>3) & 7;
    int ink2=atrNew&7;
    int paper2=(atrNew>>3) & 7;
    
    if(ink2==paper1 || paper2==ink1) return true;
    
    return false;
}

-(BOOL)compareHorizontal:(Byte*)byteData Old:(NSUInteger)old New:(NSUInteger)new charMode:(NSUInteger)chrMode {
    
    NSUInteger atrOld=byteData[7+ old * chrMode + chrMode-1];
    NSUInteger atrNew=byteData[7+ new * chrMode + chrMode-1];
    NSUInteger ink1=atrOld&7;
    NSUInteger paper1=(atrOld>>3) & 7;
    NSUInteger ink2=atrNew&7;
    NSUInteger paper2=(atrNew>>3) & 7;
    
    NSUInteger contrast=0;
    NSUInteger charLeft=7+ old * chrMode;
    NSUInteger charRight=7+ new * chrMode;
    
    for(int i=0;i<8;i++) {
        int cL=byteData[charLeft+i] & 1;
        int cR=byteData[charRight+i] >> 7;
        if(!(cL ^ cR)) contrast++;
    }
    
    if(ink2==paper1 || paper2==ink1) return true;
    //if((ink1==ink2) && (paper1==paper2)) return false;
    if ((ink1==ink2) && (contrast>6)) return true;
    if ((paper1==paper2) && (contrast>6)) return true;
    
    return FALSE;
}

-(int)calculateColorForGiga_2:(int)col1 :(int)col2 {
    
    int colorGigaPalettePulsar [16] = {0, 1, 0, 2, 1, 3, 1, 4, 0, 1, 0, 2, 2, 4, 2, 5};
    
    int r=colorGigaPalettePulsar[4 * ((col1 & 1) *2 + ((col1>>2) & 1)) + (col2&1)*2 + ((col2>>2) & 1)];
    int g=colorGigaPalettePulsar[4 * ((col1 & 1) *2 + ((col1>>3) & 1)) + (col2&1)*2 + ((col2>>3) & 1)];
    int b=colorGigaPalettePulsar[4 * ((col1 & 1) *2 + ((col1>>1) & 1)) + (col2&1)*2 + ((col2>>1) & 1)];
    int rgb=(b<<6) | (g<<3) | r;
    return rgb;
}

-(int)calculateBright:(NSUInteger)col {
    if (col < 0x66) return 0;
    if (col < 0x8a) return 1;
    if (col < 0xb6) return 2;
    if (col < 0xdb) return 3;
    if (col < 0xf3) return 4;
    return 5;
}

-(NSUInteger)calculateGiga_colorMetaTable:(int*)iipp colors:(NSUInteger *)mt amount:(NSUInteger)amount {
    
    // p0p1 - 1   i0i1 - 2  i0p1 - 3   p0i1 - 4
    
    NSUInteger num=amount;
    if(amount > 3) num=4;
    int ipadr=0;
    int c0=mt[0];
    for(int atr1=0; atr1<128; atr1++) {
        for (int atr2=0; atr2<128; atr2++) {
            int ixip[4]={3,3,3,3};
            if(c0==iipp[ipadr+0] || c0==iipp[ipadr+1] || c0==iipp[ipadr+2] || c0==iipp[ipadr+3]) {
                int ifind=0;
                for (int i=0; i<num; i++) {
                    BOOL find=false;
                    if(mt[i]==iipp[ipadr+0]) ixip[0]=i, find=true;
                    if(mt[i]==iipp[ipadr+1]) ixip[1]=i, find=true;
                    if(mt[i]==iipp[ipadr+2]) ixip[2]=i, find=true;
                    if(mt[i]==iipp[ipadr+3]) ixip[3]=i, find=true;
                    if (find) ifind++;
                }
                if (ifind>=num) return (ixip[3]<<22) | (ixip[2]<<20) | (ixip[1]<<18) | (ixip[0]<<16) | (atr2<<8) | atr1;
            }
            ipadr+=4;
        }
    }
    return  0b111001000101010001001011;
}
-(int) get2colfrom1:(int)col1 {
    int c1=col1 & 15;
    c1=(c1>>1) + ((c1 & 1) << 3);
    int c2=(col1 >> 4) & 15;
    c2=(c2>>1) + ((c2 & 1) << 3);
    return (c1<<4) + c2;
}

-(void) convChr6912:(Byte*)byteData {
    Byte * newData=(Byte*)malloc(6912);
    NSUInteger src=7;
    for(int ch=0; ch<768; ch++) {
        NSUInteger adrpix=(ch>>8)*2048 + (ch&255);
        NSUInteger adratr=6144+ch;
        for(int i=0; i<8; i++) {
            newData[adrpix+i*256]=byteData[src++];
        }
        newData[adratr]=byteData[src++];
    }
    memcpy(byteData, newData, 6912);
    free(newData);

}


-(void) convChr2Img:(Byte*)byteData {
    Byte * newData=(Byte*)malloc(6912*2);
    NSUInteger src=7;
    for(int ch=0; ch<768; ch++) {
        NSUInteger adrpix=(ch>>8)*2048 + (ch&255);
        NSUInteger adratr=6144+ch;
        for(int i=0; i<8; i++) {
            newData[adrpix+i*256]=byteData[src++];
        }
        newData[adratr]=byteData[src++];
        for(int i=0; i<8; i++) {
            newData[6912+adrpix+i*256]=byteData[src++];
        }
        newData[6912+adratr]=byteData[src++];
    }
    memcpy(byteData, newData, 6912*2);
    free(newData);
}


-(int) convChr2Mgx:(Byte*)byteData mode:(NSUInteger)chMode{
    int atrInCh=2;
    int mode=4;
    int shift=1536;
    if(chMode==24) mode=8, atrInCh=4, shift=3072;
    int len=256+12288+(768*mode);
    Byte * newData=(Byte*)malloc(len);
    newData[0]='M'; // signature
    newData[1]='G';
    newData[2]='H';
    newData[3]=1; // version
    newData[4]=chMode > 21 ? 2 : 4; // char size
    newData[5]=0; // border 1
    newData[6]=0; // border 2
    
    for(int ch=0; ch<768; ch++) {
        NSUInteger adrpix=256 + (ch>>8)*2048 + (ch&255);
        NSUInteger atradr=256 + 12288 + (ch&0x3e0)*atrInCh + (ch&31);
        NSUInteger src=7 + ch*chMode;
        for(int i=0; i<8; i++) {
            newData[adrpix + i*256]=byteData[src + i];
            newData[adrpix + 6144 + i*256]=byteData[src + i + chMode/2];
        }
        for(int a=0; a<atrInCh; a++) {
            newData[atradr + a*32]=byteData[src + 8 + a];
            newData[atradr + a*32 + shift]=byteData[src + 8 + a + chMode/2];
        }
    }
    memcpy(byteData, newData, len);
    free(newData);
    return len;
}


@end;