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
//  HVC_PRM.m
//  SimpleDemo
//

#import "HVC_PRM.h"

@implementation DetectionParam

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        MinSize = 40;
        MaxSize = 480;
        Threshold = 500;
    }
    return self;
}

// アクセッサ
-(void) setMinSize:(int)value { MinSize = value; }
-(int)MinSize { return MinSize; }
-(void) setMaxSize:(int)value { MaxSize = value; }
-(int)MaxSize { return MaxSize; }
-(void) setThreshold:(int)value { Threshold = value; }
-(int)Threshold { return Threshold; }

@end

@implementation FaceParam

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        Pose = 0;
        Angle = 0;
    }
    return self;
}

// アクセッサ
-(void) setPose:(int)value { Pose = value; }
-(int)Pose { return Pose; }
-(void) setAngle:(int)value { Angle = value; }
-(int)Angle { return Angle; }

@end

@implementation HVC_PRM

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        CameraAngle = 0;
        body = [[DetectionParam alloc] init];
        hand = [[DetectionParam alloc] init];
        face = [[FaceParam      alloc] init];
    }
    return self;
}

// アクセッサ
-(void) setCameraAngle:(int)value { CameraAngle = value; }
-(int)CameraAngle { return CameraAngle; }
-(void) setBody:(DetectionParam *)dt { body = dt; }
-(DetectionParam *)body { return body; }
-(void) setHand:(DetectionParam *)dt { hand = dt; }
-(DetectionParam *)hand { return hand; }
-(void) setFace:(FaceParam *)fd { face = fd; }
-(FaceParam *)face { return face; }

@end
