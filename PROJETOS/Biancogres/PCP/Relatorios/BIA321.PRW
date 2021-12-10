#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#include "TOTVS.CH"
#include "rwmake.ch"

/*/{Protheus.doc} BIA321
@author Marcos Alberto Soprani
@since 02/10/13
@version 1.0
@description Relatório de conferência eForms
@obs Projeto eForms
@type function
/*/

User Function BIA321()

	Private msrhEnter   := CHR(13) + CHR(10)
	Private ret := {}
	//fPerg := "BIA321"
	// fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	// fValidPerg()
	// If !Pergunte(fPerg,.T.)
	// 	Return
	// EndIf	

	ret := xParamBox()

	If Len(ret) == 0 .Or. Empty(ret)
		Return
	ENDIF

	Processa({|| Rpt321Det() }, "Processando...", , .F.)

Return

Static Function Rpt321Det()

	Local Ni
	Local nContItens := 0
	Local nTotItens  := 0
	Local msVetCamp  := {}
	Local msColPivot := ""
	Local msVetTrans := {}

	Local msQtdCamp  := 6 // número inicial para o formulário 4
	Local msDtIni    := ''
	Local msDtFim    := ''
	Local form       := 4 //Prensa

	Local msStaExcQy := 0
	Local lOk        := .T.
	Local msGravaErr := ""
	Local msTmpQry   := "##TMPBIA321_" + __cUserID +"_"+ dtos(Date()) + StrTran(Time(), ":", "")
	Local nxPlan	 := ""

	msDtIni := Substr(dtos(ret[1]), 1, 4) + "-" + Substr(dtos(ret[1]), 5, 2) + "-" + Substr(dtos(ret[1]), 7, 2)
	msDtFim := Substr(dtos(ret[2]), 1, 4) + "-" + Substr(dtos(ret[2]), 5, 2) + "-" + Substr(dtos(ret[2]), 7, 2)
	nxPlan := Alltrim(ret[3])

	//.Or. Empty(nxPlan) porque existe um bug no ParamBox quando selecionada o primeiro elemento
	if (nxPlan == "Inspeção Prensa" .Or. Empty(nxPlan)) 
		form := 4
		nxPlan := "Inspeção Prensa"
	elseif (nxPlan == "Inspeção Laboratório") 
		form := 14
	elseif (nxPlan == "Inspeção CQPA") 
		form := 10012
	elseif (nxPlan == "Inspeção Prensa 2") 
		form := 10014
	endif

	//esses numeros são os identificadores dos formularios gerados na base EFORMS, tabela Form
	// if (MV_PAR03 == 1) 
	// 	form = 4
	// 	nxPlan := "Inspeção - Prensa"
		
	// elseif (MV_PAR03 == 2) 
	// 	form = 14
	// 	nxPlan := "Inspeção - Laboratório"
		
	// elseif (MV_PAR03 == 3) 
	// 	form = 10012
	// 	nxPlan := "Inspeção - CQPA"
	// endif

	ProcRegua(0)

	oExcel := FWMSEXCEL():New()
	
	nxTabl := "Registros"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)

	oExcel:AddColumn(nxPlan, nxTabl, "FormID"   , 1, 1)
	oExcel:AddColumn(nxPlan, nxTabl, "FormCod"  , 1, 1)
	oExcel:AddColumn(nxPlan, nxTabl, "FormNam"  , 1, 1)
	oExcel:AddColumn(nxPlan, nxTabl, "ENSAIO"   , 1, 1)
	oExcel:AddColumn(nxPlan, nxTabl, "DTENSAIO" , 2, 4)
	oExcel:AddColumn(nxPlan, nxTabl, "HRENSAIO" , 1, 1)

	aadd(msVetCamp, { "FormID"   , "FormID"   , 1} )
	aadd(msVetCamp, { "FormCod"  , "FormCod"  , 1} )
	aadd(msVetCamp, { "FormNam"  , "FormNam"  , 1} )
	aadd(msVetCamp, { "ENSAIO"   , "ENSAIO"   , 1} )
	aadd(msVetCamp, { "DTENSAIO" , "DTENSAIO" , 1} )
	aadd(msVetCamp, { "HRENSAIO" , "HRENSAIO" , 1} )

	//seleção dos campos e ordem definida conforme documentação de projeto Formularios Digitais
	if(form <> 4)
		RT007 := " WITH XCAMPOS "
		RT007 += "      AS (SELECT CCAMPO = CONVERT(VARCHAR(7), CCAMPO) COLLATE Latin1_General_BIN, "
		RT007 += "                 DESCR = CONVERT(VARCHAR(75), DESCR) COLLATE Latin1_General_BIN, "
		RT007 += "                 TIPO, "
		RT007 += "                 ORDEM, "
		RT007 += "                 ROW_NUMBER() OVER( "
		RT007 += "                 ORDER BY ORDEM) SEQ "
		RT007 += "          FROM "
		RT007 += "          ( "
		RT007 += "              SELECT DISTINCT "
		RT007 += "                     'C' + RIGHT('000000' + RTRIM(CONVERT(VARCHAR, CAMPO.[ID])), 6) CCAMPO, "
		RT007 += "                     'C' + RIGHT('000000' + RTRIM(CONVERT(VARCHAR, CAMPO.[ID])), 6) + '-' + "
		RT007 += "                     ISNULL(CAMPO.[Label], CASE WHEN CHARINDEX('::', CAMPO.[Name]) > 0 
		RT007 += "                     		THEN  SUBSTRING(CAMPO.[Name], CHARINDEX('::', CAMPO.[Name])+2, LEN(CAMPO.[Name]))
		RT007 += "                     		ELSE CAMPO.[Name] 
		RT007 += "                     END) DESCR,
		RT007 += "                     CAMPO.[Type] TIPO, "
		RT007 += "					 	RIGHT('00' + RTRIM(CONVERT(VARCHAR, BOX.[Order])), 2) + "
		RT007 += "				 		(CASE WHEN F_TABELA.ID IS NOT NULL  "
		RT007 += "					  			THEN RIGHT('00' + RTRIM(CONVERT(VARCHAR, F_TABELA.[RowNumber])), 2)  "
		RT007 += "					  			ELSE RIGHT('00' + RTRIM(CONVERT(VARCHAR, CAMPO.[RowNumber])), 2)  "
		RT007 += "				 		END) + "
		RT007 += "				 
		RT007 += "				 		(CASE WHEN LINHA.ID IS NOT NULL AND COLUNA.ID IS NOT NULL "
		RT007 += "					   		THEN RIGHT('00' + RTRIM(CONVERT(VARCHAR, LINHA.[Order])), 2) +  "
		RT007 += "									RIGHT('00' + RTRIM(CONVERT(VARCHAR, COLUNA.[Order])), 2) "
		RT007 += "					   		ELSE RIGHT('0000' + RTRIM(CONVERT(VARCHAR, CAMPO.[Order])), 4)  "
		RT007 += "       	 			END) ORDEM "
		RT007 += "              FROM [EFORMS].[dbo].[DataField] DADOS(NOLOCK) "
		RT007 += "                   INNER JOIN [EFORMS].[dbo].[Field] CAMPO(NOLOCK) ON CAMPO.[ID] = DADOS.[FieldID] "
		RT007 += "                   INNER JOIN [EFORMS].[dbo].[Box] BOX (NOLOCK) ON BOX.[ID] = CAMPO.BoxID "
		RT007 += "                   INNER JOIN [EFORMS].[dbo].[DataForm] LINKFORM(NOLOCK) ON LINKFORM.[ID] = DADOS.[DataFormID] "
		RT007 += "                   INNER JOIN [EFORMS].[dbo].[Form] FORMULARIO(NOLOCK) ON FORMULARIO.[ID] = LINKFORM.[FormID] "
		RT007 += "                                                                          AND LINKFORM.[FormID] = " + STR(form) + ' '"
		RT007 += "      			 LEFT JOIN [EFORMS].[dbo].[ROW] LINHA (NOLOCK) ON LINHA.ID = CAMPO.RowID
		RT007 += "      			 LEFT JOIN [EFORMS].[dbo].[COLUMN] COLUNA (NOLOCK) ON COLUNA.ID = CAMPO.ColID
		RT007 += "      			 LEFT JOIN [EFORMS].[dbo].[TABLE] TABELA (NOLOCK) ON TABELA.ID = LINHA.TableID
		RT007 += "      			 LEFT JOIN [EFORMS].[dbo].[Field] F_TABELA (NOLOCK) ON F_TABELA.ID = TABELA.FieldID
		RT007 += "          ) AS TEMP1) "
		RT007 += "      SELECT ORDEM, "
		RT007 += "      	   CCAMPO, "
		RT007 += "             DESCRICAO = RTRIM(DESCR), "
		RT007 += "             TIPO, "
		RT007 += "             SEQ, "
		RT007 += "      ( "
		RT007 += "          SELECT MAX(SEQ) "
		RT007 += "          FROM XCAMPOS "
		RT007 += "      ) NUMREQ "
		RT007 += "      FROM XCAMPOS "
	else
		RT007 := " WITH XCAMPOS "
		RT007 += "      AS (SELECT CCAMPO = CONVERT(VARCHAR(7), CCAMPO) COLLATE Latin1_General_BIN, "
		RT007 += "                 DESCR = CONVERT(VARCHAR(75), DESCR) COLLATE Latin1_General_BIN, "
		RT007 += "                 TIPO, "
		RT007 += "                 ROW_NUMBER() OVER( "
		RT007 += "                 ORDER BY DESCR) SEQ "
		RT007 += "          FROM "
		RT007 += "          ( "
		RT007 += "              SELECT DISTINCT "
		RT007 += "                     'C' + RIGHT('000000' + RTRIM(CONVERT(VARCHAR, CAMPO.[ID])), 6) CCAMPO, "
		RT007 += "                     'C' + RIGHT('000000' + RTRIM(CONVERT(VARCHAR, CAMPO.[ID])), 6) + '-' + ISNULL(CAMPO.[Label], CAMPO.[Name]) DESCR, "
		RT007 += "                     CAMPO.[Type] TIPO "
		RT007 += "              FROM [EFORMS].[dbo].[DataField] DADOS(NOLOCK) "
		RT007 += "                   INNER JOIN [EFORMS].[dbo].[Field] CAMPO(NOLOCK) ON CAMPO.[ID] = DADOS.[FieldID] "
		RT007 += "                   INNER JOIN [EFORMS].[dbo].[DataForm] LINKFORM(NOLOCK) ON LINKFORM.[ID] = DADOS.[DataFormID] "
		RT007 += "                   INNER JOIN [EFORMS].[dbo].[Form] FORMULARIO(NOLOCK) ON FORMULARIO.[ID] = LINKFORM.[FormID] "
		RT007 += "                                                                          AND LINKFORM.[FormID] = " + STR(form) + ' '"
		RT007 += "          ) AS TEMP1) "
		RT007 += "      SELECT CCAMPO, "
		RT007 += "             DESCRICAO = RTRIM(DESCR), "
		RT007 += "             TIPO, "
		RT007 += "             SEQ, "
		RT007 += "      ( "
		RT007 += "          SELECT MAX(SEQ) "
		RT007 += "          FROM XCAMPOS "
		RT007 += "      ) NUMREQ "
		RT007 += "      FROM XCAMPOS "
	endif
	
	RTcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,RT007),'RT07',.F.,.T.)
	dbSelectArea("RT07")
	dbGoTop()
	nTotItens := RT07->NUMREQ
	ProcRegua(nTotItens)
	While !Eof()

		nContItens++
		IncProc("Montando Cabeçalho...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(99,2)) + "%")

		msProp1 := 1
		msProp2 := 1
		If RT07->TIPO = 3 // Data
			msProp1 := 2
			msProp2 := 4
		ElseIf RT07->TIPO = 2 // Numerico
			msProp1 := 3
			msProp2 := 2
		EndIf

		aadd(msVetCamp, { RT07->CCAMPO, RT07->DESCRICAO, RT07->TIPO } )

		msColPivot += IIF(!Empty(msColPivot), ",", "") 
		msColPivot += "[" + RT07->CCAMPO + "]"

		msQtdCamp  ++
		oExcel:AddColumn(nxPlan, nxTabl, Alltrim(RT07->DESCRICAO), msProp1, msProp2)

		dbSelectArea("RT07")
		dbSkip()

	End

	ProcRegua(0)
	nContItens := 0
	IncProc()
	RL005 := " SELECT FormID = CONVERT(VARCHAR(6), LINKFORM.[FormID]) COLLATE Latin1_General_BIN, "
	RL005 += "        FormCod = CONVERT(VARCHAR(7), FORMULARIO.[Code]) COLLATE Latin1_General_BIN, "
	RL005 += "        FormNam = CONVERT(VARCHAR(75), FORMULARIO.[Name]) COLLATE Latin1_General_BIN, "
	RL005 += "        ENSAIO = CONVERT(VARCHAR(7), LINKFORM.[ID]) COLLATE Latin1_General_BIN, "
	RL005 += "        DTENSAIO = CONVERT(VARCHAR(10), LINKFORM.[InsertDateTime],103) COLLATE Latin1_General_BIN, "
	RL005 += "        HRENSAIO = SUBSTRING(CONVERT(VARCHAR, LINKFORM.[InsertDateTime]), 12, 8), "
	RL005 += "        CCAMPO = 'C' + RIGHT('000000' + RTRIM(CONVERT(VARCHAR(6), CAMPO.[ID])), 6) COLLATE Latin1_General_BIN, "
	RL005 += "        CONTEUDO = CONVERT(VARCHAR(75), DADOS.[Content]) COLLATE Latin1_General_BIN "
	RL005 += "  INTO " + msTmpQry + " "
	RL005 += "  FROM [EFORMS].[dbo].[DataField] DADOS(NOLOCK) "
	RL005 += "       INNER JOIN [EFORMS].[dbo].[Field] CAMPO(NOLOCK) ON CAMPO.[ID] = DADOS.[FieldID] "
	RL005 += "       INNER JOIN [EFORMS].[dbo].[DataForm] LINKFORM(NOLOCK) ON LINKFORM.[ID] = DADOS.[DataFormID] "
	RL005 += "       INNER JOIN [EFORMS].[dbo].[Form] FORMULARIO(NOLOCK) ON FORMULARIO.[ID] = LINKFORM.[FormID] "
	RL005 += "                                                              AND LINKFORM.[FormID] = " + STR(form) + ' '"
	RL005 += "  WHERE LINKFORM.[InsertDateTime] BETWEEN '" + msDtIni + " 06:00:00.0000000' AND '" + msDtFim + " 05:59:59.9999999' "
	U_BIAMsgRun("Aguarde... Gerando area de trabalho... ",,{|| msStaExcQy := TcSQLExec(RL005) })
	If msStaExcQy < 0
		lOk := .F.
	EndIf

	If lOk

		RL005 := " SELECT * "
		RL005 += "  FROM " + msTmpQry + " PIVOT(MIN(CONTEUDO) FOR CCAMPO IN(" + msColPivot + ")) em_colunas "
		RL005 += " ORDER BY 1 "
		RLcIndex := CriaTrab(Nil,.f.)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,RL005),'RL05',.F.,.T.)
		dbSelectArea("RL05")
		nTotItens := 100
		dbGoTop()
		ProcRegua(nTotItens)
		While !Eof()

			nContItens++
			IncProc("Atribuindo Registros...  - Status: " + IIF((nContItens/nTotItens)*100 <= 99, StrZero((nContItens/nTotItens)*100,2), STRZERO(99,2)) + "%")

			aadd(msVetTrans, Array(msQtdCamp))

			For nI := 1 to Len(msVetCamp)

				If msVetCamp[nI][3] == 2
					msVetTrans[Len(msVetTrans)][nI] := Val(StrTran(StrTran(Alltrim( &( "RL05->" + msVetCamp[nI][1]) ),".",""),",","."))
				Else 
					msVetTrans[Len(msVetTrans)][nI] := Alltrim( &( "RL05->" + msVetCamp[nI][1] ) )
				EndIf

			Next nI

			oExcel:AddRow(nxPlan, nxTabl, msVetTrans[1] )
			msVetTrans := {}

			dbSelectArea("Rl05")
			dbSkip()

		End

		RL05->(dbCloseArea())
		Ferase(RLcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(RLcIndex+OrdBagExt())          //indice gerado

		RT07->(dbCloseArea())
		Ferase(RTcIndex+GetDBExtension())     //arquivo de trabalho
		Ferase(RTcIndex+OrdBagExt())          //indice gerado

		xArqTemp := "BIA321_" + ALLTrim( DTOS(DATE()) + "_"+StrTran( time(),':',''))

		If File("C:\TEMP\"+xArqTemp+".xml")
			If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
				Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
			EndIf
		EndIf

		oExcel:Activate()
		oExcel:GetXMLFile("C:\TEMP\"+xArqTemp+".xml")

		cCrLf := Chr(13) + Chr(10)
		If ! ApOleClient( 'MsExcel' )
			MsgAlert( "MsExcel nao instalado!"+cCrLf+cCrLf+"Você poderá recuperar este arquivo em: "+"C:\TEMP\"+xArqTemp+".xml" )
		Else
			oExcel:= MsExcel():New()
			oExcel:WorkBooks:Open( "C:\TEMP\"+xArqTemp+".xml" ) // Abre uma planilha
			oExcel:SetVisible(.T.)
		EndIf

	Else

		msGravaErr := TCSQLError()
		Aviso('Problema de Processamento', "Erro na execução do processamento: " + msrhEnter + msrhEnter + msrhEnter + msGravaErr + msrhEnter + msrhEnter + msrhEnter + msrhEnter + "Processo Cancelado!!!" + msrhEnter + msrhEnter + msrhEnter, {'Fecha'}, 3 )

	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ fValidPerg ¦ Autor ¦ Marcos Alberto S    ¦ Data ¦ 18/09/12 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
// Static Function fValidPerg()

// 	local i,j
// 	_sAlias := Alias()
// 	dbSelectArea("SX1")
// 	dbSetOrder(1)
// 	cPerg := PADR(fPerg,fTamX1)
// 	aRegs:={}
	

// 	MV_PAR03 := 1 

// 	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
// 	aAdd(aRegs,{cPerg,"01","De Data                  ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
// 	aAdd(aRegs,{cPerg,"02","Até Data                 ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
// 	aAdd(aRegs,{cPerg,"03","Formulário               ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Prensa","Prensa","Prensa","","","Laboratorio","Laboratorio","Laboratorio","","","CQPA","CQPA","CQPA","","","","","","","","","","","",""})
// 	For i := 1 to Len(aRegs)
// 		if !dbSeek(cPerg + aRegs[i,2])
// 			RecLock("SX1",.t.)
// 			For j:=1 to FCount()
// 				If j <= Len(aRegs[i])
// 					FieldPut(j,aRegs[i,j])
// 				Endif
// 			Next
// 			MsUnlock()
// 		Endif
// 	Next

// 	dbSelectArea(_sAlias)

// Return

Static Function xParamBox()
	Local aRet := {}
	Local aParamBox := {}
	Local aForms := {"-", "Inspeção Prensa","Inspeção Laboratório","Inspeção CQPA","Inspeção Prensa 2"}

	Private cCadastro := "Formulários"

	// --------------------------------------------------------------
	// Abaixo está a montagem do vetor que será passado para a função
	// --------------------------------------------------------------
	aAdd(aParamBox,{1,"Data inicial"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
	aAdd(aParamBox,{1,"Data final"  ,Ctod(Space(8)),"","","","",50,.T.}) // Tipo data
	// Tipo 1 -> MsGet()
	//           [2]-Descricao
	//           [3]-String contendo o inicializador do campo
	//           [4]-String contendo a Picture do campo
	//           [5]-String contendo a validacao
	//           [6]-Consulta F3
	//           [7]-String contendo a validacao When
	//           [8]-Tamanho do MsGet
	//           [9]-Flag .T./.F. Parametro Obrigatorio ?

	aAdd(aParamBox,{2,"Formulário",1,aForms,100,"",.T.})
	// Tipo 2 -> Combo
	//           [2]-Descricao
	//           [3]-Numerico contendo a opcao inicial do combo
	//           [4]-Array contendo as opcoes do Combo
	//           [5]-Tamanho do Combo
	//           [6]-Validacao
	//           [7]-Flag .T./.F. Parametro Obrigatorio ?
	// Cuidado, há um problema nesta opção quando selecionado a 1ª opção.

	ParamBox(aParamBox,"Extração de dados de formulários",@aRet)
	
Return aRet
