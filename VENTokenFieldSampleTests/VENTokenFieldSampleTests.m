//
//  VENTokenFieldSampleTests.m
//  VENTokenFieldSampleTests
//
//  Created by Ayaka Nonaka on 6/20/14.
//  Copyright (c) 2014 Venmo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KIF/KIF.h>

@interface VENTokenFieldSampleTests : XCTestCase
@end

@implementation VENTokenFieldSampleTests

- (void)testBasicFlow
{
    [tester enterTextIntoCurrentFirstResponder:@"Ayaka\n"];
    [tester waitForViewWithAccessibilityLabel:@"Ayaka,"];

    [tester enterTextIntoCurrentFirstResponder:@"Mark\n"];
    [tester waitForViewWithAccessibilityLabel:@"Mark,"];

    [tester enterTextIntoCurrentFirstResponder:@"Neeraj\n"];
    [tester waitForViewWithAccessibilityLabel:@"Neeraj,"];

    [tester enterTextIntoCurrentFirstResponder:@"Octocat\n"];
    [tester waitForViewWithAccessibilityLabel:@"Octocat,"];

    // Make sure everything else is still there.
    [tester waitForViewWithAccessibilityLabel:@"Ayaka,"];
    [tester waitForViewWithAccessibilityLabel:@"Mark,"];

    // Delete
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Octocat,"];
}

- (void)testResignFirstResponder
{
    [tester tapViewWithAccessibilityLabel:@"To"];
    [tester tapViewWithAccessibilityLabel:@"Resign First Responder"];
    [tester waitForAbsenceOfKeyboard];
}

- (void)testResignFirstResponderAndCollapse
{
    [tester tapViewWithAccessibilityLabel:@"To"];
    [tester tapViewWithAccessibilityLabel:@"Resign First Responder"];

    [tester waitForAbsenceOfKeyboard];

    [tester tapViewWithAccessibilityLabel:@"Collapse token field"];
    [tester waitForViewWithAccessibilityLabel:@"3 people"];
}

@end
