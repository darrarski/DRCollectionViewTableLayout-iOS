//
//  DRViewController.m
//  DRCollectionViewTableLayoutDemo
//
//  Created by Dariusz Rybicki on 08.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import "DRViewController.h"
#import "DRCollectionViewTableLayout.h"

static NSString *CollectionViewCellIdentifier = @"Cell";

@interface DRViewController () <UICollectionViewDataSource, DRCollectionViewTableLayoutDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation DRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    DRCollectionViewTableLayout *collectionViewLayout = [[DRCollectionViewTableLayout alloc] initWithDelegate:self];
    collectionViewLayout.horizontalSpacing = 5.f;
    collectionViewLayout.verticalSpacing = 5.f;
    self.collectionView.collectionViewLayout = collectionViewLayout;
    self.collectionView.dataSource = self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if (section == 0) {
		return 25;
	}
    else if (section == 1) {
        return 16;
    }
	
	return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
	
	CGFloat(^randomFloat)(CGFloat, CGFloat) = ^CGFloat(CGFloat min, CGFloat max) {
		return min + ((float)rand() / RAND_MAX) * max;
	};
	
	cell.contentView.backgroundColor = [UIColor colorWithRed:randomFloat(.2f, .75f)
													   green:randomFloat(.2f, .75f)
														blue:randomFloat(.2f, .75f)
													   alpha:1];
	
	[[cell.contentView subviews] enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
		[subview removeFromSuperview];
	}];
	
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.f,
															   0.f,
                                                               [self collectionView:collectionView
                                                                        tableLayout:(DRCollectionViewTableLayout *)collectionView.collectionViewLayout
                                                                     widthForColumn:[(DRCollectionViewTableLayout *)collectionView.collectionViewLayout columnNumberForIndexPath:indexPath]
                                                                          inSection:indexPath.section],
                                                               [self collectionView:collectionView
                                                                        tableLayout:(DRCollectionViewTableLayout *)collectionView.collectionViewLayout
                                                                       heightForRow:[(DRCollectionViewTableLayout *)collectionView.collectionViewLayout rowNumberForIndexPath:indexPath]
                                                                          inSection:indexPath.section])];
	label.text = [NSString stringWithFormat:@"%ld.%ld", (long)indexPath.section,  (long)indexPath.row];
	label.textAlignment = NSTextAlignmentCenter;
	[cell.contentView addSubview:label];
	
	return cell;
}

#pragma mark - DRCollectionViewDelegateTableLayout

- (NSUInteger)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout numberOfColumnsPerRowInSection:(NSUInteger)section
{
    if (section == 0) {
        return 5;
    }
    else if (section == 1) {
        return 4;
    }
    
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout widthForColumn:(NSUInteger)column inSection:(NSUInteger)section
{
    return 50.f + column * 10.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout heightForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    return 50.f + row * 10.f;
}

@end
