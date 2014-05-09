//
//  DRCollectionViewTableLayoutManager.m
//  DRCollectionViewTableLayout
//
//  Created by Dariusz Rybicki on 09.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import "DRCollectionViewTableLayoutManager.h"

@implementation DRCollectionViewTableLayoutManager

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.delegate collectionViewTableLayoutManager:self numberOfSectionsInCollectionView:collectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger numberOfRows = [self.delegate collectionViewTableLayoutManager:self
                                                               collectionView:collectionView
                                                        numberOfRowsInSection:section];
    NSUInteger numberOfColumns = [self.delegate collectionViewTableLayoutManager:self
                                                                  collectionView:collectionView
                                                        numberOfColumnsInSection:section];
    return numberOfRows * numberOfColumns;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    #ifdef DEBUG
    
        SEL selector = @selector(collectionViewTableLayoutManager:collectionView:cellForRow:column:indexPath:);
        NSAssert([self.delegate respondsToSelector:selector],
                 @"DRCollectionViewTableLayoutManagerDelegate should respond to selector %@", NSStringFromSelector(selector));
        
        NSAssert([collectionView.collectionViewLayout isKindOfClass:[DRCollectionViewTableLayout class]],
                 @"DRCollectionViewTableLayoutManagerDelegate can be used only with collection views with DRCollectionViewTableLayout layout");
    
    #endif
    
    NSUInteger row = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout rowNumberForIndexPath:indexPath];
    NSUInteger column = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout columnNumberForIndexPath:indexPath];
    
    return [self.delegate collectionViewTableLayoutManager:self
                                            collectionView:collectionView
                                                cellForRow:row
                                                    column:column
                                                 indexPath:indexPath];
}

#pragma mark - DRCollectionViewTableLayoutDelegate

- (NSUInteger)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout numberOfColumnsPerRowInSection:(NSUInteger)section
{
    return [self.delegate collectionViewTableLayoutManager:self
                                            collectionView:collectionView
                                  numberOfColumnsInSection:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout widthForColumn:(NSUInteger)column inSection:(NSUInteger)section
{
    return [self.delegate collectionViewTableLayoutManager:self
                                            collectionView:collectionView
                                            widthForColumn:column
                                                 inSection:section];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout heightForRow:(NSUInteger)row inSection:(NSUInteger)section
{
    return [self.delegate collectionViewTableLayoutManager:self
                                            collectionView:collectionView
                                              heightForRow:row
                                                 inSection:section];
}

@end
