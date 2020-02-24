//
//  ViewController.m
//  CoreDataQuery
//
//  Created by 覃团业 on 2020/2/22.
//  Copyright © 2020 覃团业. All rights reserved.
//

#import "ViewController.h"
#import <CoreData/CoreData.h>
#import "Employee+CoreDataClass.h"
#import "Department+CoreDataClass.h"

@interface ViewController ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPersistentStoreCoordinator *psc;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self insertEmployee];
//    [self insetEntity];
//    [self conditionalQuery];
//    [self queryEntity];
//    [self pageQuery];
//    [self likeQuery];
//    [self requestTemplate];
//    [self queryCount1];
//    [self queryCount2];
//    [self querySum];
//    [self bulkUpdate];
    [self asyncQuery];
}

#pragma mark - 更新操作

// 批量更新
- (void)bulkUpdate {
    // 创建批量更新对象，并指明操作Employee表。
    NSBatchUpdateRequest *updateRequest = [NSBatchUpdateRequest batchUpdateRequestWithEntityName:@"Employee"];
    // 设置返回值类型，默认是什么都不返回（NSStatusOnlyResultType），这里设置返回反生改变的对象Count值
    updateRequest.resultType = NSUpdatedObjectsCountResultType;
    // 设置发生改变字段的字典
    updateRequest.propertiesToUpdate = @{@"height" : [NSNumber numberWithFloat:5.0f]};

    // 执行请求后，返回值是一个特定的result对象，通过result的属性获取返回的结果。NSManagedObjectContext的这个API是从iOS8出来的，所以需要注意版本兼容。
    NSError *error = nil;
    NSBatchUpdateResult *result = [self.context executeRequest:updateRequest error:&error];
    NSLog(@"batch update count is %ld", [result.result integerValue]);

    // 错误处理
    if (error) {
        NSLog(@"batch update request result error: %@", error);
    }

    // 更新NSManagedObjectContext的托管对象，使NSManagedObjectContext和本地持久化区数据同步
    [self.context refreshAllObjects];
}

#pragma mark - 查询操作

// 异步查询
- (void)asyncQuery {
    // 创建请求对象，并指明操作Employee表
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];

    // 创建异步请求对象，并通过一个block进行回调，返回结果是一个NSAsynchronousFetchResult类型参数
    NSAsynchronousFetchRequest *asycFetchRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:fetchRequest completionBlock:^(NSAsynchronousFetchResult * _Nonnull result) {
        [result.finalResult enumerateObjectsUsingBlock:^(Employee*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"fetch request result Employee.count = %ld, Employee.name = %@", result.finalResult.count, obj.name);
        }];
    }];

    // 执行异步请求，和批量处理执行同一个请求方法
    NSError *error = nil;
    [self.context executeRequest:asycFetchRequest error:&error];

    // 错误处理
    if (error) {
        NSLog(@"fetch request result error: %@", error);
    }
}

- (void)conditionalQuery {
    // 建立获取数据的请求对象，并指明操作Employee表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    
    // 设置请求条件，通过设置的条件，来过虑出需要的数据
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", @"lxz"];
    request.predicate = predicate;
    
    // 设置请求结果排序方式，可以设置一个或一组排序方式，最后将所有的排序方式添加到排序数组中
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"height" ascending:YES];
    // NSSortDescriptor的操作都是在SQLite层级完成的，不会将对象加载到内存中，所以对内存的消耗非常小的
    request.sortDescriptors = @[sort];
    
    // 执行获取请求操作，获取的托管对象将会被存储在一个数组中并返回
    NSError *error = nil;
    NSArray<Employee *> *employees = [self.context executeFetchRequest:request error:&error];
    if (error == nil) {
        [employees enumerateObjectsUsingBlock:^(Employee * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"Employee Name: %@, Height: %f, Birthday: %@", obj.name, obj.height, obj.brithday);
        }];
    } else {
        NSLog(@"CoreData Fetch Data Error: %@", error);
    }
}

- (void)queryEntity {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Department"];
    
    NSError *error = nil;
    NSArray<Department *> *departments = [self.context executeFetchRequest:request error:&error];
    
    if (error == nil) {
        [departments enumerateObjectsUsingBlock:^(Department * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"Department Search Result DepartName: %@, employee name: %@", obj.departName, obj.employee.name);
        }];
    } else {
        NSLog(@"Query entity error: %@", error);
    }
}

