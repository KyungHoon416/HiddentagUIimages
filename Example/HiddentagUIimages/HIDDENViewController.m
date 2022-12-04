//
//  HIDDENViewController.m
//  HiddentagUIimages
//
//  Created by kimkyunghoon on 12/04/2022.
//  Copyright (c) 2022 kimkyunghoon. All rights reserved.
//

#import "HIDDENViewController.h"
#import <Photos/Photos.h>
#import "HIDDENCamerCollectionViewCell.h"
#import "HIDDENPhotoViewCell.h"

static NSString * const HIDDENCamerCollectionViewCellNibName = @"HIDDENCamerCollectionViewCell";
static NSString * const HIDDENPhotoViewCellNibName = @"HIDDENPhotoViewCell";
static const NSUInteger HIDDENNumberOfPhotoColumns = 3;
static const CGFloat HIDDENPhotoFetchScaleResizingRatio = 0.75;

@interface HIDDENViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver>


@property (nonatomic, strong) NSDictionary *selectedCollectionItem;
@property (nonatomic, strong) NSArray *collectionItems;
@property (weak, nonatomic) IBOutlet UICollectionView *photoCollectionView;
@property (nonatomic, strong) PHImageManager *imageManager;
@property (nonatomic, weak) AVCaptureSession *session;
@property (nonatomic, strong) NSDictionary *currentCollectionItem;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@end

@implementation HIDDENViewController

- (instancetype)init
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        self.selectedPhotos = [NSMutableArray array];
        self.numberOfPhotoToSelect = 1;
        self.shouldReturnImageForSingleSelection = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
