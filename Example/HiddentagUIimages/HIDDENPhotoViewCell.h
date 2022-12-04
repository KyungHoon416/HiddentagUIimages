//
//  HIDDENPhotoViewCell.h
//  HiddentagUIimages_Example
//
//  Created by 경훈's MacBook on 2022/12/04.
//  Copyright © 2022 kimkyunghoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

//NS_ASSUME_NONNULL_BEGIN

@interface HIDDENPhotoViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet UILabel *selectionOrderLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIView *selectionVeil;

@property (nonatomic, weak) PHImageManager *imageManager;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, assign) BOOL animateSelection;
@property (nonatomic, strong) UIImage *thumbnailImage;

/**
 * @brief It is the identifier for photo picker to display single photo in current album.
 *
 */
@property (nonatomic, strong) NSString *representedAssetIdentifier;

/**
 * @brief Set target method to this to recognize long press gesture.
 *
 */
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

/**
 * @brief Set selection order to this to display on UILabel.
 *
 */
@property (nonatomic, assign) NSUInteger selectionOrder;

/**
 * @brief Load the photo from photo library and display it on cell.
 *
 * @param manager Reuse current image manager from photo picker.
 * @param asset The photo image asset.
 * @param size The target photo size.
 */
- (void)loadPhotoWithManager:(PHImageManager *)manager forAsset:(PHAsset *)asset targetSize:(CGSize)size;


/**
 * @brief Set this to make cell will animate when it has been selected.
 *
 */
- (void)setNeedsAnimateSelection;

/**
 * @brief Display highlighted and unhighlighted animation.
 *
 * @param highlighted The animation type for highlighted and unhighlighted.
 */
- (void)animateHighlight:(BOOL)highlighted;
@end

//NS_ASSUME_NONNULL_END