// 分页查询
- (void)pageQuery {
    // 创建获取数据的请求对象，并指明操作Employee表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];

    // 设置查找起点，这里是从搜索结果的第六个开始获取
    request.fetchOffset = 6;

    // 设置分页，每次请求获取六个托管对象
    request.fetchLimit = 6;

    // 设置排序规则，这里设置身高升序排序
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"height" ascending:YES];
    request.sortDescriptors = @[descriptor];

    // 执行查询操作
    NSError *error = nil;
    NSArray<Employee *> *employees = [self.context executeFetchRequest:request error:&error];
    [employees enumerateObjectsUsingBlock:^(Employee * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Page Search Result Name : %@, height : %f", obj.name, obj.height);
    }];

    // 错误处理
    if (error) {
        NSLog(@"Page Search Data Error: %@", error);
    }
}

// 模糊查询
- (void)likeQuery {
    // 创建获取数据的请求对象，设置对Employee表进行操作
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];

    // 创建模糊查询条件。这里设置的带通配符的查询，查询条件的结果包含lxz
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", @"*lxz*"];
    request.predicate = predicate;

    // 执行查询操作
    NSError *error = nil;
    NSArray<Employee *> *employees = [self.context executeFetchRequest:request error:&error];
    [employees enumerateObjectsUsingBlock:^(Employee * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Fuzzy Search Result Name : %@, height : %f", obj.name, obj.height);
    }];

    // 处理错误
    if (error) {
        NSLog(@"Fuzzy Search Data Error : %@", error);
    }
}

// 请求模板
- (void)requestTemplate {
    // 通过NSManagedObjectContext获取模型文件对应的托管对象模型
    NSManagedObjectModel *model = self.context.persistentStoreCoordinator.managedObjectModel;
    // 通过.xcdatamodeld文件中设置的模板名，获取请求对象
    NSFetchRequest *fetchRequest = [model fetchRequestTemplateForName:@"EmployeeFR"];

    // 请求数据， 下面的操作和普通请求一样
    NSError *error = nil;
    NSArray <Employee *> *dataList = [self.context executeFetchRequest:fetchRequest error:&error];
    [dataList enumerateObjectsUsingBlock:^(Employee * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"Employee.count = %ld, Employee.height = %f", dataList.count, obj.height);
    }];

    // 错误处理
    if (error) {
        NSLog(@"Execute Fetch Request Error : %@", error);
    }
}

// 查询数据数量
- (void)queryCount1 {
    // 设置过虑条件，可以根据需求设置自己的过虑条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"height < 2"];
    // 创建请求对象，并指明操作Employee表
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    fetchRequest.predicate = predicate;
    // 这一步是关键。设置返回结果类型为Count，返回结果为NSNumber类型
    fetchRequest.resultType = NSCountResultType;

    // 执行查询操作，返回的结果还是数组，数组中值存在一个对象，就是计算出的Count值
    NSError *error = nil;
    NSArray *dataList = [self.context executeFetchRequest:fetchRequest error:&error];
    NSInteger count = [dataList.firstObject integerValue];
    NSLog(@"fetch request result Employee.count = %ld", count);

    // 错误处理
    if (error) {
        NSLog(@"fetch request result error : %@", error);
    }
}

- (void)queryCount2 {
    // 设置过虑条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"height < 2"];
    // 创建请求对象，指明操作Employee表
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    fetchRequest.predicate = predicate;

    // 通过调用NSManagedObjectContext的countForFetchRequest:error:方法，获取请求结果count值，返回结果直接是NSUInteger类型变量
    NSError *error = nil;
    NSUInteger count = [self.context countForFetchRequest:fetchRequest error:&error];
    NSLog(@"fetch request result count is : %ld", count);

    // 错误处理
    if (error) {
        NSLog(@"fetch request result error : %@", error);
    }
}

