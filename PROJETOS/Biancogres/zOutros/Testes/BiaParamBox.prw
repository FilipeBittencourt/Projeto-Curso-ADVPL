#include "totvs.ch"
#include "parmtype.ch"

class BiaParamBox
  static method DialogCoords(nRow,nCol,nRight,nBottom)
  static method ParamBox(aParametros,cTitle,aRet,bOk,aButtons,lCentered,nPosx,nPosy,oDlgWizard,cLoad,lCanSave,lUserSave)
end class

static method DialogCoords(nRow,nCol,nRight,nBottom) class BiaParamBox

paramtype nRow    as numeric default 0
paramtype nCol    as numeric default 0
paramtype nRight  as numeric default 600
paramtype nBottom as numeric default 300

cacheData():Set("BiaParamBox","nRow",nRow)
cacheData():Set("BiaParamBox","nCol",nCol)
cacheData():Set("BiaParamBox","nRight",nRight)
cacheData():Set("BiaParamBox","nBottom",nBottom)

return(nil)

static method ParamBox(aParametros,cTitle,aRet,bOk,aButtons,lCentered,nPosx,nPosy,oDlgWizard,cLoad,lCanSave,lUserSave) class BiaParamBox

local lOK     as logical

local nRow    as numeric
local nCol    as numeric
local nRight  as numeric
local nBottom as numeric
Local oPanelB
DEFAULT bOk			:= {|| (.T.)}
DEFAULT aButtons	:= {}
DEFAULT lCentered	:= .T.
DEFAULT nPosX		:= 0
DEFAULT nPosY		:= 0
DEFAULT cLoad     := ProcName(1)
DEFAULT lCanSave	:= .T.
DEFAULT lUserSave	:= .F.
DEFAULT aButtons	:= {}

lOK:=.F.

if (valtype(oDlgWizard)!="O")
  if (type("cCadastro")!="C")
    private cCadastro:="ParamBox"
  endif

  nRow:=cacheData():Get("BiaParamBox","nRow",0)
  nCol:=cacheData():Get("BiaParamBox","nCol",0)
  nRight:=cacheData():Get("BiaParamBox","nRight",600)
  nBottom:=cacheData():Get("BiaParamBox","nBottom",300)

  DEFINE MSDIALOG oDlgWizard TITLE cCadastro+" - "+cTitle FROM nRow,nCol TO nBottom,nRight PIXEL
  DEFINE SBUTTON FROM 4,157 TYPE 1 ENABLE OF oPanelB ACTION (If(ParamOk(aParametros,@aRet).And.Eval(bOk),(oDlgWizard:End(),lOk:=.T.),(lOk:=.F.)))
  DEFINE SBUTTON FROM 4,190 TYPE 2 ENABLE OF oPanelB ACTION (lOk:=.F.,oDlgWizard:End())
endif

ParamBox(@aParametros,@cTitle,@aRet,@bOk,@aButtons,@lCentered,@nPosx,@nPosy,@oDlgWizard,@cLoad,@lCanSave,@lUserSave)

ACTIVATE MSDIALOG oDlgWizard CENTERED

if ((lOk).and.(lUserSave))
  ParamSave(cLoad,aParametros,"1")
endif

return(lOk)
