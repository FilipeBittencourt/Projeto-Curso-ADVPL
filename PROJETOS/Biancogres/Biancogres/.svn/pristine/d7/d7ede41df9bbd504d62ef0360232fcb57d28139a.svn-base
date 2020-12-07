#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} TBiaArquivo
@author Artur Antunes
@since 17/03/2017
@version 1.0
@description Classe Generica para manipulação de arquivos EXCEL (leitura, conversão, etc...)
@obs OS: 4704-16 
@type Class
/*/

Class TBiaArquivo from LongClassName

	Method New() Constructor
	Method ConverteArq(_cArquivo,_cFormDest,_lTemp)  // Converte arquivos compativeis com Excel              
	Method GetArquivo(_cArquivo)		  			 // Retorna Arreio com a leitura do arquivo formato XML Excel
EndClass

Method New() Class TBiaArquivo

Return

Method ConverteArq(_cArquivo,_lTemp,_cFormDest) Class TBiaArquivo

	// _cArquivo  = Endereço completo do arquivo a ser convertido
	// _lTemp	  = Define se o arquivo convertido será gerado na pasta de temporarios e o original mantido
	// _cFormDest = Formato para a conversão do arquivo

	Local nHandler 		:= 0
	Local cVbs 			:= ''
	Local cDrive 		:= ''
	Local cDir   		:= ''
	Local cNome  		:= ''
	Local cExt   		:= '' 
	local cArqVbs 		:= '' 
	local cTipoConv		:= ''
	local cArqDest 		:= '' 
	local lContinua 	:= .F.    
	default _cArquivo 	:= ''
	default _cFormDest	:= 'XML'
	default _lTemp	 	:= .F.

	_cArquivo := Alltrim(_cArquivo)

	do case
		case UPPER(Alltrim(_cFormDest)) = 'XML'
		cTipoConv := '46'
		case UPPER(Alltrim(_cFormDest)) = 'CSV'
		cTipoConv := '6'
		case UPPER(Alltrim(_cFormDest)) = 'XLSX'
		cTipoConv := '51'
		case UPPER(Alltrim(_cFormDest)) = 'XLS'
		cTipoConv := '43'
		case UPPER(Alltrim(_cFormDest)) = 'PDF'
		cTipoConv := '3'
		otherwise
		cTipoConv := '46'
	endcase

	if !empty(_cArquivo) .and. ApOleClient('MsExcel') 
		lContinua := .T.
		SplitPath(_cArquivo,@cDrive,@cDir,@cNome,@cExt)
		if _lTemp
			cArqDest := AllTrim(GetTempPath())+cNome+"."+_cFormDest
		else
			cArqDest := cDrive+cDir+cNome+"."+_cFormDest
		endif	
		cArqVbs := AllTrim(GetTempPath())+cNome+".vbs"
	endif

	if UPPER(Alltrim(_cFormDest)) <> UPPER(Alltrim(cExt))

		if File(cArqDest)
			FErase(cArqDest)
		endif

		cVbs := 'Dim objXLApp, objXLWb '+CRLF
		cVbs += 'Set objXLApp = CreateObject("Excel.Application") '+CRLF
		cVbs += 'objXLApp.DisplayAlerts = False '+CRLF
		cVbs += 'objXLApp.Visible = False '+CRLF
		cVbs += 'Set objXLWb = objXLApp.Workbooks.Open("'+_cArquivo+'") '+CRLF
		cVbs += 'objXLWb.SaveAs "'+cArqDest+'", '+cTipoConv+' '+CRLF
		cVbs += 'objXLWb.Close (true) '+CRLF
		cVbs += 'Set objXLWb = Nothing '+CRLF
		cVbs += 'objXLApp.Quit '+CRLF
		cVbs += 'Set objXLApp = Nothing '+CRLF
		if lContinua
			nHandler := FCreate(cArqVbs)
			If nHandler <> -1 
				FWrite(nHandler, cVbs)
				FClose(nHandler)                                   
				if WaitRun('cscript.exe '+cArqVbs,0) == 0 
					if file(cArqDest)
						if file(_cArquivo) .and. !_lTemp
							FErase(_cArquivo)
						endif
						if file(cArqVbs)
							//FErase(cArqVbs)
						endif
					else
						lContinua := .F.
					endif
				else
					lContinua := .F.
				endif
			else
				lContinua := .F.	  	 
			endif
		endif 
		if !lContinua
			if file(cArqDest)
				FErase(cArqDest)
			endif
			if file(cArqVbs)
				FErase(cArqVbs)
			endif
		endif
	else
		cArqDest := _cArquivo
	endif	

Return {lContinua,cArqDest}

Method GetArquivo(_cArquivo) Class TBiaArquivo

	// _cArquivo  = Endereço completo do arquivo a ser lido
	local aRetTemp	  := {}
	local cArqDest	  := ''
	local cBuffer	  := ''
	local aLinha	  := {}
	local aPlanilha	  := {}
	local aTempLin	  := {}
	local nc		  := 0
	local nAvanCol	  := 0
	local cTemp		  := ''
	local cTemp2	  := ''
	local cCelula	  := ''	
	local nTamCab 	  := 0
	default _cArquivo := ''

	aRetTemp  := ::ConverteArq(_cArquivo,.T.)

	if aRetTemp[1]

		cArqDest := aRetTemp[2]

		if File(cArqDest)

			nHandle := FT_FUSE(cArqDest) //ABRIR o arquivo como .txt

			if nHandle <> -1 

				msqContad := 0
				FT_FGOTOP()
				While !FT_FEOF()

					cBuffer := Alltrim(FT_FREADLN())
					msqContad ++

					// Por Marcos...
					If msqContad == 4769
						sdfsdf := 1
					EndIf 

					if UPPER('<Cell') $ UPPER(cBuffer)

						cCelula += cBuffer

						if UPPER('<Cell') $ UPPER(cCelula) //.and. UPPER('</Cell>') $ UPPER(cCelula)

							// Por Marcos... 
							If UPPER('</Cell>') $ UPPER(cCelula)
								xfrFim := .T.
								While !FT_FEOF() .and. xfrFim 
									If UPPER('</Cell>') $ UPPER(cCelula)
										xfrFim := .F.
									Else
										FT_FSKIP()
										cBuffer := Alltrim(FT_FREADLN())
										msqContad ++
										cCelula += cBuffer
									EndIf
								End
							EndIf

							If UPPER(':Index=') $ UPPER(cCelula)

								cTemp2 := '' 
								cTemp := SubStr(cCelula,AT(UPPER(':Index='),UPPER(cCelula))+7)
								cTemp := SubStr(cTemp,1,5)
								for nc := 1 to len(cTemp)
									if SubStr(cTemp,nc,1) $ '0123456789'
										cTemp2 += SubStr(cTemp,nc,1) 
									endif
								next nc
								nAvanCol := val(cTemp2)
								nAvanCol := nAvanCol - len(aLinha) - 1
								for nc := 1 to nAvanCol
									AADD(aLinha,'')
								next nc

							EndIf

							// Por Marcos... 
							If UPPER('<Data') $ UPPER(cCelula)
								xfrFim := .T.
								While !FT_FEOF() .and. xfrFim 
									If UPPER('</Data') $ UPPER(cCelula)
										xfrFim := .F.
									Else
										FT_FSKIP()
										cBuffer := Alltrim(FT_FREADLN())
										msqContad ++
										cCelula += " " + cBuffer
									EndIf
								End
							EndIf

							cCelula   := SubStr(cCelula,AT(UPPER('<Data'),UPPER(cCelula))+5)
							cCelula   := SubStr(cCelula,1,RAT('</Data',cCelula)-1)
							cCelula   := SubStr(cCelula,AT('>',cCelula)+1)

							AADD(aLinha,cCelula)
							cCelula := ''

						endif

					endif	

					If UPPER('</Row') $ UPPER(cBuffer) .AND. Len(aLinha) > 0

						If len(aTempLin) == 0
							nTamCab := len(aLinha)
						EndIf

						If nTamCab > len(aLinha)
							nAvanCol := nTamCab - len(aLinha)
							for nc := 1 to nAvanCol
								AADD(aLinha,'')
							next nc    				
						EndIf

						AADD(aTempLin,aLinha)
						aLinha  := {}

					EndIf	

					If UPPER("</Worksheet") $ UPPER(cBuffer) .AND. Len(aTempLin) > 0
						AADD(aPlanilha,aTempLin)
						aTempLin := {}
					EndIf

					FT_FSKIP() 

				EndDo

				FT_FUSE() 

			EndIf  

		EndIf

	EndIf

Return aPlanilha
