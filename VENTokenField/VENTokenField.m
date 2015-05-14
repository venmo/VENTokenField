// VENTokenField.m
//
// Copyright (c) 2014 Venmo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "VENTokenField.h"

#import <FrameAccessor/FrameAccessor.h>
#import "VENToken.h"
#import "VENBackspaceTextField.h"

static const CGFloat VENTokenFieldDefaultVerticalInset      = 7.0;
static const CGFloat VENTokenFieldDefaultHorizontalInset    = 15.0;
static const CGFloat VENTokenFieldDefaultToLabelPadding     = 5.0;
static const CGFloat VENTokenFieldDefaultTokenPadding       = 2.0;
static const CGFloat VENTokenFieldDefaultMaxHeight          = 150.0;


@interface VENTokenField () <VENBackspaceTextFieldDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *tokens;
@property (assign, nonatomic) CGFloat originalHeight;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) VENBackspaceTextField *invisibleTextField;
@property (strong, nonatomic) VENBackspaceTextField *inputTextField;
@property (strong, nonatomic) UIColor *colorScheme;
@property (strong, nonatomic) UILabel *collapsedLabel;
@property (strong, nonatomic) NSString *inputTextFieldText;
@property (strong, nonatomic) UILabel *placeholderTextLabel;

@end


@implementation VENTokenField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setUpInit];
}

- (BOOL)isFirstResponder
{
    return [self.inputTextField isFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [self layoutTokensAndInputWithFrameAdjustment:YES];
    [self inputTextFieldBecomeFirstResponder];
    return YES;
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.inputTextField resignFirstResponder];
}

- (void)setUpInit
{
    // Set up default values.
    _autocorrectionType = UITextAutocorrectionTypeNo;
    _autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.maxHeight = VENTokenFieldDefaultMaxHeight;
    self.verticalInset = VENTokenFieldDefaultVerticalInset;
    self.horizontalInset = VENTokenFieldDefaultHorizontalInset;
    self.tokenPadding = VENTokenFieldDefaultTokenPadding;
    self.colorScheme = [UIColor blueColor];
    self.toLabelTextColor = [UIColor colorWithRed:112/255.0f green:124/255.0f blue:124/255.0f alpha:1.0f];
    self.inputTextFieldTextColor = [UIColor colorWithRed:38/255.0f green:39/255.0f blue:41/255.0f alpha:1.0f];
    self.tokenAlignment = VENTokenFieldAlignmentLeft;
    
    // Accessing bare value to avoid kicking off a premature layout run.
    _toLabelText = NSLocalizedString(@"To:", nil);

    self.originalHeight = CGRectGetHeight(self.frame);

    // Add invisible text field to handle backspace when we don't have a real first responder.
    [self layoutInvisibleTextField];

    [self layoutScrollView];
    [self reloadData];
}

- (void)collapse
{
    [self layoutCollapsedLabel];
}

- (void)reloadData
{
    [self layoutTokensAndInputWithFrameAdjustment:YES];
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = placeholderText;
    self.placeholderTextLabel.text = _placeholderText;
    self.placeholderTextLabel.width = [_placeholderText sizeWithAttributes:@{NSFontAttributeName:self.placeholderTextLabel.font}].width;
}

-(void)setInputTextFieldAccessibilityLabel:(NSString *)inputTextFieldAccessibilityLabel {
    _inputTextFieldAccessibilityLabel = inputTextFieldAccessibilityLabel;
    self.inputTextField.accessibilityLabel = _inputTextFieldAccessibilityLabel;
}

- (void)setInputTextFieldTextColor:(UIColor *)inputTextFieldTextColor
{
    _inputTextFieldTextColor = inputTextFieldTextColor;
    self.inputTextField.textColor = _inputTextFieldTextColor;
}

- (void)setToLabelTextColor:(UIColor *)toLabelTextColor
{
    _toLabelTextColor = toLabelTextColor;
    self.toLabel.textColor = _toLabelTextColor;
}

- (void)setToLabelText:(NSString *)toLabelText
{
    _toLabelText = toLabelText;
    [self reloadData];
}

- (void)setColorScheme:(UIColor *)color
{
    _colorScheme = color;
    self.collapsedLabel.textColor = color;
    self.inputTextField.tintColor = color;
    for (VENToken *token in self.tokens) {
        [token setColorScheme:color];
    }
}

