#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BACP0014
@author Gabriel Rossi Mafioletti
@since 03/10/2019
@version 1.0
@description Processo de Faturamento LM
@type function
/*/
User Function BACP0014()

	Local xv_Emps
	Local nI

	RpcSetEnv('01','01')

	xv_Emps := U_BAGtEmpr("01_05_13")

	RpcClearEnv()

	RpcSetEnv("07","01")

	//Parametro para desligar os Jobs Automaticos em caso de Necessidade
	If U_GETBIAPAR("BIA_FATAUTO", .T. , cEmpAnt, cFilAnt)

		For nI := 1 To Len(xv_Emps)
			
			If U_GETBIAPAR("BIA_FATAUTO", .T. , xv_Emps[nI,1], xv_Emps[nI,2])
			
				fProcessa(xv_Emps[nI,1], xv_Emps[nI,2])
			
			Else
			
				ConOut("BACP0014 ==> Cancelado/Desligado[BIA_FATAUTO] - " + Time()+" => Empresa: "+xv_Emps[nI,1]+" Filial: "+xv_Emps[nI,2])
			
			EndIf
			
		Next nI

	Else

		ConOut("BACP0014 ==> Cancelado/Desligado[BIA_FATAUTO] - " + Time()+" => Empresa: "+cEmpAnt+" Filial: "+cFilAnt)

	EndIf

	RpcClearEnv()

Return()

Static Function fProcessa(_cEmp,_cFil)

	Local _cAlias	:=	GetNextAlias()

	Local _cZZV		:=	""
	Local _cZZW		:=	""
	Local _cSC9		:=  ""
	Local _cSD2		:=  ""
	Local _cSql		:=	""
	
	Do Case
	
		Case (_cEmp == '01')
		
		_cZZV		:=	"ZZV010"
		_cZZW		:=	"ZZW010"
		_cSC9		:=  "%SC9010%"
		_cSD2		:=  "%SD2010%"

		Case (_cEmp == '05')
		
		_cZZV		:=	"ZZV050"
		_cZZW		:=	"ZZW050"
		_cSC9		:=  "%SC9050%"
		_cSD2		:=  "%SD2050%"

		Case (_cEmp == '13')
		
		_cZZV		:=	"ZZV130"
		_cZZW		:=	"ZZW130"
		_cSC9		:=  "%SC9130%"
		_cSD2		:=  "%SD2130%"

		OtherWise
		
		ConOut('BACP0014::Empresa/Filial não Cadastrada... '+_cEmp+'/'+_cFil+' - '+ Time())
		
		Return
		
	EndCase

	//Limpa temp
	_cSql := ""
	_cSql += "DROP TABLE IF EXISTS ##TMPZZW"
	TcSQLExec(_cSql)

	//Carrega temp ZZV e ZZW
	_cSql := ""
	_cSql += "SELECT ZZW.ZZW_FILIAL, ZZW.ZZW_PEDIDO, ZZW.ZZW_ITEM, ZZW.ZZW_SEQUEN, ZZW.ZZW_CARGA "
	_cSql += "INTO ##TMPZZW " 
	_cSql += "FROM "+_cZZV+" ZZV WITH (NOLOCK) "
	_cSql += "JOIN "+_cZZW+" ZZW WITH (NOLOCK) ON ( "
	_cSql += "		ZZV.ZZV_FILIAL		= ZZW.ZZW_FILIAL "
	_cSql += "		AND ZZV.ZZV_CARGA	= ZZW.ZZW_CARGA "
 	_cSql += "		AND ZZW_CCLI 		= '010064'	"
	_cSql += "		AND ZZW.D_E_L_E_T_	= ''		"
	_cSql += "									)	"
	_cSql += "WHERE ZZV.ZZV_FILIAL 		= '01' 	"
 	_cSql += "		AND ZZV.ZZV_FIMP	<> '' 	"
	_cSql += "		AND ZZV.D_E_L_E_T_	= ''	"
	TcSQLExec(_cSql)


	BeginSql Alias _cAlias
	
		%NoParser%

		SELECT ZZW_CARGA, NC9BIA = COUNT(SC9B.R_E_C_N_O_), NC9LM = COUNT(SC9.R_E_C_N_O_)

		FROM ##TMPZZW ZZW (NOLOCK)

		JOIN %Exp:_cSC9% SC9B (NOLOCK) ON 
		(
			SC9B.C9_FILIAL 		= ZZW.ZZW_FILIAL
			AND SC9B.C9_PEDIDO 	= ZZW.ZZW_PEDIDO
			AND SC9B.C9_ITEM 	= ZZW.ZZW_ITEM
			AND SC9B.C9_SEQUEN 	= ZZW.ZZW_SEQUEN		 		
			AND SC9B.C9_BLCRED 	= '10'
			AND SC9B.C9_BLEST 	= '10'
			AND SC9B.C9_CLIENTE = '010064'
			AND SC9B.D_E_L_E_T_	= ''	
		)
		
		JOIN %Exp:_cSD2% SD2B (NOLOCK) ON
		(
			SD2B.D2_FILIAL 		= SC9B.C9_FILIAL
			AND SD2B.D2_DOC 	= SC9B.C9_NFISCAL
			AND SD2B.D2_SERIE 	= SC9B.C9_SERIENF
			AND SD2B.D2_CLIENTE = SC9B.C9_CLIENTE
			AND SD2B.D2_LOJA 	= SC9B.C9_LOJA
			AND SD2B.D2_PEDIDO 	= SC9B.C9_PEDIDO
			AND SD2B.D2_ITEMPV 	= SC9B.C9_ITEM
			AND SD2B.D2_QTDEDEV = 0
			AND SD2B.D_E_L_E_T_	= ''
		)
		
		JOIN SC5070 SC5 (NOLOCK) ON
		(
			SC5.C5_FILIAL 		= '01'
			AND SC5.C5_YEMPPED  = %Exp:_cEmp%
			AND SC5.C5_YPEDORI 	= ZZW.ZZW_PEDIDO			
			AND SC5.D_E_L_E_T_	= ''
		)
		
		JOIN SC9070 SC9 (NOLOCK) ON
		(
			SC9.C9_FILIAL 		= SC5.C5_FILIAL
			AND SC9.C9_PEDIDO 	= SC5.C5_NUM
			AND SC9.C9_ITEM 	= ZZW.ZZW_ITEM
			AND SC9.C9_PRODUTO 	= SC9B.C9_PRODUTO
			AND SC9.C9_QTDLIB 	= SC9B.C9_QTDLIB
			AND SC9.C9_BLCRED 	= ''
			AND SC9.C9_BLEST 	= ''
			AND SC9.D_E_L_E_T_	= ''
		)
		
		WHERE 
			NOT EXISTS 
		(
			SELECT 1
			FROM SD2070 SD2 (NOLOCK)
			JOIN SF2070 SF2 (NOLOCK) ON
			(
				SF2.F2_FILIAL		= SD2.D2_FILIAL
				AND SF2.F2_DOC		= SD2.D2_DOC
				AND SF2.F2_SERIE	= SD2.D2_SERIE
				AND SF2.F2_CLIENTE	= SD2.D2_CLIENTE
				AND SF2.F2_LOJA		= SD2.D2_LOJA
				AND SF2.D_E_L_E_T_	= '*'
			)
			WHERE SD2.D2_PEDIDO = ZZW.ZZW_PEDIDO
			AND SD2.D2_ITEM 	= ZZW.ZZW_ITEM
			AND SubString(SF2.F2_YAGREG, 5, 4)	= ZZW.ZZW_CARGA
			AND SD2.D_E_L_E_T_	= '*'
		)
		
		AND NOT EXISTS 
		(
			SELECT 1
			FROM SC9070 SC9E (NOLOCK)
			WHERE SC9E.C9_FILIAL	= SC9.C9_FILIAL
			AND SC9E.C9_PEDIDO 		= SC9.C9_PEDIDO 
			AND SC9E.C9_ITEM 		= SC9.C9_ITEM
			AND SC9E.C9_CLIENTE		= SC9.C9_CLIENTE
			AND SC9E.C9_LOJA		= SC9.C9_LOJA
			AND SC9E.C9_AGREG		= SC9.C9_AGREG
			AND SC9E.C9_NFISCAL		<> ''
			AND SC9E.D_E_L_E_T_		= '*'
		)

		GROUP BY ZZW_CARGA
		HAVING COUNT(SC9B.R_E_C_N_O_) = COUNT(SC9.R_E_C_N_O_)
		ORDER BY ZZW_CARGA

	EndSql	

	If (_cAlias)->(EOF())
	
		ConOut('BACP0014::Sem Registros para processar - NFS LM.. '+ Time())
		
		ConOut('BACP0014::SQL:'+ GetLastQuery()[2])
		
	Endif

	While (_cAlias)->(!EOF())

		ConOut('BACP0014::Ok FATLM - Faturamento Carga LM: '+(_cAlias)->ZZW_CARGA+ Time())

		fGetPdOr(_cEmp,(_cAlias)->ZZW_CARGA,(_cAlias)->ZZW_CARGA,'','ZZZZZZ')

		U_BACP0010((_cAlias)->ZZW_CARGA,_cEmp)

		(_cAlias)->(DbSkip())

	EndDo

Return()

/*/{Protheus.doc} fGetPdOr
@description Função para Buscar os Pedidos/Produtos na Origem 
@description Revisoes durante o projeto CICLO DO PEDIDO em 08/2019
@author Fernando Rocha / Ranisses Corona
@since 18/07/2016
@version 1.0
@type function
/*/
Static Function fGetPdOr(cEmp,cAgreIni,cAgreFim,cPedIni,cPedFim)

	Local aRet		:= {}	//Variavel de Retorno
	Local lSeq		:= .T.	//Variavel que determina o uso do campo C9_SEQUEN na chave de pesquisa
	Local nPed		:= ""   
	Local nProd		:= ""
	Local nQtd   	:= ""
	Local cSql 		:= ""
	Local cSql2		:= ""
	Local nTable	:= "SC9"+cEmp+"0"
	Local aAreaC9	:= SC9->(GetArea())
	Local cRecProc	:= ""
	Local lFilPed	:= Empty(cAgreIni) .Or. Empty(cAgreFim)
	Local cPedOri	:= ""

	If lFilPed

		SC5->(DbSetOrder(1))
		
		If SC5->(DbSeek(XFilial("SC5")+cPedIni))

			cPedOri := SC5->C5_YPEDORI
			cEmp	:= SC5->C5_YEMPPED 
			nTable	:= "SC9"+cEmp+"0"

		EndIf

	EndIf

	//Pesquisa pedidos liberados na LM
	cSql := "SELECT C5_NUM, C9_AGREG, RTRIM(C9_PRODUTO)+C9_ITEM AS C9_PRODUTO, C9_SEQUEN, ROUND(CAST(C9_QTDLIB AS DECIMAL (10,2)),2) C9_QTDLIB, C9_PEDIDO AS PEDORI, C9_ITEM AS ITORI, C9_PRODUTO AS PRODORI, C9_NFISCAL, C9_SERIENF, SC9.R_E_C_N_O_ AS RECNO "
	cSql += "FROM "+nTable+" SC9 INNER JOIN SC5070 SC5 ON "
	cSql += "	C9_PEDIDO = C5_YPEDORI " 
	cSql += "WHERE C9_FILIAL	= '01' "
	cSql += "	AND C5_FILIAL	= '"+XFILIAL("SC5")+"' " 

	If !lFilPed
		cSql += "	AND C9_AGREG 	>= '"+cAgreIni+"' "  
		cSql += "	AND C9_AGREG 	<= '"+cAgreFim+"' "
	Else
		cSql += "	AND C9_PEDIDO 	>= '"+cPedOri+"' "  
		cSql += "	AND C9_PEDIDO 	<= '"+cPedOri+"' "
	EndIf

	cSql += "	AND C5_YEMPPED 	= '"+cEmp+"' " 
	cSql += "	AND C9_NFISCAL <> '' " 
	cSql += "	AND SC5.D_E_L_E_T_ = '' " 
	cSql += "	AND SC9.D_E_L_E_T_ = '' "	
	
	If chkfile("RAC")
	
		DbSelectArea("RAC")
		DbCloseArea()
		
	EndIf
	
	TcQuery cSql New Alias "RAC"

	RAC->(DbGoTop())
	
	While .Not. RAC->(Eof())          	

		//Fernando/Facile - 16/09/2016 - Pesquisar a Sequencia liberada na LM para vincular com a origem
		cSql2 := " SELECT REC = R_E_C_N_O_, C9_SEQUEN FROM SC9070 "		 
		cSql2 += " WHERE C9_FILIAL	= '"+XFilial("SC9")+"' "
		cSql2 += " AND C9_NFISCAL	= '' "
		cSql2 += " AND C9_PEDIDO 	= '"+RAC->C5_NUM+"' "
		cSql2 += " AND C9_ITEM 		= '"+RAC->ITORI+"' "		 
		cSql2 += " AND C9_PRODUTO 	= '"+RAC->PRODORI+"' "
		cSql2 += " AND ROUND(CAST (C9_QTDLIB AS DECIMAL (10,2)),2) = "+AllTrim(Str(RAC->C9_QTDLIB))+" "

		If !Empty(cRecProc)
		
			cSql2 += " AND R_E_C_N_O_ NOT IN "+FormatIn(cRecProc,"/")+" "
			
		EndIf

		cSql2 += " AND D_E_L_E_T_='' "
		cSql2 += " ORDER BY REC " 

		If chkfile("LIBLM")
		
			DbSelectArea("LIBLM")
			DbCloseArea()
			
		EndIf
		
		TcQuery cSql2 New Alias "LIBLM"

		//Se achou a sequencia na LM
		If !LIBLM->(Eof())

			If !Empty(nPed)
				nPed	+= "/"	  	
				nProd	+= "/"
				nQtd	+= "/"
			EndIf

			//Associa pedido e sequencia para o filtro do SC9
			nPed	+= Alltrim(RAC->C5_NUM)
			nProd	+= Alltrim(RAC->C9_PRODUTO)+Alltrim(LIBLM->C9_SEQUEN)  //sempre a sequencia localizada na LM
			nQtd	+= Alltrim(Str(Round(RAC->C9_QTDLIB,2)))	

			//Gravar a chave de vinculacao no campo C9_BLINF
			SC9->(DbSetOrder(0)) 
			SC9->(DbGoto(LIBLM->REC))
			
			If !SC9->(Eof())
			
				SC9->(RecLock("SC9",.F.))

				SC9->C9_BLINF	:= AllTrim(cEmp)+RAC->(C9_NFISCAL+C9_SERIENF+PEDORI+ITORI+C9_SEQUEN)
				SC9->C9_AGREG	:= RAC->C9_AGREG
				SC9->C9_YEMPORI	:= cEmp

				SC9->(MsUnLock())
				
			EndIf

			If !Empty(cRecProc)
				cRecProc += "/"
			EndIf

			cRecProc += AllTrim(Str(LIBLM->REC))

		EndIf
		
		LIBLM->(DbCloseArea())

		RAC->(DbSkip())
		
	EndDo
	
	RAC->(DbCloseArea())

	AADD(aRet,nPed)     //01
	AADD(aRet,nProd)    //02
	AADD(aRet,nQtd)     //03
	AADD(aRet,lSeq)     //04
	AADD(aRet,MV_PAR05) //05
	AADD(aRet,MV_PAR06) //06
	AADD(aRet,nTable)   //07
	AADD(aRet,MV_PAR19) //08
	AADD(aRet,cAgreIni) //09
	AADD(aRet,cAgreFim) //10

	RestArea(aAreaC9)

Return(aRet)
