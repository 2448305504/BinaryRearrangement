//
//  ViewController.m
//  Test
//
//  Created by 林文俊 on 2021/7/23.
//

#import "ViewController.h"
#import "BLStopwatch.h"
#import "Test-Swift.h"
#import <dlfcn.h>
#import <libkern/OSAtomic.h>

@interface ViewController ()

@end

@implementation ViewController

+(void)load {
    NSLog(@"load");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self test];
}

- (void)test {
    func();
}

void func() {
    block();
}

void(^block)(void) = ^(void) {
    [SwiftTestObject swiftTest];
};

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start, uint32_t *stop) {
    static uint64_t N;  // Counter for the guards.
    if (start == stop || *start) return;  // Initialize only once.
    printf("INIT: %p %p\n", start, stop);
    for (uint32_t *x = start; x < stop; x++)
    *x = ++N;  // Guards should start from 1.
}

// 初始化院子队列
static OSQueueHead list = OS_ATOMIC_QUEUE_INIT;
// 定义节点结构体
typedef struct {
    void *pc; // 存下获取到的PC
    void *next; // 指向下一个节点
} Node;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // [self test];
    NSMutableArray *arr = [NSMutableArray array];
    while (1) {
        Node *node = OSAtomicDequeue(&list, offsetof(Node, next));
        if (node == NULL) { // 退出机制
            break;
        }
        // 获取函数信息
        Dl_info info;
        dladdr(node->pc, &info);
        NSString *sname = [NSString stringWithCString:info.dli_sname encoding:NSUTF8StringEncoding];
        
        // 处理c函数以及block前缀
        BOOL isObjc = [sname hasPrefix:@"+["] || [sname hasPrefix:@"-["];
        // c函数及block需要在开头添加下划线
        sname = isObjc ? sname : [@"_" stringByAppendingString:sname];
        
        // 去重复
        if (![arr containsObject:sname]) {
            // 入栈
            [arr insertObject:sname atIndex:0];
        }
        // 打印看看
        // printf("%s \n", info.dli_sname);
    }
    // 去掉touchBegan方法(因为启动时，不会调用它)
    [arr removeObject:[NSString stringWithFormat:@"%s", __FUNCTION__]];
    // 将数组合成字符串
    NSString *funcStr = [arr componentsJoinedByString:@"\n"];
    // 写入文件
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"link.order"];
    NSLog(@"path: %@", filePath);
    NSData *fileContents = [funcStr dataUsingEncoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
}

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
   // if (!*guard) return; // guard为0会直接return，不会捕获load
   void *PC = __builtin_return_address(0);
    
//  char PcDescr[1024];
//  printf("guard: %p %x PC %s\n", guard, *guard, PcDescr);
    
//    Dl_info info;
//    dladdr(PC, &info);
//
//    printf("fname=%s \n fbase=%p \n sname=%s \n saddr=%p \n",
//           info.dli_fname,
//           info.dli_fbase,
//           info.dli_sname,
//           info.dli_saddr);
    
    Node *node = malloc(sizeof(Node));
    *node = (Node){PC, NULL};
    //offsetOf() 计算出列尾，OSAtomicEnqueue() 把node加入list尾巴
    OSAtomicEnqueue(&list, node, offsetof(Node, next));
}


@end
