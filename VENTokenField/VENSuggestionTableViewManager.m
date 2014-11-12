//
//  VENSuggestionTableViewManager
//  Pods
//
//  Created by Ben Nicholas on 8/8/14.
//
//

#import "VENSuggestionTableViewManager.h"
#import "VENTokenField.h"

@interface VENSuggestionTableViewManager ()

@property (nonatomic, strong) NSArray *options;

@end

@implementation VENSuggestionTableViewManager

- (instancetype)initWithTokenField:(VENTokenField *)tokenField
{
    self = [super init];
    if (self) {
        self.tokenField = tokenField;
    }
    return self;
}

- (NSString *)valueForIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource tokenField:self.tokenField suggestionTitleForPartialText:self.tokenField.inputText atIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource tokenField:self.tokenField numberOfSuggestionsForPartialText:self.tokenField.inputText];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"suggestionCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"suggestionCell"];
    }
    
    cell.textLabel.text = [self valueForIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate suggestionManagerDidSelectValue:[self valueForIndexPath:indexPath] atIndex:indexPath.row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.tokenField resignFirstResponder];
}

- (void)displayTableView
{
    [self.tableView reloadData];
    [self.tokenField.window addSubview:self.tableView];
}

- (void)hideTableView
{
    [self.tableView removeFromSuperview];
}

- (UITableView *)tableView
{
    CGRect globalTokenViewFrame = [self.tokenField convertRect:self.tokenField.bounds toView:self.tokenField.window];
    CGRect newFrame = CGRectMake(CGRectGetMinX(globalTokenViewFrame),
                                 CGRectGetMaxY(globalTokenViewFrame),
                                 CGRectGetWidth(globalTokenViewFrame),
                                 CGRectGetHeight(self.tokenField.window.frame) - CGRectGetMaxY(globalTokenViewFrame));
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:newFrame
                                                  style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    } else {
        _tableView.frame = newFrame;
    }
    return _tableView;
}

@end
