//
//  DRCollectionViewTableLayout.h
//  DRCollectionViewTableLayout
//
//  Created by Dariusz Rybicki on 09.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DRCollectionViewTableLayout;

/**
 *  Collection View Table Layout Delegate
 */
@protocol DRCollectionViewTableLayoutDelegate <NSObject>

/**
 *  Return number of columns in given section
 *
 *  @param collectionView       Collection View
 *  @param collectionViewLayout Collection View Layout
 *  @param section              Section index (from collection view cell's indexPath property)
 *
 *  @return Number of columns
 */
- (NSUInteger)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout numberOfColumnsInSection:(NSUInteger)section;

/**
 *  Return width for column in given section
 *
 *  @param collectionView       Collection View
 *  @param collectionViewLayout Collection View Layout
 *  @param column               Layout's column index
 *  @param section              Section index (from collection view cell's indexPath property)
 *
 *  @return Column width
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout widthForColumn:(NSUInteger)column inSection:(NSUInteger)section;

/**
 *  Return height for row in given section
 *
 *  @param collectionView       Collection View
 *  @param collectionViewLayout Collection View Layout
 *  @param row                  Layout's row index
 *  @param section              Section index (from collection view cell's indexPath property)
 *
 *  @return Row height
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout heightForRow:(NSUInteger)row inSection:(NSUInteger)section;

@end

/**
 *  Collection View Table Layout
 */
@interface DRCollectionViewTableLayout : UICollectionViewLayout

/**
 *  Horizontal spacing between cells
 */
@property (nonatomic, assign) CGFloat horizontalSpacing;

/**
 *  Vertical spacing between cells
 */
@property (nonatomic, assign) CGFloat verticalSpacing;

/**
 *  Initialize with delegate
 *
 *  @param delegate Collection View Table Layout Delegate
 *
 *  @return new Collection View Table Layout
 */
- (id)initWithDelegate:(id<DRCollectionViewTableLayoutDelegate>)delegate;

/**
 *  Return layout's column index for collection view cell's indexPath
 *
 *  @param indexPath Collection View Cell's indexPath
 *
 *  @return Layout's column index
 */
- (NSUInteger)columnNumberForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Return layout's row index for collection view cell's indexPath
 *
 *  @param indexPath Collection View Cell's indexPath
 *
 *  @return Layout's row index
 */
- (NSUInteger)rowNumberForIndexPath:(NSIndexPath *)indexPath;

@end