- (void)setInputTextFieldAccessoryView:(UIView *)inputTextFieldAccessoryView
{
    _inputTextFieldAccessoryView = inputTextFieldAccessoryView;
    self.inputTextField.inputAccessoryView = _inputTextFieldAccessoryView;
}

- (NSString *)inputText
{
    return self.inputTextField.text;
}

- (void)setTokenAlignment:(VENTokenFieldAlignment)alignment
{
    _tokenAlignment = alignment;
    self.collapsedLabel.textAlignment = (NSTextAlignment)alignment;
    self.placeholderTextLabel.textAlignment = (NSTextAlignment)alignment;
}


#pragma mark - View Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) - self.horizontalInset * 2, CGRectGetHeight(self.frame) - self.verticalInset * 2);
    if ([self isCollapsed]) {
        [self layoutCollapsedLabel];
    } else {
        [self layoutTokensAndInputWithFrameAdjustment:NO];
    }
}

- (void)layoutCollapsedLabel
{
    [self.collapsedLabel removeFromSuperview];
    self.scrollView.hidden = YES;
    [self setHeight:self.originalHeight];

    CGFloat currentX = 0;
    [self layoutToLabelInView:self origin:CGPointMake(self.horizontalInset, self.verticalInset) currentX:&currentX];
    [self layoutCollapsedLabelWithCurrentX:&currentX];
    self.collapsedLabel.textAlignment = (NSTextAlignment)self.tokenAlignment;

    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)layoutTokensAndInputWithFrameAdjustment:(BOOL)shouldAdjustFrame
{
    [self.collapsedLabel removeFromSuperview];
    BOOL inputFieldShouldBecomeFirstResponder = self.inputTextField.isFirstResponder;
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollView.hidden = NO;
    [self removeGestureRecognizer:self.tapGestureRecognizer];

    self.tokens = [NSMutableArray array];

    CGFloat currentX = 0;
    CGFloat currentY = 0;

    [self layoutToLabelInView:self.scrollView origin:CGPointZero currentX:&currentX];
    [self layoutTokensWithCurrentX:&currentX currentY:&currentY];
    [self layoutInputTextFieldWithCurrentX:&currentX currentY:&currentY];

    if (shouldAdjustFrame) {
        [self adjustHeightForCurrentY:currentY];
    }

    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, currentY + [self heightForToken])];

    [self updatePlaceholderTextLabel];

    if (inputFieldShouldBecomeFirstResponder) {
        [self inputTextFieldBecomeFirstResponder];
    } else {
        [self focusInputTextField];
    }
}

- (BOOL)isCollapsed
{
    return self.collapsedLabel.superview != nil;
}

- (void)layoutScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) - self.horizontalInset * 2, CGRectGetHeight(self.frame) - self.verticalInset * 2);
    self.scrollView.contentInset = UIEdgeInsetsMake(self.verticalInset,
                                                    self.horizontalInset,
                                                    self.verticalInset,
                                                    self.horizontalInset);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [self addSubview:self.scrollView];
}

- (void)layoutInputTextFieldWithCurrentX:(CGFloat *)currentX currentY:(CGFloat *)currentY
{
    VENBackspaceTextField *inputTextField = self.inputTextField;
    inputTextField.text = self.inputTextFieldText;
    inputTextField.frame = CGRectMake(*currentX, *currentY + 1, self.scrollView.contentSize.width - *currentX, [self heightForToken] - 1);
    inputTextField.tintColor = self.colorScheme;
    [self.scrollView addSubview:inputTextField];
}

- (void)layoutCollapsedLabelWithCurrentX:(CGFloat *)currentX
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(*currentX, CGRectGetMinY(self.toLabel.frame), self.width - *currentX - self.horizontalInset, self.toLabel.height)];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
    label.text = [self collapsedText];
    label.textColor = self.colorScheme;
    label.minimumScaleFactor = 5./label.font.pointSize;
    label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:label];
    self.collapsedLabel = label;
}

