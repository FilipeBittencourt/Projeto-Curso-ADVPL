#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIA518
@author Marcos Alberto Soprani
@since 09/09/11
@version 1.0
@description Custos unitário para previsto ajustado BPC - SAP
@obs Em 08/03/17... Por Marcos Alberto Soprani... Revisado
@type function
/*/

/*/{Protheus.doc} BIA518
@author Artur Antunes
@since 19/04/17
@version 1.1
@description Inclusão de controle de processamento via SX6 (MV_YULRAC) 
@obs OS 2304-16
@type function
/*/

User Function BFG129I()

	Processa({|| RptiDetail()})

Return

Static Function RptiDetail()

	Local oExcel	:= Nil
	Local oExcelRel := Nil
	Local cHInicio	:= ""
	Local fPerg		:= ""
	Local fTamX1	:= ""
	Local nxPlan
	Local nxTabl
	Local xNmArq	:= "headcount_"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "")
	Local cFile		:= xNmArq + ".xml"
	Local cArqDest	:= ""
	Local _cAliasSr	:=	U_fGetDbSr()


	cHInicio := Time()
	fPerg := "BFG129I"
	fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)
	ValidPerg(fPerg,fTamX1)
	If !Pergunte(fPerg,.T.)
		Return
	EndIf

	oExcel := FWMSEXCEL():New()

	nxPlan := "Planilha 01"
	nxTabl := "Gerenciamento do HeadCount"

	oExcel:AddworkSheet(@nxPlan)
	oExcel:AddTable (@nxPlan,@nxTabl)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Cd. Processo"	,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Matricula"		,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Gestor"			,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Tp. Processo"	,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Def. Tp. Proc."	,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Data Ref."		,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Mat. Gerente"	,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Status"			,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Def. Status"		,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Cod. Posicao"	,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Descr.Posicao"	,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Matricula"		,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Nome"			,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Situação"		,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Def. Situação"	,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Tipo"			,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Def. Tipo"		,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Observação"		,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Mat. Obs."		,1,1)
	oExcel:AddColumn(@nxPlan,@nxTabl, "Motivo Obs."		,1,1)

	QR008 := " WITH MGESTOR AS "
	QR008 += "   			(SELECT RIGHT('00' + CAST(numemp AS VARCHAR(2)), 2) + RIGHT('000000' + CAST(numcad AS VARCHAR(6)), 6) MATGEST,
	QR008 += "                    	nomfun NOMGEST
	QR008 += "               FROM "+_cAliasSr+"..r034fun a(NOLOCK)
	QR008 += "               WHERE 
	QR008 += "                    	tipcol = 1
	QR008 += "               UNION ALL
	QR008 += "   			SELECT '01999998',
	QR008 += "                    	'MAX ZANCANARO'
	QR008 += "               UNION ALL
	QR008 += "   			SELECT '01999999',
	QR008 += "                    	'LUCAS ZENI')
	QR008 += "   		SELECT 
	QR008 += "                 	ZLC_CODIGO,
	QR008 += "                 	ZLC_MAT,
	QR008 += "                 	ZLCMAT.NOMGEST,
	QR008 += "                 	ZLC_TIPO,
	QR008 += "                 	ZLC_DTIPO = CASE
	QR008 += "                 		WHEN ZLC_TIPO = '1'
	QR008 += "                 		THEN 'Automatico'
	QR008 += "                 		WHEN ZLC_TIPO = '2'
	QR008 += "                 		THEN 'Manual'
	QR008 += "                 		ELSE 'Erro-Verificar'
	QR008 += "                 		END,
	QR008 += "                 	ZLC_DATREF,
	QR008 += "                 	ZLC_MATGER,
	QR008 += "                	ZLC_STATUS,
	QR008 += "                 	ZLC_DSTATU = CASE
	QR008 += "                 		WHEN ZLC_STATUS = 'A'
	QR008 += "                 		THEN 'Aberto'
	QR008 += "                 		WHEN ZLC_STATUS = 'F'
	QR008 += "                 		THEN 'Finalizado'
	QR008 += "                 		WHEN ZLC_STATUS = 'I'
	QR008 += "                 		THEN 'Iniciado'
	QR008 += "                 		ELSE 'Erro-Verificar'
	QR008 += "                 		END,
	QR008 += "                 	ZLD_CODPOS,
	QR008 += "                 	ZLA_DESPOS,
	QR008 += "                 	ZLD_MAT,
	QR008 += "                 	ZLD_NOME = ISNULL(ZLDMAT.nomfun, ''),
	QR008 += "                 	ZLD_SITUAC,
	QR008 += "                 	ZLD_DSITUAC = ISNULL(ZLE_DESCRI, ''),
	QR008 += "                 	ZLD_TIPO,
	QR008 += "                 	ZLD_DTIPO = CASE
	QR008 += "                 		WHEN ZLD_TIPO = '1'
	QR008 += "                 		THEN 'Automatico'
	QR008 += "                 		WHEN ZLD_TIPO = '2'
	QR008 += "                 		THEN 'Manual'
	QR008 += "                 		ELSE 'Erro-Verificar'
	QR008 += "                 		END,
	QR008 += "                 	ZLD_OBS,
	QR008 += "                 	ZLD_MATOBS,
	QR008 += "                 	ZLD_MOTOBS
	QR008 += "   		FROM "+ RetSqlName("ZLD") +" ZLD(NOLOCK)
	QR008 += "   			INNER JOIN "+ RetSqlName("ZLC") +" ZLC(NOLOCK) ON 
	QR008 += "									ZLC_FILIAL = '"+ xFilial("ZLC") +"'
	QR008 += "								AND ZLC_CODIGO = ZLD_CODIGO
	QR008 += "								AND ZLC_DATREF BETWEEN '"+ DToS(MV_PAR01) +"' AND '"+ DToS(MV_PAR02) +"'
	QR008 += "								AND ZLC_MAT BETWEEN '"+ MV_PAR03 +"' AND '"+ MV_PAR04 +"'
	QR008 += "								AND ZLC.D_E_L_E_T_ = ' '
	QR008 += "   			INNER JOIN "+ RetSqlName("ZLA") +" ZLA(NOLOCK) ON ZLA_FILIAL = '"+ xFilial("ZLA") +"'
	QR008 += "   			                                 AND ZLA_CODIGO = ZLD_CODPOS
	QR008 += "   			                                 AND ZLA.D_E_L_E_T_ = ' '
	QR008 += "   			LEFT JOIN "+ RetSqlName("ZLE") +" ZLE(NOLOCK) ON 
	QR008 += "									ZLE_CODIGO = ZLD_SITUAC
	QR008 += "								AND ZLE.D_E_L_E_T_ = ' '
	QR008 += "   			LEFT JOIN MGESTOR ZLCMAT ON 
	QR008 += "									ZLC.ZLC_MAT = ZLCMAT.MATGEST
	QR008 += "   			LEFT JOIN "+_cAliasSr+"..r034fun ZLDMAT ON 
	QR008 += "									CAST(SUBSTRING(ZLD.ZLD_MAT, 1, 2) AS INT) = ZLDMAT.numemp
	QR008 += "								AND CAST(RIGHT(ZLD.ZLD_MAT, 6) AS INT) = ZLDMAT.numcad
	QR008 += "								AND ZLDMAT.tipcol = 1
	QR008 += "   		WHERE ZLD.ZLD_FILIAL = '"+ xFilial("ZLD") +"'
	QR008 += "   		      AND ZLD.D_E_L_E_T_ = ' '
	QR008 += "   		ORDER BY 
	QR008 += "   			ZLC_CODIGO,
	QR008 += "   			ZLC_MAT,
	QR008 += "   			ZLD_CODPOS

	QRcIndex := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,QR008),'QR08',.F.,.T.)
	dbSelectArea("QR08")
	dbGoTop()
	ProcRegua(RecCount())
	While !Eof()

		IncProc("Processamento1")

		oExcel:AddRow(@nxPlan, @nxTabl, {	QR08->ZLC_CODIGO ,;
		QR08->ZLC_MAT    ,;
		QR08->NOMGEST    ,;
		QR08->ZLC_TIPO   ,;
		QR08->ZLC_DTIPO  ,;
		QR08->ZLC_DATREF ,;
		QR08->ZLC_MATGER ,;
		QR08->ZLC_STATUS ,;
		QR08->ZLC_DSTATU ,;
		QR08->ZLD_CODPOS ,;
		QR08->ZLA_DESPOS ,;
		QR08->ZLD_MAT    ,;
		QR08->ZLD_NOME   ,;
		QR08->ZLD_SITUAC ,;
		QR08->ZLD_DSITUAC,;                                          
		QR08->ZLD_TIPO	 ,;
		QR08->ZLD_DTIPO	 ,;
		QR08->ZLD_OBS	 ,;
		QR08->ZLD_MATOBS ,;
		QR08->ZLD_MOTOBS })

		dbSelectArea("QR08")
		dbSkip()

	End

	QR08->(dbCloseArea())
	Ferase(QRcIndex+GetDBExtension())     //arquivo de trabalho
	Ferase(QRcIndex+OrdBagExt())          //indice gerado

	oExcel:Activate()

	LjMsgRun( "Gerando o arquivo, aguarde...", "BIAFJ001", {|| oExcel:GetXMLFile( cFile ) } )
	oExcel:DeActivate()
	cArqDest := ConvertXlsx(/*cDir*/, cFile)
	If !Empty(cArqDest)
		oExcelRel := MsExcel():New()
		oExcelRel:SetVisible(.T.)
		oExcelRel:WorkBooks:Open( cArqDest )
	EndIf

