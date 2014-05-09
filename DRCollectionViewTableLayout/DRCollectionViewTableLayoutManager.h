//
//  DRCollectionViewTableLayoutManager.h
//  DRCollectionViewTableLayout
//
//  Created by Dariusz Rybicki on 09.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRCollectionViewTableLayout.h"

@class DRCollectionViewTableLayoutManager;

/**
 *  Collection View Table Layout Manager Delegate
 */
@protocol DRCollectionViewTableLayoutManagerDelegate <NSObject>

/**
 *  Return number of sections in given collection view
 *
 *  @param manager        Collection View Table Layout Manager
 *  @param collectionView Collection View
 *
 *  @return Number of sections
 */
- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
              numberOfSectionsInCollectionView:(UICollectionView *)collectionView;

/**
 *  Return number of layout's columns in given collection view section
 *
 *  @param manager        Collection View Table Layout Manager
 *  @param collectionView Collection View
 *  @param section        Collection View section
 *
 *  @return Number of layout's columns
 */
- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                collectionView:(UICollectionView *)collectionView
                      numberOfColumnsInSection:(NSUInteger)section;

/**
 *  Return number of layout's rows in given collection view section
 *
 *  @param manager        Collection View Table Layout Manager
 *  @param collectionView Collection View
 *  @param section        Collection View section
 *
 *  @return Number of layout's rows
 */
- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                collectionView:(UICollectionView *)collectionView
                         numberOfRowsInSection:(NSUInteger)section;

/**
 *  Return width for layout's column in given collection view section
 *
 *  @param manager        Collection View Table Layout Manager
 *  @param collectionView Collection View
 *  @param column         Layout's column index
 *  @param section        Collection View section
 *
 *  @return Column width
 */
- (CGFloat)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                             collectionView:(UICollectionView *)collectionView
                             widthForColumn:(NSUInteger)column
                                  inSection:(NSUInteger)section;

/**
 *  Return height for layout's row in given collection view section
 *
 *  @param manager        Collection View Table Layout Manager
 *  @param collectionView Collection View
 *  @param row            Layout's row index
 *  @param section        Collection View section
 *
 *  @return Row height
 */
- (CGFloat)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                collectionView:(UICollectionView *)collectionView
                               heightForRow:(NSUInteger)row
                                  inSection:(NSUInteger)section;

/**
 *  Return cell for given row and column in collection view
 *
 *  @param manager        Collection View Table Layout Manager
 *  @param collectionView Collection View
 *  @param row            Layout's row
 *  @param column         Layout's column
 *  @param indexPath      Collection View Cell index path
 *
 *  @return Collection View Cell
 */
- (UICollectionViewCell *)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                            collectionView:(UICollectionView *)collectionView
                                                cellForRow:(NSUInteger)row
                                                    column:(NSUInteger)column
                                                 indexPath:(NSIndexPath *)indexPath;

@end

/**
 *  Collection View Table Layout Manager
 */
@interface DRCollectionViewTableLayoutManager : NSObject <UICollectionViewDataSource, DRCollectionViewTableLayoutDelegate>

/**
 *  Collection View Table Layout Manager Delegate
 */
@property (weak, nonatomic) id<DRCollectionViewTableLayoutManagerDelegate> delegate;

@end
