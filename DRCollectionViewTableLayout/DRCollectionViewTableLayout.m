//
//  DRCollectionViewTableLayout.m
//  DRCollectionViewTableLayout
//
//  Created by Dariusz Rybicki on 09.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import "DRCollectionViewTableLayout.h"

#pragma mark - DRCollectionViewTableLayoutInvalidationContext

@interface DRCollectionViewTableLayoutInvalidationContext : UICollectionViewLayoutInvalidationContext

@property (nonatomic, assign) BOOL keepCellsLayoutAttributes;
@property (nonatomic, assign) BOOL keepSupplementaryViewsLayoutAttributes;

@end

@implementation DRCollectionViewTableLayoutInvalidationContext

@end

#pragma mark - DRCollectionViewTableLayout

@interface DRCollectionViewTableLayout ()

@property (nonatomic, assign) CGSize computedContentSize;
@property (nonatomic, weak) id<DRCollectionViewTableLayoutDelegate> delegate;
@property (nonatomic, strong) NSArray *layoutAttributesForCells;
@property (nonatomic, strong) NSArray *layoutAttributesForSupplementaryViews;

@end

@implementation DRCollectionViewTableLayout

- (id)initWithDelegate:(id<DRCollectionViewTableLayoutDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Public methods

- (NSUInteger)columnNumberForIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.row % [self.delegate collectionView:self.collectionView
                                              tableLayout:self
                                 numberOfColumnsInSection:indexPath.section]);
}

- (NSUInteger)rowNumberForIndexPath:(NSIndexPath *)indexPath
{
	return floorf((float)indexPath.row / (float)[self.delegate collectionView:self.collectionView
                                                                  tableLayout:self
                                                     numberOfColumnsInSection:indexPath.section]);
}

- (NSUInteger)columnNumberForHeaderIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row;
}

- (NSUInteger)rowNumberForHeaderIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger columnsCount = [self.delegate collectionView:self.collectionView
                                                tableLayout:self
                                   numberOfColumnsInSection:indexPath.section];
    return indexPath.row - columnsCount;
}

- (void)invalidateTableLayout
{
    DRCollectionViewTableLayoutInvalidationContext *context = (DRCollectionViewTableLayoutInvalidationContext *)[super invalidationContextForBoundsChange:self.collectionView.bounds];
    context.keepCellsLayoutAttributes = NO;
    context.keepSupplementaryViewsLayoutAttributes = NO;
    [self invalidateLayoutWithContext:context];
}

#pragma mark - Layout invalidation

+ (Class)invalidationContextClass
{
    return [DRCollectionViewTableLayoutInvalidationContext class];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (void)invalidateLayoutWithContext:(DRCollectionViewTableLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];
    
    if (![(DRCollectionViewTableLayoutInvalidationContext *)context keepCellsLayoutAttributes]) {
        if (_layoutAttributesForCells) {
            _layoutAttributesForCells = nil;
        }
    }
    
    if (![(DRCollectionViewTableLayoutInvalidationContext *)context keepSupplementaryViewsLayoutAttributes]) {
        if (_layoutAttributesForSupplementaryViews) {
            _layoutAttributesForSupplementaryViews = nil;
        }
    }
}

- (UICollectionViewLayoutInvalidationContext *)invalidationContextForBoundsChange:(CGRect)newBounds
{
    DRCollectionViewTableLayoutInvalidationContext *context = (DRCollectionViewTableLayoutInvalidationContext *)[super invalidationContextForBoundsChange:newBounds];
    
    NSUInteger sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    BOOL stickyColumnHeaders = NO;
    BOOL stickyRowHeaders = NO;
    for (NSUInteger sectionIdx = 0; sectionIdx < sectionsCount; sectionIdx++) {
        stickyColumnHeaders = [self.delegate collectionView:self.collectionView tableLayout:self stickyColumnHeadersForSection:sectionIdx];
        stickyRowHeaders = [self.delegate collectionView:self.collectionView tableLayout:self stickyRowHeadersForSection:sectionIdx];
        if (stickyColumnHeaders || stickyRowHeaders) {
            break;
        }
    }
    
    context.keepCellsLayoutAttributes = YES;
    context.keepSupplementaryViewsLayoutAttributes = !(stickyColumnHeaders || stickyRowHeaders);
    
    return context;
}

