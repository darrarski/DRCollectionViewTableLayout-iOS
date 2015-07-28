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
    return [self.delegate collectionViewTableLayoutManager:self
                          numberOfSectionsInCollectionView:collectionView];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:DRCollectionViewTableLayoutSupplementaryViewColumnHeader]) {
        
        #ifdef DEBUG
        
            SEL selector = @selector(collectionViewTableLayoutManager:collectionView:headerViewForColumn:indexPath:);
            NSAssert([self.delegate respondsToSelector:selector],
                     @"DRCollectionViewTableLayoutManagerDelegate should respond to selector %@", NSStringFromSelector(selector));
            
            NSAssert([collectionView.collectionViewLayout isKindOfClass:[DRCollectionViewTableLayout class]],
                     @"DRCollectionViewTableLayoutManagerDelegate can be used only with collection views with DRCollectionViewTableLayout layout");
        
        #endif
        
        NSUInteger column = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout columnNumberForHeaderIndexPath:indexPath];
        return [self.delegate collectionViewTableLayoutManager:self
                                                collectionView:collectionView
                                           headerViewForColumn:column
                                                     indexPath:indexPath];
    }
    else if ([kind isEqualToString:DRCollectionViewTableLayoutSupplementaryViewRowHeader]) {
        
        #ifdef DEBUG
                
            SEL selector = @selector(collectionViewTableLayoutManager:collectionView:headerViewForRow:indexPath:);
            NSAssert([self.delegate respondsToSelector:selector],
                     @"DRCollectionViewTableLayoutManagerDelegate should respond to selector %@", NSStringFromSelector(selector));
            
            NSAssert([collectionView.collectionViewLayout isKindOfClass:[DRCollectionViewTableLayout class]],
                     @"DRCollectionViewTableLayoutManagerDelegate can be used only with collection views with DRCollectionViewTableLayout layout");
                
        #endif
        
        NSUInteger row = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout rowNumberForHeaderIndexPath:indexPath];
        return [self.delegate collectionViewTableLayoutManager:self
                                                collectionView:collectionView
                                              headerViewForRow:row
                                                     indexPath:indexPath];
    }
    
    return nil;
}

#pragma mark - DRCollectionViewTableLayoutDelegate

- (NSUInteger)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout numberOfColumnsInSection:(NSUInteger)section
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

- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout widthForRowHeaderInSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionViewTableLayoutManager:collectionView:widthForRowHeaderInSection:)]) {
        return [self.delegate collectionViewTableLayoutManager:self
                                                collectionView:collectionView
                                    widthForRowHeaderInSection:section];
    }
    
    return 0.f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout heightForColumnHeaderInSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionViewTableLayoutManager:collectionView:heightForColumnHeaderInSection:)]) {
        return [self.delegate collectionViewTableLayoutManager:self
                                                collectionView:collectionView
                                heightForColumnHeaderInSection:section];
    }
    
    return 0.f;
}

- (BOOL)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout stickyRowHeadersForSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionViewTableLayoutManager:collectionView:stickyRowHeadersForSection:)]) {
        return [self.delegate collectionViewTableLayoutManager:self
                                                collectionView:collectionView
                                    stickyRowHeadersForSection:section];
    }
    
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView tableLayout:(DRCollectionViewTableLayout *)collectionViewLayout stickyColumnHeadersForSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionViewTableLayoutManager:collectionView:stickyColumnHeadersForSection:)]) {
        return [self.delegate collectionViewTableLayoutManager:self
                                                collectionView:collectionView
                                 stickyColumnHeadersForSection:section];
    }
    
    return NO;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionViewTableLayoutManager:collectionView:didSelectCellAtRow:column:indexPath:)]) {
        
        #ifdef DEBUG
        
            NSAssert([collectionView.collectionViewLayout isKindOfClass:[DRCollectionViewTableLayout class]],
                     @"DRCollectionViewTableLayoutManagerDelegate can be used only with collection views with DRCollectionViewTableLayout layout");
        
        #endif
        
        NSUInteger row = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout rowNumberForIndexPath:indexPath];
        NSUInteger column = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout columnNumberForIndexPath:indexPath];
        
        [self.delegate collectionViewTableLayoutManager:self
                                         collectionView:collectionView
                                     didSelectCellAtRow:row
                                                 column:column
                                              indexPath:indexPath];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout rowNumberForIndexPath:indexPath];
    NSUInteger column = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout columnNumberForIndexPath:indexPath];
    
    [self.delegate collectionViewTableLayoutManager:self
                                     collectionView:collectionView
                               didDeselectCellAtRow:row
                                             column:column
                                          indexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout rowNumberForIndexPath:indexPath];
    NSUInteger column = [(DRCollectionViewTableLayout *)collectionView.collectionViewLayout columnNumberForIndexPath:indexPath];
    
    return [self.delegate collectionViewTableLayoutManager:self collectionView:collectionView shouldSelectItemAtRow:row column:column indexPath:indexPath];
}

@end
