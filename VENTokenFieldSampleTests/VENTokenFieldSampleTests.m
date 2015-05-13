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

    [tester enterTextIntoCurrentFirstResponder:@"Steven,"];
    [tester waitForViewWithAccessibilityLabel:@"Steven,"];

    [tester enterTextIntoCurrentFirstResponder:@"Andy;"];
    [tester waitForViewWithAccessibilityLabel:@"Andy,"];
    
    [tester enterTextIntoCurrentFirstResponder:@"Sam--"];
    [tester waitForViewWithAccessibilityLabel:@"Sam,"];

    // Make sure everything else is still there.
    [tester waitForViewWithAccessibilityLabel:@"Ayaka,"];
    [tester waitForViewWithAccessibilityLabel:@"Mark,"];
    [tester waitForViewWithAccessibilityLabel:@"Neeraj,"];
    [tester waitForViewWithAccessibilityLabel:@"Octocat,"];
    [tester waitForViewWithAccessibilityLabel:@"Steven,"];
    [tester waitForViewWithAccessibilityLabel:@"Andy,"];
    [tester waitForViewWithAccessibilityLabel:@"Sam,"];

    // Delete
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester waitForAbsenceOfViewWithAccessibilityLabel:@"Sam,"];

    // Clear remaining names to reset state for next test
    [tester tapViewWithAccessibilityLabel:@"To"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
}

- (void)testResignFirstResponder
{
    [tester tapViewWithAccessibilityLabel:@"To"];
    [tester tapViewWithAccessibilityLabel:@"Resign First Responder"];
    [tester waitForAbsenceOfSoftwareKeyboard];
}

- (void)testResignFirstResponderAndCollapse
{
    [tester tapViewWithAccessibilityLabel:@"To"];
    [tester tapViewWithAccessibilityLabel:@"Resign First Responder"];
    [tester waitForAbsenceOfSoftwareKeyboard];
    [tester tapViewWithAccessibilityLabel:@"Collapse token field"];

    // Confirm the collapse lable
    [tester waitForViewWithAccessibilityLabel:@"0 people"];

    // Tap on the field and enter names. Lable isn't tappable, so tap the point.
    UIView *tokenField = [tester waitForViewWithAccessibilityLabel:@"0 people"];
    [tester tapScreenAtPoint:tokenField.center];
    [tester waitForSoftwareKeyboard];

    [tester enterTextIntoCurrentFirstResponder:@"Ayaka\n"];
    [tester waitForViewWithAccessibilityLabel:@"Ayaka,"];

    [tester enterTextIntoCurrentFirstResponder:@"Mark\n"];
    [tester waitForViewWithAccessibilityLabel:@"Mark,"];

    [tester enterTextIntoCurrentFirstResponder:@"Neeraj\n"];
    [tester waitForViewWithAccessibilityLabel:@"Neeraj,"];

    [tester enterTextIntoCurrentFirstResponder:@"Octocat\n"];
    [tester waitForViewWithAccessibilityLabel:@"Octocat,"];

    [tester enterTextIntoCurrentFirstResponder:@"Steven,"];
    [tester waitForViewWithAccessibilityLabel:@"Steven,"];

    [tester enterTextIntoCurrentFirstResponder:@"Andy;"];
    [tester waitForViewWithAccessibilityLabel:@"Andy,"];
    
    [tester enterTextIntoCurrentFirstResponder:@"Sam--"];
    [tester waitForViewWithAccessibilityLabel:@"Sam,"];

    [tester tapViewWithAccessibilityLabel:@"Resign First Responder"];
    [tester waitForAbsenceOfSoftwareKeyboard];
    [tester tapViewWithAccessibilityLabel:@"Collapse token field"];

    // Confirm the collapse label
    [tester waitForViewWithAccessibilityLabel:@"7 people"];

    // Remove one name and check again
    [tester tapScreenAtPoint:tokenField.center];
    [tester waitForSoftwareKeyboard];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester enterTextIntoCurrentFirstResponder:@"\b"];
    [tester tapViewWithAccessibilityLabel:@"Resign First Responder"];
    [tester waitForAbsenceOfSoftwareKeyboard];
    [tester tapViewWithAccessibilityLabel:@"Collapse token field"];
    [tester waitForViewWithAccessibilityLabel:@"6 people"];
}

@end
