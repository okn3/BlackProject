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
//  HVCC_Define.h
//  SimpleDemo
//

#ifndef SimpleDemo_HVCC_Define_h
#define SimpleDemo_HVCC_Define_h

#import <Foundation/Foundation.h>

// Define ERROR CODE
typedef enum : NSInteger
{
    // 正常
    HVC_NORMAL = 0,
    // 引数エラー
    HVC_ERROR_PARAMETER = -1,
    // デバイスエラー
    HVC_ERROR_NODEVICES = -2,
    // 接続エラー
    HVC_ERROR_DISCONNECTED = -3,
    // 再入不可エラー
    HVC_ERROR_BUSY = -4,
    // 送信エラー
    HVC_ERROR_SENDDATA = -10,
    // 受信エラー
    HVC_ERROR_HEADER_TIMEOUT = -20,
    HVC_ERROR_HEADER_INVALID = -21,
    HVC_ERROR_DATA_TIMEOUT = -22,
} HVC_ERRORCODE;

// Define Execution Function
typedef enum : NSInteger
{
    // 人体検出
    HVC_ACTIV_BODY_DETECTION        = 0x00000001,
    // 手検出
    HVC_ACTIV_HAND_DETECTION        = 0x00000002,
    // 顔検出
    HVC_ACTIV_FACE_DETECTION        = 0x00000004,
    // 顔方向検出
    HVC_ACTIV_FACE_DIRECTION        = 0x00000008,
    // 年齢推定
    HVC_ACTIV_AGE_ESTIMATION        = 0x00000010,
    // 性別推定
    HVC_ACTIV_GENDER_ESTIMATION     = 0x00000020,
    // 視線推定
    HVC_ACTIV_GAZE_ESTIMATION       = 0x00000040,
    // 目つむり推定
    HVC_ACTIV_BLINK_ESTIMATION      = 0x00000080,
    // 表情推定
    HVC_ACTIV_EXPRESSION_ESTIMATION = 0x00000100,
} HVC_FUNCTION;

// 性別推定定義
typedef enum : NSInteger
{
    HVC_GEN_FEMALE = 0,
    HVC_GEN_MALE = 1,
} HVC_GENDER;

// 表情推定定義
typedef enum : NSInteger
{
    HVC_EX_NEUTRAL = 1,
    HVC_EX_HAPPINESS = 2,
    HVC_EX_SURPRISE = 3,
    HVC_EX_ANGER = 4,
    HVC_EX_SADNESS = 5,
} HVC_EXPRESSION;

// バージョンの文字列長さ
#define HVC_LEN_VERSIONSTRING       12

#endif
