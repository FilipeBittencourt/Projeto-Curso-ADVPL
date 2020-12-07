#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} TIT_WND
//TODO Descrição auto-gerada.
@author Pedro Henrique
@since 11/06/2019
@version undefined
parametersSection
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

// TITULOS DAS JANELAS
#DEFINE TIT_WND "Emissão de Boleto"

#DEFINE nP_MARK 1
#DEFINE nP_PRE 2
#DEFINE nP_NUM 3
#DEFINE nP_PAR 4
#DEFINE nP_RECNO 18

Class TWAFImprimirBoletoReceber From LongClassName
	
	Data cPrefixoDe // Prefixo De
	Data cPrefixoAte // Prefixo De
	Data cNumeroDe // Numero De
	Data cNumeroAte // Numero Ate
	Data cCliDe // Cliente De
	Data cCliAte // Cliente Ate
	Data dVenctoDe // Data de vencimento De
	Data dVenctoAte // Data de vencimento Ate
	Data dReferencia // Nova data de vencimento	
	Data cRepAtu	//
	
	//privados
	Data oWindow  
	Data oContainer	
	Data oPanel
	Data cIdHBox	
	Data cChk
	Data cUnChk
	Data oChk
	Data lMarkAll	
	Data oBrw	
	Data oField
	Data lConfirm
	
	
	Method New(oParam) Constructor
	Method LoadInterface()
	Method LoadWindow()
	Method LoadContainer()
	Method LoadBrowser()
	Method Activate()	 
	Method GetEditableField()
	Method GetFieldProperty()
	Method GetFieldData()
	Method GetLegend()
	Method BrowserClick()
	Method Mark()
	Method MarkAll()
	Method ExistMark()
	Method GetMark()
	Method Confirm()
	Method GetPDF(cArqSaida, cNomeArq, Id)
	Method SelectDest()	
	Method ClearMark()

EndClass


Method New(aParam) Class TWAFImprimirBoletoReceber

	::oWindow 		:= Nil	
	::oContainer 	:= Nil	
	::oPanel 		:= Nil
	::cIdHBox 		:= ""
	::cChk 			:= "WFCHK"
	::cUnChk 		:= "WFUNCHK"
	::oChk 			:= Nil
	::lMarkAll 		:= .F.
	::oBrw 			:= Nil	
	::oField 		:= TGDField():New()
	::lConfirm 	:= .F.


	::cPrefixoDe 	:= aParam[1]
	::cPrefixoAte 	:= aParam[2]
	::cNumeroDe 	:= aParam[3]
	::cNumeroAte 	:= aParam[4]
	::cCliDe 		:= aParam[5]
	::cCliAte 		:= aParam[6]
	::dVenctoDe 	:= aParam[7]
	::dVenctoAte 	:= aParam[8]
	::dReferencia 	:= aParam[9]
	::cRepAtu 		:= aParam[10]

Return()


Method LoadInterface() Class TWAFImprimirBoletoReceber

	::LoadWindow()

	::LoadContainer()

	::LoadBrowser()

Return()


Method LoadWindow() Class TWAFImprimirBoletoReceber
	Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.) 
	::oWindow:SetTitle(TIT_WND)
	::oWindow:SetEscClose(.F.)
	::oWindow:SetSize(aCoors[4], aCoors[3])
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()
	
	::oWindow:AddOKButton({|| ::Confirm() }, 'PDF')
	::oWindow:AddCloseButton()

Return()


Method LoadContainer() Class TWAFImprimirBoletoReceber

	::oContainer := FWFormContainer():New()
	
	::cIdHBox := ::oContainer:CreateHorizontalBox(100)	
	
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)
		
Return()


Method LoadBrowser() Class TWAFImprimirBoletoReceber
	Local cVldDef := "AllwaysTrue"
	
	::oPanel := ::oContainer:GetPanel(::cIdHBox)	
	
	::oBrw := MsNewGetDados():New(0, 0, 0, 0, GD_UPDATE, cVldDef, cVldDef, "", ::GetEditableField(),,, cVldDef,, cVldDef, ::oPanel, ::GetFieldProperty(), ::GetFieldData())
	::oBrw:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	::oBrw:oBrowse:bLDblClick := {|| ::BrowserClick() }
	::oBrw:oBrowse:lVScroll := .T.
	::oBrw:oBrowse:lHScroll := .T.