- (void)layoutToLabelInView:(UIView *)view origin:(CGPoint)origin currentX:(CGFloat *)currentX
{
    [self.toLabel removeFromSuperview];
    self.toLabel = [self toLabel];
    
    CGRect newFrame = self.toLabel.frame;
    newFrame.origin = origin;
    
    [self.toLabel sizeToFit];
    newFrame.size.width = CGRectGetWidth(self.toLabel.frame);
    
    self.toLabel.frame = newFrame;
    
    [view addSubview:self.toLabel];
    *currentX += self.toLabel.hidden ? CGRectGetMinX(self.toLabel.frame) : CGRectGetMaxX(self.toLabel.frame) + VENTokenFieldDefaultToLabelPadding;
}

- (void)layoutTokensWithCurrentX:(CGFloat *)currentX currentY:(CGFloat *)currentY
{
    for (NSUInteger i = 0; i < [self numberOfTokens]; i++) {
        NSString *title = [self titleForTokenAtIndex:i];
        VENToken *token = [[VENToken alloc] init];
        __weak VENToken *weakToken = token;
        __weak VENTokenField *weakSelf = self;
        token.didTapTokenBlock = ^{
            [weakSelf didTapToken:weakToken];
        };

        [token setTitleText:[NSString stringWithFormat:@"%@,", title]];
        token.colorScheme = [self colorSchemeForTokenAtIndex:i];
        
        [self.tokens addObject:token];

        token.frame = [self frameForToken:token currentX:currentX currentY:currentY];
        *currentX += token.width + self.tokenPadding;
        [self.scrollView addSubview:token];
    }

    VENToken *placeholderToken = [[VENToken alloc] init];
    [placeholderToken setTitleText:[self.inputTextFieldText stringByAppendingString:@"| "]]; // account for text field cursor and space
    placeholderToken.frame = [self frameForToken:placeholderToken currentX:currentX currentY:currentY];

    [self realignTokens:[self.tokens arrayByAddingObject:placeholderToken]
               currentX:currentX
              alignment:self.tokenAlignment];
}

- (CGRect)frameForToken:(VENToken *)token currentX:(CGFloat *)currentX currentY:(CGFloat *)currentY {
    if (*currentX + token.width <= self.scrollView.contentSize.width) { // token fits in current line
        return CGRectMake(*currentX, *currentY, token.width, token.height);
    } else {
        *currentY += token.height;
        *currentX = 0;
        CGFloat tokenWidth = token.width;
        if (tokenWidth > self.scrollView.contentSize.width) { // token is wider than max width
            tokenWidth = self.scrollView.contentSize.width;
        }
        return CGRectMake(*currentX, *currentY, tokenWidth, token.height);
    }
}

- (void)realignTokens:(NSArray *)tokens
             currentX:(CGFloat *)currentX
            alignment:(VENTokenFieldAlignment)alignment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (VENToken *token in tokens) {
        if (dict[@(token.y)]) {
            dict[@(token.y)] = [dict[@(token.y)] arrayByAddingObject:token];
        } else {
            dict[@(token.y)] = @[token];
        }
    }
    // Could be parallelized: compute all new frames on background threads.
    // Once done, assign new frames to tokens on main thread.
    CGFloat currentY = 0;
    for (NSNumber *rowY in [dict allKeys]) {
        [self realignRowOfTokens:dict[rowY] currentX:currentX currentY:&currentY alignment:alignment];
    }
}

- (void)realignRowOfTokens:(NSArray *)tokens
                  currentX:(CGFloat *)currentX
                  currentY:(CGFloat *)currentY
                 alignment:(VENTokenFieldAlignment)alignment
{
    // This method is unreliant on the order of tokens. It could be faster if it was reliant.
    VENToken *firstToken = [tokens firstObject];
    VENToken *lastToken = [tokens firstObject];
    CGFloat totalLineWidth = 0;
    for (VENToken *token in tokens) {
        if (token.x < firstToken.x) {
            firstToken = token;
        }
        if (token.x > lastToken.x) {
            lastToken = token;
        }
        totalLineWidth += token.width;
    }
    CGFloat frameAdjustment = 0;
    switch (self.tokenAlignment) {
        case VENTokenFieldAlignmentCenter: {
            frameAdjustment = (self.scrollView.contentSize.width - firstToken.x - totalLineWidth) / 2.0;
            break;
        }
        default:
            break;
    }
    for (VENToken *token in tokens) {
        token.x += frameAdjustment;
    }
    if (firstToken.y >= *currentY) {
        *currentX = lastToken.x;
        *currentY = lastToken.y;
    }
}


