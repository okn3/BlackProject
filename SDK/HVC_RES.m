/*
 * Copyright (C) 2014 OMRON Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//
//  HVC_RES.m
//  SimpleDemo
//

#import "HVC_RES.h"

@implementation DetectionResult

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        posX = -1;
        posY = -1;
        size = -1;
        confidence = -1;
    }
    return self;
}

// アクセッサ
-(void) setPosX:(int)val { posX = val; }
-(int)posX { return posX; }
-(void) setPosY:(int)val { posY = val; }
-(int)posY { return posY; }
-(void) setSize:(int)val { size = val; }
-(int)size { return size; }
-(void) setConfidence:(int)val { confidence = val; }
-(int)confidence { return confidence; }

@end


@implementation DirResult

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        yaw = -1;
        pitch = -1;
        roll = -1;
        confidence = -1;
    }
    return self;
}

// アクセッサ
-(void) setYaw:(int)val { yaw = val; }
-(int)yaw { return yaw; }
-(void) setPitch:(int)val { pitch = val; }
-(int)pitch { return pitch; }
-(void) setRoll:(int)val { roll = val; }
-(int)roll { return roll; }
-(void) setConfidence:(int)val { confidence = val; }
-(int)confidence { return confidence; }

@end


@implementation AgeResult

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        age = -1;
        confidence = -1;
    }
    return self;
}

// アクセッサ
-(void) setAge:(int)val { age = val; }
-(int)age { return age; }
-(void) setConfidence:(int)val { confidence = val; }
-(int)confidence { return confidence; }

@end


@implementation GenResult

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        gender = -1;
        confidence = -1;
    }
    return self;
}

// アクセッサ
-(void) setGender:(HVC_GENDER)val { gender = val; }
-(HVC_GENDER)gender { return gender; }
-(void) setConfidence:(int)val { confidence = val; }
-(int)confidence { return confidence; }

@end


@implementation GazeResult

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        gazeLR = -1;
        gazeUD = -1;
    }
    return self;
}

// アクセッサ
-(void) setGazeLR:(int)val { gazeLR = val; }
-(int)gazeLR { return gazeLR; }
-(void) setGazeUD:(int)val { gazeUD = val; }
-(int)gazeUD { return gazeUD; }

@end


@implementation BlinkResult

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        ratioL = -1;
        ratioR = -1;
    }
    return self;
}

// アクセッサ
-(void) setRatioL:(int)val { ratioL = val; }
-(int)ratioL { return ratioL; }
-(void) setRatioR:(int)val { ratioR = val; }
-(int)ratioR { return ratioR; }

@end


@implementation ExpResult

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        expression = -1;
        score = -1;
        degree = -1;
    }
    return self;
}

// アクセッサ
-(void) setExpression:(HVC_EXPRESSION)val { expression = val; }
-(HVC_EXPRESSION)expression { return expression; }
-(void) setScore:(int)val { score = val; }
-(int)score { return score; }
-(void) setDegree:(int)val { degree = val; }
-(int)degree { return degree; }

@end


@implementation FaceResult

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        dir = [[DirResult alloc] init];
        age = [[AgeResult alloc] init];
        gen = [[GenResult alloc] init];
        gaze = [[GazeResult alloc] init];
        blink = [[BlinkResult alloc] init];
        exp = [[ExpResult alloc] init];
    }
    return self;
}

// アクセッサ
-(void) setDir:(DirResult *)val { dir = val; }
-(DirResult *)dir { return dir; }
-(void) setAge:(AgeResult *)val { age = val; }
-(AgeResult *)age { return age; }
-(void) setGen:(GenResult *)val { gen = val; }
-(GenResult *)gen { return gen; }
-(void) setGaze:(GazeResult *)val { gaze = val; }
-(GazeResult *)gaze { return gaze; }
-(void) setBlink:(BlinkResult *)val { blink = val; }
-(BlinkResult *)blink { return blink; }
-(void) setExp:(ExpResult *)val { exp = val; }
-(ExpResult *)exp { return exp; }

@end


@implementation HVC_RES

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        executedFunc = 0;
        body = [NSMutableArray array];
        hand = [NSMutableArray array];
        face = [NSMutableArray array];
    }
    return self;
}

// リセット
-(void)Reset:(HVC_FUNCTION)func
{
    executedFunc = func;
    [body removeAllObjects];
    [hand removeAllObjects];
    [face removeAllObjects];
}

// アクセッサ
-(void) setExecutedFunc:(HVC_FUNCTION)func
{
    executedFunc = func;
}

-(HVC_FUNCTION)executedFunc
{
    return executedFunc;
}

-(void) setBody:(DetectionResult *)dt
{
    [body addObject:dt];
}

-(DetectionResult *)body:(int)index
{
    return body[index];
}

-(int)sizeBody
{
    return (int)body.count;
}

-(void) setHand:(DetectionResult *)dt
{
    [hand addObject:dt];
}

-(DetectionResult *)hand:(int)index
{
    return hand[index];
}

-(int)sizeHand
{
    return (int)hand.count;
}

-(void) setFace:(FaceResult *)fd
{
    [face addObject:fd];
}

-(FaceResult *)face:(int)index
{
    return face[index];
}

-(int)sizeFace
{
    return (int)face.count;
}

@end
