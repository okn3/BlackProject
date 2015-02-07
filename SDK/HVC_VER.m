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
//  HVC_VER.m
//  SimpleDemo
//

#import "HVC_VER.h"

@implementation HVC_VER

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        for(int i=0; i<sizeof(str); i++) str[i]=0;
        major = 0;
        minor = 0;
        release = 0;
        rev = 0;
    }
    return self;
}

// アクセッサ
-(void) setStr:(unsigned char *)value { for(int i=0; i<sizeof(str); i++) str[i]=value[i]; }
-(unsigned char *)Str { return str; }
-(void) setMajor:(unsigned char)value { major = value; }
-(unsigned char)Major { return major; }
-(void) setMinor:(unsigned char)value { minor = value; }
-(unsigned char)Minor { return minor; }
-(void) setRelease:(unsigned char)value { release = value; }
-(unsigned char)Release { return release; }
-(void) setRev:(unsigned int)value { rev = value; }
-(unsigned int)Rev { return rev; }

-(NSString *) getString { return [NSString stringWithFormat:@"%d.%d.%d.%d[%s]", major, minor, release, rev, str]; }

@end
