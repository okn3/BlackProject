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
//  HVC.m
//  SimpleDemo
//

#import "HVC.h"

@implementation HVC

-(id) init
{
    self = [super init];
    return self;
}

/**
 * HVCデバイスに対して機能を指定して実行する
 */
-(HVC_ERRORCODE)Execute:(HVC_FUNCTION)inExec result:(HVC_RES *)result
{
    // 下位クラスで実装を行う。ここはダミー。
    NSLog(@"warn: HVC class Execute()");
    return HVC_NORMAL;
}

/**
 * パラメータの設定
 */
-(HVC_ERRORCODE)setParam:(HVC_PRM *)param
{
    // 下位クラスで実装を行う。ここはダミー。
    NSLog(@"warn: HVC class setParam()");
    return HVC_NORMAL;
}

/**
 * パラメータの取得
 */
-(HVC_ERRORCODE)getParam:(HVC_PRM *)param
{
    // 下位クラスで実装を行う。ここはダミー。
    NSLog(@"warn: HVC class getParam()");
    return HVC_NORMAL;
}

/**
 * バージョン番号の取得
 */
-(HVC_ERRORCODE)getVersion:(HVC_VER *)ver
{
    // 下位クラスで実装を行う。ここはダミー。
    NSLog(@"warn: HVC class getVersion()");
    return HVC_NORMAL;
}

// 送受信
-(int)Send:(NSMutableData *)data
{
    // 下位クラスで実装を行う。ここはダミー。
    NSLog(@"warn: HVC class send()");
    return (int)data.length;
}

-(int)Receive:(NSMutableData **)data length:(int)dataLength timeOut:(int)timeout
{
    // 下位クラスで実装を行う。ここはダミー。
    NSLog(@"warn: HVC class receive()");
    return 0;
}

typedef enum : NSInteger
{
    HVC_COM_GET_VERSION = 0x00,
    HVC_COM_SET_CAMERA_ANGLE = 0x01,
    HVC_COM_GET_CAMERA_ANGLE = 0x02,
    HVC_COM_EXECUTE = 0x03,
    HVC_COM_SET_THRESHOLD = 0x05,
    HVC_COM_GET_THRESHOLD = 0x06,
    HVC_COM_SET_SIZE_RANGE = 0x07,
    HVC_COM_GET_SIZE_RANGE = 0x08,
    HVC_COM_SET_DETECTION_ANGLE = 0x09,
    HVC_COM_GET_DETECTION_ANGLE = 0x0A,
    HVC_COM_GET_FULL_IMAGE_DATA = 0x80
} HVC_COMMAND;

typedef struct _hvc_send_header {
    unsigned char syncbyte;
    unsigned char commandno;
    unsigned char dataLengthLSB;
    unsigned char dataLengthMSB;
} HVC_SEND_HEADER;

#define HVC_SEND_SYNCBYTE 0xFE

// コマンド送信
-(HVC_ERRORCODE)SendCommand:(HVC_COMMAND)inCommandNo data:(NSData *)inData
{
    HVC_SEND_HEADER header;
    NSMutableData *sendData;
    
    // ヘッダー作成
    header.syncbyte = HVC_SEND_SYNCBYTE;
    header.commandno = (unsigned char)inCommandNo;
    if ( inData != nil )
    {
        int datalen = (int)inData.length;
        header.dataLengthLSB = (unsigned char)(datalen & 0xff);
        header.dataLengthMSB = (unsigned char)((datalen >> 8) & 0xff);
    }
    else
    {
        header.dataLengthLSB = 0;
        header.dataLengthMSB = 0;
    }
    
    // データ作成
    sendData = [[NSMutableData alloc] initWithBytes:&header length:sizeof(HVC_SEND_HEADER)];
    if ( inData != nil )
    {
        [sendData appendData:inData];
    }
    
    // 送信
    int r = [self Send:sendData];
    if ( r != sendData.length )
    {
        return HVC_ERROR_SENDDATA;
    }
    
    return HVC_NORMAL;
}

typedef struct _hvc_receive_header {
    unsigned char syncbyte;
    unsigned char status;
    unsigned char dataLenLL;
    unsigned char dataLenLM;
    unsigned char dataLenML;
    unsigned char dataLenMM;
} HVC_RECEIVE_HEADER;


