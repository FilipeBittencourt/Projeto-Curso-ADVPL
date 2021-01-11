#Include "PROTHEUS.CH"
#Include "TOTVS.CH"

User Function TPSLOTE()
	
	Local oDlg		:= Nil
	Local oRadio	:= Nil
	Local nRadio	:= Nil
	Local nOpca 	:= 1
		
	DEFINE MSDIALOG oDlg FROM  94,1 TO 650,293 TITLE "Parâmetros Sugestão de Lote" PIXEL

	@ 05,17 Say "Parametro:" SIZE 150,7 OF oDlg PIXEL

	@ 17,07 TO 250, 140 OF oDlg  PIXEL

	@ 25,10 Radio 	oRadio VAR nRadio;
	ITEMS 	"% Quantidade Inferior",;
	"% Quantidade Superior",;
	"Prioridade",;
	"Tolerãncia Maxima",;
	"Prazo Maximo Engenharia",;
	"UF Lotes <> 'F35'";
	SIZE 150,10 OF oDlg PIXEL

	DEFINE SBUTTON FROM 255,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
	DEFINE SBUTTON FROM 255,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)
	
	If nOpca == 1

		EditParam(nRadio)
		
	EndIf		
	
Return 

Static Function EditParam(nRadio)

	Local oDlg			:= Nil
	Local oButOk		:= Nil		
	Local oButCan		:= Nil
	Local lOk			:= .F.
	Local oValor		:= Nil
	
	Local aListParam:= {;
	 {'MV_YSLTMIN', '% Quantidade Inferior'},;
	 {'MV_YSLTMAX', '% Quantidade Superior'},;
     {'MV_YSLTPRI', 'Prioridade'},;
     {'MV_YSLTTMA', 'Tolerãncia Maxima'},;
     {'FA_PRAZOM', 'Prazo Maximo Engenharia'},;
     {'FA_UFLF35', 'UF Lotes <> "F35"'};
	 }
	 
	 
	Local cParam 		:= aListParam[nRadio][1] 
	Local cParamNome	:= aListParam[nRadio][2] 
	Local cValor 		:= ""
	Local cDescricao	:= ""
	
	
	DbSelectArea("SX6")
	SX6->(DbSetOrder(1)) 
	If SX6->(DbSeek(xFilial("SX6")+cParam)) 
		cDescricao	:= SX6->X6_DESCRIC
		cValor		:= SX6->X6_CONTEUD 
		If (SX6->X6_TIPO == 'N')
			cValor		:= val(cValor)
		EndIf
	EndIf		
	
	
	If (!Empty(cValor))
		
		
		DEFINE MSDIALOG oDlg FROM 050,100 TO 175,430 TITLE OemToAnsi("Alteração do Parâmetro") PIXEL
		
		@ 005,002 TO 045,165 LABEL cParamNome OF oDlg PIXEL
		@ 015,006 Say cDescricao SIZE 150,8 OF oDlg PIXEL
		
		@ 025,005 MSGET oValor VAR cValor SIZE 060,010 Of oDlg PIXEL
		
		
		@ 048,070 BUTTON oButOk PROMPT ("&Ok") SIZE 044,012 Of oDlg PIXEl Action (lOk := .T. , oDlg:End() )
		@ 048,120 BUTTON oButCan PROMPT ("&Cancela") SIZE 044,012 Of oDlg PIXEl Action (lOk := .F. , oDlg:End() )
		
		ACTIVATE MSDIALOG oDlg
		
		If lOk
			If (!Empty(cValor))
				PutMVEmp(cParam, cValor)
				MsgAlert('Alteração do parâmetro realizada com sucesso.', '')
				Return
			Else
				MsgAlert('Erro na alteração do parâmetro.', '')
			EndIf
		EndIf
		
	Else
		MsgAlert('Erro na alteração do parâmetro.', '')
	EndIf
	
					
Return 

Static Function PutMVEmp(_cParam, _cValor)
	Local nI		:= 0
	Local aList		:= {{'01', '01'}, {'05', '01'}, {'07', '01'}, {'07', '05'}, {'13', '01'}}
	For nI := 1 to Len(aList)
		If (cEmpAnt+cFilAnt == aList[nI, 1]+aList[nI, 2])
			PutMV(_cParam, _cValor)
		Else
			Processa( {|| StartJob("U_TPSLOTEE", GetEnvServer(), .T., aList[nI, 1], aList[nI, 2], _cParam, _cValor)}, "Empresa: ("+aList[nI, 1]+"/"+aList[nI, 2]+")", "Processando Parâmetros Sugestão de Lote...", .T.)
		EndIf
	Next nI
Return

User Function TPSLOTEE(_cEmp, _cFil, _cParam, _cValor)
	
	RpcSetEnv(_cEmp, _cFil)
		PutMV(_cParam, _cValor)
	RpcClearEnv()
	
Return


	

