//  AppDelegate.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Run.h"
#import "Post.h"
#import "Comment.h"
#import "Resort.h"
#import "Like.h"
#import "PostTopic.h"
#import "Group.h"
#import "JoinGroup.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UIImage+SkiSnowboardIcon.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface AppDelegate ()

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];

    [User registerSubclass];
    [Run registerSubclass];
    [Post registerSubclass];
    [Comment registerSubclass];
    [Resort registerSubclass];
    [Like registerSubclass];
    [PostTopic registerSubclass];
    [Group registerSubclass];
    [JoinGroup registerSubclass];



    [PFUser enableAutomaticUser];

    // Initialize Parse.
    [Parse setApplicationId:@"tToLZMQ5nL7e5kvFQNS2Z9QPmSFUQEV229IAnRQ1"
                  clientKey:@"0haiam3p9bKZRmTHv8TQFEpwBjfm1cRPtco3DTg1"];

    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];



    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];



    // Register for Push Notitications


    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.tabBar.tintColor = [UIColor lightGrayColor];

    UITabBarItem *tabBarFeed = [[tabBarController.tabBar items] objectAtIndex:0];
    [tabBarFeed setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:75.0/255.0 green:171.0/255.0 blue:253.0/255.0  alpha:1.0]} forState:UIControlStateSelected];
    tabBarFeed.selectedImage = [[UIImage imageNamed:@"FeedSelected.pdf"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarFeed.image = [[UIImage imageNamed:@"FeedUnselected.pdf"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    UITabBarItem *tabBarDiscover = [[tabBarController.tabBar items] objectAtIndex:1];
    [tabBarDiscover setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:140.0/255.0 green:1.0/255.0 blue:240.0/255.0  alpha:1.0]} forState:UIControlStateSelected];
    tabBarDiscover.selectedImage = [[UIImage imageNamed:@"DiscoverSelected.pdf"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarDiscover.image = [[UIImage imageNamed:@"DiscoverUnselected.pdf"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];


    UITabBarItem *tabBarGroups = [[tabBarController.tabBar items] objectAtIndex:2];
    [tabBarGroups setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.0/255.0 green:64.0/255.0 blue:128.0/255.0  alpha:1.0]} forState:UIControlStateSelected];
    tabBarGroups.selectedImage = [[UIImage imageNamed:@"GroupsSelected.pdf"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarGroups.image = [[UIImage imageNamed:@"GroupsUnselected.pdf"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    UITabBarItem *tabBarProfile = [[tabBarController.tabBar items] objectAtIndex:3];
     [tabBarProfile setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:174.0/255.0 green:16.0/255.0 blue:13.0/255.0  alpha:1.0]} forState:UIControlStateSelected];
    tabBarProfile.selectedImage = [[UIImage imageNamed:@"ProfileSelected.pdf"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarProfile.image = [[UIImage imageNamed:@"ProfileUnselected.pdf"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];



    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0)
    {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory
{
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ebb.Chairlifted" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Chairlifted" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Chairlifted.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext
{
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator)
    {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

#pragma mark - Push Notifications


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation[@"user"] = [User currentUser];
    [currentInstallation saveInBackground];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"%@", error.localizedDescription);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}


@end
