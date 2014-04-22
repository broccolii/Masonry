//
//  MASCompositeConstraint.m
//  Masonry
//
//  Created by Jonas Budelmann on 21/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASCompositeConstraint.h"

@interface MASCompositeConstraint () <MASConstraintDelegate>

@property (nonatomic, strong) id mas_key;
@property (nonatomic, strong) NSMutableArray *childConstraints;

@end

@implementation MASCompositeConstraint

- (id)initWithChildren:(NSArray *)children {
    self = [super init];
    if (!self) return nil;

    _childConstraints = [children mutableCopy];
    for (MASConstraint *constraint in _childConstraints) {
        constraint.delegate = self;
    }

    return self;
}

#pragma mark - MASConstraintDelegate

- (void)constraint:(MASConstraint *)constraint shouldBeReplacedWithConstraint:(MASConstraint *)replacementConstraint {
    NSUInteger index = [self.childConstraints indexOfObject:constraint];
    NSAssert(index != NSNotFound, @"Could not find constraint %@", constraint);
    [self.childConstraints replaceObjectAtIndex:index withObject:replacementConstraint];
}

#pragma mark - NSLayoutConstraint multiplier proxies 

- (MASConstraint * (^)(CGFloat))multipliedBy {
    return ^id(CGFloat multiplier) {
        for (MASConstraint *constraint in self.childConstraints) {
            constraint.multipliedBy(multiplier);
        }
        return self;
    };
}

- (MASConstraint * (^)(CGFloat))dividedBy {
    return ^id(CGFloat divider) {
        for (MASConstraint *constraint in self.childConstraints) {
            constraint.dividedBy(divider);
        }
        return self;
    };
}

#pragma mark - MASLayoutPriority proxy

- (MASConstraint * (^)(MASLayoutPriority))priority {
    return ^id(MASLayoutPriority priority) {
        for (MASConstraint *constraint in self.childConstraints) {
            constraint.priority(priority);
        }
        return self;
    };
}

#pragma mark - NSLayoutRelation proxies

- (MASConstraint * (^)(id, NSLayoutRelation))_equalToWithRelation {
    return ^id(id attr, NSLayoutRelation relation) {
        for (MASConstraint *constraint in self.childConstraints.copy) {
            constraint._equalToWithRelation(attr, relation);
        }
        return self;
    };
}

#pragma mark - Animator proxy

#if TARGET_OS_MAC && !TARGET_OS_IPHONE

- (MASConstraint *)animator {
    for (MASConstraint *constraint in self.childConstraints) {
        [constraint animator];
    }
    return self;
}

#endif

#pragma mark - debug helpers

- (MASConstraint * (^)(id))key {
    return ^id(id key) {
        self.mas_key = key;
        int i = 0;
        for (MASConstraint *constraint in self.childConstraints) {
            constraint.key([NSString stringWithFormat:@"%@[%d]", key, i++]);
        }
        return self;
    };
}

#pragma mark - NSLayoutConstraint constant setters

- (void)setValueOffset:(id)offset {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.valueOffset = offset;
    }
}

- (void)setInsets:(MASEdgeInsets)insets {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.insets = insets;
    }
}

#pragma mark - MASConstraint

- (void)install {
    for (MASConstraint *constraint in self.childConstraints) {
        constraint.updateExisting = self.updateExisting;
        [constraint install];
    }
}

- (void)uninstall {
    for (MASConstraint *constraint in self.childConstraints) {
        [constraint uninstall];
    }
}

@end
