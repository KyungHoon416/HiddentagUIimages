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
#import "HIDDENPhotoPickerTheme.h"
#import <MobileCoreServices/MobileCoreServices.h>

static NSString * const HIDDENCamerCollectionViewCellNibName = @"HIDDENCamerCollectionViewCell";
static NSString * const HIDDENPhotoViewCellNibName = @"HIDDENPhotoViewCell";
static const NSUInteger HIDDENNumberOfPhotoColumns = 3;
static const CGFloat HIDDENPhotoFetchScaleResizingRatio = 0.75;

@interface HIDDENViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
    NSArray *myList;
    BOOL tapped;
}


@property (nonatomic, strong) NSDictionary *selectedCollectionItem;
@property (nonatomic, weak) IBOutlet UIView *navigationBarBackgroundView;
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
@property (weak, nonatomic) IBOutlet UIButton *Advertising;
@property (weak, nonatomic) IBOutlet UITableView *categoryTableView;
@property (weak, nonatomic) IBOutlet UIImageView *ImageShow;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *imageZoomInOut;
- (IBAction)imageZoomInOutAction:(id)sender;
//@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;


@property (weak, nonatomic) IBOutlet UIButton *upload_Video;
- (IBAction)upload_VideoAction:(id)sender;

- (IBAction)categoryAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *categoryBtn;

- (IBAction)presentSinglePhoto:(id)sender;

- (IBAction)presentAlbumPickerView:(id)sender;
- (IBAction)finishPickingPhotos:(id)sender;
- (void)updateViewWithCollectionItem:(NSDictionary *)collectionItem;
- (IBAction)dismiss:(id)sender;
- (void)setupCellSize;
- (void)refreshPhotoSelection;
- (void)fetchCollections;
- (BOOL)allowsMultipleSelection;
- (BOOL)canAddPhoto;

@end

@implementation HIDDENViewController

- (instancetype)init
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        self.selectedPhotos = [NSMutableArray array];
        self.numberOfPhotoToSelect = 0;
        self.shouldReturnImageForSingleSelection = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1.0f;
    self.scrollView.maximumZoomScale = 10.0f;
    self.scrollView.zoomScale = 1.0f;
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    self.navigationController.navigationBar.tintColor = self.view.tintColor;
    self.categoryTableView.hidden = YES;
    self.categoryTableView.delegate = self;
    self.categoryTableView.dataSource = self;
    myList = [[NSArray alloc]initWithObjects:@"Obj-C",@"Swift",@"Python",@"Perl",@"Ruby",@"PHP",@"HTML",@"Switf", nil];
    
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:HIDDENCamerCollectionViewCellNibName bundle:[NSBundle bundleForClass:HIDDENCamerCollectionViewCell.class]];
    [self.photoCollectionView registerNib:cellNib forCellWithReuseIdentifier:HIDDENCamerCollectionViewCellNibName];
    cellNib = [UINib nibWithNibName:HIDDENPhotoViewCellNibName bundle:[NSBundle bundleForClass:HIDDENPhotoViewCell.class]];
    [self.photoCollectionView registerNib:cellNib forCellWithReuseIdentifier:HIDDENPhotoViewCellNibName];
    self.photoCollectionView.allowsMultipleSelection = self.allowsMultipleSelection;
    
    
    [self fetchCollections];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];

    if (self.allowsMultipleSelection) {
        // Add done button for multiple selections
        self.doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(finishPickingPhotos:)];
        self.doneItem.enabled = NO;
        navigationItem.rightBarButtonItem = self.doneItem;
        
    }

    self.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem;

    if (![self.theme.navigationBarBackgroundColor isEqual:[UIColor whiteColor]]) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        self.navigationBarBackgroundView.backgroundColor = self.theme.navigationBarBackgroundColor;
    }
    [self updateViewWithCollectionItem:[self.collectionItems firstObject]];

    self.cellPortraitSize = self.cellLandscapeSize = CGSizeZero;
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchCollections
{
    NSMutableArray *allAblums = [NSMutableArray array];

    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];

    __block __weak void (^weakFetchAlbums)(PHFetchResult *collections);
    void (^fetchAlbums)(PHFetchResult *collections);
    weakFetchAlbums = fetchAlbums = ^void(PHFetchResult *collections) {
        // create fecth options
        PHFetchOptions *options = [PHFetchOptions new];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType = %d",PHAssetMediaTypeImage,PHAssetMediaTypeVideo];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

        for (PHCollection *collection in collections) {
            if ([collection isKindOfClass:[PHAssetCollection class]]) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if (assetsFetchResult.count > 0) {
                    [allAblums addObject:@{@"collection": assetCollection
                                           , @"assets": assetsFetchResult}];
                }
            }
            else if ([collection isKindOfClass:[PHCollectionList class]]) {
                // If there are more sub-folders, dig into the collection to fetch the albums
                PHCollectionList *collectionList = (PHCollectionList *)collection;
                PHFetchResult *fetchResult = [PHCollectionList fetchCollectionsInCollectionList:(PHCollectionList *)collectionList options:nil];
                weakFetchAlbums(fetchResult);
            }
        }
    };

    PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    fetchAlbums(topLevelUserCollections);

    for (PHAssetCollection *collection in smartAlbums) {
        PHFetchOptions *options = [PHFetchOptions new];
//        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d || mediaType = %d",PHAssetMediaTypeImage,PHAssetMediaTypeVideo];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];

        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        if (assetsFetchResult.count > 0) {

            // put the "all photos" in the first index
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                [allAblums insertObject:@{@"collection": collection
                                          , @"assets": assetsFetchResult} atIndex:0];
            }
            else {
                [allAblums addObject:@{@"collection": collection
                                       , @"assets": assetsFetchResult}];
            }
        }
    }
    self.collectionItems = [allAblums copy];
}

