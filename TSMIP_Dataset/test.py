from obspy import read
import matplotlib.pyplot as plt
import numpy as np
st = read("GuanshanChishangeq/20220917214100.mseed")
print(st[0].stats)
for k, v in sorted(st[0].stats.mseed.items()):
    print("'%s': %s" % (k, str(v))) 
print(st[0].data)

x = np.arange(-120,480,0.01)
y = st[0].data

plt.plot(x,y)

