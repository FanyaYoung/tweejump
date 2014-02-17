#import "Game.h"
#import "Main.h"
#import "Highscores.h"

@interface Game (Private)
- (void)initPlatforms;
- (void)initPlatform;
- (void)startGame;
- (void)resetPlatforms;
- (void)resetPlatform;
- (void)resetBird;
- (void)resetBonus;
- (void)jump;
- (void)showHighscores;
@end


@implementation Game

+ (Game *)scene
{
    return [[self alloc] init];
}

- (id)init {
	
    self = [super init];
    if (!self) return(nil);
	
	_gameSuspended = YES;

	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode *)[self getChildByName:kSpriteManager recursively:NO];

	[self initPlatforms];
	
	CCSprite *bird = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(608,16,44,32)];
	[batchNode addChild:bird z:4 name:kBird];

	CCSprite *bonus;

	for(int i=0; i<kNumBonuses; i++) {
		bonus = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(608+i*32,256,25,25)];
		[batchNode addChild:bonus z:4 name:[NSString stringWithFormat:@"%d",kBonusStartTag+i]];
		bonus.visible = NO;
	}


	CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFont.fnt"];
	[self addChild:scoreLabel z:5 name:kScoreLabel];
	scoreLabel.position = ccp(160,430);

	self.userInteractionEnabled = YES;

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kFPS)];
	
	[self startGame];
	
	return self;
}

- (void)dealloc {
}

- (void)initPlatforms {
	
	_currentPlatformTag = kPlatformsStartTag;
	while(_currentPlatformTag < kPlatformsStartTag + kNumPlatforms) {
		[self initPlatform];
		_currentPlatformTag++;
	}
	
	[self resetPlatforms];
}

- (void)initPlatform {

	CGRect rect;
	switch(random()%2) {
		case 0: rect = CGRectMake(608,64,102,36); break;
		case 1: rect = CGRectMake(608,128,90,32); break;
	}

	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
	CCSprite *platform = [CCSprite spriteWithTexture:[batchNode texture] rect:rect];
	[batchNode addChild:platform z:3 name:[NSString stringWithFormat:@"%d",_currentPlatformTag]];
}

- (void)startGame {
//	CCLOG(@"startGame");

	_score = 0;
	
	[self resetClouds];
	[self resetPlatforms];
	[self resetBird];
	[self resetBonus];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	_gameSuspended = NO;
}

- (void)resetPlatforms {
//	CCLOG(@"resetPlatforms");
	
	_currentPlatformY = -1;
	_currentPlatformTag = kPlatformsStartTag;
	_currentMaxPlatformStep = 60.0f;
	_currentBonusPlatformIndex = 0;
	_currentBonusType = 0;
	_platformCount = 0;

	while(_currentPlatformTag < kPlatformsStartTag + kNumPlatforms) {
		[self resetPlatform];
		_currentPlatformTag++;
	}
}

- (void)resetPlatform {
	
	if(_currentPlatformY < 0) {
		_currentPlatformY = 30.0f;
	} else {
		_currentPlatformY += random() % (int)(_currentMaxPlatformStep - kMinPlatformStep) + kMinPlatformStep;
		if(_currentMaxPlatformStep < kMaxPlatformStep) {
			_currentMaxPlatformStep += 0.5f;
		}
	}
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
	CCSprite *platform = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",_currentPlatformTag] recursively:NO];
	
	if(random()%2==1) platform.scaleX = -1.0f;
	
	float x;
	CGSize size = platform.contentSize;
	if(_currentPlatformY == 30.0f) {
		x = 160.0f;
	} else {
		x = random() % (320-(int)size.width) + size.width/2;
	}
	
	platform.position = ccp(x,_currentPlatformY);
	_platformCount++;
	//CCLOG(@"platformCount = %d",_platformCount);
	
	if(_platformCount == _currentBonusPlatformIndex) {
//		CCLOG(@"platformCount == _currentBonusPlatformIndex");
		CCSprite *bonus = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",(kBonusStartTag+_currentBonusType)] recursively:NO];
		bonus.position = ccp(x,_currentPlatformY+30);
		bonus.visible = YES;
	}
}

- (void)resetBird {
//	CCLOG(@"resetBird");

	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
	CCSprite *bird = (CCSprite*)[batchNode getChildByName:kBird recursively:NO];
	
	_bird_pos.x = 160;
	_bird_pos.y = 160;
	bird.position = _bird_pos;
	
	_bird_vel.x = 0;
	_bird_vel.y = 0;
	
	_bird_acc.x = 0;
	_bird_acc.y = -550.0f;
	
	_birdLookingRight = YES;
	bird.scaleX = 1.0f;
}

- (void)resetBonus {
//	CCLOG(@"resetBonus");
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
	CCSprite *bonus = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",(kBonusStartTag+_currentBonusType)] recursively:NO];
	bonus.visible = NO;
	_currentBonusPlatformIndex += random() % (kMaxBonusStep - kMinBonusStep) + kMinBonusStep;
    
	if(_score < 10000) {
		_currentBonusType = 0;
	} else if(_score < 50000) {
		_currentBonusType = random() % 2;
	} else if(_score < 100000) {
		_currentBonusType = random() % 3;
	} else {
		_currentBonusType = random() % 2 + 2;
	}
}

