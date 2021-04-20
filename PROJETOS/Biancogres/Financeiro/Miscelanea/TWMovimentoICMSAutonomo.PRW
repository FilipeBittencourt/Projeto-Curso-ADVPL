#Include "TOTVS.CH"
#Include "Protheus.CH"
#Include "TOPCONN.CH"

User Function TWMICMAE(cEmp, cFil, cData, nIcmAuto, cNatureza, cBanco, cAgencia, cConta, cCC, cCLVL, cHistorico)
	
	Local lRet := .T.
	
	RpcSetEnv(cEmp, cFil)

	_ObjMICMSAut := TWMovimentoICMSAutonomo():New()
	lRet := _ObjMICMSAut::ExecMovBanc(cData, nIcmAuto, cNatureza, cBanco, cAgencia, cConta, cCC, cCLVL, cHistorico)
	
	RpcClearEnv()
	
Return lRet

User Function MVICMSAJ()
	
	_Obj := TWMovimentoICMSAutonomo():New()
	_Obj:ExecuteEmp()
		
Return

User Function TWMICMAJ()
	_Obj := TWMovimentoICMSAutonomo():New()
	_Obj:ShowModal()		
Return
 

Class TWMovimentoICMSAutonomo From LongClassName
	
	Data oWindow		
	Data oContainer		
	Data cItemBox		
	Data oLayer			
	Data oPanel1	
	Data oPanelConteiner		
	Data aListEmp	
	Data cCodEmp
	Data cCodFil
	Data cEmpresas	
	
	Method New() Constructor
	Method Execute()
	Method ExecuteEmp()
	Method Exist()
	Method GetData()
	Method GetValor() 
	Method GetValorEmp()
	Method GetEmp()
	Method ExecMovBanc()
	
	Method ShowModal()
	Method LoadModal()
	Method LoadContainer()
	Method LoadLayer()
	Method CreateView()	
	
EndClass

Method New () Class TWMovimentoICMSAutonomo
	
	Local nI	:= 0
	Local aList	:= {}
	
	::cCodEmp	:= cEmpAnt
	::cCodFil	:= cFilAnt	
	::aListEmp 	:= {{'01','01'}, {'05','01'}, {'07','01'} ,{'13','01'}}
	::cEmpresas := ""
	
	For nI:=1 to Len (::aListEmp)
		::cEmpresas += ::aListEmp[nI][1]+::aListEmp[nI][2]
		If (nI < Len (::aListEmp))
			::cEmpresas += '/'
		EndIf
	Next nI	
	
Return 

Method ShowModal() Class TWMovimentoICMSAutonomo
	
	::LoadModal()
	::LoadContainer()
	::LoadLayer()
	::CreateView()

	::oWindow:Activate()
	
Return

Method LoadModal() Class TWMovimentoICMSAutonomo

	Local aCoors := MsAdvSize()

	::oWindow := FWDialogModal():New()
	::oWindow:SetBackground(.T.)
	::oWindow:SetTitle("Movimento ICMS Frete Autônomo")
	::oWindow:SetEscClose(.T.)
	::oWindow:SetSize(aCoors[4]*.4, aCoors[3]*.3)
	::oWindow:EnableFormBar(.T.)
	::oWindow:CreateDialog()
	::oWindow:CreateFormBar()

	::oWindow:AddButtons(;
		{;
		{'', 'Valores Empresas'	, {|| Processa( {|| ::GetValorEmp()},"Aguarde...","Processando...")  }, 	'',	'', .T., .T.},;
		{'', 'Gerar Empresas'	, {|| Processa( {|| ::ExecuteEmp()},"Aguarde...","Processando...") } , 		'',	'', .T., .T.};
		};
	)
	::oWindow:AddCloseButton({|| ::oWindow:OOWNER:End()})

Return

Method LoadContainer() Class TWMovimentoICMSAutonomo

	::oContainer	:= FWFormContainer():New()
	::cItemBox 		:= ::oContainer:CreateHorizontalBox(100)
	::oContainer:Activate(::oWindow:GetPanelMain(), .T.)

Return 

Method LoadLayer() Class TWMovimentoICMSAutonomo

	::oPanelConteiner := ::oContainer:GetPanel(::cItemBox)	

	// Layer
	::oLayer := FWLayer():New()
	::oLayer:Init(::oPanelConteiner, .F., .T.)
	
	::oLayer:AddLine("LINHA_1", 80, .F.)
	::oLayer:AddCollumn('COLUNA_1', 100, .T., 'LINHA_1')
	::oLayer:AddWindow('COLUNA_1', 'JANELA_1', '', 100, .F. ,.T.,, 'LINHA_1', { || })	
	::oPanel1 := ::oLayer:GetWinPanel('COLUNA_1', 'JANELA_1', 'LINHA_1')
	
