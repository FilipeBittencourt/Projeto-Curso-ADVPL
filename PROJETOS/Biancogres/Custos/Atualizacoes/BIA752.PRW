#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA752
@author Marcos Alberto Soprani
@since 14/02/14
@version 1.0
@description Gera Devolução / Requisição Valorizada para valorizar as movi-
.            tações de PA resultado de beneficiamento próprio a partir das
.            requisições de encerramento de lote - TM 120 e 720
@type function
/*/

User Function BIA752()

	Processa({|| RptDetail()})

Return

Static Function RptDetail()

	Local vf

	cHInicio := Time()
	fPerg := "BIA752"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg()
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	If ( MV_PAR01 <= GetMV("MV_ULMES") .or. MV_PAR02 <= GetMV("MV_ULMES") )
		MsgSTOP("Favor verificar o intervalo de datas informado pois está fora do período de fechamento de estoque.","BIA752 - Data de Fechamento!!!")
		Return
	EndIf

	If dDataBase <> GetMV("MV_YULMES")
		MsgSTOP("Favor verificar a Data Base do sistema porque tem que ser igual a data de fechamento do mês.","BIA752 - Data de Fechamento!!!")
		Return
	EndIf

	oLogProc := TBiaLogProc():New()
	oLogProc:LogIniProc("BIA752",fPerg)

	TT004 := " SELECT D3_TM,
	TT004 += "        D3_COD DT_COD_RF,
	TT004 += "        ISNULL((SELECT SUM(D3_QUANT)
	TT004 += "                  FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	TT004 += "                 WHERE XD3.D3_FILIAL = '"+xFilial("SD3")+"'
	TT004 += "                   AND XD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TT004 += "                   AND SUBSTRING(XD3.D3_COD,1,7) = SUBSTRING(SD3.D3_COD,1,7)
	TT004 += "                   AND SUBSTRING(XD3.D3_COD,8,1) = '1'
	TT004 += "                   AND XD3.D3_TM = '010'
	TT004 += "                   AND XD3.D3_TIPO = 'PA'
	TT004 += "                   AND XD3.D_E_L_E_T_ = ' '), 0) PA1,
	TT004 += "        ISNULL((SELECT SUM(D3_QUANT)
	TT004 += "                  FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	TT004 += "                 WHERE XD3.D3_FILIAL = '"+xFilial("SD3")+"'
	TT004 += "                   AND XD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TT004 += "                   AND SUBSTRING(XD3.D3_COD,1,7) = SUBSTRING(SD3.D3_COD,1,7)
	TT004 += "                   AND SUBSTRING(XD3.D3_COD,8,1) = '2'
	TT004 += "                   AND XD3.D3_TM = '010'
	TT004 += "                   AND XD3.D3_TIPO = 'PA'
	TT004 += "                   AND XD3.D_E_L_E_T_ = ' '), 0) PA2,
	TT004 += "        ISNULL((SELECT SUM(D3_QUANT)
	TT004 += "                  FROM "+RetSqlName("SD3")+" XD3 WITH (NOLOCK)
	TT004 += "                 WHERE XD3.D3_FILIAL = '"+xFilial("SD3")+"'
	TT004 += "                   AND XD3.D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TT004 += "                   AND SUBSTRING(XD3.D3_COD,1,7) = SUBSTRING(SD3.D3_COD,1,7)
	TT004 += "                   AND SUBSTRING(XD3.D3_COD,8,1) = '3'
	TT004 += "                   AND XD3.D3_TM = '010'
	TT004 += "                   AND XD3.D3_TIPO = 'PA'
	TT004 += "                   AND XD3.D_E_L_E_T_ = ' '), 0) PA3,
	TT004 += "        D3_LOCAL,
	TT004 += "        D3_UM,
	TT004 += "        D3_QUANT,
	TT004 += "        D3_CONTA,
	TT004 += "        D3_GRUPO,
	TT004 += "        D3_DOC,
	TT004 += "        D3_EMISSAO,
	TT004 += "        D3_CUSTO1,
	TT004 += "        D3_CLVL
	TT004 += "   FROM "+RetSqlName("SD3")+" SD3 WITH (NOLOCK)
	TT004 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	TT004 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	TT004 += "    AND D3_TM IN('120','720')
	TT004 += "    AND D3_TIPO = 'PP'
	TT004 += "    AND SD3.D_E_L_E_T_ = ' '
	T4Index := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,TT004),'TT04',.T.,.T.)
	dbSelectArea("TT04")
	dbGoTop()

	aStruX := ("TT04")->(dbStruct())
	/*----- Exporta os dados do resultado de uma Query para um arquivo temporário normal -----*/
	gh_IndX := "DT_COD_RF"
	If !chkfile("AK08")
		AK08 := U_BIACrTMP(aStruX)
		dbUseArea( .T.,, AK08, "AK08", .F., .F. )
		dbCreateInd(AK08, gh_IndX,{ || gh_IndX })
	EndIf
	dbSelectArea("AK08")
	APPEND FROM ("TT04")
	If Select("TT04") > 0
		TT04->(dbCloseArea())
	Endif

	dbSelectArea("AK08")
	dbGoTop()
	kkssCts := 0
	kkjjCont := 0
	While !Eof()

		For vf := 1 to 3

			kkCodProd := Alltrim(AK08->DT_COD_RF)+Alltrim(Str(vf))
			kkDtRef   := dtos(MV_PAR02)

			kkjjCont ++
			IncProc("Proc... " + kkCodProd + " " + Alltrim(Str(kkjjCont)))

			jhQtdTot := AK08->PA1 + AK08->PA2 + AK08->PA3
			jhCusto  := ( AK08->D3_CUSTO1 / jhQtdTot ) * &("AK08->PA"+Alltrim(Str(vf)))

			If AK08->D3_TM > '500'
				kk_TM := "353"
				kk_CF := "DE6"
			Else
				kk_TM := "853"
				kk_CF := "RE6"
			EndIf

			If jhCusto <> 0

				SB1->(dbSetOrder(1))
				If SB1->(dbSeek(xFilial("SB1")+kkCodProd))

					RecLock("SD3",.T.)
					SD3->D3_FILIAL   := xFilial("SD3")
					SD3->D3_TM       := kk_TM
					SD3->D3_COD      := kkCodProd
					SD3->D3_UM       := SB1->B1_UM
					SD3->D3_LOCAL    := AK08->D3_LOCAL
					SD3->D3_CC       := "3000"
					SD3->D3_CLVL     := AK08->D3_CLVL
					SD3->D3_CONTA    := SB1->B1_CONTA
					SD3->D3_TIPO     := SB1->B1_TIPO
					SD3->D3_GRUPO    := SB1->B1_GRUPO
					SD3->D3_CUSTO1   := Round(ABS(jhCusto),2)
					SD3->D3_EMISSAO  := stod(kkDtRef)
					SD3->D3_DOC      := "MOVREFPUL"
					SD3->D3_USUARIO  := cUserName
					SD3->D3_CF       := kk_CF
					SD3->D3_NUMSEQ   := ProxNum()
					SD3->D3_CHAVE    := "E0"
					SD3->D3_YOBS     := "Movimento de valorização do PA com base na quebra de PP da linha 3"
					SD3->D3_YRFCUST  := "BIA752"
					MsUnlock()
					kkssCts += SD3->D3_CUSTO1

				EndIf

			EndIf

		Next vf

		dbSelectArea("AK08")
		dbSkip()

	End

	AK08->(dbCloseArea())

	// Grava XML
	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Verificar gravação - devolução valorizada referente TMs 120 E 720 de PP: " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "/" + StrZero(Year(MV_PAR02) ,4) + " - " + Alltrim(SM0->M0_NOME)

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "EMISSAO"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "TM"           ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "PRODUTO"      ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DESCR"        ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "DOC"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "CUSTO1"       ,3,2)

	PL008 := " SELECT D3_EMISSAO EMISSAO,
	PL008 += "        D3_TM TM,
	PL008 += "        D3_COD PRODUTO,
	PL008 += "        SUBSTRING(B1_DESC,1,50) DESCR,
	PL008 += "        D3_DOC DOC,
	PL008 += "        D3_CUSTO1 CUSTO1
	PL008 += "   FROM "+RetSqlName("SD3")+" SD3
	PL008 += "  INNER JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"'
	PL008 += "                       AND B1_COD = D3_COD
	PL008 += "                       AND SB1.D_E_L_E_T_ = ' '
	PL008 += "  WHERE D3_FILIAL = '"+xFilial("SD3")+"'
	PL008 += "    AND D3_EMISSAO BETWEEN '"+dtos(MV_PAR01)+"' AND '"+dtos(MV_PAR02)+"'
	PL008 += "    AND D3_YRFCUST = 'BIA752'
	PL008 += "    AND SD3.D_E_L_E_T_ = ' '
	PLcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,PL008),'PL08',.F.,.T.)
	dbSelectArea("PL08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc()

		oExcel:AddRow(nxPlan, nxTabl, { dtoc(stod(PL08->EMISSAO)), PL08->TM, PL08->PRODUTO, PL08->DESCR, PL08->DOC, PL08->CUSTO1 })

		dbSelectArea("PL08")
		dbSkip()

	End

	PL08->(dbCloseArea())
	Ferase(PLcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(PLcIndex+OrdBagExt())          //indice gerado

	xArqTemp := "devvalquebra-pp-linha3 - " + Substr(MesExtenso(Month(MV_PAR02)),1,3) + "-" + StrZero(Year(MV_PAR02) ,4) + "-" + Substr(SM0->M0_NOME,1,2)

	If fErase("C:\TEMP\"+xArqTemp+".xml") == -1
		Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + 'C:\TEMP\'+xArqTemp+'.xml' + ' antes de prosseguir!!!',{'Ok'})
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

	MsgINFO("Fim do processamento!!!")

	oLogProc:LogFimProc()

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 25.01.13 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","De Data              ?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Data             ?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.t.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return