#pragma mark - Privates

- (BOOL)allowsMultipleSelection
{
    return (self.numberOfPhotoToSelect != 1);
}


- (void)updateViewWithCollectionItem:(NSDictionary *)collectionItem
{
    self.currentCollectionItem = collectionItem;
    PHCollection *photoCollection = self.currentCollectionItem[@"collection"];
    
    UIButton *albumButton = [UIButton buttonWithType:UIButtonTypeSystem];
    albumButton.tintColor = self.theme.titleLabelTextColor;
    albumButton.titleLabel.font = self.theme.titleLabelFont;
    [albumButton addTarget:self action:@selector(presentAlbumPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [albumButton setTitle:photoCollection.localizedTitle forState:UIControlStateNormal];
    UIImage *arrowDownImage = [UIImage imageNamed:@"_" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    arrowDownImage = [arrowDownImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [albumButton setImage:arrowDownImage forState:UIControlStateNormal];
    [albumButton sizeToFit];
    albumButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, albumButton.frame.size.width - (arrowDownImage.size.width) + 100, 0.0, 0.0);
    albumButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, -arrowDownImage.size.width, 0.0, arrowDownImage.size.width + 100);
    // width + 10 for the space between text and image
    albumButton.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(albumButton.bounds) + 100, CGRectGetHeight(albumButton.bounds));
    
    self.navigationItem.titleView = albumButton;

    [self.photoCollectionView reloadData];
    [self refreshPhotoSelection];
}

- (UIImage *)yms_orientationNormalizedImage:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp) return image;

    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    [image drawInRect:CGRectMake(0.0, 0.0, image.size.width, image.size.height)];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
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

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Check if there are changes to the assets we are showing.
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult:fetchResult];
    if (collectionChanges == nil) {

        [self fetchCollections];

        if (self.needToSelectFirstPhoto) {
            self.needToSelectFirstPhoto = NO;

            fetchResult = [self.collectionItems firstObject][@"assets"];
            PHAsset *asset = [fetchResult firstObject];
            [self.selectedPhotos addObject:asset];
            self.doneItem.enabled = YES;
        }

        return;
    }
    
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Get the new fetch result.
        PHFetchResult *fetchResult = [collectionChanges fetchResultAfterChanges];
        NSLog(@"photoLibraryDidChange collectionItems : %@",self.collectionItems);
        NSLog(@"photoLibraryDidChange currentCollectionItem : %@",self.currentCollectionItem);
        NSInteger index = [self.collectionItems indexOfObject:self.currentCollectionItem];
        self.currentCollectionItem = @{
                                       @"assets": fetchResult,
                                       @"collection": self.currentCollectionItem[@"collection"]
                                       };
        if (index != NSNotFound) {
            NSMutableArray *updatedCollectionItems = [self.collectionItems mutableCopy];
            [updatedCollectionItems replaceObjectAtIndex:index withObject:self.currentCollectionItem];
            self.collectionItems = [updatedCollectionItems copy];
        }
        UICollectionView *collectionView = self.photoCollectionView;
        
        if (![collectionChanges hasIncrementalChanges] || [collectionChanges hasMoves]
            || ([collectionChanges removedIndexes].count > 0
                && [collectionChanges changedIndexes].count > 0)) {
            // Reload the collection view if the incremental diffs are not available
            [collectionView reloadData];
        }
        else {
            /*
             Tell the collection view to animate insertions and deletions if we
             have incremental diffs.
             */
            [collectionView performBatchUpdates:^{
                
                NSIndexSet *removedIndexes = [collectionChanges removedIndexes];
                NSMutableArray *removeIndexPaths = [NSMutableArray arrayWithCapacity:removedIndexes.count];
                [removedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [removeIndexPaths addObject:[NSIndexPath indexPathForItem:idx+1 inSection:0]];
                }];
                if ([removedIndexes count] > 0) {
                    [collectionView deleteItemsAtIndexPaths:removeIndexPaths];
                }
                
                NSIndexSet *insertedIndexes = [collectionChanges insertedIndexes];
                NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:insertedIndexes.count];
                [insertedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [insertIndexPaths addObject:[NSIndexPath indexPathForItem:idx+1 inSection:0]];
                }];
                if ([insertedIndexes count] > 0) {
                    [collectionView insertItemsAtIndexPaths:insertIndexPaths];
                }
                
                NSIndexSet *changedIndexes = [collectionChanges changedIndexes];
                NSMutableArray *changedIndexPaths = [NSMutableArray arrayWithCapacity:changedIndexes.count];
                [changedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:0];
                    if (![removeIndexPaths containsObject:indexPath]) {
                        // In case reload selected cell, they were didSelected and re-select. Ignore them to prevent weird transition.
                        if (self.needToSelectFirstPhoto) {
                            if (![collectionView.indexPathsForSelectedItems containsObject:indexPath]) {
                                [changedIndexPaths addObject:indexPath];
                            }
                        }
                        else {
                            [changedIndexPaths addObject:indexPath];
                        }
                    }
                }];
                if ([changedIndexes count] > 0) {
                    [collectionView reloadItemsAtIndexPaths:changedIndexPaths];
                }
            } completion:^(BOOL finished) {
                if (self.needToSelectFirstPhoto) {
                    self.needToSelectFirstPhoto = NO;

                    PHAsset *asset = [fetchResult firstObject];
                    [self.selectedPhotos addObject:asset];
                    self.doneItem.enabled = YES;
                }
                [self refreshPhotoSelection];
            }];
        }
    });
}

