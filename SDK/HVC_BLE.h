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
//  HVC_BT_Manager.h
//  SimpleDemo
//

#import <Foundation/Foundation.h>

#import "HVC.h"
#import "BleDeviceService.h"

// Define Status CODE
typedef enum : NSInteger
{
    STATE_DISCONNECTED = 0,
    STATE_CONNECTING = 1,
    STATE_CONNECTED = 2,
    STATE_BUSY = 3,
} HVC_STATUS;

@class HVC_BLE;

@protocol HVC_Delegate <NSObject>
@optional
- (void)onConnected;
- (void)onDisconnected;
- (void)onPostGetDeviceName:(NSData *)value;

/**
 * Execute実行後、結果取得とエラーコードを返すdelegate
 *
 * @param result 実行結果
 * @param err エラーコード
 */
- (void)onPostExecute:(HVC_RES *)result errcode:(HVC_ERRORCODE)err status:(unsigned char)outStatus;

- (void)onPostSetParam:(HVC_ERRORCODE)err status:(unsigned char)outStatus;
- (void)onPostGetParam:(HVC_PRM *)param errcode:(HVC_ERRORCODE)err status:(unsigned char)outStatus;
- (void)onPostGetVersion:(HVC_VER *)ver errcode:(HVC_ERRORCODE)err status:(unsigned char)outStatus;
@end

@interface HVC_BLE : HVC <BleDeviceDelegate> {
    HVC_STATUS nStatus;
    NSMutableData  *recvData;
}

@property (nonatomic, strong) id<HVC_Delegate> delegateHVC;

/// アプリケーションとのI/F

-(void)deviceSearch;
-(NSMutableArray *)getDevices;
-(void)connect:(CBPeripheral *)device;
-(void)disconnect;
-(int)setDeviceName:(NSData *)value;
-(int)getDeviceName:(NSData *)value;

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
