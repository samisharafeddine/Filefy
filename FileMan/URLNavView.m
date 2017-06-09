//
//  URLNavView.m
//  FileMan
//
//  Created by Sami Sharaf on 12/29/16.
//  Copyright © 2016 Sami Sharaf. All rights reserved.
//

#import "URLNavView.h"

@implementation URLNavView

-(CGSize)sizeThatFits:(CGSize)size {
    
    CGFloat width = size.width;
    
    CGSize newSize = CGSizeMake(width, 33);
    
    return newSize;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
