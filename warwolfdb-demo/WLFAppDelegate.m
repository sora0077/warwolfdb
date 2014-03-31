//
//  WLFAppDelegate.m
//  warwolfdb-demo
//
//  Created by 林 達也 on 2014/03/10.
//  Copyright (c) 2014年 林 達也. All rights reserved.
//

#import "WLFAppDelegate.h"

#import "User.h"
#import "Book.h"
#import "Follows.h"

#import "WLFDatabase.h"
#import "WLFCursor.h"
#import "WLFEntityIdentifier.h"

#import "WLFTable.h"
#import "WLFTableReferences.h"
#import "WLFReferenceKey.h"
#import "WLFTableReverses.h"

#import "WLFRepository.h"

@implementation WLFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];


    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath   = [docsPath stringByAppendingPathComponent:@"test.db"];

    NSURL *url = [NSURL fileURLWithPath:dbPath];

    [WLFDatabase connect:url];

    [WLFDatabase findSQL:@"PRAGMA foreign_keys" args:nil process:^id(WLFCursor *cursor) {
        if (cursor.next) {
            NSLog(@"%@", cursor.result);
        }
        return nil;
    }];
    [WLFDatabase executeSQL:@"PRAGMA foreign_keys = ON;"];

    [WLFDatabase findSQL:@"PRAGMA foreign_keys" process:^id(WLFCursor *cursor) {
        if (cursor.next) {
            NSLog(@"%@", cursor.result);
        }
        return nil;
    }];
    [WLFDatabase executeSQL:@"CREATE TABLE IF NOT EXISTS User (id TEXT PRIMARY KEY NOT NULL, name TEXT)"];
    [WLFDatabase executeSQL:@"CREATE TABLE IF NOT EXISTS Book (id TEXT PRIMARY KEY NOT NULL, name TEXT, auther_id TEXT, FOREIGN KEY(auther_id) REFERENCES User(id) ON DELETE SET NULL)"];
//    [WLFDatabase executeSQL:@"CREATE TABLE IF NOT EXISTS User_has_Books (user_id TEXT NOT NULL, book_id TEXT NOT NULL, FOREIGN KEY(user_id) REFERENCES User(id) ON DELETE CASCADE, FOREIGN KEY(book_id) REFERENCES Book(id) ON DELETE CASCADE, UNIQUE(user_id, book_id))"];
    [WLFDatabase executeSQL:@"CREATE TABLE IF NOT EXISTS Follows (following_user_id TEXT NOT NULL, follower_user_id TEXT NOT NULL, FOREIGN KEY(following_user_id) REFERENCES User(id) ON DELETE CASCADE, FOREIGN KEY(follower_user_id) REFERENCES User(id) ON DELETE CASCADE, UNIQUE(following_user_id, follower_user_id))"];

    [WLFTable tableWithName:@"Follows"];
//    [WLFTable tableWithName:@"User"];
//    [WLFTable tableWithName:@"Book"];
//    WLFTable *table = [WLFTable tableWithName:@"User"];
//    NSLog(@"%@ %@", table.name, table.reverses);
//
//    table = [WLFTable tableWithName:@"User_has_Books"];
//    NSLog(@"%@ %@", table.name, table.reverses);
//    table = [WLFTable tableWithName:@"Book"];
//    NSLog(@"%@ %@", table.name, table.reverses);

//    __weak User *user;
    @autoreleasepool {
        User *u1 = [User entity];
        @autoreleasepool {
            __weak Book *b1 = [Book entity];
        }

        User *u2 = [User entity];
        User *u3 = [User entity];

//        u1.followings = @[u2];
//        [u1.followings add:u3];
//        u1.followings = @[];

        [u2.followers add:u3];

        NSLog(@"%@", u1.followings);
        NSLog(@"%@", u2.followers);
        NSLog(@"%@", u3.followers);

        NSLog(@"%@", [Follows entityAll]);
        [WLFRepository sync];
        NSLog(@"%@", [WLFRepository entities]);

        for (Follows *follows in [Follows entityAll]) {
            NSLog(@"%@: %@", follows.follower_user, follows.following_user);
        }
    }
    [WLFRepository sync];
    NSLog(@"%@", [WLFRepository entities]);

    WLFEntityIdentifier *identifier = [WLFEntityIdentifier identifier];
    NSLog(@"%d", [identifier isEqual:[identifier copy]]);

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
