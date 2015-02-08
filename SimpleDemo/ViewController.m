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
//  ViewController.m
//  SimpleDemo
//

#import "ViewController.h"

@interface ViewController ()
{
    int Status;
    HVC_FUNCTION ExecuteFlag;
}
@property HVC_BLE *HvcBLE;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property AVAudioPlayer* player;
@end

@implementation ViewController

@synthesize HvcBLE = _HvcBLE;

- (void)viewDidLoad {
    Status = 0;
    ExecuteFlag = 0;
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.HvcBLE = [[HVC_BLE alloc] init];
    self.HvcBLE.delegateHVC = self;
    
    _ResultTextView.text = @"";
    
    // リソースファイルをAVAudioPlayerにセット。
    NSString *path = [[NSBundle mainBundle] pathForResource:@"correct5" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath: path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL: url error:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushButton:(UIButton *)sender {
    switch ( Status )
    {
        case 0:
            // disconnect -> connect
            [self.HvcBLE deviceSearch];
            [self.pushbutton setTitle:@"disconnect" forState:UIControlStateNormal ];
            Status = 1;
            break;
        case 1:
            // connect -> disconnect
            [self.HvcBLE disconnect];
            [self.pushbutton setTitle:@"connect" forState:UIControlStateNormal];
            Status = 0;
            return;
        case 2:
            return;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (int i=0; i<10; i++) {
            sleep(1);
        }
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //dispatch_release(semaphore);
    
    // アラートを作る
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"デバイス接続"
                                              message:@"選択してください"
                                              delegate:self
                                              cancelButtonTitle:@"cancel"
                                              otherButtonTitles:nil];
    
    NSMutableArray *deviseList = [self.HvcBLE getDevices];
    for( int i = 0; i < deviseList.count; i++ )
    {
        NSString *name = ((CBPeripheral *)deviseList[i]).name;
        [alert addButtonWithTitle:name];
    }
    
    // アラートを表示する
    [alert show];
}

// アラートの処理（デリゲートメソッド）
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // キャンセルボタン
        NSLog(@"キャンセルされました");
        [self.pushbutton setTitle:@"connect" forState:UIControlStateNormal];
        Status = 0;
    } else {
        NSMutableArray *deviseList = [self.HvcBLE getDevices];
        [self.HvcBLE connect:deviseList[buttonIndex-1]];
        [self.pushbutton setTitle:@"disconnect" forState:UIControlStateNormal];
        Status = 1;
    }
}

- (IBAction)btnExecute_click:(UIButton *)sender {
    switch ( Status )
    {
        case 0:
            return;
        case 1:
            [self.btnExecution setTitle:@"stop" forState:UIControlStateNormal];
            Status = 2;
            break;
        case 2:
            [self.btnExecution setTitle:@"start" forState:UIControlStateNormal];
            Status = 1;
            return;
    }
    
    HVC_PRM *param = [[HVC_PRM alloc] init];
    param.face.MinSize = 60;
    param.face.MaxSize = 480;
    
    [self.HvcBLE setParam:param];
}

- (void)onConnected
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SUCCESS" message:@"接続しました"
                                                   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}
- (void)onDisconnected
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"SUCCESS" message:@"切断しました"
                                                   delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}
- (void)onPostGetDeviceName:(NSData *)value
{
    
}

- (void)onPostSetParam:(HVC_ERRORCODE)err status:(unsigned char)outStatus
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 各フラグ参照
        ExecuteFlag = HVC_ACTIV_BODY_DETECTION | HVC_ACTIV_HAND_DETECTION | HVC_ACTIV_FACE_DETECTION
                        | HVC_ACTIV_FACE_DIRECTION | HVC_ACTIV_AGE_ESTIMATION | HVC_ACTIV_GENDER_ESTIMATION
                        | HVC_ACTIV_GAZE_ESTIMATION | HVC_ACTIV_BLINK_ESTIMATION | HVC_ACTIV_EXPRESSION_ESTIMATION;
        
        HVC_RES *res = [[HVC_RES alloc] init];
        [self.HvcBLE Execute:ExecuteFlag result:res];
    });
}
- (void)onPostGetParam:(HVC_PRM *)param errcode:(HVC_ERRORCODE)err status:(unsigned char)outStatus
{
    
}
- (void)onPostGetVersion:(HVC_VER *)ver errcode:(HVC_ERRORCODE)err status:(unsigned char)outStatus
{
    
}

int black_count = 0;
int black_sum = 0;
int black_ave;

-(void) onPostExecute:(HVC_RES *)result errcode:(HVC_ERRORCODE)err status:(unsigned char)outStatus
{
    // 実行結果の受け取り
    NSString *resStr = @"";
    
    if((err == HVC_NORMAL) && (outStatus == 0)){

        
        int i;
        
        // 顔検出と各種推定
        resStr = [resStr stringByAppendingString:[NSString stringWithFormat:@"Face Detect = %d\n", result.sizeFace]];
        for(i = 0; i < result.sizeFace; i++){
            FaceResult *fd = [result face:i];
            
//            if (fd.exp.degree > 90) {
//                black_count +=1;
//            }else{
//                black_count = 0;
//            }
            black_count += 1;
            black_sum += fd.exp.degree;
            
            // 表情推定
            if((result.executedFunc & HVC_ACTIV_EXPRESSION_ESTIMATION) != 0){
                resStr = [resStr stringByAppendingString:[NSString stringWithFormat:@"  [Expression Estimation] : "]];
                
                NSString *expression;
                switch(fd.exp.expression){
                    case HVC_EX_NEUTRAL:
                        expression = @"普通";
                        break;
                    case HVC_EX_HAPPINESS:
                        expression = @"幸せ";
                        break;
                    case HVC_EX_SURPRISE:
                        expression = @"驚き";
                        break;
                    case HVC_EX_ANGER:
                        expression = @"怒り";
                        break;
                    case HVC_EX_SADNESS:
                        expression = @"悲しい";
                        break;
                }

                resStr = [resStr stringByAppendingString:[NSString stringWithFormat:@"expression = %@, ", expression]];
                resStr = [resStr stringByAppendingString:[NSString stringWithFormat:@"score = %d, ", fd.exp.score]];
                resStr = [resStr stringByAppendingString:[NSString stringWithFormat:@"degree = %d\n", fd.exp.degree]];
                resStr = [resStr stringByAppendingString:[NSString stringWithFormat:@"count = %d\n", black_count]];
                
            }
        }
    }
    _ResultTextView.text = resStr;
//    NSLog
//    if (black_count == 5) {
//        _resultLabel.text = @"スコア：%d",sum;
//        [self.player play];
//        black_count = 0;
//    }else if (black_count == 1){
//        _resultLabel.text = @"キープ！";
//    }
//    else{
//        _resultLabel.text = @"笑って";
//    }
    
    //5回の平均値算出
    if (black_count == 3) {
                black_ave = black_sum/black_count;
        resStr = [resStr stringByAppendingString:[NSString stringWithFormat:@"笑顔スコア%d",black_ave]];
        NSLog(@"笑顔スコア%d",black_ave);
        [self.player play];
        _ResultTextView.text = resStr;
        black_count = 0;
        black_sum = 0;
        return;
    }

    if ( Status == 2 ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HvcBLE Execute:ExecuteFlag result:result];
        });
    }
}

@end
