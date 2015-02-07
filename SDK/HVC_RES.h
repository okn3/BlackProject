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
//  HVC_RES.h
//  SimpleDemo
//

#import <Foundation/Foundation.h>

#import "HVCC_Define.h"

// 検出結果
@interface DetectionResult : NSObject
{
    int posX;               // 中心座標(x)
    int posY;               // 中心座標(y)
    int size;               // サイズ
    int confidence;         // 信頼度
}

// アクセッサ
-(void) setPosX:(int)val;
-(int)posX;
-(void) setPosY:(int)val;
-(int)posY;
-(void) setSize:(int)val;
-(int)size;
-(void) setConfidence:(int)val;
-(int)confidence;

@end


// 顔向き
@interface DirResult : NSObject
{
    int yaw;                // 左右角
    int pitch;              // 上下角
    int roll;               // ロール角
    int confidence;         // 信頼度
}

// アクセッサ
-(void) setYaw:(int)val;
-(int)yaw;
-(void) setPitch:(int)val;
-(int)pitch;
-(void) setRoll:(int)val;
-(int)roll;
-(void) setConfidence:(int)val;
-(int)confidence;

@end


// 年齢
@interface AgeResult : NSObject
{
    int age;                // 年齢
    int confidence;         // 信頼度
}

// アクセッサ
-(void) setAge:(int)val;
-(int)age;
-(void) setConfidence:(int)val;
-(int)confidence;

@end


// 性別
@interface GenResult : NSObject
{
    HVC_GENDER  gender;     // 性別
    int confidence;         // 信頼度
}

// アクセッサ
-(void) setGender:(HVC_GENDER)val;
-(HVC_GENDER)gender;
-(void) setConfidence:(int)val;
-(int)confidence;

@end


// 視線
@interface GazeResult : NSObject
{
    int gazeLR;             // 左右角
    int gazeUD;             // 上下角
}

// アクセッサ
-(void) setGazeLR:(int)val;
-(int)gazeLR;
-(void) setGazeUD:(int)val;
-(int)gazeUD;

@end


// 目つむり
@interface BlinkResult : NSObject
{
    int ratioL;             // 左目の度合い
    int ratioR;             // 右目の度合い
}

// アクセッサ
-(void) setRatioL:(int)val;
-(int)ratioL;
-(void) setRatioR:(int)val;
-(int)ratioR;

@end


// 表情
@interface ExpResult : NSObject
{
    HVC_EXPRESSION expression;  // 表情
    int score;                  // スコア
    int degree;                 // ネガポジ度合い
}

// アクセッサ
-(void) setExpression:(HVC_EXPRESSION)val;
-(HVC_EXPRESSION)expression;
-(void) setScore:(int)val;
-(int)score;
-(void) setDegree:(int)val;
-(int)degree;

@end


// 顔検出
@interface FaceResult : DetectionResult
{
    DirResult *dir;     // 顔向き推定結果
    AgeResult *age;     // 年齢推定結果
    GenResult *gen;     // 性別推定結果
    GazeResult *gaze;   // 視線推定結果
    BlinkResult *blink; // 目つむり推定結果
    ExpResult *exp;     // 表情推定結果
}

// アクセッサ
-(void) setDir:(DirResult *)val;
-(DirResult *)dir;
-(void) setAge:(AgeResult *)val;
-(AgeResult *)age;
-(void) setGen:(GenResult *)val;
-(GenResult *)gen;
-(void) setGaze:(GazeResult *)val;
-(GazeResult *)gaze;
-(void) setBlink:(BlinkResult *)val;
-(BlinkResult *)blink;
-(void) setExp:(ExpResult *)val;
-(ExpResult *)exp;

@end


@interface HVC_RES : NSObject
{
    HVC_FUNCTION executedFunc;      // 実行機能フラグ
    NSMutableArray *body;           // 人体検出結果
    NSMutableArray *hand;           // 手検出結果
    NSMutableArray *face;           // 顔検出結果
}

// リセット
-(void)Reset:(HVC_FUNCTION)func;

// アクセッサ
-(void) setExecutedFunc:(HVC_FUNCTION)func;
-(HVC_FUNCTION)executedFunc;
-(void) setBody:(DetectionResult *)dt;
-(DetectionResult *)body:(int)index;
-(int)sizeBody;
-(void) setHand:(DetectionResult *)dt;
-(DetectionResult *)hand:(int)index;
-(int)sizeHand;
-(void) setFace:(FaceResult *)fd;
-(FaceResult *)face:(int)index;
-(int)sizeFace;

@end