#pragma mark - Layout methods

- (void)prepareLayout
{
    [super prepareLayout];
    
    // pre-build layout attributes if needed
    [self layoutAttributesForCells];
    [self layoutAttributesForSupplementaryViews];
}

- (CGSize)collectionViewContentSize
{
	if (CGSizeEqualToSize(self.computedContentSize, CGSizeZero)) {
		self.computedContentSize = self.collectionView.frame.size;
	}
	
	return self.computedContentSize;
}

- (NSArray *)layoutAttributesForCells
{
    @synchronized(self) {
        if (!_layoutAttributesForCells) {
            NSMutableArray *layoutAttributes = [NSMutableArray new];
            NSUInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
            for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; sectionIdx++) {
                NSUInteger numberOfItemsInSection = [self.collectionView.dataSource collectionView:self.collectionView
                                                                            numberOfItemsInSection:sectionIdx];
                for (NSUInteger itemIdx = 0; itemIdx < numberOfItemsInSection; itemIdx++) {
                    [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIdx
                                                                                                             inSection:sectionIdx]]];
                }
            }
            _layoutAttributesForCells = [NSArray arrayWithArray:layoutAttributes];
        }
        return _layoutAttributesForCells;
    }
}

- (NSArray *)layoutAttributesForSupplementaryViews
{
    @synchronized(self) {
        if (!_layoutAttributesForSupplementaryViews) {
            NSMutableArray *layoutAttributes = [NSMutableArray new];
            NSUInteger sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
            for (NSUInteger sectionIdx = 0; sectionIdx < sectionsCount; sectionIdx++) {
                NSUInteger columnsCount = [self.delegate collectionView:self.collectionView
                                                            tableLayout:self
                                               numberOfColumnsInSection:sectionIdx];
                for (NSUInteger columnIdx = 0; columnIdx < columnsCount; columnIdx++) {
                    [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewColumnHeader
                                                                                     atIndexPath:[NSIndexPath indexPathForItem:columnIdx
                                                                                                                     inSection:sectionIdx]]];
                }
                NSUInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView
                                                                numberOfItemsInSection:sectionIdx];
                NSUInteger rowsCount = ceilf((float)itemsCount / (float)columnsCount);
                for (NSUInteger rowIdx = 0; rowIdx < rowsCount; rowIdx++) {
                    [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewRowHeader
                                                                                     atIndexPath:[NSIndexPath indexPathForItem:columnsCount + rowIdx
                                                                                                                     inSection:sectionIdx]]];
                }
            }
            _layoutAttributesForSupplementaryViews = [NSArray arrayWithArray:layoutAttributes];
        }
        return _layoutAttributesForSupplementaryViews;
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray new];
    
    [layoutAttributes addObjectsFromArray:[self.layoutAttributesForCells filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
        return (CGRectIntersectsRect(rect, attributes.frame));
    }]]];
    
    [layoutAttributes addObjectsFromArray:[self.layoutAttributesForSupplementaryViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *attributes, NSDictionary *bindings) {
        return (CGRectIntersectsRect(rect, attributes.frame));
    }]]];
    
    return [NSArray arrayWithArray:layoutAttributes];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *currentItemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // get current column and row indexes
    NSUInteger currentColumn = [self columnNumberForIndexPath:indexPath];
    NSUInteger currentRow = [self rowNumberForIndexPath:indexPath];
    
    // compute x position
    CGFloat x = 0;
    CGFloat rowHeaderWidth = [self.delegate collectionView:self.collectionView
                                               tableLayout:self
                                widthForRowHeaderInSection:indexPath.section];
    if (rowHeaderWidth > 0) {
        x += rowHeaderWidth + (self.horizontalSpacing / 2.f);
    }
    for (NSUInteger columnIdx = 0; columnIdx < currentColumn; columnIdx++) {
        x += [self.delegate collectionView:self.collectionView
                               tableLayout:self
                            widthForColumn:columnIdx
                                 inSection:indexPath.section];
        x += self.horizontalSpacing / 2.f;
    }
    
    // compute y position
    CGFloat y = 0;
    for (NSUInteger sectionIdx = 0; sectionIdx <= indexPath.section; sectionIdx++) {
        CGFloat headerHeight = [self.delegate collectionView:self.collectionView
                                                 tableLayout:self
                              heightForColumnHeaderInSection:sectionIdx];
        if (headerHeight > 0) {
            y += headerHeight + (self.verticalSpacing / 2.f);
        }
        
        NSUInteger lastRowIdx;
        if (sectionIdx < indexPath.section) {
            lastRowIdx = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView
                                                                                                           numberOfItemsInSection:sectionIdx]
                                                                         inSection:sectionIdx]];
        }
        else {
            lastRowIdx = currentRow;
        }
        
        for (NSUInteger rowIdx = 0; rowIdx < lastRowIdx; rowIdx++) {
            y += [self.delegate collectionView:self.collectionView
                                   tableLayout:self
                                  heightForRow:rowIdx
                                     inSection:sectionIdx];
            y += self.verticalSpacing / 2.f;
        }
    }
	
    // compute item width
    CGFloat width = [self.delegate collectionView:self.collectionView
                                      tableLayout:self
                                   widthForColumn:currentColumn
                                        inSection:indexPath.section];
    
    // compute item height
    CGFloat height = [self.delegate collectionView:self.collectionView
                                       tableLayout:self
                                      heightForRow:currentRow
                                         inSection:indexPath.section];
    
    // set attributes frame
	currentItemAttributes.frame = CGRectMake(x, y, width, height);
	
    // update content size width if needed
	if (self.computedContentSize.width < x + width) {
		self.computedContentSize = CGSizeMake(x + width, self.computedContentSize.height);
	}
	
    // update content size height if needed
	if (self.computedContentSize.height < y + height) {
		self.computedContentSize = CGSizeMake(self.computedContentSize.width, y + height);
	}
	
	return currentItemAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *currentItemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    
    if ([kind isEqualToString:DRCollectionViewTableLayoutSupplementaryViewColumnHeader]) {
        
        // get header column index
        NSUInteger currentColumn = [self columnNumberForHeaderIndexPath:indexPath];
        
        // compute width
        CGFloat width = [self.delegate collectionView:self.collectionView
                                          tableLayout:self
                                       widthForColumn:indexPath.row
                                            inSection:indexPath.section];
        
        // compute height
        CGFloat height = [self.delegate collectionView:self.collectionView
                                           tableLayout:self
                        heightForColumnHeaderInSection:indexPath.section];
        
        // compute x position
        CGFloat x = 0;
        CGFloat rowHeaderWidth = [self.delegate collectionView:self.collectionView
                                                   tableLayout:self
                                    widthForRowHeaderInSection:indexPath.section];
        if (rowHeaderWidth > 0) {
            x += rowHeaderWidth + (self.horizontalSpacing / 2.f);
        }
        for (NSUInteger columnIdx = 0; columnIdx < currentColumn; columnIdx++) {
            x += [self.delegate collectionView:self.collectionView
                                   tableLayout:self
                                widthForColumn:columnIdx
                                     inSection:indexPath.section];
            x += self.horizontalSpacing / 2.f;
        }
        
        // compute y position
        CGFloat y = 0;
        for (NSUInteger sectionIdx = 0; sectionIdx < indexPath.section; sectionIdx++) {
            y += [self.delegate collectionView:self.collectionView tableLayout:self heightForColumnHeaderInSection:sectionIdx];
            y += self.verticalSpacing / 2.f;
            
            NSUInteger lastRowIdx = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView
                                                                                                                      numberOfItemsInSection:sectionIdx]
                                                                                    inSection:sectionIdx]];
            for (NSUInteger rowIdx = 0; rowIdx < lastRowIdx; rowIdx++) {
                y += [self.delegate collectionView:self.collectionView
                                       tableLayout:self
                                      heightForRow:rowIdx
                                         inSection:sectionIdx];
                y += self.verticalSpacing / 2.f;
            }
        }
        
        // stick column header to top edge
        if ([self.delegate collectionView:self.collectionView tableLayout:self stickyColumnHeadersForSection:indexPath.section]) {
            CGFloat maxY = 0;
            for (NSUInteger sectionIdx = 0; sectionIdx <= indexPath.section; sectionIdx++) {
                CGFloat headerHeight = [self.delegate collectionView:self.collectionView
                                                         tableLayout:self
                                      heightForColumnHeaderInSection:sectionIdx];
                if (headerHeight > 0) {
                    maxY += headerHeight + (self.verticalSpacing / 2.f);
                }
                
                NSUInteger lastRowIdx = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView
                                                                                                                          numberOfItemsInSection:sectionIdx]
                                                                                        inSection:sectionIdx]];
                for (NSUInteger rowIdx = 0; rowIdx < lastRowIdx; rowIdx++) {
                    maxY += [self.delegate collectionView:self.collectionView
                                              tableLayout:self
                                             heightForRow:rowIdx
                                                inSection:sectionIdx];
                    maxY += self.verticalSpacing / 2.f;
                }
            }
            maxY -= height + (self.verticalSpacing / 2.f);
            if (y < self.collectionView.contentOffset.y) {
                y = MIN(maxY, CGRectGetMinY(self.collectionView.bounds) + self.collectionView.contentInset.top);
            }
        }
        
        // set attributes frame and zIndex
        currentItemAttributes.frame = CGRectMake(x, y, width, height);
        currentItemAttributes.zIndex = 101;
    }
    else if ([kind isEqualToString:DRCollectionViewTableLayoutSupplementaryViewRowHeader]) {
        
        // x positon
        CGFloat x = 0;
        
        // stick header to left edge
        if ([self.delegate collectionView:self.collectionView tableLayout:self stickyRowHeadersForSection:indexPath.section]) {
            x = CGRectGetMinX(self.collectionView.bounds) + self.collectionView.contentInset.left;
        }
        
        // compute y position
        CGFloat y = 0;
        for (NSUInteger sectionIdx = 0; sectionIdx <= indexPath.section; sectionIdx++) {
            CGFloat headerHeight = [self.delegate collectionView:self.collectionView
                                                     tableLayout:self
                                  heightForColumnHeaderInSection:sectionIdx];
            if (headerHeight > 0) {
                y += headerHeight + (self.verticalSpacing / 2.f);
            }
            
            NSUInteger lastRowIdx;
            if (sectionIdx == indexPath.section) {
                lastRowIdx = [self rowNumberForHeaderIndexPath:indexPath];
            }
            else {
                lastRowIdx = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView
                                                                                                               numberOfItemsInSection:sectionIdx]
                                                                             inSection:sectionIdx]];
            }
            for (NSUInteger rowIdx = 0; rowIdx < lastRowIdx; rowIdx++) {
                y += [self.delegate collectionView:self.collectionView
                                       tableLayout:self
                                      heightForRow:rowIdx
                                         inSection:sectionIdx];
                y += self.verticalSpacing / 2.f;
            }
        }
        
        // compute width
        CGFloat width = [self.delegate collectionView:self.collectionView
                                          tableLayout:self
                           widthForRowHeaderInSection:indexPath.section];

        // compute height
        CGFloat height = [self.delegate collectionView:self.collectionView
                                           tableLayout:self
                                          heightForRow:[self rowNumberForHeaderIndexPath:indexPath]
                                             inSection:indexPath.section];
        
        // set attributes frame and zIndex
        currentItemAttributes.frame = CGRectMake(x, y, width, height);
        currentItemAttributes.zIndex = 100;
    }
    
    return currentItemAttributes;
}

@end
