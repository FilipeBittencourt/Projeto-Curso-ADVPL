#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia001()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�
//� Declaracao de variaveis utilizadas no programa atraves da funcao    �
//� SetPrvt, que criara somente as variaveis definidas pelo usuario,    �
//� identificando as variaveis publicas do sistema utilizadas no codigo �
//� Incluido pelo assistente de conversao do AP5 IDE                    �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�

SetPrvt("WALIAS,LRET,_CLASSE,")

/*/
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
굇旼컴컴컴컴컫컴컴컴컴컴컴쩡컴컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컫컴컴컴컴컴엽�
굇쿑un뇚o    � BIA001     � Autor � MICROSIGA VITORIA     � Data � 02/09/99 낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴좔컴컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컨컴컴컴컴컴눙�
굇쿏escri뇙o � Determina a Classe da Natureza                               낢�
굇쳐컴컴컴컴컵컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴눙�
굇� Uso      � Interpretador x Base                                         낢�
굇읕컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴袂�
굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇굇�
賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽賽�
/*/
	
	wAlias := Alias()
	lRet := .f.

	// Chamada via RPC n�o tem as variaveis de memoria
	If FunName() == "RPC"
		
		// DDefault para pedidos com RA e contratos
		_Classe := "1121"
		
		lRet := .T.
	
	// Consulta saldo financeiro
	ElseIf IsInCallStack("U_BIAF110") .Or. IsInCallStack("U_BIAF120") .Or. IsInCallStack("U_BIAF017")
		
		lRet := .T.
		
	Else

		Do Case
		   Case UPPER(ALLTRIM(FUNNAME())) == "MATA020"
		        _Classe := M->A2_NATUREZ
		   Case UPPER(ALLTRIM(FUNNAME())) == "MATA030"
		        _Classe := M->A1_NATUREZ
		   Case UPPER(ALLTRIM(FUNNAME())) == "BIA863"
		        _Classe := M->A1_NATUREZ
		   Case UPPER(ALLTRIM(FUNNAME())) == "RPC"
		        _Classe := M->A1_NATUREZ
		   Case UPPER(ALLTRIM(FUNNAME())) $ "FINA040_FINA740_FINA280_MATA410_BIA318_FROPTE05_CFGX019_FINA200_FINA460"
		        _Classe := M->E1_NATUREZ
		   Case UPPER(ALLTRIM(FUNNAME())) $ "FINA050_FINA750"
		        _Classe := M->E2_NATUREZ
		   Case UPPER(ALLTRIM(FUNNAME())) == "FINA100"
		        _Classe := M->E5_NATUREZ
		EndCase
		
		dbSelectArea("SED")
		dbSetOrder(1)
		DbSeek(xFilial("SED")+_Classe)
		If SED->ED_YCLASSE <> "A"
		   MsgBox("Atencao, a NATUREZA tem que ser ANALITICA","Atencao","INFO")
		Else
		   lRet := .T.
		EndIf
		
	EndIf
	
Return(lRet)