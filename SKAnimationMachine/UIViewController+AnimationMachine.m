//
//  UIViewController+AnimationMachine.m
//  SKAnimationMachine
//
//  Created by Slavko Krucaj on 6.9.2012..
//  Copyright (c) 2012. slavko.krucaj@gmail.com. All rights reserved.
//

#import "UIViewController+AnimationMachine.h"
#import <objc/runtime.h>
#import "JSONKit.h"

#define kAffineIdentity 0
#define kAffineRotation 1
#define kAffineScale 2
#define kAffineTranslate 3

#define kEaseIn 0
#define kEaseOut 1
#define kEaseInOut 2
#define kLinear 3


static char CURRENT_STATE;
static char ANIMATION_DELEGATE;
static char MACHINES;
static char MACHINE_ANIMATION_RUNNER;
static char MACHINE_RUNNER;

@implementation SKView

@synthesize animatedViewTag;
@synthesize alpha;
@synthesize frame;
@synthesize transform;

- (NSString *)description {
    return [NSString stringWithFormat:@"tag: %@, alpha: %f, frame: %@, transform: %@", animatedViewTag, alpha, NSStringFromCGRect(frame),@"nesto"];
}

@end

@implementation SKState

@synthesize stateId;
@synthesize views;
@synthesize transitions;
@synthesize initial;

- (void)addTransition:(SKTransition *)transition {
    if (self.transitions == nil) self.transitions = [NSMutableDictionary dictionary];
    [self.transitions setObject:transition forKey:transition.transitionId];
}

- (void)addView:(SKView *)view {
    if (self.views == nil) self.views = [NSMutableArray array];
    [self.views addObject:view];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"state Id:%@, views:%@, transitions:%@",self.stateId,self.views,self.transitions];
}

@end

@implementation SKTransition

@synthesize transitionId;
@synthesize toStateId;
@synthesize duration;
@synthesize animationCurve;
@synthesize delay;
@synthesize nextTransitionId;

@end

@implementation UIViewController (AnimationMachine)

@dynamic currentState;
@dynamic animationDelegate;
@dynamic machines;
@dynamic machineAnimationRunner;
@dynamic machineRunning;

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
    
    if (self.machineRunning == nil) self.machineRunning = [NSMutableDictionary dictionary];
    [self.machineRunning setObject:[NSNumber numberWithBool:YES] forKey:machine];
    
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
                         NSString *nextTransition = transition.nextTransitionId;
                         [self.currentState setObject:nextState forKey:machine];
                         
                         if ([[self.machineAnimationRunner objectForKey:machine] boolValue]) {
                             [self.machineRunning setObject:[NSNumber numberWithBool:NO] forKey:machine];
                             [self.machineAnimationRunner setObject:[NSNumber numberWithBool:NO] forKey:machine];
                             [self.animationDelegate forceStopedAnimationInState:nextState.stateId onMachine:machine];
                             return;
                         }
                         
                         if (nextTransition != nil) {
                             [self.animationDelegate movedFromState:oldStateId toState:nextState.stateId onMachine:machine];
                             [self performTransition:nextTransition onMachine:machine];
                         } else {
                             [self.machineRunning setObject:[NSNumber numberWithBool:NO] forKey:machine];
                             [self.animationDelegate finishedAnimationFromState:oldStateId toState:nextState.stateId onMachine:machine];
                         }
                     }];

}

- (void)stopAnimationsOnMachine:(NSString *)machine {
    if (!self.machineAnimationRunner) {
        self.machineAnimationRunner = [NSMutableDictionary dictionary];
    }
    [self.machineAnimationRunner setObject:[NSNumber numberWithBool:YES] forKey:machine];
}

- (void)goToState:(NSString *)stateId withTransition:(SKTransition *)transition onMachine:(NSString *)machine {
    
    if (self.machineRunning == nil) self.machineRunning = [NSMutableDictionary dictionary];
    [self.machineRunning setObject:[NSNumber numberWithBool:YES] forKey:machine];
    
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
                         
                         NSString *oldStateId = ((SKState *)[self.currentState objectForKey:machine]).stateId;
                         NSString *nextTransition = transition.nextTransitionId;
                         [self.currentState setObject:nextState forKey:machine];
                         
                         if (nextTransition != nil) {
                             [self.animationDelegate movedFromState:oldStateId toState:nextState.stateId onMachine:machine];
                             [self performTransition:nextTransition onMachine:machine];
                         } else {
                                 [self.machineRunning setObject:[NSNumber numberWithBool:NO] forKey:machine];
                             [self.animationDelegate finishedAnimationFromState:oldStateId toState:nextState.stateId onMachine:machine];
                         }
                     }];

}

- (NSMutableDictionary *)currentState {
    return objc_getAssociatedObject(self, &CURRENT_STATE);
}

