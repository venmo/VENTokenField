VENTokenField
=============
[![Build Status](https://travis-ci.org/venmo/VENTokenField.svg?branch=master)](https://travis-ci.org/venmo/VENTokenField)

```VENTokenField``` is the recipients token field that is used in the Venmo compose screen.

![alt text](http://i.imgur.com/a1FfEBi.gif "VENTokenField demo")

Installation
------------
The easiest way to get started is to use [CocoaPods](http://cocoapods.org/). Just add the following line to your Podfile:

```ruby
pod 'VENTokenField', '~> 2.0'
```

Usage
-----

If you've ever used a ```UITableView```, using ```VENTokenField``` should be a breeze.

Similar to ```UITableView```, ```VENTokenField``` provides two protocols: ```<VENTokenFieldDelegate>``` and ```<VENTokenFieldDataSource>```.

### VENTokenFieldDelegate
This protocol notifies you when things happen in the token field that you might want to know about.

* ```tokenField:didEnterText:``` is called when a user hits the return key on the input field.
* ```tokenField:didDeleteTokenAtIndex:``` is called when a user deletes a token at a particular index.
* ```tokenField:didChangeText:``` is called when a user changes the text in the input field.
* ```tokenFieldDidBeginEditing:``` is called when the input field becomes first responder.

### VENTokenFieldDataSource
This protocol allows you to provide info about what you want to present in the token field.

Implement...
* ```tokenField:titleForTokenAtIndex:``` to specify what the title for the token at a particular index should be.
* ```numberOfTokensInTokenField:``` to specify how many tokens you have.
* ```tokenFieldCollapsedText:``` to specify what you want the token field to say in the collapsed state.

Sample Project
--------------
Check out the [sample project](https://github.com/venmo/VENTokenField/tree/master/VENTokenFieldSample) in this repo for sample usage.

Contributing
------------

We'd love to see your ideas for improving this library! The best way to contribute is by submitting a pull request. We'll do our best to respond to your patch as soon as possible. You can also submit a [new GitHub issue](https://github.com/venmo/VENTokenField/issues/new) if you find bugs or have questions. :octocat:

Please make sure to follow our general coding style and add test coverage for new features!