Return()


Method Activate() Class TWAFImprimirBoletoReceber	

	::LoadInterface()
	
	::oWindow:Activate()

Return()


Method GetEditableField() Class TWAFImprimirBoletoReceber
Local aRet := {}


Return(aRet)


Method GetFieldProperty() Class TWAFImprimirBoletoReceber

	::oField:Clear()
	
	::oField:AddField("MARK")
	::oField:FieldName("MARK"):cTitle := SPACE(6)
	::oField:FieldName("MARK"):cPict := "@BMP"
	
	::oField:AddField("E1_PREFIXO")
	::oField:AddField("E1_NUM")
	::oField:AddField("E1_PARCELA")
	::oField:AddField("E1_TIPO")
	::oField:AddField("E1_CLIENTE")
	::oField:AddField("E1_LOJA")
	::oField:AddField("A1_NOME")
	::oField:AddField("E1_EMISSAO")
	::oField:AddField("E1_VENCTO")
	::oField:AddField("E1_VENCREA")
	::oField:AddField("E1_VALOR")
	::oField:AddField("E1_SALDO")	
	::oField:AddField("E1_NUMBCO")
	::oField:AddField("E1_PORTADO")
	::oField:AddField("E1_AGEDEP")
	::oField:AddField("E1_CONTA")
	
	::oField:AddField("SE1_RECNO")
	::oField:FieldName("SE1_RECNO"):cTitle := "Id"
	

Return(::oField:GetHeader())


Method GetFieldData() Class TWAFImprimirBoletoReceber
	
	Local aRet := {}
	Local cSQL := ""
	Local cQry := GetNextAlias()

	cSQL += " SELECT *, CONVERT(VARCHAR, GETDATE(), 112) DATE, SE1.R_E_C_N_O_ AS SE1_RECNO  FROM "+ RetSQLName("SE1") + " SE1 "
	cSQL += " INNER JOIN "+ RetSQLName("SA1") + " SA1  ON E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA AND SA1.D_E_L_E_T_ = ''"
	
	cSQL += " WHERE "
	cSQL += " E1_FILIAL 			= '"+xFilial("SE1")+"'  		"
	cSQL += " AND E1_SALDO 			> 0								"	
	cSQL += " AND E1_PREFIXO 		>= '"+::cPrefixoDe+"'			"
	cSQL += " AND E1_PREFIXO 		<= '"+::cPrefixoAte+"'			"
	cSQL += " AND E1_NUM 			>= '"+::cNumeroDe+"'			"
	cSQL += " AND E1_NUM 			<= '"+::cNumeroAte+"'			"	
	cSQL += " AND E1_CLIENTE 		>= '"+::cCliDe+"'				"
	cSQL += " AND E1_CLIENTE 		<= '"+::cCliAte+"'				"	
	cSQL += " AND E1_NUMBCO 		<> ''							"
	cSQL += " AND SE1.D_E_L_E_T_ 	= ''							"
	
	
	cSQL += " AND E1_VENCTO 		>= '"+dtos(::dVenctoDe)+"'	"
	cSQL += " AND E1_VENCTO 		<= '"+dtos(::dVenctoAte)+"'	"
	
	/*If !Empty(Alltrim(::cRepAtu))
		cSQL += " AND E1_VEND1 			= '"+::cRepAtu+"'				"
		cSQL += " AND E1_VENCTO 		>= '"+dtos(dDataBase)+"'		"
		cSQL += " AND E1_VENCTO 		<= '"+dtos(::dVenctoDe)+"' 		"
	Else
		
		If U_VALOPER("021",.F.)
			cSQL += " AND E1_VENCTO 		>= '"+dtos(::dVenctoDe)+"'	"
			cSQL += " AND E1_VENCTO 		<= '"+dtos(::dVenctoAte)+"'	"
		Else
			cSQL += " AND E1_VENCTO 		>= '"+dtos(dDataBase)+"'	"
			cSQL += " AND E1_VENCTO 		<= '"+dtos(::dVenctoAte)+"'	"
		EndIf
		
	EndIf*/
			
	
	TcQuery cSQL New Alias (cQry)

	While !(cQry)->(Eof())

		aAdd(aRet, {::cUnChk, ;
								(cQry)->E1_PREFIXO, (cQry)->E1_NUM, (cQry)->E1_PARCELA, (cQry)->E1_TIPO, (cQry)->E1_CLIENTE, (cQry)->E1_LOJA, AllTrim((cQry)->A1_NOME),;
								dToC(sToD((cQry)->E1_EMISSAO)), dToC(sToD((cQry)->E1_VENCTO)), dToC(sToD((cQry)->E1_VENCREA)), (cQry)->E1_VALOR, (cQry)->E1_SALDO,; 
								(cQry)->E1_NUMBCO, (cQry)->E1_PORTADO, (cQry)->E1_AGEDEP, (cQry)->E1_CONTA, (cQry)->SE1_RECNO,;
								 .F.})

		
		(cQry)->(DbSkip())

	EndDo()

	(cQry)->(DbCloseArea())

