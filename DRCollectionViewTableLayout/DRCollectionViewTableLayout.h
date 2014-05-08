//
//  DRCollectionViewTableLayout.h
//  DRCollectionViewTableLayout
//
//  Created by Dariusz Rybicki on 09.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRCollectionViewTableLayout;

@protocol DRCollectionViewTableLayoutDelegate <NSObject>

- (NSUInteger)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout numberOfColumnsPerRowInSection:(NSUInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout widthForColumn:(NSUInteger)column inSection:(NSUInteger)section;
- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout heightForRow:(NSUInteger)row inSection:(NSUInteger)section;

@end

@interface DRCollectionViewTableLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat horizontalSpacing;
@property (nonatomic, assign) CGFloat verticalSpacing;

- (id)initWithDelegate:(id<DRCollectionViewTableLayoutDelegate>)delegate;
- (NSUInteger)columnNumberForIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)rowNumberForIndexPath:(NSIndexPath *)indexPath;

@end
