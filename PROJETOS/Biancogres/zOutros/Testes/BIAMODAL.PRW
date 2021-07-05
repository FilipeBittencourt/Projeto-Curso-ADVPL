#Include 'Protheus.ch'

User Function BIAMODAL()

  Local oReport

  local cLoad	    := "BFATRE04"
  local lRet		:= .F.
  Local aPergs	:=	{}
  Local oDlgWizard := Nil
  //lOCAL  oMainWnd     := MsDialog():New()


  aAdd(aPergs,{3,"Mostra deletados",1,{"Sim","Não"},50,"",.F.})

  If ParamBox(aPergs ,"Filtros",/*aRet*/,/*bOk*/,/*aButtons*/,/*lCentered*/,900/*nPosx*/,500/*nPosy*/,NIL,cLoad,.T.,.T.) //PMSXFUN.PRX - LINHA 14412
    //ParamBox(aParamBox, cTitulo, aRet, bOk, aButtons, lCentered, nPosx,nPosy, /*oMainDlg*/ , cLoad, lCanSave, lUserSave)
    lRet := .T.
  EndIf

Return