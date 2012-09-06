//
//  slavkoViewController.m
//  SKAnimationMachine
//
//  Created by Slavko Krucaj on 6.9.2012..
//  Copyright (c) 2012. slavko.krucaj@gmail.com. All rights reserved.
//

#import "slavkoViewController.h"
#import "UIViewController+AnimationMachine.h"

@interface slavkoViewController ()

@end

@implementation slavkoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    HelperPair *pair = [HelperPair pairWithLabel:@"test" value:@"test12"];
    
    NSLog(@"Pair je %@, %@", pair.label, pair.value);
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
