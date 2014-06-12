//
//  ColorTestViewController.m
//  QuoteSmith
//
//  Created by waffles on 6/7/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "ColorTestViewController.h"
#import "UIColor+Expanded.h"
#import "UIColor+HSV.h"
#import "WordTile.h"

#define ARC4RANDOM_MAX      0x100000000

static float hsvStep = (1.0/360.0);

/*
 void RGBtoHSV(float r, float g, float b, float* h, float* s, float* v);
 void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v );
 
 @interface UIColor (HSV)
 
 * Accepted ranges:
 * hue: 0.0 - 360.0
 * saturation: 0.0 - 1.0
 * value: 0.0 - 1.0
 * alpha: 0.0 - 1.0
 + (UIColor*)colorWithHue:(CGFloat)h saturation:(CGFloat)s value:(CGFloat)v alpha:(CGFloat)a;
 
 */

struct HSV {
    float H;
    float S;
    float V;
};

@interface ColorTestViewController () {
    UIView *v1;
    UIView *v2;
    UIView *v3;

    WordTile *testTile;
    
    float H;
    float S;
    float V;
    float A;
}

@end
@implementation ColorTestViewController

- (float)randomFloat:(float)min maxNumber:(float)max
{
    float range = max - min;
    float val = ((float)arc4random() / ARC4RANDOM_MAX) * range + min;
    int val1 = val * 10;
    float val2= (float)val1 / 10.0f;
    return val2;
}

// update the colors we have generated for v1 and v2
- (IBAction) updateColors :(id)sender
{
    NSLog(@"Trying to update with new colors");
    
    float St = [self randomFloat:50 maxNumber:100];
    float Vt = [self randomFloat:50 maxNumber:100];
    
    H = [self randomFloat:0 maxNumber:360];
    
    S = St/100;
    V = Vt/100;
    
    NSLog(@"H %f S %f V %f", H, S, V);
    
    v1.backgroundColor = [UIColor acolorWithHue:H saturation:S value:V alpha:1.0];
    //testTile.fgColor = [UIColor acolorWithHue:H+80 saturation:S value:V alpha:1.0];
    testTile.fgColor = [UIColor whiteColor];
    S += 0.25;
    V += 0.25;
    H += 137;
    if (H > 360.0) {
        H = H - 360;
    }
    
    v2.backgroundColor = [UIColor acolorWithHue:H saturation:S value:V alpha:1.0];
    testTile.bgColor = [UIColor acolorWithHue:H saturation:S value:V alpha:1.0];
    testTile.customColors = YES;
    [testTile setNeedsLayout];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    H = 0.2;
    S = 0.4;
    V = 1.0;
    
    v1 = [[UIView alloc] initWithFrame:self.view.frame];
    v1.backgroundColor = [UIColor colorWithHue:H saturation:S brightness:V alpha:1.0];
    [self.view addSubview:v1];
    
    v2 = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 128, 128)];
    v2.backgroundColor = [UIColor colorWithHexString:@"00aa00"];
    [self.view addSubview:v2];
    
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithTitle:@"Update" style:UIBarButtonItemStylePlain target:self action:@selector(updateColors:)];
    [[self navigationItem] setRightBarButtonItems:@[updateButton]];
    
    // Create the testing tile. for color experiments
    testTile = [[WordTile alloc] initWithFrame:CGRectMake(0,200,32,32)];
    [testTile setString:@"Anthony"];
    [self.view addSubview:testTile];
}
@end
