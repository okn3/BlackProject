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
//  BleDeviceService.m
//  SimpleDemo
//

#import <UIKit/UIKit.h>
#import "BleDeviceService.h"

#define SERVICE_UUID            @"35100001-D13A-4F39-8AB3-BF64D4FBB4B4"

#define WRITE_CHAR_UUID         @"35100002-D13A-4F39-8AB3-BF64D4FBB4B4"
#define NOTIFY_CHAR_UUID        @"35100003-D13A-4F39-8AB3-BF64D4FBB4B4"
#define DEVICE_CHAR_UUID        @"35100004-D13A-4F39-8AB3-BF64D4FBB4B4"

@interface BleDeviceService() <CBCentralManagerDelegate, CBPeripheralDelegate, CBPeripheralManagerDelegate>{
    CBCentralManager *CentralManager;
    CBPeripheral     *target;
    
    CBCharacteristic *WriteCharacteristic;
    CBCharacteristic *NotifyCharacteristic;
    CBCharacteristic *DeviceCharacteristic;
    
    CBUUID *ServiceUUID;
    CBUUID *WriteCharUUID;
    CBUUID *NotifyCharUUID;
    CBUUID *DeviceCharUUID;
    NSArray *CharUUIDs;
    
    NSMutableData  *recvData;
    NSMutableData  *deviceName;
    NSMutableArray *findDevises;
}

@end

@implementation BleDeviceService

@synthesize delegate = _delegate;


#pragma mark - Properties
-(NSString *)deviceName
{
    if (!target)
    {
        return nil;
    }
    return target.name;
}

-(NSMutableArray *)deviceList
{
    if (!findDevises)
    {
        return nil;
    }
    return findDevises;
}

#pragma mark Constructor
-(id)init
{
    NSLog(@"[IN]BleDeviceService init");

    recvData = [[NSMutableData alloc] init];
    deviceName = [[NSMutableData alloc] init];
    findDevises = [NSMutableArray array];

    self = [super init];
    if ( self ) {
        CentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)];

        ServiceUUID = [CBUUID UUIDWithString:SERVICE_UUID];
        WriteCharUUID = [CBUUID UUIDWithString:WRITE_CHAR_UUID];
        NotifyCharUUID = [CBUUID UUIDWithString:NOTIFY_CHAR_UUID];
        DeviceCharUUID = [CBUUID UUIDWithString:DEVICE_CHAR_UUID];
        
        CharUUIDs = [NSArray arrayWithObjects:WriteCharUUID, NotifyCharUUID, DeviceCharUUID, nil];
        
        NSLog(@"ServiceUUID:%@",[ServiceUUID description]);
    }
    return self;
}

-(void)dealloc
{
    [self stopScan];
    [self disconnectDevice];
}

#pragma mark - Private methods

-(void)deInit
{
    [self stopScan];
    target = nil;
}

-(CBCharacteristic *)findCharacteristics:(NSArray *)cs uuid:(CBUUID *)uuid
{
    NSLog(@"[IN]findCharacteristics");
    for(CBCharacteristic *c in cs){
        if([c.UUID.data isEqualToData:uuid.data]){
            return c;
        }
    }
    return nil;
}

#pragma mark - Public methods

-(void)startScan
{
    NSLog(@"[IN]startScan");
    
    [findDevises removeAllObjects];
    
    // スキャンのオプション指定
    NSDictionary *scanOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                            forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    // スキャン開始
    [CentralManager scanForPeripheralsWithServices:nil options:scanOptions];
}

-(void)stopScan
{
    NSLog(@"[IN]stopScan");
    [CentralManager stopScan];
}

- (void)connectDevice:(CBPeripheral *)device
{
    target = device;
    target.delegate = self;
    
    // 接続処理
    [CentralManager connectPeripheral:target options:nil];
    // スキャン停止
    [self stopScan];
}

-(void)disconnectDevice
{
    NSLog(@"[IN]disconnect");
    if ( target == nil ) {
        return;
    }
    
    // 切断処理
    [CentralManager cancelPeripheralConnection:target];
}

// データ転送
-(BOOL)sendData:(NSData *)data
{
    if ( WriteCharacteristic == nil ) {
        return NO;
    }
    [target writeValue:data forCharacteristic:WriteCharacteristic type:CBCharacteristicWriteWithResponse];
    NSLog(@"[TX DATA]%@",[data description]);
    return YES;
}

-(BOOL)sendDeviceName:(NSData *)data
{
    if ( DeviceCharacteristic == nil ) {
        return NO;
    }
    [target writeValue:data forCharacteristic:DeviceCharacteristic type:CBCharacteristicWriteWithoutResponse];
    NSLog(@"[TX DATA]%@",[data description]);
    return YES;
}

-(BOOL)readDeviceName
{
    if (target == nil ) {
        return NO;
    }
    
    [target readValueForCharacteristic:DeviceCharacteristic];
    return YES;
}


#pragma mark - CBCentralManagerDelegate

