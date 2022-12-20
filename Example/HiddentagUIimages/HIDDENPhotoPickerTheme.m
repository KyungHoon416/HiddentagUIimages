//
//  HIDDENPhotoPickerTheme.m
//  HiddentagUIimages_Example
//
//  Created by 경훈's MacBook on 2022/12/04.
//  Copyright © 2022 kimkyunghoon. All rights reserved.
//

#import "HIDDENPhotoPickerTheme.h"

@implementation UIColor(HIDDENPhotoPickerTheme)

+ (UIColor *)systemBlueColor
{
    static UIColor *systemBlueColor = nil;
    if (!systemBlueColor) {
        systemBlueColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    }
    return systemBlueColor;
}

@end

@implementation HIDDENPhotoPickerTheme

+ (instancetype)sharedInstance
{
    static HIDDENPhotoPickerTheme *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[HIDDENPhotoPickerTheme alloc] init];
        [instance reset];
    });
    return instance;
}

- (void)reset
{
    self.tintColor = self.cameraVeilColor = [UIColor blackColor];
    self.orderTintColor = [UIColor systemBlueColor];
    self.orderLabelTextColor = [UIColor whiteColor];
    self.navigationBarBackgroundColor = self.cameraIconColor = [UIColor whiteColor];
    self.titleLabelTextColor = [UIColor blackColor];
    self.statusBarStyle = UIStatusBarStyleDefault;
    self.titleLabelFont = [UIFont systemFontOfSize:18.0];
    self.albumNameLabelFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightLight];
    self.photosCountLabelFont = [UIFont systemFontOfSize:18.0 weight:UIFontWeightLight];
    self.selectionOrderLabelFont = [UIFont systemFontOfSize:17.0];
    
}



@end
