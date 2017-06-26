//
//  URLTextField.m
//  FileMan
//
//  Created by Sami Sharaf on 1/17/17.
//  Copyright © 2017 Sami Sharaf. All rights reserved.
//

#import "URLTextField.h"

@implementation URLTextField

-(CGRect)rightViewRectForBounds:(CGRect)bounds {
    
    CGRect textRect = [super rightViewRectForBounds:bounds];
    textRect.origin.x -= 8;
    return textRect;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