#pragma mark - Private

- (CGFloat)heightForToken
{
    return 30;
}

- (void)layoutInvisibleTextField
{
    self.invisibleTextField = [[VENBackspaceTextField alloc] initWithFrame:CGRectZero];
    [self.invisibleTextField setAutocorrectionType:self.autocorrectionType];
    [self.invisibleTextField setAutocapitalizationType:self.autocapitalizationType];
    self.invisibleTextField.backspaceDelegate = self;
    [self addSubview:self.invisibleTextField];
}

- (void)inputTextFieldBecomeFirstResponder
{
    if (self.inputTextField.isFirstResponder) {
        return;
    }

    [self.inputTextField becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidBeginEditing:)]) {
        [self.delegate tokenFieldDidBeginEditing:self];
    }
}

- (UILabel *)toLabel
{
    if (!_toLabel) {
        _toLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _toLabel.textColor = self.toLabelTextColor;
        _toLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
        _toLabel.x = 0;
        [_toLabel sizeToFit];
        [_toLabel setHeight:[self heightForToken]];
    }
    if (![_toLabel.text isEqualToString:_toLabelText]) {
        _toLabel.text = _toLabelText;
    }
    return _toLabel;
}

- (UILabel *)placeholderTextLabel
{
    if (!_placeholderTextLabel) {
        _placeholderTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0,
                                                                          [self heightForToken])];
        _placeholderTextLabel.font = self.inputTextField.font;
        _placeholderTextLabel.textAlignment = (NSTextAlignment)self.tokenAlignment;
        _placeholderTextLabel.textColor = [UIColor colorWithWhite:.8 alpha:1];
        [_placeholderTextLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self.inputTextField
                                                                                            action:@selector(becomeFirstResponder)]];
        _placeholderTextLabel.userInteractionEnabled = YES;
    }
    return _placeholderTextLabel;
}

- (void)adjustHeightForCurrentY:(CGFloat)currentY
{
    if (currentY + [self heightForToken] > CGRectGetHeight(self.frame)) { // needs to grow
        if (currentY + [self heightForToken] <= self.maxHeight) {
            [self setHeight:currentY + [self heightForToken] + self.verticalInset * 2];
        } else {
            [self setHeight:self.maxHeight];
        }
    } else { // needs to shrink
        if (currentY + [self heightForToken] > self.originalHeight) {
            [self setHeight:currentY + [self heightForToken] + self.verticalInset * 2];
        } else {
            [self setHeight:self.originalHeight];
        }
    }
}

- (VENBackspaceTextField *)inputTextField
{
    if (!_inputTextField) {
        _inputTextField = [[VENBackspaceTextField alloc] init];
        [_inputTextField setKeyboardType:self.inputTextFieldKeyboardType];
        _inputTextField.textColor = self.inputTextFieldTextColor;
        _inputTextField.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
        _inputTextField.autocorrectionType = self.autocorrectionType;
        _inputTextField.autocapitalizationType = self.autocapitalizationType;
        _inputTextField.tintColor = self.colorScheme;
        _inputTextField.delegate = self;
        _inputTextField.backspaceDelegate = self;
        _inputTextField.accessibilityLabel = self.inputTextFieldAccessibilityLabel ?: NSLocalizedString(@"To", nil);
        _inputTextField.inputAccessoryView = self.inputTextFieldAccessoryView;
        [_inputTextField addTarget:self action:@selector(inputTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _inputTextField;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
    _autocorrectionType = autocorrectionType;
    [self.inputTextField setAutocorrectionType:self.autocorrectionType];
    [self.invisibleTextField setAutocorrectionType:self.autocorrectionType];
}

- (void)setInputTextFieldKeyboardType:(UIKeyboardType)inputTextFieldKeyboardType
{
    _inputTextFieldKeyboardType = inputTextFieldKeyboardType;
    [self.inputTextField setKeyboardType:self.inputTextFieldKeyboardType];
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
{
    _autocapitalizationType = autocapitalizationType;
    [self.inputTextField setAutocapitalizationType:self.autocapitalizationType];
    [self.invisibleTextField setAutocapitalizationType:self.autocapitalizationType];
}

- (void)inputTextFieldDidChange:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenField:didChangeText:)]) {
        [self.delegate tokenField:self didChangeText:textField.text];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self becomeFirstResponder];
}

