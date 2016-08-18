//
//  ViewController.m
//  GCD下载网络图片以及调度组的使用
//
//  Created by 天桥算命 on 16/8/18.
//  Copyright © 2016年 OrangeIce. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(strong,nonatomic) NSArray *URLArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self downloadWithURLArray:self.URLArray completion:^(NSArray *failedArray) {
       
        NSLog(@"%@",failedArray);
    }];
}


#pragma mark - 调度组的方法
- (void)downloadWithURLArray:(NSArray *)URLArray completion:(void(^)(NSArray *failedArray))FailedArray {
    
    // 调度组
    dispatch_group_t group = dispatch_group_create();
    
    // 队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    //遍历URL数组
    for (NSString *urlString in URLArray) {
        
        // 把一个异步任务添加到调度组和队列里面
        dispatch_group_async(group, queue, ^{
            
            UIImage *image = [self downloadWithURLString1:urlString];
            
            NSLog(@"下载图片 %@ --  当前线程 %@",image,[NSThread currentThread]);
        
        });
        
    }
    // 监听 group 里面的所有的异步任务是否执行完,如果执行完就自动的执行dispatch_group_notify这个函数
    // 异步监听
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        // 写图片下载完成之后的代码
        NSLog(@"刷新UI %@",[NSThread currentThread]);
    });
}


#pragma mark - 下载图片的方法

//方法一. dataWithContentsOfURL
- (UIImage *)downloadWithURLString1:(NSString *)URLString {
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:URLString]];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

//方法二. NSURLConnection
- (void)downloadWithURLString2:(NSString *)URLString {
    
    //1.URL
    NSURL *url = [NSURL URLWithString:URLString];
    //2.请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //3.发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        //4.处理响应
        if (connectionError == nil && data != nil) {
            //获取data
            UIImage *image = [UIImage imageWithData:data];
            
        }else {
           
            NSLog(@"%@",connectionError);
        }
    }];
}

#pragma mark - 懒加载
- (NSArray *)URLArray {
    
    if (_URLArray == nil) {
        
        _URLArray = @[@"http://d.hiphotos.baidu.com/image/h%3D200/sign=6008b360f336afc3110c38658318eb85/a1ec08fa513d26973aa9f6fd51fbb2fb4316d81c.jpg",
                      @"http://www.4j4j.cn/upload/pic/20121031/261e39e216.jpg",
                      @"http://e.hiphotos.baidu.com/image/h%3D200/sign=4b8869d4a9345982da8ae2923cf5310b/d009b3de9c82d15810eaa411840a19d8bc3e4222.jpg"
                      ];
    }
    
    return _URLArray;
}





@end
