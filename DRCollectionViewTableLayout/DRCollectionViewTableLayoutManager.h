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

@protocol DRCollectionViewTableLayoutManagerDelegate <NSObject>

- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
              numberOfSectionsInCollectionView:(UICollectionView *)collectionView;

- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                collectionView:(UICollectionView *)collectionView
                      numberOfColumnsInSection:(NSUInteger)section;

- (NSUInteger)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                collectionView:(UICollectionView *)collectionView
                         numberOfRowsInSection:(NSUInteger)section;

- (CGFloat)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                             collectionView:(UICollectionView *)collectionView
                             widthForColumn:(NSUInteger)column
                                  inSection:(NSUInteger)section;

- (CGFloat)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                collectionView:(UICollectionView *)collectionView
                               heightForRow:(NSUInteger)row
                                  inSection:(NSUInteger)section;

- (UICollectionViewCell *)collectionViewTableLayoutManager:(DRCollectionViewTableLayoutManager *)manager
                                            collectionView:(UICollectionView *)collectionView
                                                cellForRow:(NSUInteger)row
                                                    column:(NSUInteger)column
                                                 indexPath:(NSIndexPath *)indexPath;

@end

@interface DRCollectionViewTableLayoutManager : NSObject <UICollectionViewDataSource, DRCollectionViewTableLayoutDelegate>

@property (weak, nonatomic) id<DRCollectionViewTableLayoutManagerDelegate> delegate;

@end
