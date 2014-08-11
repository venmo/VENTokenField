//
//  VENAutocompleteTableViewManager.h
//  Pods
//
//  Created by bnicholas on 8/8/14.
//
//

#import <UIKit/UIKit.h>

@class VENTokenField;

@protocol VENAutocompleteTableViewManagerDelegate <NSObject>
- (void)autocompleteManagerDidSelectValue:(NSString *)value;
@end

@interface VENAutocompleteTableViewManager : NSObject < UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate >

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) VENTokenField *tokenField;
//@property (strong, nonatomic) NSArray *autocompleteOptions;
@property (assign, nonatomic) id<VENAutocompleteTableViewManagerDelegate> delegate;

- (instancetype)initWithTokenField:(VENTokenField *)tokenField;

- (void)displayTableView;
- (void)hideTableView;

- (void)setAutocompleteOptions:(NSArray *)autocompleteOptions;

@end
