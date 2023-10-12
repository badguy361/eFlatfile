from obspy import read
st = read("./GuanshanChishangeq/rowdata2/0916-0917.mseed")
print(st.__str__(extended=True))