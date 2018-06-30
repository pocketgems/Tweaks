#ifndef UIKitWrapper_h
#define UIKitWrapper_h

#ifdef TARGET_OS_MAC

#else
#import <UIKit/UIKit.h>
#define UIK(x, y) x
#endif

typedef NSObject UIViewController;
typedef NSObject UIWindow;
typedef NSObject UINavigationController;
typedef struct objc_object UITableView;
typedef struct objc_object UITableViewCell;


#define UIK(x, y) y


#endif /* UIKitWrapper_h */