- (void)didTapToken:(VENToken *)token
{
    for (VENToken *aToken in self.tokens) {
        if (aToken == token) {
            aToken.highlighted = !aToken.highlighted;
        } else {
            aToken.highlighted = NO;
        }
    }
    [self setCursorVisibility];
}

- (void)unhighlightAllTokens
{
    for (VENToken *token in self.tokens) {
        token.highlighted = NO;
    }
    
    [self setCursorVisibility];
}

- (void)setCursorVisibility
{
    NSArray *highlightedTokens = [self.tokens filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(VENToken *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.highlighted;
    }]];
    
    BOOL visible = [highlightedTokens count] == 0;
    if (visible) {
        [self inputTextFieldBecomeFirstResponder];
    } else {
        [self.invisibleTextField becomeFirstResponder];
    }
}

- (void)updatePlaceholderTextLabel
{
    if (![self.tokens count] && self.inputTextFieldText.length == 0) {
        switch (self.tokenAlignment) {
            case VENTokenFieldAlignmentCenter:
                self.placeholderTextLabel.centerX = self.inputTextField.x;
                self.inputTextField.x = self.placeholderTextLabel.x;
                break;
            case VENTokenFieldAlignmentLeft:
                self.placeholderTextLabel.x = self.inputTextField.x;
                break;
            default:
                break;
        }
        [self.scrollView insertSubview:self.placeholderTextLabel belowSubview:self.inputTextField];
    } else {
        [self.placeholderTextLabel removeFromSuperview];
    }
}

- (void)focusInputTextField
{
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat targetY = self.inputTextField.y + [self heightForToken] - self.maxHeight;
    if (targetY > contentOffset.y) {
        [self.scrollView setContentOffset:CGPointMake(contentOffset.x, targetY) animated:NO];
    }
}

- (UIColor *)colorSchemeForTokenAtIndex:(NSUInteger)index {
    
    if ([self.dataSource respondsToSelector:@selector(tokenField:colorSchemeForTokenAtIndex:)]) {
        return [self.dataSource tokenField:self colorSchemeForTokenAtIndex:index];
    }
    
    return self.colorScheme;
}


#pragma mark - Data Source

- (NSString *)titleForTokenAtIndex:(NSUInteger)index
{
    if (index == [self numberOfTokens]) {
        return self.inputTextFieldText;
    } else if ([self.dataSource respondsToSelector:@selector(tokenField:titleForTokenAtIndex:)]) {
        return [self.dataSource tokenField:self titleForTokenAtIndex:index];
    }
    
    return [NSString string];
}

- (NSUInteger)numberOfTokens
{
    if ([self.dataSource respondsToSelector:@selector(numberOfTokensInTokenField:)]) {
        return [self.dataSource numberOfTokensInTokenField:self];
    }
    
    return 0;
}

- (NSString *)collapsedText
{
    if ([self.dataSource respondsToSelector:@selector(tokenFieldCollapsedText:)]) {
        return [self.dataSource tokenFieldCollapsedText:self];
    }
    
    return @"";
}


#pragma mark - Delegate

- (void)didEnterText:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(tokenField:didEnterText:)]) {
        if ([text length]) {
            self.inputTextFieldText = @"";
            [self.delegate tokenField:self didEnterText:text];
        }
    }
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self didEnterText:textField.text];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.inputTextField) {
        [self unhighlightAllTokens];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self unhighlightAllTokens];
    if (textField == self.inputTextField) {
        self.inputTextFieldText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        [self reloadData];
        return NO;
    }
    return YES;
}


#pragma mark - VENBackspaceTextFieldDelegate

- (void)textFieldDidEnterBackspace:(VENBackspaceTextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenField:didDeleteTokenAtIndex:)] && [self numberOfTokens]) {
        BOOL didDeleteToken = NO;
        for (VENToken *token in self.tokens) {
            if (token.highlighted) {
                [self.delegate tokenField:self didDeleteTokenAtIndex:[self.tokens indexOfObject:token]];
                didDeleteToken = YES;
                break;
            }
        }
        if (!didDeleteToken) {
            VENToken *lastToken = [self.tokens lastObject];
            lastToken.highlighted = YES;
        }
        [self setCursorVisibility];
    }
}

@end
