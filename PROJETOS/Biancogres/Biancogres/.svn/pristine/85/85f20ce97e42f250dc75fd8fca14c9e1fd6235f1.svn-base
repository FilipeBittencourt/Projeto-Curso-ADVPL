#include "rwMake.ch"
#include "Topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PREVDES        ºAutor  ³ HARLEY DIAS KOEHLERº Data ³  14/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RELATORIO DE PREVISAO DE DESPESAS - MARKETING                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP 7                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIMARK()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cSQL
	Private Enter := CHR(13)+CHR(10) 
	lEnd       := .F.
	cString    := ""
	cDesc1     := "Este programa tem como objetivo imprimir relatorio "
	cDesc2     := "de acordo com os parametros informados pelo usuario."
	cDesc3     := "Comparativo de Pesos "
	cTamanho   := ""
	limite     := 80		
	aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	cNomeprog  := "DIMARK"
	cPerg      := "DIMARK"
	aLinha     := {}
	nLastKey   := 0
	cTitulo	   := "Relatorio Previsao de Despesas - Marketing"
	Cabec1     := ""
	Cabec2     := ""
	nBegin     := 0
	cDescri    := ""
	cCancel    := "***** CANCELADO PELO OPERADOR *****"
	m_pag      := 1                                    
	wnrel      := "DIMARK"
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
	cSQL += "ALTER VIEW VW_DISTMARK AS  " + Enter
	cSQL += "SELECT 'D' AS TIPO,ZO_TPDES, SUM(JAN) AS JAN , SUM(FEV) AS FEV , SUM(MARC) AS MAR, SUM(ABR) AS ABR, SUM(MAI) AS MAI," + Enter
	cSQL += "SUM(JUN) AS JUN, SUM(JUL) AS JUL,SUM(AGO) AS AGO, SUM(SETE) AS SETE,SUM(OUTU) AS OUTU, " + Enter
	cSQL += "SUM(NOV) AS NOV, SUM(DEZ) AS DEZ FROM (" + Enter
	cSQL += "SELECT ZO_STATUS, ZO_TPDES, ZO_DATA, ZO_REPRE, ZO_CLIENTE, D_E_L_E_T_,  " + Enter
	cSQL += "JAN  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0101' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0131' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "FEV  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0201' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0229' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "MARC = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0301' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0331' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "ABR  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0401' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0430' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "MAI  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0501' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0531' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "JUN  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0601' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0630' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "JUL  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0701' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0731' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "AGO  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0801' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0831' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "SETE = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0901' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0930' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "OUTU = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"1001' AND '"+Subs(Dtos(MV_PAR01),1,4)+"1031' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "NOV  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"1101' AND '"+Subs(Dtos(MV_PAR01),1,4)+"1130' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "DEZ  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"1201' AND '"+Subs(Dtos(MV_PAR01),1,4)+"1231' THEN ZO_VALOR ELSE 0 END  " + Enter
	cSQL += "FROM " + RetSqlName("SZO") + ") SZO " + Enter
	cSQL += "WHERE D_E_L_E_T_ = '' AND  ZO_TPDES   <> '' " + Enter
	cSQL += "AND  ZO_STATUS = 'Baixa Total' " + Enter
	cSQL += "AND  ZO_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' " + Enter
	cSQL += "AND  ZO_REPRE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
	cSQL += "AND  ZO_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
	cSQL += "GROUP BY ZO_TPDES " + Enter
	cSQL += "UNION " + Enter

	cSQL += "SELECT 'P' AS TIPO,ZO_FPAGTO, SUM(JAN) AS JAN , SUM(FEV) AS FEV , SUM(MARC) AS MAR, SUM(ABR) AS ABR, SUM(MAI) AS MAI," + Enter
	cSQL += "SUM(JUN) AS JUN, SUM(JUL) AS JUL,SUM(AGO) AS AGO, SUM(SETE) AS SETE,SUM(OUTU) AS OUTU, " + Enter
	cSQL += "SUM(NOV) AS NOV, SUM(DEZ) AS DEZ FROM (" + Enter
	cSQL += "SELECT ZO_STATUS, ZO_FPAGTO, ZO_DATA, ZO_REPRE, ZO_CLIENTE, D_E_L_E_T_,  " + Enter
	cSQL += "JAN  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0101' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0131' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "FEV  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0201' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0229' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "MARC = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0301' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0331' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "ABR  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0401' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0430' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "MAI  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0501' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0531' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "JUN  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0601' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0630' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "JUL  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0701' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0731' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "AGO  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0801' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0831' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "SETE = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"0901' AND '"+Subs(Dtos(MV_PAR01),1,4)+"0930' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "OUTU = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"1001' AND '"+Subs(Dtos(MV_PAR01),1,4)+"1031' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "NOV  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"1101' AND '"+Subs(Dtos(MV_PAR01),1,4)+"1130' THEN ZO_VALOR ELSE 0 END, " + Enter
	cSQL += "DEZ  = CASE WHEN ZO_DATA BETWEEN '" +Subs(Dtos(MV_PAR01),1,4)+"1201' AND '"+Subs(Dtos(MV_PAR01),1,4)+"1231' THEN ZO_VALOR ELSE 0 END  " + Enter
	cSQL += "FROM " + RetSqlName("SZO") + ") SZO " + Enter
	cSQL += "WHERE D_E_L_E_T_ = '' AND  ZO_FPAGTO   <> '' " + Enter
	cSQL += "AND  ZO_STATUS = 'Baixa Total' " + Enter
	cSQL += "AND  ZO_DATA BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' " + Enter
	cSQL += "AND  ZO_REPRE BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + Enter
	cSQL += "AND  ZO_CLIENTE BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + Enter
	cSQL += "GROUP BY ZO_FPAGTO " + Enter


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
	callcrys("DIMARK",cempant+";"+Dtoc(MV_PAR01)+";"+Dtoc(MV_PAR02)+";"+MV_PAR03+";"+MV_PAR04+";"+MV_PAR05+";"+MV_PAR06,cOpcao)
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

	//AAdd(_aPerguntas,{cPerg,"01","Do Periodo de ? de:"	,"","","mv_ch01","C",06,0,0,"G","","mv_par01",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Periodo Final ate :"	,"","","mv_ch02","C",06,0,0,"G","","mv_par02",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Att:"				,"","","mv_ch03","C",20,0,0,"G","","mv_par03",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Data FAX:"		,"","","mv_ch04","D",08,0,0,"G","","mv_par04",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Tel:"				,"","","mv_ch05","C",14,0,0,"G","","mv_par05",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Pags:"			,"","","mv_ch06","C",03,0,0,"G","","mv_par06",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Ref:"				,"","","mv_ch07","C",30,0,0,"G","","mv_par07",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","C/C:"				,"","","mv_ch08","C",15,0,0,"G","","mv_par08",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Empresa:"			,"","","mv_ch09","C",30,0,0,"G","","mv_par09",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Data Deb:"		,"","","mv_ch10","D",08,0,0,"G","","mv_par10",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Agencia:"			,"","","mv_ch11","C",05,0,0,"G","","mv_par11",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","C/C:"				,"","","mv_ch12","C",10,0,0,"G","","mv_par12",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch13","N",14,2,0,"G","","mv_par13",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Data Cred:"		,"","","mv_ch14","D",08,0,0,"G","","mv_par14",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Func 1:"			,"","","mv_ch15","C",50,0,0,"G","","mv_par15","SRA"	,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch16","N",14,2,0,"G","","mv_par16",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Func 2:"			,"","","mv_ch17","C",50,0,0,"G","","mv_par17","SRA"	,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch18","N",14,2,0,"G","","mv_par18",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Func 3:"			,"","","mv_ch19","C",50,0,0,"G","","mv_par19","SRA"	,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch20","N",14,2,0,"G","","mv_par20",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Func 4:"			,"","","mv_ch21","C",50,0,0,"G","","mv_par21","SRA"	,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//AAdd(_aPerguntas,{cPerg,"01","Valor::"			,"","","mv_ch22","N",14,2,0,"G","","mv_par22",""		,"","","","","","","","","","","","","","","","","","","","","","","","","","","",""})





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