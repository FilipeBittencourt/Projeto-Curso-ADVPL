#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BIAFM017
@author Marcelo Sousa Correa - Facile Sistemas
@since 15/03/2019
@version 1.0
@description Tela para importacao da planilha relacionada a prêmio produtividade 
@type function
/*/

User Function BIAFM017()

	Local aSays	   		:= {}
	Local aButtons 		:= {}
	Local lConfirm 		:= .F.
	Private cArquivo	:= space(100)

	If cEmpAnt <> "07" .AND. !MSGYESNO("Empresa Diferente de LM. Deseja continuar?","Empresa Diferente de LM")

		Return

	Else

		fPergunte()

	Endif

	AADD(aSays, OemToAnsi("Rotina para importação dos Prêmios por Produtividade."))
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))
	AADD(aSays, OemToAnsi(""))
	AADD(aSays, OemToAnsi("IMPORTANTE: >>>> TODAS as matrículas constantes neste arquivo terão seus valores"))
	AADD(aSays, OemToAnsi("importados para os lançamentos por funcionário (tabela RGB)!!!"))
	AADD(aSays, OemToAnsi(""))
	AADD(aSays, OemToAnsi("Deseja Continuar?"))

	AADD(aButtons, { 5,.T.,{|| fPergunte() } } )
	AADD(aButtons, { 1,.T.,{|o| lConfirm := .T. , o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( OemToAnsi('Importação dos percentuais...'), aSays, aButtons ,,,500)

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

	Local aPergs 	:= {}
	Local cLoad	    := 'B383IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= SPACE(100)
	MV_PAR01 := space(100)

	aAdd( aPergs ,{6,"Arquivo a ser importado "  					,MV_PAR01  ,"","","", 75 ,.T.,"Arquivos .XLX |*.XLSX",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )

	If ParamBox(aPergs ,"Importar Arquivo",,,,,,,,,.T.,.T.)
		cArquivo  := MV_PAR01
	Endif

Return

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local cTabImp			:= 'RGB'
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local aImport           := {}
	Local aCabec            := {}
	Local a
	Local i2, i

	ProcRegua(0)

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))

	// Gravando período do arquivo e verificando se o mesmo é o ativo no momento
	// cPeriodo := VAL(SUBSTRING(aArquivo[1,3,3],1,4)+SUBSTRING(aArquivo[1,3,3],6,2))+1 // Desativado Pontin - Ticket:
	cPeriodo := AnoMes( MonthSum( StoD( SUBSTRING(aArquivo[1,3,3],1,4) + SUBSTRING(aArquivo[1,3,3],6,2) + "01" ), 1 ) )
	If Len(aArquivo) > 0

		// Acessando tabela de Lançamento por Funcionários
		DBSELECTAREA("RGB")
		RGB->(DBSETORDER(1))

		// Preparando SRA para verificação de matrícula
		DBSELECTAREA("SRA")
		SRA->(DBSETORDER(1))

		For a := 7 to len(aArquivo[1])

			// Acertando Matrículas importadas no arquivo
			aArquivo[1,a,3] := StrZero(Val(aArquivo[1,a,3]),6)

		next a

		For i := 7 to len(aArquivo[1])

			nPremio := 0

			For i2 := 7 to len(aArquivo[1])

				IF aArquivo[1,i,3] == aArquivo[1,i2,3] .AND. aArquivo[1,i2,3] <> '000000'

					nPremio += VAL(aArquivo[1,i2,11])

				ENDIF

			Next i2

			IF SRA->(DBSEEK(XFILIAL()+aArquivo[1,i,3])) .AND. ALLTRIM(DTOS(SRA->RA_DEMISSA)) == '' .AND. RGB->(DBSEEK(XFILIAL()+aArquivo[1,i,3]+'317'+CVALTOCHAR(cPeriodo))) .AND. nPremio <> RGB->RGB_VALOR .AND. !aArquivo[1,i,11] <= '0' .AND. aArquivo[1,i,3] <> '000000'

				RGB->(DBSEEK(XFILIAL()+aArquivo[1,i,3]+'317'+CVALTOCHAR(cPeriodo)))

				RECLOCK("RGB",.F.)

				DBDELETE()

				MSUNLOCK()

				RECLOCK("RGB",.T.)

				RGB_FILIAL := XFILIAL()
				RGB_MAT    := aArquivo[1,i,3]
				RGB_PD     := "317"
				RGB_PERIOD := CVALTOCHAR(cPeriodo)
				RGB_SEMANA := "01"
				RGB_SEQ    := ''
				RGB_CONVOC := ''
				RGB_ROTEIR := "FOL"
				RGB_VALOR  := nPremio
				RGB_PROCES := "00001"
				RGB_CC     := ALLTRIM(SRA->RA_CC)
				RGB_TIPO1  := "V"
				RGB_TIPO2  := "I"
				RGB_CODFUN := ALLTRIM(SRA->RA_CODFUNC)
				RGB_DEPTO  := ALLTRIM(SRA->RA_DEPTO)
				RGB_ITEM   := "GPE000000"
				RGB_CLVL   := ALLTRIM(SRA->RA_CLVL)

				MSUNLOCK()

				aAdd(aImport,{aArquivo[1,i,3],aArquivo[1,i,2],CVALTOCHAR(aArquivo[1,i,11]),"Importado"})

			ELSEIF SRA->(DBSEEK(XFILIAL()+aArquivo[1,i,3])) .AND. ALLTRIM(DTOS(SRA->RA_DEMISSA)) == ''  .AND. nPremio <> RGB->RGB_VALOR .AND. !aArquivo[1,i,11] <= '0' .AND. aArquivo[1,i,3] <> '000000'

				RECLOCK("RGB",.T.)

				RGB_FILIAL := XFILIAL()
				RGB_MAT    := aArquivo[1,i,3]
				RGB_PD     := "317"
				RGB_PERIOD := CVALTOCHAR(cPeriodo)
				RGB_SEMANA := "01"
				RGB_SEQ    := ''
				RGB_CONVOC := ''
				RGB_ROTEIR := "FOL"
				RGB_VALOR  := nPremio
				RGB_PROCES := "00001"
				RGB_CC     := ALLTRIM(SRA->RA_CC)
				RGB_TIPO1  := "V"
				RGB_TIPO2  := "I"
				RGB_CODFUN := ALLTRIM(SRA->RA_CODFUNC)
				RGB_DEPTO  := ALLTRIM(SRA->RA_DEPTO)
				RGB_ITEM   := "GPE000000"
				RGB_CLVL   := ALLTRIM(SRA->RA_CLVL)

				MSUNLOCK()

				aAdd(aImport,{aArquivo[1,i,3],aArquivo[1,i,2],CVALTOCHAR(aArquivo[1,i,11]),"Importado"})

			ELSE

				IF ALLTRIM(DTOS(SRA->RA_DEMISSA)) <> ''

					aAdd(aImport,{aArquivo[1,i,3],aArquivo[1,i,2],CVALTOCHAR(aArquivo[1,i,11]),"Funcionario em situação demitido"})

				ELSEIF !(SRA->(DBSEEK(XFILIAL()+aArquivo[1,i,3])))

					aAdd(aImport,{aArquivo[1,i,3],aArquivo[1,i,2],CVALTOCHAR(aArquivo[1,i,11]),"Funcionario nao encontrado na empresa"})

				ELSEIF nPremio == RGB->RGB_VALOR .AND. SRA->(DBSEEK(XFILIAL()+aArquivo[1,i,3])) .AND. !(aArquivo[1,i,11] <= '0')

					aAdd(aImport,{aArquivo[1,i,3],aArquivo[1,i,2],CVALTOCHAR(aArquivo[1,i,11]),"Funcionario já foi importado"})

				ELSEIF aArquivo[1,i,11] <= '0' .AND. SRA->(DBSEEK(XFILIAL()+aArquivo[1,i,3]))

					aAdd(aImport,{aArquivo[1,i,3],aArquivo[1,i,2],CVALTOCHAR(aArquivo[1,i,11]),"Funcionario sem valor a receber"})

				ENDIF

			ENDIF

		next i

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
	nxTabl := "Importação Premio Produtividade"

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