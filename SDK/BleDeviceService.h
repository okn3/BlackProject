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
//  BleDeviceService.h
//  SimpleDemo
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol BleDeviceDelegate <NSObject>
@optional
//デバイス接続完了
- (void)didConnect;
// デバイス切断完了
- (void)didDisconnect;
// デバイスからのデータ受信
- (void)didReceiveData:(NSData *)data;
// デバイスからのデバイス名受信
- (void)didReceiveDeviceName:(NSData *)data;
@end

@interface BleDeviceService : NSObject

@property (nonatomic, strong) id<BleDeviceDelegate> delegate;
@property (nonatomic, readonly) NSMutableArray *deviceList;

/**
 *
 * デバイス・ペリフェラル・キャラクタリスティックの検索開始
 */
-(void)startScan;
/**
 *
 * デバイス・ペリフェラル・キャラクタリスティックの検索停止
 */
-(void)stopScan;
/**
 *
 * デバイス・ペリフェラル・キャラクタリスティックの接続
 */
-(void)connectDevice:(CBPeripheral *)device;
/**
 *
 * 接続しているデバイスのセッションの切断
 */
-(void)disconnectDevice;

-(BOOL)sendData:(NSData *)data;
-(BOOL)sendDeviceName:(NSData *)data;
-(BOOL)readDeviceName;

@end
