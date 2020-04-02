#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#include "rwmake.ch"
#include "Ap5Mail.ch"
#INCLUDE 'APVT100.CH'
#INCLUDE  "Fileio.ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

/*/{Protheus.doc} TFZLeituraEtiqueta
@description Classe para leitura das etiquetas de venda do produto através do coletor
@author Pontin - Facile Sistemas
@since 14.01.19
@version 1.0
/*/

Class TFZLeituraEtiqueta From LongClassName

	Data cEtiqueta		//|Etiqueta lida pelo coletor |
	Data cTransp		//|Transportadora lida na etiqueta |
	Data cVolume		//|Volume lido na etiqueta |
	Data cPedVenda		//|Pedido de venda lido na etiqueta |
	Data cLayEtiq		//|Tamanho padrão do campo de leitura da etiqueta |
	Data cChvNFe		//|Tamanho padrão do campo de leitura da etiqueta |
	Data cImpZebra		//|Impressora Zebra selecionada |
	Data cImpLaser		//|Impressora Laser selecionada |
	Data aDadosDel		//|Dados a serem excluidos |

	Data oPedVenda		//|Objeto com os dados do pedido de venda |
	Data oCliente		//|Objeto com os dados do cliente |

	//Dados Transportadora
	Data cCodTransp
	Data cRazTransp
	Data cFanTransp

	Method New() Constructor

	Method LerEtiqueta()
	Method VldEtiqueta()    		//|Validacao etiqueta |
	Method BuscaPedido()    		//|Busca o pedido de vendas |
	Method AnalisaChave()			//|Analisa a chave da nota fiscal |
	Method ValidaGNRE()				//|Valida a se a GNRE foi paga |
	Method SelecImpres()			//|Seleciona impressora |
	Method LimpaDir()				//|Realiza a limpeza do diretorio |
	Method DownloadME2()			//|Realiza o download da PLP |
	Method GerarPLP()				//|Realiza a geração da PLP de contrato |

	Method LimpVar()    			//|Limpa as variaveis da rotina |
	Method Destroy()    			//|Elimina os objetos |

EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
description método construtor da classe
@author  Pontin - Facile Sistemas
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method New() Class TFZLeituraEtiqueta

	::LimpVar()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpVar
description Limpa as variaveis da rotina
@author  Pontin - Facile Sistemas
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method LimpVar() Class TFZLeituraEtiqueta

	::cEtiqueta		:= ""
	::cTransp		:= ""
	::cVolume		:= ""
	::cPedVenda		:= ""
	::cLayEtiq		:= Space(TamSX3("C5_TRANSP")[1] + TamSX3("C5_VOLUME1")[1] + TamSX3("C5_NUM")[1])
	::cChvNFe		:= ""
	::aDadosDel		:= {}

	::cCodTransp	:= ""
	::cRazTransp	:= ""
	::cFanTransp	:= ""

	::oPedVenda		:= Nil
	::oCliente		:= Nil

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} LerEtiqueta
description Efetua a leitura do código de barras da etiqueta
@author  Pontin - Facile Sistemas
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method LerEtiqueta() Class TFZLeituraEtiqueta

	If Type('oSigep') <> 'O'
		oSigep	:= ServSigep():New()
	EndIf

	::cImpZebra	:= ""
	::cImpLaser	:= ""

	//|Seta o atalho CTRL + P para Gerar a PLP |
	VTSetKey(K_CTRL_P,{|| ::GerarPLP()},'Gerar PLP')

	//|Seleciona impressoras |
	While Empty(::cImpZebra) .And. Empty(::cImpLaser)

		If Empty(::cImpZebra)
			::SelecImpres("ZEBRA")
		EndIf

		If Empty(::cImpLaser)
			::SelecImpres("LASER")
		EndIf

	EndDo

	//|Leia a Etiqueta até que seja correta |
	While .T.

		VtClear()

		::Destroy()

FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 134", 0, 0, {})

		//|Limpa a etiqueta com espaços para nova leitura |
		::cEtiqueta = ::cLayEtiq

		VTBeep(2)

		DLVTCabec("Leitor de Etiquetas "  +  cEmpAnt + cFilAnt + "    ", .F., .F., .T.)

		@ 02, 00 VTSay 'CONF.:' + UPPER(Alltrim(cUserName))
		@ 04, 00 VTSay 'Ler Etiqueta'
		@ 05, 00 VTGet ::cEtiqueta Picture "@!"

		VTRead

		//|Verifica se aborta = Tecla ESC |
		If VTLastKey() == 27
			VTClear()
			Exit
		EndIf

		//|Verifica se a Etiqueta está Valida |
		VTAlert("Validando etiqueta...","Aviso",.T.,2000)

FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 158", 0, 0, {})

		If ::VldEtiqueta()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 160", 0, 0, {})

			::AnalisaChave()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 162", 0, 0, {})

		Else
			::LimpVar()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 165", 0, 0, {})

			Loop
		EndIf

		// Aperte ESC para sair
		If (VTLastKey()==27)
			Exit
		EndIf

	EndDo
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 179", 0, 0, {})

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} VldEtiqueta
description Verifica se foi lido uma etiqueta valida
@author  Pontin - Facile Sistemas
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method VldEtiqueta() Class TFZLeituraEtiqueta

	Local nPos		:= 1
	Local aRetGNRE	:= {}

	//|Verifica se a etiqueta está em branco |
	If Empty(::cEtiqueta)
		VTBeep(3)
		VTAlert("Etiqueta em Branco, Favor ler novamente...","Aviso",.T.,2000)
		Return .F.
	EndIf






	//|TRATAMENTO TEMPORARIO PARA GERAR PLP DE CONTRATO |
	If Upper(AllTrim(::cEtiqueta)) == "GERARPLP"
		::GerarPLP()
		Return .F.
	EndIf









	//|Verifica se o tamanho é valido |
	If Len(::cEtiqueta) <> Len(::cLayEtiq)
		VTBeep(3)
		VTAlert("Etiqueta Invalida, Favor ler novamente...","Aviso",.T.,2000)
		Return .F.
	EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 224", 0, 0, {})

	//|Carrega as variaveis |
	::cTransp	:= PADR(Alltrim(::cEtiqueta),TAMSX3("ZH_TRANSP")[1]); nPos += TAMSX3("ZH_TRANSP")[1]
	::cVolume	:= SubStr(::cEtiqueta,nPos,TAMSX3("ZH_VOLCONF")[1]);  nPos += TAMSX3("ZH_VOLCONF")[1]
	::cPedVenda := SubStr(::cEtiqueta,nPos,TAMSX3("C5_NUM")[1])
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 229", 0, 0, {})

	::BuscaPedido()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 231", 0, 0, {})

	If !::oPedVenda:lAchouPed
		VTBeep(3)
		VTAlert("Pedido: " + ::oPedVenda:cPedNum + " nao localizado","Aviso",.T.,2000)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 235", 0, 0, {})

		Return .F.
	EndIf

	If Empty(::oPedVenda:cPedNF)
		VTBeep(3)
		VTAlert("Pedido de venda não se encontra faturado","Aviso",.T.,2000)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 242", 0, 0, {})

		Return .F.
	EndIf

	If "XXXXXX" $ ::oPedVenda:cPedNF
		VTBeep(3)
		VTAlert("Pedido de venda foi eliminado residuo","Aviso",.T.,2000)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 249", 0, 0, {})

		Return .F.
	EndIf

	//|Verifica se a NF está transmitida e com chave |
	dbSelectArea("SF2")
	SF2->(dbSetOrder(1))
	If SF2->(dbSeek(::oPedVenda:cFilialx + ::oPedVenda:cPedNF + ::oPedVenda:cPedSerie + ::oCliente:cCodClient + ::oCliente:cCodLoja ))
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 257", 0, 0, {})

		If !Empty(SF2->F2_CHVNFE)

			::cChvNFe	:= SF2->F2_CHVNFE

		Else
			VTBeep(3)
			VTAlert("Nota Fiscal nao esta transmitida e autorizada","Aviso",.T.,2000)
			Return .F.
		EndIf

	Else
		VTBeep(3)
		VTAlert("Nota Fiscal nao encontrada","Aviso",.T.,2000)
		Return .F.
	EndIf

	//|Valida a GNRE da NF |
	aRetGNRE	:= ::ValidaGNRE(SF2->(Recno()))
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 276", 0, 0, {})

	If !aRetGNRE[1]
		VTBeep(3)
		VTAlert(aRetGNRE[2],"Aviso",.T.,2000)
		Return .F.
	EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 294", 0, 0, {})

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaPedido
description Busca o pedido referente a etiqueta
@author  Pontin - Facile Sistemas
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method BuscaPedido() Class TFZLeituraEtiqueta

	Local cChvSC5	:= xFilial("SC5") + ::cPedVenda
	Local cChvSA1	:= ""
	Local oPedVendD := Nil
	Local oClienteD	:= Nil

	//|Carrega os dados do Pedido de Venda |
	oPedVendD 	:= TEZPedidoVendaController():New()
	::oPedVenda	:= oPedVendD:Get(cChvSC5, 1)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 304", 0, 0, {})

	//|Verifica se conseguiu encontrar o pedido de venda |
	If !::oPedVenda:lAchouPed
		Return
	EndIf

	//|Carrega os dados da Transportadora (SA4) |
	dbSelectArea("SA4")
	SA4->(dbSetOrder(1))
	SA4->(dbSeek(xFilial("SA4") + ::oPedVenda:cTransp))
	::cCodTransp	:= SA4->A4_COD
	::cRazTransp 	:= SA4->A4_NOME
	::cFanTransp  	:= SA4->A4_NREDUZ

	//Carrega os dados do Cliente (SA1)
	cChvSA1		:= xFilial("SA1")+ SC5->C5_CLIENTE + SC5->C5_LOJACLI
	oClienteD 	:= TEZClienteController():New()
	::oCliente 	:= oClienteD:Get(cChvSA1, 1)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 322", 0, 0, {})

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} AnalisaChave
description Analisa a chave da nota fiscal eletronica
@author  Pontin - Facile Sistemas
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method AnalisaChave() Class TFZLeituraEtiqueta

	Local aRet		 	:= ""
	Local cModFrete		:= ""
	Local cNomDanfe		:= ""
	Local cAliasZZB		:= ""
	Local cAliasSF6		:= ""
	Local cLocalArm		:= "0801"	//|Henrique afirmou via whatsapp que sempre será 0801 |
	Local cRaiz			:= GetSrvProfString("ROOTPATH","")
	Local cChave	 	:= ::cChvNFe
	Local cTransp 		:= SuperGetMV("MV_Y189TRA",.F.,'000901/000902/000903/000703')
	Local cCodPAC		:= SuperGetMV("MV_YCONPAC",.F.,'41068,41211,04669')
	Local nVezes		:= 3
	Local nX			:= 0
	Local nZ			:= 0
	Local aME2			:= {}
	Local aArqPLP		:= {}
	Local aDados		:= {}
	Local lImpZPL		:= .F.
	Local lImpDanfe		:= .F.
	Local lImpPLP		:= .F.
	Local lImpAR		:= .F.

	Private cAlias 	 	:= ""
	Private oBjMEnvios 	:= Nil
	Private oObjImprime	:= Nil
	Private oObjImpLaser:= Nil
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 361", 0, 0, {})

	If !Empty(cTransp)
		cTransp := ' AND SF2.F2_TRANSP IN ' + FormatIn(cTransp,'/')
	Else
		cTransp := " AND 1 = 1 "
	End If

	cTransp := '% '+cTransp+' %'

	cAlias := GetNextAlias()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 371", 0, 0, {})

	BeginSql Alias cAlias

		SELECT
		    F2_DOC,
		    F2_SERIE,
		    F2_TRANSP,
		    F2_CLIENTE,
		    F2_LOJA,
		    F2_EMISSAO,
		    F2_CHVNFE,
		    F2_VALBRUT,
			F2_VOLUME1,
		    (
		        SELECT TOP 1
		            D2_CF
		        FROM
		            %table:SD2% SD2
		        WHERE
		            D2_FILIAL = F2_FILIAL
		            AND D2_DOC = F2_DOC
		            AND D2_SERIE = F2_SERIE
		            AND D2_CLIENTE = F2_CLIENTE
		            AND D2_LOJA = F2_LOJA
		            AND SD2.D_E_L_E_T_ = ""
		    ) D2_CF,
		    A1_INSCR,
		    ZZB_DOC,
			ISNULL(ZZB.R_E_C_N_O_,0) AS RECZZB,
		    SA4.A4_YSERVIC,
		    VT1_MODFRE,
		    VT1_IDCART,
		    VT1_ORDID,
		    VT1_SEQUEN,
		    VT1_API
		FROM
		    %table:SF2% SF2
		    JOIN %table:SC5% SC5 ON (
		                           C5_FILIAL = %xFilial:SC5%
		                           AND SF2.F2_DOC = SC5.C5_NOTA
		                           AND SF2.F2_SERIE = SC5.C5_SERIE
								   AND SC5.D_E_L_E_T_ = ""
		                       )
		    JOIN %table:SA1% SA1 ON (
		                           A1_FILIAL = %xFilial:SA1%
		                           AND SF2.F2_CLIENTE = SA1.A1_COD
		                           AND SF2.F2_LOJA = SA1.A1_LOJA
								   AND SA1.D_E_L_E_T_ = ""
		                       )
		    JOIN %table:SA4% SA4 ON (
		                           A4_FILIAL = %xFilial:SA4%
		                           AND SA4.A4_COD = SF2.F2_TRANSP
								   AND SA4.D_E_L_E_T_ = ""
		                       )
		    LEFT JOIN %table:VT1% VT1 ON (
		                                VT1_FILIAL = %xFilial:VT1%
		                                AND SC5.C5_NUM = VT1.VT1_NUMPED
										AND VT1.D_E_L_E_T_ = ""
		                            )
		    LEFT JOIN %table:VT4% VT4 ON (
		                                VT4_FILIAL = %xFilial:VT4%
		                                AND VT4.VT4_ORDID = VT1.VT1_ORDID
		                                AND VT4_EMPFOR + VT4_FILFOR = %Exp:cLocalArm%
										AND VT4.D_E_L_E_T_ = ""
		                            )
		    LEFT JOIN %table:ZZB% ZZB ON (
		                                ZZB_FILIAL = %xFilial:ZZB%
		                                AND ZZB.ZZB_DOC = SF2.F2_DOC
		                                AND ZZB.ZZB_SERIE = SF2.F2_SERIE
										AND ZZB.D_E_L_E_T_ = ' '
		                            )
		WHERE
		    SF2.F2_FILIAL = %xFilial:SF2%
		    AND SF2.F2_TIPO = 'N'
		   	%Exp:cTransp%
		    AND F2_CHVNFE = %Exp:cChave%
			AND SF2.D_E_L_E_T_ = ""

	EndSQL
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 449", 0, 0, {})

	If (cAlias)->(EoF())
		VTBeep(3)
		VTAlert("Nota fiscal nao existe ou o transporte nao e Correios!","Aviso",.T.,2000)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 453", 0, 0, {})

		Return .F.
	Else

		If (cAlias)->RECZZB > 0
			VTAlert("Nao e permitido reimprimir etiqueta!","Aviso",.T.,4000)
			Return .F.
		EndIf

		cModFrete := AllTrim((cAlias)->VT1_MODFRE)

		For nX := 1 To nVezes

			::LimpaDir(::aDadosDel)
			::Destroy()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 462", 0, 0, {})

			oBjMEnvios 		:= MEnviosRastreamento():New()
			oObjImprime		:= TFZImprimeEtiqueta():New()
			oObjImpLaser	:= TFZImprimeLaser():New()

			//|Caso tenha GNRE não imprime a DANFE|
			cAliasSF6 := GetNextAlias()

			BeginSql Alias cAliasSF6

			SELECT F6_NUMERO
			FROM SF6090 SF2
			WHERE F6_FILIAL = %xFilial:SF6%
					AND F6_DOC = %Exp:(cAlias)->F2_DOC%
					AND F6_SERIE = %Exp:(cAlias)->F2_SERIE%
					AND SUBSTRING(F6_NUMERO, 1, 3) = 'ICM'
					AND D_E_L_E_T_ = ''

			EndSQL

			(cAliasSF6)->(dbGoTop())

			If !(cAliasSF6)->(EoF())
				lImpDanfe		:= .T.
			EndIf

			If lImpZPL .And. lImpDanfe .And. lImpPLP .And. lImpAR
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 468", 0, 0, {})

				//|Exclui os arquivos gerados |
				If Len(::aDadosDel) > 0
					::LimpaDir(::aDadosDel)
				EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 473", 0, 0, {})

				VTAlert("Processamento concluido!!","Aviso",.T.,2000)
				Exit
			EndIf

			If cModFrete == "ME2"	//|Venda Mercado Livre |

				//|Mercado Livre não imprime AR |
				lImpAR	:= .T.

				oBjMEnvios:cOrdId	:= (cAlias)->VT1_ORDID
				oBjMEnvios:cSequen  := (cAlias)->VT1_SEQUEN
				oBjMEnvios:cIdCart  := (cAlias)->VT1_IDCART
				oBjMEnvios:cApi     := (cAlias)->VT1_API
				oBjMEnvios:cDoc     := (cAlias)->F2_DOC
				oBjMEnvios:cSerie   := (cAlias)->F2_SERIE
				oBjMEnvios:cCliente := (cAlias)->F2_CLIENTE
				oBjMEnvios:cLoja    := (cAlias)->F2_LOJA
				oBjMEnvios:cEmissao := (cAlias)->F2_EMISSAO
				oBjMEnvios:cServico := (cAlias)->A4_YSERVIC
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 493", 0, 0, {})

				//|Imprime etiqueta ZPL |
				If !lImpZPL

					aRet := oBjMEnvios:GetAtuRastro(.T.,.T.)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 498", 0, 0, {})

					If aRet[1]
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 500", 0, 0, {})

						//|JADLOG não imprime PLP |
						If "JADLOG" $ aRet[2]
							lImpPLP := .T.
						EndIf

						//|Imprime a Etiqueta ZPL |
						oObjImprime:cPrinter	:= ::cImpZebra
						oObjImprime:cEtiqZPL	:= aRet[2]
						If oObjImprime:ImprimeZPL()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 510", 0, 0, {})

							VTAlert("Etiqueta Impressa!!","Aviso",.T.,2000)
							lImpZPL	:= .T.

						EndIf

					Else
						VTAlert("Erro: " + aRet[2],"Aviso",.T.,4000)
						Return .F.
					EndIf

				EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 545", 0, 0, {})

				//|Imprime a DANFE |
				If !lImpDanfe
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 549", 0, 0, {})

					cNomDanfe	:= "DANFE_" + (cAlias)->F2_CHVNFE + "_" + Dtos(MSDate()) + StrTran(Time(),":","")
					oObjImpLaser:cPrinter	:= ::cImpLaser
					oObjImpLaser:cNumNF		:= (cAlias)->F2_DOC
					oObjImpLaser:cSerieNF	:= (cAlias)->F2_SERIE
					oObjImpLaser:cNomePDF	:= cNomDanfe + ".pdf"
					oObjImpLaser:ImpDanfe()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 557", 0, 0, {})

					If oObjImpLaser:lImpresso

						//|Levanta os arquivos a serem excluidos |
						aDados	:= Directory("\DANFES\" + cNomDanfe + ".*")

						For nZ := 1 To Len(aDados)
							aAdd(::aDadosDel,{"\DANFES\" + aDados[nZ,1],.T.})
						Next nZ
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 567", 0, 0, {})

						VTAlert("DANFE Impressa!!","Aviso",.T.,2000)
						lImpDanfe	:= .T.

					EndIf

				EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 575", 0, 0, {})

				//|Busca o PLP e imprime |
				If !lImpPLP
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 579", 0, 0, {})

					If !Empty(oBjMEnvios:cCodPLP)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 582", 0, 0, {})

						//aRet := oBjMEnvios:GetAtuRastro(.F.,.F.)

						If aRet[1] .And. !Empty(aRet[3])	//|URL para download o ZIP com a PLP |
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 587", 0, 0, {})

							aArqPLP	:= ::DownloadME2(aRet[3])
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 590", 0, 0, {})

							If Len(aArqPLP) > 0 .And. File(aArqPLP[1] + aArqPLP[2] + aArqPLP[3])
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 593", 0, 0, {})

								oObjImpLaser:LimpVar()
								oObjImpLaser:cPrinter	:= ::cImpLaser
								oObjImpLaser:cArqImp	:= cRaiz + aArqPLP[1] + aArqPLP[2] + aArqPLP[3]

								//|Executa a impressão |
								oObjImpLaser:ImpArquivo()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 601", 0, 0, {})

								If oObjImpLaser:lImpresso
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 604", 0, 0, {})

									VTAlert("PLP Impressa!!","Aviso",.T.,2000)
									lImpPLP	:= .T.

								EndIf

							EndIf

						EndIf

					EndIf

				EndIf



			Else

				//|Não imprime PLP e AR para contrato da União |
				lImpPLP		:= .T.
				lImpAR		:= .T.
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 626", 0, 0, {})

				//|Imprime etiqueta ZPL |
				If !lImpZPL
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 631", 0, 0, {})

					//|Gera o rastro na ZZB |
					VTAlert("Gerando Rastro!!","Aviso",.T.,2000)

					cAliasZZB		:= GetNextAlias()
					BeginSql alias cAliasZZB

						SELECT Z.ZZB_RASTRO
						FROM %Table:ZZB% Z
						WHERE Z.ZZB_FILIAL = %xFilial:ZZB%
							AND Z.ZZB_RASTRO <> ''
							AND Z.ZZB_DOC = %Exp:(cAlias)->F2_DOC%
							AND Z.ZZB_SERIE = %Exp:(cAlias)->F2_SERIE%
							AND Z.ZZB_CLIENT = %Exp:(cAlias)->F2_CLIENTE%
							AND Z.ZZB_LOJA = %Exp:(cAlias)->F2_LOJA%
							AND Z.%NotDel%

					EndSql

					(cAliasZZB)->(dbGoTop())
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 651", 0, 0, {})

					If !(cAliasZZB)->(EoF())
						oBjMEnvios:cCodRastr	:= (cAliasZZB)->ZZB_RASTRO
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 655", 0, 0, {})

					Else
						GeraRastro((cAlias)->A4_YSERVIC)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 659", 0, 0, {})

					EndIf

					(cAliasZZB)->(DbCloseArea())
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 664", 0, 0, {})

					//|Atualiza a ZZB com dados para etiqueta |
					GeraEtiqueta()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 668", 0, 0, {})

					If !Empty(oBjMEnvios:cCodRastr)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 671", 0, 0, {})

						dbSelectArea('ZZB')
						ZZB->(dbSetOrder(2))
						If ZZB->(dbSeek(xFilial('ZZB') + oBjMEnvios:cCodRastr))
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 676", 0, 0, {})

							//|Limpa as variaveis de impressão |
							VTAlert("Iniciando impressao da Etiqueta!!","Aviso",.T.,2000)
							oObjImprime:LimpVar()

							oObjImprime:cChvSC5			:= ::oPedVenda:cFilialx + ::oPedVenda:cPedNum
							oObjImprime:nSC5Indice		:= 1
							oObjImprime:cChvSA1			:= ::oCliente:cFilialx + ::oCliente:cCodClient + ::oCliente:cCodLoja
							oObjImprime:nSA1Indice		:= 1

							oObjImprime:cRastro			:= oBjMEnvios:cCodRastr
							oObjImprime:cCodServ		:= SubStr((cAlias)->A4_YSERVIC, 1, 5)
							oObjImprime:nVlrDeclarado	:= Round((cAlias)->F2_VALBRUT, 0)
							oObjImprime:cNumLog			:= "0"
							oObjImprime:cPLP			:= oBjMEnvios:cCodPLP
							oObjImprime:cContrato		:= ZZB->ZZB_SERVIC
							oObjImprime:cTpContrato		:= IIf(AllTrim((cAlias)->A4_YSERVIC) $ cCodPAC,"PAC","SEDEX")
							oObjImprime:cCartao			:= ""

							oObjImprime:cPrinter		:= ::cImpZebra
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 697", 0, 0, {})

							If oObjImprime:MontaZPL()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 700", 0, 0, {})

								RecLock("ZZB",.F.)
								If ZZB->(FieldPos("ZZB_DTPRIN")) > 0
									ZZB->ZZB_DTPRIN	:= dDataBase
									ZZB->ZZB_HRPRIN	:= SubStr(Time(),1,5)
								EndIf
								ZZB->(MsUnLock())
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 708", 0, 0, {})

								lImpZPL	:= .T.

							EndIf

						EndIf

					EndIf

				EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 719", 0, 0, {})

				//|Imprime a DANFE |
				If !lImpDanfe
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 723", 0, 0, {})

					cNomDanfe	:= "DANFE_" + (cAlias)->F2_CHVNFE + "_" + Dtos(MSDate()) + StrTran(Time(),":","")
					oObjImpLaser:cPrinter	:= ::cImpLaser
					oObjImpLaser:cNumNF		:= (cAlias)->F2_DOC
					oObjImpLaser:cSerieNF	:= (cAlias)->F2_SERIE
					oObjImpLaser:cNomePDF	:= cNomDanfe + ".pdf"
					oObjImpLaser:ImpDanfe()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 731", 0, 0, {})

					If oObjImpLaser:lImpresso
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 734", 0, 0, {})

						//|Levanta os arquivos a serem excluidos |
						aDados	:= Directory("\DANFES\" + cNomDanfe + ".*")

						For nZ := 1 To Len(aDados)
							aAdd(::aDadosDel,{"\DANFES\" + aDados[nZ,1],.T.})
						Next nZ
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 742", 0, 0, {})

						VTAlert("DANFE Impressa!!","Aviso",.T.,2000)
						lImpDanfe	:= .T.

					EndIf

				EndIf

			EndIf

		Next nX

		If !lImpZPL
			VTAlert("Falha ao imprimir a etiqueta!!","Aviso",.T.,2000)
		EndIf

		If !lImpDanfe
			VTAlert("Falha ao imprimir a DANFE!!","Aviso",.T.,2000)
		EndIf

		If !lImpPLP
			VTAlert("Falha ao imprimir a PLP!!","Aviso",.T.,2000)
		EndIf

		If !lImpAR
			VTAlert("Falha ao imprimir a AR!!","Aviso",.T.,2000)
		EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 770", 0, 0, {})


	EndIf

FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 775", 0, 0, {})


Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} DownloadME2
description Realiza o download da PLP
@author  Pontin - Facile Sistemas
@since   14.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method DownloadME2(cUrl) Class TFZLeituraEtiqueta

	Local cHeaderRet	:= ""
	Local cArqui		:= ""
	Local cFile			:= "MEnvios" + __cUserID + "-" + dToS(Date()) + "-" + StrTran(Time(), ":", "") + ".zip"
	Local cDirTmp		:= "\PLPS\"
	Local cDirZIP		:= AllTrim(IIf(Empty((cAlias)->VT1_IDCART),__cUserID + "-" + dToS(Date()) + "-" + StrTran(Time(), ":", ""),(cAlias)->VT1_IDCART)) + "\"
	Local nHandle		:= 0
	Local nRetZip		:= 0
	Local nZ			:= 0
	Local aRet			:= {}
	Local aDados		:= {}

	Default cUrl		:= ""
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 800", 0, 0, {})

	//|Verifica e cria o diretório para salvar a Danfe |
	If !ExistDir(cDirTmp + cDirZIP)
		FWMakeDir( cDirTmp + cDirZIP, .F. )
	EndIf

	//|Exclui o arquivo, caso já exista |
	If File(cDirTmp + cDirZIP + cFile)
		fErase(cDirTmp + cDirZIP + cFile)
	EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 811", 0, 0, {})

	If !Empty(cUrl)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 814", 0, 0, {})

		If !File(cDirTmp + cDirZIP + cFile)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 817", 0, 0, {})

			nHandle := FCreate(cDirTmp + cDirZIP + cFile)

			cArqui := HTTPGET(cUrl,,,,@cHeaderRet)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 822", 0, 0, {})

			FWrite(nHandle, cArqui)

			FClose(nHandle)

			//|Descompacta o ZIP |
			nRetZip := FUnZip(cDirTmp + cDirZIP + cFile,cDirTmp + cDirZIP,)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 830", 0, 0, {})

			If nRetZip != 0
				VTAlert("Nao foi possivel descompactar a PLP!!","Aviso",.T.,2000)
			Else

				aDados	:= Directory(cDirTmp + cDirZIP + "*.pdf")

				If Len(aDados) > 0

					cFile	:= aDados[1,1]
					aRet	:= {cDirTmp, cDirZIP, cFile}

				Else
					VTAlert("PLP nao encontrada!!","Aviso",.T.,2000)
				EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 846", 0, 0, {})

				//|Levanta os arquivos a serem excluidos |
				aDados	:= Directory(cDirTmp + cDirZIP + "*.*")

				For nZ := 1 To Len(aDados)
					aAdd(::aDadosDel,{aDados[nZ,1],.T.})
				Next nZ

				aAdd(::aDadosDel,{cDirTmp + cDirZIP,.F.})

			EndIf

		EndIf

	EndIf

FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 863", 0, 0, {})


Return aRet


/*/{Protheus.doc} GeraRastro
Monta uma tela para obter uma sequencia de números de rastros nos correios
@author henrique
@since 05/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraRastro(cServico)

	Local cAliasZZB		:= GetNextAlias()
	Local cRet			:= ''
	Local nI			:= 0
	Local nQuantidade	:= 30
	Local nPos			:= 0
	//Private oSigep		:= ServSigep():New()

	If Type('oSigep') <> 'O'
		oSigep	:= ServSigep():New()
	EndIf

FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 892", 0, 0, {})

	oBjMEnvios:cCodRastr	:= ""

	Default cServico	:= SuperGetMv("MV_YSIGCOD", .F., '04669') //'41068'
	cServico := AllTrim(cServico)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 898", 0, 0, {})

	BeginSql alias cAliasZZB
		SELECT ZZB_RASTRO, ZZB_SERVIC
		FROM (	SELECT LEFT(ZZB.ZZB_RASTRO, 2) TIPO
				FROM %Table:ZZB% ZZB
				WHERE ZZB.ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel%
					AND ZZB_DOC = ''
				GROUP BY LEFT(ZZB.ZZB_RASTRO, 2)
			) RAST

		CROSS APPLY (
				SELECT TOP 10 ZZB_RASTRO, ZZB_SERVIC
				FROM %Table:ZZB% ZZB
				WHERE ZZB.ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel%
					AND ZZB_DOC = '' AND RAST.TIPO = LEFT(ZZB.ZZB_RASTRO, 2)
			) ZZB
		ORDER BY
			ZZB_RASTRO

	EndSql

	(cAliasZZB)->(dbGoTop())
	While !(cAliasZZB)->(EoF())
		If cServico == AllTrim((cAliasZZB)->ZZB_SERVIC)
			oBjMEnvios:cCodRastr	:= (cAliasZZB)->ZZB_RASTRO
			Return
		EndIf

		(cAliasZZB)->(DbSkip())
	EndDo
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 929", 0, 0, {})

	oSigep:LimpCampos()

	nPos := aScan(oSigep:aServicos, {|x|AllTrim(x[1])==cServico})

	If nPos == 0
		VTBeep(3)
		VTAlert('O serviço "'+cServico+'" informado na transportadora nao foi implementado ou nao faz parte do contrato da empresa!',"Aviso",.T.,2000)
		Return .F.
	EndIf

	nQuantidade	:= oSigep:aServicos[nPos, 5]

	oSigep:nQuantidade 		:= nQuantidade
	oSigep:cServico 		:= cServico
	cRet := oSigep:ReservarEtiquetas()

	For nI := 1 To Len(oSigep:aEtiquetas)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 948", 0, 0, {})

		oBjMEnvios:cCodRastr := oSigep:aEtiquetas[nI, 3]
		If SubStr(oBjMEnvios:cCodRastr, 11,1) == ' '
			oBjMEnvios:cCodRastr := GeraDigitoVerificador(oBjMEnvios:cCodRastr)
		EndIf

		If SubStr(oBjMEnvios:cCodRastr, 11,1) <> ' '

			dbSelectArea("ZZB")
			ZZB->(dbSetOrder(2))
			If !ZZB->(dbSeek(xFilial("ZZB") + oBjMEnvios:cCodRastr))
				RecLock('ZZB', .T.)
					ZZB->ZZB_FILIAL		:= xFilial('ZZB')
					ZZB->ZZB_RASTRO		:= oBjMEnvios:cCodRastr
					ZZB->ZZB_EMISSA		:= dDataBase
					ZZB->ZZB_SERVIC		:= cServico
				ZZB->(MsUnLock())
			EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 967", 0, 0, {})

		Else
			VTBeep(3)
			VTAlert('Nao foi possivel obter o digito verificador do codigo do Rastreio nos correios, favor tentar mais tarde!',"Aviso",.T.,2000)
		EndIf

	Next nI
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 975", 0, 0, {})

Return


/*/{Protheus.doc} GeraEtiqueta
Gerar um registro na tabela ZZB com o dados de rastreamento
@author henrique
@since 05/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraEtiqueta()

	Local aAreaZZB		:= ZZB->(GetArea())
	Local nVolume		:= Max((cAlias)->F2_VOLUME1, 1)
	Local nI			:= 0
	Local cServico		:= ''

	Local aME2			:= {}
	//Local oBjMEnvios 	:= MEnviosRastreamento():New()

	//Private oSigep		:= ServSigep():New()
	If Type('oSigep') <> 'O'
		oSigep	:= ServSigep():New()
	EndIf

	cServico := AllTrim((cAlias)->A4_YSERVIC)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1003", 0, 0, {})

	If Empty(cServico)
		Return
	EndIf

	oSigep:LimpCampos()

	For nI := 1 To nVolume
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1012", 0, 0, {})

		dbSelectArea('ZZB')
		ZZB->(dbSetOrder(2))

		nPos := aScan(oSigep:aServicos, {|x|AllTrim(x[1])==cServico})

		If nPos == 0
			VTBeep(3)
			VTAlert('O servico "'+cServico+'" informado na transportadora nao foi implementado ou nao faz parte do contrato da empresa!',"Aviso",.T.,2000)
			Return .F.
		EndIf

		If ZZB->(DbSeek(xFilial('ZZB') + oBjMEnvios:cCodRastr))
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1026", 0, 0, {})

			oBjMEnvios:cCodPLP	:= AllTrim((cAlias)->F2_DOC) + AllTrim((cAlias)->F2_SERIE)

			RecLock('ZZB', .F.)
				//ZZB->ZZB_PLP	:= oBjMEnvios:cCodPLP
				ZZB->ZZB_DOC	:= (cAlias)->F2_DOC
				ZZB->ZZB_SERIE	:= (cAlias)->F2_SERIE
				ZZB->ZZB_CLIENT	:= (cAlias)->F2_CLIENTE
				ZZB->ZZB_LOJA	:= (cAlias)->F2_LOJA
				ZZB->ZZB_EMISNF	:= StoD((cAlias)->F2_EMISSAO)
				ZZB->ZZB_VOLUME	:= cValToChar(nI)+'/'+ cValToChar(nVolume)

				If ZZB->(FieldPos("ZZB_DTBIP")) > 0
					ZZB->ZZB_DTBIP	:= dDataBase
					ZZB->ZZB_HRBIP	:= SubStr(Time(),1,5)
				EndIf
			ZZB->(MsUnLock())

			Exit

		EndIf

	Next nI

	RestArea(aAreaZZB)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1052", 0, 0, {})

Return()


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpVar
description Limpa as variaveis da rotina
@author  Pontin - Facile Sistemas
@since   23.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method ValidaGNRE(nRecSF2) Class TFZLeituraEtiqueta

	Local aArea		:= GetArea()
	Local aAreaSF2	:= SF2->(GetArea())
	Local aRet		:= {.F., "Valida GNRE - Nenhuma validacao realizada"}

	dbSelectArea("SF2")
	SF2->(dbGoTo(nRecSF2))
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1073", 0, 0, {})


	//|Verifica se a venda tem ST e se deve pagar o imposto na emissão da NF |
	If GetMV("MV_ESTADO") <> SF2->F2_EST .And. Empty(IESubTrib(SF2->F2_EST)) //.And. !Empty(SF2->F2_ICMSRET)

		If Select("__TRB") > 0
			__TRB->(DbCloseArea())
		EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1082", 0, 0, {})

		BeginSql Alias "__TRB"
			SELECT 	F6_FILIAL,
					F6_DOC,
					F6_SERIE,
					F2_CLIENTE,
					F6_EST,
					F2_EMISSAO,
					E2_VENCREA,
					E2_FORNECE,
					E2_NOMFOR,
					E2_VALOR
			FROM %TABLE:SE2% SE2
				INNER JOIN %TABLE:SF6% SF6
					ON F6_FILIAL = SE2.E2_FILIAL
					AND F6_NUMERO = E2_PREFIXO + E2_NUM
					AND F6_TIPOIMP = '3'
					AND SF6.%NotDel%
				INNER JOIN %TABLE:SF2% SF2
					ON F2_FILIAL = F6_FILIAL
					AND F2_DOC = F6_DOC
					AND F2_SERIE = F6_SERIE
					AND F2_CLIENTE = F6_CLIFOR
					AND F2_LOJA = F6_LOJA
					AND SF2.%NotDel%
			WHERE E2_FILIAL = %Exp:SF2->F2_FILIAL%
				AND E2_BAIXA = ''
				AND E2_PREFIXO = 'ICM'
				AND E2_SALDO > 0
				AND F2_FILIAL = %Exp:SF2->F2_FILIAL%
				AND F2_DOC = %Exp:SF2->F2_DOC%
				AND F2_SERIE = %Exp:SF2->F2_SERIE%
				AND F2_CLIENTE = %Exp:SF2->F2_CLIENTE%
				AND F2_LOJA = %Exp:SF2->F2_LOJA%
				AND SE2.%NotDel%
		EndSql

		__TRB->(dbGoTop())

		//|Possui titulos de GNRE em aberto |
		If !__TRB->(EoF())
			aRet	:= {.F., "Valida GNRE - Imposto da Nota Fiscal ainda nao foi pago"}
		Else
			aRet	:= {.T., "Valida GNRE - Nota Fiscal com imposto pago"}
		EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1128", 0, 0, {})

	Else
		aRet	:= {.T., "Valida GNRE - Nota Fiscal nao necessita de GNRE"}
	EndIf

	If Select("__TRB") > 0
		__TRB->(DbCloseArea())
	EndIf

	RestArea(aAreaSF2)
	RestArea(aArea)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1140", 0, 0, {})

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpVar
description Realiza a limpeza do diretorio
@author  Pontin - Facile Sistemas
@since   22.02.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method LimpaDir() Class TFZLeituraEtiqueta

	Local nW	:= 0
	Local aDel	:= {}

	For nW := 1 To Len(::aDadosDel)

		If ::aDadosDel[nW,2]	//|Apagar arquivos |
			fErase(::aDadosDel[nW,1])
		Else	//|Apagar diretorio |
			FWDirRemove(::aDadosDel[nW,1],.F.,.T.)
		EndIf

	Next nW
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1166", 0, 0, {})

	//|Realiza limpeza dos arquivos temporários |
	aDel	:= Directory("\system\SC*")

	For nW := 1 To Len(aDel)

		//Apenas arquivos SC e sem extensão |
		If SubStr(Upper(aDel[nW,1]),1,2) == "SC" .And. AT(".",aDel[nW,1]) == 0

			fErase(aDel[nW,1])

		EndIf

	Next nW


Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} LimpVar
description Limpa as variaveis da rotina
@author  Pontin - Facile Sistemas
@since   23.01.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method SelecImpres(cTipo) Class TFZLeituraEtiqueta

	Local aArea 		:= GetArea()
	Local cAlias		:= GetNextAlias()
	Local cMV_YSRVIMP	:= SuperGetMV("MV_YSRVIMP",.F.,"10.1.25.40")
	Local cMV_YNOMIMP	:= SuperGetMV("MV_YNOMIMP",.F.,"CSC - Grupo Uniao SA")
	Local cImpressora	:= ""
	Local nI			:= 0
	Local aCab			:= {}
	Local aSize	 		:= {}
	Local nPos			:= {}
	Local aImpressora 	:= {}
	Local aImpress		:= {}
	Local aTela

	VTSave Screen To aTela
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1195", 0, 0, {})

	If cTipo == "ZEBRA"

		BeginSql Alias cAlias

		SELECT  CB5.CB5_CODIGO ,
				CB5.CB5_DESCRI ,
				CB5.CB5_SERVER ,
				CB5.CB5_PORTIP
		FROM    %Table:CB5% CB5
		WHERE   CB5.CB5_FILIAL = %xFilial:CB5%
				AND CB5.D_E_L_E_T_ = ''
				AND CB5.CB5_SERVER <> ''
		ORDER BY CB5.CB5_CODIGO DESC

		EndSql

		While (cAlias)->(!EoF())
			aAdd(aImpressora,{ (cAlias)->CB5_CODIGO,(cAlias)->CB5_DESCRI,(cAlias)->CB5_SERVER,(cAlias)->CB5_PORTIP })
			(cAlias)->(dbSkip())
		EndDo

	Else

		/*
		aImpress 	:= GetImpWindows(.T.)

		For nI := 1 To Len(aImpress)

			aAdd(aImpressora,{ aImpress[nI],aImpress[nI],getServerIP(),"" })

		Next nI
		*/

		If at('\\',cMV_YSRVIMP) <= 0
			cMV_YSRVIMP := '\\' + cMV_YSRVIMP + '\'
		EndIf

		cImpressora	:= cMV_YSRVIMP + cMV_YNOMIMP
		aAdd(aImpressora,{cImpressora,cMV_YNOMIMP,getServerIP(),"" })

	EndIf

	aCab := {"Codigo","Impressora","Server","Porta"}
	aSize:= {6,15,12,04}
	nPos := 1
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1242", 0, 0, {})

	If Len(aImpressora) > 0

		DLVTCabec("Impressoras", .F., .F., .T.)

		@ 01, 00 VTSay "Selecione Imp. " + cTipo
		nPos := VTaBrowse(03,0,7,40,aCab,aImpressora,aSize,/*Funcao p/ tratar as teclas*/,nPos)

		// pega o codigo da impressora
		If nPos > 0
			If cTipo == "ZEBRA"
				::cImpZebra := aImpressora[nPos][1]
			Else
				::cImpLaser := cMV_YSRVIMP + cMV_YNOMIMP
			EndIf
		EndIf

	EndIf

	RestArea(aArea)
	VTRestore Screen From aTela
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1264", 0, 0, {})

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} GerarPLP
description Gera a PLP para contratos
@author  Pontin - Facile Sistemas
@since   28.02.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method GerarPLP() Class TFZLeituraEtiqueta

	Local cTrbPLP	:= GetNextAlias()
	Local cTrb2		:= ""
	Local cTransp 	:= SuperGetMV("MV_Y189TRA",.F.,'000901/000902/000903/000703')
	Local cLocalArm	:= "0801"
	Local cNota		:= ''
	Local cSerie	:= ''
	Local cControle	:= ''
	Local cFilePrint:= ''
	Local cFileRel	:= ''
	Local cRaiz		:= GetSrvProfString("ROOTPATH","")
	Local aEndereco	:= {}
	Local aTotalPLP	:= {}
	Local oSigDest	:= Nil
	Local cNumPLP	:= ''
	Local aTela

FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1296", 0, 0, {})


	VTSave Screen To aTela

	Private oObjImpLaser	:= TFZImprimeLaser():New()
	//Private oSigep			:= ServSigep():New()
	If Type('oSigep') <> 'O'
		oSigep	:= ServSigep():New()
	EndIf

	If !oSigep:lConnectSigep
		VTAlert('NAO FOI POSSIVEL ACESSAR O SISTEMA SIGEP NOS CORREIOS, FAVOR ENTRAR EM CONTATO COM OS MESMO!',"Atenção",.T.,4000)
		Return .F.
	EndIf



	VTAlert("Inicio da Geracao da PLP!!","Aviso",.T.,1000)

	If !Empty(cTransp)
		cTransp := ' AND SF2.F2_TRANSP IN ' + FormatIn(cTransp,'/')
	Else
		cTransp := " AND 1 = 1 "
	End If

	cTransp := '% '+cTransp+' %'
FwLogMsg("INFO", , "ZEBRA", "ZEBRA", "", "01", "LINHA 1319", 0, 0, {})

	BeginSql alias cTrbPLP
		SELECT
			A1_COD, A1_LOJA, A1_NOME, F2_DOC, F2_SERIE, CONVERT(DATE,F2_EMISSAO) AS F2_EMISSAO, ZZB_VOLUME, SA4.A4_COD, SA4.A4_NOME
			, SA1.A1_END, SA1.A1_COMPLEM, SA1.A1_BAIRRO, SA1.A1_EST, SA1.A1_MUN, SA1.A1_CEP, A1_CGC
			, SA1.A1_TEL, SA1.A1_DDD, A1_EMAIL
			, ZZB.ZZB_RASTRO, A4_YSERVIC
			, SF2.F2_VALBRUT, SF2.F2_VOLUME1
			, VT1_API, VT1_ORDID, VT1_SEQUEN, F2_PBRUTO * 1000 F2_PBRUTO
			, VT1_IDCART
		FROM
			%table:SF2% SF2
			JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND SA1.%NotDel%
			JOIN %table:SA4% SA4 ON A4_FILIAL = %xFilial:SA4% AND SA4.A4_COD = SF2.F2_TRANSP AND SA4.%NotDel%
			JOIN %table:ZZB% ZZB ON ZZB_FILIAL = %xFilial:ZZB% AND ZZB.ZZB_DOC = SF2.F2_DOC AND ZZB.ZZB_SERIE = SF2.F2_SERIE AND ZZB.%NotDel%
			JOIN %table:SC5% SC5 ON C5_FILIAL = %xFilial:SC5% AND SF2.F2_DOC = SC5.C5_NOTA AND SF2.F2_SERIE = SC5.C5_SERIE AND SC5.%NotDel%
			left JOIN %table:VT1% VT1 ON VT1_FILIAL = %xFilial:VT1% AND SC5.C5_NUM = VT1.VT1_NUMPED AND VT1.%NotDel%
 			OUTER APPLY (SELECT TOP 1 * FROM %table:VT4% VT4 WHERE VT4_FILIAL = %xFilial:VT4% AND VT4.VT4_ORDID = VT1.VT1_ORDID AND VT4_EMPFOR+VT4_FILFOR = %Exp:cLocalArm% AND VT4.%NotDel%)	VT4

		WHERE
			SF2.F2_FILIAL = %xFilial:SF2% AND SF2.%NotDel%
			AND SF2.F2_TIPO = 'N' AND SF2.F2_EMISSAO >= '20170315'
			%Exp:cTransp%
			AND ZZB.ZZB_PLP = ''
		ORDER BY
			ZZB.ZZB_RASTRO DESC, F2_DOC
	EndSql

FwLogMsg("INFO", , "ZEBRA", "ZEBRA", "", "01", "LINHA 1347", 0, 0, {})

	(cTrbPLP)->(dbGoTop())
	While !(cTrbPLP)->(EoF())

		cNota	:= (cTrbPLP)->F2_DOC
		cSerie	:= (cTrbPLP)->F2_SERIE

		cTrb2	:= GetNextAlias()

		BeginSql alias cTrb2
			SELECT
				SD2.D2_PESO*1000 D2_PESO, SB1.B1_COD, SB1.B1_DESC, SB1.B1_YAPLICA, SB5.B5_CEME, B5_COMPRLC, B5_LARGLC, B5_ALTURLC
				, SD2.D2_PRCVEN, SD2.D2_TOTAL
			FROM
				%Table:SD2% SD2
				JOIN %Table:SB1% SB1 ON B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SD2.D2_COD AND SB1.%NotDel%
				JOIN %Table:SB5% SB5 ON B5_FILIAL = %xFilial:SB5% AND SB5.B5_COD = SD2.D2_COD AND SB5.%NotDel%
				JOIN %Table:ZZB% ZZB ON ZZB_FILIAL = %xFilial:ZZB% AND ZZB_DOC = SD2.D2_DOC AND ZZB_SERIE = SD2.D2_SERIE AND ZZB.%NotDel%
				LEFT JOIN %table:VT1% VT1 ON VT1_FILIAL = %xFilial:VT1% AND VT1.VT1_NUMPED = SD2.D2_PEDIDO AND VT1.%NotDel%
 				LEFT JOIN %table:VT4% VT4 ON VT4_FILIAL = %xFilial:VT4% AND VT4.VT4_ORDID = VT1.VT1_ORDID AND VT4_EMPFOR+VT4_FILFOR = %Exp:cLocalArm% AND VT4.%NotDel%
			WHERE
				SD2.D2_FILIAL = %xFilial:SD2%
				AND SD2.D2_DOC = %Exp:cNota%
				AND SD2.D2_SERIE = %Exp:cSerie%
				AND SD2.%NotDel%
			ORDER BY
				SD2.D2_ITEM

		EndSql

		oSigDest := SigPLPDestinatario():New()
FwLogMsg("INFO", , "ZEBRA", "ZEBRA", "", "01", "LINHA 1379", 0, 0, {})

		oSigDest:cTipoObj		:= '002' 				// 001 - Envelope ; 002 - Pacote/Caixa; 003 - Rolo / Cilindro
		oSigDest:cCliente		:= (cTrbPLP)->A1_COD
		oSigDest:cNomeCli		:= (cTrbPLP)->A1_NOME
		oSigDest:cNota			:= (cTrbPLP)->F2_DOC
		oSigDest:cSerie			:= (cTrbPLP)->F2_SERIE
		oSigDest:cEtiqueta		:= (cTrbPLP)->ZZB_RASTRO

		aEndereco	:= StaticCall(VIXA189, TrataEnd, (cTrbPLP)->A1_END) //TrataEnd((cTrbPLP)->A1_END)

		oSigDest:cEndCli		:= aEndereco[1]
		oSigDest:cNumCli		:= aEndereco[2]
		oSigDest:cComplemento	:= (cTrbPLP)->A1_COMPLEM
		oSigDest:cBairro		:= (cTrbPLP)->A1_BAIRRO
		oSigDest:cMunicipio		:= (cTrbPLP)->A1_MUN
		oSigDest:cUF			:= (cTrbPLP)->A1_EST
		oSigDest:cCEP			:= (cTrbPLP)->A1_CEP
		oSigDest:nValorNota		:= (cTrbPLP)->F2_VALBRUT
		oSigDest:nVolume		:= (cTrbPLP)->F2_VOLUME1

		If Len(AllTrim((cTrbPLP)->A1_DDD)) > 2
			oSigDest:cTelefone	:= (cTrbPLP)->(SubStr(AllTrim(A1_DDD), 2, 2) + AllTrim(A1_TEL))
		Else
			oSigDest:cTelefone	:= (cTrbPLP)->(AllTrim(A1_DDD) + AllTrim(A1_TEL))
		EndIf

		oSigDest:cEmail			:= (cTrbPLP)->A1_EMAIL
		oSigDest:nCubagem		:= 0
		oSigDest:nPeso			:= (cTrbPLP)->F2_PBRUTO
		oSigDest:cDescprod		:= (cTrb2)->B5_CEME
		oSigDest:nValor			:= (cTrbPLP)->F2_VALBRUT
		oSigDest:nAltura		:= (cTrb2)->B5_ALTURLC
		oSigDest:nLargura		:= (cTrb2)->B5_LARGLC
		oSigDest:nCompr			:= (cTrb2)->B5_COMPRLC
		oSigDest:cServPostag	:= iif(Empty((cTrbPLP)->A4_YSERVIC), '41068', AllTrim((cTrbPLP)->A4_YSERVIC))
		oSigDest:nDiamentro		:= 0

		aAdd(oSigep:aDestinatarios, oSigDest)

		(cTrbPLP)->(dbSkip())

		(cTrb2)->(dbCloseArea())
FwLogMsg("INFO", , "ZEBRA", "ZEBRA", "", "01", "LINHA 1422", 0, 0, {})

	EndDo


	cControle := StaticCall(VIXA189, NumeControle)	//NumeControle()
	oSigep:cNumControle := cControle

FwLogMsg("INFO", , "ZEBRA", "ZEBRA", "", "01", "LINHA 1428", 0, 0, {})

	If oSigep:GerarPLP()

		dbSelectArea('ZZB')
		ZZB->(dbSetOrder(2))

		(cTrbPLP)->(DbGoTop())


		While !(cTrbPLP)->(EoF())

			If ZZB->(DbSeek(xFilial('ZZB') + (cTrbPLP)->ZZB_RASTRO))
				RecLock('ZZB', .F.)
					ZZB->ZZB_PLP 		:= oSigep:cNumPLP
					ZZB->ZZB_FECHAM		:= dDataBase
					ZZB->ZZB_CONTRO		:= cControle
				ZZB->(MsUnLock())

			EndIf
FwLogMsg("INFO",, "ZEBRA", "ZEBRA", "", "01", "LINHA 1449", 0, 0, {})

			RecLock('VT7', .T.)

				VT7->VT7_FILIAL	:= xFilial('VT7')
				VT7->VT7_ORDID	:= (cTrbPLP)->VT1_ORDID
				VT7->VT7_SEQUEN	:= (cTrbPLP)->VT1_SEQUEN
				VT7->VT7_API	:= (cTrbPLP)->VT1_API
				VT7->VT7_DOC	:= (cTrbPLP)->F2_DOC
				VT7->VT7_SERIE	:= (cTrbPLP)->F2_SERIE
				VT7->VT7_CODRAS	:= (cTrbPLP)->ZZB_RASTRO

			VT7->(MsUnLock())

			(cTrbPLP)->(dbSkip())

		EndDo

		oObjImpLaser:LimpVar()
		oObjImpLaser:cPrinter	:= ::cImpLaser

		cNumPLP := oSigep:cNumPLP
		//|Imprime a PLP |
		cFilePrint	:= "PLP_" + AllTrim(cNumPLP) + ".pdf"
		cFileRel	:= "PLP_" + AllTrim(cNumPLP) + ".rel"
		aTotalPLP	:= PdfRelPLP(cNumPLP, .T., cFilePrint)

		oObjImpLaser:cArqImp	:= cRaiz + "\PLPS\" + cFilePrint
		oObjImpLaser:ImpArquivo()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1480", 0, 0, {})

		If oObjImpLaser:lImpresso
			VTAlert("PLP Impressa!!","Aviso",.T.,1000)
		EndIf

		aAdd(::aDadosDel,{"\PLPS\" + cFilePrint,.T.})
		aAdd(::aDadosDel,{"\PLPS\" + cFileRel,.T.})

		//|Imprime a PLP com código de barras |
		cFilePrint	:= "PLP_CDBARRAS_" + AllTrim(cNumPLP) + ".pdf"
		cFileRel	:= "PLP_CDBARRAS_" + AllTrim(cNumPLP) + ".rel"
		PDF_PLP_Barra(cNumPLP, aTotalPLP, cFilePrint)

		oObjImpLaser:cArqImp	:= cRaiz + "\PLPS\" + cFilePrint
		oObjImpLaser:ImpArquivo()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1497", 0, 0, {})

		If oObjImpLaser:lImpresso
			VTAlert("PLP Codigo de Barras Impressa!!","Aviso",.T.,1000)
		EndIf

		aAdd(::aDadosDel,{"\PLPS\" + cFilePrint,.T.})
		aAdd(::aDadosDel,{"\PLPS\" + cFileRel,.T.})


		//|Imprime o AR |
		nCont := 0

		While nCont <= 5

			nCont++
			cFilePrint	:= "AR_" + AllTrim(cNumPLP) + ".pdf"
			cFileRel	:= "AR_" + AllTrim(cNumPLP) + ".rel"
			PDFImpAR(cNumPLP,1,cFilePrint)

			oObjImpLaser:cArqImp	:= cRaiz + "\PLPS\" + cFilePrint
			oObjImpLaser:ImpArquivo()
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1514", 0, 0, {})

			If oObjImpLaser:lImpresso
				VTAlert("AR Impressa!!","Aviso",.T.,2000)
			EndIf

			If File("\PLPS\" + cFilePrint)
				nCont := 5
				Exit
			EndIf

			aAdd(::aDadosDel,{"\PLPS\" + cFilePrint,.T.})
			aAdd(::aDadosDel,{"\PLPS\" + cFileRel,.T.})

		EndDo

		//|Exclui os arquivos gerados |
		If Len(::aDadosDel) > 0
			::LimpaDir(::aDadosDel)
		EndIf

	Else
		VTAlert('A PLP não foi gerada, favor tentar novamente!',"Atenção",.T.,2000)
	EndIf

	If Select((cTrbPLP)) > 0
		(cTrbPLP)->(dbCloseArea())
	EndIf

	::Destroy()

	VTRestore Screen From aTela
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1551", 0, 0, {})

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GerarPLP
description Elimina os objetos da memoria
@author  Pontin - Facile Sistemas
@since   28.02.19
@version 1.0
/*/
//-------------------------------------------------------------------
Method Destroy() Class TFZLeituraEtiqueta
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1565", 0, 0, {})

	If Type("oObjImpLaser") == "O"
		FreeObj(oObjImpLaser)
	EndIf

	If Type("oSigDest") == "O"
		FreeObj(oSigDest)
	EndIf

	If Type("oBjMEnvios") == "O"
		FreeObj(oBjMEnvios)
	EndIf

	If Type("oObjImprime") == "O"
		FreeObj(oObjImprime)
	EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1582", 0, 0, {})

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PdfRelPLP
description Imprime a PLP em PDF direto do Coletor
@author  Pontin - Facile Sistemas
@since   12.03.19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function PdfRelPLP(cPLP, lImpTodos, cFilePrint)

	Local oFont09 			:= TFont():New("ARIAL",,012,,.F.,,,,,.F.,.F.)
	Local oFont09N 			:= TFont():New("ARIAL",,012,,.T.,,,,,.F.,.F.)
	Local nI 				:= 0
	Local lImpBoxRastro		:= .T.
	Local nPosInc			:= 0
	Local cAlias			:= GetNextAlias()
	Local nMaxRastro		:= 13
	Local nMaxRodape		:= 9
	Local nQdeIens			:= 0
	Local cTotalizador		:= ''
	Local nPagina			:= 0
	Local nTotalLinha		:= 0
	Local nTotalPagina		:= 0
	Local nCopias			:= 2
	Local nZ				:= 0
	Local aTotalPLP			:= {}
	Local cServico			:= ''
	Local cDescServ			:= ''
	Local lImpLista			:= SuperGetMv("MV_YIMPLP", .F., .T.)
	Local aME2				:= {}
	//Local oBjMEnvios 		:= MEnviosRastreamento():New()

	Default cPLP  			:= ''
	Default lImpTodos 		:= .F.
	Default cFilePrint		:= "PLP_" + AllTrim(cPLP) + ".pdf"

	If Empty(cPLP)
		VTAlert('A PLP não foi informada para impressao, favor tentar novamente!',"Atenção",.T.,4000)
		Return
	EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1628", 0, 0, {})

	BeginSql alias cAlias
		SELECT
			ZZB.ZZB_RASTRO, ZZB_VOLUME, SA1.A1_CEP, F2_PBRUTO * 1000 F2_PBRUTO, SF2.F2_VALBRUT, F2_DOC, F2_SERIE, SF2.F2_VOLUME1
			,  A4_YSERVIC, SA4.A4_NOME, A1_COD, A1_LOJA, A1_NOME
		FROM
			%table:SF2% SF2
			JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND SA1.%NotDel% AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA
			JOIN %table:SA4% SA4 ON A4_FILIAL = %xFilial:SA4% AND SA4.%NotDel% AND SA4.A4_COD = SF2.F2_TRANSP
			JOIN %table:ZZB% ZZB ON ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel% AND ZZB.ZZB_DOC = SF2.F2_DOC AND ZZB.ZZB_SERIE = SF2.F2_SERIE
		WHERE
			SF2.F2_FILIAL = %xFilial:SF2% AND SF2.%NotDel%
			AND ZZB_PLP = %Exp:cPLP%
		ORDER BY
			F2_DOC

	EndSql

	lAdjustToLegacy := .T. //.F.
	lDisableSetup 	:= .T.
	cDirPLP			:= "\PLPS\"

	//|Exclui o arquivo impresso |
	If File(cDirPLP + cFilePrint)
		fErase(cDirPLP + cFilePrint)
	EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1655", 0, 0, {})

	oPrint := FWMSPrinter():New(cFilePrint,IMP_PDF, lAdjustToLegacy, cDirPLP, .T., , ,"PDF", .T., , ,.F. , 2)
	oPrint:lInJob 	:= .T.
	oPrint:lServer 	:= .T.
	oPrint:nDevice 	:= IMP_PDF
	oPrint:SetLandscape() // Paisagem
	oPrint:SetViewPDF(.F.)
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(0,0,0,0)

    oPrint:cPathPDF:= cDirPLP

	For nZ := 1 To nCopias

		If lImpLista

			If nZ > 1
				aTotalPLP	:= {}
				oPrint:EndPage()
			EndIf

			oPrint:StartPage()

		EndIf
		nTotalLinha := 0
		nPagina 	:= 0
		(cAlias)->(dbGoTop())
		While !(cAlias)->(EoF())

			nTotalLinha += Max(1, (cAlias)->F2_VOLUME1)

			(cAlias)->(DbSkip())

		EndDo

		nTotalPagina := NoRound( nTotalLinha / nMaxRastro, 0)

		//Caso uma página tem memos itens que o máximo permitido
		nTotalPagina += iif(mod( nTotalLinha , nMaxRastro) > 0 , 1, 0)

		//Caso a última página tenha mesmo itens que o máximo permitido, porém tenha mais que o máximo para impressão do rodapé
		nTotalPagina += iif(mod( nTotalLinha , nMaxRastro) > nMaxRodape , 1, 0)


		nQdeIens := 0

		oSigep:LimpCampos()

		(cAlias)->(DbGoTop())
		While !(cAlias)->(Eof())

			cServico := AllTrim((calias)->A4_YSERVIC)

			nPos := aScan(oSigep:aServicos, {|x|AllTrim(x[1])==cServico})

			If nPos == 0
				VTAlert("Atenção",'O serviço "'+cServico+'" informado na transportadora não foi implementado ou não faz parte do contrato da empresa!',"Aviso",.T.,2000)
				Return .F.
			EndIf

			cDescServ := oSigep:aServicos[nPos, 4]

			If lImpLista
			//Se passar da quantidade de itens por página, pula para a próxima
				If nQdeIens  == nMaxRastro
					nQdeIens := 0
					oPrint:EndPage()
					oPrint:StartPage()
					lImpBoxRastro := .T.
				EndIf

				If nQdeIens == 0
					nPagina ++
					MontaCab2(oPrint, cPLP, cTotalizador, nPagina, nTotalPagina)
				EndIF

				nQdeIens ++
				nPosInc := ((nQdeIens - 1) * 130 )

				If lImpBoxRastro
					oPrint:Box( 0616 + (nPosInc - 14) , 0060, 0746 + (nPosInc - 14), 3312 - 400 )
				EndIf

				oPrint:Say( 0640 + nPosInc, 0070, (calias)->ZZB_RASTRO			,oFont09N,1400 )
				oPrint:Say( 0690 + nPosInc, 0070, 'Serviço:' + cServico			,oFont09,1400 )
				oPrint:Say( 0640 + nPosInc, 0350, (calias)->A1_CEP				,oFont09N,1400 )
				oPrint:Say( 0640 + nPosInc, 0570, Transform((calias)->F2_PBRUTO,"@E 999999"),oFont09N,1400 )
				oPrint:Say( 0640 + nPosInc, 0710, "S"								,oFont09,1400 )
				oPrint:Say( 0640 + nPosInc, 0790, "N"								,oFont09,1400 )
				oPrint:Say( 0640 + nPosInc, 0880, "S"								,oFont09,1400 )
				oPrint:Say( 0640 + nPosInc, 1040, Transform((calias)->F2_VALBRUT,"@E 999,999,999.99") ,oFont09,1400 )
				oPrint:Say( 0640 + nPosInc, 1350, (calias)->F2_DOC				,oFont09,1400 )
				oPrint:Say( 0690 + nPosInc, 1500, 'Observação:'					,oFont09,1400 )
				//oPrint:Say( 0640 + nPosInc, 1630, cValToChar(nI)+'/'+ cValToChar((calias)->F2_VOLUME1)		,oFont09,1400 )
				oPrint:Say( 0640 + nPosInc, 1630, (calias)->ZZB_VOLUME			,oFont09,1400 )
				oPrint:Say( 0640 + nPosInc, 1800, (calias)->A1_NOME				,oFont09,1400 )

				lImpBoxRastro := !lImpBoxRastro
			EndIf

			nPosPlP := 0

			If Len(aTotalPLP) > 0
				nPosPlP := aScan(aTotalPLP, {|x|x[1] == cServico })
			EndIf

			If nPosPlP > 0
				aTotalPLP[nPosPlP, 3] += 1
			Else
				aAdd(aTotalPLP, {cServico, cDescServ, 1})
			EndIf

			(cAlias)->(DbSkip())

		EndDo

		If lImpLista
			//O sistema cabe  rastros com o rodapé por página por isso se tiver mais de 8 deverá pula a página
			If nQdeIens > nMaxRodape
				oPrint:EndPage()
				oPrint:StartPage()
				nPagina++
				MontaCab2(oPrint, cPLP, cTotalizador, nPagina, nTotalPagina)
			EndIf

			oPrint:Box( 1786 - 14, 0060, 2310 - 14, 3312 - 400 )
			oPrint:Say( 1801, 0070,"Totalizador:"					,oFont09N,1400 )
			oPrint:Say( 1801, 0420,""					,oFont09 ,1400 )

			oPrint:Say( 1810, 2300,"Carinho e Assinatura / Matrícula dos correios"	, oFont09N ,1400 )
			oPrint:Say( 2100, 2300,"________________________________________"	,oFont09N ,1400 )

			oPrint:Say( 1830, 0830,"APRESENTAR ESTA LISTA EM CASO DE PEDIDO DE INFORMAÇÕES"	,oFont09N ,1400 )
			oPrint:Say( 1900, 0830,"Estou ciente do disposto na cláusula terceira do contrato de prestação de Serviço."	,oFont09N ,1400 )

			oPrint:Say( 2050, 0900,"_____________________________________________________________________"	,oFont09N ,1400 )
			oPrint:Say( 2120, 1280,"ASSINATURA DO REMETENTE"					,oFont09N ,1400 )
			oPrint:Say( 2190, 1150,"Obs: 1ª via Unidade de Postagem e 2ª via cliente"					,oFont09N ,1400 )

			If nZ == nCopias
				oPrint:EndPage()
				oPrint:Print(, 2)
			EndIf

		EndIf

	Next nZ

	FreeObj(oPrint)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1805", 0, 0, {})

Return aTotalPLP



/*/{Protheus.doc} MontaCab2
Monta o cabeçalho do relatório PLP
@author henrique
@since 12/12/2016
@version 1.0
@param oPrint, objeto, (Descrição do parâmetro)
@param cPLP, character, (Descrição do parâmetro)
@param cTotalizador, character, (Descrição do parâmetro)
@param nPagina, numérico, (Descrição do parâmetro)
@param nTotalPagina, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MontaCab2(oPrint, cPLP, cTotalizador, nPagina, nTotalPagina)

	Local oFont09N 		:= TFont():New("ARIAL",,012,,.T.,,,,,.F.,.F.)
	Local oFont10 		:= TFont():New("ARIAL",,012,,.F.,,,,,.F.,.F.)
	Local oFont15 		:= TFont():New("ARIAL",,017,,.F.,,,,,.F.,.F.)
	Local oFont18 		:= TFont():New("ARIAL",,020,,.F.,,,,,.F.,.F.)

	oPrint:SayBitmap( 080,050,"\Imagens\logo_correios.png",400,120 )  //"C:\Temp\Correios\logo_correios.png"

	oPrint:Say( 0130, 0610,"EMPRESA BRASILEIRA DE CORREIOS E TELÉGRAFOS",oFont15,1400 )

	//Cabeçalho
	oPrint:Box( 0225 - 14, 0060, 0556 - 14, 3312 - 400 )

	oPrint:Say( 0240 + 15, 1300,"LISTA DE POSTAGEM"				,oFont18,1400 )
	oPrint:Say( 0320, 0070,"N° da Lista:"					,oFont09N,1400 )
	oPrint:Say( 0320, 0420,cPLP								,oFont10,1400 )

	oPrint:Say( 0370, 0070,"Contrato:"						,oFont09N,1400 )
	oPrint:Say( 0370, 0420, oSigep:cContrato				,oFont10,1400 )

	oPrint:Say( 0430, 0070,"Cód Administrativo:"			,oFont09N,1400 )
	oPrint:Say( 0430, 0420, oSigep:cCodAdm				,oFont10,1400 )

	oPrint:Say( 0490, 0070,"Cartão:"						,oFont09N,1400 )
	oPrint:Say( 0490, 0420, oSigep:cCartao				,oFont10,1400 )

	//2 COLUNA
	oPrint:Say( 0320, 0850,"Remetene:"						,oFont09N,1400 )
	oPrint:Say( 0320, 1060,SM0->M0_NOMECOM					,oFont10,1400 )

	oPrint:Say( 0370, 0850,"Cliente:"						,oFont09N,1400 )
	oPrint:Say( 0370, 1060,"VIXPAR"							,oFont10,1400 )

	oPrint:Say( 0430, 0850,"Endereço:"						,oFont09N,1400 )
	oPrint:Say( 0430, 1060,AllTrim(SM0->M0_ENDCOB)+'-'+ AllTrim(SM0->M0_BAIRCOB) ,oFont10,1400 )

	oPrint:Say( 0490, 0850,AllTrim(SM0->M0_CIDCOB)+'/'+SM0->M0_ESTCOB +;
							'- CEP : ' + SM0->M0_CEPCOB ,oFont10,1400 )

	//3 COLUNA
	oPrint:Say( 0490, 2500,"Telefone:"						,oFont09N,1400 )
	oPrint:Say( 0490, 2670,SM0->M0_TEL						,oFont10,1400 )

	//Titulos Rastro
	oPrint:Say( 0570, 0070, "N° do Objeto"					,oFont09N,1400 )
	oPrint:Say( 0570, 0350, "CEP"							,oFont09N,1400 )
	oPrint:Say( 0570, 0580, "Peso"							,oFont09N,1400 )
	oPrint:Say( 0570, 0700, "AR"							,oFont09N,1400 )
	oPrint:Say( 0570, 0790, "MP"							,oFont09N,1400 )
	oPrint:Say( 0570, 0880, "VD"							,oFont09N,1400 )
	oPrint:Say( 0570, 1040, "Valor Declarado"				,oFont09N,1400 )
	oPrint:Say( 0570, 1350, "Nota Fiscal"					,oFont09N,1400 )
	oPrint:Say( 0570, 1600, "Volume"						,oFont09N,1400 )
	oPrint:Say( 0570, 1800, "Destinatário"					,oFont09N,1400 )

	oPrint:Say( 2340, 0070, "Data de emissão:"+ DTOC(dDataBase)						,oFont09N ,1400 )
	oPrint:Say( 2340, 3000 - 400, "Página: "+ cValToChar(nPagina) + ' de '+ cValToChar(nTotalPagina),oFont09N ,1400 )

Return


/*/{Protheus.doc} PDF_PLP_Barra
(long_description)
@author henrique
@since 03/03/2017
@version 1.0
@param cPLP, character, (Descrição do parâmetro)
@param aTotalPLP, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PDF_PLP_Barra(cPLP, aTotalPLP, cFilePrint)

	Local oFont08N 			:= TFont():New("ARIAL",,012,,.T.,,,,,.F.,.F.)
	Local oFont12N 			:= TFont():New("ARIAL",,012,,.T.,,,,,.F.,.F.)
	Local oFont10N 			:= TFont():New("ARIAL",,012,,.T.,,,,,.F.,.F.)
	Local oFont10 			:= TFont():New("ARIAL",,012,,.F.,,,,,.F.,.F.)
	Local oFont14N 			:= TFont():New("ARIAL",,015,,.T.,,,,,.F.,.F.)
	Local oFont18 			:= TFont():New("ARIAL",,020,,.F.,,,,,.F.,.F.)
	Local nI, nJ, nX		:= 0
	Local nPos				:= 0
	Local nTop				:= 370
	Local nLeft 			:= 1650
	Local nBottom			:= 610
	Local nWidth			:= 1650
	Local nTotal			:= 0

	Default cFilePrint		:= "PLP_CDBARRAS_" + AllTrim(cPLP) + ".pdf"

	lAdjustToLegacy := .T. //.F.
	lDisableSetup 	:= .T.
	cDirPLP			:= "\PLPS\"

	//|Exclui o arquivo impresso |
	If File(cDirPLP + cFilePrint)
		fErase(cDirPLP + cFilePrint)
	EndIf
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 1926", 0, 0, {})

	oPrint := FWMSPrinter():New(cFilePrint,IMP_PDF, lAdjustToLegacy, cDirPLP, .T., , ,"PDF", .T., , ,.F. , 1)
	oPrint:lInJob 	:= .T.
	oPrint:lServer 	:= .T.
	oPrint:nDevice 	:= IMP_PDF
	oPrint:SetPortrait() // Paisagem
	oPrint:SetViewPDF(.F.)
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(0,0,0,0)

    oPrint:cPathPDF:= cDirPLP

	oPrint:StartPage()

	If Len(aTotalPLP) == 0
		Return
	EndIf

	//Cabeçalho

	For nI := 1 to 2
		nTotal 	:= 0
		nPos 	:= (nI-1)*1040

		oPrint:SayBitmap( 0105+nPos,0060,"C:\Temp\Correios\logo_correios.png",280,84 )

		oPrint:Say( 0140+nPos, 0400,"EMPRESA BRASILEIRA DE CORREIOS E TELÉGRAFOS",oFont14N,1400 )

		oPrint:Box( 0225+(nPos - 25), 0050, 0310+(nPos - 25), 2400 - 5)
		oPrint:Box( 0310+(nPos - 25), 0050, 0680+(nPos - 25), 2400 - 5)
		oPrint:Box( 0680+(nPos - 25), 0050, 1030+(nPos - 25), 2400 - 5)

		oPrint:Say( 0240+nPos, 0780,"PRÉ - LISTA DE POSTAGEM - PLP - SIGEP WEB" 			, oFont14N,1400 )

		PDF_MSBA('CODE128' , nPos, 0, AllTrim(cPLP) , oPrint,.F.   ,     ,.T.  ,  ,   ,.F.,oFont08N ,'C'  , .F.,,,, 7, nTop, nLeft, nBottom, nWidth)

		oPrint:Say( 0320+nPos, 0060,"SIGEP WEB - Gerenciador de Postagem dos Correios:"			, oFont08N,1400 )
		oPrint:Say( 0320+nPos, 1780,"Nº PLP: " + cPLP											, oFont08N,1400 )
		oPrint:Say( 0390+nPos, 0060,"Contrato: " +oSigep:cContrato								, oFont08N,1400 )
		oPrint:Say( 0460+nPos, 0060,"Cliente: VIXPAR"											, oFont08N,1400 )
		oPrint:Say( 0530+nPos, 0060,"Telefone de contato:" + SM0->M0_TEL						, oFont08N,1400 )
		oPrint:Say( 0600+nPos, 0060,"E-mail de contato: atendimento@hipervarejo.com.br"			, oFont08N,1400 )

		oPrint:Say( 0690+nPos, 0060,"Cod Serviço:"												, oFont08N,1400 )
		oPrint:Say( 0690+nPos, 0560,"Quantidade:"												, oFont08N,1400 )
		oPrint:Say( 0690+nPos, 1060,"Serviço" 													, oFont08N,1400 )

		For nX := 1 to Len(aTotalPLP)
			oPrint:Say( 0770+nPos + ((nX -1) * 65), 0060, aTotalPLP[nX, 1]					, oFont08N,1400 )
			oPrint:Say( 0770+nPos + ((nX -1) * 65), 0560, cValToChar(aTotalPLP[nX, 3])	, oFont08N,1400 )
			oPrint:Say( 0770+nPos + ((nX -1) * 65), 1060, aTotalPLP[nX, 2] 				, oFont08N,1400 )
			nTotal += aTotalPLP[nX, 3]
		Next

		oPrint:Say( 0950+nPos, 0060,"Total:"													, oFont08N,1400 )
		oPrint:Say( 0950+nPos, 0560, cValToChar(nTotal)										, oFont08N,1400 )

		oPrint:Say( 0730+nPos, 1650,"Data Entrega: _____/_____/_________"					, oFont08N,1400 )
		oPrint:Say( 0820+nPos, 1650,"________________________________"						, oFont08N,1400 )
		oPrint:Say( 0890+nPos, 1650,"Assinatura / Matrícula dos Correios"					, oFont08N,1400 )

		If nI == 1
			For nJ := 1 to 68
				oPrint:Say( 1060, 0050 + ((nJ - 1)*35), '_'								, oFont10N, 20 )
			Next

			oPrint:Say( 0950, 1650,"1ª Via - Correios"										, oFont08N,1400 )
		Else
			oPrint:Say( 0950+nPos, 1650,"2ª Via - Cliente"									, oFont08N,1400 )
		EndIf

	Next

    oPrint:EndPage()
    oPrint:Print()

	FreeObj(oPrint)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 2004", 0, 0, {})

Return


Static Function PDF_MSBA(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix, nTam, nTop, nLeft, nBottom, nWidth2)

   	Local nI   			:= 0
   	Local nPos 			:= 0

   	Local oBrush1		:= nil
   	Local nSpace		:= 0
   	Local nSpaceZero	:= 0

   	Default nTop		:= 550
	Default nLeft 		:= 100
	Default nBottom		:= 810
	Default nWidth2		:= 180


   	oBar:= CBBAR():New(cTypeBar,nRow,nCol,cCode,oPrint,lCheck,Color,lHorz,nWidth,nHeigth,lBanner,cFont,cMode,lPrint,nPFWidth,nPFHeigth,lCmtr2Pix)
	nTop		+= nRow
	nLeft 		+= nCol
	nBottom		+= nRow
	nWidth2		+= nCol + nTam
	nSpace 		:= nWidth2-nLeft
	nSpaceZero 	:= 1 * (Round(nTam / 7, 4))
  	oBrush1 	:= TBrush():New( , CLR_BLACK )

  	For nI := 1 to Len(oBar:cConteudo)

  		If Substr(oBar:cConteudo, nI, 1) == '1'
  			If nI > 1 .AND. Substr(oBar:cConteudo, nI-1, 1) == '0'
		  		nLeft 	+= nSpaceZero
				nWidth2	+= nSpaceZero
			EndIf
  			//Alert('Left: '+cValToChar(nLeft) + " | Width "+ cValToChar(nWidth) )
	  		oPrint:FillRect( {nTop, nLeft, nBottom, nWidth2}, oBrush1 )
	  	EndIf

		nLeft 		+= nSpace
		nWidth2		+= nSpace

  	Next

Return


/*/{Protheus.doc} PDFImpAR
Relatório do voucher dos correios
@author henrique
@since 12/12/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PDFImpAR(cPLP, cTipo, cFilePrint)

	Local nQdeEtiq		:= 0
	Local nPos			:= 0
	Local nPosBarra		:= 0
	Local nI			:= 0
	Local cImag001		:=	"\Imagens\logo_correios.png"
	Local cImag002		:=	"\Imagens\Cole_Aqui.png"
	Local oArial44  	:=	TFont():New("Arial",,23,,.F.,,,,,.F.,.F.)
	Local oFont11		:=	TFont():New("Arial",,13,,.T.,,,,,.F.,.F.)
	Local oFont09		:=	TFont():New("Arial",,12,,.T.,,,,,.F.,.F.)
	Local oFont08  		:=	TFont():New("Arial",,10,,.F.,,,,,.F.,.F.)
	Local oFont05		:=	TFont():New("Arial",,08,,.T.,,,,,.F.,.F.)
	Local cRastrosSel	:= ''
	Local cAlias		:= Nil
	Local cRastro		:= ''
	Local aEndere		:= {}
  	Local aME2			:= {}
	//Local oBjMEnvios 	:= MEnviosRastreamento():New()

   	Default cPLP 		:= ''
	Default cTipo 		:= 1
	Default cFilePrint	:= "AR_" + AllTrim(cPLP) + ".pdf"
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 2085", 0, 0, {})

	If Empty(cPLP)
		VTAlert('A PLP não foi informada para impressao da AR, favor tentar novamente!',"Atenção",.T.,4000)
		Return
	EndIf

	cAlias := GetNextAlias()
	BeginSql Alias cAlias
		SELECT
			Cast('  ' as Char(2)) as ZZB_OK
		   , ZZB.ZZB_RASTRO
			, A1_COD, A1_LOJA, A1_NOME, A1_END, A1_BAIRRO, SA1.A1_MUN, SA1.A1_EST, SA1.A1_COMPLEM, A1_CEP
			, SF2.F2_VOLUME1
		FROM
			%table:ZZB% ZZB
			JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1% AND SA1.%NotDel% AND SA1.A1_COD = ZZB.ZZB_CLIENT AND SA1.A1_LOJA = ZZB.ZZB_LOJA
			JOIN %table:SF2% SF2 ON SF2.F2_FILIAL = %xFilial:SF2% AND SF2.%NotDel% AND SF2.F2_DOC = ZZB.ZZB_DOC AND SF2.F2_SERIE = ZZB.ZZB_SERIE
		WHERE
			ZZB.ZZB_FILIAL = %xFilial:ZZB% AND ZZB.%NotDel%
			AND ZZB_PLP = %Exp:cPLP%
	EndSql

	lAdjustToLegacy := .T.
	lDisableSetup 	:= .T.
	cDirPLP			:= "\PLPS\"

	//|Exclui o arquivo impresso |
	If File(cDirPLP + cFilePrint)
		fErase(cDirPLP + cFilePrint)
	EndIf

	oPrinter := FWMSPrinter():New(cFilePrint,IMP_PDF, lAdjustToLegacy, cDirPLP, .T., , ,"PDF", .T., , ,.F. , 1)
	oPrinter:lInJob 	:= .T.
	oPrinter:lServer 	:= .T.
	oPrinter:nDevice 	:= IMP_PDF
	oPrinter:SetPortrait()
	oPrinter:SetViewPDF(.F.)
	oPrinter:SetPaperSize(0, 297, 210)

    oPrinter:cPathPDF	:= cDirPLP

	oPrinter:StartPage()

	(cAlias)->(dbGoTop())
	While !(cAlias)->(EoF())

		If nQdeEtiq >= 3

			oPrinter:EndPage()
			oPrinter:StartPage()
			nPos 		:= 0
			nQdeEtiq 	:= 0
		EndIf

		nQdeEtiq ++

		If nQdeEtiq == 1
			nPos := 50 + (nQdeEtiq - 1) * 1120
		ElseIf nQdeEtiq == 2
			nPos := (nQdeEtiq - 1) * 1115
		Else
			nPos := ((nQdeEtiq - 1) * 1115) - 40
		EndIf

		nEsq 		:= 40
		nDireita 	:= 40
		nBaixo 		:= -50
		nCima  		:= 0
		//nPos += 10

		//|Box vertical da esquerda COLE AQUI
		oPrinter:Box(0011+nPos+nCima,0037+nEsq,(1116+nPos)+nBaixo,0108+nDireita)

		//|Box Principal |
		oPrinter:Box(0011+nPos+nCima,0122+nEsq,(1116+nPos)+nBaixo,2400)

		//|linha superior do texto SIGEP AVISO DE RECEBIMENTO |
		oPrinter:Line(0100+nPos+nCima, 0122+nEsq, 0100+nPos+nCima, 2400)

		//|linha da direita carimbo e rubrida |
		oPrinter:Line(0100+nPos+nCima, 2003+nEsq, (1116+nPos)+nBaixo, 2003+nEsq)
		oPrinter:Line(0600+nPos+nCima, 2003+nEsq, 0600+nPos+nCima, 2400)

		//|Linha TENTATIVA DE ENTREGA |
		oPrinter:Line(0100+nPos+nCima, 1254+nEsq, (0980+nPos)+nBaixo, 1254+nEsq)

		//|Linha DECLARACAO DE CONTEUDO |
		oPrinter:Line((0860+nPos)+nCima, 0122+nEsq, (0860+nPos)+nCima, 1254+nEsq)
		oPrinter:Line((0930+nPos)+nCima, 0122+nEsq, (0930+nPos)+nCima, 2003+nEsq)

		//|Linha ASSINATURA DO RECEBEDOR |
		oPrinter:Line((1000+nPos)+nCima, 0122+nEsq, (1000+nPos)+nCima, 2003+nEsq)

		//|Linha DATA DE ENTREGA e N DOC DE IDENTIDADE |
		oPrinter:Line((0930+nPos)+nCima,1600+nEsq,(1115+nPos)+nBaixo,1600+nEsq)

		//|Imprime as imagens |
		oPrinter:SayBitMap(0025+nPos,0148+nEsq,cImag001,0293,0068)
		oPrinter:SayBitMap(0211+nPos,0049+nEsq,cImag002,0056,0183)
		oPrinter:SayBitMap(0826+nPos,0049+nEsq,cImag002,0056,0183)

		nLinha := 30

		oPrinter:Say(0018+nPos+nLinha+30,0580+nEsq, "SIGEP",oArial44,,0)
		oPrinter:Say(0015+nPos+nLinha,0899+nEsq, "AVISO DE",oFont11,,0)
		oPrinter:Say(0058+nPos+nLinha,0901+nEsq, "RECEBIMENTO",oFont11,,0)
		oPrinter:Say(0033+nPos+nLinha,1274+nEsq, "CONTRATO "+oSigep:cContrato,oFont11,,0)

		aEndere := StaticCall(VIXA189, TrataEnd, AllTrim((cAlias)->A1_END))

		oPrinter:Say(0130+nPos,0140+nEsq,"DESTINATARIO:"		, oFont09,,0)
		oPrinter:Say(0180+nPos,0140+nEsq, AllTrim((cAlias)->A1_NOME)		, oFont09,,0)
		oPrinter:Say(0230+nPos,0140+nEsq, aEndere[1]+', '+aEndere[2]		,oFont09,,0)
		oPrinter:Say(0280+nPos,0140+nEsq, AllTrim((cAlias)->A1_BAIRRO)	,oFont09,,0)
		oPrinter:Say(0330+nPos,0140+nEsq, AllTrim((cAlias)->A1_CEP)+ '  '+AllTrim((cAlias)->A1_MUN) + '-'+ AllTrim((cAlias)->A1_EST), oFont09,,0)

		//           Centimetros              milimetros
		nPosBarra 	:= 9.4+((nQdeEtiq-1)*23.9) - ((nQdeEtiq-1)*1)
		cRastro 	:= AllTrim((cAlias)->ZZB_RASTRO)

		cSigla 		:= SubStr(cRastro, 1, 2)
		cRastro 	:= StrTran(cRastro, 'BR', '')
		cRastro 	:= StrTran(cRastro, cSigla, 'AR')+cSigla

		nCol := 6

		oPrinter:Say(0365+nPos,0526, cRastro	,oFont09,,0)
		//MSBAR3('CODE128',nPosBarra,2.6, cRastro, oPrinter,.F.,,.T.,0.030,1,.F.,oFontBAR,'CODE128',.F.)
		oPrinter:FWMsBar("CODE128" /*cTypeBar*/,nPosBarra/*nRow*/,nCol/*nCol*/,AllTrim(cRastro)/*cCode*/,oPrinter/*oPrint*/,.F./*lCheck*/,/*Color*/,;
						.T./*lHorz*/, 0.020/*nWidth*/,1.0/*nHeigth*/,.F./*lBanner*/,/*cFont*/,'CODE128'/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)

		oPrinter:Say(0632+nPos,0140+nEsq, "REMETENTE: "+AllTrim(SM0->M0_NOMECOM)	, oFont09,,0)
		oPrinter:Say(0680+nPos,0140+nEsq, "ENDEREÇO PARA DEVOLUÇÃO DO OBJETO:"		, oFont09,,0)
		oPrinter:Say(0730+nPos,0140+nEsq, AllTrim(SM0->M0_ENDCOB)					, oFont09,,0)
		oPrinter:Say(0780+nPos,0140+nEsq, AllTrim(SM0->M0_COMPCOB)+', '+ AllTrim(SM0->M0_BAIRCOB)					, oFont09,,0)
		oPrinter:Say(0830+nPos,0140+nEsq, SM0->M0_CEPCOB +'  '+ AllTrim(SM0->M0_CIDCOB)+'-'+SM0->M0_ESTCOB  		, oFont09,,0)

		oPrinter:Say(0127+nPos,1289+nEsq, "TENTATIVAS DE ENTREGA",oFont08,,0)
		oPrinter:Say(0200+nPos,1290+nEsq,"1º _____/_____/_____       ______:______ h",oFont08,,0)
		oPrinter:Say(0275+nPos,1290+nEsq,"2º _____/_____/_____       ______:______ h",oFont08,,0)
		oPrinter:Say(0350+nPos,1290+nEsq,"3º _____/_____/_____       ______:______ h",oFont08,,0)
		oPrinter:Say(0576+nPos,1297+nEsq,"MOTIVO DE DEVOLUÇÃO:",oFont08,,0)

		nPos := nPos - 20
		oPrinter:Box(0640+nPos,1303+nEsq,(0687+nPos),1350+nEsq)
		oPrinter:Box(0700+nPos,1303+nEsq,(0747+nPos),1350+nEsq)
		oPrinter:Box(0760+nPos,1303+nEsq,(0807+nPos),1350+nEsq)
		oPrinter:Box(0820+nPos,1303+nEsq,(0867+nPos),1350+nEsq)
		oPrinter:Box(0880+nPos,1303+nEsq,(0927+nPos),1350+nEsq)

		oPrinter:Box(0640+nPos,1647+nEsq,(0687+nPos),1694+nEsq)
		oPrinter:Box(0700+nPos,1647+nEsq,(0747+nPos),1694+nEsq)
		oPrinter:Box(0760+nPos,1647+nEsq,(0807+nPos),1694+nEsq)
		oPrinter:Box(0820+nPos,1647+nEsq,(0867+nPos),1694+nEsq)

		nLinha := 30

		oPrinter:Say(0642+nPos+nLinha,1318+nEsq,"1",oFont08,,0)
		oPrinter:Say(0702+nPos+nLinha,1318+nEsq,"2",oFont08,,0)
		oPrinter:Say(0762+nPos+nLinha,1318+nEsq,"3",oFont08,,0)
		oPrinter:Say(0822+nPos+nLinha,1318+nEsq,"4",oFont08,,0)
		oPrinter:Say(0882+nPos+nLinha,1318+nEsq,"9",oFont08,,0)

		oPrinter:Say(0642+nPos+nLinha,1662+nEsq,"5",oFont08,,0)
		oPrinter:Say(0702+nPos+nLinha,1662+nEsq,"6",oFont08,,0)
		oPrinter:Say(0762+nPos+nLinha,1662+nEsq,"7",oFont08,,0)
		oPrinter:Say(0822+nPos+nLinha,1662+nEsq,"8",oFont08,,0)

		oPrinter:Say(0650+nPos+nLinha,1365+nEsq,"Modou-se",oFont05,,0)
		oPrinter:Say(0710+nPos+nLinha,1365+nEsq,"Endereço insuficiente",oFont05,,0)
		oPrinter:Say(0770+nPos+nLinha,1365+nEsq,"Não Existe o Número",oFont05,,0)
		oPrinter:Say(0830+nPos+nLinha,1365+nEsq,"Desconhecido",oFont05,,0)
		oPrinter:Say(0890+nPos+nLinha,1365+nEsq,"Outros ______________________________",oFont05,,0)

		oPrinter:Say(0650+nPos+nLinha,1713+nEsq,"Recusado",oFont05,,0)
		oPrinter:Say(0710+nPos+nLinha,1713+nEsq,"Não Procurado",oFont05,,0)
		oPrinter:Say(0770+nPos+nLinha,1713+nEsq,"Ausente",oFont05,,0)
		oPrinter:Say(0830+nPos+nLinha,1713+nEsq,"Falecido",oFont05,,0)

		nPos := nPos + 20

		oPrinter:Say(0130+nPos,2175,"CARIMBO",oFont05,,0)
		oPrinter:Say(0160+nPos,2120,"UNIDADE DE ENTREGA",oFont05,,0)
		oPrinter:Say(0640+nPos,2018+nEsq,"RUBRICA E MATRÍCULA CARTEIRO",oFont05,,0)

		nLinha	:= 10
		oPrinter:Say(0866+nPos+nLinha,0135+nEsq,"DECLARAÇÃO DE CONTEÚDO",oFont05,,0)
		oPrinter:Say(0936+nPos+nLinha,0135+nEsq,"ASSINATURA DO RECEBEDOR",oFont05,,0)
		oPrinter:Say(1006+nPos+nLinha,0135+nEsq,"NOME LEGÍVEL DO RECEBEDOR",oFont05,,0)
		oPrinter:Say(0936+nPos+nLinha,1610+nEsq,"DATA DE ENTREGA",oFont05,,0)
		oPrinter:Say(1006+nPos+nLinha,1610+nEsq,"Nº DOC. DE IDENTIDADE",oFont05,,0)

    	(cAlias)->(dbSkip())

 	EndDo

	oPrinter:EndPage()
	oPrinter:Print()

   	(cAlias)->(DbCloseArea())

   	FreeObj(oPrinter)
FwLogMsg("INFO",  , "ZEBRA", "ZEBRA", "", "01", "LINHA 2288", 0, 0, {})

Return



User Function fTeste()

	Local cnome := "SC"
	Local cdir	:= "\system\"
	Local nCont := 105470
	LOcal nI	:= 0

	For nI := 1 To 1000

		nCont++

		carquivo := cdir + cnome + cValToChar(nCont)
		nHandle := FCreate(carquivo)

		FWrite(nHandle, carquivo)

		FClose(nHandle)

	Next nI

Return