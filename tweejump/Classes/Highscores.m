#import "Highscores.h"
#import "Main.h"
#import "Game.h"
#import "cocos2d-ui.h"

@interface Highscores (Private)
- (void)loadCurrentPlayer;
- (void)loadHighscores;
- (void)updateHighscores;
- (void)saveCurrentPlayer;
- (void)saveHighscores;
- (void)button1Callback:(id)sender;
- (void)button2Callback:(id)sender;
@end


@implementation Highscores

+ (Highscores *)sceneWithScore:(int)lastScore
{
    return [[self alloc] initWithScore:lastScore];
}


- (id)initWithScore:(int)lastScore {
	
    self = [super init];
    if (!self) return(nil);

//	CCLOG(@"lastScore = %d",lastScore);
	
	_currentScore = lastScore;

//	CCLOG(@"currentScore = %d",currentScore);
	
	[self loadCurrentPlayer];
	[self loadHighscores];
	[self updateHighscores];
	if(_currentScorePosition >= 0) {
		[self saveHighscores];
	}
	
	CCSpriteBatchNode *batchNode = (CCSpriteBatchNode*)[self getChildByName:kSpriteManager recursively:NO];
	
	CCSprite *title = [CCSprite spriteWithTexture:[batchNode texture] rect:CGRectMake(608,192,225,57)];
	[batchNode addChild:title z:5];
	title.position = ccp(160,420);

	float start_y = 360.0f;
	float step = 27.0f;
	int count = 0;
	for(NSMutableArray *highscore in _highscores) {
		NSString *player = [highscore objectAtIndex:0];
		int score = [[highscore objectAtIndex:1] intValue];
		
		CCLabelTTF *label1 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",(count+1)] fontName:@"Arial" fontSize:14 dimensions:CGSizeMake(30,40)];
		[self addChild:label1 z:5];
        [label1 setHorizontalAlignment:CCTextAlignmentRight];
		[label1 setColor:[CCColor blackColor]];
		[label1 setOpacity:200];
		label1.position = ccp(15,start_y-count*step-2.0f);
	
		CCLabelTTF *label2 = [CCLabelTTF labelWithString:player fontName:@"Arial" fontSize:16 dimensions:CGSizeMake(240,40)];
		[self addChild:label2 z:5];
		[label2 setColor:[CCColor blackColor]];
        [label2 setHorizontalAlignment:CCTextAlignmentLeft];
		label2.position = ccp(160,start_y-count*step);

		CCLabelTTF *label3 = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",score] fontName:@"Arial" fontSize:16 dimensions:CGSizeMake(290,40)];
		[self addChild:label3 z:5];
        [label3 setHorizontalAlignment:CCTextAlignmentRight];
		[label3 setColor:[CCColor blackColor]];
		[label3 setOpacity:200];
		label3.position = ccp(160,start_y-count*step);
		
		count++;
		if(count == 10) break;
	}
    
    CCButton *button1 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"playAgainButton.png"]];
    [button1 setTarget:self selector:@selector(button1Callback:)];
    button1.positionType = CCPositionTypeNormalized;
    button1.position = ccp(0.50f, 0.15f);
    [self addChild:button1];
    
    CCButton *button2 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"changePlayerButton.png"]];
    [button2 setTarget:self selector:@selector(button2Callback:)];
    button2.positionType = CCPositionTypeNormalized;
    button2.position = ccp(0.50f, 0.05f);
    [self addChild:button2];
	
	return self;
}

- (void)dealloc {
}

- (void)loadCurrentPlayer {
//	CCLOG(@"loadCurrentPlayer");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	_currentPlayer = nil;
	_currentPlayer = [defaults objectForKey:@"player"];
	if(!_currentPlayer) {
		_currentPlayer = @"anonymous";
	}

//	CCLOG(@"currentPlayer = %@",currentPlayer);
}

- (void)loadHighscores {
//	CCLOG(@"loadHighscores");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	_highscores = nil;
	_highscores = [[NSMutableArray alloc] initWithArray: [defaults objectForKey:@"highscores"]];
#ifdef RESET_DEFAULTS	
	[highscores removeAllObjects];
#endif
	if([_highscores count] == 0) {
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:1000000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:750000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:500000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:250000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:100000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:50000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:20000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:10000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:5000],nil]];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:1000],nil]];
	}
#ifdef RESET_DEFAULTS	
	[self saveHighscores];
#endif
}

- (void)updateHighscores {
//	CCLOG(@"updateHighscores");
	
	_currentScorePosition = -1;
	int count = 0;
	for(NSMutableArray *highscore in _highscores) {
		int score = [[highscore objectAtIndex:1] intValue];
		
		if(_currentScore >= score) {
			_currentScorePosition = count;
			break;
		}
		count++;
	}
	
	if(_currentScorePosition >= 0) {
		[_highscores insertObject:[NSArray arrayWithObjects:_currentPlayer,[NSNumber numberWithInt:_currentScore],nil] atIndex:_currentScorePosition];
		[_highscores removeLastObject];
	}
}

- (void)saveCurrentPlayer {
//	CCLOG(@"saveCurrentPlayer");
//	CCLOG(@"currentPlayer = %@",_currentPlayer);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:_currentPlayer forKey:@"player"];
}

- (void)saveHighscores {
//	CCLOG(@"saveHighscores");
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject:_highscores forKey:@"highscores"];
}

- (void)button1Callback:(id)sender {
//	CCLOG(@"button1Callback");

    [[CCDirector sharedDirector] replaceScene:[Game scene]
                               withTransition:[CCTransition  transitionFadeWithColor:[CCColor whiteColor] duration:0.5f]];
}

- (void)button2Callback:(id)sender {
//	CCLOG(@"button2Callback");
	
	_changePlayerAlert = [UIAlertView new];
	_changePlayerAlert.title = @"Change Player";
	_changePlayerAlert.message = @"\n";
	_changePlayerAlert.delegate = self;
    
	[_changePlayerAlert addButtonWithTitle:@"Save"];
	[_changePlayerAlert addButtonWithTitle:@"Cancel"];
    
    // iOS7 Text Input in Alert
    _changePlayerAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
	[_changePlayerAlert show];
}

- (void)changePlayerDone {
    UITextField *textField = [_changePlayerAlert textFieldAtIndex:0];
	_currentPlayer = textField.text;
	[self saveCurrentPlayer];
	if(_currentScorePosition >= 0) {
		[_highscores removeObjectAtIndex:_currentScorePosition];
		[_highscores addObject:[NSArray arrayWithObjects:@"tweejump",[NSNumber numberWithInt:0],nil]];
		[self saveHighscores];
        
        [[CCDirector sharedDirector] replaceScene:[Highscores sceneWithScore:_currentScore]
                                   withTransition:[CCTransition  transitionFadeWithColor:[CCColor whiteColor] duration:1.0f]];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	CCLOG(@"alertView:clickedButtonAtIndex: %i",buttonIndex);
	
	if(buttonIndex == 0) {
		[self changePlayerDone];
	} else {
		// nothing
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	CCLOG(@"textFieldShouldReturn");
	[_changePlayerAlert dismissWithClickedButtonIndex:0 animated:YES];
	[self changePlayerDone];
	return YES;
}

@end
