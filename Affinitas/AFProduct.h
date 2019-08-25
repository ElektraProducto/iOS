//
//  AFProduct.h
//  Affinitas
//
//  Created by Miguel Angel Olmedo Perez on 8/25/19.
//  Copyright © 2019 Onur Unal. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AFProduct : JSONModel

@property(nonatomic, nullable) NSString* foto;
@property(nonatomic, nullable) NSString* nombre;
@property(nonatomic, nullable) NSString* precio;
@property(nonatomic, nullable) NSString* sku;

@end

NS_ASSUME_NONNULL_END
