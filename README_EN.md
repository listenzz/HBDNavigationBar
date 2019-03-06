# HBDNavigationBar

A custom UINavigationBar for smooth switching between various states, including bar style, bar tint color, background image, background alpha, bar hidden, title text attributes, tint color, shadow hidden...

## Screenshots

### ShadowImage transition between present and absent

![shadow](./screenshot/shadow.gif)

### NavigationBar transition between present and absent

It's diffrent from by calling `setNavigationBarHidden:animated:`

![hidden](./screenshot/hidden.gif)

### NavigationBar background alpha transition

![gradient](./screenshot/gradient.gif)

### NavigationBar transition between diffrent background

![background](./screenshot/background.gif)

## Usage

These effects are the result of three classes working together:

`HBDNavigationBar` inherits `UINavigationBar`

`HBDNavigationController` inherits `UINavigationController` and internally uses `HBDNavigationBar`

`UIViewController(HBD)` is a category with some configurable properties

```objc
@property (nonatomic, assign) UIBarStyle hbd_barStyle;   // The NavigationBar style, which determines the color of the status bar
@property (nonatomic, strong) UIColor *hbd_barTintColor; // NavigationBar background color
@property (nonatomic, strong) UIImage *hbd_barImage;     // NavigationBar background image
@property (nonatomic, strong) UIColor *hbd_tintColor;    // NavigationBar button color
@property (nonatomic, strong) NSDictionary *hbd_titleTextAttributes; // NavigationBar title attributes
@property (nonatomic, assign) float hbd_barAlpha;        // NavigationBar background alpha
@property (nonatomic, assign) BOOL hbd_barHidden;        // Whether to hide the NavigationBar
@property (nonatomic, assign) BOOL hbd_barShadowHidden;  // Whether to hide the shadowImage of the NavigationBar
@property (nonatomic, assign) BOOL hbd_backInteractive;  // Whether the UIViewController can responds to edge gesture, and can pop by click the back button of `UINavigationBar`. The default value is `YES`
@property (nonatomic, assign) BOOL hbd_swipeBackEnabled; // Whether the UIViewController can responds to edge gesture, the default value is `YES`
```

Actually simple to use:

Custom your NavigationBar style globally, just as using normal UINavigationBar.

```objc
// AppDelegate.m
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UINavigationBar appearance] setTintColor:UIColor.blackColor];
    // ...

    return YES;
}
```

Use `HBDNavigationController` instead of `UINavigationController`.

```objc
DemoViewController *vc = [[DemoViewController alloc] init];
self.window.rootViewController = [[HBDNavigationController alloc] initWithRootViewController:vc];
```

If a UIViewController's NavigationBar style is different from global, tweak the style at its `viewDidLoad` using the properties in `UIViewController(HBD)`. It's declarative API, you only need to set the unique features of that UIViewController, no need to clean up.

```objc
@implementation DemoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // hide the NavigationBar just for this UIViewController
    self.hbd_barHidden = YES;
}
@end
```

Don't forget to set `HBDNavigationBar` in addition to setting `HBDNavigationController`, if you use storyboard.

![storyboard](./screenshot/storyboard.jpg)

### Caveat and Limitation

#### hbd_barHidden

`hbd_barHidden` doesn't really hide the NavigationBar, just make it transparent. Of course, the touch event can be pass through. Just because we don't really hide the NavigationBar, we can switch between the NavigationBar style smoothly and gracefully.

#### Background algorithm

`hbd_barTintColor` will be invalidated once the background image is set via `hbd_barImage`.

The calculation rules for the background are as follows:

1. Whether `hbd_barImage` has a value, if it is, set it to background, otherwise the next step
2. Whether `hbd_barTintColor` has a value, if it is, set it to background, otherwise the next step
3. Whether `[[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]` has a value, if it is, set it to background, otherwise the next step
4. Whether `[UINavigationBar appearance].barTintColor` has a value, if it is, set it to background, otherwise the next step
5. Calculate the default background color based on `NavigationBar#barStyle` and set it to background

If you use an image to set the background and want transparency, use an image with transparency.

If blur effect is required, the color set to `hbd_barTintColor` should have non-zero alpha component. Don't use `hbd_barAlpha` to adjust the blur effect, it is used to control the alpha of the NavigationBar background, dynamically.

The image background is without blur effect.

#### Aways translucent

The value of the NavigationBar property `translucent` is always `YES`. You can not change it. It means that the UIViewController's view is always under the NavigationBar, which may bothering some guy. Our current solution to this problem is to define a base class:

```objc
@interface HBDViewController : UIViewController

@property (nonatomic, assign) BOOL hbd_extendedLayoutIncludesTopBar;

@end

BOOL hasAlpha(UIColor *color) {
    if (!color) {
        return YES;
    }
    CGFloat red = 0;
    CGFloat green= 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return alpha < 1.0;
}

@implementation HBDViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!(self.hbd_extendedLayoutIncludesTopBar || hasAlpha(self.hbd_barTintColor))) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

@end
```

The basic principle is that if the background has alpha, then the UIViewController's view should be under the NavigationBar, otherwise it will be below the NavigationBar.
If our NavigationBar is opaque at first, but it may be transparent due to user actions, set the value of `hbd_extendedLayoutIncludesTopBar` to `YES`, remember to set it before `[super viewDidLoad]`.

#### Intercept back event

Sometimes, we need to intercept the back click event and back gesture. For that, you can override the following method to return `NO`:

```objc

- (BOOL)hbd_backInteractive {
    // show alert
    return NO;
}

```

#### About hiding statusBar

If you need to hide the status bar, use this lib with [HBDStatusBar](https://github.com/listenzz/HBDStatusBar)

## Requirements

iOS 8+

## Installation

HBDNavigationBar is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HBDNavigationBar', '~> 1.5.0'
```

## License

HBDNavigationBar is available under the MIT license. See the LICENSE file for more info.
