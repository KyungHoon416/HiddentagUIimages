//
//  HIDDENCollectionViewCell.h
//  HiddentagUIimages_Example
//
//  Created by 경훈's MacBook on 2022/12/04.
//  Copyright © 2022 kimkyunghoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
//NS_ASSUME_NONNULL_BEGIN

@interface HIDDENCamerCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, weak) IBOutlet UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, weak) IBOutlet UIView *captureVeilView;
@property (nonatomic, weak) IBOutlet UIImageView *cameraImageView;

@end

//NS_ASSUME_NONNULL_END