Return

Method CreateView() Class TWMovimentoICMSAutonomo
	
	oSayEmp 			:= TSay():Create(::oPanel1)
	oSayEmp:cName 		:= "oSayEmp"
	oSayEmp:cCaption 	:= "Empresas: "
	oSayEmp:nLeft 		:= 06
	oSayEmp:nTop 		:= 07
	oSayEmp:nWidth 		:= 100
	oSayEmp:nHeight 	:= 30
	oSayEmp:lReadOnly 	:= .T.
	oSayEmp:cToolTip	:= "Empresas"
	
	oGetEmp 			:= TGet():Create(::oPanel1)
	oGetEmp:cName 		:= "oGetEmp"
	oGetEmp:nLeft 		:= 70
	oGetEmp:nTop 		:= 06
	oGetEmp:nWidth 		:= 300
	oGetEmp:nHeight 	:= 20
	oGetEmp:cVariable 	:= "cGetEmp"
	oGetEmp:bSetGet 	:= bSetGet(::cEmpresas)
	oGetEmp:bChange 	:= {|| }
	oGetEmp:lHasButton	:= .T.
	oGetEmp:lReadOnly	:= .T.
	oGetEmp:cToolTip 	:= "Empresas"

Return

Method Exist(cRecPag, cData, cBanco, cAgencia, cConta, cCLVL, cCC, cNatureza, nValor) Class TWMovimentoICMSAutonomo
	Local cAliasTrab	:= GetNextAlias()
	Local cQuery 		:= ""
	Local lRet			:= .F.
	
	cQuery := " SELECT  *																				"
	cQuery += "	FROM SE5"+::cCodEmp+"0	SE5					 											"
	cQuery += "	WHERE SE5.E5_FILIAL 		= "+ ValToSQL(::cCodFil)+"									"
	cQuery += "	AND SE5.E5_RECPAG		 	= '"+cRecPag+"'												"
	cQuery += "	AND SE5.E5_DATA		 		= '"+cData+"'												"
	cQuery += "	AND SE5.E5_BANCO		 	= '"+cBanco+"'												"
	cQuery += "	AND SE5.E5_AGENCIA		 	= '"+cAgencia+"'											"
	cQuery += "	AND SE5.E5_CONTA		 	= '"+cConta+"'												"
	cQuery += "	AND SE5.E5_CLVLCR		 	= '"+cCLVL+"'												"
	cQuery += "	AND SE5.E5_CCC			 	= '"+cCC+"'													"
	cQuery += "	AND SE5.E5_NATUREZ		 	= '"+cNatureza+"'											"
	cQuery += "	AND SE5.E5_VALOR		 	= "+cValtochar(nValor)+"									"
	cQuery += "	AND SE5.D_E_L_E_T_	 		= '' 														"

	TcQuery cQuery New Alias (cAliasTrab)

	If !(cAliasTrab)->(Eof())	
		lRet	:= .T.
	EndIf
	
	(cAliasTrab)->(DbCloseArea())	
	
Return lRet

Method GetData()  Class TWMovimentoICMSAutonomo
	
	Local dData		:= dDataBase - 1 
	Local nDia		:= DOW(dData)    
	
	While nDia == 1 .Or. nDia == 7
		
		dData	:= dData - 1 
		nDia	:= DOW(dData)   
		
	EndDo()
	
	dData	:= DataValida(dData, .F.) 		
		
Return dData

Method GetValor() Class TWMovimentoICMSAutonomo
	
	Local cQuery 		:= ""
	Local cAliasTemp	:= GetNextAlias()
	Local nFreteAut		:= 0
	Local nIcmAuto		:= 0
	Local cData			:= ::GetData()  
	Local cSerieDe		:= ""
	Local cSerieAte		:= ""
	
	//todo tratar final de semana	
	cQuery := " SELECT  FRETAUT=SUM(F2_FRETAUT), ICMAUTO=SUM(F2_ICMAUTO)							"
	cQuery += "	FROM SF2"+::cCodEmp+"0  SF2					 										"
	cQuery += "	WHERE F2_FILIAL 		= "+ ValToSQL(::cCodFil)+"									"
	
	If (!Empty(cSerieDe) .And. !Empty(cSerieAte) )
		cQuery += "	AND SF2.F2_SERIE	 	BETWEEN '"+cSerieDe+"' AND '"+cSerieAte+"'				"
	EndIf
	
	cQuery += "	AND SF2.F2_EMISSAO	 	= '"+dtos(cData)+"'											"
	cQuery += "	AND SF2.D_E_L_E_T_	 	= '' 														"
	cQuery += "	GROUP BY F2_EMISSAO 																"
	
	Conout(cQuery)
	
	TcQuery cQuery New Alias (cAliasTemp)
	
	If !(cAliasTemp)->(Eof())	
	
		nFreteAut 		:= (cAliasTemp)->FRETAUT
		nIcmAuto 		:= (cAliasTemp)->ICMAUTO
		
	EndIf

	(cAliasTemp)->(DbCloseArea())
	
