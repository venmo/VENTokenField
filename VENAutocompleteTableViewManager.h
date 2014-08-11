//
//  VENAutocompleteTableViewManager.h
//  Pods
//
//  Created by bnicholas on 8/8/14.
//
//

#import <UIKit/UIKit.h>

@protocol VENAutocompleteTableViewManagerDelegate <NSObject>

@end

@interface VENAutocompleteTableViewManager : NSObject < UITableViewDataSource, UITableViewDelegate >

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *autocompleteOptions;
@property (assign, nonatomic) id<VENAutocompleteTableViewManagerDelegate> delegate;

- (void)displayTableView;
- (void)hideTableView;

@end
