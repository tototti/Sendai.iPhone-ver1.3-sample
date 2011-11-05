//
//  HelloWorldLayer.m
//  cocos2dTest
//
//  Created by tototti on 11/09/13.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {

		// ask director the the window size
		// CGSize size = [[CCDirector sharedDirector] winSize];
	
		// create and initialize a Label
		// position the label on the center of the screen
        _label = [[NSMutableArray alloc] init];
        _labelSpeed = [[NSMutableArray alloc] init];
        
        [self getPublicTimeline];
        
		// add the label as a child to this Layer
        
		srand(time(NULL));
        [self schedule:@selector(nextFrame:)];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void)nextFrame:(ccTime)dt 
{
    CGSize size = [[CCDirector sharedDirector] winSize];

    for (int i = 0; i < [_label count]; i++)
    {
        BOOL speedchange = NO;
        CCLabelTTF * label = [_label objectAtIndex:i];
        NSValue* value = [_labelSpeed objectAtIndex:i];
        CGPoint labelSpeed = [value CGPointValue];
        
        label.position = ccp( label.position.x + labelSpeed.x , label.position.y + labelSpeed.y ); 
        if (label.position.x < 0) 
        {
            labelSpeed.x = - labelSpeed.x;
            speedchange = YES;
        }
        else if (label.position.x > size.width) 
        {
            labelSpeed.x = - labelSpeed.x;
            speedchange = YES;
        }
        
        if (label.position.y < 0) 
        {
            labelSpeed.y = - labelSpeed.y;
            speedchange = YES;
        }
        else if (label.position.y > size.height) 
        {
            labelSpeed.y = - labelSpeed.y;
            speedchange = YES;
        }
        
        if(speedchange)
        {
            [_labelSpeed replaceObjectAtIndex:i 
                                   withObject:[NSValue valueWithCGPoint:labelSpeed]];
        }
    }
}


-(void)addLabel:(NSString*)text
{
    CCLabelTTF* label;
    CGPoint labelSpeed;
    CGSize size = [[CCDirector sharedDirector] winSize];

    label = [CCLabelTTF labelWithString:text
                               fontName:@"Marker Felt" 
                               fontSize:(int)(5 + CCRANDOM_0_1() * 20)];
    label.position =  ccp( size.width / 2, size.height / 2 );
    
    labelSpeed.x = CCRANDOM_MINUS1_1() * 1.5;
    labelSpeed.y = CCRANDOM_MINUS1_1() * 1.5;
    
    [_label addObject:label];
    [_labelSpeed addObject:[NSValue valueWithCGPoint:labelSpeed]];
    
    [self addChild:label];
}


- (void)getPublicTimeline 
{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) 
        {
			// Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			// For the sake of brevity, we'll assume there is only one Twitter account present.
			// You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
			if ([accountsArray count] > 0) 
            {
				// Grab the initial Twitter account to tweet from.
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
                
                
                // Create a request, which in this example, grabs the public timeline.
                // This example uses version 1 of the Twitter API.
                // This may need to be changed to whichever version is currently appropriate.
                TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"http://api.twitter.com/1/statuses/home_timeline.json"] 
                                                             parameters:nil 
                                                          requestMethod:TWRequestMethodGET];
                
				// Set the account used to post the tweet.
				[postRequest setAccount:twitterAccount];
                
                // Perform the request created above and create a handler block to handle the response.
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) 
                 {
                     NSMutableString *output = [NSMutableString stringWithCapacity:1000];
                     
                     if ([urlResponse statusCode] == 200) 
                     {
                         // Parse the responseData, which we asked to be in JSON format for this request, into an NSDictionary using NSJSONSerialization.
                         NSError *jsonParsingError = nil;
                         NSArray * publicTimeline = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&jsonParsingError];
                         //                        output = [NSString stringWithFormat:@"HTTP response status: %i\nPublic timeline:\n%@", [urlResponse statusCode], publicTimeline];
                         
                         
                         for (int i = 0; i < [publicTimeline count]; i++) 
                         {
                             NSDictionary *dict = [publicTimeline objectAtIndex:i];
                             NSString* str = [NSString stringWithFormat:@"%@ %@", 
                                              [[dict objectForKey:@"user"] objectForKey:@"name"],
                                              [dict objectForKey:@"text"]];
                             [self performSelectorOnMainThread:@selector(displayText:)
                                                    withObject:str
                                                 waitUntilDone:NO];
                         }
                     }
                     else 
                     {
                         output = [NSString stringWithFormat:@"HTTP response status: %i\n", [urlResponse statusCode]];
                         [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                     }
                     
                     NSLog(@"output=%@", output);
                     
                 }];
            }
        }
    }];
}


- (void)displayText:(NSString *)text 
{
	[self addLabel:text];
}




@end