// ヘッダー受信
-(HVC_ERRORCODE)ReceiveHeader:(int)timeOut datalen:(int *)outDataSize status:(unsigned char *)outStatus
{
    // ヘッダー部の取得
    NSMutableData *recvData;
    int r = [self Receive:&recvData length:sizeof(HVC_RECEIVE_HEADER) timeOut:timeOut];
    
    if ( r != sizeof(HVC_RECEIVE_HEADER) )
    {
        NSLog(@"reH: ret=%d len=%lu", r, sizeof(HVC_RECEIVE_HEADER));
        return HVC_ERROR_HEADER_TIMEOUT;
    }
    HVC_RECEIVE_HEADER header;
    [recvData getBytes:&header length:sizeof(HVC_RECEIVE_HEADER)];
    if ( HVC_SEND_SYNCBYTE != header.syncbyte )
    {
        // 別の値だったということは、異常と判断する
        return HVC_ERROR_HEADER_INVALID;
    }
    
    // データ長の取得
    *outDataSize = header.dataLenLL + ( header.dataLenLM << 8 ) + ( header.dataLenML << 16 ) + ( header.dataLenMM << 24);
    // コマンドの実施結果取得
    *outStatus = header.status;
    
    return HVC_NORMAL;
}

// データ受信
-(HVC_ERRORCODE)ReceiveData:(int)timeOut datalen:(int)inDataSize data:(NSMutableData **)outResult
{
    if ( inDataSize <= 0 )
    {
        // いいの？正常で返して。INVALID系のエラーじゃなくて？
        return HVC_NORMAL;
    }
    
    // データを取得
    int r = [self Receive:outResult length:inDataSize timeOut:timeOut];
    if ( r != inDataSize )
    {
        return HVC_ERROR_DATA_TIMEOUT;
    }
    
    return HVC_NORMAL;
}


// GetVersion
-(HVC_ERRORCODE)GetVersion:(int)timeOut status:(unsigned char *)outStatus version:(HVC_VER *)ver
{
    // GetVersionの取得コマンド送信
    NSLog(@"start GetVersion");
    HVC_ERRORCODE err;
    err = [self SendCommand:HVC_COM_GET_VERSION data:nil];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"sendcommand error");
        return err;
    }
    
    // ヘッダー受信
    NSLog(@"getversion receiveHeader");
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"receiveHeader error");
        return err;
    }
    // 受信サイズチェック
    
    // データ受信
    NSLog(@"getversion receiveData");
    NSMutableData *recvDat;
    err = [self ReceiveData:timeOut datalen:dataLen data:&recvDat];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"receiveData error");
        return err;
    }
    unsigned char rDat[HVC_LEN_VERSIONSTRING+7];
    [recvDat getBytes:&rDat length:HVC_LEN_VERSIONSTRING+7];
    for ( int i=0; i<HVC_LEN_VERSIONSTRING; i++ ) ver.Str[i] = rDat[i];
    ver.Major = rDat[HVC_LEN_VERSIONSTRING];
    ver.Minor = rDat[HVC_LEN_VERSIONSTRING+1];
    ver.Release = rDat[HVC_LEN_VERSIONSTRING+2];
    ver.Rev = rDat[HVC_LEN_VERSIONSTRING+3] +
             (rDat[HVC_LEN_VERSIONSTRING+4]<<8) +
             (rDat[HVC_LEN_VERSIONSTRING+5]<<16) +
             (rDat[HVC_LEN_VERSIONSTRING+6]<<24);
    
    return HVC_NORMAL;
}

// SetCameraAngle
-(HVC_ERRORCODE)SetCameraAngle:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param
{
    HVC_ERRORCODE err;
    // データの準備
    unsigned char datasrc[1];
    datasrc[0] = (unsigned char)param.CameraAngle;
    NSData *sendData = [[NSData alloc] initWithBytes:&datasrc length:1];
    
    // コマンド送信
    err = [self SendCommand:HVC_COM_SET_CAMERA_ANGLE data:sendData];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    return HVC_NORMAL;
}


