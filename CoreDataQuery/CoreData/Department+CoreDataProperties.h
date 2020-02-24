//
//  Department+CoreDataProperties.h
//  CoreDataQuery
//
//  Created by 覃团业 on 2020/2/24.
//  Copyright © 2020 覃团业. All rights reserved.
//
//

#import "Department+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Department (CoreDataProperties)

+ (NSFetchRequest<Department *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *departName;
@property (nullable, nonatomic, copy) NSDate *createDate;
@property (nullable, nonatomic, retain) Employee *employee;

@end

NS_ASSUME_NONNULL_END
