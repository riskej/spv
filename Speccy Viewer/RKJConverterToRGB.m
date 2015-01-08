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

@synthesize mode_scr;
@synthesize FinallyProcessedImage;
@synthesize FinallyProcessedImage2;
@synthesize FinallyProcessedImage_giga;
@synthesize BorderColor1;
@synthesize BorderColor2;

//#define Mask8(x) ( (x) & 0xFF )
//#define RGBAMake(r, g, b, a) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 | Mask8(a) << 24 )
//#define RGBMake(r, g, b) ( Mask8(r) | Mask8(g) << 8 | Mask8(b) << 16 )
//#define BlackColor = 0;

- (void) openZX_scr6144:(NSData*)datafile {
    
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
                
                NSUInteger byte = byteData[shiftPixelAdress + xchar];
                
                for (int xBit=128;xBit>0; xBit/=2) {
                    *inputPixel++ = byte & xBit ? 0xffffff : 0;
                    *inputPixel++ = byte & xBit ? 0xffffff : 0;
                }
                
                
            }
            
        }
    }
    //
    
    
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
    
    UInt32 * inputPixels;
    
    NSUInteger colorPalettePulsar [16] = {0x0, 0xca0000, 0x0000ca, 0xca00ca, 0x00ca00, 0xcaca00, 0x00caca, 0xcacaca,
        0x0, 0xfe0000, 0x0000fe, 0xfe00fe, 0x00fe00, 0xfefe00, 0x00fefe, 0xfefefe};
    
    NSUInteger inputWidth = 256*2;
    NSUInteger inputHeight = 192*2;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    
    NSUInteger inputBytesPerRow = bytesPerPixel * inputWidth;
    
    inputPixels = (UInt32 *)calloc(inputHeight * inputWidth, sizeof(UInt32));
    
    //    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString :@"https://dl.dropboxusercontent.com/u/36464659/_apptest/nday6144.scr"]];
    
    //    NSData *data = [NSData dataWithContentsOfFile:@"/Users/riskej/Documents/Developing/SpecViewT1/Files/nday6144.scr"];
    
    NSData *data = datafile;
    
    NSUInteger len = [data length];
    Byte *byteData = (Byte*)malloc(len);
    memcpy(byteData, [data bytes], len);
    
    
    // Draw Screen
    
    NSUInteger firstByteOfPixelArrayOfFirstScreen = 0;
    NSUInteger firstByteOfCharsArrayOfFirstScreen = 6144;
    
    for (NSUInteger yRetina = 0; yRetina < 2; yRetina++) {
        
        for (int line=0; line<192; line++) {
            
            [self calculateAddressForPixel:line andMode:mode_scr];
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                
                NSUInteger byte = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
                NSUInteger atr= byteData[firstByteOfCharsArrayOfFirstScreen + shiftZxcharAdress + xchar];
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                
                
                for (int xBit=128;xBit>0; xBit/=2) {
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
    
    free(inputPixels);
    
    UIImage * processedImage = [UIImage imageWithCGImage:newCGImage];
    FinallyProcessedImage = processedImage;
    
    free(byteData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newCGImage);
    CGContextRelease(context);
    
}


- (void) openZX_img_mgX:(NSData*)datafile {
    
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
    
    // modes =  1 - 6144
    //          2 - 6912
    //          3 - img(gsc)
    //          4 - mg8
    //          5 - mg4
    //          6 - mg2
    //          7 – mg1
    //          8 - mc
    
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
    
    if (mode_scr==7) {
        firstByteOfPixelArrayOfFirstScreen = 256+0;
        firstByteOfPixelArrayOfSecondScreen = 256+6144;
        firstByteOfCharsArrayOfFirstScreen = 256+6144*2;
        firstByteOfCharsArrayOfSecondScreen = 256+6144*2+3072;
    }
    
    for (NSUInteger yRetina = 0; yRetina < 2; yRetina++) {
        
        for (int line=0; line<192; line++) {
            
            [self calculateAddressForPixel:line andMode:mode_scr];
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                
                NSUInteger byte = byteData[firstByteOfPixelArrayOfFirstScreen + shiftPixelAdress + xchar];
                NSUInteger atr= byteData[firstByteOfCharsArrayOfFirstScreen + shiftZxcharAdress + xchar];
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                
                
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
            
            for (int xchar=0; xchar<32; xchar++) {
                
                UInt32 * inputPixel = inputPixels + (line * 2 + yRetina) * 512 + (xchar*16);
                
                NSUInteger byte = byteData[firstByteOfPixelArrayOfSecondScreen + shiftPixelAdress + xchar];
                NSUInteger atr= byteData[firstByteOfCharsArrayOfSecondScreen + shiftZxcharAdress + xchar];
                NSUInteger bright = atr & 64 ? 8 : 0;
                NSUInteger ink=(UInt32)colorPalettePulsar [(atr & 7) + bright];
                NSUInteger paper=(UInt32)colorPalettePulsar [(atr >> 3) & 7 + bright];
                
                
                for (int xBit=128;xBit>0; xBit/=2) {
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
}

@end