// GetCameraAngle
-(HVC_ERRORCODE)GetCameraAngle:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param
{
    HVC_ERRORCODE err;
    // コマンド送信
    err = [self SendCommand:HVC_COM_GET_CAMERA_ANGLE data:nil];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // データ受信
    NSMutableData *recvDat;
    err = [self ReceiveData:timeOut datalen:dataLen data:&recvDat];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    unsigned char rDat[1];
    [recvDat getBytes:&rDat length:1];
    param.CameraAngle = rDat[0];
    
    return HVC_NORMAL;
}

// SetThreshold
-(HVC_ERRORCODE)SetThreshold:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param
{
    HVC_ERRORCODE err;
    // データの準備
    unsigned char datasrc[8];
    datasrc[0] = (unsigned char)(param.body.Threshold & 0xff);
    datasrc[1] = (unsigned char)(param.body.Threshold >> 8);
    datasrc[2] = (unsigned char)(param.hand.Threshold & 0xff);
    datasrc[3] = (unsigned char)(param.hand.Threshold >> 8);
    datasrc[4] = (unsigned char)(param.face.Threshold & 0xff);
    datasrc[5] = (unsigned char)(param.face.Threshold >> 8);
    datasrc[6] = 0x00;
    datasrc[7] = 0x00;
    NSData *sendData = [[NSData alloc] initWithBytes:&datasrc length:8];
    
    // コマンド送信
    err = [self SendCommand:HVC_COM_SET_THRESHOLD data:sendData];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    return HVC_NORMAL;
}


// GetThreshold
-(HVC_ERRORCODE)GetThreshold:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param
{
    HVC_ERRORCODE err;
    // コマンド送信
    err = [self SendCommand:HVC_COM_GET_THRESHOLD data:nil];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // データ受信
    NSMutableData *recvDat;
    err = [self ReceiveData:timeOut datalen:dataLen data:&recvDat];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    unsigned char rDat[8];
    [recvDat getBytes:&rDat length:8];
    param.body.Threshold = (int)(rDat[0] + ( rDat[1] << 8 ));
    param.hand.Threshold = (int)(rDat[2] + ( rDat[3] << 8 ));
    param.face.Threshold =  rDat[4] + ( rDat[5] << 8 );
    
    return HVC_NORMAL;
}

// SetSizeRange
-(HVC_ERRORCODE)SetSizeRange:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param
{
    HVC_ERRORCODE err;
    // データの準備
    unsigned char datasrc[12];
    datasrc[0] = (unsigned char)(param.body.MinSize & 0xff);
    datasrc[1] = (unsigned char)(param.body.MinSize >> 8);
    datasrc[2] = (unsigned char)(param.body.MaxSize & 0xff);
    datasrc[3] = (unsigned char)(param.body.MaxSize >> 8);
    datasrc[4] = (unsigned char)(param.hand.MinSize & 0xff);
    datasrc[5] = (unsigned char)(param.hand.MinSize >> 8);
    datasrc[6] = (unsigned char)(param.hand.MaxSize & 0xff);
    datasrc[7] = (unsigned char)(param.hand.MaxSize >> 8);
    datasrc[8] = (unsigned char)(param.face.MinSize & 0xff);
    datasrc[9] = (unsigned char)(param.face.MinSize >> 8);
    datasrc[10] = (unsigned char)(param.face.MaxSize & 0xff);
    datasrc[11] = (unsigned char)(param.face.MaxSize >> 8);
    NSData *sendData = [[NSData alloc] initWithBytes:&datasrc length:12];
    
    // コマンド送信
    err = [self SendCommand:HVC_COM_SET_SIZE_RANGE data:sendData];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    return HVC_NORMAL;
}


