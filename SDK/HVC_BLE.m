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
//  HVC_BLE.m
//  SimpleDemo
//

#import "HVC_BLE.h"

@interface HVC_BLE () {
}
@property BleDeviceService *mBleService;
@end

@implementation HVC_BLE

@synthesize delegateHVC = _delegate;
@synthesize mBleService = _mBleService;

-(id) init
{
    nStatus = STATE_DISCONNECTED;
    recvData = [[NSMutableData alloc] init];
    self = [super init];
    if ( self ) {
        self.mBleService = [[BleDeviceService alloc] init];
        self.mBleService.delegate = self;
    }
    return self;
}

//デバイス接続完了
- (void)didConnect
{
    nStatus = STATE_CONNECTED;
    dispatch_async(dispatch_get_main_queue(), ^{
    	[self.delegateHVC onConnected];
    });
}

// デバイス切断完了
- (void)didDisconnect
{
    nStatus = STATE_DISCONNECTED;
    dispatch_async(dispatch_get_main_queue(), ^{
    	[self.delegateHVC onDisconnected];
    });
}

// デバイスからのデータ受信
- (void)didReceiveData:(NSData *)data
{
    @synchronized(recvData)
    {
        [recvData appendData:data];
    }
}

// デバイスからのデバイス名受信
- (void)didReceiveDeviceName:(NSData *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
	    [self.delegateHVC onPostGetDeviceName:data];
    });
}

// アプリケーションとのI/F
-(void)deviceSearch
{
    [self.mBleService startScan];
}

-(NSMutableArray *)getDevices
{
    return self.mBleService.deviceList;
}

-(void)connect:(CBPeripheral *)device
{
    nStatus = STATE_CONNECTING;
    [self.mBleService connectDevice:device];
}

-(void)disconnect
{
    nStatus = STATE_DISCONNECTED;
    [self.mBleService disconnectDevice];
}

-(int)setDeviceName:(NSData *)value
{
    BOOL bRet = [self.mBleService sendDeviceName:value];
    if ( bRet == YES ) return HVC_NORMAL;
    return HVC_ERROR_NODEVICES;
}

-(int)getDeviceName:(NSData *)value
{
    BOOL bRet = [self.mBleService readDeviceName];
    if ( bRet == YES ) return HVC_NORMAL;
    return HVC_ERROR_NODEVICES;
}

// HVCデバイスに対して機能を指定して実行する
-(HVC_ERRORCODE)Execute:(HVC_FUNCTION)inExec result:(HVC_RES *)result
{
    if ( nStatus == STATE_DISCONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_NODEVICES");
        return HVC_ERROR_NODEVICES;
    }
    if ( nStatus < STATE_CONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_DISCONNECTED");
        return HVC_ERROR_DISCONNECTED;
    }
    if ( nStatus > STATE_CONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_BUSY");
        return HVC_ERROR_BUSY;
    }

    nStatus = STATE_BUSY;
    dispatch_async(dispatch_get_main_queue(), ^{
        unsigned char outStatus;
        HVC_ERRORCODE err = [self ExecuteFunc:20000 exec:inExec status:&outStatus result:result];
        [self.delegateHVC onPostExecute:result errcode:err status:outStatus];
        nStatus = STATE_CONNECTED;
    });
    return HVC_NORMAL;
}

// パラメータの設定
-(HVC_ERRORCODE)setParam:(HVC_PRM *)param
{
    if ( nStatus == STATE_DISCONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_NODEVICES");
        return HVC_ERROR_NODEVICES;
    }
    if ( nStatus < STATE_CONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_DISCONNECTED");
        return HVC_ERROR_DISCONNECTED;
    }
    if ( nStatus > STATE_CONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_BUSY");
        return HVC_ERROR_BUSY;
    }

    nStatus = STATE_BUSY;
    dispatch_async(dispatch_get_main_queue(), ^{
        unsigned char outStatus;
        HVC_ERRORCODE err = [self SetCameraAngle:10000 status:&outStatus parameter:param];
        if ( err == HVC_NORMAL && outStatus == 0 ) {
            err = [self SetThreshold:10000 status:&outStatus parameter:param];
        }
        if ( err == HVC_NORMAL && outStatus == 0 ) {
            err = [self SetSizeRange:10000 status:&outStatus parameter:param];
        }
        if ( err == HVC_NORMAL && outStatus == 0 ) {
            err = [self SetFaceDetectionAngle:10000 status:&outStatus parameter:param];
        }
        [self.delegateHVC onPostSetParam:err status:outStatus];
        nStatus = STATE_CONNECTED;
    });
    return HVC_NORMAL;
}

