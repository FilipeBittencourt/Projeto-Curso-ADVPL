#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFM018
@author Marcelo Sousa Correa - Facile Sistemas
@since 20/03/2019
@version 1.0
@description Tela para importacao da planilha relacionada a PLR anual. 
@type function
/*/

User Function BIAFM018()

	Local aSays	   		:= {}
	Local aButtons 		:= {}
	Local lConfirm 		:= .F.
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação de valores para a RGB."))
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))
	AADD(aSays, OemToAnsi(""))
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> TODAS as matrículas constantes neste arquivo terão seus valores"))
	AADD(aSays, OemToAnsi("importados para os lançamentos por funcionário (tabela RGB)!!!"))
	AADD(aSays, OemToAnsi(""))
	AADD(aSays, OemToAnsi("Deseja Continuar?"))

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação dos dados...'), aSays, aButtons ,,,500)

	If lConfirm

		If !empty(cArquivo) .and. File(cArquivo)
			Processa({ || fProcImport() },"Aguarde...","Carregando Arquivo...",.F.)
		Else
			MsgStop('Informe o arquivo valido para importação!')
		EndIf

	EndIf

Return

//Parametros
Static Function fPergunte()

	Local aPergs 		:= {}
	Local cLoad	    := 'B383IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo				:= SPACE(100)
	cPeriodo        := space(6)
	cRoteiro        := space(3)
	cVerba        	:= space(3)
	MV_PAR01 				:= space(100)
	MV_PAR02 				:= space(6)
	MV_PAR03 				:= space(3)
	MV_PAR04 				:= space(3)

	aAdd( aPergs ,{6,"Arquivo a ser importado "  					,MV_PAR01  ,"","",""   , 75 ,.T.,"Arquivos .XLX |*.XLSX",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )
	aAdd( aPergs ,{1,"Período " 	  				                ,MV_PAR02  ,"","",'RCHPLR',''  ,6  ,.F.})
	aAdd( aPergs ,{1,"Roteiro " 	  				                ,MV_PAR03  ,"","",'SRY',''  ,3  ,.F.})
	aAdd( aPergs ,{1,"Verba a ser Gerada "	                ,MV_PAR04  ,"","",'SRV',''  ,3  ,.F.})

	If ParamBox(aPergs ,"Parametros",,,,,,,,,.T.,.T.)
		cArquivo  := MV_PAR01
		cPeriodo  := MV_PAR02
		cRoteiro  := PadR(AllTrim(MV_PAR03),TamSX3("RGB_ROTEIR")[1])
		cVerba  	:= PadR(AllTrim(MV_PAR04),TamSX3("RGB_PD")[1])
	Endif

Return

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 		:= nil
	Local aArquivo 		:= {}
	Local aWorksheet 	:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'RGB'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo		:= ''
	Local nTotLin			:= 0
	Local aImport     := {}
	Local aCabec      := {}
	Local i

	ProcRegua(0)

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	If Len(aArquivo) > 0

		msTpLin   := Alltrim( Str( ( ( Val( Substr(msTmpRead,1,2)) * 3600 ) + ( Val(Substr(msTmpRead,4,2)) * 360 ) + ( Val(Substr(msTmpRead,7,2)) ) ) / Len(aArquivo[1]) ) )

		nTotLin		:= len(aArquivo[1])

		nMat 			:= getpos(aArquivo,"MATRICULA")
		nVal 			:= getpos(aArquivo,"VALOR")
		cNome 		:= getpos(aArquivo,"NOME")
		cPeriodo 	:= MV_PAR02
		cRoteiro	:= PadR(AllTrim(MV_PAR03),TamSX3("RGB_ROTEIR")[1])
		cVerba		:= PadR(AllTrim(MV_PAR04),TamSX3("RGB_PD")[1])

		//|Valida campos chaves |
		If Empty(cRoteiro) .Or. Empty(cVerba)
			MsgStop("Necessário informar o roteiro e a verba a ser gerada!",FunName())
			Return
		EndIf

		// Acessando tabela de Lançamento por Funcionários
		DBSELECTAREA("RGB")
		RGB->(DBSETORDER(1))

		// Preparando SRA para verificação de matrícula
		DBSELECTAREA("SRA")
		SRA->(DBSETORDER(1))

		For i := 2 to len(aArquivo[1])

			// Acertando Matrículas importadas no arquivo
			aArquivo[1,i,nMat] := StrZero(Val(aArquivo[1,i,nMat]),6)

			IF SRA->(DBSEEK(XFILIAL()+aArquivo[1,i,nMat])) .AND. RGB->(DBSEEK(XFILIAL()+aArquivo[1,i,nMat]+cVerba+cPeriodo)) .AND. !aArquivo[1,i,nVal] <= '0'

				IF Empty(SRA->RA_DEMISSA) .AND. SRA->RA_SITFOLH <> 'D'
					RGB->(DBSEEK(XFILIAL()+aArquivo[1,i,nMat]+cVerba+cPeriodo))

					RECLOCK("RGB",.F.)

					DBDELETE()

					MSUNLOCK()

					RECLOCK("RGB",.T.)

					RGB_FILIAL := XFILIAL()
					RGB_MAT    := aArquivo[1,i,nMat]
					RGB_PD     := cVerba
					RGB_PERIOD := cPeriodo
					RGB_SEMANA := "01"
					RGB_SEQ    := ''
					RGB_CONVOC := ''
					RGB_ROTEIR := cRoteiro
					RGB_VALOR  := VAL(aArquivo[1,i,nVal])
					RGB_PROCES := SRA->RA_PROCES
					RGB_CC     := ALLTRIM(SRA->RA_CC)
					RGB_TIPO1  := "V"
					RGB_TIPO2  := "I"
					RGB_CODFUN := ALLTRIM(SRA->RA_CODFUNC)
					RGB_DEPTO  := ALLTRIM(SRA->RA_DEPTO)
					RGB_ITEM   := "GPE000000"
					RGB_CLVL   := ALLTRIM(SRA->RA_CLVL)

					RGB->(MSUNLOCK())

					aAdd(aImport,{aArquivo[1,i,nMat],aArquivo[1,i,cNome],CVALTOCHAR(aArquivo[1,i,nVal]),"Importado"})
				END IF

			ELSEIF SRA->(DBSEEK(XFILIAL()+aArquivo[1,i,nMat])) .AND. !aArquivo[1,i,nVal] <= '0'

				If Empty(SRA->RA_DEMISSA) .AND. SRA->RA_SITFOLH <> 'D'
					RECLOCK("RGB",.T.)

					RGB_FILIAL := XFILIAL()
					RGB_MAT    := aArquivo[1,i,nMat]
					RGB_PD     := cVerba
					RGB_PERIOD := cPeriodo
					RGB_SEMANA := "01"
					RGB_SEQ    := ''
					RGB_CONVOC := ''
					RGB_ROTEIR := cRoteiro
					RGB_VALOR  := VAL(aArquivo[1,i,nVal])
					RGB_PROCES := SRA->RA_PROCES
					RGB_CC     := ALLTRIM(SRA->RA_CC)
					RGB_TIPO1  := "V"
					RGB_TIPO2  := "I"
					RGB_CODFUN := ALLTRIM(SRA->RA_CODFUNC)
					RGB_DEPTO  := ALLTRIM(SRA->RA_DEPTO)
					RGB_ITEM   := "GPE000000"
					RGB_CLVL   := ALLTRIM(SRA->RA_CLVL)

					RGB->(MSUNLOCK())

					aAdd(aImport,{aArquivo[1,i,nMat],aArquivo[1,i,cNome],CVALTOCHAR(aArquivo[1,i,nVal]),"Importado"})

				EndIf

			ELSE

				IF aArquivo[1,i,nVal] <= '0' .AND. aArquivo[1,i,nMat] <> '000000'

					aAdd(aImport,{aArquivo[1,i,nMat],aArquivo[1,i,cNome],CVALTOCHAR(aArquivo[1,i,nVal]),"Funcionario sem valor a receber"})

				ELSEIF aArquivo[1,i,nMat] <> '000000'

					aAdd(aImport,{aArquivo[1,i,nMat],aArquivo[1,i,cNome],CVALTOCHAR(aArquivo[1,i,nVal]),"Funcionario nao encontrado na empresa"})

				ENDIF

			ENDIF

		Next i

		ProcRegua(nTotLin)

		geraexcel(aImport)

	EndIf

	RestArea(aArea)

Return


Static Function geraexcel(aImport)

	Local i

	// Abertura de Planilha 
	oExcel := FWMSEXCEL():New()

	nxPlan := "Importados"
	nxTabl := "Importação Verbas"

	oExcel:AddworkSheet(nxPlan)
	oExcel:AddTable (nxPlan, nxTabl)
	oExcel:AddColumn(nxPlan, nxTabl, "Matricula"          ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Nome"               ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Valor"              ,1,1)
	oExcel:AddColumn(nxPlan, nxTabl, "Importado?"          ,1,1)

	// Dados da planilha 		

	For i := 1 To Len(aImport)

		oExcel:AddRow(nxPlan, nxTabl,{aImport[i,1],aImport[i,2],ROUND(VAL(aImport[i,3]),2),aImport[i,4]})

	Next i



	// Fechamento e geração de planilha 	
	cDir := ("c:\temp\importado"+ DTOS(DATE()) +".xml")

	If File(cDir)
		If fErase(cDir) == -1
			Aviso('Arquivo em uso', 'Favor fechar o arquivo: ' + cDir + ' antes de prosseguir!!!',{'Ok'})
		EndIf
	EndIf

	oExcel:Activate()
	oExcel:GetXMLFile(cDir)
	oExcel := FWMsExcel():DeActivate()

	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cDir) // Abre uma planilha
	oExcelApp:SetVisible(.T.)

Return

Static Function getpos(aArray,cCampo)

	Local nx := 0

	IF aArray[1,1] <> NIL

		FOR nx := 1 to len(aArray[1][1])

			IF ALLTRIM(aArray[1,1,nx]) $ ALLTRIM(cCampo)

				Return nx

			ENDIF

		NEXT nx

	ENDIF

Return 0