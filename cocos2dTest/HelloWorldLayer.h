//
//  HelloWorldLayer.h
//  cocos2dTest
//
//  Created by tototti on 11/09/13.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    NSMutableArray* _label;
    NSMutableArray* _labelSpeed;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
