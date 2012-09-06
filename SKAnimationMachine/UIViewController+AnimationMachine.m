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
static char STATES;
static char ANIMATION_DELEGATE;

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
@dynamic states;
@dynamic animationDelegate;

- (void)addState:(SKState *)state {
    if (self.states == nil) {
        self.states = [NSMutableDictionary dictionary];
    }
    [self.states setObject:state forKey:state.stateId];

}

- (void)initialize:(NSString *)stateId {
    self.currentState = [self.states objectForKey:stateId];
}

- (void)performTransition:(NSString *)transitionId{
    SKTransition *transition = [self.currentState.transitions objectForKey:transitionId];
    SKState *nextState = [self.states objectForKey:transition.toStateId];
    
    if (transition == nil) {
        NSLog(@"There is no transition with id %@", transitionId);
    }
    
    if (transition.duration == 0) {
        NSLog(@"Duration must be > 0");
        return;
    }
    
    SKView *view = [nextState.views objectAtIndex:0];
    
    NSLog(@"%@",NSStringFromCGRect(view.frame));
    NSLog(@"%@",view.transform);
    
    [UIView animateWithDuration:transition.duration
                          delay:transition.delay
                        options:transition.animationCurve
                     animations:^{
                         
                         for (int i=0;i<nextState.views.count;i++) {
                             SKView *view = [nextState.views objectAtIndex:i];
                             
                             view.animatedView.frame = view.frame;
                             view.animatedView.alpha = view.alpha;
//                             view.animatedView.transform = view.transform;
                         }

                     } 
                     completion:^(BOOL finished){


                         NSString *nextTransition = self.currentState.nextTransition;
                         self.currentState = nextState;
                         
                         if (nextTransition != nil) {
                             [self performTransition:nextTransition];
                         } else {
                             [self.animationDelegate finishedAnimationToState:nextState.stateId];
                         }
                     }];

}

- (SKState *)currentState {
    return objc_getAssociatedObject(self, &CURRENT_STATE);
}

- (void)setCurrentState:(SKState *)_currentState {
    objc_setAssociatedObject(self, &CURRENT_STATE, _currentState, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)states {
    return objc_getAssociatedObject(self, &STATES);
}

- (void)setStates:(NSMutableDictionary *)_states {
    objc_setAssociatedObject(self, &STATES, _states, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<AnimationMachineProtocol>)animationDelegate {
    return objc_getAssociatedObject(self, &ANIMATION_DELEGATE);
}

- (void)setAnimationDelegate:(id<AnimationMachineProtocol>)_animationDelegate {
    objc_setAssociatedObject(self, &ANIMATION_DELEGATE, _animationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
