#import "Main.h"
#import <mach/mach_time.h>

#define RANDOM_SEED() srandom((unsigned)(mach_absolute_time() & 0xFFFFFFFF))

@interface Main(Private)
- (void)initClouds;
- (void)initCloud;
@end


@implementation Main

+ (Main *)scene
{
    return [[self alloc] init];
}

- (id)init {
	
    self = [super init];
    if (!self) return(nil);
	
	RANDOM_SEED();

	CCSpriteBatchNode *batchNode = [CCSpriteBatchNode batchNodeWithFile:@"sprites.png"];
	[self addChild:batchNode z:-1 name:kSpriteManager];

	CCSprite *background = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(0,0,320,480)];
	[batchNode addChild:background];
	background.position = CGPointMake(160,240);

	[self initClouds];
	
	return self;
}

- (void)dealloc {
}

- (void)initClouds {
//	CCLOG(@"initClouds");
	
	_currentCloudTag = kCloudsStartTag;
	while(_currentCloudTag < kCloudsStartTag + kNumClouds) {
		[self initCloud];
		_currentCloudTag++;
	}
	
	[self resetClouds];
}

- (void)initCloud {
	
	CGRect rect;
	switch(random()%3) {
		case 0: rect = CGRectMake(336,16,256,108); break;
		case 1: rect = CGRectMake(336,128,257,110); break;
		case 2: rect = CGRectMake(336,240,252,119); break;
	}	
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
	CCSprite *cloud = [CCSprite spriteWithTexture:[batchNode texture] rect:rect];
    [batchNode addChild:cloud z:3 name:[NSString stringWithFormat:@"%d",_currentCloudTag]];
	
	cloud.opacity = 0.5f;
}

- (void)resetClouds {
//	CCLOG(@"resetClouds");
	
	_currentCloudTag = kCloudsStartTag;
	
	while(_currentCloudTag < kCloudsStartTag + kNumClouds) {
		[self resetCloud];

		CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
		CCSprite *cloud = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",_currentCloudTag] recursively:NO];
		CGPoint pos = cloud.position;
		pos.y -= 480.0f;
		cloud.position = pos;
		
		_currentCloudTag++;
	}
}

- (void)resetCloud {
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
	CCSprite *cloud = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",_currentCloudTag] recursively:NO];
	
	float distance = random()%20 + 5;
	
	float scale = 5.0f / distance;
	cloud.scaleX = scale;
	cloud.scaleY = scale;
	if(random()%2==1) cloud.scaleX = -cloud.scaleX;
	
	CGSize size = cloud.contentSize;
	float scaled_width = size.width * scale;
	float x = random()%(320+(int)scaled_width) - scaled_width/2;
	float y = random()%(480-(int)scaled_width) + scaled_width/2 + 480;
	
	cloud.position = ccp(x,y);
}

#pragma mark - Scheduled update
// Notice, that update is now automatically called for any descendant of CCNode, if the method is implemented
     
-(void)update:(CCTime)delta {
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];

	for(int t = kCloudsStartTag; t < kCloudsStartTag + kNumClouds; t++) {
        
		CCSprite *cloud = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",t] recursively:NO];
        
		CGPoint pos = cloud.position;
		CGSize size = cloud.contentSize;
		pos.x += 0.1f * cloud.scaleY;
		if(pos.x > 320 + size.width/2) {
			pos.x = -size.width/2;
		}
		cloud.position = pos;
	}
	
}

@end
