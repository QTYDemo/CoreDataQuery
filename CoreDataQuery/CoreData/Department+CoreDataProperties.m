//
//  Department+CoreDataProperties.m
//  CoreDataQuery
//
//  Created by 覃团业 on 2020/2/24.
//  Copyright © 2020 覃团业. All rights reserved.
//
//

#import "Department+CoreDataProperties.h"

@implementation Department (CoreDataProperties)

+ (NSFetchRequest<Department *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Department"];
}

@dynamic departName;
@dynamic createDate;
@dynamic employee;

@end
