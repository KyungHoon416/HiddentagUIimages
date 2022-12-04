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

@end

//NS_ASSUME_NONNULL_END