// パラメータの取得
-(HVC_ERRORCODE)getParam:(HVC_PRM *)param
{
    if ( nStatus == STATE_DISCONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_NODEVICES");
        return HVC_ERROR_NODEVICES;
    }
    if ( nStatus < STATE_CONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_DISCONNECTED");
        return HVC_ERROR_DISCONNECTED;
    }
    if ( nStatus > STATE_CONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_BUSY");
        return HVC_ERROR_BUSY;
    }

    nStatus = STATE_BUSY;
    dispatch_async(dispatch_get_main_queue(), ^{
        unsigned char outStatus;
        HVC_ERRORCODE err = [self GetCameraAngle:10000 status:&outStatus parameter:param];
        if ( err == HVC_NORMAL && outStatus == 0 ) {
            err = [self GetThreshold:10000 status:&outStatus parameter:param];
        }
        if ( err == HVC_NORMAL && outStatus == 0 ) {
            err = [self GetSizeRange:10000 status:&outStatus parameter:param];
        }
        if ( err == HVC_NORMAL && outStatus == 0 ) {
            err = [self GetFaceDetectionAngle:10000 status:&outStatus parameter:param];
        }
        [self.delegateHVC onPostGetParam:param errcode:err status:outStatus];
        nStatus = STATE_CONNECTED;
    });
    return HVC_NORMAL;
}

// バージョン番号の取得
-(HVC_ERRORCODE)getVersion:(HVC_VER *)ver
{
    if ( nStatus == STATE_DISCONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_NODEVICES");
        return HVC_ERROR_NODEVICES;
    }
    if ( nStatus < STATE_CONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_DISCONNECTED");
        return HVC_ERROR_DISCONNECTED;
    }
    if ( nStatus > STATE_CONNECTED ) {
        NSLog(@"execute() : HVC_ERROR_BUSY");
        return HVC_ERROR_BUSY;
    }

    nStatus = STATE_BUSY;
    dispatch_async(dispatch_get_main_queue(), ^{
        unsigned char outStatus;
        HVC_ERRORCODE err = [self GetVersion:10000 status:&outStatus version:ver];
        [self.delegateHVC onPostGetVersion:ver errcode:err status:outStatus];
        nStatus = STATE_CONNECTED;
    });
    return HVC_NORMAL;
}

// 下位クラスで実装すべきメソッド
// 送受信
-(int)Send:(NSMutableData *)data
{
    NSData *p = [data copy];
    [self.mBleService sendData:p];
    return (int)p.length;
}

-(int)Receive:(NSMutableData **)data length:(int)dataLength timeOut:(int)timeout
{
    // 受信待ち
    int timecnt = 0;
    while (true)
    {
        // 受信待ち
        @synchronized(recvData)
        {
            if ( recvData.length >= dataLength )
            {
                // 受信完了
                NSRange n;
                n.length = dataLength;
                n.location = 0;
                *data = [[recvData subdataWithRange:n] mutableCopy];
                // 受信済みのデータを前に詰める
                n.length = recvData.length - dataLength;
                n.location = dataLength;
                NSData *backup = [recvData subdataWithRange:n];
                [recvData setLength:0];
                [recvData appendData:backup];
                NSLog(@"Recieve datalen=%d recvDataLen=%d", (int)(*data).length, (int)recvData.length);
                break;
            }
        }
        // 適当にスリープ入れるか
        //NSLog(@"receive waitloop");
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        timecnt += 100;
        if ( timeout <= timecnt )
        {
            // 時間切れ
            NSLog(@"receive timeout");
            return (int)(*data).length;
        }
    }
    
    NSLog(@"receive success");
    return (int)(*data).length;
}

@end
