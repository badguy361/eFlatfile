# install step
1. R 4.1.3(32bit)
2. RStudio
3. 
```
install.packages("Cairo")  
install.packages("RSEIS")
install.packages("digest")
```
4. install.packages(c('Rcpp', 'pracma'))
5. install.packages("devtools")
The package will be installed in C:\Users\user\Documents\R\win-library\4.1 if you don't assign.
6. 
```
library(devtools)
install_github('wltcwpf/RCTC')
```


> https://github.com/wltcwpf/RCTC