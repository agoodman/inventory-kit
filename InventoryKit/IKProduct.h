//
//  IKProduct.h
//  InventoryKit
//
//  Created by Aubrey Goodman on 3/7/11.
//  Copyright 2011 Migrant Studios LLC. 
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//

#import <Foundation/Foundation.h>

#define kProductsUrl	@"http://enrollmint.com/products.json"


@interface IKProduct : NSObject {

	NSNumber* productId;
	NSString* identifier;
	NSNumber* price;
	NSNumber* duration;
	NSDate* createdAt;
	NSDate* updatedAt;
}

@property (retain) NSNumber* productId;
@property (retain) NSString* identifier;
@property (retain) NSNumber* price;
@property (retain) NSNumber* duration;
@property (retain) NSDate* createdAt;
@property (retain) NSDate* updatedAt;

@end


typedef void (^IKProductBlock)(IKProduct*);
