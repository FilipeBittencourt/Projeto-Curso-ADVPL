#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

User Function Bia001()        // incluido pelo assistente de conversao do AP5 IDE em 29/01/01

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetPrvt("WALIAS,LRET,_CLASSE,")

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BIA001     ³ Autor ³ MICROSIGA VITORIA     ³ Data ³ 02/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Determina a Classe da Natureza                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Interpretador x Base                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
	
	wAlias := Alias()
	lRet := .f.

	// Chamada via RPC não tem as variaveis de memoria
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