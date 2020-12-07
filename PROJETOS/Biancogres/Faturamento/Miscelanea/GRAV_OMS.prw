#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOPCONN.CH'
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GRAV_OMS         ³ MADALENO           º Data ³  23/12/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ GRAVA TABELA DA7											  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 8 - R4                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION GRAV_OMS() 

//Se a rotina for chamada atraves do cadastro de cliente
If Alltrim(funname())=="MATA030" .OR. Alltrim(funname())=="RPC" .OR. Alltrim(funname())=="BIA863" .Or. Alltrim(funname()) == "WFPREPENV" .Or. isBlind()
	RunProc()
Else

	@ 96,42 TO 323,505 DIALOG oDlg5 TITLE "Grava Tabela Pontos por Setor - DA7"
	@ 8,10 TO 84,222
	
	@ 16,12 SAY "Esta rotina tem por finalidade: "
	@ 24,12 SAY "Gravar a tabela DA7 - Pontos por Setor, de acordo com a tabela DA6 - Setores por Zona"
	
	@ 91,166 BMPBUTTON TYPE 1 ACTION OkProc()
	@ 91,195 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
	
	ACTIVATE DIALOG oDlg5 CENTERED
EndIf

RETURN()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Chama rotina que acerta o empenho       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function OkProc()
	Processa( {|| RunProc() } )
	Close(oDlg5)
Return


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Rotina que realiza o acerto do Empenho  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function RunProc()
PRIVATE CSQL 	:= ""
PRIVATE ENTER	:= CHR(13)+CHR(10)

//ATUALIZAÇÃO QUERY - SQL ATUAL - 14/10/2015
CSQL := "SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_COD_MUN, SA1.A1_MUN, SA1.A1_EST, ISNULL(DA6.DA6_PERCUR,'') DA6_PERCUR, ISNULL(DA6.DA6_ROTA,'') DA6_ROTA, " + ENTER
CSQL += "	   REPLICATE('0', 6 - DATALENGTH( LTRIM(ROW_NUMBER() OVER (PARTITION BY DA6.DA6_PERCUR ORDER BY DA6.DA6_PERCUR, DA6.DA6_ROTA)) ) ) + " + ENTER
CSQL += "	   LTRIM(ROW_NUMBER() OVER (PARTITION BY DA6.DA6_PERCUR ORDER BY DA6.DA6_PERCUR, DA6.DA6_ROTA)) AS SEQUENCIA " + ENTER
If cEmpAnt == "01"
	CSQL += "FROM SA1050 SA1 " + ENTER
ElseIf cEmpAnt == "05"
	CSQL += "FROM SA1010 SA1 " + ENTER
ElseIf cEmpAnt == "07"
	CSQL += "FROM SA1010 SA1 " + ENTER
ElseIf cEmpAnt == "13"
	CSQL += "FROM SA1010 SA1 " + ENTER
Else
	CSQL += "FROM SA1010 SA1 " + ENTER
EndIf
CSQL += "	LEFT JOIN DA6010 DA6 " + ENTER
CSQL += "		ON SA1.A1_COD_MUN = DA6.DA6_ROTA " + ENTER
CSQL += "			AND SA1.A1_EST = DA6.DA6_YEST " + ENTER
CSQL += "			AND DA6.D_E_L_E_T_ = '' " + ENTER
CSQL += "WHERE " + ENTER
If Alltrim(funname())=="MATA030"
	CSQL += "				SA1.A1_COD = '"+M->A1_COD+"' AND SA1.A1_LOJA = '"+M->A1_LOJA+"' AND" + ENTER
EndIf				 	
CSQL += "				SA1.A1_COD_MUN 	<> '' " + ENTER
CSQL += "				AND SA1.D_E_L_E_T_ 	= '' " + ENTER
CSQL += "				AND	A1_COD+RTRIM(LTRIM(A1_LOJA))+A1_EST NOT IN (SELECT DA7_CLIENT+RTRIM(LTRIM(DA7_LOJA))+DA7_YEST FROM DA7010 WHERE D_E_L_E_T_ = '') " + ENTER
IF CHKFILE("_TRAB")
	DBSELECTAREA("_TRAB")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TRAB" NEW

DBSELECTAREA("DA7")		
WHILE ! _TRAB->(EOF()) 

	cAliasTmp := GetNextAlias()
	BeginSql Alias cAliasTmp
		SELECT MAX(DA7_SEQUEN) SEQUEN
		FROM  %Table:DA7%
		WHERE DA7_PERCUR = %Exp:(_TRAB->DA6_PERCUR)% AND %NOTDEL%
	EndSql

	If ALLTRIM(_TRAB->DA6_PERCUR) <> ""
		RecLock("DA7",.T.)
		Replace DA7_FILIAL  With xFilial("DA7")
		Replace DA7_PERCUR  With ALLTRIM(_TRAB->DA6_PERCUR)
		Replace DA7_ROTA  	With ALLTRIM(_TRAB->DA6_ROTA)
		Replace DA7_SEQUEN  With Soma1((cAliasTmp)->SEQUEN)
		Replace DA7_CLIENT  With ALLTRIM(_TRAB->A1_COD)
		Replace DA7_LOJA  	With ALLTRIM(_TRAB->A1_LOJA)   
		Replace DA7_YEST  	With ALLTRIM(_TRAB->A1_EST)   	
		MsUnLock()
	Else
		If !isBlind()
			MsgAlert("Código do Municipio não está cadastrado na tabela Setores por Zona - DA6 :"+_TRAB->A1_COD_MUN)
		EndIf
	EndIf
	_TRAB->(DBSKIP())
	
	(cAliasTmp)->(dbCloseArea())
	
END

RETURN