Return nIcmAuto

Method GetEmp() class TWMovimentoICMSAutonomo
	
	Local aListEmpSel	:= {}
	Local cListEmp		:= ::cEmpresas
	
	Private aPergs		:= {}
	Private cRefPer		:= 'TWMICMAJ' + cEmpAnt
	Private cFileName   := __cUserID +"_"+ cRefPer
	Private aRetPerg	:= {""}
	
	aAdd( aPergs ,{1, "Ex: (0101/0501) - Empresas", cListEmp  ,"","","",'.T.',50,.T.})
		
	If !ParamBox(aPergs ,"Filtro - Empresas", aRetPerg,,,,,,,cRefPer,.F.,.F.)
		Return aListEmpSel
	EndIf

	cListEmp	:= ParamLoad(cFileName,, 2	, cListEmp)
	aListEmpSel	:= StrTokArr(cListEmp, "/" )
	
Return aListEmpSel

Method GetValorEmp() Class TWMovimentoICMSAutonomo
	
	Local nI			:= 0
	Local nValor		:= 0
	Local cMsg			:= ""
	Local aListEmpSel	:= ::GetEmp()
	Local nPos			:= 0
	Local lOk			:= .F.
	
	cMsg	+= '<p>
	For nI:=1 To Len (aListEmpSel)
		
		::cCodEmp	:= substr(aListEmpSel[nI], 1, 2)
		::cCodFil	:= substr(aListEmpSel[nI], 3, 2)
		
		nPos := AScan(::aListEmp, {|x| AllTrim(x[1]+x[2]) == AllTrim(::cCodEmp+::cCodFil)})
		If (nPos > 0)
			nValor := ::GetValor() 
			
			If (nValor > 0)
				cMsg	+= '<b>Empresa ('+::cCodEmp+'/'+::cCodFil+'): </b>'+cvaltochar(nValor)+'<br/>'
				lOk	:= .T.
			EndIf
		EndIf
		
	Next nI
	cMsg	+= '</p>'
	
	If (lOk)
		MsgAlert(cMsg, '')
	Else
		MsgAlert('Não foi encontrado nenhuma informação!', '')
	EndIf
	
Return 

Method ExecuteEmp() Class TWMovimentoICMSAutonomo
	
	Local nI			:= 0
	Local aListEmpSel	:= ::GetEmp()
	Local nPos			:= 0
	Local lRet			:= .T.
	
	For nI:=1 To Len (aListEmpSel)
		
		::cCodEmp	:= substr(aListEmpSel[nI], 1, 2)
		::cCodFil	:= substr(aListEmpSel[nI], 3, 2)
		
		nPos := AScan(::aListEmp, {|x| AllTrim(x[1]+x[2]) == AllTrim(::cCodEmp+::cCodFil)})
		If (nPos > 0)
			::Execute() 
		EndIf
		
	Next nI
	
Return 

