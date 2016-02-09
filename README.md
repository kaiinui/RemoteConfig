# RemoteConfig

Easy remote configuration for iOS with Google Spreadsheet.

![](https://i.gyazo.com/be33a058ed64d3344a4a1895bf82c9d1.png)

```objc
[RMTConfig startWithURL:@"https://docs.google.com/spreadsheets/d/1NanRTook1EeXpfIbVNR-tmGSo9h-2LSsdxJQE3n7NYM/pub?gid=0&single=true&output=csv"];

// Then,

RMTString(@"SomeKey", @"SomeDefault");
  // => @"SomeValue" from retrieved configuration

RMTInt(@"SomeNotFoundKey", 2);
  // => 2 from specified default value

// It caches retrieved value and refreshes them when calling every `- startWithURL:`.
```

## 1. Setup

Specify the URL to retrieve and initialize `RMTConfig` at the `-application:didFinishLaunchingWithOptions:`. The retrieved values are stored and cached in `NSUserDefaults`.

```objc
[RMTConfig startWithURL:@"https://docs.google.com/spreadsheets/d/1NanRTook1EeXpfIbVNR-tmGSo9h-2LSsdxJQE3n7NYM/pub?gid=0&single=true&output=csv"];
```

## 2. Getting Values

You can get values with simple static functions. They return given default value when 1.`RMTConfig` has not retrieved the URL yet. 2.The value for key does not exist.

```objc
RMTString(@"SomeKey", @"SomeDefault"); // => @"SomeValue" from retrieved configuration

RMTInt(@"SomeNotFoundKey", 2); // => 2 from specified default value 

RMTBool(@"FooBar", NO); // => YES from retrieved configuration
```

You can simply use them with `if` statement to work them more programmatically.

```objc
if (RMTBool(@"ShouldDoSomething", NO)) {
    DoSomething();
}
```

It allows you to switch functions or do some tests without updating the app. Yay!

## 3. Editing Values

The format of spreadsheets is simple. Put keys on the first column and put values on the second column. It avoids keys start with `$`.

![](https://i.gyazo.com/be33a058ed64d3344a4a1895bf82c9d1.png)

You should obtain and specify the **.csv** URL from spreadsheets. To obtain .csv URL, click `File` -> `Publish to the Web` then pull down the format selection to `Comma-separated values (.csv)` as follows.

![](https://i.gyazo.com/4db2a15464ee929af4950a962b9144b2.png)

Then you will obtain an URL as follows.

`https://docs.google.com/spreadsheets/d/1NanRTook1EeXpfIbVNR-tmGSo9h-2LSsdxJQE3n7NYM/pub?output=csv`

## 4. Debugging

For debugging purpose, you can force returning value by calling simple api.

```objc
// This method force `RMTString()` or related methods to return "ForcedValue"
// Do nothing while production build.
[RMTConfig debug_forceValueForKey:@"SomeKey" withString:@"ForcedValue"];

RMTString(@"SomeKey");
  // => @"ForcedValue"

[RMTConfig debug_forceValueForKey:@"SomeBoolKey" withBool:YES];
RMTBool(@"SomeBoolKey", NO); // => YES!
```

For helping debug, `RMTConfig` emits some `NSLog`s while DEBUG.

### (Optional) Bring your own CSV

You can bring your own `.csv` URL. The format is as follows.

```csv
SomeKey, SomeValue
FooBar, 2
TheAnswerOfEveryThing, 42
```

## Use

`pod "RMTConfig"`

## Author

kaiinui (https://kaiinui.com/, https://twitter.com/_kaiinui)