Return(aRet)


Method GetLegend() Class TWAFImprimirBoletoReceber
Local cRet := ""


Return(cRet)


Method BrowserClick() Class TWAFImprimirBoletoReceber

	::Mark()

Return()


Method Mark() Class TWAFImprimirBoletoReceber

	If ::oBrw:aCols[::oBrw:nAt, nP_MARK] == ::cChk
		
		::oBrw:aCols[::oBrw:nAt, nP_MARK] := ::cUnChk
		
	Else
		
		::oBrw:aCols[::oBrw:nAt, nP_MARK] := ::cChk
		
	EndIf			

Return()


Method MarkAll() Class TWAFImprimirBoletoReceber
Local nCount := 0

	If Len(::oBrw:aCols) > 0
		
		For nCount := 1 To Len(::oBrw:aCols)
	
			If ::lMarkAll
				::oBrw:aCols[nCount, nP_MARK] := ::cChk
			Else
				::oBrw:aCols[nCount, nP_MARK] := ::cUnChk
			EndIf
	
		Next
			
		::oBrw:oBrowse:Refresh()
		
	EndIf

Return()


Method ExistMark() Class TWAFImprimirBoletoReceber
Local lRet := .F.

	lRet := aScan(::oBrw:aCols, {|x| x[nP_MARK] == ::cChk }) > 0

Return(lRet)

Method ClearMark() Class TWAFImprimirBoletoReceber
	
	Local nI	:= 0
	
	For nI:=1 To Len (::oBrw:aCols)
		::oBrw:aCols[nI, nP_MARK] := ::cUnChk
	Next nI
	
Return()


Method GetMark() Class TWAFImprimirBoletoReceber
Local aRet := {}

	
	aEval(::oBrw:aCols, {|aPar| If (aPar[nP_MARK] == ::cChk, aAdd(aRet, {aPar[nP_PRE], aPar[nP_NUM], aPar[nP_PAR], aPar[nP_RECNO]}), Nil) })

Return(aRet)



Method Confirm() Class TWAFImprimirBoletoReceber
	
	If ::ExistMark()
						
		::SelectDest()
		
		//::lConfirm := .T.
	
	Else
	
		MsgStop("Não existem itens selecionados!")
		
	EndIf 
	
		
Return


