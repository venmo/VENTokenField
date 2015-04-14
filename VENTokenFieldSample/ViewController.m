//
//  ViewController.m
//  VENTokenFieldSample
//
//  Created by Ayaka Nonaka on 6/20/14.
//  Copyright (c) 2014 Venmo. All rights reserved.
//

#import "ViewController.h"
#import "VENTokenField.h"

@interface ViewController () <VENTokenFieldDelegate, VENTokenFieldDataSource>
@property (weak, nonatomic) IBOutlet VENTokenField *tokenField;
@property (strong, nonatomic) NSMutableArray *names;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.names = [NSMutableArray array];
    self.tokenField.delegate = self;
    self.tokenField.dataSource = self;
    self.tokenField.placeholderText = NSLocalizedString(@"Enter names here", nil);
    self.tokenField.toLabelText = NSLocalizedString(@"Post to:", nil);
    [self.tokenField setColorScheme:[UIColor colorWithRed:61/255.0f green:149/255.0f blue:206/255.0f alpha:1.0f]];
    [self.tokenField becomeFirstResponder];
}

- (IBAction)didTapCollapseButton:(id)sender
{
    [self.tokenField collapse];
}

- (IBAction)didTapResignFirstResponderButton:(id)sender
{
    [self.tokenField resignFirstResponder];
}

- (IBAction)fontChanged:(UISwitch *)sender
{
    if (sender.isOn) {
        self.tokenField.tokenFont = [UIFont fontWithName:@"HelveticaNeueBold" size:15.5];
    }
    else {
        self.tokenField.tokenFont = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
    }
}


#pragma mark - VENTokenFieldDelegate

- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text
{
    [self.names addObject:text];
    [self.tokenField reloadData];
}

- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index
{
    [self.names removeObjectAtIndex:index];
    [self.tokenField reloadData];
}


#pragma mark - VENTokenFieldDataSource

- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index
{
    return self.names[index];
}

- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField
{
    return [self.names count];
}

- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField
{
    return [NSString stringWithFormat:@"%tu people", [self.names count]];
}

@end
