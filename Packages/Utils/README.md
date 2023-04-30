# Utils

> This package contains various helpers & utilities reusable across multiple projects.

Here's a simple example:

```swift
import Utils

let env = Env()

extension Env {
    var device: Device {
        .init()
    }

    var version: Version {
        .init(bundleVersion)
    }

    func describe() -> String {
        """
        + device \n\(device)\n
        + environment \n\(self)\n
        + version \n\(version)\n
        """
    }
}

print(env.describe())
```

which would output something like this:

```
+ device 
model: iPhone15,2
kind: iPhone
platform: iOS
os version: 16.2.0
simulator: true

+ environment 
product name: MyProduct
bundle id: dev.my-product.app
bundle version: 0.1.1
bundle build: 3

+ version 
version: 0.1.1
history: [0.1.0]
state: update(from: 0.1.0, to: 0.1.1)
```

For more examples, check out other available [types](Sources/Utils/Types) and [extensions](Sources/Utils/Extensions).

---

`#done-for-fun`
