import numpy as np
import matplotlib.pyplot as plt

data = np.loadtxt('asc/2024.093.23.53.09.0000.TW.A002.10.E.ACC.D.SAC.asc', skiprows=1)

time = data[:, 0]
component1 = data[:, 1]
component2 = data[:, 2]
component3 = data[:, 3]

fig, axs = plt.subplots(3, 1, figsize=(10, 8))

axs[0].plot(time, component1)
axs[0].set_title('Component 1')
axs[0].set_ylabel('Amplitude')

axs[1].plot(time, component2)
axs[1].set_title('Component 2')
axs[1].set_ylabel('Amplitude')

axs[2].plot(time, component3)
axs[2].set_title('Component 3')
axs[2].set_xlabel('Time')
axs[2].set_ylabel('Amplitude')

plt.tight_layout()
plt.show()