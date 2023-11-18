// https://developer.apple.com/documentation/packagedescription/package

init commands

```
mkdir import-audio
swift package init --type executable
```

dev commands

```
swift build
swift run
```

https://www.fivestars.blog/articles/ultimate-guide-swift-executables/

building

```
$ swift build -c release
$ .build/release/import-audio

$ swift build -c release --show-bin-path
/Users/richard/msc/scripts/import-audio/.build/x86_64-apple-macosx/release
```
