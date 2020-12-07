#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

User Function FCLA0047; Return()

/*
|------------------------------------------------------------|
| Classe:	| TBiaComposicaoDesconto						 |
| Autor:	| Fernando Rocha - Facile Sistemas				 |
| Data:		| 24/08/15										 |
|------------------------------------------------------------|
| Desc.:	| Classe para estrutura de dados  da composicao  |
| 			| do desconto no pedido de venda                 |
|------------------------------------------------------------|
*/

Class TBiaComposicaoDesconto From LongClassName

Data oInterface
Data oLst

Method New() Constructor
Method Get(cPedidoItem)  //Buscar a composicao do desconto ja gravada na tabela ZA4

Method GetFromObj(oDesconto)
Method GetFromPar(_cCliente, _cVendedor, _cProduto, _lPaletizado, _nPICMS, _nPPIS, _nPCOF, _nAComis)  //Processar a composicao do desconto por parametros

EndClass


Method New() Class TBiaComposicaoDesconto

	::oInterface	:= TIBiaComposicaoDesconto():New()
	::oLst 			:= ArrayList():New()

Return()

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Metodo para buscar os descontos da politica baseado na tabela gravada (DETALHADO -> Tabela ZA4)
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method Get(cPedidoItem) Class TBiaComposicaoDesconto

	::oLst := ArrayList():New()


	ZA4->(DbSetOrder(1))
	If ZA4->(DbSeek(XFilial("ZA4")+cPedidoItem+"DCAT"))

		While !ZA4->(EOF()) .And. ZA4->(ZA4_FILIAL+ZA4_PEDIDO+ZA4_ITEM+ZA4_TIPO) == (XFilial("ZA4")+cPedidoItem+"DCAT")

			If !(ZA4->ZA4_STATUS == "X") .And. ZA4->ZA4_PDESC == 0 .And. ZA4->ZA4_CADDAT <= STOD("20190801")

				LjMsgRun("Aguarde... reprocessando historico de politica",,{|| fBPRECZA4(ZA4->ZA4_PEDIDO) })				
				Exit

			EndIf

			ZA4->(dbSkip())
		EndDo

	EndIf


	ZA4->(DbSetOrder(1))
	If ZA4->(DbSeek(XFilial("ZA4")+cPedidoItem))

		While !ZA4->(EOF()) .And. ZA4->(ZA4_FILIAL+ZA4_PEDIDO+ZA4_ITEM) == (XFilial("ZA4")+cPedidoItem)

			//descontos excluidos por eventual alteracao de pedidos
			If (ZA4->ZA4_STATUS == "X")
				ZA4->(dbSkip())	
				loop
			EndIf

			::oInterface := TIBiaComposicaoDesconto():New()

			::oInterface:Pedido    := ZA4->ZA4_PEDIDO
			::oInterface:Item      := ZA4->ZA4_ITEM
			::oInterface:CodReg    := ZA4->ZA4_CODREG
			::oInterface:Tipo      := ZA4->ZA4_TIPO
			::oInterface:PDesc     := ZA4->ZA4_PDESC
			::oInterface:PVCat     := ZA4->ZA4_PVCAT
			::oInterface:PVSol     := ZA4->ZA4_PVSOL
			::oInterface:PICM      := ZA4->ZA4_PICM
			::oInterface:PPIS      := ZA4->ZA4_PPIS
			::oInterface:PCOF      := ZA4->ZA4_PCOF
			::oInterface:PComis    := ZA4->ZA4_PCOMIS
			::oInterface:FC        := ZA4->ZA4_FC
			::oInterface:PDesc_Ori := ZA4->ZA4_PDORI

			::oLst:Add(::oInterface)

			ZA4->(dbSkip())	
		EndDo 

	EndIf

Return(::oLst) 

Static Function fBPRECZA4(_cPed) 

	U_BPRECZA4(_cPed)

Return


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Metodo para buscar os descontos da politica baseado nos parametros da venda (DETALHADO -> Tabela ZA4)
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Method GetFromObj(oDesconto)  Class TBiaComposicaoDesconto
	//oDesconto => TBiaPoliticaDesconto

	If ( oDesconto <> Nil )
		::GetFromPar(oDesconto:_cCliente, oDesconto:_cVendedor, oDesconto:_cProduto, oDesconto:_cLote, oDesconto:_lPaletizado, oDesconto:_nPICMS, oDesconto:_nPPIS, oDesconto:_nPCOF, oDesconto:_nAComis)
	EndIf