// Bluetoothの電源ON/OFFが変更されたらここに通知される
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"[IN]centralManagerDidUpdateState");
    switch ( central.state )
    {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"[STATE]CBCentralManagerStatePoweredOff");
            break;
            
        case CBCentralManagerStatePoweredOn:
            NSLog(@"[STATE]CBCentralManagerStatePoweredOn");
            break;
            
        case CBCentralManagerStateResetting:
        case CBCentralManagerStateUnauthorized:
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateUnsupported:
            // 何もしない
            break;
    }
}

// デバイス発見
-(void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
 advertisementData:(NSDictionary *)advertisementData
 RSSI:(NSNumber *)RSSI
{
    NSLog(@"didDiscoverPeripheral name:%@ advertisementData:%@", peripheral.name, [advertisementData description]);
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if ( localName != nil ) {
        for ( int i=0; i<[findDevises count]; i++ )
        {
            NSString *name = ((CBPeripheral *)findDevises[i]).name;
            if ( [name isEqualToString:peripheral.name] ) {
                return;
            }
        }
        [findDevises addObject:peripheral];
    }
}

// 接続完了
-(void)centralManager:(CBCentralManager *)central
 didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog((@"[IN]didConnectPeripheral"));
    target.delegate = self;

    // 接続完了を通知
    [self.delegate didConnect];

    // サービスの探索を開始
    [target discoverServices:@[[CBUUID UUIDWithString:SERVICE_UUID]]];
}

// 接続失敗
-(void)centralManager:(CBCentralManager *)central
 didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog((@"[IN]didFailToConnectPeripheral"));
    
    // 切断通知
    [self.delegate didDisconnect];
    [self deInit];
}

// 切断
-(void)centralManager:(CBCentralManager *)central
 didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog((@"[IN]didDisconnectPeripheral"));

    // 切断通知
    [self.delegate didDisconnect];

    [self deInit];
}


#pragma mark - CBPeripheralDelegate

// サービスが見つかった
// Charactreristicsを探す
-(void)peripheral:(CBPeripheral *)peripheral
 didDiscoverServices:(NSError *)error
{
    NSLog(@"[IN]didDiscoverServices");
    if ( error )
    {
        NSLog(@"didDiscoverService error: %@", error.localizedDescription);
        return;
    }
    
    NSLog(@"foundService: %@", [peripheral.services description]);
    for ( CBService *service in peripheral.services ) {
        NSLog(@"%@",[service.UUID description]);
        if ( [service.UUID isEqual:ServiceUUID] ) {
            // サービスを見つけたので、送受信キャラクタリスティックを検索する
            NSLog(@"[FIND]find characteristics");
            [peripheral discoverCharacteristics:CharUUIDs forService:service];
        }
    }
}

// Characteristicsが見つかった
-(void)peripheral:(CBPeripheral *)peripheral
 didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"[IN]didDiscoverCharacteristicsForService");
    if ( error )
    {
        NSLog(@"didDiscoverCharacteristicsForService error: %@", error.localizedDescription);
        return;
    }
    
    if ( [service.UUID.data isEqualToData:ServiceUUID.data] ) {
        NSLog(@"%@",[service.characteristics description]);
        WriteCharacteristic = [self findCharacteristics:service.characteristics uuid:WriteCharUUID];
        NotifyCharacteristic = [self findCharacteristics:service.characteristics uuid:NotifyCharUUID];
        DeviceCharacteristic = [self findCharacteristics:service.characteristics uuid:DeviceCharUUID];
        
        // 通知の申し込み
        [peripheral setNotifyValue:YES forCharacteristic:NotifyCharacteristic];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral
 didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"[IN]didUpdateNotificationStateForCharacteristic");
}

-(void)peripheral:(CBPeripheral *)peripheral
 didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"[IN]didWriteValueForCharacteristic");
    if ( error ) {
        NSLog(@"[ERROR]didWriteValueForCharacteristic:%@",[error description]);
        return;
    }
}

// Characteristicの内容を確認
-(void)peripheral:(CBPeripheral*)peripheral
 didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"[IN]didUpdateValueForCharacteristic");
    
    if ( error ) {
        NSLog(@"[ERROR]didUpdateValueForCharacteristic:%@",[error description]);
        return;
    }
    
    NSLog(@"Received data. %@",[characteristic description]);
    if ( [characteristic.UUID isEqual:NotifyCharacteristic.UUID] ) {
        // データの受信
        @synchronized(self)
        {
            [recvData setLength:0];
            [recvData appendData:characteristic.value];
            [self.delegate didReceiveData:recvData];
        }
    }
    else
    if ( [characteristic.UUID isEqual:DeviceCharacteristic.UUID] ) {
        // デバイス名の受信
        @synchronized(self)
        {
            [deviceName setLength:0];
            [deviceName appendData:characteristic.value];
            [self.delegate didReceiveDeviceName:deviceName];
        }
    }
}

-(void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"[IN]peripheralManagerDidUpdateState");
}

@end
