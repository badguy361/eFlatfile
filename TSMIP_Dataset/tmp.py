from obspy import read
st = read("./GuanshanChishangeq/rowdata/20220918144415.mseed")
print(st.__str__(extended=True))