- (void)refreshPhotoSelection
{
    PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
    NSUInteger selectionNumber = self.selectedPhotos.count;

    for (int i=0; i<fetchResult.count; i++) {
        PHAsset *asset = [fetchResult objectAtIndex:i];
        if ([self.selectedPhotos containsObject:asset]) {

            // Display selection
            [self.photoCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:i+1 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
            HIDDENPhotoViewCell *cell = (HIDDENPhotoViewCell *)[self.photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i+1 inSection:0]];
            cell.selectionOrder = [self.selectedPhotos indexOfObject:asset]+1;

            selectionNumber--;
            if (selectionNumber == 0) {
                break;
            }
        }
    }
}

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
        PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
        
        PHAsset *asset = fetchResult[indexPath.item-1];
        
        HIDDENPhotoViewCell *photoCell = (HIDDENPhotoViewCell *)cell;
        
        [photoCell setNeedsAnimateSelection];
        
        CGFloat scale = [UIScreen mainScreen].scale * HIDDENPhotoFetchScaleResizingRatio;
        CGSize imageSize = CGSizeMake(CGRectGetWidth(photoCell.frame) * scale, CGRectGetHeight(photoCell.frame) * scale);
        
//        photoCell.selectionOrder = self.selectedPhotos.count+1;
        photoCell.selectionOrder = photoCell.selectionOrder +1;
//        [photoCell loadPhotoWithManager:self.imageManager forAsset:asset targetSize:imageSize];
//        PHAssetResource
//        self.ImageShow.image = [UIImage imageWithData:asset];
        
        NSLog(@"photoCell.selectionOrder : %lu",(unsigned long)photoCell.selectionOrder);
        NSLog(@"photoCell.fetchResult : %@",fetchResult);
        NSLog(@"photoCell.asset : %@",asset);
        NSLog(@"photoCell.selectedPhotos : %lu",(unsigned long)self.selectedPhotos.count);
        
        [self PHAssetToUIImage:asset];
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
    NSLog(@"didDeselectItemAtIndexPath indexPath.row : %ld",(long)indexPath.row);
    if (indexPath.item == 0) {
        NSLog(@"indexPath.item == 0");
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //미디어 타입: 이미지, 영상
        picker.mediaTypes = [NSArray arrayWithObjects:
                                      (NSString *) kUTTypeImage,
                                      (NSString *) kUTTypeMovie,nil];
        [self presentViewController:picker animated:YES completion:nil];
        
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
//        photoCell.selectionOrder = cell.selectionOrder +1;
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
    NSLog(@"fetchResult : %@",fetchResult);
    return fetchResult.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"indexPath : %ld",(long)indexPath.row);
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
//    photoCell.representedAssetIdentifier = asset.mediaType;
//    asset.mediaType  = PHAssetMediaTypeUnknown;
    CGFloat scale = [UIScreen mainScreen].scale * HIDDENPhotoFetchScaleResizingRatio;
    CGSize imageSize = CGSizeMake(CGRectGetWidth(photoCell.frame) * scale, CGRectGetHeight(photoCell.frame) * scale);
    
    NSLog(@"imageSize %@",NSStringFromCGSize(imageSize));
    NSLog(@"collectionView asset %@",asset);
    NSLog(@"collectionView fetchResult %@",fetchResult);

    
    [photoCell loadPhotoWithManager:self.imageManager forAsset:asset targetSize:imageSize];

