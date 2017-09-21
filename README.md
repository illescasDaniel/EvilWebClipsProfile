A class to easily create a profile of X web clips for iOS

Example:
---

```swift

import Foundation

let myProfile = EvilWebClipsProfile(profileName: "pass2WithIcon",
										url: "https://www.google.com",
										alias: "Daniel",
										clipsCount: 2,
										password: "1234",
										iconPath: "/Users/Daniel/Downloads/Icons/1465621530_laptop.png")

myProfile.save(to: "/Users/Daniel/Desktop")

```
