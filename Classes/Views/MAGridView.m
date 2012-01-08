/*
 * Copyright (c) 2010-2012 Matias Muhonen <mmu@iki.fi>
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "MAGridView.h"

@interface MAGridView (PrivateMethods)
- (void)setupCustomInitialisation;
@end

@implementation MAGridView

@synthesize horizontalLines=_horizontalLines;
@synthesize verticalLines=_verticalLines;
@synthesize lineWidth=_lineWidth;
@synthesize lineColor=_lineColor;
@synthesize outerBorder=_outerBorder;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		[self setupCustomInitialisation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		[self setupCustomInitialisation];
	}
	return self;
}


- (void)setupCustomInitialisation {
	self.rows             = 8;
	self.columns          = 8;
	self.lineWidth        = 1;
	self.horizontalLines  = YES;
	self.verticalLines    = YES;
	self.outerBorder      = YES;
	self.lineColor        = [UIColor lightGrayColor]; // retain
}

- (void)setRows:(unsigned int)rows {
	_rows = rows;
}

- (void)setColumns:(unsigned int)columns {
	_columns = columns;
}

- (unsigned int)rows {
	return _rows;
}

- (unsigned int)columns {
	return _columns;
}

- (CGFloat)cellWidth {
	if (_columns > 0) {
		return self.bounds.size.width  / _columns;
	} else {
		return 0;
	}
}

- (CGFloat)cellHeight {
	if (_rows > 0) {
		return self.bounds.size.height / _rows;
	} else {
		return 0;
	}
}

- (void)drawRect:(CGRect)rect {
	if (!(_columns > 0 && _rows > 0)) {
		// Nothing to draw
		return;
	}
	
    CGFloat cellHeight = self.cellHeight;
    CGFloat cellWidth = self.cellWidth;
	register unsigned int i;
	CGFloat x, y;
	
	const CGContextRef c          = UIGraphicsGetCurrentContext();
	const CGFloat      lineMiddle = _lineWidth / 2.f;
	
	CGContextSetStrokeColorWithColor(c, [_lineColor CGColor]);
	CGContextSetLineWidth(c, _lineWidth);
	
	CGContextBeginPath(c); {
		x = CGRectGetMinX(rect);
		y = CGRectGetMinY(rect);
		
		for (i=0; i <= _rows && _horizontalLines; i++) {
			if (i == 0) {
				y += lineMiddle;
				if (!_outerBorder) goto NEXT_ROW;
			} else if (i == _rows) {
				y = CGRectGetMaxY(rect) - lineMiddle;
				if (!_outerBorder) goto NEXT_ROW;
			}
			
			CGContextMoveToPoint(c, x, y);
			CGContextAddLineToPoint(c, self.bounds.size.width, y);
			
		NEXT_ROW:
			y += cellHeight;
		}
		
		x = CGRectGetMinX(rect);
		y = CGRectGetMinY(rect);
		
		for (i=0; i <= _columns && _verticalLines; i++) {
			if (i == 0) {
				x += lineMiddle;
				if (!_outerBorder) goto NEXT_COLUMN;
			} else if (i == _columns) {
				x = CGRectGetMaxX(rect) - lineMiddle;
				if (!_outerBorder) goto NEXT_COLUMN;
			}
		
			CGContextMoveToPoint(c, x, y);
			CGContextAddLineToPoint(c, x, self.bounds.size.height);
			
		NEXT_COLUMN:
			x += cellWidth;
		}
	}
	
	CGContextClosePath(c);
	CGContextSaveGState(c);
	CGContextDrawPath(c, kCGPathFillStroke);
	CGContextRestoreGState(c);
}

@end