//    [photoCell.longPressGestureRecognizer addTarget:self action:@selector(presentSinglePhoto:)];

    if ([self.selectedPhotos containsObject:asset]) {
        NSUInteger selectionIndex = [self.selectedPhotos indexOfObject:asset];
        photoCell.selectionOrder = selectionIndex+1;
    }

    return photoCell;
}

-(void)PHAssetToUIImage:(PHAsset *)asset{
    NSLog(@"PHAssetToUIImage asset : %@",asset);
    
  
//    imageManager
    _imageManager = [[PHImageManager alloc] init];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.networkAccessAllowed = YES;
    options.version = PHImageRequestOptionsVersionOriginal;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.synchronous = YES;
    
    NSLog(@"PHAssetToUIImage imageManager : %@",_imageManager);
    NSLog(@"PHAssetToUIImage options : %@",options);
    
  
    CGSize targetSize = CGSizeMake(CGRectGetWidth(self.ImageShow.bounds), CGRectGetHeight(self.ImageShow.bounds) );
    NSLog(@"targetSize : %@",NSStringFromCGSize(targetSize));
    if(asset.mediaType == 1){
        [_imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *image, NSDictionary *info) {
            
            //        image = [info objectForKey:UIImagePickerControllerOriginalImage];
            //        NSData *data = UIImagePNGRepresentation(_imageManager);
            //        NSLog(@"PHAssetToUIImage data : %@",data);
            NSLog(@"PHAssetToUIImage image : %@",image);
            NSLog(@"PHAssetToUIImage image.size.width, image.size.height : %.1f,%.1f",image.size.width,image.size.height);
            
            
            NSLog(@"사진입니다.");
            self.ImageShow.image = image;
//            self.scrollView.minimumZoomScale = 5.0;
//            self.ImageShow.min
            
            
            
            
        }];
    }
    else {
        NSLog(@"동영상입니다.");
    
    }
}

//- (IBAction)presentSinglePhoto:(id)sender
//{
//    if ([sender isKindOfClass:[UILongPressGestureRecognizer class]]) {
//        UILongPressGestureRecognizer *gesture = sender;
//        if (gesture.state != UIGestureRecognizerStateBegan) {
//            return;
//        }
//        NSIndexPath *indexPath = [self.photoCollectionView indexPathForCell:(HIDDENPhotoViewCell *)gesture.view];
//
//        PHFetchResult *fetchResult = self.currentCollectionItem[@"assets"];
//
//        PHAsset *asset = fetchResult[indexPath.item-1];
//
//        HIDDENViewController *presentedViewController = [[HIDDENViewController alloc] initWithPhotoAsset:asset imageManager:self.imageManager dismissalHandler:^(BOOL selected) {
//            if (selected && [self collectionView:self.photoCollectionView shouldSelectItemAtIndexPath:indexPath]) {
//                [self.photoCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//                [self collectionView:self.photoCollectionView didSelectItemAtIndexPath:indexPath];
//            }
//        }];
//
//        YMSNavigationController *navigationController = [[YMSNavigationController alloc] initWithRootViewController:presentedViewController];
//
//        navigationController.view.tintColor = presentedViewController.view.tintColor = self.theme.tintColor;
//
//        [self presentViewController:navigationController animated:YES completion:nil];
//    }
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    
    cell.textLabel.text = [myList objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[myList objectAtIndex:indexPath.row] forKey:@"item"];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"selectedListItem"
         object:self userInfo:dictionary];
   
     [self.view removeFromSuperview];
}


- (IBAction)categoryAction:(id)sender {
    self.categoryTableView.hidden = NO;
    
}

- (IBAction)upload_VideoAction:(id)sender {
    // Present videos from which to choose
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //미디어 타입: 이미지, 영상
    picker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  (NSString *) kUTTypeMovie,nil];
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)imageZoomInOutAction:(id)sender {
    if (!tapped) {
//            CGPoint tapPoint = [self.tapGesture locationOfTouch:0 inView:self.tapGesture.view];
//            CGRect zoomRect = [self zoomRectForScrollView:self.scrollView withScale:6.0f withCenter:tapPoint];
            [self.scrollView setZoomScale:1.0f animated:YES];
            tapped = YES;
    } else {
        [self.scrollView setZoomScale:2.0f animated:YES];
        tapped = NO;
    }
//    self.scrollView.minimumZoomScale = 0.1;
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _ImageShow;
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView withScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = scrollView.frame.size.height / scale;
    zoomRect.size.width = scrollView.frame.size.width / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

@end
