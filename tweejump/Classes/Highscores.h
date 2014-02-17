#import "cocos2d.h"
#import "Main.h"

@interface Highscores : Main <UITextFieldDelegate>
{
	NSString *_currentPlayer;
	int _currentScore;
	int _currentScorePosition;
	NSMutableArray *_highscores;
	UIAlertView *_changePlayerAlert;
	UITextField *_changePlayerTextField;
}
+ (Highscores *)sceneWithScore:(int)lastScore;
- (id)initWithScore:(int)lastScore;


@end
