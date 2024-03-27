//
//  DPBaseDataSource.m
//  DP Commons
//
//  Created by Dmitriy Petrusevich on 27/04/15.
//  Copyright (c) 2015 Dmitriy Petrusevich. All rights reserved.
//

#import "DPBaseDataSource.h"

@implementation NSFetchedResultsController (DataSourceContainerController)

- (NSInteger)numberOfSections {
    return self.sections.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    NSInteger result = 0;
    if (section < self.sections.count && section >= 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo =  [self.sections objectAtIndex:section];
        result = [sectionInfo numberOfObjects];
    }
    return result;
}

- (BOOL)hasData {
    return self.fetchedObjects.count > 0;
}

@end

@implementation DPBaseDataSource

@synthesize listController = _listController;

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    if (self.listController.delegate == self) self.listController.delegate = nil;
}

- (void)setListController:(id<DataSourceContainerController>)listController {
    _listController = listController;
    if ([listController isKindOfClass:[NSFetchedResultsController class]]) {
        [((NSFetchedResultsController *)listController) performFetch:nil];
    }
}

#pragma mark -

- (NSInteger)numberOfSections {
    return [self.listController numberOfSections];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
    return [self.listController numberOfItemsInSection:section];
}

- (BOOL)hasData {
    return self.listController.hasData;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    id result = nil;
    if (indexPath && [indexPath indexAtPosition:0] < [self numberOfSections] && [indexPath indexAtPosition:1] < [self numberOfItemsInSection:[indexPath indexAtPosition:0]]) {
        result = [self.listController objectAtIndexPath:indexPath];
    }
    return result;
}

- (NSArray<id> *)objectsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    NSMutableArray *result = [NSMutableArray array];
    for (NSIndexPath *indexPath in indexPaths) {
        id object = [self objectAtIndexPath:indexPath];
        if (object != nil) {
            [result addObject:object];
        }
    }
    return result;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return object ? [self.listController indexPathForObject:object] : nil;
}

#pragma mark - Forward

- (BOOL)respondsToSelector:(SEL)selector {
    BOOL result = [super respondsToSelector:selector];
    return result ? result : [self.forwardDelegate respondsToSelector:selector];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.forwardDelegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.forwardDelegate];
    }
    else if ([super respondsToSelector:invocation.selector]) {
        [super forwardInvocation:invocation];
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
    NSMethodSignature* signature = [super methodSignatureForSelector:selector];
    if (!signature) {
        signature = [self.forwardDelegate methodSignatureForSelector:selector];
    }
    return signature;
}

@end
