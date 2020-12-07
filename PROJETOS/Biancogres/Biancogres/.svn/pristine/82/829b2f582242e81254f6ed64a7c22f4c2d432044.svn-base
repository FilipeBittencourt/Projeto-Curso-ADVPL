#include "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "tbiconn.ch"


User Function CAD_FERI()
	
	Local aArea			:= GetArea()
	Local cFiltro		:= ""
	Private cCadastro	:= "Cadastro de Feriados"
	Private aRotina		:= { }

	AADD(aRotina, { "Pesquisar"		, "AxPesqui"	, 0, 1 })
	AADD(aRotina, { "Visualizar"	, "AxVisual"	, 0, 2 })
	AADD(aRotina, { "Incluir"		, "U_CADFERI1(3)"	, 0, 3 })
	AADD(aRotina, { "Manutenção"	, "U_CADFERI1(4)"	, 0, 4 })
	///AADD(aRotina, { "Excluir"		, "AxDeleta"	, 0, 5 })

	
	aCores :=   {{'LEN(AllTrim(SUBSTR(SX5->X5_DESCRI, 0, 8))) == 8', 'GREEN'},;        
	 {'LEN(AllTrim(SUBSTR(SX5->X5_DESCRI, 0, 8))) == 5' , 'YELLOW' };        
	 }
	 
		DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	
	cFiltro := " X5_TABELA = '63' "
		
	MBrowse(6, 1, 22, 75, "SX5",,,,,, aCores,,,,,,,,cFiltro)
	
	RestArea(aArea)
	
Return

User Function CADFERI1(nOpc)
	
	Private oWindow			:= Nil
	Private oContainer		:= Nil
	Private cItemBox		:= Nil
	Private oLayer			:= Nil
	Private oPanel1			:= Nil
	Private oPanelConteiner	:= Nil
	Private oGridMargem		:= Nil
	Private oGrid			:= Nil
	Private aFieldsSX5		:=  {"X5_DESCRI","X5_DESCRI", "X5_DESCENG", "X5_DESCSPA"}
	Private nOper			:= nOpc
	
	LoadModal()
	LoadContainer()
	LoadLayer()

	Grid()

	oWindow:Activate()
	
Return 


Static Function GetHeader(aFields)

	Local aHeader := {}
	Local nX

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeader, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

Return aHeader


Static Function LoadModal()

	Local aCoors := MsAdvSize()

	oWindow := FWDialogModal():New()
	oWindow:SetBackground(.T.)
	oWindow:SetTitle("Feriados")
	oWindow:SetEscClose(.T.)
	//oWindow:SetSize(aCoors[4], aCoors[3])
	oWindow:SetSize(aCoors[4]-50, aCoors[3]-70)
	oWindow:EnableFormBar(.T.)
	oWindow:CreateDialog()
	oWindow:CreateFormBar()

	oWindow:AddOKButton({|| Processa( {|| GravaSX5()},"Aguarde...","Gravando Registros...") }, "Salvar")
	oWindow:AddCloseButton({|| oWindow:OOWNER:End()})

Return

Static Function LoadContainer()

	oContainer	:= FWFormContainer():New()
	cItemBox 	:= oContainer:CreateHorizontalBox(100)
	oContainer:Activate(oWindow:GetPanelMain(), .T.)

Return 


Static Function LoadLayer()

	oPanelConteiner := oContainer:GetPanel(cItemBox)	

	// Layer
	oLayer := FWLayer():New()
	oLayer:Init(oPanelConteiner, .F., .T.)

	oLayer:AddLine("LINHA_1", 100, .F.)

	oLayer:AddCollumn('COLUNA_1', 100, .T., 'LINHA_1')

	// Janela acima 
	oLayer:AddWindow('COLUNA_1', 'JANELA_1', '', 100, .F. ,.T.,, 'LINHA_1', { || })	

	oPanel1 := oLayer:GetWinPanel('COLUNA_1', 'JANELA_1', 'LINHA_1')

Return


