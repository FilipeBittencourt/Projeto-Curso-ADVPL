#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA770
@author Marcos Alberto Soprani
@since 10/02/17
@version 1.0
@description Importação da Metas de Receita - BPC/SAP e outras - para Protheus SCT a fim de apurar comissão variável
.            e outras informações pertinentes a meta de vendas...
@type function
/*/

User Function BIA770()

	Processa({|| DetProcXX()})

Return

Static Function DetProcXX()

	Local oDlg
	Private cArquivo := Space(100)
	Private nLin := 18
	Private nCol1 := 16
	Private nCol2 := 40
	Private nCol3 := 170
	Private bOk := { || If(ValidDirect(), (lOk:=.T.,oDlg:End()) ,) }
	Private bCancel := { || lOk:=.F.,oDlg:End() }

	Private oComboBox1
	Private nComboBox1 := "0"

	zpMensag := 'Importante:' + CHR(13) + CHR(10)
	zpMensag += '   É necessário estar com o arquivo de integração convertido para .dbf' + CHR(13) + CHR(10)
	zpMensag += '   Para efetuar a conversão de seu arquivo .xlsx para .dbf, você deverá utilizar um editor de planilha open source: exemplo, BrOffice, LibreOffice ' + CHR(13) + CHR(10) + CHR(13) + CHR(10)
	zpMensag += 'Quanto ao Layout:' + CHR(13) + CHR(10)
	zpMensag += '   BPC:' + CHR(13) + CHR(10)
	zpMensag += '       MARCA + TEMPO + VENDEDOR + SEGMENTO + PACOTE + CONTA_REC_ + IND_RECEIT + BPC_SIGNDA' + CHR(13) + CHR(10)
	zpMensag += '   Livre:' + CHR(13) + CHR(10)
	zpMensag += '       ...' + CHR(13) + CHR(10)
	zpMensag += CHR(13) + CHR(10) + CHR(13) + CHR(10) + CHR(13) + CHR(10) + CHR(13) + CHR(10) + CHR(13) + CHR(10)

	Aviso( 'Importação das Metas', zpMensag, {'Ok'}, 3 )

	//Set Deleted On
	Define MsDialog oDlg Title "Diretório" From 08,15 To 20,65 Of GetWndDefault()
	@nLin,nCol1 Say "Diretorio:" Size 050,10 Of oDlg Pixel
	@nLin,nCol2 MsGet cArquivo Size 110,08 Of oDlg Pixel

	@nLin+18,nCol1 SAY oSay1 PROMPT "Layout: " SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@nLin+15,nCol2 MSCOMBOBOX oComboBox1 VAR nComboBox1 ITEMS {"Meta Receita (Layout BPC)","Meta Receita (Layout Livre)"} SIZE 082, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@nLin,nCol3-15 Button "…" Size 010,10 Action Eval({|| ChooseFile() }) Of oDlg Pixel

	Activate MsDialog oDlg Centered On Init (EnchoiceBar(oDlg,bOk,bCancel))

	If !File(alltrim(cArquivo))
		MsgStop("Caminho ou Arquivo inválido!","Atenção")
		Return .F.
	Endif

	If nComboBox1 == "Meta Receita (Layout BPC)"

		xcTab := Substr(cArquivo, 1, AT(".dbf",cArquivo)-1)
		dbUseArea(.T.,,xcTab+".dbf","REF1",.F.)
		dbCreateIndex(xcTab+".cdx","MARCA+TEMPO+VENDEDOR+SEGMENTO+PACOTE+CONTA_REC_+IND_RECEIT",{|| MARCA+TEMPO+VENDEDOR+SEGMENTO+PACOTE+CONTA_REC_+IND_RECEIT })
		dbSelectArea("REF1")
		dbGoTop()

		aCampos := ("REF1")->(dbStruct())
		AADD(aCampos,{ "REC_101   ", "N", 15, 7 })
		AADD(aCampos,{ "REC_102   ", "N", 15, 7 })
		AADD(aCampos,{ "REC_103   ", "N", 15, 7 })
		T001 := CriaTrab(aCampos, .T.)
		dbUseArea(.T.,, T001, "T001")
		dbCreateInd(T001, "MARCA+TEMPO+VENDEDOR+SEGMENTO+PACOTE+CONTA_REC_", {|| MARCA+TEMPO+VENDEDOR+SEGMENTO+PACOTE+CONTA_REC_ })

		dbSelectArea("REF1")
		dbGoTop()
		ProcRegua(RecCount())
		While !Eof()

			IncProc("Importando arquivo .dbf ...")

			If ( cEmpAnt $ "01" .and. Substr(Alltrim(REF1->MARCA),7,4) $ "0101" ) .or. ( cEmpAnt $ "05" .and. Substr(Alltrim(REF1->MARCA),7,4) $ "0501/0599/1399" )

				dbSelectArea("T001")
				dbSetOrder(1)
				If !dbSeek(REF1->MARCA+REF1->TEMPO+REF1->VENDEDOR+REF1->SEGMENTO+REF1->PACOTE+REF1->CONTA_REC_)
					RecLock("T001",.T.)
					T001->MARCA       := REF1->MARCA     
					T001->TEMPO       := REF1->TEMPO     
					T001->VENDEDOR    := REF1->VENDEDOR  
					T001->SEGMENTO    := REF1->SEGMENTO  
					T001->PACOTE      := REF1->PACOTE    
					T001->CONTA_REC_  := REF1->CONTA_REC_			
				Else
					RecLock("T001",.F.)
				EndIf
				T001->REC_101     += IIF(Alltrim(REF1->IND_RECEIT) == "REC_101", REF1->BPC_SIGNDA, 0)  
				T001->REC_102     += IIF(Alltrim(REF1->IND_RECEIT) == "REC_102", REF1->BPC_SIGNDA, 0)
				T001->REC_103     += IIF(Alltrim(REF1->IND_RECEIT) == "REC_103", REF1->BPC_SIGNDA, 0)
				MsUnLock("T001")

			EndIf

			dbSelectArea("REF1")
			dbSkip()

		End

		REF1->(dbCloseArea())
		Ferase(xcTab+".cdx")          //indice gerado

		dbSelectArea("T001")
		dbGotop()
		dbSetOrder(1)
		ProcRegua(RecCount())
		While !Eof()

			cfChave := T001->MARCA + T001->TEMPO + T001->VENDEDOR
			MS001   := " SELECT MAX(CT_DOC) MAXDOC FROM " + RetSqlName("SCT") + " WHERE CT_FILIAL = '" + xFilial("SCT") + "' AND D_E_L_E_T_ = ' ' "
			MSIndex := CriaTrab(Nil,.f.)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,MS001),'MS01',.T.,.T.)
			dbSelectArea("MS01")
			dbGoTop()
			cfDoc   := Soma1(MS01->MAXDOC)
			cfSeqDc := 0 
			MS01->(dbCloseArea())
			Ferase(MSIndex+GetDBExtension())
			Ferase(MSIndex+OrdBagExt())

			dbSelectArea("T001")
			While !Eof() .and. T001->MARCA + T001->TEMPO + T001->VENDEDOR == cfChave 

				IncProc("Gravando tabela de METAS ...")

				cfSeqDc ++

				If T001->REC_101 <> 0

					RecLock("SCT",.T.)
					SCT->CT_FILIAL  := xFilial("SCT")
					SCT->CT_DESCRI  := 'META DE VENDAS REPRESENTANTE ' + Substr(T001->VENDEDOR,6,6)
					SCT->CT_DOC     := cfDoc
					SCT->CT_VEND    := Substr(T001->VENDEDOR,6,6)
					SCT->CT_GRUPO   := 'PA'
					SCT->CT_VALOR   := T001->REC_103
					SCT->CT_QUANT   := T001->REC_101
					SCT->CT_DATA    := stod(Substr(T001->TEMPO,1,4) + Substr(T001->TEMPO,6,2)+"01")
					SCT->CT_MOEDA   := 1
					SCT->CT_SEQUEN  := StrZero(cfSeqDc,3)
					SCT->CT_YPRCUN  := T001->REC_102
					SCT->CT_YPOSCLI := 0
					SCT->CT_YPACOTE := Substr(T001->PACOTE,5,1)
					SCT->CT_CATEGO  := Substr(T001->SEGMENTO,5,1)
					SCT->CT_PRODUTO := Substr(T001->CONTA_REC_,6,2)
					SCT->CT_YEMP    := Substr(T001->MARCA,7,4)
					SCT->CT_YCLIENT := "999999"
					SCT->CT_YTPCLI  := "C"
					MsUnLock()

				EndIf

				dbSelectArea("T001")
				dbSkip()

			End

			dbSelectArea("T001")

		End

		T001->(dbCloseArea())
		Ferase(T001+OrdBagExt())          //indice gerado

	EndIf

	Aviso( 'Metas...', 'Fim do processamento...', {'Ok'} )

Return

//————————————————————————————————-//
//————————————————————————————————-//
Static Function ChooseFile()

	Local cMaskDir := "Arquivos dBASE (*.dbf) |*.dbf|"
	Local cTitTela := "Arquivo para a integracao"
	Local lInfoOpen := .T.
	Local lDirServidor := .T.
	Local cOldFile := cArquivo

	cArquivo := cGetFile(cMaskDir,cTitTela,,cArquivo,lInfoOpen, (GETF_LOCALHARD+GETF_NETWORKDRIVE) ,lDirServidor)

	If !File(cArquivo)
		MsgStop("Arquivo Não Existe!")
		cArquivo := cOldFile
		Return .F.
	EndIf

Return .T.

//————————————————————————————————-//
//————————————————————————————————-//
Static Function ValidDirect()

	Local lRet := .T.

	If Empty(cArquivo)
		MsgStop("Selecione um arquivo", "Atenção")
		lRet := .F.
	ElseIf !File(cArquivo)
		MsgStop("Selecione um arquivo válido!", "Atenção")
		lRet := .F.
	EndIf

	If nComboBox1 == "0"
		MsgStop("Selecione um Layout válido!", "Atenção")
		lRet := .F.
	EndIf

Return lRet