Return(::oLst)

Method GetFromPar(_cCliente, _cVendedor, _cProduto, _cLote, _lPaletizado, _nPICMS, _nPPIS, _nPCOF, _nAComis)  Class TBiaComposicaoDesconto

	Local aAreaB1 := SB1->(GetArea())
	Local aAreaZ7 := ZZ7->(GetArea())
	Local lRet := .T.
	Local cEmpSql
	Local cSpName
	Local _aRet
	Local _cAliasDet
	Local _cSQL

	//Funcao SQL para retornar os descontos
	cEmpSql := AllTrim(CEMPANT)  //ver regra LM 

	If (AllTrim(CEMPANT) == "07")

		//buscando a marca do produto
		SB1->(DbSetOrder(1))
		IF SB1->(DbSeek(XFilial("SB1")+_cProduto))
			ZZ7->(DbSetOrder(1))
			If ZZ7->(DbSeek(XFilial("ZZ7")+SB1->(B1_YLINHA+B1_YLINSEQ))) .And. !Empty(ZZ7->ZZ7_EMP)
				cEmpSql := SubStr(ZZ7->ZZ7_EMP,1,2)
			EndIf
		ENDIF

	EndIf

	//Funcao SQL para retornar os descontos
	cEmpSql := "01"  //PROJETO CONSOLIDA«√O - POLITICAS COMERCIAIS TODAS CONCENTRADAS NA BIANCOGRES

	cSpName := "SP_POL_TAB_POLITICA_"+cEmpSql

	IF TCSPEXIST(cSpName)

		_cAliasDet := GetNextAlias()
		_cSQL := "EXEC "+cSpName+" '"+XFilial("ZA0")+"', '"+_cCliente+"' , '"+_cVendedor+"', '"+_cProduto+"', '"+_cLote+"', "+AllTrim(Str(IIf(_lPaletizado,1,0)))+", "+AllTrim(Str(_nPICMS))+", "+AllTrim(Str(_nPPIS))+", "+AllTrim(Str(_nPCOF))+", "+AllTrim(Str(_nAComis))+" "
		TCQuery _cSQL Alias (_cAliasDet) New

		If !(_cAliasDet)->(Eof())

			While !(_cAliasDet)->(Eof())

				::oInterface := TIBiaComposicaoDesconto():New()

				::oInterface:CodReg    := (_cAliasDet)->CODREG
				::oInterface:Tipo      := (_cAliasDet)->TIPO
				::oInterface:PDesc     := (_cAliasDet)->PDESC
				::oInterface:PVCat     := (_cAliasDet)->PVCAT
				::oInterface:PVSol     := (_cAliasDet)->PVSOL
				::oInterface:PICM      := (_cAliasDet)->PICM
				::oInterface:PPIS      := (_cAliasDet)->PPIS
				::oInterface:PCOF      := (_cAliasDet)->PCOF
				::oInterface:PComis    := (_cAliasDet)->PCOMIS
				::oInterface:FC        := (_cAliasDet)->FC
				::oInterface:PDesc_Ori := (_cAliasDet)->PDESC_ORI

				::oLst:Add(::oInterface)		     

				(_cAliasDet)->(DbSkip())
			EndDo                       

			(_cAliasDet)->(DbCloseArea())

		EndIf

	ENDIF

	RestArea(aAreaB1)
	RestArea(aAreaZ7)

Return(::oLst) 


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//Classe com a estrutura de dados
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Class TIBiaComposicaoDesconto From LongClassName

	Data Pedido
	Data Item
	Data CodReg
	Data Tipo
	Data PDesc
	Data PVCat
	Data PVSol
	Data PICM
	Data PPIS
	Data PCOF
	Data PComis
	Data FC   
	Data PDesc_Ori

	Method New() Constructor

EndClass

Method New() Class TIBiaComposicaoDesconto

	::Pedido    := ""
	::Item      := ""
	::CodReg    := ""
	::Tipo      := ""
	::PDesc     := 0
	::PVCat     := 0
	::PVSol     := 0
	::PICM      := 0
	::PPIS      := 0
	::PCOF      := 0
	::PComis    := 0
	::FC        := 0 
	::PDesc_Ori := 0

Return()