Return

/*___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçào    ¦ ValidPerg¦ Autor ¦ Marcos Alberto S      ¦ Data ¦ 05/07/11 ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg(fPerg,fTamX1)

	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(fPerg,fTamX1)
	aRegs:={}

	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Dt Ini p/ ReferÊncia?","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Dt Fim p/ ReferÊncia?","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Do Gestor   ?","","","mv_ch3","C",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Ao Gestor   ?","","","mv_ch4","C",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i := 1 to Len(aRegs)
		if !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	dbSelectArea(_sAlias)

Return

static procedure ConvertXlsx(cDirOri,cArqOri)
	Local nHandler 
	Local cDrive	:= ""
	Local cDir		:= ""
	Local cNome		:= ""
	Local cExt		:= ""
	Local cVbs		:= ""
	Local cArqVbs	:= ""
	Local cDestino	:= AllTrim(GetTempPath())
	Local cArqDest	:= ""
	Local lContinua := .F.

	Default cDirOri	:= ""
	Default cArqOri := ""

	If !Empty(cArqOri) .AnD. ApOleClient('MsExcel') 
		If Empty(cDirOri)
			If CpyS2T(cArqOri, cDestino, .F.)
				lContinua := .T.
				SplitPath(cDestino + cArqOri, @cDrive, @cDir, @cNome, @cExt)
				cArqOri	 := cDrive + cDir + cArqOri
				cArqDest := cDrive + cDir + cNome +".xlsx"
				cArqVbs  := AllTrim(GetTempPath())+ cNome +".vbs"
			EndIf
		Else
			If CpyS2T(cDirOri + cArqOri, cDestino, .F.)
				lContinua := .T.
				SplitPath(cDestino + cArqOri, @cDrive, @cDir, @cNome, @cExt)
				cArqOri	 := cDrive + cDir + cArqOri
				cArqDest := cDrive + cDir + cNome +".xlsx"
				cArqVbs  := AllTrim(GetTempPath())+ cNome +".vbs"
			EndIf
		EndIf
	EndIf
	cVbs := 'Dim objXLApp, objXLWb '+CRLF
	cVbs += 'Set objXLApp = CreateObject("Excel.Application") '+CRLF
	cVbs += 'objXLApp.Visible = False '+CRLF
	cVbs += 'Set objXLWb = objXLApp.Workbooks.Open("'+ cArqOri +'") '+CRLF
	cVbs += 'objXLWb.SaveAs "'+ cArqDest +'", 51 '+CRLF
	cVbs += 'objXLWb.Close (true) '+CRLF
	cVbs += 'Set objXLWb = Nothing '+CRLF
	cVbs += 'objXLApp.Quit '+CRLF
	cVbs += 'Set objXLApp = Nothing '+CRLF
	If lContinua
		nHandler := FCreate(cArqVbs)
		If ( nHandler <> -1 )
			FWrite(nHandler, cVbs)
			FClose(nHandler)                           
			If WaitRun('cscript.exe '+ cArqVbs, 0) == 0 
				If File(cArqDest)
					If File(cArqOri)
						FErase(cArqOri)
					EndIf
					If File(cArqVbs)
						FErase(cArqVbs)
					EndIf
				Else
					lContinua := .F.
				EndIf
			Else
				lContinua := .F.
			EndIf
		Else
			lContinua := .F.	  	 
		EndIf
	EndIf
	If !lContinua
		If File(cArqDest)
			FErase(cArqDest)
		EndIf
		If File(cArqVbs)
			FErase(cArqVbs)
		EndIf
	EndIf

Return(cArqDest)
