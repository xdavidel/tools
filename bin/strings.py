#!/usr/bin/env python

##########################################################################################################
##
## Like steroids for your strings!
##
## Original idea: @williballenthin 
## Original link: https://gist.github.com/williballenthin/8e3913358a7996eab9b96bd57fc59df2
##
## Lipstick and rouge by: @herrcore
##########################################################################################################

import sys
import re
import argparse
from collections import namedtuple


ASCII_BYTE = " !\"#\$%&\'\(\)\*\+,-\./0123456789:;<=>\?@ABCDEFGHIJKLMNOPQRSTUVWXYZ\[\]\^_`abcdefghijklmnopqrstuvwxyz\{\|\}\\\~\t"


String = namedtuple("String", ["s", "offset"])


def ascii_strings(buf, n=4):
    reg = "([%s]{%d,})" % (ASCII_BYTE, n)
    ascii_re = re.compile(reg)
    for match in ascii_re.finditer(buf):
        yield String(match.group().decode("ascii"), match.start())

def unicode_strings(buf, n=4):
    reg = b"((?:[%s]\x00){%d,})" % (ASCII_BYTE, n)
    uni_re = re.compile(reg)
    for match in uni_re.finditer(buf):
        try:
            yield String(match.group().decode("utf-16"), match.start())
        except UnicodeDecodeError:
            pass


def main():
    parser = argparse.ArgumentParser(description="Extract strings.")
    parser.add_argument("infile", help="File to extract from.")
    parser.add_argument('-a','--ascii',dest="ascii_only",action='store_true',default=False,help="Only extract ascii strings.")
    parser.add_argument('-u','--unicode',dest="unicode_only",action='store_true',default=False,help="Only extract unicode strings.")
    parser.add_argument('-o','--offset',dest="set_offset",action='store_true',default=False,help="Include string offset.")
    parser.add_argument('--size', type=int, dest="string_size",help="Set minumum length of string to extract. Default: 4")
    args = parser.parse_args()

    with open(args.infile, 'rb') as f:
        b = f.read()

    #setup the min string size
    if args.string_size == None:
        string_size = 4;
    else:
        string_size = args.string_size

    #should we print the string offset
    if args.set_offset:
        if args.ascii_only:
            for s in ascii_strings(b,n=string_size):
                print('0x{:x}: {:s}'.format(s.offset, s.s))
        elif args.unicode_only:
            for s in unicode_strings(b,n=string_size):
                print('0x{:x}: {:s}'.format(s.offset, s.s))
        else:
            for s in ascii_strings(b,n=string_size):
                print('0x{:x}: {:s}'.format(s.offset, s.s))

            for s in unicode_strings(b,n=string_size):
                print('0x{:x}: {:s}'.format(s.offset, s.s))
    else:
        if args.ascii_only:
            for s in ascii_strings(b,n=string_size):
                print('{:s}'.format(s.s))
        elif args.unicode_only:
            for s in unicode_strings(b,n=string_size):
                print('{:s}'.format(s.s))
        else:
            for s in ascii_strings(b,n=string_size):
                print('{:s}'.format(s.s))
                
            for s in unicode_strings(b,n=string_size):
                print('{:s}'.format(s.s))




if __name__ == '__main__':
    main()
