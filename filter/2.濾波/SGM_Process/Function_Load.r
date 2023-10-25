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
	source("SGM_Process/Function_Integrate2VD.r")    #ç©å?†å‡½?•¸
  source("SGM_Process/Function_Integrate_Ia.r")    #Iaç©å?†å‡½?•¸
	source("SGM_Process/Function_spectraw3.r")       #è¨ˆç?—å?æ?‰è??
	source("SGM_Process/Function_Baseline.r")        #?Ÿºç·šæ ¡æ­?
	source("SGM_Process/Function_Butterworth.r")     #Butterworthæ¿¾æ³¢?‡½?•¸
	source("SGM_Process/Function_write_DB.r")        #å¯«å…¥è³‡æ?™åº«
	source("SGM_Process/Function_write_File.r")      #å¯«åˆ°æª”æ??
#	source("SGM_Process/Function_tcltk_mesgbox.r")   #?¸??–è?‡æ?™å?è³ªè¦–ç??
	source("SGM_Process/Function_Process.r")         #ä¸»ç?‹å??
	
###
#  source("SGM_Process/Function_plot_processed_SGM.r")    #å°æ–¼??•ç?†å?Œæ?ç?„è?‡æ?™ç¹ª???(å¾è?‡æ?™åº«)
  