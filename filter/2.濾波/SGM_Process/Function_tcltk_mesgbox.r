require(tcltk)
setqc <- function(){
  tt <- tktoplevel()
  tkwm.title(tt,"Set Data Quality")
  rb1 <- tkradiobutton(tt)
  rb2 <- tkradiobutton(tt)
  rb3 <- tkradiobutton(tt)
  rb4 <- tkradiobutton(tt)
  rb5 <- tkradiobutton(tt)
  rbValue <- tclVar("B")
  tkconfigure(rb1,variable=rbValue,value="A")
  tkconfigure(rb2,variable=rbValue,value="B")
  tkconfigure(rb3,variable=rbValue,value="C")
  tkconfigure(rb4,variable=rbValue,value="D")
  tkconfigure(rb5,variable=rbValue,value="E")
  tkgrid(tklabel(tt,text="Please chose quality of the data"))
  tkgrid(tklabel(tt,text="Good"),rb1)
  tkgrid(tklabel(tt,text="OK"),rb2)
  tkgrid(tklabel(tt,text="Poor"),rb3)
  tkgrid(tklabel(tt,text="Bad"),rb4)
  tkgrid(tklabel(tt,text="Terrible"),rb5)
  OnOK <- function()
  {
      rbVal <- as.character(tclvalue(rbValue))
      qc <- as.character(tclvalue(rbValue))
      tkdestroy(tt)
      if (rbVal=="A")
      	tkmessageBox(message="Thanks!  That's great!")
      if (rbVal=="B")
      	tkmessageBox(message="Thanks!  This data will help us.")
      if (rbVal=="C")
      	tkmessageBox(message="Thanks!  Maybe we can use this data.")
      if (rbVal=="D")
      	tkmessageBox(message="Thanks!  We can't use this data.")
      if (rbVal=="E")
      	tkmessageBox(message="Thanks!  That's a bad news, how could this be ?")
  }
  OK.but <- tkbutton(tt,text="OK",command=OnOK)
  tkgrid(OK.but)
  tkfocus(tt)
}