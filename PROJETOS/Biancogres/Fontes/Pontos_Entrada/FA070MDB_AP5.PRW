#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function fa070mdb()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("WFLAG,WRESP,WCUSER,WCSENHA,WCNOVSENHA,GET_SENHA,CMOTBX")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � fa070mdb   � Autor � CESAR MAGNAGO         � Data � 20/12/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � So permite baixa por DACAO com autorizacao de Senha          낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Interpretador x Base                                         낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
wFlag := .T.
wResp := .F.
//IF UPPER(ALLTRIM(FUNNAME())) == "FINA460"
//CMOTBX := ""
//END IF

//IF UPPER(ALLTRIM(FUNNAME())) <> "FINA460"
	If SUBST(CMOTBX,1,5) == "DACAO" .And. !IsBlind()
	   MsgAlert("Favor pedir autorizacao a Gerencia Financeira")
	   wcUser  := Upper(AllTrim(cUserName))
	   wcSenha := Alltrim( GetMv("MV_SENHA") )

	   While wFlag
	
	      @ 096,042 To 323,505 Dialog woDlg Title "Autorizacao p/Baixa por DACAO"
	      @ 008,010 To 084,222
	
	      wcNovSenha := Space(10)
	
	      @ 023,014 Say "Digite Senha autorizada : "
	      @ 023,080 Get wcNovSenha PICTURE "@!" PASSWORD Object oGet
	
	      @ 055,020 BMPBUTTON TYPE 01 ACTION fSubmit()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 055,020 BMPBUTTON TYPE 01 ACTION Execute(fSubmit)
	      @ 055,060 BMPBUTTON TYPE 02 ACTION fAborta()// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==>       @ 055,060 BMPBUTTON TYPE 02 ACTION Execute(fAborta)
	
	      ACTIVATE DIALOG woDlg CENTERED
	
	   EndDo
	Else
	   wResp := .T.
	
	EndIf
//END IF
// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> __Return(wResp)
Return(wResp)        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fSubmit
Static Function fSubmit()
If Alltrim(wcSenha) == ALLTRIM(wcNovSenha)
   wFlag := .F.
   wResp := .T.
   Close(woDlg)
Else
   Get_Senha := IIf(!Empty(wcNovSenha),Space(10),Space(10))
   dlgRefresh(woDlg)
   ObjectMethod(oGet,"SetFocus(wcNovSenha)")
   ObjectMethod(oGet,"Refresh()")
   Help(1,"","Y_BIA045")
Endif
Return

// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> Function fAborta
Static Function fAborta()
  wFlag := .T.
  Close(woDlg)
Return
