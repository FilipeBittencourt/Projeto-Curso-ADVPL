#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CLIINA         ºAutor  ³ HARLEY DIAS KOEHLERº Data ³  08/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELACAO DE CLIENTES INATIVOS                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CLIINA()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cSQL
	Private Enter := CHR(13)+CHR(10) 
	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Envio de Fax ao Banco"
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "CLIINA"
	cPerg      := "CLIINA"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Folha de Rosto para Fax                  "
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "CLIINA"
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

	cSQL := ""
	cSQL += "ALTER VIEW VW_CLIINAT AS  " + Enter
	cSQL += "SELECT A3_COD, A3_NOME, A1_COD, A1_NOME, A1_MUN, A1_TEL, " + Enter
	cSQL += "CONVERT(VARCHAR(10),CONVERT(DATETIME,A1_ULTCOM),103) AS ANO, DATEDIFF(day,A1_ULTCOM, GETDATE()) AS DIAS  " + Enter
	cSQL += "FROM " + RetSqlName("SA1") + " SA1," + RetSqlName("SA3") + " SA3"+ Enter
	cSQL += "WHERE SA1.D_E_L_E_T_ = '' AND SA3.D_E_L_E_T_ = '' AND" + Enter
	If MV_PAR05 == 1 		//Biancogres
		cSQL += "	  (A1_VEND		= A3_COD OR 
		cSQL += "	   A1_YVENDB2	= A3_COD OR
		cSQL += "	   A1_YVENDB3	= A3_COD	) AND 
	ElseIf MV_PAR05 == 2	//Incesa
		cSQL += "	  (A1_YVENDI	= A3_COD OR 
		cSQL += "	   A1_YVENDI2	= A3_COD OR
		cSQL += "	   A1_YVENDI3	= A3_COD 	) AND 
	ElseIf MV_PAR05 == 3	//Bellacasa
		cSQL += "	  (A1_YVENBE1	= A3_COD OR 
		cSQL += "	   A1_YVENBE2	= A3_COD OR
		cSQL += "	   A1_YVENBE3	= A3_COD 	) AND 
	ElseIf MV_PAR05 == 4	//Vitcer
		cSQL += "	  (A1_YVENVT1	= A3_COD OR 
		cSQL += "	   A1_YVENVT2	= A3_COD OR
		cSQL += "	   A1_YVENVT3	= A3_COD 	) AND 
	ElseIf MV_PAR05 == 5	//Mundialli
		cSQL += "	  (A1_YVENML1	= A3_COD OR 
		cSQL += "	   A1_YVENML2	= A3_COD OR
		cSQL += "	   A1_YVENML3	= A3_COD 	) AND 
	ElseIf MV_PAR05 == 6	//Pegasus
		cSQL += "	  (A1_YVENPEG	= A3_COD ) AND 
	ElseIf MV_PAR05 == 7	//Vinilico
		cSQL += "	  (A1_YVENVI1	= A3_COD ) AND 
	Endif
	cSQL += "A3_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND  " + Enter
	cSQL += "DATEDIFF(day,A1_ULTCOM, GETDATE()) BETWEEN '"+MV_PAR03+"'  AND '"+MV_PAR04+"'" +Enter
	TcSQLExec(cSql)



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
	callcrys("CLIINA",MV_PAR01+";"+MV_PAR02+";"+MV_PAR03+";"+MV_PAR04+";"+Alltrim(Str(MV_PAR05)),cOpcao)
Return

//+
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ValidPerg    ³ Autor ³ MAGNAGO                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria as perguntas no SX1                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
	LOcal _j, _i
	Private _aPerguntas := {}

	AAdd(_aPerguntas,{cPerg,"01","Representante de:"	,"","","mv_ch01","C",15,0,0,"G","","mv_par01",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Ate:"			       	,"","","mv_ch02","C",20,0,0,"G","","mv_par02",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Inativos de:"			,"","","mv_ch03","C",20,0,0,"G","","mv_par03",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Ate:"             	,"","","mv_ch04","C",05,0,0,"G","","mv_par04",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AAdd(_aPerguntas,{cPerg,"01","Serie:"				,"","","mv_ch05","C",05,0,0,"G","","mv_par05",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})


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