Method SelectDest() Class TWAFImprimirBoletoReceber

	Local aPergs		:= {}
	Local cRefPer	  	:= 'BAF040_1' + cEmpAnt
	Local cFileName    	:= __cUserID +"_"+ cRefPer
	Local cDirDest		:= Space(170)
	Local cArqSaida		:= ""
	Local cNomeArq		:= ""
	Local cNomeComArq	:= ""
	Local aListaSelect	:= ::GetMark()
	Local aLinha		:= {}
	Local Id			:= 0
	Local nI			:= 0
	Local nJ			:= 0
	Local cRegistro		:= ""
	Local aListaAgrup	:= {}
	
	Private lOkApi		:= .T.
	
	aAdd( aPergs ,{6, "Pasta Destino: " 	,cDirDest  ,"","","", 75 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE} )

	If !ParamBox(aPergs ,"Pdf do Boleto",,,,,,,,cRefPer,.T.,.T.)
		Return
	EndIf

	cDirDest	:= ParamLoad(cFileName,,1 , cDirDest)
	cArqSaida	:= AllTrim(cDirDest)

	If (!Empty(cArqSaida))
		
		If ExistDir( cArqSaida ) 
			
			/*For nI:=1 To Len (aListaSelect) 
			
				aLinha 		:= aListaSelect[nI]
				cNomeArq	:= AllTrim(aLinha[1])+'_'+AllTrim(aLinha[2])+'_'+AllTrim(aLinha[3])
				cNomeComArq := cNomeArq+".PDF" 
				Id 			:= aLinha[4]
				
				cRegistro	:= aLinha[1]+'/'+aLinha[2]+'/'+aLinha[3]
				
				FWMsgRun(, {|| ::GetPDF(cArqSaida, cNomeComArq, Id)}, "Buscando dados para geração do PDF ("+cRegistro+")", "")
			
			Next nI
			*/
			
			//agrupar todos mesmo prefixo/numero
			For nI:=1 To Len (aListaSelect) 
				
				aLinha 		:= aListaSelect[nI]
				
				If (AScan(aListaAgrup, {|x| AllTrim(x) == AllTrim(aLinha[1]+'_'+aLinha[2])}) <= 0)
					Aadd(aListaAgrup, AllTrim(aLinha[1]+'_'+aLinha[2]))
				EndIf
			
			Next nI
			
			
			For nJ:=1 To Len (aListaAgrup) 
				
				cParcela	:= ""
				cListaId	:= ""	
				
				For nI:=1 To Len (aListaSelect) 
					
					aLinha 		:= aListaSelect[nI]
				
					If (AllTrim(aListaAgrup[nJ]) == AllTrim(aLinha[1]+'_'+aLinha[2]))
						cParcela += AllTrim(aLinha[3])+"_"
						cListaId += cValtoChar(aLinha[4])+"_"
					EndIf
					
				Next nI
			
				cNomeArq	:= AllTrim(aListaAgrup[nJ])+'_'+SubStr(cParcela, 1, Len(cParcela) - 1)
				cNomeComArq := cNomeArq+".PDF" 
				cRegistro	:= StrTran(cNomeArq, "_", "/")
				cListaId	:= SubStr(cListaId, 1, Len(cListaId) - 1)
			
				FWMsgRun(, {|| ::GetPDF(cArqSaida, cNomeComArq, cListaId)}, "Buscando dados para geração do PDF ("+cRegistro+")", "")
				
			Next nJ
					
			
			::ClearMark()
			If (lOkApi)
				MsgInfo('Arquivos salvos no diretório: '+cArqSaida+'')
			EndIf
		Else
		
			MsgStop('Pasta Destino não encontrada.')
		
		EndIf
	
	Else

		MsgStop('Selecione um pasta destino para salvar os arquivos.')

	EndIf
	

Return


Method GetPDF(cArqSaida, cNomeArq, cListaId) Class TWAFImprimirBoletoReceber

	Local cArq 			:= cArqSaida+cNomeArq
	Local cArquivo		:= Nil
	Local cDecode64		:= Nil
	Local oRet			:= Nil
	Local nRet			:= Nil
	Local oApiImpBol	:= Nil
	
		    
	oApiImpBol	:= TAFApiImprimirBoleto():New()
	oRet 		:= oApiImpBol:GetPDF(cListaId, ::dReferencia)
	
	
	If (oRet <> Nil)
		
		If (oRet:Ok .And. oRet:oRetorno:Dados <> Nil .And. !Empty(oRet:oRetorno:Dados))
			
			lOkApi := .T.
			
			cDecode64	:= Decode64(oRet:oRetorno:Dados)
			MemoWrite(cArq, cDecode64)
			
			nRet := ShellExecute("open", cNomeArq, "", cArqSaida, 1)
			If nRet <= 32
		        MsgStop("Não foi possível abrir o arquivo " +cArq+ "!", "Atenção")
		    EndIf
		
		Else
			
			lOkApi := .F.
			//MsgStop("Erro: " +oRet:mensagemRetorno+ "!", "Atenção")
			MsgStop("Registro não encontdado na API", "Atenção")
			U_BIA272P(cListaId)
	
		EndIf
	     
	EndIf
	
			
Return
