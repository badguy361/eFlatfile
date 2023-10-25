### Set Work directory
  setwd('C:/Users/user/Desktop/meinon/')
### Set config parameters
#  source("SGM_Process/Function_config.r")
###
### LOAD Library
###
  library(RMySQL)
  library(foreign)
  library(digest)
###
### LOAD Functions
###
	source("SGM_Process/Function_Integrate2VD.r")    #積�?�函?��
  source("SGM_Process/Function_Integrate_Ia.r")    #Ia積�?�函?��
	source("SGM_Process/Function_spectraw3.r")       #計�?��?��?��??
	source("SGM_Process/Function_Baseline.r")        #?��線校�?
	source("SGM_Process/Function_Butterworth.r")     #Butterworth濾波?��?��
	source("SGM_Process/Function_write_DB.r")        #寫入資�?�庫
	source("SGM_Process/Function_write_File.r")      #寫到檔�??
#	source("SGM_Process/Function_tcltk_mesgbox.r")   #?��??��?��?��?�質視�??
	source("SGM_Process/Function_Process.r")         #主�?��??
	
###
#  source("SGM_Process/Function_plot_processed_SGM.r")    #對於??��?��?��?��?��?��?�繪???(從�?��?�庫)
  