//
//  main.m
//  tweejump
//
//  Created by Martin Walsh on 17/02/2014.
//  Copyright Apportable 2014. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    @autoreleasepool {
#ifdef ANDROID
  [UIScreen mainScreen].currentMode = 
          [UIScreenMode emulatedMode:UIScreenIPhone3GEmulationMode];
#endif
        int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
        return retVal;
    }
}
