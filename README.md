# ProfilePage

ProfilePage is an iOS UI prototype that replicates a modern social-media profile screen with a sticky header and horizontally paged content (like TikTok or Instagram).  
The project focuses on scroll synchronization, gesture handling, and custom container controller behavior using UIKit.

The app is implemented for iOS 15+ and is intended as a UI demonstration rather than a production app.
![ProfilePage Demo](./demo.gif)

---

## Architecture Overview

The profile screen is built around a custom container view controller that coordinates:

- a sticky profile header
- a tab bar
- horizontally paged scrollable content
- synchronized vertical scrolling across pages

---

## View Hierarchy
UINavigationController
```text
UINavigationController
 └── ProfileViewController
     ├── HeaderContainerView
     │   └── UserInfoView
     ├── MenuBar
     └── ProfilePageViewController (UIPageViewController)
         ├── GridViewController (ScrollableViewController)
         │   └── UICollectionView
         ├── GridViewController (ScrollableViewController)
         │   └── UICollectionView
         └── GridViewController (ScrollableViewController)
             └── UICollectionView
```


## Installation

Clone the repository and use it as example for your design:
   ```
   git clone https://github.com/talazaren/ProfilePage.git
   ```

