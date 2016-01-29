# RemoteConfig

Easy remote configuration for iOS with Google Spreadsheet.

```objc
[RMTConfig startWithURL:@"https://docs.google.com/spreadsheets/d/1NanRTook1EeXpfIbVNR-tmGSo9h-2LSsdxJQE3n7NYM/pub?gid=0&single=true&output=csv"];

// ...

RMTString(@"SomeKey", @"SomeDefault"); // => @"SomeValue"

RMTInt(@"SomeNotFoundKey", 2); // => 2
```

## 1. Setup

Specify the URL to retrieve and initialize `RMTConfig` at the `-application:didFinishLaunchingWithOptions:`. The retrieved values are stored and cached in `NSUserDefaults`.

```objc
[RMTConfig startWithURL:@"https://docs.google.com/spreadsheets/d/1NanRTook1EeXpfIbVNR-tmGSo9h-2LSsdxJQE3n7NYM/pub?gid=0&single=true&output=csv"];
```

## 2. Get Values

You can get values with simple static functions. They return specified default value when 1.`RMTConfig` has not retrieved the URL yet. 2.The value for key does not exist.

```objc
RMTString(@"SomeKey", @"SomeDefault"); // => @"SomeValue"

RMTInt(@"SomeNotFoundKey", 2); // => 2

RMTBool(@"FooBar", NO); // => YES
```

You can simply use them for `if` statement.

```objc
if (RMTBool(@"ShouldDoSomething", NO)) {
    DoSomething();
}
```
