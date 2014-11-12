//
//  VENSuggestionTableViewManager.h
//  Pods
//
//  Created by Ben Nicholas on 8/8/14.
//
//

#import <UIKit/UIKit.h>

@class VENTokenField;
@protocol VENTokenSuggestionDataSource;

@protocol VENSuggestionTableViewManagerDelegate <NSObject>
- (void)suggestionManagerDidSelectValue:(NSString *)value atIndex:(NSInteger)index;
@end

@interface VENSuggestionTableViewManager : NSObject < UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate >

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) VENTokenField *tokenField;
@property (assign, nonatomic) id<VENTokenSuggestionDataSource> dataSource;
@property (assign, nonatomic) id<VENSuggestionTableViewManagerDelegate> delegate;

- (instancetype)initWithTokenField:(VENTokenField *)tokenField;

- (void)displayTableView;
- (void)hideTableView;

@end
