VENTokenField
=============

```VENTokenField``` is the recipients token field that is used in the Venmo compose screen.

Installation
------------
The easiest way to get started is to use [CocoaPods](http://cocoapods.org/). Just add the following line to your Podfile:

```ruby
pod 'VENTokenField', '~>1.0.0'
```

Usage
-----

If you've ever used a ```UITableView```, using ```VENTokenField``` should be a breeze.

Similar to ```UITableView```, ```VENTokenField``` provides two protocols: ```<VENTokenFieldDelegate>``` and ```<VENTokenFieldDataSource>```.

### <VENTokenFieldDelegate>
This protocol notifies you when things happen in the token field that you might want to know about.

* ```tokenField:didEnterText:``` is called when a user hits the return key on the input field.
* ```tokenField:didDeleteTokenAtIndex:``` is called when a user deletes a token at a particular index.
* ```tokenField:didChangeText:``` is called when a user changes the text in the input field.
* ```tokenFieldDidBeginEditing:``` is called when the input field becomes first responder.

Contributing
------------

We'd love to see your ideas for improving this library! The best way to contribute is by submitting a pull request. We'll do our best to respond to your patch as soon as possible. You can also submit a [new Github issue](https://github.com/venmo/VENCalculatorInputView/issues/new) if you find bugs or have questions. :octocat:

Please make sure to follow our general coding style and add test coverage for new features!
