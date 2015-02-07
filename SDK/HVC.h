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
//  HVC.h
//  SimpleDemo
//

#import <Foundation/Foundation.h>

#import "HVC_PRM.h"
#import "HVC_RES.h"
#import "HVC_VER.h"

@class HVC;

@interface HVC : NSObject {
}

// GetVersion
-(HVC_ERRORCODE)GetVersion:(int)timeOut status:(unsigned char *)outStatus version:(HVC_VER *)ver;
// SetCameraAngle
-(HVC_ERRORCODE)SetCameraAngle:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param;
// GetCameraAngle
-(HVC_ERRORCODE)GetCameraAngle:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param;
// SetThreshold
-(HVC_ERRORCODE)SetThreshold:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param;
// GetThreshold
-(HVC_ERRORCODE)GetThreshold:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param;
// SetSizeRange
-(HVC_ERRORCODE)SetSizeRange:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param;
// GetSizeRange
-(HVC_ERRORCODE)GetSizeRange:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param;
// SetFaceDetectionAngle
-(HVC_ERRORCODE)SetFaceDetectionAngle:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param;
// GetFaceDetectionAngle
-(HVC_ERRORCODE)GetFaceDetectionAngle:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param;

-(HVC_ERRORCODE)ExecuteFunc:(int)timeOut exec:(HVC_FUNCTION)inExec status:(unsigned char *)outStatus result:(HVC_RES *)result;

/**
 *
 * HVCデバイスに対して機能を指定して実行する
 *
 * @param inExec 実行する機能を１つもしくは複数(orで連結)指定
 * @param outStat 機能実行時のステータスを取得するバッファ
 * @return エラーコード（実行前にチェックするエラーのみ）
 */
-(HVC_ERRORCODE)Execute:(HVC_FUNCTION)inExec result:(HVC_RES *)result;

/**
 * パラメータの設定
 */
-(HVC_ERRORCODE)setParam:(HVC_PRM *)param;
/**
 * パラメータの取得
 */
-(HVC_ERRORCODE)getParam:(HVC_PRM *)param;

/**
 * バージョン番号の取得
 */
-(HVC_ERRORCODE)getVersion:(HVC_VER *)ver;

// 下位クラスで実装すべきメソッド
/**
 *
 * デバイスへデータを送信する
 *
 * @param data 送信するデータ
 * @return 送信できたバイト数
 *
 */
-(int)Send:(NSMutableData *)data;

/**
 *
 * デバイスからデータを受信する
 * (実際はデバイスからコールバックでデータを受信しているので、受信済みのデータの確認をしている)
 *
 * @param data 受信できたデータが入る
 * @param dataLength 受け取るデータバイト長
 * @param timeout データ未受信タイムアウト値を指定（単位はミリ秒）
 * @return 受信できたバイト数
 */
-(int)Receive:(NSMutableData **)data length:(int)dataLength timeOut:(int)timeout;

@end
