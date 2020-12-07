#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFM018
@author Marcelo Sousa Correa - Facile Sistemas
@since 20/03/2019
@version 1.0
@description Tela para importacao da planilha relacionada a PLR anual. 
@type function
/*/

User Function BIAFM022()

	Local aSays	   		:= {} 
	Local aButtons 		:= {}  
	Local lConfirm 		:= .F. 
	Private cArquivo	:= space(100)

	fPergunte()

	AADD(aSays, OemToAnsi("Rotina para importação dos dados de geração do ECF."))   
	AADD(aSays, OemToAnsi("Antes de continuar, verifique os parâmetros!"))   
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

	MsgInfo('Importação finalizada com sucesso!')

Return

//Parametros
Static Function fPergunte()

	Local aPergs 	:= {}
	Local cLoad	    := 'BM022IEXC' + cEmpAnt
	Local cFileName := RetCodUsr() +"_"+ cLoad
	cArquivo		:= SPACE(100)
	cBloco          := space(1) 
	MV_PAR01 := space(100)
	MV_PAR02 := space(6)
	aOpcs 	:= {"1=Y600","2=Y520","3=X450"}

	aAdd( aPergs ,{6,"Arquivo a ser importado ",MV_PAR01  ,"","",""   , 75 ,.T.,"Arquivos .XLX |*.XLSX",,GETF_LOCALHARD+GETF_NETWORKDRIVE} )
	aAdd( aPergs ,{2,"Bloco a ser importado ","1",aOpcs,60,'.T.',.F.})	

	If ParamBox(aPergs ,"Parametros ECF",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		cArquivo := ALLTRIM(ParamLoad(cFileName,,1,MV_PAR01))
		cBloco := ALLTRIM(ParamLoad(cFileName,,2,MV_PAR02))

	EndIf

Return 

//Processa importação
Static Function fProcImport()

	Local aArea 			:= GetArea()
	Local oArquivo 			:= nil
	Local aArquivo 			:= {}
	Local aWorksheet 		:= {}
	Local aCampos			:= {}
	Local cTemp 			:= ''
	Local aItem 			:= {}
	Local aLinha			:= {}
	Local aErro				:= {}
	Local cErro 			:= ''
	Local nImport			:= 0
	Local cConteudo			:= ''
	Local nTotLin			:= 0
	Local aImport           := {}
	Local aCabec            := {}

	ProcRegua(0) 

	msTmpINI := Time()
	oArquivo := TBiaArquivo():New()
	aArquivo := oArquivo:GetArquivo(cArquivo)

	msDtProc  := Date()
	msHrProc  := Time()
	msTmpRead := Alltrim(ElapTime(msTmpINI, msHrProc))


	If Len(aArquivo) > 0 

		nTotLin		:= len(aArquivo[1])

		// Gerando registros nas tabelas envolvidas
		gerabloco(aArquivo)

		ProcRegua(nTotLin)
	Else
		MsgStop('Arquivo vazio ou com espacos no nome. Favor verificar!')	
	EndIf

	RestArea(aArea)

Return

Static Function getpos(aArray,cCampo,pos)

	Local nx := 0 

	IF aArray[pos,1] <> NIL

		FOR nx := 1 to len(aArray[pos][1])

			IF ALLTRIM(aArray[pos,1,nx]) $ ALLTRIM(cCampo)	

				Return nx

			ENDIF

		NEXT nx

	ENDIF

Return 0

Static Function getplan(aArray)

	Local nx := 0 
	Local cCampo := "PERIODO"
	Local na

	nTab := Len(aArray)

	IF aArray[nTab,1] <> NIL

		FOR nx := 1 to nTab

			aTab := Len(aArray[nx,1])

			FOR na := 1 to aTab

				IF ALLTRIM(aArray[nx,1,na]) $ cCampo	

					Return nx

				ENDIF

			nEXT na

		NEXT nx

	ENDIF

Return 0

Static Function gerabloco(aArquivo)

	Local I

	cBloco := MV_PAR02

	pos := getplan(aArquivo)

	If cBloco == '1' //Se foi escolhido Y600, irá posicionar na tabela CGM

		PERIOD := getpos(aArquivo,"PERIODO",pos)
		INCSOC := getpos(aArquivo,"INCSOC",pos)
		FIMSOC := getpos(aArquivo,"FIMSOC",pos)
		PAIS   := "000001"
		QUASOC := getpos(aArquivo,"1=CPF/2=CNPJ",pos)
		CPFCNP := getpos(aArquivo,"NUMCPFCNP",pos)
		NOMEMP := getpos(aArquivo,"NOME",pos)
		PERTOT := getpos(aArquivo,"PERCTOT",pos)
		PERVOT := getpos(aArquivo,"PERCVOT",pos)
		CPFLEG := getpos(aArquivo,"CPFLEG",pos)
		QUALEG := getpos(aArquivo,"QUALEG",pos)
		VLRMTR := "0"
		VLLCDV := getpos(aArquivo,"VLDIV",pos)
		JURCAP := getpos(aArquivo,"JURCAP",pos)
		VLDMRD := "0"
		VLIRRT := getpos(aArquivo,"VALIR",pos)

		DBSELECTAREA("CGM")
		CGM->(DBSETORDER(2))

		//Deleta os registros 
		cDel := ""
		cDel += " DELETE FROM " + RetSqlName("CGM")
		cDel += " WHERE CGM_PERIOD = " + STRTRAN(SUBSTR(aArquivo[pos,2,PERIOD],1,10),"-",)

		TcSQLExec(cDel)
		//

		For I=2 To Len(aArquivo[pos])

			RecLock("CGM",.T.)

			CGM->CGM_FILIAL := xFilial("CGM")
			CGM->CGM_ID     := TAFGeraID("TAF")
			CGM->CGM_PERIOD := STOD(STRTRAN(SUBSTR(aArquivo[pos,i,PERIOD],1,10),"-",))
			CGM->CGM_INCSOC := STOD(STRTRAN(SUBSTR(aArquivo[pos,i,INCSOC],1,10),"-",))
			CGM->CGM_FIMSOC := STOD(STRTRAN(SUBSTR(aArquivo[pos,i,FIMSOC],1,10),"-",))
			CGM->CGM_PAIS   := "000001"
			CGM->CGM_QUASOC := aArquivo[pos,i,QUASOC]
			CGM->CGM_CPFCNP := aArquivo[pos,i,CPFCNP]
			CGM->CGM_NOMEMP := aArquivo[pos,i,NOMEMP]
			CGM->CGM_PERTOT := Val(aArquivo[pos,i,PERTOT])
			CGM->CGM_PERVOT := Val(aArquivo[pos,i,PERVOT])
			CGM->CGM_CPFLEG := aArquivo[pos,i,CPFLEG]
			CGM->CGM_QUALEG := aArquivo[pos,i,QUALEG]
			CGM->CGM_VLRMTR := VAL(VLRMTR)
			CGM->CGM_VLLCDV := Val(aArquivo[pos,i,VLLCDV])
			CGM->CGM_JURCAP := Val(aArquivo[pos,i,JURCAP])
			CGM->CGM_VLDMRD := Val(VLDMRD)
			CGM->CGM_VLIRRT := Val(aArquivo[pos,i,VLIRRT])

			MsUnlock()	

		Next I

	ElseIf cBloco == '2' //Se foi escolhido Y520, irá posicionar na tabela CFQ

		PERIOD := getpos(aArquivo,"PERIODO",pos)
		TIPO   := getpos(aArquivo,"1=RENDIMENTO/2=PAGAMENTO",pos)
		RECEB  := getpos(aArquivo,"1=CAMBIO/2=TRANSF/3=CARTAO/4=DEPOS/5=RECEXT/6=MOEDA",pos)
		NATOP  := getpos(aArquivo,"NATOP",pos)
		VALPER := getpos(aArquivo,"VALPER",pos)

		DBSELECTAREA("CFQ")
		CFQ->(DBSETORDER(2))

		//Deleta os registros 
		cDel := ""
		cDel += " DELETE FROM " + RetSqlName("CFQ")
		cDel += " WHERE CFQ_PERIOD LIKE '" + STRTRAN(SUBSTR(aArquivo[pos,2,PERIOD],1,4),"-",) + "%' "

		TcSQLExec(cDel)
		//

		For I=2 To Len(aArquivo[pos])

			// Posiciona C1N para buscar ID da natureza
			DBSELECTAREA("C1N")
			C1N->(DBSETORDER(1))
			C1N->(DbSeek(xFilial("CFQ")+ALLTRIM(aArquivo[pos,i,NATOP])))

			RecLock("CFQ",.T.)

			CFQ->CFQ_FILIAL := xFilial("CFQ") 
			CFQ->CFQ_ID     := TAFGeraID("TAF")
			CFQ->CFQ_PERIOD := STOD(STRTRAN(SUBSTR(aArquivo[pos,i,PERIOD],1,10),"-",)) 
			CFQ->CFQ_TIPEXT := aArquivo[pos,i,TIPO]
			CFQ->CFQ_PAIS   := "000001"
			CFQ->CFQ_FORMA  := aArquivo[pos,i,RECEB]
			CFQ->CFQ_NATOPE := ALLTRIM(C1N->C1N_ID)
			CFQ->CFQ_VLPERI := VAL(aArquivo[pos,i,VALPER])

			MsUnlock()	

		Next I

	ElseIf cBloco == '3' //Se foi escolhido X450, irá posicionar na tabela CG5

		PERIOD := getpos(aArquivo,"PERIODO",pos)
		VLJPJ   := getpos(aArquivo,"VLJPJ",pos)
		VLDJUR  := getpos(aArquivo,"VLDJUR",pos)
		DIVIPJ  := getpos(aArquivo,"DIVIPJ",pos)

		DBSELECTAREA("CG5")
		CG5->(DBSETORDER(2))

		//Deleta os registros 
		cDel := ""
		cDel += " DELETE FROM " + RetSqlName("CG5")
		cDel += " WHERE CG5_PERIOD LIKE '" + STRTRAN(SUBSTR(aArquivo[pos,2,PERIOD],1,4),"-",) + "%' "

		TcSQLExec(cDel)
		//

		For I=2 To Len(aArquivo[pos])

			RecLock("CG5",.T.)

			CG5->CG5_FILIAL := xFilial("CG5") 
			CG5->CG5_ID     := TAFGeraID("TAF")
			CG5->CG5_PERIOD := STOD(STRTRAN(SUBSTR(aArquivo[pos,i,PERIOD],1,10),"-",)) 
			CG5->CG5_PAIS   := "000001"
			CG5->CG5_VLJPJ  := VAL(aArquivo[pos,i,VLJPJ])
			CG5->CG5_VLDJUR := VAL(aArquivo[pos,i,VLDJUR])
			CG5->CG5_DIVIPJ := VAL(aArquivo[pos,i,DIVIPJ])

			MsUnlock()	

		Next I	
	Endif

Return 