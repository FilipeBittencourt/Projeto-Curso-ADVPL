#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
##############################################################################################################
# PROGRAMA...: MT080GRV         
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 22/10/2013                      
# DESCRICAO..: Ponto de Entrada No Cadastro de TES para que ao bloquear um Cadastro, informa qual que irá 
# 				 Substitui-la, para atualizar o cadastro de Produtos.
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/

User Function MT080GRV()

Local lRet := .F.
Local oCheckBo1
Local lCheckBo1 := .F.
Local oGet1
Local cGet1 := Space(3)
Local oSay1
Local oSay2
Local oSay3
Local oSButton1
Local oSButton2
Static oDlg   

PRIVATE ENTER := CHR(13)+CHR(10)


If(SF4->F4_MSBLQL == '1')	//BLOQUEADO? 

	While !lRet

	  DEFINE MSDIALOG oDlg TITLE "Informe TES" FROM 000, 000  TO 200, 370 COLORS 0, 16777215 PIXEL
	
	    @ 016, 014 SAY oSay1 PROMPT "Informe TES que Substituira" SIZE 075, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 014, 105 MSGET oGet1 VAR cGet1 SIZE 060, 010 OF oDlg COLORS 0, 16777215 F3 "SF4" PIXEL
	    @ 039, 016 SAY oSay2 PROMPT "Sera Atualizado o Cadastro de Produtos, substituindo" SIZE 135, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 047, 016 SAY oSay3 PROMPT "os valores que da TES bloqueada pelo valor informado acima!" SIZE 152, 007 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 066, 014 CHECKBOX oCheckBo1 VAR lCheckBo1 PROMPT "Nao Utilizara nova TES" SIZE 077, 008 OF oDlg COLORS 0, 16777215 PIXEL    
	    //DEFINE SBUTTON oSButton1 FROM 082, 042 TYPE 01 OF oDlg ENABLE ACTION {||lRet:= Validar(cGet1,lCheckBo1), IIF(lRet,AtualizaProd(cGet1),oDlg:End()),oDlg:End()}
	    DEFINE SBUTTON oSButton1 FROM 082, 042 TYPE 01 OF oDlg ENABLE ACTION {||lRet := Valida(cGet1,lCheckBo1),oDlg:End()}
	    DEFINE SBUTTON oSButton2 FROM 082, 101 TYPE 02 OF oDlg ENABLE ACTION {||oDlg:End(), lRet := .F.}
	
	  ACTIVATE MSDIALOG oDlg CENTERED
	
	EndDo	
EndIf

	
Return    

                    
/*
##############################################################################################################
# PROGRAMA...: Valida         
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 22/10/2013                      
# DESCRICAO..: Validacoes
##############################################################################################################
*/
Static Function Valida(cNewTes,lCheckBo1)

Local lRet := .T. 
Local lContinua := .T.  
Local cOldTes := SF4->F4_CODIGO  
Local aArea := GetArea()

If Empty(cNewTes) .And. !lCheckBo1
     MsgInfo("TES Devera ser Informada!")
     lRet := .F.
     lContinua := .F.
EndIf     
If lContinua .And. !lCheckBo1
	If (Alltrim(cNewTes) == Alltrim(SF4->F4_CODIGO))
	     MsgInfo("TES De Substituicao nao Pode ser Igual a TES Antiga!")
	     lRet := .F.
	     lContinua := .F.
	EndIf    
EndIf
If lContinua .And. !lCheckBo1
	If (SF4->F4_TIPO == "E") .And. Val(cNewTes) >500//ENTRADA
		MsgInfo("TES De Entrada Deve ser Menor que 500!")     
		lRet := .F.
		lContinua := .F.
	EndIf
EndIf
If lContinua .And. !lCheckBo1
	If (SF4->F4_TIPO == "S") .And. Val(cNewTes) <=500//SAIDA
		MsgInfo("TES De Saida Deve ser Maior que 500!")
		lRet := .F.
		lContinua := .F.
	EndIf
EndIf

If lContinua .And. !lCheckBo1
	DbSelectArea("SF4")
	DbSetOrder(1)
	If!(DbSeek(xFilial("SE4")+cNewTes))
		MsgInfo("TES Informada Nao Existe!")
	EndIf
Endif

If lRet .And. !Empty(cNewTes) .And. !lCheckBo1
	AtualizaProd(cNewTes,cOldTes)
EndIf

RestArea(aArea)

RETURN lRet    


/*
##############################################################################################################
# PROGRAMA...: AtualizaProd         
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 22/10/2013                      
# DESCRICAO..: Atualizacao do SB1
##############################################################################################################
*/
Static Function AtualizaProd(cNewTes,cOldTes) 

Local cCampo := ""
Local cUpdate := ""

If (SF4->F4_TIPO == "E") //ENTRADA
  cCampo := "B1_TE"
Else
  cCampo := "B1_TS"    //SAIDA
EndIf 
      
cUpdate += "UPDATE SB1010 SB1 SET "+cCampo+" =  '"+cNewTes+"' WHERE " +ENTER
cUpdate += cCampo+ " =  '"+cOldTes+"' AND SB1.D_E_L_E_T_= '' "    

TCSQLExec(cUpdate)  

Return