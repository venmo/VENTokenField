//
//  VENAutocompleteTableViewManager.h
//  Pods
//
//  Created by bnicholas on 8/8/14.
//
//

#import <UIKit/UIKit.h>

@class VENTokenField;
@protocol VENTokenAutocompleteDataSource;

@protocol VENAutocompleteTableViewManagerDelegate <NSObject>
- (void)autocompleteManagerDidSelectValue:(NSString *)value;
@end

@interface VENAutocompleteTableViewManager : NSObject < UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate >

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) VENTokenField *tokenField;
@property (assign, nonatomic) id<VENTokenAutocompleteDataSource> dataSource;
@property (assign, nonatomic) id<VENAutocompleteTableViewManagerDelegate> delegate;

- (instancetype)initWithTokenField:(VENTokenField *)tokenField;

- (void)displayTableView;
- (void)hideTableView;

@end