// GetSizeRange
-(HVC_ERRORCODE)GetSizeRange:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param
{
    HVC_ERRORCODE err;
    // コマンド送信
    err = [self SendCommand:HVC_COM_GET_SIZE_RANGE data:nil];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // データ受信
    NSMutableData *recvDat;
    err = [self ReceiveData:timeOut datalen:dataLen data:&recvDat];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    unsigned char rDat[12];
    [recvDat getBytes:&rDat length:12];
    param.body.MinSize = (int)(rDat[0] + ( rDat[1] << 8 ));
    param.body.MaxSize = (int)(rDat[2] + ( rDat[3] << 8 ));
    param.hand.MinSize = (int)(rDat[4] + ( rDat[5] << 8 ));
    param.hand.MaxSize = (int)(rDat[6] + ( rDat[7] << 8 ));
    param.face.MinSize = (int)(rDat[8] + ( rDat[9] << 8 ));
    param.face.MaxSize = (int)(rDat[10] + ( rDat[11] << 8 ));
    
    return HVC_NORMAL;
}

// SetFaceDetectionAngle
-(HVC_ERRORCODE)SetFaceDetectionAngle:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param
{
    HVC_ERRORCODE err;
    // データの準備
    unsigned char datasrc[2];
    datasrc[0] = (unsigned char)(param.face.Pose & 0xff);
    datasrc[1] = (unsigned char)(param.face.Angle & 0xff);
    NSData *sendData = [[NSData alloc] initWithBytes:&datasrc length:2];
    
    // コマンド送信
    err = [self SendCommand:HVC_COM_SET_DETECTION_ANGLE data:sendData];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        return err;
    }
    
    return HVC_NORMAL;
}


// GetFaceDetectionAngle
-(HVC_ERRORCODE)GetFaceDetectionAngle:(int)timeOut status:(unsigned char *)outStatus parameter:(HVC_PRM *)param
{
    NSLog(@"GetFaceDetectionAngle");
    HVC_ERRORCODE err;
    // コマンド送信
    err = [self SendCommand:HVC_COM_GET_DETECTION_ANGLE data:nil];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"sendcommand err:%d", (int)err);
        return err;
    }
    
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"recvhd err:%d", (int)err);
        return err;
    }
    
    // データ受信
    NSMutableData *recvDat;
    err = [self ReceiveData:timeOut datalen:dataLen data:&recvDat];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"recvdat err:%d", (int)err);
        return err;
    }
    unsigned char rDat[2];
    [recvDat getBytes:&rDat length:2];
    param.face.Pose = (int)(rDat[0]);
    param.face.Angle = (int)(rDat[1]);
    
    NSLog(@"successed.");
    return HVC_NORMAL;
}


