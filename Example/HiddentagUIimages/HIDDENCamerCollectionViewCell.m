//
//  HIDDENCollectionViewCell.m
//  HiddentagUIimages_Example
//
//  Created by 경훈's MacBook on 2022/12/04.
//  Copyright © 2022 kimkyunghoon. All rights reserved.
//

#import "HIDDENCamerCollectionViewCell.h"
#import "HIDDENPhotoPickerTheme.h"

@implementation HIDDENCamerCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.captureVeilView.backgroundColor = [HIDDENPhotoPickerTheme sharedInstance].cameraVeilColor;
    self.cameraImageView.image = [self.cameraImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.cameraImageView.tintColor = [HIDDENPhotoPickerTheme sharedInstance].cameraIconColor;
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.previewLayer.bounds = self.bounds;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    AVCaptureVideoOrientation orientation;

    switch ([UIDevice currentDevice].orientation) {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
            // Accrording the declaration UIDeviceOrientationLandscapeLeft is home button on the right which as same as AVCaptureVideoOrientationLandscapeRight
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
            // Accrording the declaration UIDeviceOrientationLandscapeLeft is home button on the right which as same as AVCaptureVideoOrientationLandscapeRight
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    self.previewLayer.connection.videoOrientation = orientation;
}

- (AVCaptureSession *)session
{
    if ([_session.inputs count] > 0) {
        // Already open camera
        return _session;
    }
    
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];

    if (status == AVAuthorizationStatusNotDetermined) {
        // User didn't authorize the camera permission before, we won't want the app pop-up two alerts(camera and album permission) in the same time.
        return _session;
    }
    
    _session = [[AVCaptureSession alloc] init];
    
    NSError *error = nil;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    // If camera access denied, show full cover
    if ([_session canAddInput:deviceInput] && !error) {
        // This line would let permission choose alert pop-up if it's first time to ask the camera permission
        [_session addInput:deviceInput];
        self.captureVeilView.alpha = 0.5;
        self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
        CGRect bounds = self.bounds;
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.bounds = bounds;
        self.previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        [self.cameraPreviewView.layer addSublayer:self.previewLayer];
    }
    else {
        self.captureVeilView.alpha = 1.0;
    }
    
    return _session;
}
@end
