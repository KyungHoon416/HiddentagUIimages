//
//  HIDDENViewController.h
//  HiddentagUIimages
//
//  Created by kimkyunghoon on 12/04/2022.
//  Copyright (c) 2022 kimkyunghoon. All rights reserved.
//

@import UIKit;

@protocol HIDDENViewControllerDelegate;

@interface HIDDENViewController : UIViewController

@property (nonatomic, weak) id<HIDDENViewControllerDelegate> delegate;

@property (nonatomic, assign) NSUInteger numberOfPhotoToSelect;

@property (nonatomic, assign) BOOL shouldReturnImageForSingleSelection;

@end

@protocol YMSPhotoPickerViewControllerDelegate <NSObject>

@required
@optional
@end
