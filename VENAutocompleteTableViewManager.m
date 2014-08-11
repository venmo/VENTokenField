//
//  VENAutocompleteTableViewManager.m
//  Pods
//
//  Created by bnicholas on 8/8/14.
//
//

#import "VENAutocompleteTableViewManager.h"

@implementation VENAutocompleteTableViewManager

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.autocompleteOptions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"autocompleteCell" forIndexPath:indexPath];
    
    cell.detailTextLabel.text = self.autocompleteOptions[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning implement this
}

- (void)setAutocompleteOptions:(NSArray *)autocompleteOptions
{
    if (!_autocompleteOptions) {
        [self displayTableView];
    }
    _autocompleteOptions = autocompleteOptions;
    if (autocompleteOptions != nil) {
        [self.tableView reloadData];
    } else {
        [self hideTableView];
    }
}

- (void)displayTableView
{
    [[[UIAlertView alloc] initWithTitle:@"Would show table"
                                message:@""
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
#warning implement this
#warning add a reusable basic cell with @"autocompleteCell" identifier
}

- (void)hideTableView
{
    [[[UIAlertView alloc] initWithTitle:@"Would hide table"
                                message:@""
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
#warning implement this
}

@end