- (void)update:(CCTime)dt {
//	CCLOG(@"Game::step");

	[super update:dt];
	
	if(_gameSuspended) return;

	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
	CCSprite *bird = (CCSprite*)[batchNode getChildByName:kBird recursively:NO];
	
	_bird_pos.x += _bird_vel.x * dt;
	
	if(_bird_vel.x < -30.0f && _birdLookingRight) {
		_birdLookingRight = NO;
		bird.scaleX = -1.0f;
	} else if (_bird_vel.x > 30.0f && !_birdLookingRight) {
		_birdLookingRight = YES;
		bird.scaleX = 1.0f;
	}

	CGSize bird_size = bird.contentSize;
	float max_x = 320-bird_size.width/2;
	float min_x = 0+bird_size.width/2;
	
	if(_bird_pos.x>max_x) _bird_pos.x = max_x;
	if(_bird_pos.x<min_x) _bird_pos.x = min_x;
	
	_bird_vel.y += _bird_acc.y * dt;
	_bird_pos.y += _bird_vel.y * dt;
	
	CCSprite *bonus = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",(kBonusStartTag+_currentBonusType)] recursively:NO];

	if(bonus.visible) {
		CGPoint bonus_pos = bonus.position;
		float range = 20.0f;
		if(_bird_pos.x > bonus_pos.x - range &&
		   _bird_pos.x < bonus_pos.x + range &&
		   _bird_pos.y > bonus_pos.y - range &&
		   _bird_pos.y < bonus_pos.y + range ) {
			switch(_currentBonusType) {
				case kBonus5:   _score += 5000;   break;
				case kBonus10:  _score += 10000;  break;
				case kBonus50:  _score += 50000;  break;
				case kBonus100: _score += 100000; break;
			}
			NSString *scoreStr = [NSString stringWithFormat:@"%d",_score];
			CCLabelBMFont *scoreLabel = (CCLabelBMFont*)[self getChildByName:kScoreLabel recursively:NO];
			[scoreLabel setString:scoreStr];
			id a1 = [CCActionScaleTo actionWithDuration:0.2f scaleX:1.5f scaleY:0.8f];
			id a2 = [CCActionScaleTo actionWithDuration:0.2f scaleX:1.0f scaleY:1.0f];
			id a3 = [CCActionSequence actions:a1,a2,a1,a2,a1,a2,nil];
			[scoreLabel runAction:a3];
			[self resetBonus];
		}
	}
	
	if(_bird_vel.y < 0) {
		
		for(int t=kPlatformsStartTag; t < kPlatformsStartTag + kNumPlatforms; t++) {
			CCSprite *platform = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",t] recursively:NO];

			CGSize platform_size = platform.contentSize;
			CGPoint platform_pos = platform.position;
			
			max_x = platform_pos.x - platform_size.width/2 - 10;
			min_x = platform_pos.x + platform_size.width/2 + 10;
			float min_y = platform_pos.y + (platform_size.height+bird_size.height)/2 - kPlatformTopPadding;
			
			if(_bird_pos.x > max_x &&
			   _bird_pos.x < min_x &&
			   _bird_pos.y > platform_pos.y &&
			   _bird_pos.y < min_y) {
				[self jump];
			}
		}
		
		if(_bird_pos.y < -bird_size.height/2) {
			[self showHighscores];
		}
		
	} else if(_bird_pos.y > 240) {
		
		float delta = _bird_pos.y - 240;
		_bird_pos.y = 240;

		_currentPlatformY -= delta;
		
		for(int t=kCloudsStartTag; t < kCloudsStartTag + kNumClouds; t++) {
			CCSprite *cloud = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",t] recursively:NO];
			CGPoint pos = cloud.position;
			pos.y -= delta * cloud.scaleY * 0.8f;
			if(pos.y < -cloud.contentSize.height/2) {
				_currentCloudTag = t;
				[self resetCloud];
			} else {
				cloud.position = pos;
			}
		}
		
		for(int t=kPlatformsStartTag; t < kPlatformsStartTag + kNumPlatforms; t++) {
			CCSprite *platform = (CCSprite*)[batchNode getChildByName:[NSString stringWithFormat:@"%d",t] recursively:NO];
			CGPoint pos = platform.position;
			pos = ccp(pos.x,pos.y-delta);
			if(pos.y < -platform.contentSize.height/2) {
				_currentPlatformTag = t;
				[self resetPlatform];
			} else {
				platform.position = pos;
			}
		}
		
		if(bonus.visible) {
			CGPoint pos = bonus.position;
			pos.y -= delta;
			if(pos.y < -bonus.contentSize.height/2) {
				[self resetBonus];
			} else {
				bonus.position = pos;
			}
		}
		
		_score += (int)delta;
		NSString *scoreStr = [NSString stringWithFormat:@"%d",_score];

		CCLabelBMFont *scoreLabel = (CCLabelBMFont*)[self getChildByName:kScoreLabel recursively:NO];
		[scoreLabel setString:scoreStr];
	}
	
	bird.position = _bird_pos;
}

- (void)jump {
	_bird_vel.y = 350.0f + fabsf(_bird_vel.x);
}

- (void)showHighscores {
//	CCLOG(@"showHighscores");
	_gameSuspended = YES;
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
//	CCLOG(@"score = %d",_score);
    // start spinning scene with transition
    [[CCDirector sharedDirector] replaceScene:[Highscores sceneWithScore:_score]
                               withTransition:[CCTransition  transitionFadeWithColor:[CCColor whiteColor] duration:1.0f]];
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
	if(_gameSuspended) return;
    
	float accel_filter = 0.1f;
	_bird_vel.x = _bird_vel.x * accel_filter + acceleration.x * (1.0f - accel_filter) * 500.0f;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	CCLOG(@"alertView:clickedButtonAtIndex: %i",buttonIndex);

	if(buttonIndex == 0) {
		[self startGame];
	} else {
		[self startGame];
	}
}

@end