Method Execute() Class TWMovimentoICMSAutonomo

	Local cData			:= DataValida(::GetData() + 1, .T.) 	 //movimento sempre dia + 1
	Local cBanco		:= ''
	Local cAgencia		:= ''
	Local cConta		:= ''
	Local cCLVL 		:= ''
	Local cNatureza		:= ''
	Local cCC			:= ''
	Local cMsg			:= ''
	Local cHistorico	:= ''
				
	nIcmAuto		:= ::GetValor()
	//nIcmAuto		:= 10
	cBanco			:= ''
	cAgencia		:= ''
	cConta			:= ''
	cCLVL 			:= ''
	
	//Biancogres 55097-3 e LM 5286-8
	//001
	//
	cHistorico := 'REC ICMS do DIA '+cvaltochar(DTOC(::GetData()))
	// B=1101, LM=1150, INCESA=1003, Vinilico=1035
	If AllTrim(::cCodEmp)+AllTrim(::cCodFil) == '0101'
		cCLVL 		:= '1101'
		cBanco		:= '001'
		cAgencia	:= '34312'
		cConta		:= '55.097-3'
	ElseIf AllTrim(::cCodEmp)+AllTrim(::cCodFil) == '0501'
		cCLVL		:= '1003'
		cBanco		:= '021'
		cAgencia	:= '552'
		cConta		:= '10.532.885'
	ElseIf AllTrim(::cCodEmp)+AllTrim(::cCodFil) == '0701'
		cCLVL		:= '1150'
		cBanco		:= '001'
		cAgencia	:= '34312'
		cConta		:= '52868'
	ElseIf AllTrim(::cCodEmp)+AllTrim(::cCodFil) == '1301'
		cCLVL		:= '1035'
		cBanco		:= '001'
		cAgencia	:= '34312'
		cConta		:= '54666'
	EndIf
	
	cNatureza		:= '1225'
	cCC				:= '1000'
	
	cMsg			+= '<p><b>Empresa: </b>'+::cCodEmp+'/'+::cCodFil+', <b>Valor: </b>'+cValToChar(nIcmAuto)+'</p>'
	cMsg			+= '<p><b>Data: </b>'+cvaltochar(DTOC(cData))+'</p>'
	cMsg			+= '<p><b>Banco: </b>'+cBanco+', <b>Agência: </b>'+cAgencia+', <b>Conta: </b>'+cConta+'</p>'
	cMsg			+= '<p><b>Natureza: </b>'+cNatureza+'</p>'
	cMsg			+= '<p><b>Centro de Custo: </b>'+cCC+', <b>Classe de Valor: </b>'+cCLVL+'</p>'
	cMsg			+= '<p>Deseja lançar o movimento?</p>'
	
	ConOut(cMsg)
	
	
	If (!::Exist('R', dtos(cData), cBanco, cAgencia, cConta, cCLVL, cCC, cNatureza, nIcmAuto))
		If (nIcmAuto > 0)
			
			_lConfirm := .F.
			If (IsBlind())
				_lConfirm := .T.
			Else
				_lConfirm := MsgNoYes(cMsg, "Confirma?")
			EndIf
			
			If (_lConfirm)
				
				lRet := StartJob("U_TWMICMAE", GetEnvServer(), .T., ::cCodEmp, ::cCodFil, cData, nIcmAuto, cNatureza, cBanco, cAgencia, cConta, cCC, cCLVL, cHistorico)
				
				If lRet
					MsgAlert('Movimentação de ICMS Frete inserido com sucesso.', 'Sucesso')
				Else
					MsgAlert('Erro no inserção do ICMS de Frete.', 'Erro')
				EndIf
				
				//::ExecMovBanc(cData, nIcmAuto, cNatureza, cBanco, cAgencia, cConta, cCC, cCLVL)
				
			EndIf
		EndIf
	EndIf			
		
Return 

Method ExecMovBanc(cData, nIcmAuto, cNatureza, cBanco, cAgencia, cConta, cCC, cCLVL, cHistorico) Class TWMovimentoICMSAutonomo

	Local lRet := .T.
	
	oObjMovBanc := TAFMovimentoBancario():New()
			
	oObjMovBanc:cRecPag			:= 'R'
	oObjMovBanc:dData 			:= cData
	oObjMovBanc:dDigit 			:= cData
	oObjMovBanc:dDispo 			:= cData
	oObjMovBanc:cMoeda 			:= 'M1'
	oObjMovBanc:nValor 			:= nIcmAuto
	oObjMovBanc:cNatureza 		:= cNatureza
	oObjMovBanc:cBanco 			:= PADR(cBanco, TamSx3("A6_COD")[1]) 
	oObjMovBanc:cAgencia 		:= PADR(cAgencia, TamSx3("A6_AGENCIA")[1]) 
	oObjMovBanc:cConta 			:= PADR(cConta, TamSx3("A6_NUMCON")[1]) 
	oObjMovBanc:cHistorico 		:= cHistorico
	oObjMovBanc:cCentroCusto 	:= cCC
	oObjMovBanc:cClasseValor 	:= cCLVL
	oObjMovBanc:nIdApi 			:= 0
	
	//varinfo("oObjMovBanc", oObjMovBanc)
	
	If oObjMovBanc:Insert()
		lRet := .T.
		//MsgAlert('Movimentação de ICMS Frete inserido com sucesso.', 'Sucesso')
	Else
		lRet := .F.
		//MsgAlert('Erro no inserção do ICMS de Frete.', 'Erro')
	EndIf
	
Return lRet