Static Function Grid()

	Local aHeader		:= {}
	Local aCols			:= {}
	Local aFieldFill 	:= {}
	Local aAlterFields	:= AClone(aFieldsSX5)
	
	aHeader := GetHeader(aFieldsSX5)
	
	aHeader[1][1] := "Data"
	aHeader[1][2] := "DATA"
	aHeader[1][4] := 8
	aHeader[1][8] := "D"
	
	aAlterFields[1] := "DATA"
	
	
	oGrid := MsNewGetDados():New( 0, 0, 0, 0,  GD_INSERT + GD_UPDATE + GD_DELETE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", .T., .T., oPanel1, aHeader, aCols)
	oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGrid:oBrowse:lVScroll := .T.
	oGrid:oBrowse:lHScroll := .T.

	If (nOper <> 3)
		LoadSX5()
	EndIf
Return



User Function CADFERIL()
	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Feriado Variado"  })
	AADD(aLegenda,{"BR_AMARELO",	"Feriado Fixo"})
	
	BrwLegenda(cTitle, "Tipo de Feriado", aLegenda)
Return
   

Static Function GravaSX5()
	
	Local xv_Emps	:= {}
	Local nI		:= 0
	Local cEmp		:= cEmpAnt
	Local cFil		:= cFilAnt
	
	If (ValidaGrid())
	
		oWindow:OOWNER:End()
		
		//xv_Emps :=  {{'01', '01'}, {'05', '01'}, {'07', '01'}, {'13', '01'}} 
		
		xv_Emps := {;
						{'01', '01'},;
						{'03', '01'},;
						{'04', '01'},;
						{'05', '01'},;
						{'06', '01'},;
						{'07', '01'},;
						{'08', '01'},;
						{'09', '01'},;
						{'10', '01'},;
						{'11', '01'},;
						{'12', '01'},;
						{'13', '01'},;
						{'14', '01'},;
						{'15', '01'},;
						{'16', '01'},;
						{'17', '01'},;
						{'90', '01'},;
						{'91', '01'};
						} 

		For nI := 1 To Len(xv_Emps)
			If (cEmpAnt <> xv_Emps[nI][1])
				StartJob("U_CADFERI2", GetEnvServer(), .T., xv_Emps[nI][1], xv_Emps[nI][2], nOper, oGrid:aCols, oGrid:aHeader, .T. )
			Else
				fProcCommit(cEmp, cFil, nOper, oGrid:aCols, oGrid:aHeader , .F.)
			EndIf
		Next nI	

	EndIf
	
Return

Static Function ValidaGrid()
	
	Local aCols := oGrid:aCols
	Local nI	:= 0
	Local aAux	:= {}
	Local nPos	:= 0
	
	For nI := 1 To Len(aCols)
		
		If (aCols[nI, Len(aCols[nI])] == .F.)	
			nPos := aScan(aAux,{|x| Alltrim(x) == cvaltochar(aCols[nI][1])})
			If (nPos <= 0)
				Aadd(aAux, cvaltochar(aCols[nI][1]))
			Else
				Alert("Registro duplicado: Data => "+cvaltochar(aCols[nI][1]))
				Return .F.
			EndIf
		EndIf
		
	Next nI	
	
Return .T.



User Function CADFERI2(cEmp, cFil, nOper, aCols, aHeader, lJob)
	fProcCommit(cEmp, cFil, nOper, aCols, aHeader, lJob)
Return 

Static Function fProcCommit(cEmp, cFil, nOper, aCols, aHeader, lJob)

	Local cUltChave		:= ""
	Local nI			:= 0
	Local nEmp			:= 0
	Local cQuery		:= ""
	Local cAliasTrab	:= Nil
	Local cChave		:= ""
	
	If (lJob)
		RpcSetEnv(cEmp, cFil)
	EndIf
	//BEGIN TRANSACTION
		
		If (Len(aCols) > 1 .And. nOper == 5)
			
			cAno	:= cvaltochar(aCols[1][1])// campo data
			cAno	:= SUBSTR(cAno, 7, 2)
			
			If (!Empty(cAno))
				
				cAliasTrab := GetNextAlias()	
				
				cQuery += "	SELECT 																				"
				cQuery += "		ID=R_E_C_N_O_																	"	
				cQuery += "		FROM "+RetSQLName("SX5")+" SX5 (NOLOCK)											"	
				cQuery += "			WHERE X5_TABELA					= '63' 										"
				cQuery += "			AND SUBSTRING (X5_DESCRI, 7, 2)	= '"+cAno+"' 								"
				cQuery += "			AND D_E_L_E_T_					= '' 										"
				
				TCQuery cQuery New Alias cAliasTrab
					
				While !cAliasTrab->(EoF())
					
					DbSelectArea("SX5")
					SX5->(DbSetOrder(1))
					SX5->(DbGoto(cAliasTrab->ID))
					
					RecLock("SX5",.F.)
						SX5->(DbDelete())
					SX5->(MsUnlock())
					
					cAliasTrab->(DbSkip()) 
				EndDo
				
				cAliasTrab->(DbCloseArea())	
			EndIf
			
		EndIf
		
		
		For nI := 1 To Len(aCols)
		
			If ( nOper == 3 .Or. nOper == 4) //incluir/ Editar

				
				cAliasTrab	:= GetNextAlias()	
				cChave		:= cvaltochar(aCols[nI][1])
				
				If (!Empty(cChave))
				
					cQuery := ""
					cQuery += "	SELECT 																				"
					cQuery += "		ID=R_E_C_N_O_																	"	
					cQuery += "		FROM "+RetSQLName("SX5")+" SX5 (NOLOCK)											"	
					cQuery += "			WHERE X5_TABELA					= '63' 										"
					cQuery += "			AND SUBSTRING (X5_DESCRI, 1, 8) = '"+cChave+"' 								"
					cQuery += "			AND D_E_L_E_T_					= '' 										"
					
					TCQuery cQuery New Alias cAliasTrab
						
					If (aCols[nI, Len(aCols[nI])] == .F.)	
						
						If !cAliasTrab->(EoF())
							
							DbSelectArea("SX5")
							SX5->(DbSetOrder(1))
							SX5->(DbGoto(cAliasTrab->ID))
							
							RecLock("SX5",.F.)
								SX5->X5_FILIAL		:= xFilial("SX5")
								SX5->X5_TABELA		:= "63"
								SX5->X5_DESCRI		:= cvaltochar(aCols[nI][1])+" "+aCols[nI][2]
								SX5->X5_DESCENG		:= cvaltochar(aCols[nI][1])+" "+aCols[nI][3]
								SX5->X5_DESCSPA		:= cvaltochar(aCols[nI][1])+" "+aCols[nI][4]
							SX5->(MsUnlock())
						Else
						
							cUltChave := UltChave()
							cUltChave := Soma1(cUltChave)
							
							RecLock("SX5",.T.)
									
								SX5->X5_FILIAL		:= xFilial("SX5")
								SX5->X5_TABELA		:= "63"
								SX5->X5_CHAVE		:= cUltChave
								SX5->X5_DESCRI		:= cvaltochar(aCols[nI][1])+" "+aCols[nI][2]
								
								
								SX5->X5_DESCENG		:= cvaltochar(aCols[nI][1])+" "+aCols[nI][3]
								SX5->X5_DESCSPA		:= cvaltochar(aCols[nI][1])+" "+aCols[nI][4]
								
							SX5->(MsUnlock())
							
						EndIf
					
					Else
						
						//delete
						
						If !cAliasTrab->(EoF())					
							DbSelectArea("SX5")
							SX5->(DbSetOrder(1))
							SX5->(DbGoto(cAliasTrab->ID))
							
							RecLock("SX5",.F.)
								SX5->(DbDelete())
							SX5->(MsUnlock())
							
						EndIf
						
					EndIf
					cAliasTrab->(DbCloseArea())	
				
				EndIf											
				
			EndIf
			
		Next nI
		
	//END TRANSACTION
	
	If (lJob)
		RpcClearEnv()	
	EndIf
	
Return(.T.)


Static Function LoadSX5()
	U_BIAMsgRun("Aguarde... Carregando registros...",, {|| fProcLoadSX5() })
Return


Static Function fProcLoadSX5()

	Local aArea			:= GetArea()
	Local cAno 			:= ""
	Local aDados 		:= {}
	Local aLinha		:= {}
	Local nI			:= 0
	Local cQuery		:= ""
	Local cAliasTrab	:= GetNextAlias()	
	Local dData			:= Nil
	Local cDesc1		:= ""
	Local cDesc2		:= ""
	Local cDesc3		:= ""
	
	cAno :=  AllTrim(SUBSTR(SX5->X5_DESCRI, 7, 2))
	If (!Empty(cAno))
		
		cQuery += "	SELECT 																				"
		cQuery += "		*																				"	
		cQuery += "		FROM "+RetSQLName("SX5")+" SX5 (NOLOCK)											"	
		cQuery += "			WHERE X5_TABELA					= '63' 										"
		cQuery += "			AND SUBSTRING (X5_DESCRI, 7, 2)	= '"+cAno+"' 								"
		cQuery += "			AND D_E_L_E_T_					= '' 										"
		
		TCQuery cQuery New Alias cAliasTrab
			
		While !cAliasTrab->(EoF())
			
			If (Len(AllTrim(SUBSTR(cAliasTrab->X5_DESCRI, 0, 8))) == 8)
				dData	:= cTod(AllTrim(SUBSTR(cAliasTrab->X5_DESCRI, 0, 8)))
			Else
				dData	:= AllTrim(SUBSTR(cAliasTrab->X5_DESCRI, 0, 8))
			EndIf
			
			cDesc1	:= (SUBSTR(cAliasTrab->X5_DESCRI, 10))
			cDesc2	:= (SUBSTR(cAliasTrab->X5_DESCENG, 10))
			cDesc3	:= (SUBSTR(cAliasTrab->X5_DESCSPA, 10))
			
			aLinha := {dData, cDesc1, cDesc2, cDesc3, .F.}
			
			Aadd(aDados, aLinha)
			cAliasTrab->(DbSkip()) 
		EndDo
		
		cAliasTrab->(DbCloseArea())	
		
	EndIf
	
	
	If (Len(aDados))
		oGrid:SetArray(aDados, .T.)
		oGrid:oBrowse:Refresh()
	EndIf
	
	RestArea(aArea)
	
Return


Static Function UltChave()
	
	Local cChave		:= ""
	Local cQuery		:= ""
	Local cAliasTemp	:= GetNextAlias()	
	
	//pegar ultima chave valida
	cQuery += "	 SELECT MIN(X5_CHAVE) AS CHAVE															"
	cQuery += "	 FROM "+RetSQLName("SX5")+" T1																"
	cQuery += "	 WHERE NOT EXISTS (																			"
	cQuery += "	  SELECT X5_CHAVE FROM "+RetSQLName("SX5")+" T2 											"
	cQuery += "	 	WHERE CONVERT(INT, ISNULL(T2.X5_CHAVE, 0)) = (CONVERT(INT, ISNULL(T1.X5_CHAVE, 0)) + 1)	"
	cQuery += "	 	AND T2.X5_TABELA 	= '63' 																"
	cQuery += "	 	AND T2.D_E_L_E_T_	= ''																"
	cQuery += "	 )																							"
	cQuery += "	 AND T1.X5_TABELA 	= '63' 																	"
	cQuery += "	 AND T1.D_E_L_E_T_	= ''																	"
		
	
	TCQuery cQuery New Alias cAliasTemp
		
	If !cAliasTemp->(EoF())
		cChave := AllTrim(cAliasTemp->CHAVE)
	EndIf
	
	cAliasTemp->(DbCloseArea())
		
Return cChave