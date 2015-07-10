//
//  DRCollectionViewTableLayout.m
//  DRCollectionViewTableLayout
//
//  Created by Dariusz Rybicki on 09.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import "DRCollectionViewTableLayout.h"

const NSInteger DRTopLeftColumnHeaderIndex = -1;

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
        _verticalSectionSpacing = 50.f;
    }
    return self;
}

- (BOOL)stickyColumnHeadersInSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:tableLayout:stickyColumnHeadersForSection:)]) {
        return [self.delegate collectionView:self.collectionView tableLayout:self stickyColumnHeadersForSection:section];
    }
    else {
        return NO;
    }
}

- (BOOL)stickyRowHeadersInSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:tableLayout:stickyRowHeadersForSection:)]) {
        return [self.delegate collectionView:self.collectionView tableLayout:self stickyRowHeadersForSection:section];
    }
    else {
        return NO;
    }
}

- (BOOL)stickyColumnOrRowHeadersInAnySection
{
    NSUInteger sectionsCount = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
    for (NSUInteger sectionIdx = 0; sectionIdx < sectionsCount; sectionIdx++) {
        if ([self stickyColumnHeadersInSection:sectionIdx] || [self stickyRowHeadersInSection:sectionIdx]) {
            return YES;
        }
    }
    
    return NO;
}

- (CGFloat)widthForRowHeaderInSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:tableLayout:widthForRowHeaderInSection:)]) {
        return [self.delegate collectionView:self.collectionView tableLayout:self widthForRowHeaderInSection:section];
    }
    
    return 0.f;
}

- (CGFloat)heightForColumnHeaderInSection:(NSUInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:tableLayout:heightForColumnHeaderInSection:)]) {
        return [self.delegate collectionView:self.collectionView tableLayout:self heightForColumnHeaderInSection:section];
    }
    
    return 0.f;
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
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
		_computedContentSize = CGSizeZero;
		_layoutAttributesForCells = nil;
		_layoutAttributesForSupplementaryViews = nil;
		[super invalidateLayout];
	}
	else {
		DRCollectionViewTableLayoutInvalidationContext *context = (DRCollectionViewTableLayoutInvalidationContext *)[super invalidationContextForBoundsChange:self.collectionView.bounds];
		context.keepCellsLayoutAttributes = NO;
		context.keepSupplementaryViewsLayoutAttributes = NO;
		[self invalidateLayoutWithContext:context];
	}
}

#pragma mark - Layout invalidation

+ (Class)invalidationContextClass
{
    return [DRCollectionViewTableLayoutInvalidationContext class];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    /**
     *  Workaround for floating (sticky) headers under iOS 6.
     *  This is due to custom invalidation contexts are not available under iOS 6.
     */
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1 &&
        [self stickyColumnOrRowHeadersInAnySection]) {
        _layoutAttributesForSupplementaryViews = nil;
    }
    
    return YES;
}

- (void)invalidateLayoutWithContext:(DRCollectionViewTableLayoutInvalidationContext *)context
{
    [super invalidateLayoutWithContext:context];
	
	if (![(DRCollectionViewTableLayoutInvalidationContext *)context keepCellsLayoutAttributes]) {
		_computedContentSize = CGSizeZero;
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
    
    context.keepCellsLayoutAttributes = YES;
    context.keepSupplementaryViewsLayoutAttributes = ![self stickyColumnOrRowHeadersInAnySection];
    
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
                
                
                BOOL hasColumnHeader = ([self heightForColumnHeaderInSection:sectionIdx] > 0);
                if (hasColumnHeader) {
                    for (NSUInteger columnIdx = 0; columnIdx < columnsCount; columnIdx++) {
                        [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewColumnHeader
                                                                                         atIndexPath:[NSIndexPath indexPathForItem:columnIdx
                                                                                                                         inSection:sectionIdx]]];
                    }
                }
                
                BOOL hasRowHeader = ([self widthForRowHeaderInSection:sectionIdx] > 0);
                if (hasRowHeader) {
                    NSUInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView
                                                                    numberOfItemsInSection:sectionIdx];
                    NSUInteger rowsCount = ceilf((float)itemsCount / (float)columnsCount);
                    for (NSUInteger rowIdx = 0; rowIdx < rowsCount; rowIdx++) {
                        [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewRowHeader
                                                                                         atIndexPath:[NSIndexPath indexPathForItem:columnsCount + rowIdx
                                                                                                                         inSection:sectionIdx]]];
                    }
                }
                
                if (hasColumnHeader && hasRowHeader && self.hasTopLeftColumnHeaderView) {
                    [layoutAttributes addObject:[self layoutAttributesForSupplementaryViewOfKind:DRCollectionViewTableLayoutSupplementaryViewColumnHeader
                                                                                     atIndexPath:[NSIndexPath indexPathForItem:DRTopLeftColumnHeaderIndex
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
    CGFloat rowHeaderWidth = [self widthForRowHeaderInSection:indexPath.section];
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
        CGFloat headerHeight = [self heightForColumnHeaderInSection:sectionIdx];
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
    y += (indexPath.section * self.verticalSectionSpacing);
	
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
        
        // compute height
        CGFloat height = [self heightForColumnHeaderInSection:indexPath.section];
        CGFloat width;
        
        CGFloat x = 0;
        if (indexPath.item == DRTopLeftColumnHeaderIndex) {
            x = 0;
            width = [self.delegate collectionView:self.collectionView
                                      tableLayout:self
                       widthForRowHeaderInSection:indexPath.section];
        } else {
            // compute x position
            CGFloat rowHeaderWidth = [self widthForRowHeaderInSection:indexPath.section];
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
            
            // compute width
            width = [self.delegate collectionView:self.collectionView
                                      tableLayout:self
                                   widthForColumn:indexPath.row
                                        inSection:indexPath.section];
        }
        
        // compute y position
        CGFloat y = 0;
        for (NSUInteger sectionIdx = 0; sectionIdx < indexPath.section; sectionIdx++) {
            y += [self heightForColumnHeaderInSection:sectionIdx];
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
        y += (indexPath.section * self.verticalSectionSpacing);
        
        // stick column header to top edge
        if ([self stickyColumnHeadersInSection:indexPath.section]) {
            CGFloat maxY = 0;
            for (NSUInteger sectionIdx = 0; sectionIdx <= indexPath.section; sectionIdx++) {
                CGFloat headerHeight = [self heightForColumnHeaderInSection:sectionIdx];
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
            maxY += (indexPath.section * self.verticalSectionSpacing);
            maxY -= height + (self.verticalSpacing / 2.f);
            
            CGFloat stickyY = self.collectionView.contentOffset.y + self.collectionView.contentInset.top;
            if (y < stickyY) {
                y = MIN(maxY, stickyY);
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
        if ([self stickyRowHeadersInSection:indexPath.section]) {
            CGFloat stickyX = CGRectGetMinX(self.collectionView.bounds) + self.collectionView.contentInset.left;
            if (x < stickyX)
                x = stickyX;
        }
        
        // compute y position
        CGFloat y = 0;
        for (NSUInteger sectionIdx = 0; sectionIdx <= indexPath.section; sectionIdx++) {
            CGFloat headerHeight = [self heightForColumnHeaderInSection:sectionIdx];
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
        y += (indexPath.section * self.verticalSectionSpacing);
        
        // compute width
        CGFloat width = [self widthForRowHeaderInSection:indexPath.section];

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
