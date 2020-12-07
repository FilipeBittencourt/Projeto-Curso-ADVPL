#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BIA826		      ºAutor  ³ Ranisses A. Corona º Data ³  13/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Grava Vendedor/Comissao no Pedido de Venda    				          	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BIA826()
Local _cMVLIBRES	:= AllTrim(GetMV("MV_YLIBRES"))
Local _cLibPath		:= ""
Local lOld			:= GetMV("MV_YOLDPED") //Parametro que define utilizacao da Analise de Pedido / .T. => REGRA ANTIGA / .F. => REGRA NOVA
Local cFiltro		:= ""

If lOld
	
	If Alltrim(CUSERNAME)$ "RANISSES_WANISAY_wanisay"
		
		DbSelectArea("SZM")
		DbSetOrder(1)
		
		aRotina  := {  { "Pesquisar"  ,'AxPesqui'    , 0 , 1  } ,;
		{ "Visualizar" ,'AxVisual'    , 0 , 2  } ,;
		{ "Incluir"    ,'AxInclui'    , 0 , 4   },;
		{ "Alterar"    ,'AxAltera'    , 0 , 4   } }
		
		cCadastro := "Aprovadores Pedido Venda"
		SZM->(mBrowse(06,01,22,75,"SZM"))
		
	Else
		
		
		_cStr := _cMVLIBRES
		While AT("=",_cStr) > 0
			_nAt1 := AT("=",_cStr)
			_nAt2 := AT("/",_cStr)
			
			if (_nAt1 <= 0 .Or. _nAt2 <= 0)
				MsgStop("Erro na configuração da função. Verificar com setor de T.I")
				Break
			endif
			
			_cUser := SUBSTR(_cStr, _nAt1+1, (_nAt2-_nAt1-1))
			_cPath := SUBSTR(_cStr, 1, _nAt1-1)
			
			If (Upper(Alltrim(cUserName)) == Upper(Alltrim(_cUser)))
				_cLibPath += _cPath+"#"
			EndIf
			
			_cStr := SUBSTR(_cStr,_nAt2+1)
		EndDo
		
		IF !Empty(_cLibPath)
			
			_bCondicao := {|| ZM_LINHA+ZM_TIPO $ _cLibPath }
			_cCondicao := "ZM_LINHA+ZM_TIPO $ '"+_cLibPath+"'"
			DbSelectArea("SZM")
			DbSetOrder(1)
			DbSetFilter(_bCondicao,_cCondicao)
			
			aRotina  := {  { "Pesquisar"  ,'AxPesqui'    , 0 , 1  } ,;
			{ "Visualizar" ,'AxVisual'    , 0 , 2  } ,;
			{ "Alterar"    ,'AxAltera'    , 0 , 4   } }
			
			cCadastro := "Aprovadores Pedido Venda"
			SZM->(mBrowse(06,01,22,75,"SZM"))
			
		ENDIF
		
	EndIf
	
Else
	
	If Alltrim(CUSERNAME)$ "RANISSES_WANISAY_wanisay"
		
		SZM->(DbSetOrder(1))
				
		cFiltro := " !Alltrim(SZM->ZM_MARCA) == '' "
		SZM->(DbSetFilter({|| &cFiltro }, cFiltro))
						
		aRotina  := {  	{ "Pesquisar"  ,'AxPesqui'    , 0 , 1  },;
						{ "Visualizar" ,'AxVisual'    , 0 , 2  },;
						{ "Incluir"    ,'AxInclui'    , 0 , 4  },;
						{ "Alterar"    ,'AxAltera'    , 0 , 4  } }
		
		cCadastro := "Aprovadores Pedido Venda"
		SZM->(mBrowse(06,01,22,75,"SZM"))
		
	Else
		
		SZM->(DbSetOrder(1))
		
		cFiltro := " !Alltrim(SZM->ZM_MARCA) == '' .And. SZM->ZM_CODAPRO == '"+__cUserID+"' "
		SZM->(DbSetFilter({|| &cFiltro }, cFiltro))
		
		aRotina  := {  	{ "Pesquisar"  ,'AxPesqui'    , 0 , 1  },;
						{ "Visualizar" ,'AxVisual'    , 0 , 2  },;
						{ "Alterar"    ,'AxAltera'    , 0 , 4  } }
				
		cCadastro := "Aprovadores Pedido Venda"
		SZM->(mBrowse(06,01,22,75,"SZM"))
				
	EndIf
	
EndIf

Return()
