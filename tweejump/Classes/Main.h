#import "cocos2d.h"

//#define RESET_DEFAULTS

#define kFPS 60

#define kNumClouds			12

#define kMinPlatformStep	50
#define kMaxPlatformStep	300
#define kNumPlatforms		10
#define kPlatformTopPadding 10

#define kMinBonusStep		30
#define kMaxBonusStep		50

#define kSpriteManager      @"manager"
#define kBird               @"bird"
#define kScoreLabel         @"scoreLabel"
#define kCloudsStartTag     100
#define kPlatformsStartTag  200
#define kBonusStartTag      300

enum {
	kBonus5 = 0,
	kBonus10,
	kBonus50,
	kBonus100,
	kNumBonuses
};

@interface Main : CCScene
{
	int _currentCloudTag;
}

+ (Main *)scene;
- (id)init;

- (void)resetClouds;
- (void)resetCloud;

@end