-(HVC_ERRORCODE)ExecuteFunc:(int)timeOut exec:(HVC_FUNCTION)inExec status:(unsigned char *)outStatus result:(HVC_RES *)result
{
    HVC_ERRORCODE err;
    
    NSLog(@"Execute : reset");
    // 結果情報をリセット
    [result Reset:inExec];
    
    // データの準備
    unsigned char datasrc[3];
    datasrc[0] = (unsigned char)(inExec & 0xff);
    datasrc[1] = (unsigned char)(inExec >> 8);
    datasrc[2] = 0x00;
    NSData *sendData = [[NSData alloc] initWithBytes:&datasrc length:3];
    
    NSLog(@"Execute : SendCommand");
    // コマンド送信
    err = [self SendCommand:HVC_COM_EXECUTE data:sendData];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"err:%d", (int)err);
        return err;
    }
    
    NSLog(@"Execute : ReceiveHeader");
    // ヘッダー受信
    int dataLen = 0;
    err = [self ReceiveHeader:timeOut datalen:&dataLen status:outStatus];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"err:%d", (int)err);
        return err;
    }
    // 内容チェック
    if ( dataLen < 4 )
    {
        // 結果なしなのでこのまま戻る
        NSLog(@"no result:%d", dataLen);
        return HVC_NORMAL;
    }
    NSLog(@"Execute : ReceiveData:%d", dataLen);
    // データ個数受信
    NSMutableData *recvDat;
    err = [self ReceiveData:timeOut datalen:4 data:&recvDat];
    if ( err != HVC_NORMAL )
    {
        NSLog(@"err:%d", (int)err);
        return err;
    }
    unsigned char rDat[4];
    [recvDat getBytes:&rDat length:4];
    int numBody = rDat[0];
    int numHand = rDat[1];
    int numFace = rDat[2];
    dataLen -= 4;
    NSLog(@"Execute : body=%d hand=%d face=%d", numBody, numHand, numFace);
    
    // 人体検出の結果取得
    for ( int i = 0 ; i < numBody ; i++ )
    {
        if ( dataLen >= 8 )
        {
            NSLog(@"Execute : ReceiveData(BodyDetect):8");
            // 一つずつ受信
            [recvDat setLength:0];
            err = [self ReceiveData:timeOut datalen:8 data:&recvDat];
            if ( err != HVC_NORMAL )
            {
                NSLog(@"err:%d", (int)err);
                return err;
            }
            unsigned char rDat[8];
            DetectionResult *dt = [[DetectionResult alloc] init];
            [recvDat getBytes:&rDat length:8];
            dt.posX = (int)( rDat[0] + ( rDat[1] << 8) );
            dt.posY = (int)( rDat[2] + ( rDat[3] << 8) );
            dt.size = (int)( rDat[4] + ( rDat[5] << 8) );
            dt.confidence = (int)( rDat[6] + ( rDat[7] << 8) );
            dataLen -= 8;
            [result setBody:dt];
        }
    }
    
    // 手検出の結果取得
    for ( int i = 0 ; i < numHand ; i++ )
    {
        if ( dataLen >= 8 )
        {
            NSLog(@"Execute : ReceiveData(HandDetect):8");
            // 一つずつ受信
            [recvDat setLength:0];
            err = [self ReceiveData:timeOut datalen:8 data:&recvDat];
            if ( err != HVC_NORMAL )
            {
                NSLog(@"err:%d", (int)err);
                return err;
            }
            unsigned char rDat[8];
            DetectionResult *dt = [[DetectionResult alloc] init];
            [recvDat getBytes:&rDat length:8];
            dt.posX = (int)( rDat[0] + ( rDat[1] << 8) );
            dt.posY = (int)( rDat[2] + ( rDat[3] << 8) );
            dt.size = (int)( rDat[4] + ( rDat[5] << 8) );
            dt.confidence = (int)( rDat[6] + ( rDat[7] << 8) );
            dataLen -= 8;
            [result setHand:dt];
        }
    }
    
    // 顔にまつわる結果取得
    for ( int i = 0 ; i < numFace ; i++ )
    {
        FaceResult *fd = [[FaceResult alloc] init];
        
        // 顔検出結果
        if ( 0 != ( result.executedFunc & HVC_ACTIV_FACE_DETECTION) )
        {
            if ( dataLen >= 8 )
            {
                NSLog(@"Execute : ReceiveData(FaceDetect):8");
                // 一つずつ受信
                [recvDat setLength:0];
                err = [self ReceiveData:timeOut datalen:8 data:&recvDat];
                if ( err != HVC_NORMAL )
                {
                    NSLog(@"err:%d", (int)err);
                    return err;
                }
                unsigned char rDat[8];
                [recvDat getBytes:&rDat length:8];
                fd.posX = (int)( rDat[0] + ( rDat[1] << 8) );
                fd.posY = (int)( rDat[2] + ( rDat[3] << 8) );
                fd.size = (int)( rDat[4] + ( rDat[5] << 8) );
                fd.confidence = (int)( rDat[6] + ( rDat[7] << 8) );
                dataLen -= 8;
            }
        }
        
        // 顔向き
        if ( 0 != ( result.executedFunc & HVC_ACTIV_FACE_DIRECTION) )
        {
            if ( dataLen >= 8 )
            {
                NSLog(@"Execute : ReceiveData(FaceDirection):8");
                // 一つずつ受信
                [recvDat setLength:0];
                err = [self ReceiveData:timeOut datalen:8 data:&recvDat];
                if ( err != HVC_NORMAL )
                {
                    NSLog(@"err:%d", (int)err);
                    return err;
                }
                unsigned char rDat[8];
                [recvDat getBytes:&rDat length:8];
                fd.dir.yaw = (short)( rDat[0] + ( rDat[1] << 8) );
                fd.dir.pitch = (short)( rDat[2] + ( rDat[3] << 8) );
                fd.dir.roll = (short)( rDat[4] + ( rDat[5] << 8) );
                fd.dir.confidence = (short)( rDat[6] + ( rDat[7] << 8) );
                dataLen -= 8;
            }
        }
        
        // 年齢
        if ( 0 != ( result.executedFunc & HVC_ACTIV_AGE_ESTIMATION) )
        {
            if ( dataLen >= 3 )
            {
                NSLog(@"Execute : ReceiveData(AgeEstimation):3");
                // 一つずつ受信
                [recvDat setLength:0];
                err = [self ReceiveData:timeOut datalen:3 data:&recvDat];
                if ( err != HVC_NORMAL )
                {
                    NSLog(@"err:%d", (int)err);
                    return err;
                }
                unsigned char rDat[3];
                [recvDat getBytes:&rDat length:3];
                fd.age.age = (char)rDat[0];
                fd.age.confidence = (short)( rDat[1] + ( rDat[2] << 8) );
                dataLen -= 3;
            }
        }
        
        // 性別
        if ( 0 != ( result.executedFunc & HVC_ACTIV_GENDER_ESTIMATION) )
        {
            if ( dataLen >= 3 )
            {
                NSLog(@"Execute : ReceiveData(GenderEstimation):3");
                // 一つずつ受信
                [recvDat setLength:0];
                err = [self ReceiveData:timeOut datalen:3 data:&recvDat];
                if ( err != HVC_NORMAL )
                {
                    NSLog(@"err:%d", (int)err);
                    return err;
                }
                unsigned char rDat[3];
                [recvDat getBytes:&rDat length:3];
                fd.gen.gender = (char)rDat[0];
                fd.gen.confidence = (short)( rDat[1] + ( rDat[2] << 8) );
                dataLen -= 3;
            }
        }
        
        // 視線
        if ( 0 != ( result.executedFunc & HVC_ACTIV_GAZE_ESTIMATION) )
        {
            if ( dataLen >= 2 )
            {
                NSLog(@"Execute : ReceiveData(GazeEstimation):2");
                // 一つずつ受信
                [recvDat setLength:0];
                err = [self ReceiveData:timeOut datalen:2 data:&recvDat];
                if ( err != HVC_NORMAL )
                {
                    NSLog(@"err:%d", (int)err);
                    return err;
                }
                unsigned char rDat[2];
                [recvDat getBytes:&rDat length:2];
                fd.gaze.gazeLR = (char)rDat[0];
                fd.gaze.gazeUD = (char)rDat[1];
                dataLen -= 2;
            }
        }
        
        // 目つむり
        if ( 0 != ( result.executedFunc & HVC_ACTIV_BLINK_ESTIMATION) )
        {
            if ( dataLen >= 4 )
            {
                NSLog(@"Execute : ReceiveData(BlinkEstimation):4");
                // 一つずつ受信
                [recvDat setLength:0];
                err = [self ReceiveData:timeOut datalen:4 data:&recvDat];
                if ( err != HVC_NORMAL )
                {
                    NSLog(@"err:%d", (int)err);
                    return err;
                }
                unsigned char rDat[4];
                [recvDat getBytes:&rDat length:4];
                fd.blink.ratioL = (short)( rDat[0] + ( rDat[1] << 8) );
                fd.blink.ratioR = (short)( rDat[2] + ( rDat[3] << 8) );
                dataLen -= 4;
            }
        }
        
        // 表情
        if ( 0 != ( result.executedFunc & HVC_ACTIV_EXPRESSION_ESTIMATION) )
        {
            if ( dataLen >= 3 )
            {
                NSLog(@"Execute : ReceiveData(ExpressionEstimate):3");
                // 一つずつ受信
                [recvDat setLength:0];
                err = [self ReceiveData:timeOut datalen:3 data:&recvDat];
                if ( err != HVC_NORMAL )
                {
                    NSLog(@"err:%d", (int)err);
                    return err;
                }
                unsigned char rDat[3];
                [recvDat getBytes:&rDat length:3];
                fd.exp.expression = (char)rDat[0];
                fd.exp.score = (char)rDat[1];
                fd.exp.degree = (char)rDat[2];
                dataLen -= 3;
            }
        }
        [result setFace:fd];
    }
    
    return HVC_NORMAL;
}

@end
