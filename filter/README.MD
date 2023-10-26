# install step
1. R 4.1.3(32bit)
2. RStudio
3. Install packages
```
install.packages("Cairo")  
install.packages("RSEIS")
install.packages("digest")
install.packages(c('Rcpp', 'pracma'))
install.packages("devtools")
```
The packages will be installed in C:\Users\user\Documents\R\win-library\4.1 if you don't assign.

4. Install RCTC 
```
library(devtools)
install_github('wltcwpf/RCTC')
```


>　Reference : https://github.com/wltcwpf/RCTC