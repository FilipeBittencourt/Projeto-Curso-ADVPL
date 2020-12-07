#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FERVEN         ºAutor  ³ BRUNO MADALENO     º Data ³  16/01/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATORIO EM CRYSTAL PARA GERAR AS QUANTIDADES DE TICKE E VALE   º±±
±±º          ³TRANSPORTE 														º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function COM_V_T()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cSQL
	Private Enter := CHR(13)+CHR(10) 
	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Comprovante de recebimento de vale e tick"
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "COM_V_T"
	cPerg      := ""
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Comprovante de recebimento de vale e tick"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "COM_V_T"
	lprim      := .t.
	li         := 80
	nTipo      := 0
	wFlag      := .t. 


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria parametros se nao existir e chama os parametros na tela           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ValidPerg()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT.								     ³
	//³ Verifica Posicao do Formulario na Impressora.				             ³
	//³ Solicita os parametros para a emissao do relatorio			             |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	pergunte(cPerg,.F.)
	wnrel := SetPrint(cString,cNomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,    ,.T.,cTamanho,,.F.)
	//Cancela a impressao
	If nLastKey == 27
		Return
	Endif

	//cSQL := ""
	//cSQL += "ALTER VIEW VW_RECEB_VALE_TICK AS  " + Enter
	//cSQL += "SELECT 	RA_YEQUIPE, RA_CC, RA_APELIDO, RA_MAT, RA_NOME,  RA_VALEREF, SPF.PF_TURNOPA AS RA_TNOTRAB,  " + Enter
	//cSQL += "			ISNULL(R0_QDIACAL,0) AS VALE,   " + Enter
	//cSQL += "			 " + Enter
	//cSQL += "			TICK = CASE WHEN SPF.PF_TURNOPA = '047' THEN (R6_DIAVTRA/2) " + Enter
	//cSQL += "					ELSE (R6_DIAVTRA) END " + Enter
	//cSQL += " " + Enter
	//cSQL += "FROM " + RetSqlName("SRA") + " SRA, " + RetSqlName("SR0") + " SR0, " + RetSqlName("SR6") + " SR6 " + Enter
	//cSQL += " " + Enter
	//cSQL += ",(SELECT SPF.*  " + Enter
	//cSQL += "FROM " + RetSqlName("SPF") + " SPF,  " + Enter
	//cSQL += "				(SELECT MAX(R_E_C_N_O_) AS RECNO, PF_MAT FROM " + RetSqlName("SPF") + "  WHERE D_E_L_E_T_ = '' GROUP BY PF_MAT) AS AUX  " + Enter
	//cSQL += "WHERE	SPF.R_E_C_N_O_ = AUX.RECNO AND " + Enter
	//cSQL += "		SPF.D_E_L_E_T_ = '') AS SPF " + Enter
	//cSQL += " " + Enter
	//cSQL += "WHERE 		SR0.R0_MAT =* SRA.RA_MAT  AND  " + Enter
	//cSQL += "			SR6.R6_TURNO = SPF.PF_TURNOPA AND  " + Enter
	//cSQL += "			SPF.PF_MAT = SRA.RA_MAT AND   " + Enter
	//cSQL += "			SUBSTRING(SRA.RA_MAT,1,1) <> '2' AND " + Enter
	//cSQL += "			SRA.RA_SITFOLH <> 'D'	AND  " + Enter
	//cSQL += "			SR0.D_E_L_E_T_ = '' AND  " + Enter
	//cSQL += "			SRA.D_E_L_E_T_ = ''  AND  " + Enter
	//cSQL += "			SR6.D_E_L_E_T_ = ''   " + Enter
	//cSQL += " " + Enter


	//ATUALIZAÇÃO QUERY - SQL ATUAL - 18/01/2016
	cSQL := ""
	cSQL += "ALTER VIEW VW_RECEB_VALE_TICK AS  " + Enter
	cSQL += "SELECT 	RA_YEQUIPE, RA_CC, RA_APELIDO, RA_MAT, RA_NOME,  RA_VALEREF, SPF.PF_TURNOPA AS RA_TNOTRAB,  " + Enter
	cSQL += "			ISNULL(R0_QDIACAL,0) AS VALE,   " + Enter
	cSQL += "			 " + Enter
	cSQL += "			TICK = CASE WHEN SPF.PF_TURNOPA = '047' THEN (R6_DIAVTRA/2) " + Enter
	cSQL += "					ELSE (R6_DIAVTRA) END " + Enter
	cSQL += " " + Enter
	cSQL += "FROM " + RetSqlName("SRA") + " SRA " + Enter
	cSQL += "	LEFT JOIN " + RetSqlName("SR0") + " SR0 " + Enter
	cSQL += "		ON SRA.RA_MAT = SR0.R0_MAT " + Enter
	cSQL += "			AND SR0.D_E_L_E_T_ = '' " + Enter
	cSQL += "	INNER JOIN (SELECT SPF.* " + Enter
	cSQL += "				FROM " + RetSqlName("SPF") + " SPF, (SELECT MAX(R_E_C_N_O_) AS RECNO, PF_MAT FROM " + RetSqlName("SPF") + "  WHERE D_E_L_E_T_ = '' GROUP BY PF_MAT) AS AUX " + Enter
	cSQL += "				WHERE	SPF.R_E_C_N_O_ = AUX.RECNO AND " + Enter
	cSQL += "						SPF.D_E_L_E_T_ = '') AS SPF " + Enter
	cSQL += "		ON SPF.PF_MAT = SRA.RA_MAT " + Enter
	cSQL += "	INNER JOIN " + RetSqlName("SR6") + " SR6 " + Enter
	cSQL += "		ON SR6.R6_TURNO = SPF.PF_TURNOPA " + Enter
	cSQL += "			AND SR6.D_E_L_E_T_ = '' " + Enter
	cSQL += "WHERE SUBSTRING(SRA.RA_MAT,1,1) <> '2' AND " + Enter
	cSQL += "	SRA.RA_SITFOLH <> 'D'	AND " + Enter
	cSQL += "	SRA.D_E_L_E_T_ = '' " + Enter
	cSQL += " " + Enter



	//cSQL += "ORDER BY RA_NOME " + Enter
	TcSQLExec(cSQL)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5]==1
		//Parametros Crystal Em Disco
		Private cOpcao:="1;0;1;Apuracao"
	Else
		//Direto Impressora
		Private cOpcao:="3;0;1;Apuracao"
	Endif
	//AtivaRel()
	callcrys("COM_V_T",cEmpant,cOpcao)
Return


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ValidPerg    ³ Autor ³ MAGNAGO                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas no SX1                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
	Local _i, _j
	Private _aPerguntas := {}

	AAdd(_aPerguntas,{cPerg,"01","Data de Referencia ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	DbSelectArea("SX1")
	For _i:= 1 to Len(_aPerguntas)
		If !DbSeek( cPerg + StrZero(_i,2) )
			RecLock("SX1",.T.)
			For _j:= 1 to FCount()
				FieldPut(_j,_aPerguntas[_i,_j])
			Next _j
			MsUnLock()
		Endif
	Next _i
Return