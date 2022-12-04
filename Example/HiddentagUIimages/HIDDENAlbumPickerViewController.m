//
//  HIDDENAlbumPickerViewController.m
//  HiddentagUIimages_Example
//
//  Created by 경훈's MacBook on 2022/12/04.
//  Copyright © 2022 kimkyunghoon. All rights reserved.
//

#import "HIDDENAlbumPickerViewController.h"
#import <Photos/Photos.h>
#import "HIDDENPhotoPickerTheme.h"

@interface HIDDENAlbumPickerViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) void (^dismissalHandler)(NSDictionary *);
@property (nonatomic, strong) NSDictionary *selectedCollectionItem;
@property (nonatomic, strong) NSArray *collectionItems;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, weak) IBOutlet UIView *navigationBarBackgroundView;
@property (nonatomic, weak) IBOutlet UITableView *albumListTableView;
@end

@implementation HIDDENAlbumPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
