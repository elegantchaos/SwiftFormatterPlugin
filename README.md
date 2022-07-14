# SwiftFormatterPlugin

A Swift Package Manager plugin which runs [SwiftFormat](https://github.com/nicklockwood/SwiftFormat).

## Usage

Add this repo to your package dependencies:

```Swift
    dependencies: [
        .package(url: "https://github.com/elegantchaos/SwiftFormatterPlugin", from: "1.0.2"),
        /* other dependencies here... */ 
    ],
```

Invoke the tool from the command line:

`swift package plugin --allow-writing-to-package-directory format-source-code`

