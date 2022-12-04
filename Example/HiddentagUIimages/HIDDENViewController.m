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
@property (nonatomic, assign) BOOL needToSelectFirstPhoto;
@property (nonatomic, assign) CGSize cellPortraitSize;
@property (nonatomic, assign) CGSize cellLandscapeSize;
@property (nonatomic, strong) UIBarButtonItem *doneItem;

- (IBAction)dismiss:(id)sender;
- (void)setupCellSize;

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
    
    self.navigationController.navigationBar.tintColor = self.view.tintColor;
    
    
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:HIDDENCamerCollectionViewCellNibName bundle:[NSBundle bundleForClass:HIDDENCamerCollectionViewCell.class]];
    [self.photoCollectionView registerNib:cellNib forCellWithReuseIdentifier:HIDDENCamerCollectionViewCellNibName];
    cellNib = [UINib nibWithNibName:HIDDENPhotoViewCellNibName bundle:[NSBundle bundleForClass:HIDDENPhotoViewCell.class]];
    [self.photoCollectionView registerNib:cellNib forCellWithReuseIdentifier:HIDDENPhotoViewCellNibName];
    self.photoCollectionView.allowsMultipleSelection = self.allowsMultipleSelection;
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Privates

- (BOOL)allowsMultipleSelection
{
    return (self.numberOfPhotoToSelect != 1);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{

        // Enable camera preview when user allow it first time
        if (![self.session isRunning]) {
            [self.photoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        }

        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (![image isKindOfClass:[UIImage class]]) {
            return;
        }

        // Save the image to Photo Album
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollection *collection = self.currentCollectionItem[@"collection"];
            if (collection.assetCollectionType == PHAssetCollectionTypeSmartAlbum) {
                // Cannot save to smart albums other than "all photos", pick it and dismiss
                [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            }
            else {
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                PHObjectPlaceholder *placeholder = [assetRequest placeholderForCreatedAsset];
                PHAssetCollectionChangeRequest *albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection assets:self.currentCollectionItem[@"assets"]];
                [albumChangeRequest addAssets:@[placeholder]];
            }
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                self.needToSelectFirstPhoto = YES;
            }

            if (!self.allowsMultipleSelection) {
                if ([self.delegate respondsToSelector:@selector(photoPickerViewController:didFinishPickingImage:)]) {
                    [self.delegate photoPickerViewController:self didFinishPickingImage:image];
                }
                else {
                    [self dismiss:nil];
                }
            }
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^(){
        [self.photoCollectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO];

        // Enable camera preview when user allow it first time
        if (![self.session isRunning]) {
            [self.photoCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:0]]];
        }
    }];
}

#pragma mark - IBActions

- (IBAction)dismiss:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(photoPickerViewControllerDidCancel:)]) {
        [self.delegate photoPickerViewControllerDidCancel:self];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


#pragma mark - PHPhotoLibraryChangeObserver
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[HIDDENPhotoViewCell class]]) {
        [(HIDDENPhotoViewCell *)cell animateHighlight:YES];
    }
}

- (BOOL)canAddPhoto
{
    return (self.selectedPhotos.count < self.numberOfPhotoToSelect
            || self.numberOfPhotoToSelect == 0);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (!self.canAddPhoto
        || cell.isSelected) {
        return NO;
    }
    if ([cell isKindOfClass:[HIDDENPhotoViewCell class]]) {
        HIDDENPhotoViewCell *photoCell = (HIDDENPhotoViewCell *)cell;
        [photoCell setNeedsAnimateSelection];
        photoCell.selectionOrder = self.selectedPhotos.count+1;
    }
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (CGSizeEqualToSize(CGSizeZero, self.cellPortraitSize)
        || CGSizeEqualToSize(CGSizeZero, self.cellLandscapeSize)) {
        [self setupCellSize];
    }

    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft
        || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        return self.cellLandscapeSize;
    }
    return self.cellPortraitSize;
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == 0) {
        // Camera cell doesn't need to be deselected
        return;
    }
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    PHAsset *asset = fetchResult[indexPath.item-1];

    NSUInteger removedIndex = [self.selectedPhotos indexOfObject:asset];

    // Reload order higher than removed cell
    for (NSInteger i=removedIndex+1; i<self.selectedPhotos.count; i++) {
        PHAsset *needReloadAsset = self.selectedPhotos[i];
        HIDDENPhotoViewCell *cell = (HIDDENPhotoViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[fetchResult indexOfObject:needReloadAsset]+1 inSection:indexPath.section]];
        cell.selectionOrder = cell.selectionOrder-1;
    }

    [self.selectedPhotos removeObject:asset];
    if (self.selectedPhotos.count == 0) {
        self.doneItem.enabled = NO;
    }
}

- (void)setupCellSize
{
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.photoCollectionView.collectionViewLayout;

    // Fetch shorter length
    CGFloat arrangementLength = MIN(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));

    CGFloat minimumInteritemSpacing = layout.minimumInteritemSpacing;
    UIEdgeInsets sectionInset = layout.sectionInset;

    CGFloat totalInteritemSpacing = MAX((HIDDENNumberOfPhotoColumns - 1), 0) * minimumInteritemSpacing;
    CGFloat totalHorizontalSpacing = totalInteritemSpacing + sectionInset.left + sectionInset.right;

    // Caculate size for portrait mode
    CGFloat size = (CGFloat)floor((arrangementLength - totalHorizontalSpacing) / HIDDENNumberOfPhotoColumns);
    self.cellPortraitSize = CGSizeMake(size, size);

    // Caculate size for landsacpe mode
    arrangementLength = MAX(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    NSUInteger numberOfPhotoColumnsInLandscape = (arrangementLength - sectionInset.left + sectionInset.right)/size;
    totalInteritemSpacing = MAX((numberOfPhotoColumnsInLandscape - 1), 0) * minimumInteritemSpacing;
    totalHorizontalSpacing = totalInteritemSpacing + sectionInset.left + sectionInset.right;
    size = (CGFloat)floor((arrangementLength - totalHorizontalSpacing) / numberOfPhotoColumnsInLandscape);
    self.cellLandscapeSize = CGSizeMake(size, size);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // +1 for camera cell
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    
    return fetchResult.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {   // Camera Cell
        HIDDENCamerCollectionViewCell *cameraCell = [collectionView dequeueReusableCellWithReuseIdentifier:HIDDENCamerCollectionViewCellNibName forIndexPath:indexPath];

        self.session = cameraCell.session;
        
        if (![self.session isRunning]) {
            [self.session startRunning];
        }
        
        return cameraCell;
    }
    
    HIDDENPhotoViewCell *photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:HIDDENPhotoViewCellNibName forIndexPath:indexPath];

    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    
    PHAsset *asset = fetchResult[indexPath.item-1];
    photoCell.representedAssetIdentifier = asset.localIdentifier;
    
    CGFloat scale = [UIScreen mainScreen].scale * HIDDENPhotoFetchScaleResizingRatio;
    CGSize imageSize = CGSizeMake(CGRectGetWidth(photoCell.frame) * scale, CGRectGetHeight(photoCell.frame) * scale);
    
    [photoCell loadPhotoWithManager:self.imageManager forAsset:asset targetSize:imageSize];

    [photoCell.longPressGestureRecognizer addTarget:self action:@selector(presentSinglePhoto:)];

    if ([self.selectedPhotos containsObject:asset]) {
        NSUInteger selectionIndex = [self.selectedPhotos indexOfObject:asset];
        photoCell.selectionOrder = selectionIndex+1;
    }

    return photoCell;
}

@end