// 使用位运算求和
- (void)querySum {
    // 创建请求对象，指明操作Employee表
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Employee"];
    // 设置返回值为字典类型，这是为了结果可以通过设置的name名取出，这一步是必须的
    fetchRequest.resultType = NSDictionaryResultType;

    // 创建描述对象
    NSExpressionDescription *expressionDes = [[NSExpressionDescription alloc] init];
    // 设置描述对象的name，最后结果需要用这个name当做key来取出结果
    expressionDes.name = @"sumOperatin";
    // 设置返回值类型，根据运算结果设置类型
    expressionDes.expressionResultType = NSFloatAttributeType;

    // 创建具体描述对象，用来描述对那个属性进行什么运算（可执行的运算类型很多，这里描述的是对height属性，做sum运算
    NSExpression *expression = [NSExpression expressionForFunction:@"sum:" arguments:@[[NSExpression expressionForKeyPath:@"height"]]];
    // 只能对应一个具体描述对象
    expressionDes.expression = expression;
    // 给请求对象设置描述对象，这里是一个数组类型，也就是可以设置多个描述对象
    fetchRequest.propertiesToFetch = @[expressionDes];

    // 执行请求，返回值还是一个数组，数组中只有一个元素，就是存储计算结果的字典
    NSError *error = nil;
    NSArray *resultArr = [self.context executeFetchRequest:fetchRequest error:&error];
    // 通过上面设置的name值，当做请求结果的key取出计算结果
    NSNumber *number = resultArr.firstObject[@"sumOperatin"];
    NSLog(@"fetch request result is %f", [number floatValue]);

    // 错误处理
    if (error) {
        NSLog(@"fetch request result error : %@", error);
    }
}

#pragma mark - 插入操作

- (void)insertEmployee {
    //创建托管对象，并指明创建的托管对象所属实体名
    Employee *emp = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.context];
    emp.name = @"lxz";
    emp.height = 1.7;
    emp.brithday = [NSDate date];
    
    // 通过上下文保存对象，并在保存前判断是否有更改
    NSError *error = nil;
    if (self.context.hasChanges) {
        [self.context save:&error];
    }
    
    // 处理错误
    if (error) {
        NSLog(@"insert employee error: %@", error);
    }
}

- (void)insetEntity {
    // 创建托管对象，并将其关联到指定的MOC上
    Employee *zsEmployee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.context];
    zsEmployee.name = @"zhangsan";
    zsEmployee.height = 1.9f;
    zsEmployee.brithday = [NSDate date];
    
    Employee *lsEmployee = [NSEntityDescription insertNewObjectForEntityForName:@"Employee" inManagedObjectContext:self.context];
    lsEmployee.name = @"lisi";
    lsEmployee.height = 1.7f;
    lsEmployee.brithday = [NSDate date];
    
    Department *iosDepartment = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:self.context];
    iosDepartment.departName = @"iOS";
    iosDepartment.createDate = [NSDate date];
    iosDepartment.employee = zsEmployee;
    
    Department *androidDepartment = [NSEntityDescription insertNewObjectForEntityForName:@"Department" inManagedObjectContext:self.context];
    androidDepartment.departName = @"android";
    androidDepartment.createDate = [NSDate date];
    androidDepartment.employee = lsEmployee;
    
    // 执行存储操作
    NSError *error = nil;
    if (self.context.hasChanges) {
        [self.context save:&error];
    }

    // 错误处理
    if (error) {
        NSLog(@"Association Table add Data Error: %@", error);
    }
}

#pragma mark - 懒加载

- (NSPersistentStoreCoordinator *)psc {
    // 创建托管对象模型，并使用ManualCoreData.xcdatamodeId路径当中初始化参数
    NSURL *modelPath = [[NSBundle mainBundle] URLForResource:@"CoreDataQuery" withExtension:@"momd"];
    if (@available(iOS 11.0, *)) {} else {
        modelPath = [modelPath URLByAppendingPathComponent:@"CoreDataQuery.mom"];
    }
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelPath];
    
    // 创建持久化存储调度器
    _psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    // 创建并关联SQLite数据库文件，如果已经存在则不会重复创建
    NSString *dataPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    dataPath = [dataPath stringByAppendingFormat:@"/%@.sqlite", @"CoreDataQuery"];
    NSError *error = nil;
    [_psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:dataPath] options:nil error:&error];
    
    if (error) {
        NSLog(@"Init NSPersistentStoreCoordinator error: %@", error);
        _psc = nil;
    }
    
    return _psc;
}

- (NSManagedObjectContext *)context {
    if (self.psc != nil && _context == nil) {
        // 创建上下文对象，并发队列设置为主队列
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _context.persistentStoreCoordinator = self.psc;
    }
    
    return _context;
}

@end
