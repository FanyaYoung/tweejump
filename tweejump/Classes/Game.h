#import "cocos2d.h"
#import "Main.h"
#import <CoreMotion/CoreMotion.h>

@interface Game : Main
{
	CGPoint _bird_pos;
	ccVertex2F _bird_vel;
	ccVertex2F _bird_acc;

	float _currentPlatformY;
	int _currentPlatformTag;
	float _currentMaxPlatformStep;
	int _currentBonusPlatformIndex;
	int _currentBonusType;
	int _platformCount;
	
	BOOL _gameSuspended;
	BOOL _birdLookingRight;
	
	int _score;
}

+ (Game *)scene;
- (id)init;
- (void)accelerometer:(CMAcceleration)acceleration;

@end
