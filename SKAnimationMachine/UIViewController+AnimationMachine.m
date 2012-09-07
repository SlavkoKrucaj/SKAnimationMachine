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

@synthesize animatedViewTag;
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
                             
                             UIView *realView = self.view;
                             NSArray *tags = [view.animatedViewTag componentsSeparatedByString:@"."];
                             
                             for (NSString *tag in tags) {
                                 realView = [realView viewWithTag:[tag intValue]];
                             }
                             
                             NSAssert(realView != self.view && realView != nil, ([NSString stringWithFormat:@"There is no view with tag %@",view.animatedViewTag]));
                                
                             if (!CGRectIsNull(view.frame) && !CGRectIsEmpty(view.frame)) 
                                 realView.frame = view.frame;
                              
                             realView.transform = view.transform;
                             realView.alpha = view.alpha;
                         }

                     } 
                     completion:^(BOOL finished){

                         NSString *oldStateId = ((SKState *)[self.currentState objectForKey:machine]).stateId;
                         NSString *nextTransition = ((SKState *)[self.currentState objectForKey:machine]).nextTransition;
                         [self.currentState setObject:nextState forKey:machine];
                         
                         if (nextTransition != nil) {
                             [self.animationDelegate movedFromState:oldStateId toState:nextState.stateId onMachine:machine];
                             [self performTransition:nextTransition onMachine:machine];
                         } else {
                             [self.animationDelegate finishedAnimationFromState:oldStateId toState:nextState.stateId onMachine:machine];
                         }
                     }];

}

- (void)stopAnimationsOnMachine:(NSString *)machine {
#warning implement
}

- (void)goToState:(NSString *)stateId withTransition:(SKTransition *)transition onMachine:(NSString *)machine {
#warning TEST
    SKState *nextState = [[self.machines objectForKey:machine] objectForKey:stateId];
    
    [UIView animateWithDuration:transition.duration
                          delay:transition.delay
                        options:transition.animationCurve
                     animations:^{
                         
                         for (int i=0;i<nextState.views.count;i++) {
                             SKView *view = [nextState.views objectAtIndex:i];
                             
                             UIView *realView = self.view;
                             NSArray *tags = [view.animatedViewTag componentsSeparatedByString:@"."];
                             
                             for (NSString *tag in tags) {
                                 realView = [realView viewWithTag:[tag intValue]];
                             }
                             
                             NSAssert(realView != self.view && realView != nil, ([NSString stringWithFormat:@"There is no view with tag %@",view.animatedViewTag]));
                             
                             if (!CGRectIsNull(view.frame) && !CGRectIsEmpty(view.frame)) 
                                 realView.frame = view.frame;
                             
                             realView.transform = view.transform;
                             realView.alpha = view.alpha;
                         }
                         
                     } 
                     completion:^(BOOL finished){
                         
                         NSString *oldStateId = stateId;
                         NSString *nextTransition = nextState.nextTransition;
                         [self.currentState setObject:nextState forKey:machine];
                         
                         if (nextTransition != nil) {
                             [self.animationDelegate movedFromState:oldStateId toState:nextState.stateId onMachine:machine];
                             [self performTransition:nextTransition onMachine:machine];
                         } else {
                             [self.animationDelegate finishedAnimationFromState:oldStateId toState:nextState.stateId onMachine:machine];
                         }
                     }];

}

- (void)initializeAnimationStateMachine {
    //parsiraj json i potrpaj sve sto treba unutra device sensitive
    NSString *device = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)? @"iphone":@"ipad";
    NSString *resourceName = [NSString stringWithFormat:@"animation_%@_%@.json", NSStringFromClass(self.class), device];

    NSString* basePath =  [[NSBundle mainBundle] pathForResource:resourceName ofType:@""];
    NSString* content = [NSString stringWithContentsOfFile:basePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSAssert([content length]>=2, ([NSString stringWithFormat:@"Cannot find state machine definition for resourceName: %@", resourceName]));

#warning implement
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
