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

@protocol HIDDENViewControllerDelegate <NSObject>

@required
/**
 * @brief Invoked when view controller finish picking single image from camera or photo album. The picker does not dismiss itself; the client dismisses it in this callback.
 *
 * @param picker The view controller invoking the delegate method.
 * @param image The UIImage object user picked.
 */
- (void)photoPickerViewController:(HIDDENViewController *)picker didFinishPickingImage:(UIImage *)image;


@optional
/**
 * @brief Invoked when user press cancel button. The picker does not dismiss itself; the client dismisses it in this callback.
 *
 * @param picker The view controller invoking the delegate method.
 */
- (void)photoPickerViewControllerDidCancel:(HIDDENViewController *)picker;


@end
