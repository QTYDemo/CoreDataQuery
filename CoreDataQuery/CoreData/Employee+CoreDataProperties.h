//
//  Employee+CoreDataProperties.h
//  CoreDataQuery
//
//  Created by 覃团业 on 2020/2/24.
//  Copyright © 2020 覃团业. All rights reserved.
//
//

#import "Employee+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Employee (CoreDataProperties)

+ (NSFetchRequest<Employee *> *)fetchRequest;

@property (nonatomic) float height;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *brithday;
@property (nullable, nonatomic, copy) NSString *sectionName;
@property (nullable, nonatomic, retain) Department *department;

@end

NS_ASSUME_NONNULL_END
