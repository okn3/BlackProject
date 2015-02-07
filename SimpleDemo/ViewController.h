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
//  ViewController.h
//  SimpleDemo
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "../SDK/HVC_BLE.h"


@interface ViewController : UIViewController <HVC_Delegate>

@property (weak, nonatomic) IBOutlet UIButton *pushbutton;
- (IBAction)pushButton:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *btnExecution;
- (IBAction)btnExecute_click:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITextView *ResultTextView;

@end

