//
//  pdfpop.m
//  pdfpop
//
// Copyright (c) 2017 Tommy Allen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to do
// so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

int main(int argc, const char * argv[]) {
  @autoreleasepool {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *infile = [defaults stringForKey:@"in"];
    NSString *outfile = [defaults stringForKey:@"out"];
    NSString *range = [defaults stringForKey:@"range"];

    if (infile == nil && range == nil) {
      fprintf(stderr, "Missing -in and -range\n");
      return 1;
    }

    if (outfile == nil) {
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"yyyy-MM-dd_HH:mm:ss"];
      outfile = [[infile stringByDeletingPathExtension]
                 stringByAppendingFormat:@"_%@.pdf",
               [formatter stringFromDate:[NSDate date]]];
    }

    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager isWritableFileAtPath:[outfile stringByDeletingLastPathComponent]]) {
      fprintf(stderr, "Can't write file: %s\n", [outfile UTF8String]);
      return 1;
    }

    NSURL *inurl = [NSURL fileURLWithPath:infile];
    PDFDocument *doc = [[[PDFDocument alloc] initWithURL:inurl] autorelease];

    NSMutableArray *ranges = [NSMutableArray arrayWithArray:[range componentsSeparatedByString:@","]];
    for (NSUInteger i = 0; i < [ranges count]; i++) {
      NSString *curRange = (NSString *)[ranges objectAtIndex:i];
      NSArray *r = [curRange componentsSeparatedByString:@"-"];
      NSInteger last = 0;
      for (NSUInteger ri = 0; ri < MIN(2, [r count]); ri++) {
        NSInteger p = [(NSString *)[r objectAtIndex:ri] integerValue];
        if (p <= last) {
          fprintf(stderr, "Invalid range: %s\n", [curRange UTF8String]);
          return 1;
        } else if (ri > [doc pageCount]) {
          fprintf(stderr, "PDF does not have enough pages for range: %s\n",
                  [curRange UTF8String]);
          return 1;
        }
        last = p;
      }
      [ranges replaceObjectAtIndex:i withObject:r];
    }

    NSInteger curPage = 0;
    PDFDocument *out = [[[PDFDocument alloc] init] autorelease];

    for (NSArray *range in ranges) {
      NSInteger page1 = [(NSString *)[range objectAtIndex:0] integerValue];
      NSInteger page2 = page1;
      if ([range count] > 1) {
        page2 = [(NSString *)[range objectAtIndex:1] integerValue];
      }

      for (NSInteger p = page1; p < page2 + 1; p++) {
        PDFPage *page = [doc pageAtIndex:p];
        [out insertPage:page atIndex:curPage];
        curPage++;
      }
    }

    [out writeToFile:outfile];
    fprintf(stderr, "Wrote PDF: %s\n", [outfile UTF8String]);
  }

  return 0;
}
