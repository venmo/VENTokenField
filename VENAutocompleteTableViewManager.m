//
//  VENAutocompleteTableViewManager.m
//  Pods
//
//  Created by bnicholas on 8/8/14.
//
//

#import "VENAutocompleteTableViewManager.h"
#import "VENTokenField.h"

@interface VENAutocompleteTableViewManager ()

@property (nonatomic, strong) NSArray *options;

@end

@implementation VENAutocompleteTableViewManager

- (instancetype)initWithTokenField:(VENTokenField *)tokenField
{
    self = [super init];
    if (self) {
        self.tokenField = tokenField;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"autocompleteCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"autocompleteCell"];
    }
    
    cell.textLabel.text = self.options[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning implement this
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tokenField resignFirstResponder];
}

- (void)setAutocompleteOptions:(NSArray *)autocompleteOptions
{
    if (!self.options) {
        [self displayTableView];
    }
    self.options = autocompleteOptions;
    if (autocompleteOptions != nil) {
        [self.tableView reloadData];
    } else {
        [self hideTableView];
    }
}

- (void)displayTableView
{
    [self.tokenField.superview addSubview:self.tableView];
}

- (void)hideTableView
{
    [self.tableView removeFromSuperview];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.tokenField.frame),
                                                                   CGRectGetMaxY(self.tokenField.frame),
                                                                   CGRectGetWidth(self.tokenField.frame),
                                                                   CGRectGetHeight(self.tokenField.superview.frame) - CGRectGetHeight(self.tokenField.frame))
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

@end
