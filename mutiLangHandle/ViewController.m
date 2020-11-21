//
//  ViewController.m
//  mutiLangHandle
//
//  Created by hou hui on 2020/11/21.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    NSMutableDictionary *dict1 = [self dataArrayWithPath:[[NSBundle mainBundle] pathForResource:@"en" ofType:@"strings"]];
    NSMutableDictionary *dict2 = [self dataArrayWithPath:[[NSBundle mainBundle] pathForResource:@"vi" ofType:@"strings"]];
    NSMutableDictionary *dict3 = [self dataArrayWithPath:[[NSBundle mainBundle] pathForResource:@"id" ofType:@"strings"]];
    NSMutableDictionary *dict4 = [self dataArrayWithPath:[[NSBundle mainBundle] pathForResource:@"th" ofType:@"strings"]];
    
    NSMutableSet *insertSet = [NSMutableSet setWithArray:dict1.allKeys];
    NSMutableSet *set2 = [NSMutableSet setWithArray:dict2.allKeys];
    NSMutableSet *set3 = [NSMutableSet setWithArray:dict3.allKeys];
    NSMutableSet *set4 = [NSMutableSet setWithArray:dict4.allKeys];
    
    [insertSet intersectSet:set2];
    [insertSet intersectSet:set3];
    [insertSet intersectSet:set4];
//    NSLog(@"并集数: %d",insertSet.count);
    
    //得到所有元素的交集
    NSArray *ary = [insertSet.allObjects sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString *enString = [self stringWithDict:dict1 ary:ary];
    NSMutableString *viString = [self stringWithDict:dict2 ary:ary];
    NSMutableString *idString = [self stringWithDict:dict3 ary:ary];
    NSMutableString *thString = [self stringWithDict:dict4 ary:ary];
    
    NSLog(@"-------开始打印这些数组的交集，注意：打印可能不完整，建议断点调试打印------------\n");
    NSLog(@"------英文-----\n%@",enString);
    NSLog(@"------越南语-----\n%@",viString);
    NSLog(@"------印尼语-----\n%@",idString);
    NSLog(@"------泰语-----\n%@",thString);
    NSLog(@"\n-------打印交集完成------------\n");
    
    //计算差集并排序
    NSArray *dict1cj = [self minusSetArayWithArray:dict1.allKeys insetSet:insertSet];
    NSArray *dict2cj = [self minusSetArayWithArray:dict2.allKeys insetSet:insertSet];
    NSArray *dict3cj = [self minusSetArayWithArray:dict3.allKeys insetSet:insertSet];
    NSArray *dict4cj = [self minusSetArayWithArray:dict4.allKeys insetSet:insertSet];
    
    //分别取每种语言与交集的差集并打印
    NSMutableString *enString2 = [self stringWithDict:dict1 ary:dict1cj];
    NSMutableString *viString2 = [self stringWithDict:dict2 ary:dict2cj];
    NSMutableString *idString2 = [self stringWithDict:dict3 ary:dict3cj];
    NSMutableString *thString2 = [self stringWithDict:dict4 ary:dict4cj];
    NSLog(@"-------开始打印这些数组与交集的差集，注意：打印可能不完整，建议断点调试打印------------\n");
    NSLog(@"------英文-----\n%@",enString2);
    NSLog(@"------越南语-----\n%@",viString2);
    NSLog(@"------印尼语-----\n%@",idString2);
    NSLog(@"------泰语-----\n%@",thString2);
    NSLog(@"\n-------打印差集完成------------\n");
    
    NSLog(@"\n总结：这几种语言并集数为:%ld\n,英文差集为:%ld,越南语差集为:%ld,印尼语差集为:%ld,泰语差集为:%ld",insertSet.count,dict1cj.count,dict2cj.count,dict3cj.count,dict4cj.count);
}

-(NSArray *)minusSetArayWithArray:(NSArray *)ary insetSet:(NSSet *)insert {
    NSMutableSet *set = [NSMutableSet setWithArray:ary];
    [set minusSet:insert];
    NSArray *mAry = [set.allObjects sortedArrayUsingSelector:@selector(compare:)];
    return mAry;
}

- (NSMutableString *)stringWithDict:(NSMutableDictionary *)dict ary:(NSArray *)ary{
    
    NSMutableString *mString = [NSMutableString string];
    for (NSString *key in ary) {
        NSString *str = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n",key,dict[key]];
        [mString appendString:str];
    }
    return mString;
}

- (NSMutableDictionary *)dataArrayWithPath:(NSString *)path {
    
    NSMutableDictionary *mdict = [NSMutableDictionary dictionary];
    NSError *error = nil;
    //多语言会有各种语言存在，只能用unicode码来取
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF16StringEncoding error:&error];
//    NSLog(@"content = %@",content);
    NSArray *array = [content componentsSeparatedByString:@"\n"];
//    NSLog(@"arraycount = %d",array.count);
    NSMutableArray *newLines = [NSMutableArray array];
    for (NSInteger i = 0; i < array.count; i++) {
//        NSLog(@"line %d:%@",i,array[i]);
        NSString *linestr = array[i];
        if ([linestr rangeOfString:@"//"].location == NSNotFound &&
            [linestr rangeOfString:@"/*"].location == NSNotFound &&
            [linestr rangeOfString:@"*/"].location == NSNotFound &&
            [linestr rangeOfString:@"\""].location != NSNotFound &&
            [linestr rangeOfString:@"="].location != NSNotFound &&
            linestr.length > 6) {
            [newLines addObject:linestr];
        }
    }
//    NSLog(@"new Line count = %d",newLines.count);
    
    for (NSString *string in newLines) {
        
        NSMutableArray *ary = [NSMutableArray array];
        for (NSInteger i = 0; i < string.length; i++) {
            if ([[string substringWithRange:NSMakeRange(i, 1)] isEqualToString:@"\""]) {
                [ary addObject:@(i)];
            }
        }
        NSInteger index1 = [[ary objectAtIndex:0] intValue];
        NSInteger index2 = [[ary objectAtIndex:1] intValue];
        NSInteger index3 = [[ary objectAtIndex:2] intValue];
        NSInteger index4 = [[ary objectAtIndex:3] intValue];
        if (ary.count != 4) {//一行只能出现4个双引号，否则这行数据就是有问题的
            NSLog(@"error line (count = %ld): %@:%@",ary.count,string,ary);
        }
        NSString *key = [string substringWithRange:NSMakeRange(index1+1, index2-index1-1)];
        NSString *value = [string substringWithRange:NSMakeRange(index3+1, index4-index3-1)];
        if (key.length > 1 && value.length > 1) {
            [mdict setObject:value forKey:key];
        }
    }
    
    return mdict;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
