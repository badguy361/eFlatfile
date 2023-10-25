import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
df = pd.read_csv('total_year.csv')
df.head()
df['GCMT_Dip1'] = df['GCMT_Dip1'].fillna(0.0)
def isna(value):
    if value == 0.0:
        return 0
    else:
        return 1
df['GCMT_Dip1'] = df['GCMT_Dip1'].apply(lambda x:isna(x))
index = np.arange(601)
plt.scatter(index,df['final_Mw'])

plt.scatter(x=df['event_id'],y=df['final_Mw'],c=df['GCMT_Dip1'], cmap='viridis')
plt.xlabel('event_id')
plt.ylabel('Mw')
plt.title('total events GCMT solve')
plt.savefig('GCMT distribution.png',dpi=300)
plt.show()