import zlib
import struct
import sys

if len(sys.argv) < 2 : 
    print('USAGE: PLZCompress.py <inputfile>')
    sys.exit(0)

compress_file = sys.argv[1]
decompress_file = compress_file.rsplit('.', 1)[0] + ".plz"
indata  =  open(compress_file, "rb").read()
outdata = zlib.compress(indata,zlib.Z_BEST_COMPRESSION)
MAGIC = b"\x2E\x50\x4C\x5A\x01\x01\x01\x01\x00\x00\x12\x30\xC9\x5A\x37\x6D"
with open(decompress_file,"wb") as outfile:
    outfile.write(MAGIC)
    outfile.write(struct.pack('>II',len(indata),len(outdata)))
    outfile.write(b"\x00"*40)
    outfile.write(outdata)

