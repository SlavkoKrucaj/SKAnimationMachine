//
//  UIViewController+AnimationMachine.m
//  SKAnimationMachine
//
//  Created by Slavko Krucaj on 6.9.2012..
//  Copyright (c) 2012. slavko.krucaj@gmail.com. All rights reserved.
//

#import "UIViewController+AnimationMachine.h"
#import <objc/runtime.h>

static char CURRENT_STATE;
static char ANIMATION_DELEGATE;
static char MACHINES;

@implementation SKView

@synthesize animatedViewId;
@synthesize animatedView;
@synthesize alpha;
@synthesize frame;
@synthesize transform;

@end

@implementation SKState

@synthesize stateId;
@synthesize views;
@synthesize transitions;
@synthesize nextTransition;

- (void)addTransition:(SKTransition *)transition {
    if (self.transitions == nil) self.transitions = [NSMutableDictionary dictionary];
    [self.transitions setObject:transition forKey:transition.transitionId];
}

- (void)addView:(SKView *)view {
    if (self.views == nil) self.views = [NSMutableArray array];
    [self.views addObject:view];
}

@end

@implementation SKTransition

@synthesize transitionId;
@synthesize fromStateId;
@synthesize toStateId;
@synthesize duration;
@synthesize animationCurve;
@synthesize delay;

@end

@implementation SKHelper

@synthesize currentState;

@end

@implementation UIViewController (AnimationMachine)

@dynamic currentState;
@dynamic animationDelegate;
@dynamic machines;

- (void)addState:(SKState *)state toMachine:(NSString *)machine{
    if (self.machines == nil) self.machines = [NSMutableDictionary dictionary];
    if ([self.machines objectForKey:machine] == nil) {
        [self.machines setObject:[NSMutableDictionary dictionary] forKey:machine];
    }
    [[self.machines objectForKey:machine] setObject:state forKey:state.stateId];
}

- (void)initialize:(NSString *)stateId onMachine:(NSString *)machine{
    if (self.currentState == nil) self.currentState = [NSMutableDictionary dictionary];
    
    [self.currentState setObject:[[self.machines objectForKey:machine] objectForKey:stateId] 
                          forKey:machine];
}

- (void)performTransition:(NSString *)transitionId onMachine:(NSString *)machine {
    
    SKTransition *transition = [((SKState *)[self.currentState objectForKey:machine]).transitions objectForKey:transitionId];
    SKState *nextState = [[self.machines objectForKey:machine] objectForKey:transition.toStateId];
    
    
    NSAssert(transition != nil, ([NSString stringWithFormat:@"There is no transition with id %@",transitionId]));
    NSAssert(transition.duration != 0, @"Duration must be > 0");
    NSAssert(nextState != nil, @"There is no nextState found");
    
    [UIView animateWithDuration:transition.duration
                          delay:transition.delay
                        options:transition.animationCurve
                     animations:^{
                         
                         for (int i=0;i<nextState.views.count;i++) {
                             SKView *view = [nextState.views objectAtIndex:i];
                             
                             if (!CGRectIsNull(view.frame)) 
                                 view.animatedView.frame = view.frame;
                             
                             if (!NSStringFromCGAffineTransform(view.transform)) 
                                 view.animatedView.transform = view.transform;
                             view.animatedView.alpha = view.alpha;
                         }

                     } 
                     completion:^(BOOL finished){


                         NSString *nextTransition = ((SKState *)[self.currentState objectForKey:machine]).nextTransition;
                         [self.currentState setObject:nextState forKey:machine];
                         
                         if (nextTransition != nil) {
                             [self performTransition:nextTransition onMachine:machine];
                         } else {
                             [self.animationDelegate finishedAnimationToState:nextState.stateId onMachine:machine];
                         }
                     }];

}

- (NSMutableDictionary *)currentState {
    return objc_getAssociatedObject(self, &CURRENT_STATE);
}

- (void)setCurrentState:(NSMutableDictionary *)_currentState {
    objc_setAssociatedObject(self, &CURRENT_STATE, _currentState, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<AnimationMachineProtocol>)animationDelegate {
    return objc_getAssociatedObject(self, &ANIMATION_DELEGATE);
}

- (void)setAnimationDelegate:(id<AnimationMachineProtocol>)_animationDelegate {
    objc_setAssociatedObject(self, &ANIMATION_DELEGATE, _animationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)machines {
    return objc_getAssociatedObject(self, &MACHINES);
}

- (void)setMachines:(NSMutableDictionary *)_machines {
    objc_setAssociatedObject(self, &MACHINES, _machines, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
