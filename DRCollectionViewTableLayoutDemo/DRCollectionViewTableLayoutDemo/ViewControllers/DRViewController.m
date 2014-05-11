//
//  DRViewController.m
//  DRCollectionViewTableLayoutDemo
//
//  Created by Dariusz Rybicki on 08.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import "DRViewController.h"
#import "DRCollectionViewTableLayout.h"
#import "DRCollectionViewTableLayoutManager.h"

static NSString * const CollectionViewCellIdentifier = @"Cell";
static NSString * const CollectionViewHeaderIdentifier = @"Header";

@interface DRViewController () <DRCollectionViewTableLayoutManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) DRCollectionViewTableLayoutManager *collectionManager;

@end

@implementation DRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewColumnHeader
                   withReuseIdentifier:CollectionViewHeaderIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewRowHeader
                   withReuseIdentifier:CollectionViewHeaderIdentifier];
    
    [self.collectionView registerClass:[UICollectionViewCell class]
            forCellWithReuseIdentifier:CollectionViewCellIdentifier];
    
    DRCollectionViewTableLayout *collectionViewLayout = [[DRCollectionViewTableLayout alloc] initWithDelegate:self.collectionManager];
    collectionViewLayout.horizontalSpacing = 5.f;
    collectionViewLayout.verticalSpacing = 5.f;
    self.collectionView.collectionViewLayout = collectionViewLayout;
    self.collectionView.dataSource = self.collectionManager;
    self.collectionView.delegate = self.collectionManager;
}

- (DRCollectionViewTableLayoutManager *)collectionManager
{
    if (!_collectionManager) {
        _collectionManager = [[DRCollectionViewTableLayoutManager alloc] init];
        _collectionManager.delegate = self;
    }
    return _collectionManager;
}

#pragma mark - DRCOllectionViewTableLayoutManagerDelegate

- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
              numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                collectionView:(UICollectionView *)collectionView
                         numberOfRowsInSection:(NSUInteger)section
{
    if (section == 0) {
        return 10;
    }
    else if (section == 1) {
        return 5;
    }
    
    return 0;
}

- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                collectionView:(UICollectionView *)collectionView
                      numberOfColumnsInSection:(NSUInteger)section
{
    if (section == 0) {
        return 10;
    }
    else if (section == 1) {
        return 5;
    }
    
    return 0;
}

- (CGFloat)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                             collectionView:(UICollectionView *)collectionView
                             widthForColumn:(NSUInteger)column
                                  inSection:(NSUInteger)section
{
    if (section == 0) {
        return 100.f + column * 10.f;
    }
    else if (section == 1) {
        return 80.f + column * 10.f;
    }
    
    return 0;
}

- (CGFloat)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                             collectionView:(UICollectionView *)collectionView
                               heightForRow:(NSUInteger)row
                                  inSection:(NSUInteger)section
{
    return 50.f + row * 10.f;
}

- (CGFloat)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                             collectionView:(UICollectionView *)collectionView
                 widthForRowHeaderInSection:(NSUInteger)section
{
    if (section == 0) {
        return 80.f;
    }
    else if (section == 1) {
        return 60.f;
    }
    
    return 0.f;
}

- (CGFloat)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                             collectionView:(UICollectionView *)collectionView
             heightForColumnHeaderInSection:(NSUInteger)section
{
    if (section == 0) {
        return 30.f;
    }
    else if (section == 1) {
        return 20.f;
    }
    
    return 0.f;
}

- (UICollectionViewCell *)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                            collectionView:(UICollectionView *)collectionView
                                                cellForRow:(NSUInteger)row
                                                    column:(NSUInteger)column
                                                 indexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
	CGFloat(^randomFloat)(CGFloat, CGFloat) = ^CGFloat(CGFloat min, CGFloat max) {
		return min + ((float)rand() / RAND_MAX) * max;
	};
    
	cell.contentView.backgroundColor = [UIColor colorWithRed:randomFloat(.2f, .75f)
													   green:randomFloat(.2f, .75f)
														blue:randomFloat(.2f, .75f)
													   alpha:1];
    
    UILabel *label = [[[cell.contentView subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *subview, NSDictionary *bindings) {
        return ([subview isKindOfClass:[UILabel class]]);
    }]] firstObject];
    
    if (!label) {
        label = [[UILabel alloc] initWithFrame:cell.bounds];
        label.font = [UIFont systemFontOfSize:10.f];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    
	label.text = [NSString stringWithFormat:@"%ld:%ld / %ld:%ld", (long)indexPath.section,  (long)indexPath.row, (long)row, (long)column];
	
	return cell;
}

- (UICollectionReusableView *)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                                collectionView:(UICollectionView *)collectionView
                                           headerViewForColumn:(NSUInteger)column
                                                     indexPath:(NSIndexPath *)indexPath;
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewColumnHeader
                                                                        withReuseIdentifier:CollectionViewHeaderIdentifier
                                                                               forIndexPath:indexPath];
    view.backgroundColor = [UIColor grayColor];
    view.layer.borderColor = [[UIColor blackColor] CGColor];
    view.layer.borderWidth = 1.f;
    
    UILabel *label = [[[view subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *subview, NSDictionary *bindings) {
        return ([subview isKindOfClass:[UILabel class]]);
    }]] firstObject];
    
    if (!label) {
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.font = [UIFont systemFontOfSize:10.f];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
    }
    
    label.text = [NSString stringWithFormat:@"C %ld:%ld", (long)indexPath.section,  (long)column];
    
    return view;
}

- (UICollectionReusableView *)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                                collectionView:(UICollectionView *)collectionView
                                              headerViewForRow:(NSUInteger)row
                                                     indexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewRowHeader
                                                                        withReuseIdentifier:CollectionViewHeaderIdentifier
                                                                               forIndexPath:indexPath];
    view.backgroundColor = [UIColor grayColor];
    view.layer.borderColor = [[UIColor blackColor] CGColor];
    view.layer.borderWidth = 1.f;
    
    UILabel *label = [[[view subviews] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *subview, NSDictionary *bindings) {
        return ([subview isKindOfClass:[UILabel class]]);
    }]] firstObject];
    
    if (!label) {
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.font = [UIFont systemFontOfSize:10.f];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
    }
    
    label.text = [NSString stringWithFormat:@"R %ld:%ld", (long)indexPath.section,  (long)row];
    
    return view;
}

- (BOOL)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager collectionView:(UICollectionView *)collectionView stickyColumnHeadersForSection:(NSUInteger)section
{
    return YES;
}

- (BOOL)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager collectionView:(UICollectionView *)collectionView stickyRowHeadersForSection:(NSUInteger)section
{
    return YES;
}

- (void)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager collectionView:(UICollectionView *)collectionView didSelectCellAtRow:(NSUInteger)row column:(NSUInteger)column indexPath:(NSIndexPath *)indexPath
{
    NSLog(@"SELECTED: %ld.%ld / %ld.%ld", (long)indexPath.section, (long)indexPath.row, (long)row, (long)column);
}

@end
