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
//  HVC_PRM.h
//  SimpleDemo
//

#import <Foundation/Foundation.h>

#import "HVCC_Define.h"

@interface DetectionParam : NSObject
{
    int MinSize;            // 最小サイズ
    int MaxSize;            // 最大サイズ
    int Threshold;          // 信頼度
}

// アクセッサ
-(void) setMinSize:(int)size;
-(int)MinSize;
-(void) setMaxSize:(int)size;
-(int)MaxSize;
-(void) setThreshold:(int)size;
-(int)Threshold;

@end

@interface FaceParam : DetectionParam
{
    int Pose;               // 顔検出顔向き
    int Angle;              // 顔検出顔傾き
}

// アクセッサ
-(void) setPose:(int)pose;
-(int)Pose;
-(void) setAngle:(int)angle;
-(int)Angle;

@end

@interface HVC_PRM : NSObject
{
    int CameraAngle;        // カメラ取り付け方向
    DetectionParam *body;   // 人体検出パラメータ
    DetectionParam *hand;   // 手検出パラメータ
    FaceParam      *face;   // 顔検出パラメータ
}

// アクセッサ
-(void) setCameraAngle:(int)ca;
-(int)CameraAngle;
-(void) setBody:(DetectionParam *)body;
-(DetectionParam *)body;
-(void) setHand:(DetectionParam *)hand;
-(DetectionParam *)hand;
-(void) setFace:(FaceParam *)face;
-(FaceParam *)face;

@end