- (void)setCurrentState:(NSMutableDictionary *)_currentState {
    objc_setAssociatedObject(self, &CURRENT_STATE, _currentState, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<SKAnimationMachineProtocol>)animationDelegate {
    return objc_getAssociatedObject(self, &ANIMATION_DELEGATE);
}

- (void)setAnimationDelegate:(id<SKAnimationMachineProtocol>)_animationDelegate {
    objc_setAssociatedObject(self, &ANIMATION_DELEGATE, _animationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)machines {
    return objc_getAssociatedObject(self, &MACHINES);
}

- (void)setMachines:(NSMutableDictionary *)_machines {
    objc_setAssociatedObject(self, &MACHINES, _machines, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)machineAnimationRunner {
    return objc_getAssociatedObject(self, &MACHINE_ANIMATION_RUNNER);
}

- (void)setMachineAnimationRunner:(NSMutableDictionary *)_machineAnimationRunner {
    objc_setAssociatedObject(self, &MACHINE_ANIMATION_RUNNER, _machineAnimationRunner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)machineRunning {
    return objc_getAssociatedObject(self, &MACHINE_RUNNER);
}

- (void)setMachineRunning:(NSMutableDictionary *)_machineRunner {
    objc_setAssociatedObject(self, &MACHINE_RUNNER, _machineRunner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SKView *)parseView:(NSDictionary *)view {
    SKView *skView = [[SKView alloc] init];
    skView.animatedViewTag = [view objectForKey:@"animatedViewTag"];
    skView.alpha = [[view objectForKey:@"alpha"] floatValue];
    skView.frame = CGRectFromString([view objectForKey:@"rect"]);
    
    CGAffineTransform affineTransformation = CGAffineTransformIdentity;
    
    for (NSDictionary *transform in [view objectForKey:@"transformations"]) {
        int transformationId = [[transform objectForKey:@"id"] intValue];
        
        if (transformationId == kAffineIdentity) 
        
            affineTransformation = CGAffineTransformIdentity;
        
        else if (transformationId == kAffineRotation) {

            int alpha = [[transform objectForKey:@"alpha"] intValue] / 180.;
            affineTransformation = CGAffineTransformRotate(affineTransformation, alpha*M_PI); 
        
        } else if (transformationId == kAffineScale) {
            
            double sx = [[transform objectForKey:@"sx"] doubleValue];
            double sy = [[transform objectForKey:@"sy"] doubleValue];
            
            affineTransformation = CGAffineTransformScale(affineTransformation, sx, sy);
            
        } else if (transformationId == kAffineTranslate) {
        
            double tx = [[transform objectForKey:@"tx"] doubleValue];
            double ty = [[transform objectForKey:@"ty"] doubleValue];
            
            affineTransformation = CGAffineTransformTranslate(affineTransformation, tx, ty);
            
        }
    }
    
    skView.transform = affineTransformation;
    
    return skView;
}

- (SKTransition *)parseTransition:(NSDictionary *)transition {
    SKTransition *skTransition = [[SKTransition alloc] init];
    skTransition.transitionId = [transition objectForKey:@"transitionId"];
    skTransition.toStateId = [transition objectForKey:@"toStateId"];
    skTransition.duration = [[transition objectForKey:@"duration"] doubleValue];
    skTransition.delay = [[transition objectForKey:@"delay"] doubleValue];
    skTransition.nextTransitionId = [transition objectForKey:@"nextTransitionId"];
    
    int easingCurveId = [[transition objectForKey:@"animationCurve"] intValue];
    switch (easingCurveId) {
        case kEaseIn:skTransition.animationCurve = UIViewAnimationCurveEaseIn;break;
        case kEaseOut:skTransition.animationCurve = UIViewAnimationCurveEaseOut;break;
        case kEaseInOut:skTransition.animationCurve = UIViewAnimationCurveEaseInOut;break;
        case kLinear:skTransition.animationCurve = UIViewAnimationCurveLinear;break;
            
        default:skTransition.animationCurve = UIViewAnimationCurveEaseInOut;
    }
    
    return skTransition;
}

- (void)initializeAnimationStateMachine {

    NSString *device = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)? @"iphone":@"ipad";
    NSString *resourceName = [NSString stringWithFormat:@"animation_%@_%@.json", NSStringFromClass(self.class), device];
    
    NSString* basePath =  [[NSBundle mainBundle] pathForResource:resourceName ofType:@""];
    NSString* content = [NSString stringWithContentsOfFile:basePath encoding:NSUTF8StringEncoding error:NULL];
    
    NSAssert([content length]>=2, ([NSString stringWithFormat:@"Cannot find state machine definition for resourceName: %@", resourceName]));
    
    NSArray *machines = [content objectFromJSONString];
    for (NSDictionary *machine in machines) {
        
        NSString *machineId = [machine objectForKey:@"machine"];
        NSArray *states = [machine objectForKey:@"states"];
        
        for (NSDictionary *state in states) {
            
            SKState *skState = [[SKState alloc] init];
            skState.stateId = [state objectForKey:@"stateId"];
            skState.initial = [[state objectForKey:@"initial"] boolValue];
            
            for (NSDictionary *viewInState in [state objectForKey:@"views"])
                [skState addView:[self parseView:viewInState]];

            for (NSDictionary *transitionInState in [state objectForKey:@"transitions"])
                [skState addTransition:[self parseTransition:transitionInState]];
            
            [self addState:skState toMachine:machineId];

            if (skState.initial) {
                [self initialize:skState.stateId onMachine:machineId];
            }
        }
        
    }
}

- (BOOL)animationRunningOnMachine:(NSString *)machine {
    return [[self.machineRunning objectForKey:machine] boolValue];
}

- (void)initializeAnimationStateMachineWithDelegate:(id<SKAnimationMachineProtocol>)delegate {
    [self initializeAnimationStateMachine];
    self.animationDelegate = delegate;
}

@end
