//
//  DRCollectionViewTableLayout.m
//  DRCollectionViewTableLayout
//
//  Created by Dariusz Rybicki on 09.05.2014.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#import "DRCollectionViewTableLayout.h"

@interface DRCollectionViewTableLayout ()

@property (nonatomic, assign) CGSize computedContentSize;
@property (nonatomic, weak) id<DRCollectionViewTableLayoutDelegate> delegate;
@property (nonatomic, strong) NSArray *layoutAttributes;

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
	return (indexPath.row % [self.delegate collectionView:self.collectionView tableLayout:self numberOfColumnsInSection:indexPath.section]);
}

- (NSUInteger)rowNumberForIndexPath:(NSIndexPath *)indexPath
{
	return floorf((float)indexPath.row / (float)[self.delegate collectionView:self.collectionView tableLayout:self numberOfColumnsInSection:indexPath.section]);
}

#pragma mark - Layout methods

- (void)invalidateLayout
{
    [super invalidateLayout];
    self.layoutAttributes = nil;
}

- (CGSize)collectionViewContentSize
{
	if (CGSizeEqualToSize(self.computedContentSize, CGSizeZero)) {
		self.computedContentSize = self.collectionView.frame.size;
	}
	
	return self.computedContentSize;
}

- (NSArray *)layoutAttributes
{
    if (!_layoutAttributes) {
        NSMutableArray *layoutAttributes = [NSMutableArray new];
        NSUInteger numberOfSections = [self.collectionView.dataSource numberOfSectionsInCollectionView:self.collectionView];
        for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; sectionIdx++) {
            NSUInteger numberOfItemsInSection = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIdx];
            for (NSUInteger itemIdx = 0; itemIdx < numberOfItemsInSection; itemIdx++) {
                [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:itemIdx inSection:sectionIdx]]];
            }
        }
        _layoutAttributes = [NSArray arrayWithArray:layoutAttributes];
    }
    return _layoutAttributes;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *currentItemAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSUInteger currentColumn = [self columnNumberForIndexPath:indexPath];
    CGFloat width = [self.delegate collectionView:self.collectionView tableLayout:self widthForColumn:currentColumn inSection:indexPath.section];
	CGFloat x = 0;
	for (NSUInteger columnIdx = 0; columnIdx < currentColumn; columnIdx++) {
		x += [self.delegate collectionView:self.collectionView tableLayout:self widthForColumn:columnIdx inSection:indexPath.section];
	}
	x += (self.horizontalSpacing / 2.f) * currentColumn;
    
    NSUInteger currentRow = [self rowNumberForIndexPath:indexPath];
    CGFloat height = [self.delegate collectionView:self.collectionView tableLayout:self heightForRow:currentRow inSection:indexPath.section];
    CGFloat y = 0;
    for (NSUInteger sectionIdx = 0; sectionIdx < indexPath.section; sectionIdx++) {
        NSUInteger numberOfRowsInSection = [self rowNumberForIndexPath:[NSIndexPath indexPathForItem:[self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:sectionIdx]
                                                                                           inSection:sectionIdx]];
        for (NSUInteger rowIdx = 0; rowIdx < numberOfRowsInSection; rowIdx++) {
            y += [self.delegate collectionView:self.collectionView tableLayout:self heightForRow:rowIdx inSection:sectionIdx];
        }
        y += (self.verticalSpacing / 2.f) * numberOfRowsInSection;
    }
    for (NSUInteger rowIdx = 0; rowIdx < currentRow; rowIdx++) {
        y += [self.delegate collectionView:self.collectionView tableLayout:self heightForRow:rowIdx inSection:indexPath.section];
    }
    y += (self.verticalSpacing / 2.f) * currentRow;
	
	currentItemAttributes.frame = CGRectMake(x, y, width, height);
	
	if (self.computedContentSize.width < x + width) {
		self.computedContentSize = CGSizeMake(x + width, self.computedContentSize.height);
	}
	
	if (self.computedContentSize.height < y + height) {
		self.computedContentSize = CGSizeMake(self.computedContentSize.width, y + height);
	}
	
	return currentItemAttributes;
}

@end
