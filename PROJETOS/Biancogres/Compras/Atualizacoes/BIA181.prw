#include "protheus.ch"

/*
##############################################################################################################
# PROGRAMA...: BIA181
# AUTOR......: Rubens Junior (FACILE)
# DATA.......: 17/09/2013                      
# DESCRICAO..: Rotina para Solicitar Senha no Ponto de Entrada MT120GRV quando o campo B1_YTPCOT nao atender
#  				aos requisitos
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
#
##############################################################################################################
*/
User Function BIA181()                        

Local oBitmap1
Local oGet1
Local cUser := Space(30)
Local oGet2
Local cPasswd := Space(20)
Local oSay1
Local oSay2
Local oSButton1
Local oSButton2
Local lRet := .F. 

Static aUsers := {}
Static oDlg 

//VALIDA CONFIGURACAO DO PARAMETRO DE LOGINS
If(Empty(GetMv( "MV_YUSPEDC")))
	MsgInfo("Configure Parametro MV_YUSPEDC para Continuar.")
	lRet := .F.
	Return lRet
EndIf
	
If ('/' $ GetMv( "MV_YUSPEDC") )                                     
	aUsers := StrTokArr(GetMv( "MV_YUSPEDC"),"/")    
Else
	aUsers := StrTokArr(GetMv( "MV_YUSPEDC")," ")
EndIf

DEFINE MSDIALOG oDlg TITLE "Autorização Para Gerar Pedido de Compra" FROM 000, 000  TO 180, 400 COLORS 0, 16777215 PIXEL

    @ 010, 010 SAY oSay1 PROMPT "Usuário" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 021, 009 MSGET oGet1 VAR cUser SIZE 106, 010 OF oDlg COLORS 0, 16777215 PIXEL

    @ 039, 010 SAY oSay2 PROMPT "Senha" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL  
    @ 050, 009 MSGET oGet2 VAR cPasswd SIZE 106, 010 OF oDlg COLORS 0, 16777215 PASSWORD PIXEL

    DEFINE SBUTTON oSButton1 FROM 070, 051 TYPE 01 OF oDlg ENABLE ACTION {||lRet:=ValidUser(cUser,cPasswd),oDlg:End()}
    DEFINE SBUTTON oSButton2 FROM 070, 088 TYPE 02 OF oDlg ENABLE ACTION {||lRet:= .F., Odlg:End()}    
//    @ 005, 138 BITMAP oBitmap1 SIZE 046, 044 OF oDlg FILENAME "\system\totvs.jpg" NOBORDER PIXEL
    @ 030, 120 BITMAP oBitmap1 SIZE 080, 075 OF oDlg FILENAME "\sigaadv\lgrl"+cEmpAnt+cFilAnt+".bmp" NOBORDER PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return lRet



//****************************************************************************************************************************
//EFETUAR AS VALIDACOES																										 *
//****************************************************************************************************************************   
Static Function ValidUser(cName,cPasswd)
      
Local lRet := .F. 
Local cUserId
Local nI

//VALIDAR SE USUARIO ESTA NO PARAMETRO DE APROVADORES   
//PASSAR LOGIN E RETORNAR ID
cUserId := GetId(cName) 

//PERCORRER ARRAY
For nI := 1 to Len(aUsers)
	If(aUsers[nI] == cUserId)
       lRet := .T.
       exit
    EndIf
Next nI    

//VALIDAR SENHA DO USUARIO
If lRet
	If !(ValidPasswd(cUserId, cPasswd))      
		MsgInfo("Usuario ou Senha Invalidos!")  
		lRet := .F. 
	EndIf
Else
	MsgInfo("Usuario nao Esta no Parametro de Aprovadores!")  	
EndIf

Return lRet     

//****************************************************************************************************************************
//RETORNAR ID DO USUARIO				                                                                                     *
//****************************************************************************************************************************   
Static Function GetId(cName)	 

Local cUserId
	
Begin Sequence

	PswOrder(2)
	IF !( PswSeek( cName ) )
		Break
	EndIF
	
	cUserId := PswRet(1)[1][1]

End Sequence

Return( cUserId )       


//****************************************************************************************************************************
//VALIDAR SE USUARIO/SENHA ESTAO VALIDOS                                                                                     *
//****************************************************************************************************************************   
Static Function ValidPasswd(cId, cPasswd)

Local lRet := .F.

PswOrder(1)

If ( PswSeek(cId, .T.) )
	If PswName(cPasswd)
		lRet := .T.
	EndIf
EndIf

Return(lRet)   