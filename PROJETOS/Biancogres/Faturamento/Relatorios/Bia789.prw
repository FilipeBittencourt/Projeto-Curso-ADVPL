#include "protheus.ch"
#include "rwmake.ch"
#INCLUDE "TOPCONN.CH"
#include "buttom.ch"

/*/{Protheus.doc} BIA789
@description MAPA DE PEDIDOS NÃO ATENDIDOS
@author Alexandre Panetto
@since 04/04/05 
@version 1.0
@type function
@obs Retirado funcao fUpdSC63. O campo C6_YSTAT esta gravado atraves de job SQL
@obs Ticket 22844 - Tratar travamentos
@version V12 - Revisado por Fernando Rocha
/*/
User Function BIA789()

	Local aOrd 			 	:= {}
	Local cDesc1		 	:= "Este programa tem como objetivo emitir um mapa de Pedidos"
	Local cDesc2		 	:= "nao atendidos por vendedor.             "
	Local cDesc3         	:= ""
	Local titulo		 	:= "MAPA DE PEDIDO NAO ATENDIDOS"
	Local Cabec1		 	:= "CODIGO  DATA DE   CODIGO DO       DESCRICAO DO                  PRECO      _________VOLUME(M2)__________      PESO     OBSERVACAO              DT NEC.   DT PREV   DT DISP                                "
	Local Cabec2		 	:= "PEDIDO  EMISSAO   PRODUTO         PRODUTO                       MEDIO      PEDIDO    ATENDIDO      SALDO      BRUTO    (TRANSPORTADORA)        ENGEN     INICIAL   OP        COND.PAG          LOCAL   PC "
	Local cLoad				:= "BIA789" + cEmpAnt
	Local cFileName			:= RetCodUsr() +"_"+ cLoad



	Private oAceTela 	:= TAcessoTelemarketing():New()


	Private nNomeSC5	:= "##BIA789SC5"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //+strzero(seconds()*3500,10)
	Private nNomeSC6	:= "##BIA789SC6"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))
	Private nNomeSC9	:= "##BIA789SC9"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

	Private Enter 		 := CHR(13)+CHR(10)
	Private nLin         := 80
	Private lAbortPrint  := .F.
	Private Tamanho      := "G"
	Private NomeProg     := "BIA789"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "BIA074"

	Private m_pag        := 01  //Private obrigatoria dentro do fonte padrao da funcao "cabec" nao remover
	Private cString      := "SC5"

	Private nTotReg		 := 0
	Private lFirstCc     := .T.
	Private lFirstCta    := .T.
	Private aVend        := {}
	Private cNumPed      := ''

	MV_PAR01 := SPACE(6) 	//"Pedido de 	?"
	MV_PAR02 := SPACE(6)     //	   "Pedido ate
	MV_PAR03 := SPACE(6)     //	   "Vendedor de
	MV_PAR04 := SPACE(6)     //	   "Vendedor ate
	MV_PAR05 := STOD("")     //	   "Emissao Pedido de  ?"
	MV_PAR06 := STOD("")     //	   "Emissao Pedido ate ?"
	MV_PAR07 := SPACE(9)     //	   "Situacao
	MV_PAR08 := SPACE(1)     //	   "Marca
	MV_PAR09 := SPACE(6)     //	   "Cliente de
	MV_PAR10 := SPACE(6)     //	   "Cliente ate
	MV_PAR11 := SPACE(15)    //	   "Produto de
	MV_PAR12 := SPACE(15)    //	   "Produto ate
	MV_PAR13 := SPACE(1)    //	   "Gera Duplicata?"
	MV_PAR14 := SPACE(1)    //	   "Atualiza Estoque?"
	MV_PAR15 := SPACE(1)    //	   "Mercado ?"
	MV_PAR16 := SPACE(6)    //	   "Grupo de
	MV_PAR17 := SPACE(6)    //	   "Grupo ate
	MV_PAR18 := SPACE(1)    //	   "Filtra Vendedores?"
	MV_PAR19 := SPACE(6)    //	   "Atendente?"
	MV_PAR20 := SPACE(6)    //	   "Segmento De?"
	MV_PAR21 := SPACE(6)    //	   "Segmento Ate? "
	MV_PAR22 := SPACE(2)    //	   "Tipo do Pedido ?"
	MV_PAR23 := SPACE(1)    //	   "Considera Rotas?"
	MV_PAR24 := SPACE(15)    //	   "Pedido de Compra Cliente?"
	MV_PAR25 := SPACE(1)    //	   "Exportar Para Excel?"
	MV_PAR26 := SPACE(1)    //	   "Layout?"
	MV_PAR27 := SPACE(1)    //	   "Classe De?"
	MV_PAR28 := SPACE(1)    //	   "Classe Ate?"
	MV_PAR29 := SPACE(2)    //	   "Regiao De?"
	MV_PAR30 := SPACE(2)    //	   "Regiao Ate?"
	MV_PAR31 := SPACE(6)    //	   "Rede de Compras De?"
	MV_PAR32 := SPACE(6)    //	   "Rede de Compras Ate?"
    MV_PAR33 := SPACE(1)    // Tp Segmento ? A1_YTPSEG

 
    //MV_PAR33 := ''


	aMarca		:= {'1=Biancogres', '2=Incesa', '3=Bellacasa', '4=Incesa/Bellacasa', '5=Pegasus','6=Vinilico', '7=Todas'}
	aPergs		:= {}


	aAdd( aPergs ,{1,"Pedido de"			, MV_PAR01	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Pedido ate"			, MV_PAR02	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Vendedor de"	   		, MV_PAR03	,"",,"SA3",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Vendedor ate"     		, MV_PAR04	,"",,"SA3",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Emissao Pedido de"		, MV_PAR05	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Emissao Pedido ate"		, MV_PAR06	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Situacao"				, MV_PAR07	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Marca"				, MV_PAR08, aMarca, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Cliente de"	   		, MV_PAR09	,"",,"SA1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cliente ate"     		, MV_PAR10	,"",,"SA1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto de"	   		, MV_PAR11	,"",,"SB1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto ate"     		, MV_PAR12	,"",,"SB1",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Gera Duplicata"			, MV_PAR13, {'1=Gerar', '2=Não Gerar', '3=Ambas'}, 50, ".T.",.F.})
	aAdd( aPergs ,{2,"Atualiza Estoque"		, MV_PAR14, {'1=Gerar', '2=Não Gerar', '3=Ambas'}, 50, ".T.",.F.})
	aAdd( aPergs ,{2,"Mercado"				, MV_PAR15, {'1=Interno', '2=Externo', '3=Ambas'}, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Grupo de"	   			, MV_PAR16	,"",,"ACY",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Grupo ate"     			, MV_PAR17	,"",,"ACY",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Filtra Vendedores"		, MV_PAR18, {'1=Sim', '2=Não'}, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Atendente"	   			, MV_PAR19	,"",,"USR",'.T.',50,.F.})

   // aAdd( aPergs ,{2,"Segmento"     		, MV_PAR33	,{'1=R','2=E','3=H','4=X','5=Todos'}, 50, ".T.",.F.}) 

    aAdd( aPergs ,{1,"Segmento De"     		, MV_PAR20	,"",,"T3",'.F.',50,.F.}) 
	aAdd( aPergs ,{1,"Segmento Ate"     		, MV_PAR21	,"",,"T3",'.F.',50,.F.}) 
	
    aAdd( aPergs ,{1,"Tipo do Pedido "			, MV_PAR22	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Considera Rotas"			, MV_PAR23, {'1=Sim', '2=Não'}, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Pedido de Compra Cliente", MV_PAR24	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Exportar Para Excel"		, MV_PAR25, {'1=Sim', '2=Não'}, 50, ".T.",.F.})
	aAdd( aPergs ,{2,"Layout"					, MV_PAR26, {'1=Padrao', '2=Representante'}, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Classe De"     			, MV_PAR27	,"",,"ZZ8",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Classe Ate"     			, MV_PAR28	,"",,"ZZ8",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Regiao De"     			, MV_PAR29	,"",,"12",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Regiao Ate"     			, MV_PAR30	,"",,"12",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Rede de Compras De"  	, MV_PAR31	,"",,"Z79",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Rede de Compras Ate" 	, MV_PAR32	,"",,"Z79",'.T.',50,.F.})

    aAdd( aPergs ,{2,"Segmento"     		, MV_PAR33	,{'1=R','2=E','3=H','4=X','5=Todos'}, 50, ".T.",.F.}) 

	dbSelectArea("SC5")
	dbSetOrder(1)

	If GetRemoteType() == 5

		If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
			Return()
		EndIf
		/*If !Pergunte(cPerg,.T.)
		Return
	EndIf*/

		Processa({||  Monta_Arq()})

		RptStatus({|| U_BIA789_3() })
		Return()
EndIf

If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
		Return()
EndIf
	//pergunte(cPerg,.F.)

	MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
	MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
	MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
	MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
	MV_PAR05 := ((ParamLoad(cFileName,,5,MV_PAR05)))
	MV_PAR06 := ((ParamLoad(cFileName,,6,MV_PAR06)))
	MV_PAR07 := ParamLoad(cFileName,,7,MV_PAR07)
	MV_PAR08 := Val(ParamLoad(cFileName,,8,MV_PAR08))
	MV_PAR09 := ParamLoad(cFileName,,9,MV_PAR09)
	MV_PAR10 := ParamLoad(cFileName,,10,MV_PAR10)
	MV_PAR11 := ParamLoad(cFileName,,11,MV_PAR11)
	MV_PAR12 := ParamLoad(cFileName,,12,MV_PAR12)
	MV_PAR13 := VAl(ParamLoad(cFileName,,13,MV_PAR13))
	MV_PAR14 := VAl(ParamLoad(cFileName,,14,MV_PAR14))
	MV_PAR15 := VAl(ParamLoad(cFileName,,15,MV_PAR15))
	MV_PAR16 := ParamLoad(cFileName,,16,MV_PAR16)
	MV_PAR17 := ParamLoad(cFileName,,17,MV_PAR17)
	MV_PAR18 := Val(ParamLoad(cFileName,,18,MV_PAR18))
	MV_PAR19 := ParamLoad(cFileName,,19,MV_PAR19)    
    MV_PAR20 := ParamLoad(cFileName,,20,MV_PAR20) 
	MV_PAR21 := ParamLoad(cFileName,,21,MV_PAR21) 
	MV_PAR22 := ParamLoad(cFileName,,22,MV_PAR22)
	MV_PAR23 := Val(ParamLoad(cFileName,,23,MV_PAR23))
	MV_PAR24 := ParamLoad(cFileName,,24,MV_PAR24)
	MV_PAR25 := Val(ParamLoad(cFileName,,25,MV_PAR25))
	MV_PAR26 := Val(ParamLoad(cFileName,,26,MV_PAR26))
	MV_PAR27 := ParamLoad(cFileName,,27,MV_PAR27)
	MV_PAR28 := ParamLoad(cFileName,,28,MV_PAR28)
	MV_PAR29 := ParamLoad(cFileName,,29,MV_PAR29)
	MV_PAR30 := ParamLoad(cFileName,,30,MV_PAR30)
	MV_PAR31 := ParamLoad(cFileName,,31,MV_PAR31)
	MV_PAR32 := ParamLoad(cFileName,,32,MV_PAR32)
	MV_PAR33 := ParamLoad(cFileName,,33,MV_PAR33)
	MV_PAR34 := ParamLoad(cFileName,,34,MV_PAR34)
	MV_PAR35 := ParamLoad(cFileName,,35,MV_PAR35)
	MV_PAR36 := ParamLoad(cFileName,,36,MV_PAR36)

    MV_PAR20 := '000001'
    MV_PAR21 := '999999'

	//NomeProg
	//Monta a interface padrao com o usuario...
	NomeProg := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
		Return
Endif

	SetDefault(aReturn,cString)

If nLastKey == 27
		Return
Endif

	nTipo := If(aReturn[4]==1,15,18)

If MV_PAR33== "1"
    MV_PAR33 := 'R'
ElseIf MV_PAR33 == "2"
    MV_PAR33 := 'E'
ElseIF MV_PAR33 == "3"
    MV_PAR33 := 'H' 
ElseIF MV_PAR33 == "4"
    MV_PAR33 := 'X'
EndIf

if MV_PAR18 == 1
		lOk       := .T.
		cVend := ""
	do while lOk
			@ 000,000 TO 150,350 DIALOG oDialog TITLE "Selecao"
			@ 005,005 SAY "Digite abaixo, separando por ';', cada representante que deseja pesquisar."
			@ 020,005 GET cVend SIZE 130,050 MEMO
			@ 060,140 BMPBUTTON TYPE BT_OK ACTION fFinaliza()
			ACTIVATE DIALOG oDialog CENTERED
	enddo
	if len(aVend) == 0
			cMsg := ""
			cMsg += "O parametro 'Selecionar Representantes' esta configurado como 'SIM',"+chr(13)
			cMsg += "portanto se faz necessaria a digitacao dos representantes no quadro "+chr(13)
			cMsg += "anterior."
			alert(cMsg)
			return
	endif
endif

	Processa({||  Monta_Arq()})  

If(MV_PAR25 == 2)	//IMPRESSAO EM TELA
		RptStatus({|| Impr_Arq(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Else
		//EXPORTAR PARA EXCEL
		RptStatus({|| U_BIA789_2() })	
EndIf
Return


/*/{Protheus.doc} Monta_Arq
@description Monta o Arquivo de Trabalho Principal
@since 25/01/2018
@version 1.0
@type function
/*/
Static Function Monta_Arq()

	Local cLinPed := '' //linha descomentada: Pablo S. Nascimento em correção do ticket 22091
	cData_ini := ''
	if val(substr(dtos(MV_PAR05),3,2)) < 70
		cData_ini := '20' + substr(dtos(MV_PAR05),3,2) + substr(dtos(MV_PAR05),5,2) + substr(dtos(MV_PAR05),7,2)
	else
		cData_ini := '19' + substr(dtos(MV_PAR05),3,2) + substr(dtos(MV_PAR05),5,2) + substr(dtos(MV_PAR05),7,2)
	endif

	cData_fim := ''
	if val(substr(dtos(MV_PAR06),3,2)) < 70
		cData_fim := '20' + substr(dtos(MV_PAR06),3,2) + substr(dtos(MV_PAR06),5,2) + substr(dtos(MV_PAR06),7,2)
	else
		cData_fim := '19' + substr(dtos(MV_PAR06),3,2) + substr(dtos(MV_PAR06),5,2) + substr(dtos(MV_PAR06),7,2)
	endif

	cData_Base := ''
	if val(substr(dtos(ddatabase),3,2)) < 70
		cData_Base := '20' + substr(dtos(ddatabase),3,2) + substr(dtos(ddatabase),5,2) + substr(dtos(ddatabase),7,2)
	else
		cData_Base := '19' + substr(dtos(ddatabase),3,2) + substr(dtos(ddatabase),5,2) + substr(dtos(ddatabase),7,2)
	endif

	//PERGUNTA 08 MARCA - CONSOLIDACAO
	//Wlysses/Thiago Haagensen - Ticket 22824 (Tratativa dos tipos váriáveis no Protheus WEB)
	If ValType(MV_PAR08) == "C"
		MV_PAR08 := Val(MV_PAR08)
	EndIf

	If ValType(MV_PAR13) == "C"
		MV_PAR13 := Val(MV_PAR13)
	EndIf

	If ValType(MV_PAR14) == "C"
		MV_PAR14 := Val(MV_PAR14)
	EndIf

	If ValType(MV_PAR15) == "C"
		MV_PAR15 := Val(MV_PAR15)
	EndIf

	If ValType(MV_PAR18) == "C"
		MV_PAR18 := Val(MV_PAR18)
	EndIf

	If ValType(MV_PAR23) == "C"
		MV_PAR23 := Val(MV_PAR23)
	EndIf

	If ValType(MV_PAR25) == "C"
		MV_PAR25 := Val(MV_PAR25)
	EndIf

	If ValType(MV_PAR26) == "C"
		MV_PAR26 := Val(MV_PAR26)
	EndIf

	//PERGUNTA 08 MARCA - CONSOLIDACAO
	If cEmpAnt == "01"
		Do Case
		Case MV_PAR08 == 1 	//BIANCOGRES
			cLinPed	:= "'1'"
		Case MV_PAR08 == 2 	//INCESA
			cLinPed	:= "'2'"
		Case MV_PAR08 == 3 	//BELLACASA
			cLinPed	:= "'3'"
		Case MV_PAR08 == 4	//INCESA/BELLACASA
			cLinPed	:= "'2','3'"
		Case MV_PAR08 == 5	//Pegasus
			cLinPed	:= "'5'"
		Case MV_PAR08 == 6	//VINILICO
			cLinPed	:= "'6'"
		Case MV_PAR08 == 7	//TODAS
			cLinPed	:= "'1','2','3','4','5','6'"
		EndCase
	Elseif cEmpAnt == "05"
		Do Case
		Case MV_PAR08 == 1 	//BIANCOGRES
			cLinPed	:= "'1'"
		Case MV_PAR08 == 2 	//INCESA
			cLinPed	:= "'2'"
		Case MV_PAR08 == 3 	//BELLACASA
			cLinPed	:= "'3'"
		Case MV_PAR08 == 4	//INCESA/BELLACASA
			cLinPed	:= "'2','3'"
		Case MV_PAR08 == 5	//Pegaus
			cLinPed	:= "'5'"
		Case MV_PAR08 == 6	//VINILICO
			cLinPed	:= "'6'"
		Case MV_PAR08 == 7	//TODAS
			cLinPed	:= "'1','2','3','4','5','6'"
		EndCase
	ElseIf cEmpAnt == "07"
		Do Case
		Case MV_PAR08 == 1 	//BIANCOGRES
			cLinPed	:= "'1'"
		Case MV_PAR08 == 2 	//INCESA
			cLinPed	:= "'2'"
		Case MV_PAR08 == 3 	//BELLACASA
			cLinPed	:= "'3'"
		Case MV_PAR08 == 4	//INCESA/BELLACASA
			cLinPed	:= "'2','3'"
		Case MV_PAR08 == 5	//Pegaus
			cLinPed	:= "'5'"
		Case MV_PAR08 == 6	//VINILICO
			cLinPed	:= "'6'"
		Case MV_PAR08 == 7	//TODAS
			cLinPed	:= "'1','2','3','4','5','6'"
		EndCase
	ElseIf cEmpAnt == "13"
		Do Case
			Case MV_PAR08 == 6	//VINILICO
			cLinPed	:= "'6'"
		EndCase	
	Else
		Do Case
		Case MV_PAR08 == 5 	//MUNDI
			cLinPed	:= "'1'"
		Case MV_PAR08 == 2 	//MUNDIALLI
			cLinPed	:= "'4'"
		Case MV_PAR08 == 3 	//MUNDI/MUNDIALLI
			cLinPed	:= "'1','4'"
		EndCase
	EndIf

	//GERA TMP DA TABELA SC5

	If cEmpAnt $ "01_05_07_13"  .And. (cEmpAnt+cFilAnt != '0705')

		//PEDIDOS BIANCOGRES
		cSql := ""
		cSql += "SELECT * INTO "+nNomeSC5+" FROM (	" + Enter
		cSql += "SELECT '01' AS 'EMPRESA',	" + Enter
		cSql += "	C5.C5_FILIAL, C5.C5_YEMP, C5.C5_NUM,	C5.C5_TIPO, C5.C5_YEMPPED, C5.C5_YLINHA,					" + Enter
		cSql += "	CLI_ORIG   = CASE WHEN C5.C5_YCLIORI <> '' THEN C5.C5_YCLIORI ELSE C5.C5_CLIENTE END,	" + Enter
		cSql += "	LOJ_ORIG   = CASE WHEN C5.C5_YLOJORI <> '' THEN C5.C5_YLOJORI ELSE C5.C5_LOJACLI END,	" + Enter
		cSql += "	C5_VEND    = CASE WHEN C5.C5_YCLIORI <> '' AND C5.C5_EMISSAO <= '20111231' THEN C5.C5_VEND1 WHEN C5.C5_YCLIORI <> '' AND C5.C5_EMISSAO >= '20120101' THEN LC5.C5_VEND1 ELSE C5.C5_VEND1 END, " + Enter
		cSql += "	C5_TRANSP1 = CASE WHEN C5.C5_YCLIORI <> '' THEN LC5.C5_TRANSP ELSE C5.C5_TRANSP	END," + Enter
		cSql += "	C5.C5_CLIENTE, C5.C5_LOJAENT,	C5.C5_LOJACLI,	C5.C5_YRECR,	C5.C5_YSUBTP,	C5.C5_TRANSP,		" + Enter
		cSql += "	C5.C5_TIPOCLI,	ISNULL(LC5.C5_CONDPAG, C5.C5_CONDPAG) AS C5_CONDPAG,	C5.C5_YFORMA,	C5.C5_YMAXCND,	C5.C5_YPERC,	C5.C5_YPRZINC,	C5.C5_YDTINC,	C5.C5_YPC,	C5.C5_VLRFRET,	C5.C5_YVLRREV,	C5.C5_YCLIDEL,	" + Enter
		cSql += "	C5.C5_YPERDEL,	C5.C5_YBAIDEL,	C5.C5_YNFDEL,	C5.C5_TABELA,	ISNULL(C5.C5_VEND1,'      ') AS C5_VEND1,	C5.C5_COMIS1,	C5.C5_VEND2,	C5.C5_COMIS2,	C5.C5_VEND3,	C5.C5_COMIS3,	C5.C5_VEND4,	C5.C5_COMIS4,	" + Enter
		cSql += "	C5.C5_VEND5,	C5.C5_COMIS5,	C5.C5_DESC1,	C5.C5_DESC2,	C5.C5_DESC3,	C5.C5_DESC4,	C5.C5_BANCO,	C5.C5_DESCFI,	C5.C5_EMISSAO,	C5.C5_COTACAO,	C5.C5_PARC1,	C5.C5_DATA1,	C5.C5_PARC2,	C5.C5_DATA2, " + Enter
		cSql += "	C5.C5_PARC3,	C5.C5_DATA3,	C5.C5_PARC4,	C5.C5_DATA4,	C5.C5_TPFRETE,	C5.C5_FRETE,	C5.C5_SEGURO,	C5.C5_DESPESA,	C5.C5_FRETAUT,	C5.C5_REAJUST,	C5.C5_MOEDA,	C5.C5_PESOL,	C5.C5_PBRUTO,	C5.C5_REIMP, " + Enter
		cSql += "	C5.C5_REDESP,	C5.C5_VOLUME1,	C5.C5_VOLUME2,	C5.C5_VOLUME3,	C5.C5_VOLUME4,	C5.C5_ESPECI1,	C5.C5_ESPECI2,	C5.C5_ESPECI3,	C5.C5_ESPECI4,	C5.C5_ACRSFIN,	C5.C5_MENNOTA,	C5.C5_MENPAD,	C5.C5_INCISS,	C5.C5_LIBEROK,	" + Enter
		cSql += "	C5.C5_OK,	C5.C5_NOTA,	C5.C5_SERIE,	C5.C5_VENDA,	C5.C5_KITREP,	C5.C5_TIPLIB,	C5.C5_OS,	C5.C5_YMARCA,	C5.C5_YNUMERO,	C5.C5_DESCONT,	C5.C5_PEDEXP,	C5.C5_TXMOEDA,	C5.C5_USERLGI,	C5.C5_USERLGA,	C5.C5_YAAPROV,	" + Enter
		cSql += "	ISNULL(LC5.C5_YAPROV, C5.C5_YAPROV) AS C5_YAPROV ,	C5.C5_YDIGP,	C5.C5_YALTP,	C5.C5_YOBS,	C5.C5_TPCARGA,	C5.C5_PREPEMB,	C5.C5_CLIENT,	C5.C5_PDESCAB,	C5.C5_YFLAG,	C5.C5_YEND,	C5.C5_YEST,	C5.C5_YMUN,	C5.C5_YBAIRRO,	" + Enter
		cSql += "	C5.C5_YCEP,	C5.C5_YTEL,	C5.C5_YFATOR,	C5.C5_YDESCLI,	C5.C5_RECISS,	C5.D_E_L_E_T_,	C5.R_E_C_N_O_,	C5.R_E_C_D_E_L_,	C5.C5_BLQ,	C5.C5_FORNISS,	C5.C5_CONTRA,	C5.C5_VLR_FRT,	C5.C5_YCC,	C5.C5_YVLTOTP,	C5.C5_YTPBLQ,	" + Enter
		cSql += "	C5.C5_YPEDPAI,	C5.C5_YMEDDES,	C5.C5_YMDESPD, C5.C5_YPEDORI, C5.C5_YITEMCT, C5.C5_YCLVL, C5.C5_YSI, C5.C5_YCLIORI, C5.C5_YLOJORI, C5.C5_YCODMUN, C5.C5_YTPTRAN, C5.C5_YTPCRED	" + Enter
		cSql += "FROM SC5010 C5 WITH (NOLOCK) " + Enter
		cSql += " LEFT  JOIN SC5070 LC5 WITH (NOLOCK) ON LC5.C5_FILIAL = '01' AND C5.C5_NUM  = LC5.C5_YPEDORI	AND C5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = C5.C5_YCLIORI AND C5.C5_YLOJORI = LC5.C5_LOJACLI AND C5.C5_YEMPPED = LC5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' " + Enter
		cSql += "WHERE 	C5.C5_FILIAL 	= '01'	AND 					" + Enter
		cSql += "		C5.C5_NUM 		IN (SELECT C6_NUM FROM SC6010 WITH (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = C5.C5_NUM AND (ROUND(C6_QTDVEN,2) - ROUND(C6_QTDENT,2)) > 0 AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '') AND
		cSql += "		C5.C5_EMISSAO	BETWEEN '"+cData_ini+"' AND '"+cData_fim+"' AND " + Enter
		cSql += "		C5.D_E_L_E_T_	= ''											" + Enter

		cSql += "UNION ALL	" + Enter

		//PEDIDOS INCESA
		cSql += "SELECT '05' AS 'EMPRESA', " + Enter
		cSql += "	C5.C5_FILIAL, C5.C5_YEMP,	C5.C5_NUM,	C5.C5_TIPO, C5.C5_YEMPPED, C5.C5_YLINHA,					" + Enter
		cSql += "	CLI_ORIG   = CASE WHEN C5.C5_YCLIORI <> '' THEN C5.C5_YCLIORI ELSE C5.C5_CLIENTE END,	" + Enter
		cSql += "	LOJ_ORIG   = CASE WHEN C5.C5_YLOJORI <> '' THEN C5.C5_YLOJORI ELSE C5.C5_LOJACLI END,	" + Enter
		cSql += "	C5_VEND    = CASE WHEN C5.C5_YCLIORI <> '' AND C5.C5_EMISSAO <= '20111231' THEN C5.C5_VEND1 WHEN C5.C5_YCLIORI <> '' AND C5.C5_EMISSAO >= '20120101' THEN LC5.C5_VEND1 ELSE C5.C5_VEND1 END, " + Enter
		cSql += "	C5_TRANSP1 = CASE WHEN C5.C5_YCLIORI <> '' THEN LC5.C5_TRANSP ELSE C5.C5_TRANSP	END," + Enter
		cSql += "	C5.C5_CLIENTE, C5.C5_LOJAENT,	C5.C5_LOJACLI,	C5.C5_YRECR,	C5.C5_YSUBTP,	C5.C5_TRANSP,		" + Enter
		cSql += "	C5.C5_TIPOCLI,	ISNULL(LC5.C5_CONDPAG, C5.C5_CONDPAG) AS C5_CONDPAG,	C5.C5_YFORMA,	C5.C5_YMAXCND,	C5.C5_YPERC,	C5.C5_YPRZINC,	C5.C5_YDTINC,	C5.C5_YPC,	C5.C5_VLRFRET,	C5.C5_YVLRREV,	C5.C5_YCLIDEL,	" + Enter
		cSql += "	C5.C5_YPERDEL,	C5.C5_YBAIDEL,	C5.C5_YNFDEL,	C5.C5_TABELA,	ISNULL(C5.C5_VEND1,'      ') AS C5_VEND1,	C5.C5_COMIS1,	C5.C5_VEND2,	C5.C5_COMIS2,	C5.C5_VEND3,	C5.C5_COMIS3,	C5.C5_VEND4,	C5.C5_COMIS4,	" + Enter
		cSql += "	C5.C5_VEND5,	C5.C5_COMIS5,	C5.C5_DESC1,	C5.C5_DESC2,	C5.C5_DESC3,	C5.C5_DESC4,	C5.C5_BANCO,	C5.C5_DESCFI,	C5.C5_EMISSAO,	C5.C5_COTACAO,	C5.C5_PARC1,	C5.C5_DATA1,	C5.C5_PARC2,	C5.C5_DATA2, " + Enter
		cSql += "	C5.C5_PARC3,	C5.C5_DATA3,	C5.C5_PARC4,	C5.C5_DATA4,	C5.C5_TPFRETE,	C5.C5_FRETE,	C5.C5_SEGURO,	C5.C5_DESPESA,	C5.C5_FRETAUT,	C5.C5_REAJUST,	C5.C5_MOEDA,	C5.C5_PESOL,	C5.C5_PBRUTO,	C5.C5_REIMP, " + Enter
		cSql += "	C5.C5_REDESP,	C5.C5_VOLUME1,	C5.C5_VOLUME2,	C5.C5_VOLUME3,	C5.C5_VOLUME4,	C5.C5_ESPECI1,	C5.C5_ESPECI2,	C5.C5_ESPECI3,	C5.C5_ESPECI4,	C5.C5_ACRSFIN,	C5.C5_MENNOTA,	C5.C5_MENPAD,	C5.C5_INCISS,	C5.C5_LIBEROK,	" + Enter
		cSql += "	C5.C5_OK,	C5.C5_NOTA,	C5.C5_SERIE,	C5.C5_VENDA,	C5.C5_KITREP,	C5.C5_TIPLIB,	C5.C5_OS,	C5.C5_YMARCA,	C5.C5_YNUMERO,	C5.C5_DESCONT,	C5.C5_PEDEXP,	C5.C5_TXMOEDA,	C5.C5_USERLGI,	C5.C5_USERLGA,	C5.C5_YAAPROV,	" + Enter
		cSql += "	ISNULL(LC5.C5_YAPROV, C5.C5_YAPROV) AS C5_YAPROV ,	C5.C5_YDIGP,	C5.C5_YALTP,	C5.C5_YOBS,	C5.C5_TPCARGA,	C5.C5_PREPEMB,	C5.C5_CLIENT,	C5.C5_PDESCAB,	C5.C5_YFLAG,	C5.C5_YEND,	C5.C5_YEST,	C5.C5_YMUN,	C5.C5_YBAIRRO,	" + Enter
		cSql += "	C5.C5_YCEP,	C5.C5_YTEL,	C5.C5_YFATOR,	C5.C5_YDESCLI,	C5.C5_RECISS,	C5.D_E_L_E_T_,	C5.R_E_C_N_O_,	C5.R_E_C_D_E_L_,	C5.C5_BLQ,	C5.C5_FORNISS,	C5.C5_CONTRA,	C5.C5_VLR_FRT,	C5.C5_YCC,	C5.C5_YVLTOTP,	C5.C5_YTPBLQ,	" + Enter
		cSql += "	C5.C5_YPEDPAI,	C5.C5_YMEDDES,	C5.C5_YMDESPD, C5.C5_YPEDORI, C5.C5_YITEMCT, C5.C5_YCLVL, C5.C5_YSI, C5.C5_YCLIORI, C5.C5_YLOJORI, C5.C5_YCODMUN, C5.C5_YTPTRAN, C5.C5_YTPCRED	" + Enter
		cSql += "FROM SC5050 C5 WITH (NOLOCK)										" + Enter
		cSql += " LEFT  JOIN SC5070 LC5 WITH (NOLOCK) ON LC5.C5_FILIAL = '01' AND C5.C5_NUM  = LC5.C5_YPEDORI	AND C5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = C5.C5_YCLIORI AND C5.C5_YLOJORI = LC5.C5_LOJACLI AND C5.C5_YEMPPED = LC5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' " + Enter
		cSql += "WHERE 	C5.C5_FILIAL 	= '01'	AND 					" + Enter
		cSql += "		C5.C5_NUM 		IN (SELECT C6_NUM FROM SC6050 WITH (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = C5.C5_NUM AND (ROUND(C6_QTDVEN,2) - ROUND(C6_QTDENT,2)) > 0 AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '') AND
		cSql += "		C5.C5_EMISSAO	BETWEEN '"+cData_ini+"' AND '"+cData_fim+"' AND " + Enter
		cSql += "		C5.D_E_L_E_T_	= ''											" + Enter

		cSql += "UNION ALL	" + Enter

		//PEDIDOS MUNDI/MUNDIALLI
		cSql += "SELECT '13' AS 'EMPRESA', " + Enter
		cSql += "	C5.C5_FILIAL, C5.C5_YEMP,	C5.C5_NUM,	C5.C5_TIPO, C5.C5_YEMPPED, C5.C5_YLINHA,					" + Enter
		cSql += "	CLI_ORIG   = CASE WHEN C5.C5_YCLIORI <> '' THEN C5.C5_YCLIORI ELSE C5.C5_CLIENTE END,	" + Enter
		cSql += "	LOJ_ORIG   = CASE WHEN C5.C5_YLOJORI <> '' THEN C5.C5_YLOJORI ELSE C5.C5_LOJACLI END,	" + Enter
		cSql += "	C5_VEND    = CASE WHEN C5.C5_YCLIORI <> '' AND C5.C5_EMISSAO <= '20111231' THEN C5.C5_VEND1 WHEN C5.C5_YCLIORI <> '' AND C5.C5_EMISSAO >= '20120101' THEN LC5.C5_VEND1 ELSE C5.C5_VEND1 END, " + Enter
		cSql += "	C5_TRANSP1 = CASE WHEN C5.C5_YCLIORI <> '' THEN LC5.C5_TRANSP ELSE C5.C5_TRANSP	END," + Enter
		cSql += "	C5.C5_CLIENTE, C5.C5_LOJAENT,	C5.C5_LOJACLI,	C5.C5_YRECR,	C5.C5_YSUBTP,	C5.C5_TRANSP,		" + Enter
		cSql += "	C5.C5_TIPOCLI,	ISNULL(LC5.C5_CONDPAG, C5.C5_CONDPAG) AS C5_CONDPAG,	C5.C5_YFORMA,	C5.C5_YMAXCND,	C5.C5_YPERC,	C5.C5_YPRZINC,	C5.C5_YDTINC,	C5.C5_YPC,	C5.C5_VLRFRET,	C5.C5_YVLRREV,	C5.C5_YCLIDEL,	" + Enter
		cSql += "	C5.C5_YPERDEL,	C5.C5_YBAIDEL,	C5.C5_YNFDEL,	C5.C5_TABELA,	ISNULL(C5.C5_VEND1,'      ') AS C5_VEND1,	C5.C5_COMIS1,	C5.C5_VEND2,	C5.C5_COMIS2,	C5.C5_VEND3,	C5.C5_COMIS3,	C5.C5_VEND4,	C5.C5_COMIS4,	" + Enter
		cSql += "	C5.C5_VEND5,	C5.C5_COMIS5,	C5.C5_DESC1,	C5.C5_DESC2,	C5.C5_DESC3,	C5.C5_DESC4,	C5.C5_BANCO,	C5.C5_DESCFI,	C5.C5_EMISSAO,	C5.C5_COTACAO,	C5.C5_PARC1,	C5.C5_DATA1,	C5.C5_PARC2,	C5.C5_DATA2, " + Enter
		cSql += "	C5.C5_PARC3,	C5.C5_DATA3,	C5.C5_PARC4,	C5.C5_DATA4,	C5.C5_TPFRETE,	C5.C5_FRETE,	C5.C5_SEGURO,	C5.C5_DESPESA,	C5.C5_FRETAUT,	C5.C5_REAJUST,	C5.C5_MOEDA,	C5.C5_PESOL,	C5.C5_PBRUTO,	C5.C5_REIMP, " + Enter
		cSql += "	C5.C5_REDESP,	C5.C5_VOLUME1,	C5.C5_VOLUME2,	C5.C5_VOLUME3,	C5.C5_VOLUME4,	C5.C5_ESPECI1,	C5.C5_ESPECI2,	C5.C5_ESPECI3,	C5.C5_ESPECI4,	C5.C5_ACRSFIN,	C5.C5_MENNOTA,	C5.C5_MENPAD,	C5.C5_INCISS,	C5.C5_LIBEROK,	" + Enter
		cSql += "	C5.C5_OK,	C5.C5_NOTA,	C5.C5_SERIE,	C5.C5_VENDA,	C5.C5_KITREP,	C5.C5_TIPLIB,	C5.C5_OS,	C5.C5_YMARCA,	C5.C5_YNUMERO,	C5.C5_DESCONT,	C5.C5_PEDEXP,	C5.C5_TXMOEDA,	C5.C5_USERLGI,	C5.C5_USERLGA,	C5.C5_YAAPROV,	" + Enter
		cSql += "	ISNULL(LC5.C5_YAPROV, C5.C5_YAPROV) AS C5_YAPROV ,	C5.C5_YDIGP,	C5.C5_YALTP,	C5.C5_YOBS,	C5.C5_TPCARGA,	C5.C5_PREPEMB,	C5.C5_CLIENT,	C5.C5_PDESCAB,	C5.C5_YFLAG,	C5.C5_YEND,	C5.C5_YEST,	C5.C5_YMUN,	C5.C5_YBAIRRO,	" + Enter
		cSql += "	C5.C5_YCEP,	C5.C5_YTEL,	C5.C5_YFATOR,	C5.C5_YDESCLI,	C5.C5_RECISS,	C5.D_E_L_E_T_,	C5.R_E_C_N_O_,	C5.R_E_C_D_E_L_,	C5.C5_BLQ,	C5.C5_FORNISS,	C5.C5_CONTRA,	C5.C5_VLR_FRT,	C5.C5_YCC,	C5.C5_YVLTOTP,	C5.C5_YTPBLQ,	" + Enter
		cSql += "	C5.C5_YPEDPAI,	C5.C5_YMEDDES,	C5.C5_YMDESPD, C5.C5_YPEDORI, C5.C5_YITEMCT, C5.C5_YCLVL, C5.C5_YSI, C5.C5_YCLIORI, C5.C5_YLOJORI, C5.C5_YCODMUN, C5.C5_YTPTRAN, C5.C5_YTPCRED	" + Enter
		cSql += "FROM SC5130 C5	WITH (NOLOCK) " + Enter
		cSql += " LEFT  JOIN SC5070 LC5 WITH (NOLOCK) ON LC5.C5_FILIAL = '01' AND  C5.C5_NUM  = LC5.C5_YPEDORI AND C5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = C5.C5_YCLIORI AND C5.C5_YLOJORI = LC5.C5_LOJACLI AND C5.C5_YEMPPED = LC5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' " + Enter
		cSql += "WHERE 	C5.C5_FILIAL 	= '01'	AND 					" + Enter
		cSql += "		C5.C5_NUM 		IN (SELECT C6_NUM FROM SC6130 WITH (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = C5.C5_NUM AND (ROUND(C6_QTDVEN,2) - ROUND(C6_QTDENT,2)) > 0 AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '') AND
		cSql += "		C5.C5_EMISSAO	BETWEEN '"+cData_ini+"' AND '"+cData_fim+"' AND " + Enter
		cSql += "		C5.D_E_L_E_T_	= ''											" + Enter


	Else

		cSql := ""
		cSql += "SELECT * INTO "+nNomeSC5+" FROM (	" + Enter
		cSql += "SELECT '"+cEmpAnt+"' AS 'EMPRESA',	" + Enter
		cSql += "	C5.C5_FILIAL, C5.C5_YEMP, C5.C5_NUM,	C5.C5_TIPO, C5.C5_YEMPPED, C5.C5_YLINHA,					" + Enter
		cSql += "	CLI_ORIG   = CASE WHEN C5.C5_YCLIORI <> '' THEN C5.C5_YCLIORI ELSE C5.C5_CLIENTE END,	" + Enter
		cSql += "	LOJ_ORIG   = CASE WHEN C5.C5_YLOJORI <> '' THEN C5.C5_YLOJORI ELSE C5.C5_LOJACLI END,	" + Enter
		cSql += "	C5_VEND    = CASE WHEN C5.C5_YCLIORI <> '' AND C5.C5_EMISSAO <= '20111231' THEN C5.C5_VEND1 WHEN C5.C5_YCLIORI <> '' AND C5.C5_EMISSAO >= '20120101' THEN LC5.C5_VEND1 ELSE C5.C5_VEND1 END, " + Enter
		cSql += "	C5_TRANSP1 = CASE WHEN C5.C5_YCLIORI <> '' THEN LC5.C5_TRANSP ELSE C5.C5_TRANSP	END," + Enter
		cSql += "	C5.C5_CLIENTE, C5.C5_LOJAENT,	C5.C5_LOJACLI,	C5.C5_YRECR,	C5.C5_YSUBTP,	C5.C5_TRANSP,		" + Enter
		cSql += "	C5.C5_TIPOCLI,	ISNULL(LC5.C5_CONDPAG, C5.C5_CONDPAG) AS C5_CONDPAG,	C5.C5_YFORMA,	C5.C5_YMAXCND,	C5.C5_YPERC,	C5.C5_YPRZINC,	C5.C5_YDTINC,	C5.C5_YPC,	C5.C5_VLRFRET,	C5.C5_YVLRREV,	C5.C5_YCLIDEL,	" + Enter
		cSql += "	C5.C5_YPERDEL,	C5.C5_YBAIDEL,	C5.C5_YNFDEL,	C5.C5_TABELA,	ISNULL(C5.C5_VEND1,'      ') AS C5_VEND1,	C5.C5_COMIS1,	C5.C5_VEND2,	C5.C5_COMIS2,	C5.C5_VEND3,	C5.C5_COMIS3,	C5.C5_VEND4,	C5.C5_COMIS4,	" + Enter
		cSql += "	C5.C5_VEND5,	C5.C5_COMIS5,	C5.C5_DESC1,	C5.C5_DESC2,	C5.C5_DESC3,	C5.C5_DESC4,	C5.C5_BANCO,	C5.C5_DESCFI,	C5.C5_EMISSAO,	C5.C5_COTACAO,	C5.C5_PARC1,	C5.C5_DATA1,	C5.C5_PARC2,	C5.C5_DATA2, " + Enter
		cSql += "	C5.C5_PARC3,	C5.C5_DATA3,	C5.C5_PARC4,	C5.C5_DATA4,	C5.C5_TPFRETE,	C5.C5_FRETE,	C5.C5_SEGURO,	C5.C5_DESPESA,	C5.C5_FRETAUT,	C5.C5_REAJUST,	C5.C5_MOEDA,	C5.C5_PESOL,	C5.C5_PBRUTO,	C5.C5_REIMP, " + Enter
		cSql += "	C5.C5_REDESP,	C5.C5_VOLUME1,	C5.C5_VOLUME2,	C5.C5_VOLUME3,	C5.C5_VOLUME4,	C5.C5_ESPECI1,	C5.C5_ESPECI2,	C5.C5_ESPECI3,	C5.C5_ESPECI4,	C5.C5_ACRSFIN,	C5.C5_MENNOTA,	C5.C5_MENPAD,	C5.C5_INCISS,	C5.C5_LIBEROK,	" + Enter
		cSql += "	C5.C5_OK,	C5.C5_NOTA,	C5.C5_SERIE,	C5.C5_VENDA,	C5.C5_KITREP,	C5.C5_TIPLIB,	C5.C5_OS,	C5.C5_YMARCA,	C5.C5_YNUMERO,	C5.C5_DESCONT,	C5.C5_PEDEXP,	C5.C5_TXMOEDA,	C5.C5_USERLGI,	C5.C5_USERLGA,	C5.C5_YAAPROV,	" + Enter
		cSql += "	ISNULL(LC5.C5_YAPROV, C5.C5_YAPROV) AS C5_YAPROV ,	C5.C5_YDIGP,	C5.C5_YALTP,	C5.C5_YOBS,	C5.C5_TPCARGA,	C5.C5_PREPEMB,	C5.C5_CLIENT,	C5.C5_PDESCAB,	C5.C5_YFLAG,	C5.C5_YEND,	C5.C5_YEST,	C5.C5_YMUN,	C5.C5_YBAIRRO,	" + Enter
		cSql += "	C5.C5_YCEP,	C5.C5_YTEL,	C5.C5_YFATOR,	C5.C5_YDESCLI,	C5.C5_RECISS,	C5.D_E_L_E_T_,	C5.R_E_C_N_O_,	C5.R_E_C_D_E_L_,	C5.C5_BLQ,	C5.C5_FORNISS,	C5.C5_CONTRA,	C5.C5_VLR_FRT,	C5.C5_YCC,	C5.C5_YVLTOTP,	C5.C5_YTPBLQ,	" + Enter
		cSql += "	C5.C5_YPEDPAI,	C5.C5_YMEDDES,	C5.C5_YMDESPD, C5.C5_YPEDORI, C5.C5_YITEMCT, C5.C5_YCLVL, C5.C5_YSI, C5.C5_YCLIORI, C5.C5_YLOJORI, C5.C5_YCODMUN, C5.C5_YTPTRAN, C5.C5_YTPCRED	" + Enter
		cSql += "FROM "+RetSqlName("SC5")+ " C5 WITH (NOLOCK) " + Enter
		cSql += " LEFT  JOIN SC5070 LC5 WITH (NOLOCK) ON LC5.C5_FILIAL = '"+xFilial("SC5")+"' AND C5.C5_NUM  = LC5.C5_YPEDORI	AND C5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = C5.C5_YCLIORI AND C5.C5_YLOJORI = LC5.C5_LOJACLI AND C5.C5_YEMPPED = LC5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' " + Enter
		cSql += "WHERE 	C5.C5_FILIAL 	= '"+xFilial("SC5")+"'	AND 					" + Enter
		cSql += "		C5.C5_NUM 		IN (SELECT C6_NUM FROM "+RetSqlName("SC6")+" WITH (NOLOCK) WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = C5.C5_NUM AND (ROUND(C6_QTDVEN,2) - ROUND(C6_QTDENT,2)) > 0 AND C6_BLQ <> 'R' AND D_E_L_E_T_ = '') AND
		cSql += "		C5.C5_EMISSAO	BETWEEN '"+cData_ini+"' AND '"+cData_fim+"' AND " + Enter
		cSql += "		C5.D_E_L_E_T_	= ''											" + Enter

	EndIf

	cSql += " ) AS TMP " + Enter
	U_BIAMsgRun("Aguarde... Gerando Base... Cabeçalho do Pedido",,{|| TcSQLExec(cSql)})

	//__oSemaforo				:=	tBiaSemaforo():New()
	//__oSemaforo:cGrupo		:=	"FATURAMENTO"
	//__oSemaforo:lShowMsg	:= .F. //Nao Exibir mensagem de LOCK
	//If __oSemaforo:GeraSemaforo("FAT:Mapa de Pedido - Atualiza Status")

		//NOVA FUNÇÃO PARA CALCULAR O STATUS DO PEDIDO DE VENDA
		//U_BIAMsgRun("Aguarde... Atualizando status do Pedido...",,{|| U_fUpdSC62() })

		/*
		If Upper(AllTrim(getenvserver())) == "PRODUCAO"
			U_BIAMsgRun("Aguarde... Atualizando status do Pedido...",,{|| U_fUpdSC63() })
		Else
			U_BIAMsgRun("Aguarde... Atualizando status do Pedido...",,{|| U_fUpdSC62() })
		EndIf
		*/

	//	__oSemaforo:LiberaSemaforo()
	//EndIf

	If cEmpAnt $ "01_05_07_13"  .And. (cEmpAnt+cFilAnt != '0705')

		//AGRUPADOR
		cSql := ""
		cSql += "SELECT TMP.EMPRESA , TMP.C6_FILIAL,	TMP.C6_ITEM,	TMP.C6_PRODUTO,	TMP.C6_YEMPPED, TMP.C6_DESCRI,	TMP.C6_UM,	TMP.C6_QTDVEN,	TMP.C6_PRCVEN,	TMP.C6_VALOR,	TMP.C6_QTDLIB,	TMP.C6_TES,	TMP.C6_CF,	TMP.C6_SEGUM,	" + Enter
		cSql += "	TMP.C6_UNSVEN,	TMP.C6_LOCAL,	TMP.C6_QTDEMP,	TMP.C6_QTDENT,	TMP.C6_CLI,	TMP.C6_YPERC,	TMP.C6_YDESC,	TMP.C6_DESCONT,	TMP.C6_VALDESC, C6_ENTREG, C6_YDTNECE, C6_YDTNERE, TMP.C6_LA,	TMP.C6_LOJA,	TMP.C6_NOTA,	TMP.C6_SERIE,	" + Enter
		cSql += "	TMP.C6_DATFAT,	TMP.C6_NUM,	TMP.C6_COMIS1,	TMP.C6_COMIS2,	TMP.C6_COMIS3,	TMP.C6_COMIS4,	TMP.C6_COMIS5,	TMP.C6_YPALLET,	TMP.C6_PEDCLI,	TMP.C6_PRUNIT,	TMP.C6_BLOQUEI,	TMP.C6_GEROUPV,	TMP.C6_RESERVA,	TMP.C6_OP,	TMP.C6_OK,	" + Enter
		cSql += "	TMP.C6_NFORI,	TMP.C6_SERIORI,	TMP.C6_ITEMORI,	TMP.C6_IPIDEV,	TMP.C6_IDENTB6,	TMP.C6_BLQ,	TMP.C6_PICMRET,	TMP.C6_CODISS,	TMP.C6_GRADE,	TMP.C6_ITEMGRD,	TMP.C6_LOTECTL,	TMP.C6_NUMLOTE,	TMP.C6_DTVALID,	TMP.C6_NUMORC,	" + Enter
		cSql += "	TMP.C6_CHASSI,	TMP.C6_OPC,	TMP.C6_LOCALIZ,	TMP.C6_NUMSERI,	TMP.C6_NUMOP,	TMP.C6_ITEMOP,	TMP.C6_CLASFIS,	TMP.C6_YPESOL,	TMP.C6_QTDRESE,	TMP.C6_NUMOS,	TMP.C6_NUMOSFA,	TMP.C6_CODFAB,	TMP.C6_LOJAFA,	TMP.C6_TPOP,	" + Enter
		cSql += "	TMP.C6_REVISAO,	TMP.C6_YEMISSA,	TMP.C6_USERLGI,	TMP.C6_USERLGA,	TMP.C6_YIMPNF,	TMP.C6_QTDLIB2,	TMP.C6_QTDENT2,	TMP.C6_SERVIC,	TMP.C6_ENDPAD,	TMP.C6_CONTRT,	TMP.C6_TPCONTR,	TMP.C6_ITCONTR,	TMP.C6_PROJPMS,	TMP.C6_TASKPMS,	" + Enter
		cSql += "	TMP.C6_LICITA,	TMP.C6_QTDEMP2,	TMP.C6_CONTRAT,	TMP.C6_ITEMCON,	TMP.C6_TPESTR,	TMP.C6_EDTPMS,	TMP.C6_TRT,	TMP.C6_PROJET,	TMP.C6_ITPROJ,	TMP.C6_POTENCI,	TMP.C6_REGWMS,	TMP.C6_MOPC,	TMP.C6_NUMCP,	TMP.C6_NUMSC,	" + Enter
		cSql += "	TMP.C6_ITEMSC,	TMP.C6_SUGENTR,	TMP.C6_YPRCIMP,	TMP.C6_YCOD, TMP.C6_YQTDPC,	TMP.C6_YVLIMP, TMP.C6_YPRCTAB, TMP.C6_YDESCLI, TMP.C6_YREGRA, TMP.C6_ICMSRET, TMP.C6_YDTRESI, F4_DUPLIC, F4_ESTOQUE, TMP.C6_YSTAT AS OBS, " + Enter
		cSql += "	TMP.FORMATO, TMP.FORNO " + Enter

		cSql += " INTO "+nNomeSC6+"  FROM (" + Enter

		//ITENS DE PEDIDO BIANCOGRES
		cSql += " SELECT '01' AS EMP, '01'   AS EMPRESA, C6.C6_FILIAL, C5.C5_NUM, C5.C5_EMISSAO, ISNULL(LC5.C5_CLIENTE, C5.C5_CLIENTE) AS C5_CLIENTE,  C5.C5_VEND1, C6.C6_ITEM,	C6.C6_PRODUTO,	C6_YEMPPED=C5.C5_YEMPPED, " + Enter
		cSql += "		C6.C6_DESCRI,	C6.C6_UM,	C6.C6_QTDVEN,	ISNULL(LC6.C6_PRCVEN,C6.C6_PRCVEN) AS C6_PRCVEN,	C6.C6_VALOR,	C6.C6_QTDLIB,	C6.C6_TES,	C6.C6_CF,	C6.C6_SEGUM,	C6.C6_UNSVEN,	C6.C6_LOCAL,	C6.C6_QTDEMP,	" + Enter
		cSql += "		C6.C6_QTDENT,	C6.C6_CLI,	C6.C6_YPERC,	C6.C6_YDESC,	C6.C6_DESCONT,	C6.C6_VALDESC,	ISNULL(LC6.C6_ENTREG, C6.C6_ENTREG) AS C6_ENTREG, 
		cSql += "		C6.C6_YDTNECE AS C6_YDTNECE, C6.C6_YDTNERE, C6.C6_LA,	" + Enter
		cSql += "		C6.C6_LOJA,	C6.C6_NOTA,	C6.C6_SERIE,	C6.C6_DATFAT,	C6.C6_NUM,	C6.C6_COMIS1,	C6.C6_COMIS2,	C6.C6_COMIS3,	C6.C6_COMIS4,	C6.C6_COMIS5,	C6.C6_YPALLET,	C6.C6_PEDCLI,	ISNULL(LC6.C6_PRUNIT, C6.C6_PRUNIT) AS C6_PRUNIT, " + Enter
		cSql += "		C6.C6_BLOQUEI,	C6.C6_GEROUPV,	C6.C6_RESERVA,	C6.C6_OP,	C6.C6_OK,	C6.C6_NFORI,	C6.C6_SERIORI,	C6.C6_ITEMORI,	C6.C6_IPIDEV,	C6.C6_IDENTB6,	C6.C6_BLQ,	C6.C6_PICMRET,	C6.C6_CODISS,	C6.C6_GRADE,	C6.C6_ITEMGRD,	" + Enter
		cSql += "		C6.C6_LOTECTL,	C6.C6_NUMLOTE,	C6.C6_DTVALID,	C6.C6_NUMORC,	C6.C6_CHASSI,	C6.C6_OPC,	C6.C6_LOCALIZ,	C6.C6_NUMSERI,	C6.C6_NUMOP,	C6.C6_ITEMOP,	C6.C6_CLASFIS,	C6.C6_YPESOL,	C6.C6_QTDRESE,	C6.C6_NUMOS,	" + Enter
		cSql += "		C6.C6_NUMOSFA,	C6.C6_CODFAB,	C6.C6_LOJAFA,	C6.C6_TPOP,	C6.C6_REVISAO,	C6.C6_YEMISSA,	C6.C6_USERLGI,	C6.C6_USERLGA,	C6.C6_YIMPNF,	C6.C6_QTDLIB2,	C6.C6_QTDENT2,	C6.C6_SERVIC,	C6.C6_ENDPAD,	C6.C6_CONTRT,	" + Enter
		cSql += "		C6.C6_TPCONTR,	C6.C6_ITCONTR,	C6.C6_PROJPMS,	C6.C6_TASKPMS,	C6.C6_LICITA,	C6.C6_QTDEMP2,	C6.C6_CONTRAT,	C6.C6_ITEMCON,	C6.C6_TPESTR,	C6.C6_EDTPMS,	C6.C6_TRT,	C6.C6_PROJET,	C6.C6_ITPROJ,	C6.C6_POTENCI,	" + Enter
		cSql += "		C6.C6_REGWMS,	C6.C6_MOPC,	C6.C6_NUMCP,	C6.C6_NUMSC,	C6.C6_ITEMSC,	C6.C6_SUGENTR,	C6.C6_YPRCIMP,	C6.C6_YCOD,	C6.C6_YQTDPC,	C6.C6_YVLIMP,	C6.C6_YPRCTAB,	C6.C6_YDESCLI,	C6.C6_YREGRA,	C6.C6_ICMSRET, C6.C6_YDTRESI, " + Enter
		cSql += "		ISNULL(LF4.F4_DUPLIC, F4.F4_DUPLIC) AS F4_DUPLIC, ISNULL(F4.F4_ESTOQUE, LF4.F4_ESTOQUE) AS F4_ESTOQUE, C6.C6_YSTAT, " + Enter
		cSql += "		FORMATO=ZZ6_COD+' - '+ZZ6_DESC, FORNO=ZZ6_FORNOP   " + Enter


		cSql += " FROM SC5010 C5 WITH (NOLOCK) " + Enter
		cSql += " INNER JOIN SC6010 C6 WITH (NOLOCK) ON C5.C5_FILIAL  = C6.C6_FILIAL AND C5.C5_NUM = C6_NUM AND C6.C6_BLQ <> 'R' AND C6.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN SF4010 F4  WITH (NOLOCK) ON C6.C6_FILIAL = F4.F4_FILIAL AND C6.C6_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = '' " + Enter
		cSql += " INNER JOIN SB1010 B1  WITH (NOLOCK) ON C6.C6_PRODUTO = B1.B1_COD	AND B1.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN ZZ7010 Z7  WITH (NOLOCK) ON B1.B1_YLINHA = Z7.ZZ7_COD	AND B1.B1_YLINSEQ	= Z7.ZZ7_LINSEQ " + Enter

		cSql += " INNER JOIN ZZ6010 Z6  WITH (NOLOCK) ON B1.B1_YFORMAT = Z6.ZZ6_COD	AND Z6.D_E_L_E_T_   = '' " + Enter


		cSql += " AND Z7.D_E_L_E_T_   = '' " + Enter
		cSql += " LEFT  JOIN SC5070 LC5 WITH (NOLOCK) ON C5.C5_NUM  = LC5.C5_YPEDORI	AND C5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = C5.C5_YCLIORI AND LC5.C5_YEMPPED = C5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' " + Enter
		cSql += " LEFT  JOIN SC6070 LC6 WITH (NOLOCK) ON LC6.C6_FILIAL = LC5.C5_FILIAL AND LC6.C6_NUM = LC5.C5_NUM AND LC6.C6_ITEM 	= C6.C6_ITEM	AND LC6.C6_PRODUTO = C6.C6_PRODUTO AND LC6.D_E_L_E_T_ = ''" + Enter
		cSql += " LEFT  JOIN SF4070 LF4 WITH (NOLOCK) ON LC6.C6_FILIAL = LF4.F4_FILIAL AND LC6.C6_TES = LF4.F4_CODIGO AND LF4.D_E_L_E_T_   = '' " + Enter
		cSql += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + Enter
		
		If (cEmpAnt == '07')
			cSql += "	AND C5.C5_FILIAL IN ('01', '05') " + Enter
			cSql += "	AND C6.C6_FILIAL IN ('01', '05') " + Enter
		Else
			cSql += "	AND C5.C5_FILIAL = '01' " + Enter
			cSql += "	AND C6.C6_FILIAL = '01' " + Enter
		EndIf
		
		cSql += "	AND Z7.ZZ7_FILIAL = '"+xFilial("ZZ7")+"' " + Enter
		cSql += "	AND (ROUND(C6.C6_QTDVEN,2) - ROUND(C6.C6_QTDENT,2)) > 0 " + Enter
		cSql += "	AND (LC6.C6_BLQ <> 'R' OR LC6.C6_NUM IS NULL) " + Enter
		cSql += "	AND C6.C6_YEMISSA	>= '20120101' " + Enter
		cSql += "	AND B1.B1_YLINHA	<> '0000' " + Enter
		cSql += "	AND C5.D_E_L_E_T_ = '' " + Enter

		cSql += "UNION ALL	" + Enter

		//ITENS DE PEDIDO INCESA
		cSql += " SELECT '05' AS EMP, '05'   AS EMPRESA, C6.C6_FILIAL, C5.C5_NUM, C5.C5_EMISSAO, ISNULL(LC5.C5_CLIENTE, C5.C5_CLIENTE) AS C5_CLIENTE,  C5.C5_VEND1, C6.C6_ITEM,	C6.C6_PRODUTO,	C6_YEMPPED=C5.C5_YEMPPED, " + Enter
		cSql += "		C6.C6_DESCRI,	C6.C6_UM,	C6.C6_QTDVEN,	ISNULL(LC6.C6_PRCVEN,C6.C6_PRCVEN) AS C6_PRCVEN,	C6.C6_VALOR,	C6.C6_QTDLIB,	C6.C6_TES,	C6.C6_CF,	C6.C6_SEGUM,	C6.C6_UNSVEN,	C6.C6_LOCAL,	C6.C6_QTDEMP,	" + Enter
		cSql += "		C6.C6_QTDENT,	C6.C6_CLI,	C6.C6_YPERC,	C6.C6_YDESC,	C6.C6_DESCONT,	C6.C6_VALDESC,	ISNULL(LC6.C6_ENTREG, C6.C6_ENTREG) AS C6_ENTREG, 
		cSql += "		C6.C6_YDTNECE AS C6_YDTNECE, C6.C6_YDTNERE, C6.C6_LA,	" + Enter
		cSql += "		C6.C6_LOJA,	C6.C6_NOTA,	C6.C6_SERIE,	C6.C6_DATFAT,	C6.C6_NUM,	C6.C6_COMIS1,	C6.C6_COMIS2,	C6.C6_COMIS3,	C6.C6_COMIS4,	C6.C6_COMIS5,	C6.C6_YPALLET,	C6.C6_PEDCLI,	ISNULL(LC6.C6_PRUNIT, C6.C6_PRUNIT) AS C6_PRUNIT, " + Enter
		cSql += "		C6.C6_BLOQUEI,	C6.C6_GEROUPV,	C6.C6_RESERVA,	C6.C6_OP,	C6.C6_OK,	C6.C6_NFORI,	C6.C6_SERIORI,	C6.C6_ITEMORI,	C6.C6_IPIDEV,	C6.C6_IDENTB6,	C6.C6_BLQ,	C6.C6_PICMRET,	C6.C6_CODISS,	C6.C6_GRADE,	C6.C6_ITEMGRD,	" + Enter
		cSql += "		C6.C6_LOTECTL,	C6.C6_NUMLOTE,	C6.C6_DTVALID,	C6.C6_NUMORC,	C6.C6_CHASSI,	C6.C6_OPC,	C6.C6_LOCALIZ,	C6.C6_NUMSERI,	C6.C6_NUMOP,	C6.C6_ITEMOP,	C6.C6_CLASFIS,	C6.C6_YPESOL,	C6.C6_QTDRESE,	C6.C6_NUMOS,	" + Enter
		cSql += "		C6.C6_NUMOSFA,	C6.C6_CODFAB,	C6.C6_LOJAFA,	C6.C6_TPOP,	C6.C6_REVISAO,	C6.C6_YEMISSA,	C6.C6_USERLGI,	C6.C6_USERLGA,	C6.C6_YIMPNF,	C6.C6_QTDLIB2,	C6.C6_QTDENT2,	C6.C6_SERVIC,	C6.C6_ENDPAD,	C6.C6_CONTRT,	" + Enter
		cSql += "		C6.C6_TPCONTR,	C6.C6_ITCONTR,	C6.C6_PROJPMS,	C6.C6_TASKPMS,	C6.C6_LICITA,	C6.C6_QTDEMP2,	C6.C6_CONTRAT,	C6.C6_ITEMCON,	C6.C6_TPESTR,	C6.C6_EDTPMS,	C6.C6_TRT,	C6.C6_PROJET,	C6.C6_ITPROJ,	C6.C6_POTENCI,	" + Enter
		cSql += "		C6.C6_REGWMS,	C6.C6_MOPC,	C6.C6_NUMCP,	C6.C6_NUMSC,	C6.C6_ITEMSC,	C6.C6_SUGENTR,	C6.C6_YPRCIMP,	C6.C6_YCOD,	C6.C6_YQTDPC,	C6.C6_YVLIMP,	C6.C6_YPRCTAB,	C6.C6_YDESCLI,	C6.C6_YREGRA,	C6.C6_ICMSRET, C6.C6_YDTRESI, " + Enter
		cSql += "		ISNULL(LF4.F4_DUPLIC, F4.F4_DUPLIC) AS F4_DUPLIC, ISNULL(F4.F4_ESTOQUE, LF4.F4_ESTOQUE) AS F4_ESTOQUE, C6.C6_YSTAT, " + Enter
		cSql += "		FORMATO=ZZ6_COD+' - '+ZZ6_DESC, FORNO=ZZ6_FORNOP   " + Enter


		cSql += " FROM SC5050 C5 WITH (NOLOCK) " + Enter
		cSql += " INNER JOIN SC6050 C6 WITH (NOLOCK) ON C5.C5_FILIAL  = C6.C6_FILIAL AND C5.C5_NUM = C6_NUM AND C6.C6_BLQ <> 'R' AND C6.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN SF4050 F4  WITH (NOLOCK) ON C6.C6_FILIAL = F4.F4_FILIAL AND C6.C6_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = '' " + Enter
		cSql += " LEFT  JOIN SC5070 LC5 WITH (NOLOCK) ON C5.C5_NUM = LC5.C5_YPEDORI	AND C5.C5_CLIENTE = '010064' AND LC5.C5_CLIENTE = C5.C5_YCLIORI AND LC5.C5_YEMPPED = C5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' " + Enter
		cSql += " LEFT  JOIN SC6070 LC6 WITH (NOLOCK) ON LC6.C6_FILIAL = LC5.C5_FILIAL AND LC6.C6_NUM = LC5.C5_NUM AND LC6.C6_ITEM 	= C6.C6_ITEM	AND LC6.C6_PRODUTO = C6.C6_PRODUTO AND LC6.D_E_L_E_T_ = ''" + Enter
		cSql += " LEFT  JOIN SF4070 LF4 WITH (NOLOCK) ON LC6.C6_FILIAL = LF4.F4_FILIAL AND LC6.C6_TES = LF4.F4_CODIGO AND LF4.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN SB1010 B1  WITH (NOLOCK) ON C6.C6_PRODUTO = B1.B1_COD	AND B1.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN ZZ7010 Z7  WITH (NOLOCK) ON B1.B1_YLINHA = Z7.ZZ7_COD	AND B1.B1_YLINSEQ	= Z7.ZZ7_LINSEQ AND Z7.D_E_L_E_T_   = '' " + Enter

		cSql += " INNER JOIN ZZ6010 Z6  WITH (NOLOCK) ON B1.B1_YFORMAT = Z6.ZZ6_COD	AND Z6.D_E_L_E_T_   = '' " + Enter


		cSql += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + Enter
		cSql += "	AND C5.C5_FILIAL = '01' " + Enter
		cSql += "	AND C6.C6_FILIAL = '01' " + Enter
		cSql += "	AND Z7.ZZ7_FILIAL = '"+xFilial("ZZ7")+"' " + Enter
		cSql += "	AND (ROUND(C6.C6_QTDVEN,2) - ROUND(C6.C6_QTDENT,2)) > 0 " + Enter
		cSql += "	AND (LC6.C6_BLQ <> 'R' OR LC6.C6_NUM IS NULL) " + Enter
		cSql += "	AND C6.C6_YEMISSA >= '20120101' " + Enter
		cSql += "	AND B1.B1_YLINHA <> '0000' " + Enter
		cSql += "	AND C5.D_E_L_E_T_ = '' " + Enter

		cSql += "UNION ALL	" + Enter

		//ITENS DE PEDIDO MUNDI/MUNDIALLI
		cSql += " SELECT '13' AS EMP, '13'   AS EMPRESA, C6.C6_FILIAL, C5.C5_NUM, C5.C5_EMISSAO, ISNULL(LC5.C5_CLIENTE, C5.C5_CLIENTE) AS C5_CLIENTE,  C5.C5_VEND1, C6.C6_ITEM,	C6.C6_PRODUTO,	C6_YEMPPED=C5.C5_YEMPPED, " + Enter
		cSql += "		C6.C6_DESCRI,	C6.C6_UM,	C6.C6_QTDVEN,	ISNULL(LC6.C6_PRCVEN,C6.C6_PRCVEN) AS C6_PRCVEN,	C6.C6_VALOR,	C6.C6_QTDLIB,	C6.C6_TES,	C6.C6_CF,	C6.C6_SEGUM,	C6.C6_UNSVEN,	C6.C6_LOCAL,	C6.C6_QTDEMP,	" + Enter
		cSql += "		C6.C6_QTDENT,	C6.C6_CLI,	C6.C6_YPERC,	C6.C6_YDESC,	C6.C6_DESCONT,	C6.C6_VALDESC,	ISNULL(LC6.C6_ENTREG, C6.C6_ENTREG) AS C6_ENTREG, 
		cSql += "		C6.C6_YDTNECE AS C6_YDTNECE, C6.C6_YDTNERE, C6.C6_LA,	" + Enter
		cSql += "		C6.C6_LOJA,	C6.C6_NOTA,	C6.C6_SERIE,	C6.C6_DATFAT,	C6.C6_NUM,	C6.C6_COMIS1,	C6.C6_COMIS2,	C6.C6_COMIS3,	C6.C6_COMIS4,	C6.C6_COMIS5,	C6.C6_YPALLET,	C6.C6_PEDCLI,	ISNULL(LC6.C6_PRUNIT, C6.C6_PRUNIT) AS C6_PRUNIT, " + Enter
		cSql += "		C6.C6_BLOQUEI,	C6.C6_GEROUPV,	C6.C6_RESERVA,	C6.C6_OP,	C6.C6_OK,	C6.C6_NFORI,	C6.C6_SERIORI,	C6.C6_ITEMORI,	C6.C6_IPIDEV,	C6.C6_IDENTB6,	C6.C6_BLQ,	C6.C6_PICMRET,	C6.C6_CODISS,	C6.C6_GRADE,	C6.C6_ITEMGRD,	" + Enter
		cSql += "		C6.C6_LOTECTL,	C6.C6_NUMLOTE,	C6.C6_DTVALID,	C6.C6_NUMORC,	C6.C6_CHASSI,	C6.C6_OPC,	C6.C6_LOCALIZ,	C6.C6_NUMSERI,	C6.C6_NUMOP,	C6.C6_ITEMOP,	C6.C6_CLASFIS,	C6.C6_YPESOL,	C6.C6_QTDRESE,	C6.C6_NUMOS,	" + Enter
		cSql += "		C6.C6_NUMOSFA,	C6.C6_CODFAB,	C6.C6_LOJAFA,	C6.C6_TPOP,	C6.C6_REVISAO,	C6.C6_YEMISSA,	C6.C6_USERLGI,	C6.C6_USERLGA,	C6.C6_YIMPNF,	C6.C6_QTDLIB2,	C6.C6_QTDENT2,	C6.C6_SERVIC,	C6.C6_ENDPAD,	C6.C6_CONTRT,	" + Enter
		cSql += "		C6.C6_TPCONTR,	C6.C6_ITCONTR,	C6.C6_PROJPMS,	C6.C6_TASKPMS,	C6.C6_LICITA,	C6.C6_QTDEMP2,	C6.C6_CONTRAT,	C6.C6_ITEMCON,	C6.C6_TPESTR,	C6.C6_EDTPMS,	C6.C6_TRT,	C6.C6_PROJET,	C6.C6_ITPROJ,	C6.C6_POTENCI,	" + Enter
		cSql += "		C6.C6_REGWMS,	C6.C6_MOPC,	C6.C6_NUMCP,	C6.C6_NUMSC,	C6.C6_ITEMSC,	C6.C6_SUGENTR,	C6.C6_YPRCIMP,	C6.C6_YCOD,	C6.C6_YQTDPC,	C6.C6_YVLIMP,	C6.C6_YPRCTAB,	C6.C6_YDESCLI,	C6.C6_YREGRA,	C6.C6_ICMSRET, C6.C6_YDTRESI, " + Enter
		cSql += "		ISNULL(LF4.F4_DUPLIC, F4.F4_DUPLIC) AS F4_DUPLIC, ISNULL(F4.F4_ESTOQUE, LF4.F4_ESTOQUE) AS F4_ESTOQUE, C6.C6_YSTAT, " + Enter
		cSql += "		FORMATO=ZZ6_COD+' - '+ZZ6_DESC, FORNO=ZZ6_FORNOP  " + Enter


		cSql += " FROM SC5130 C5 WITH (NOLOCK) " + Enter
		cSql += " INNER JOIN SC6130 C6 WITH (NOLOCK) ON C5.C5_FILIAL  = C6.C6_FILIAL AND C5.C5_NUM = C6_NUM AND C6.C6_BLQ <> 'R' AND C6.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN SF4130 F4  WITH (NOLOCK) ON C6.C6_FILIAL = F4.F4_FILIAL AND C6.C6_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = '' " + Enter
		cSql += " LEFT  JOIN SC5070 LC5 WITH (NOLOCK) ON C5.C5_NUM = LC5.C5_YPEDORI	AND C5.C5_CLIENTE = '010064' AND LC5.C5_CLIENTE = C5.C5_YCLIORI AND LC5.C5_YEMPPED = C5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' " + Enter
		cSql += " LEFT  JOIN SC6070 LC6 WITH (NOLOCK) ON LC6.C6_FILIAL = LC5.C5_FILIAL AND LC6.C6_NUM = LC5.C5_NUM AND LC6.C6_ITEM 	= C6.C6_ITEM	AND LC6.C6_PRODUTO = C6.C6_PRODUTO AND LC6.D_E_L_E_T_ = ''" + Enter
		cSql += " LEFT  JOIN SF4070 LF4 WITH (NOLOCK) ON LC6.C6_FILIAL = LF4.F4_FILIAL AND LC6.C6_TES = LF4.F4_CODIGO AND LF4.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN SB1010 B1  WITH (NOLOCK) ON C6.C6_PRODUTO = B1.B1_COD	AND B1.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN ZZ7010 Z7  WITH (NOLOCK) ON B1.B1_YLINHA = Z7.ZZ7_COD	AND B1.B1_YLINSEQ	= Z7.ZZ7_LINSEQ AND Z7.D_E_L_E_T_   = '' " + Enter

		cSql += " INNER JOIN ZZ6010 Z6  WITH (NOLOCK) ON B1.B1_YFORMAT = Z6.ZZ6_COD	AND Z6.D_E_L_E_T_   = '' " + Enter


		cSql += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + Enter
		cSql += "	AND C5.C5_FILIAL = '01' " + Enter
		cSql += "	AND C6.C6_FILIAL = '01' " + Enter
		cSql += "	AND Z7.ZZ7_FILIAL = '"+xFilial("ZZ7")+"' " + Enter
		cSql += "	AND (ROUND(C6.C6_QTDVEN,2) - ROUND(C6.C6_QTDENT,2)) > 0 " + Enter
		cSql += "	AND (LC6.C6_BLQ <> 'R' OR LC6.C6_NUM IS NULL) " + Enter
		cSql += "	AND C6.C6_YEMISSA >= '20120101' " + Enter
		cSql += "	AND B1.B1_YLINHA <> '0000' " + Enter
		cSql += "	AND C5.D_E_L_E_T_ = '' " + Enter
        
	Else

		cSql := ""
		cSql += "SELECT TMP.EMPRESA , TMP.C6_FILIAL,	TMP.C6_ITEM,	TMP.C6_PRODUTO,	TMP.C6_YEMPPED, TMP.C6_DESCRI,	TMP.C6_UM,	TMP.C6_QTDVEN,	TMP.C6_PRCVEN,	TMP.C6_VALOR,	TMP.C6_QTDLIB,	TMP.C6_TES,	TMP.C6_CF,	TMP.C6_SEGUM,	" + Enter
		cSql += "	TMP.C6_UNSVEN,	TMP.C6_LOCAL,	TMP.C6_QTDEMP,	TMP.C6_QTDENT,	TMP.C6_CLI,	TMP.C6_YPERC,	TMP.C6_YDESC,	TMP.C6_DESCONT,	TMP.C6_VALDESC, C6_ENTREG, C6_YDTNECE, C6_YDTNERE, TMP.C6_LA,	TMP.C6_LOJA,	TMP.C6_NOTA,	TMP.C6_SERIE,	" + Enter
		cSql += "	TMP.C6_DATFAT,	TMP.C6_NUM,	TMP.C6_COMIS1,	TMP.C6_COMIS2,	TMP.C6_COMIS3,	TMP.C6_COMIS4,	TMP.C6_COMIS5,	TMP.C6_YPALLET,	TMP.C6_PEDCLI,	TMP.C6_PRUNIT,	TMP.C6_BLOQUEI,	TMP.C6_GEROUPV,	TMP.C6_RESERVA,	TMP.C6_OP,	TMP.C6_OK,	" + Enter
		cSql += "	TMP.C6_NFORI,	TMP.C6_SERIORI,	TMP.C6_ITEMORI,	TMP.C6_IPIDEV,	TMP.C6_IDENTB6,	TMP.C6_BLQ,	TMP.C6_PICMRET,	TMP.C6_CODISS,	TMP.C6_GRADE,	TMP.C6_ITEMGRD,	TMP.C6_LOTECTL,	TMP.C6_NUMLOTE,	TMP.C6_DTVALID,	TMP.C6_NUMORC,	" + Enter
		cSql += "	TMP.C6_CHASSI,	TMP.C6_OPC,	TMP.C6_LOCALIZ,	TMP.C6_NUMSERI,	TMP.C6_NUMOP,	TMP.C6_ITEMOP,	TMP.C6_CLASFIS,	TMP.C6_YPESOL,	TMP.C6_QTDRESE,	TMP.C6_NUMOS,	TMP.C6_NUMOSFA,	TMP.C6_CODFAB,	TMP.C6_LOJAFA,	TMP.C6_TPOP,	" + Enter
		cSql += "	TMP.C6_REVISAO,	TMP.C6_YEMISSA,	TMP.C6_USERLGI,	TMP.C6_USERLGA,	TMP.C6_YIMPNF,	TMP.C6_QTDLIB2,	TMP.C6_QTDENT2,	TMP.C6_SERVIC,	TMP.C6_ENDPAD,	TMP.C6_CONTRT,	TMP.C6_TPCONTR,	TMP.C6_ITCONTR,	TMP.C6_PROJPMS,	TMP.C6_TASKPMS,	" + Enter
		cSql += "	TMP.C6_LICITA,	TMP.C6_QTDEMP2,	TMP.C6_CONTRAT,	TMP.C6_ITEMCON,	TMP.C6_TPESTR,	TMP.C6_EDTPMS,	TMP.C6_TRT,	TMP.C6_PROJET,	TMP.C6_ITPROJ,	TMP.C6_POTENCI,	TMP.C6_REGWMS,	TMP.C6_MOPC,	TMP.C6_NUMCP,	TMP.C6_NUMSC,	" + Enter
		cSql += "	TMP.C6_ITEMSC,	TMP.C6_SUGENTR,	TMP.C6_YPRCIMP,	TMP.C6_YCOD, TMP.C6_YQTDPC,	TMP.C6_YVLIMP, TMP.C6_YPRCTAB, TMP.C6_YDESCLI, TMP.C6_YREGRA, TMP.C6_ICMSRET, TMP.C6_YDTRESI, F4_DUPLIC, F4_ESTOQUE, TMP.C6_YSTAT AS OBS, " + Enter
		cSql += "	TMP.FORMATO,	TMP.FORNO " + Enter

		cSql += " INTO "+nNomeSC6+"  FROM (" + Enter

		cSql += " SELECT '"+cEmpAnt+"' AS EMP, '"+cEmpAnt+"'   AS EMPRESA, C6.C6_FILIAL, C5.C5_NUM, C5.C5_EMISSAO, ISNULL(LC5.C5_CLIENTE, C5.C5_CLIENTE) AS C5_CLIENTE,  C5.C5_VEND1, C6.C6_ITEM,	C6.C6_PRODUTO,	C6_YEMPPED=C5.C5_YEMPPED, " + Enter
		cSql += "		C6.C6_DESCRI,	C6.C6_UM,	C6.C6_QTDVEN,	ISNULL(LC6.C6_PRCVEN,C6.C6_PRCVEN) AS C6_PRCVEN,	C6.C6_VALOR,	C6.C6_QTDLIB,	C6.C6_TES,	C6.C6_CF,	C6.C6_SEGUM,	C6.C6_UNSVEN,	C6.C6_LOCAL,	C6.C6_QTDEMP,	" + Enter
		cSql += "		C6.C6_QTDENT,	C6.C6_CLI,	C6.C6_YPERC,	C6.C6_YDESC,	C6.C6_DESCONT,	C6.C6_VALDESC,	ISNULL(LC6.C6_ENTREG, C6.C6_ENTREG) AS C6_ENTREG, 
		cSql += "		C6.C6_YDTNECE AS C6_YDTNECE, C6.C6_YDTNERE, C6.C6_LA,	" + Enter
		cSql += "		C6.C6_LOJA,	C6.C6_NOTA,	C6.C6_SERIE,	C6.C6_DATFAT,	C6.C6_NUM,	C6.C6_COMIS1,	C6.C6_COMIS2,	C6.C6_COMIS3,	C6.C6_COMIS4,	C6.C6_COMIS5,	C6.C6_YPALLET,	C6.C6_PEDCLI,	ISNULL(LC6.C6_PRUNIT, C6.C6_PRUNIT) AS C6_PRUNIT, " + Enter
		cSql += "		C6.C6_BLOQUEI,	C6.C6_GEROUPV,	C6.C6_RESERVA,	C6.C6_OP,	C6.C6_OK,	C6.C6_NFORI,	C6.C6_SERIORI,	C6.C6_ITEMORI,	C6.C6_IPIDEV,	C6.C6_IDENTB6,	C6.C6_BLQ,	C6.C6_PICMRET,	C6.C6_CODISS,	C6.C6_GRADE,	C6.C6_ITEMGRD,	" + Enter
		cSql += "		C6.C6_LOTECTL,	C6.C6_NUMLOTE,	C6.C6_DTVALID,	C6.C6_NUMORC,	C6.C6_CHASSI,	C6.C6_OPC,	C6.C6_LOCALIZ,	C6.C6_NUMSERI,	C6.C6_NUMOP,	C6.C6_ITEMOP,	C6.C6_CLASFIS,	C6.C6_YPESOL,	C6.C6_QTDRESE,	C6.C6_NUMOS,	" + Enter
		cSql += "		C6.C6_NUMOSFA,	C6.C6_CODFAB,	C6.C6_LOJAFA,	C6.C6_TPOP,	C6.C6_REVISAO,	C6.C6_YEMISSA,	C6.C6_USERLGI,	C6.C6_USERLGA,	C6.C6_YIMPNF,	C6.C6_QTDLIB2,	C6.C6_QTDENT2,	C6.C6_SERVIC,	C6.C6_ENDPAD,	C6.C6_CONTRT,	" + Enter
		cSql += "		C6.C6_TPCONTR,	C6.C6_ITCONTR,	C6.C6_PROJPMS,	C6.C6_TASKPMS,	C6.C6_LICITA,	C6.C6_QTDEMP2,	C6.C6_CONTRAT,	C6.C6_ITEMCON,	C6.C6_TPESTR,	C6.C6_EDTPMS,	C6.C6_TRT,	C6.C6_PROJET,	C6.C6_ITPROJ,	C6.C6_POTENCI,	" + Enter
		cSql += "		C6.C6_REGWMS,	C6.C6_MOPC,	C6.C6_NUMCP,	C6.C6_NUMSC,	C6.C6_ITEMSC,	C6.C6_SUGENTR,	C6.C6_YPRCIMP,	C6.C6_YCOD,	C6.C6_YQTDPC,	C6.C6_YVLIMP,	C6.C6_YPRCTAB,	C6.C6_YDESCLI,	C6.C6_YREGRA,	C6.C6_ICMSRET, C6.C6_YDTRESI, " + Enter
		cSql += "		ISNULL(LF4.F4_DUPLIC, F4.F4_DUPLIC) AS F4_DUPLIC, ISNULL(F4.F4_ESTOQUE, LF4.F4_ESTOQUE) AS F4_ESTOQUE, C6.C6_YSTAT, " + Enter
		cSql += "		FORMATO=ZZ6_COD+' - '+ZZ6_DESC, FORNO=ZZ6_FORNOP   " + Enter


		cSql += " FROM " + RetSqlName("SC5")+ " C5 WITH (NOLOCK) " + Enter
		cSql += " INNER JOIN "+RetSqlName("SC6")+" C6 WITH (NOLOCK) ON C5.C5_FILIAL  = C6.C6_FILIAL AND C5.C5_NUM = C6_NUM AND C6.C6_BLQ <> 'R' AND C6.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN "+RetSqlName("SF4")+" F4 WITH (NOLOCK) ON C6.C6_FILIAL = F4.F4_FILIAL AND C6.C6_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = '' " + Enter
		cSql += " INNER JOIN SB1010 B1  WITH (NOLOCK) ON C6.C6_PRODUTO = B1.B1_COD	AND B1.D_E_L_E_T_   = '' " + Enter
		cSql += " INNER JOIN ZZ7010 Z7  WITH (NOLOCK) ON B1.B1_YLINHA = Z7.ZZ7_COD	AND B1.B1_YLINSEQ	= Z7.ZZ7_LINSEQ " + Enter

		cSql += " INNER JOIN ZZ6010 Z6  WITH (NOLOCK) ON B1.B1_YFORMAT = Z6.ZZ6_COD	AND Z6.D_E_L_E_T_   = '' " + Enter


		cSql += " AND Z7.D_E_L_E_T_   = '' " + Enter
		cSql += " LEFT  JOIN SC5070 LC5 WITH (NOLOCK) ON C5.C5_NUM  = LC5.C5_YPEDORI	AND C5.C5_CLIENTE	= '010064' AND LC5.C5_CLIENTE = C5.C5_YCLIORI AND LC5.C5_YEMPPED = C5.C5_YEMPPED AND LC5.D_E_L_E_T_ = '' " + Enter
		cSql += " LEFT  JOIN SC6070 LC6 WITH (NOLOCK) ON LC6.C6_FILIAL = LC5.C5_FILIAL AND LC6.C6_NUM = LC5.C5_NUM AND LC6.C6_ITEM 	= C6.C6_ITEM	AND LC6.C6_PRODUTO = C6.C6_PRODUTO AND LC6.D_E_L_E_T_ = ''" + Enter
		cSql += " LEFT  JOIN SF4070 LF4 WITH (NOLOCK) ON LC6.C6_FILIAL = LF4.F4_FILIAL AND LC6.C6_TES = LF4.F4_CODIGO AND LF4.D_E_L_E_T_   = '' " + Enter
		cSql += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' " + Enter
		cSql += "	AND C5.C5_FILIAL = '"+xFilial("SC5")+"' " + Enter
		cSql += "	AND C6.C6_FILIAL = '"+xFilial("SC6")+"' " + Enter
		cSql += "	AND Z7.ZZ7_FILIAL = '"+xFilial("ZZ7")+"' " + Enter
		cSql += "	AND (ROUND(C6.C6_QTDVEN,2) - ROUND(C6.C6_QTDENT,2)) > 0 " + Enter
		cSql += "	AND (LC6.C6_BLQ <> 'R' OR LC6.C6_NUM IS NULL) " + Enter
		cSql += "	AND C6.C6_YEMISSA	>= '20120101' " + Enter
		cSql += "	AND B1.B1_YLINHA	<> '0000' " + Enter
		cSql += "	AND C5.D_E_L_E_T_ = '' " + Enter
        
	EndIf

	cSql += " ) TMP  "+ Enter
	cSql += " option (maxdop 1) "+ Enter //OPÇÃO UTILIZADA PROVISÓRIAMENTE PARA MELHORIA A QUESTÃO DA PERFORMANCE - RECOMENDAÇÃO DE MUDAR ESTRUTURA DO RELATORIO.

	U_BIAMsgRun("Aguarde... Gerando Base... Item do Pedido",,{|| TcSQLExec(cSql)})

	//BASE DE LIBERACOES DE PEDIDOS
	If cEmpAnt $ "01_05_07_13"  .And. (cEmpAnt+cFilAnt != '0705')

		cSql := ""
		cSql += "SELECT * INTO "+nNomeSC9+" FROM (" + Enter

		//BIANCOGRES
		cSql += "SELECT '01' AS 'EMPRESA', C9_FILIAL,C9_PEDIDO,C9_AGREG,C9_PRODUTO,C9_LOTECTL,C9_CLIENTE,C9_LOJA,C9_ITEM,C9_NFISCAL,C9_BLEST,C9_BLCRED,C9_GRUPO,C9_LOCAL,C9_DATALIB,C9_QTDLIB,C9_QTDLIB2, C9_YRASTAT, C9_YDTBLCT, C9_YTPBLCT, C9_YDTLICT " + Enter
		cSql += "FROM SC9010 SC9 WITH (NOLOCK) 		" + Enter
		cSql += "	INNER JOIN "+nNomeSC5+" ON		" + Enter
		cSql += "		C9_CLIENTE = C5_CLIENTE	AND " + Enter
		cSql += "		C9_LOJA    = C5_LOJACLI AND " + Enter
		cSql += "		C9_PEDIDO  = C5_NUM		AND " + Enter
		cSql += "		EMPRESA	   = '01'			" + Enter
		cSql += "WHERE C9_FILIAL = '01' AND SC9.D_E_L_E_T_ = '' " + Enter

		cSql += "UNION ALL " + Enter

		//INCESA
		cSql += "SELECT '05' AS 'EMPRESA', C9_FILIAL,C9_PEDIDO,C9_AGREG,C9_PRODUTO,C9_LOTECTL,C9_CLIENTE,C9_LOJA,C9_ITEM,C9_NFISCAL,C9_BLEST,C9_BLCRED,C9_GRUPO,C9_LOCAL,C9_DATALIB,C9_QTDLIB,C9_QTDLIB2, C9_YRASTAT, C9_YDTBLCT, C9_YTPBLCT, C9_YDTLICT " + Enter
		cSql += "FROM SC9050 SC9 WITH (NOLOCK)			" + Enter
		cSql += "	INNER JOIN "+nNomeSC5+" ON			" + Enter
		cSql += "		C9_CLIENTE	= C5_CLIENTE	AND " + Enter
		cSql += "		C9_LOJA		= C5_LOJACLI	AND	" + Enter
		cSql += "		C9_PEDIDO	= C5_NUM		AND " + Enter
		cSql += "		EMPRESA		= '05'    			" + Enter
		cSql += "WHERE C9_FILIAL = '01' AND SC9.D_E_L_E_T_ = '' " + Enter

		cSql += "UNION ALL " + Enter

		//MUNDI
		cSql += "SELECT '13' AS 'EMPRESA', C9_FILIAL,C9_PEDIDO,C9_AGREG,C9_PRODUTO,C9_LOTECTL,C9_CLIENTE,C9_LOJA,C9_ITEM,C9_NFISCAL,C9_BLEST,C9_BLCRED,C9_GRUPO,C9_LOCAL,C9_DATALIB,C9_QTDLIB,C9_QTDLIB2, C9_YRASTAT , C9_YDTBLCT, C9_YTPBLCT, C9_YDTLICT " + Enter
		cSql += "FROM SC9130 SC9 WITH (NOLOCK)		" + Enter
		cSql += "	INNER JOIN "+nNomeSC5+" ON		" + Enter
		cSql += "		C9_CLIENTE = C5_CLIENTE AND " + Enter
		cSql += "		C9_LOJA    = C5_LOJACLI AND " + Enter
		cSql += "		C9_PEDIDO  = C5_NUM		AND " + Enter
		cSql += "		EMPRESA	   = '13'			" + Enter
		cSql += "WHERE C9_FILIAL = '01' AND SC9.D_E_L_E_T_ = '' " + Enter

	Else

		cSql := ""
		cSql += "SELECT * INTO "+nNomeSC9+" FROM (" + Enter

		cSql += "SELECT '"+cEmpAnt+"' AS 'EMPRESA', C9_FILIAL,C9_PEDIDO,C9_AGREG,C9_PRODUTO,C9_LOTECTL,C9_CLIENTE,C9_LOJA,C9_ITEM,C9_NFISCAL,C9_BLEST,C9_BLCRED,C9_GRUPO,C9_LOCAL,C9_DATALIB,C9_QTDLIB,C9_QTDLIB2, C9_YRASTAT, C9_YDTBLCT, C9_YTPBLCT, C9_YDTLICT " + Enter
		cSql += "FROM "+RetSqlName("SC9")+" SC9 WITH (NOLOCK)	" + Enter
		cSql += "	INNER JOIN "+nNomeSC5+" ON					" + Enter
		cSql += "		C9_CLIENTE = C5_CLIENTE AND				" + Enter
		cSql += "		C9_LOJA    = C5_LOJACLI AND				" + Enter
		cSql += "		C9_PEDIDO  = C5_NUM		AND				" + Enter
		cSql += "		EMPRESA	   = '"+cEmpAnt+"'    			" + Enter
		cSql += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' AND SC9.D_E_L_E_T_ = '' " + Enter

	EndIf


	cSql += " ) AS TMP " + Enter

	U_BIAMsgRun("Aguarde... Gerando Base... Pedido Liberado",,{|| TcSQLExec(cSql)})

	//Fernando em 19/12/13
	//Adicionado os campo C5.C5_CLIENTE, C5.C5_LOJACLI, C6.F4_DUPLIC para uso na versao Excel

	IF MV_PAR23 == 1
		//Utiliza Roteirização
		cQuery := ""
		cQuery := "SELECT	C5.EMPRESA, E4.E4_YMEDIA, C5.C5_YTPTRAN, C5.CLI_ORIG, C5.LOJ_ORIG, C5.C5_YCLIORI, C5.C5_YLOJORI, C5.C5_TIPOCLI, C5.C5_CLIENTE, C5.C5_LOJACLI, C6.F4_DUPLIC, C6.C6_VALOR, C5.C5_YFATOR, (A3.A3_COD +' - '+ A3.A3_NREDUZ) AS VENDEDOR, " + Enter
		cQuery += "			CLIENTE = CASE 																						" + Enter
		cQuery += "						WHEN C5_TIPO = 'N' THEN C5.CLI_ORIG														" + Enter
		cQuery += "						ELSE (SELECT (A2_COD + ' - ' + A2_NOME) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') " + Enter
		cQuery += "					END, 									" + Enter
		cQuery += "			SEGMENTO = CASE 					" + Enter
		cQuery += "						WHEN C5_TIPO = 'N' THEN (SELECT RTRIM(X5_DESCRI) FROM "+RetSqlName("SX5")+" WHERE X5_CHAVE = A1.A1_SATIV1 AND X5_TABELA = 'T3' AND D_E_L_E_T_ = '' ) " + Enter
		cQuery += "						ELSE 'OUTROS' 			" + Enter
		cQuery += "					END, 									" + Enter
		cQuery += "			(B1.B1_YFORMAT + B1.B1_YFATOR + B1.B1_YLINHA + B1.B1_YCLASSE) AS PRO, 								" + Enter
		cQuery += "			LOT = CASE 																									" + Enter
		cQuery += "					WHEN Z9.ZZ9_PRODUT IS NULL THEN RTRIM(C6_LOTECTL)+'***'	" + Enter
		cQuery += "					ELSE C6_LOTECTL																				" + Enter
		cQuery += "	  			  END,																								" + Enter
		cQuery += " 		C5.C5_NUM,  																							" + Enter
		cQuery += " 		C5.C5_YPC,   																						" + Enter
		cQuery += " 		C5.C5_YEND,   																						" + Enter
		cQuery += " 		C5.C5_EMISSAO,   																					" + Enter
		cQuery += " 	 	E4.E4_DESCRI AS CONDPAG,  																" + Enter
		cQuery += " 	 	C6.C6_PRODUTO,  																					" + Enter
		cQuery += " 	 	B1.B1_DESC,  																						" + Enter
		cQuery += " 	 	UF_CLI = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_TIPO = 'N' THEN (RTRIM(A1.A1_EST))				" + Enter
		cQuery += " 	 				ELSE (SELECT RTRIM(A2_EST) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 			 END, 																										" + Enter
		cQuery += " 	 	MUN_CLI = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_TIPO = 'N' THEN (RTRIM(A1.A1_MUN))				" + Enter
		cQuery += " 	 				ELSE (SELECT RTRIM(A2_MUN) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 			 END, 		" + Enter
		cQuery += " 	 	ESTADO = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN (RTRIM(A1.A1_EST))				" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT RTRIM(A2_EST) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 				ELSE RTRIM(C5.C5_YEST)								" + Enter
		cQuery += " 	 			END, 																										" + Enter
		cQuery += " 	 	CIDADE = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN (RTRIM(A1.A1_MUN))				" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT RTRIM(A2_MUN) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 				ELSE RTRIM(C5.C5_YMUN)+ '/' +C5.C5_YEST								" + Enter
		cQuery += " 	 			END, 		" + Enter
		cQuery += " 	 	BAIRRO = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN (RTRIM(A1.A1_BAIRRO))				" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT RTRIM(A2_BAIRRO) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 				ELSE RTRIM(C5.C5_YBAIRRO)								" + Enter
		cQuery += " 	 			END, 				" + Enter
		cQuery += " 	 	CEP = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN (RTRIM(A1.A1_CEP))				" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT RTRIM(A2_CEP) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 				ELSE RTRIM(C5.C5_YCEP)								" + Enter
		cQuery += " 	 			END, 																												" + Enter

		cQuery += " 	 	C6.C6_ITEM,  																							" + Enter
		cQuery += " 	 	C6.C6_ENTREG,  																							" + Enter
		cQuery += " 	 	C6.C6_YDTNECE,  																						" + Enter
		cQuery += " 	 	C6.C6_YDTNERE,  																						" + Enter

		cQuery += " 		DTDISPOP = (dbo.FNC_ROP_GET_DTDISP_OP(C5.EMPRESA,C6.C6_FILIAL,B1.B1_COD,C5.C5_NUM,C6.C6_ITEM)),     " + Enter

		cQuery += " 	 	C6.C6_DESCRI,  																						" + Enter
		cQuery += " 	 	C6.C6_PRCVEN,  																						" + Enter
		cQuery += " 	 	C6.C6_QTDVEN,  																						" + Enter
		cQuery += " 	 	C6.C6_QTDENT,  																						" + Enter
		cQuery += " 	 	C6.C6_LOTECTL, 																						" + Enter
		cQuery += " 	 	A1.A1_COD_MUN,   																					" + Enter
		//fernano/facile em 20/01/2014 - mudancas nos conceitos para uso de rota - conforme solicitacao do Mateus por email
		cQuery += " ZONA = CASE	" + Enter
		cQuery += "  		WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN ISNULL((SELECT DA6_PERCUR FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = A1.A1_COD_MUN AND DA6_YEST = A1.A1_EST AND DA6.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += " 		WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN ISNULL((SELECT DA6_PERCUR FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = (SELECT RTRIM(A2_COD_MUN) FROM "+RetSqlName("SA2")+" WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') AND DA6_YEST = (SELECT RTRIM(A2_EST) FROM "+RetSqlName("SA2")+" WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') AND DA6.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += " 		ELSE ISNULL((SELECT DA6_PERCUR FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = C5.C5_YCODMUN AND DA6_YEST = C5.C5_YEST AND DA6.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += " 		END,
		cQuery += " DESZONA = CASE	" + Enter
		cQuery += "  		WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN ISNULL((SELECT TOP 1 DA5_DESC FROM "+RetSqlName("DA5")+" DA5 WITH (NOLOCK) WHERE DA5_FILIAL = '01' AND DA5_COD = (SELECT DA6_PERCUR FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = A1.A1_COD_MUN AND DA6_YEST = A1.A1_EST AND DA6.D_E_L_E_T_ = '') AND DA5.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += " 		WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN ISNULL((SELECT TOP 1 DA5_DESC FROM "+RetSqlName("DA5")+" DA5 WITH (NOLOCK) WHERE DA5_FILIAL = '01' AND DA5_COD = (SELECT DA6_PERCUR FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = (SELECT RTRIM(A2_COD_MUN) FROM "+RetSqlName("SA2")+" WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') AND DA6_YEST = (SELECT RTRIM(A2_EST) FROM "+RetSqlName("SA2")+" WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') AND DA6.D_E_L_E_T_ = '') AND DA5.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += " 		ELSE ISNULL((SELECT TOP 1 DA5_DESC FROM "+RetSqlName("DA5")+" DA5 WITH (NOLOCK) WHERE DA5_FILIAL = '01' AND DA5_COD = (SELECT DA6_PERCUR FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = C5.C5_YCODMUN AND DA6_YEST = C5.C5_YEST AND DA6.D_E_L_E_T_ = '') AND DA5.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += " 		END,			" + Enter
		cQuery += " SETOR = CASE 	" + Enter
		cQuery += "  		WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN ISNULL((SELECT DA6_ROTA FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = A1.A1_COD_MUN AND DA6_YEST = A1.A1_EST AND DA6.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += "  		WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN ISNULL((SELECT DA6_ROTA FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = (SELECT RTRIM(A2_COD_MUN) FROM "+RetSqlName("SA2")+" WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') AND DA6_YEST = (SELECT RTRIM(A2_EST) FROM "+RetSqlName("SA2")+" WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') AND DA6.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += " 		ELSE ISNULL((SELECT DA6_ROTA FROM "+RetSqlName("DA6")+" DA6 WITH (NOLOCK) WHERE DA6_ROTA = C5.C5_YCODMUN AND DA6_YEST = C5.C5_YEST AND DA6.D_E_L_E_T_ = ''),'BRANCO')	" + Enter
		cQuery += " 		END,	" + Enter
		cQuery += " 	 	(C6.C6_QTDVEN - C6.C6_QTDENT) AS SALDO,  															" + Enter
		cQuery += " 	 	PBRUTO = CASE   																					" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'D' AND Z9.ZZ9_PRODUT IS NULL		AND	B1.B1_CONV > 0 THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * B1.B1_PESO)  + (((C6.C6_QTDVEN - C6.C6_QTDENT)/B1.B1_CONV)*B1.B1_YPESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'D' AND Z9.ZZ9_PRODUT IS NOT NULL AND	B1.B1_CONV > 0 THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * Z9.ZZ9_PESO) + (((C6.C6_QTDVEN - C6.C6_QTDENT)/B1.B1_CONV)*Z9.ZZ9_PESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'D' AND Z9.ZZ9_PRODUT IS NULL		AND	B1.B1_CONV = 0 THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * B1.B1_PESO)  + (((C6.C6_QTDVEN - C6.C6_QTDENT)/1)*B1.B1_YPESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'D' AND Z9.ZZ9_PRODUT IS NOT NULL AND	B1.B1_CONV = 0 THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * Z9.ZZ9_PESO) + (((C6.C6_QTDVEN - C6.C6_QTDENT)/1)*Z9.ZZ9_PESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'M' AND Z9.ZZ9_PRODUT IS NULL		THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * B1.B1_PESO)  + (((C6.C6_QTDVEN - C6.C6_QTDENT)*B1.B1_CONV)*B1.B1_YPESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'M' AND Z9.ZZ9_PRODUT IS NOT NULL THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * Z9.ZZ9_PESO) + (((C6.C6_QTDVEN - C6.C6_QTDENT)*B1.B1_CONV)*Z9.ZZ9_PESEMB) " + Enter
		cQuery += "						ELSE 0												" + Enter
		cQuery += " 	 	         END,  													" + Enter
		cQuery += " 	 	ISNULL(SUBSTRING(A4.A4_NOME,1,50),'CLIENTE RETIRA') AS TRANSP,	" + Enter
		cQuery += " 	 	C5.C5_YRECR, 													" + Enter
		cQuery += " 	 	C6.OBS	 														" + Enter
		//Fernando em 07/01 - separar coluna do saldo empenhado - acertado alguns conceitos acima no calculo deste Estoque disponivel total/parcial
		cQuery += " , QTDEMP = C6.C6_QTDEMP " + Enter

		//Atendente - Projeto consolidacao esta tudo na empresa 01
		//cQuery += " , ATENDE = ISNULL((SELECT TOP 1 ZZI_ATENDE FROM ZZI010 X WITH (NOLOCK) WHERE ZZI_VEND = C5.C5_VEND AND ZZI_TPSEG = A1.A1_YTPSEG),'')  " + Enter
		cQuery += "  , ATENDE = ISNULL((SELECT ATENDE FROM [dbo].[GET_ZKP] (A1.A1_YTPSEG, C5_YEMP, A1.A1_EST, C5_VEND, A1.A1_YCAT, A1.A1_GRPVEN)),'')   "+ Enter
		

		cQuery += " , A1.A1_NOME " + Enter
		cQuery += " , C6.C9_DATALIB " + Enter
		cQuery += " , B1.B1_YCLASSE " + Enter
		cQuery += " , B1.B1_YLINHA " + Enter
		cQuery += " , B1.B1_YLINSEQ " + Enter
		cQuery += " , B1.B1_YPCGMR3 " + Enter

		cQuery += " , FORMATO " + Enter
		cQuery += " , FORNO " + Enter
		cQuery += " , ITEM_PED=C6_ITEM 	" + Enter
		cQuery += " , TIPO_PED=C5_YSUBTP " + Enter
		cQuery += " , TP_SEG=A1.A1_YTPSEG " + Enter
		cQuery += " , CATEGORIA=A1.A1_YCAT " + Enter
		cQuery += " , GRP_CLI=A1.A1_GRPVEN " + Enter
		cQuery += " , DIAS_EMP=DATEDIFF(day, C6.C9_DATALIB, GETDATE()) " + Enter


		cQuery += " , DESCPACOTE = ISNULL((SELECT TOP 1 X5_DESCRI FROM SX5010 PCT WITH (NOLOCK) WHERE PCT.X5_TABELA = 'ZH' AND PCT.X5_CHAVE = B1.B1_YPCGMR3 AND PCT.D_E_L_E_T_=''),' ') " + Enter
		cQuery += " , MARCA = ISNULL((SELECT TOP 1 ZZ7_EMP FROM ZZ7010 ZZ7 WITH (NOLOCK) WHERE ZZ7_FILIAL = ' ' AND ZZ7_COD = B1_YLINHA AND ZZ7_LINSEQ = B1_YLINSEQ AND ZZ7.D_E_L_E_T_=' '),' ') " + Enter

		//Fernando em 07/01 - transportadora original do orcamento
		cQuery += " , TRANSP_ORC = (SELECT TOP 1 A42.A4_NOME FROM "+RetSqlName("SCJ")+" CJ WITH (NOLOCK), "+RetSqlName("SCK")+" CK WITH (NOLOCK), SA4010 A42 WITH (NOLOCK) WHERE CJ_FILIAL = CK_FILIAL and CJ_NUM = CK_NUM and CK_NUM+CK_ITEM = C6.C6_NUMORC and CJ.CJ_YTRANSP = A42.A4_COD and CK.D_E_L_E_T_=' ' and CJ.D_E_L_E_T_=' ' and A42.D_E_L_E_T_=' ') " + Enter

		//11/02/2016 - ALTERAÇÃO DE MODIFICAÇÃO DOS SELECTS, INCLUINDO JOINS - LUANA MARIN RIBEIRO
		cQuery += "FROM " + nNomeSC5 + " AS C5 " + Enter
		cQuery += "	INNER JOIN (SELECT * " + Enter
		cQuery += "					,(SELECT MAX(C9_DATALIB) FROM " + nNomeSC9 + " AS XXX WHERE C9_FILIAL = '" + xFilial('SC9') + "' AND C9_PRODUTO = C6_PRODUTO AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND XXX.EMPRESA = ZZZ.EMPRESA) C9_DATALIB " + Enter
		cQuery += "			FROM " + nNomeSC6 + " AS ZZZ WHERE C6_FILIAL = '" + xFilial('SC6') + "') C6 " + Enter
		cQuery += "		ON C5.EMPRESA		= C6.EMPRESA	AND " + Enter
		cQuery += "			C5.C5_NUM		= C6.C6_NUM		AND " + Enter
		cQuery += "			C5.C5_CLIENTE	= C6.C6_CLI		AND " + Enter
		cQuery += "			C5.C5_LOJACLI	= C6.C6_LOJA  	AND " + Enter
		If (cEmpAnt+cFilAnt != '0705')
			cQuery += "			C5.C5_YEMPPED   = C6.C6_YEMPPED	AND " + Enter
		EndIf
		cQuery += "			C6_FILIAL = '" + xFilial('SC6') + "' AND " + Enter
		IF MV_PAR13 = 1
			cQuery += "			C6.F4_DUPLIC = 'S' AND " + Enter
		ELSEIF MV_PAR13 = 2
			cQuery += "			C6.F4_DUPLIC = 'N' AND " + Enter
		END IF
		IF MV_PAR14 = 1
			cQuery += "			C6.F4_ESTOQUE = 'S' AND " + Enter
		ELSEIF MV_PAR14 = 2
			cQuery += "			C6.F4_ESTOQUE = 'N' AND " + Enter
		END IF
		cQuery += "			C6.C6_BLQ		<>	'R'				AND " + Enter
		cQuery += "			(ROUND(C6.C6_QTDVEN,2) - ROUND(C6.C6_QTDENT,2)) > 0 " + Enter
		cQuery += "	INNER JOIN (SELECT * " + Enter
		cQuery += "			FROM " + Enter
		cQuery += "				(SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_BAIRRO, A1_CEP, A1_EST, A1_COD_MUN, A1_RISCO, A1_GRPVEN, A1_YREDCOM, A1_SATIV1, A1_YVENDB2, A1_YVENDB3, A1_YTPSEG, A1_VENCLC, A1_YCAT ,A1_VEND, A1_YVENDI " + Enter
		cQuery += "				FROM " + RetSqlName("SA1") + " WITH (NOLOCK) " + Enter
		cQuery += "				WHERE A1_FILIAL = '" + xFilial('SA1') + "' AND D_E_L_E_T_ = '' ) AS TMP)  A1 " + Enter
		cQuery += "		ON C5.CLI_ORIG	= A1.A1_COD 	AND " + Enter
		cQuery += "		C5.LOJ_ORIG		= A1.A1_LOJA 	AND " + Enter
		IF alltrim(cRepAtu) <> ""
			// VERIFICANDO SE E O GERENTE // BRUNO MADALENO
			IF SUBSTRING(cRepAtu,1,1) = "1"
				IF CEMPANT == "01"
					cQuery += "			(A1_YVENDB2 = '"+cRepAtu+"' OR  A1_YVENDB3 = '"+cRepAtu+"') AND " + Enter
				ELSE
					cQuery += "			(A1_YVENDI2 = '"+cRepAtu+"' OR  A1_YVENDI3 = '"+cRepAtu+"') AND " + Enter
				END IF
			END IF
		END IF


		cQuery += "			A1.A1_GRPVEN BETWEEN '"+MV_PAR16+"' AND '"+MV_PAR17+"' AND " + Enter
		cQuery += "			A1.A1_SATIV1 BETWEEN '"+MV_PAR20+"' AND '"+MV_PAR21+"' AND " + Enter 
        If MV_PAR33 == "5"
            cQuery += "			A1.A1_YTPSEG in ('R','E','H','X') AND " + Enter
        Else
            cQuery += "			A1.A1_YTPSEG = '"+MV_PAR33+"' AND " + Enter
        EndIf
        cQuery += "			A1.A1_YREDCOM BETWEEN '"+MV_PAR31+"' AND '"+MV_PAR32+"' " + Enter
		cQuery += "	INNER JOIN " + RetSqlName("SE4") + " E4 WITH (NOLOCK) " + Enter
		cQuery += "		ON C5.C5_CONDPAG	= E4.E4_CODIGO	AND " + Enter
		cQuery += "			E4_FILIAL = '" + xFilial('SE4') + "' AND " + Enter
		cQuery += "			E4.D_E_L_E_T_ = '' " + Enter
		cQuery += "	INNER JOIN " + RetSqlName("SA3") + " A3 WITH (NOLOCK) " + Enter
		cQuery += "		ON ISNULL(C5.C5_VEND,'999999')	= A3.A3_COD	AND " + Enter
		cQuery += "			A3_FILIAL = '" + xFilial('SA3') + "' AND " + Enter
		cQuery += "			A3.D_E_L_E_T_ = '' " + Enter
		cQuery += "	INNER JOIN " + RetSqlName("SB1") + " B1 WITH (NOLOCK) " + Enter
		cQuery += "		ON C6.C6_PRODUTO	= B1.B1_COD			AND " + Enter
		cQuery += "			B1_FILIAL = '" + xFilial('SB1') + "' AND " + Enter
		cQuery += "			B1.B1_COD BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND " 	+ Enter
		IF !EMPTY(MV_PAR27)
			cQuery += " 		B1.B1_YCLASSE >= '"+MV_PAR27+"' AND " + Enter
		ENDIF

		IF !EMPTY(MV_PAR28)
			cQuery += " 		B1.B1_YCLASSE <= '"+MV_PAR28+"' AND " + Enter
		ENDIF
		cQuery += "			B1.B1_TIPO		=	'PA' 			AND " + Enter
		cQuery += "			B1.D_E_L_E_T_ = '' " + Enter
		cQuery += "	INNER JOIN " + RetSqlName("ZZ9") + " Z9 WITH (NOLOCK) " + Enter
		cQuery += "		ON C6.C6_LOTECTL = Z9.ZZ9_LOTE AND " + Enter
		cQuery += "			(B1.B1_YFORMAT+B1.B1_YFATOR+B1.B1_YLINHA+B1.B1_YCLASSE) = Z9.ZZ9_PRODUT AND " + Enter
		cQuery += "			ZZ9_FILIAL 	= '" + xFilial('ZZ9') + "' AND " + Enter
		cQuery += "			Z9.D_E_L_E_T_ = '' " + Enter
		cQuery += "	LEFT JOIN " + RetSqlName("SA4") + " A4 WITH (NOLOCK) " + Enter
		cQuery += "		ON C5.C5_TRANSP1	= A4.A4_COD		AND " + Enter
		cQuery += "			A4_FILIAL = '" + xFilial('SA4') + "' AND " + Enter
		cQuery += "			A4.D_E_L_E_T_ = '' " + Enter
		cQuery += "WHERE C5_FILIAL = '"+xFilial('SC5')+"' AND	" + Enter
		cQuery += "			C5.C5_NUM BETWEEN '"+MV_PAR01+"'  AND '"+MV_PAR02+"' AND	" + Enter
	
        IF alltrim(cRepAtu) = ""

			IF MV_PAR18 == 2
				cQuery += "	C5.C5_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + Enter
			ELSE
				cQuery += "	C5.C5_VEND IN ("+cVend+") AND " + Enter
			ENDIF
         
			If Alltrim(MV_PAR19) <> ""

				cQuery += " ISNULL((SELECT ATENDE FROM [dbo].[GET_ZKP] (A1.A1_YTPSEG, C5_YEMP, A1.A1_EST, C5_VEND, A1.A1_YCAT, A1.A1_GRPVEN)), '') = '"+MV_PAR19+"'  AND "+ Enter
				
				//(SELECT ATENDE FROM [dbo].[GET_ZKP] (A1.A1_YTPSEG, C5_YEMP, A1.A1_EST, C5_VEND, '', '')) 
				//cQuery += "	C5.C5_VEND IN (SELECT ZZI_VEND FROM ZZI010 WITH (NOLOCK) WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND ZZI_ATENDE = '"+MV_PAR19+"'	AND D_E_L_E_T_ = '') AND " + Enter

			EndIf

		ELSE

			// VERIFICANDO SE E O GERENTE // BRUNO MADALENO
			IF SUBSTRING(cRepAtu,1,1) = "1"
				IF CEMPANT == "01"
					cQuery += "	C5.C5_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + Enter
				ELSE
					cQuery += "	C5.C5_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + Enter
				END IF
			ELSE
				cQuery += "	C5.C5_VEND = '"+cRepAtu+"' AND " + Enter
			END IF

			MV_PAR03 := cRepAtu
			MV_PAR04 := cRepAtu

		END IF
		cQuery += "			C5.C5_EMISSAO BETWEEN '"+cData_ini+"' AND '"+cData_fim+"' AND " + Enter

		If !Empty(cLinPed)
			cQuery += "			C5.C5_YLINHA IN ("+cLinPed+") AND " + Enter
		EndIf
		cQuery += "			C5.CLI_ORIG BETWEEN '"	+MV_PAR09+"' AND '" + MV_PAR10 + "' AND " 	+ Enter


		IF MV_PAR15 = 1
			cQuery += "			C5.C5_TIPOCLI <> 'X' AND " + Enter
		ELSEIF MV_PAR15 = 2
			cQuery += "			C5.C5_TIPOCLI = 'X' AND " + Enter
		END IF
		IF !EMPTY(MV_PAR22)
			cQuery += " 		C5.C5_YSUBTP = '"+MV_PAR22+"' AND " + Enter
		ENDIF
		IF !EMPTY(MV_PAR24)
			cQuery += " 		C5.C5_YPC = '"+MV_PAR24+"' AND " + Enter
		ENDIF
		// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
		cQuery += "  CASE WHEN C5_TIPO = 'N' THEN (RTRIM(A1.A1_EST))	"
		cQuery += " ELSE (SELECT RTRIM(A2_EST) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') END BETWEEN "+ ValToSQL(MV_PAR29) + " AND " + ValToSQL(MV_PAR30)
		cQuery += "	AND C5.D_E_L_E_T_ = ''" + Enter


		If (oAceTela:UserTelemaketing())

			// vendedor de = MV_PAR03
			// vendedor até = MV_PAR04

			If (AllTrim(MV_PAR03) == AllTrim(MV_PAR04))
				cQuery += " AND  ( "+oAceTela:FiltroSA1('S', '', MV_PAR03)+" ) 								" + Enter
			Else
				cQuery += " AND  ( "+oAceTela:FiltroSA1('S')+" ) 											" + Enter
			EndIf

		EndIf

		cQuery += "ORDER BY ZONA, C5.C5_YTPTRAN, A3.A3_COD, A3.A3_NOME, C5.CLI_ORIG, C5.C5_NUM, C6.C6_ITEM " + Enter
		MemoWrite("\SQLMAPAPEDIDOS.TXT",cQuery)
	ELSE
		//Nao utiliza Roteirização
		cQuery := ""
		cQuery := "SELECT	C5.EMPRESA, E4.E4_YMEDIA, C5.C5_YTPTRAN, C5.CLI_ORIG, C5.LOJ_ORIG, C5.C5_YCLIORI, C5.C5_YLOJORI, C5.C5_TIPOCLI, C5.C5_CLIENTE, C5.C5_LOJACLI, C6.F4_DUPLIC, C6.C6_VALOR, C5.C5_YFATOR, (A3.A3_COD +' - '+ A3.A3_NREDUZ) AS VENDEDOR, " + Enter
		cQuery += "			CLIENTE = CASE 																						" + Enter
		cQuery += "						WHEN C5_TIPO = 'N' THEN C5.CLI_ORIG														" + Enter
		cQuery += "						ELSE (SELECT (A2_COD + ' - ' + A2_NOME) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') " + Enter
		cQuery += "					END, 																						" + Enter
		cQuery += "			SEGMENTO = CASE 																					" + Enter
		cQuery += "						WHEN C5_TIPO = 'N' THEN (SELECT RTRIM(X5_DESCRI) FROM "+RetSqlName("SX5")+" WHERE X5_CHAVE = A1.A1_SATIV1 AND X5_TABELA = 'T3' AND D_E_L_E_T_ = '' ) " + Enter
		cQuery += "						ELSE 'OUTROS' " + Enter
		cQuery += "					END, 																						" + Enter
		cQuery += "			(B1.B1_YFORMAT + B1.B1_YFATOR + B1.B1_YLINHA + B1.B1_YCLASSE) AS PRO, 								" + Enter
		cQuery += "			LOT = CASE 																							" + Enter
		cQuery += "					WHEN Z9.ZZ9_PRODUT IS NULL THEN RTRIM(C6_LOTECTL)+'***'										" + Enter
		cQuery += "					ELSE C6_LOTECTL																				" + Enter
		cQuery += "	  			  END,																							" + Enter
		cQuery += " 		C5.C5_NUM,  																						" + Enter
		cQuery += " 		C5.C5_YPC,   																						" + Enter
		cQuery += " 		C5.C5_YEND,   																						" + Enter
		cQuery += " 		C5.C5_EMISSAO,   																					" + Enter
		cQuery += " 	 	E4.E4_DESCRI AS CONDPAG,  																			" + Enter
		cQuery += " 	 	C6.C6_PRODUTO,  																					" + Enter
		cQuery += " 	 	B1.B1_DESC,  																						" + Enter
		cQuery += " 	 	UF_CLI = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_TIPO = 'N' THEN (RTRIM(A1.A1_EST))				" + Enter
		cQuery += " 	 				ELSE (SELECT RTRIM(A2_EST) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 			 END, 																										" + Enter
		cQuery += " 	 	MUN_CLI = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_TIPO = 'N' THEN (RTRIM(A1.A1_MUN))				" + Enter
		cQuery += " 	 				ELSE (SELECT RTRIM(A2_MUN) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 			 END, 		" + Enter
		cQuery += " 	 	ESTADO = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN (RTRIM(A1.A1_EST))				" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT RTRIM(A2_EST) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 				ELSE RTRIM(C5.C5_YEST)								" + Enter
		cQuery += " 	 			END, 																										" + Enter
		cQuery += " 	 	CIDADE = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN (RTRIM(A1.A1_MUN))				" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT RTRIM(A2_MUN) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 				ELSE RTRIM(C5.C5_YMUN)+ '/' +C5.C5_YEST								" + Enter
		cQuery += " 	 			END, 		" + Enter
		cQuery += " 	 	BAIRRO = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN (RTRIM(A1.A1_BAIRRO))				" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT RTRIM(A2_BAIRRO) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 				ELSE RTRIM(C5.C5_YBAIRRO)								" + Enter
		cQuery += " 	 			END, 				" + Enter
		cQuery += " 	 	CEP = CASE 																							" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'N' THEN (RTRIM(A1.A1_CEP))				" + Enter
		cQuery += " 	 				WHEN C5_YFLAG = '1' AND C5_TIPO = 'B' THEN (SELECT RTRIM(A2_CEP) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '"+xFilial('SA2')+"' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') 	" + Enter
		cQuery += " 	 				ELSE RTRIM(C5.C5_YCEP)								" + Enter
		cQuery += " 	 			END, 																						" + Enter
		cQuery += " 	 	C6.C6_ITEM,  																						" + Enter
		cQuery += " 	 	C6.C6_ENTREG,  																						" + Enter
		cQuery += " 	 	C6.C6_YDTNECE,  																					" + Enter
		cQuery += " 	 	C6.C6_YDTNERE,  																					" + Enter

		cQuery += " 		DTDISPOP = (dbo.FNC_ROP_GET_DTDISP_OP(C5.EMPRESA,C6.C6_FILIAL,B1.B1_COD,C5.C5_NUM,C6.C6_ITEM)),     " + Enter

		cQuery += " 	 	C6.C6_DESCRI,  																						" + Enter
		cQuery += " 	 	C6.C6_PRCVEN,  																						" + Enter
		cQuery += " 	 	C6.C6_QTDVEN,  																						" + Enter
		cQuery += " 	 	C6.C6_QTDENT,  																						" + Enter
		cQuery += " 	 	C6.C6_PRUNIT,  																						" + Enter
		cQuery += " 	 	C6.C6_LOTECTL, 																						" + Enter
		cQuery += " 	 	A1.A1_COD_MUN,   																					" + Enter
		cQuery += " 	 	(C6.C6_QTDVEN - C6.C6_QTDENT) AS SALDO,  															" + Enter
		cQuery += " 	 	PBRUTO = CASE   																					" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'D' AND Z9.ZZ9_PRODUT IS NULL		AND	B1.B1_CONV > 0 THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * B1.B1_PESO)  + (((C6.C6_QTDVEN - C6.C6_QTDENT)/B1.B1_CONV)*B1.B1_YPESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'D' AND Z9.ZZ9_PRODUT IS NOT NULL AND	B1.B1_CONV > 0 THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * Z9.ZZ9_PESO) + (((C6.C6_QTDVEN - C6.C6_QTDENT)/B1.B1_CONV)*Z9.ZZ9_PESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'D' AND Z9.ZZ9_PRODUT IS NULL		AND	B1.B1_CONV = 0 THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * B1.B1_PESO)  + (((C6.C6_QTDVEN - C6.C6_QTDENT)/1)*B1.B1_YPESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'D' AND Z9.ZZ9_PRODUT IS NOT NULL AND	B1.B1_CONV = 0 THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * Z9.ZZ9_PESO) + (((C6.C6_QTDVEN - C6.C6_QTDENT)/1)*Z9.ZZ9_PESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'M' AND Z9.ZZ9_PRODUT IS NULL		THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * B1.B1_PESO)  + (((C6.C6_QTDVEN - C6.C6_QTDENT)*B1.B1_CONV)*B1.B1_YPESEMB)	" + Enter
		cQuery += "						WHEN B1.B1_TIPCONV  = 'M' AND Z9.ZZ9_PRODUT IS NOT NULL THEN ((C6.C6_QTDVEN - C6.C6_QTDENT) * Z9.ZZ9_PESO) + (((C6.C6_QTDVEN - C6.C6_QTDENT)*B1.B1_CONV)*Z9.ZZ9_PESEMB) " + Enter
		cQuery += "						ELSE 0												" + Enter
		cQuery += " 	 	         END,  													" + Enter
		cQuery += " 	 	ISNULL(SUBSTRING(A4.A4_NOME,1,50),'CLIENTE RETIRA') AS TRANSP,	" + Enter
		cQuery += " 	 	C5.C5_YRECR, 													" + Enter
		cQuery += " 	 	C6.OBS       													" + Enter
		//Fernando em 07/01 - separar coluna do saldo empenhado - acertado alguns conceitos acima no calculo deste Estoque disponivel total/parcial
		cQuery += " , QTDEMP = C6.C6_QTDEMP " + Enter
		
		/*If cEmpAnt == '01'
			cQuery += " , ATENDE = ISNULL((SELECT TOP 1 ZZI_ATENDE FROM "+RetSqlName("ZZI")+" X WITH (NOLOCK) WHERE ZZI_VEND = C5.C5_VEND AND ZZI_TPSEG = A1.A1_YTPSEG),'')  " + Enter
		Else
			cQuery += " , ATENDE = ISNULL((SELECT TOP 1 ZZI_ATENDE FROM ZZI050 X WITH (NOLOCK) WHERE ZZI_VEND = C5.C5_VEND AND ZZI_TPSEG = A1.A1_YTPSEG),'')  " + Enter
		EndIf
		*/
		cQuery += "  , ATENDE =  ISNULL((SELECT ATENDE FROM [dbo].[GET_ZKP] (A1.A1_YTPSEG, C5_YEMP, A1.A1_EST, C5_VEND, A1.A1_YCAT, A1.A1_GRPVEN)),'')   "+ Enter
	
		cQuery += " , A1.A1_NOME " + Enter
		cQuery += " , C6.C9_DATALIB " + Enter
		cQuery += " , B1.B1_YCLASSE " + Enter
		cQuery += " , B1.B1_YLINHA " + Enter
		cQuery += " , B1.B1_YLINSEQ " + Enter
		cQuery += " , B1.B1_YPCGMR3 " + Enter

		cQuery += " , FORMATO " + Enter
		cQuery += " , FORNO " + Enter
		cQuery += " , ITEM_PED=C6_ITEM 	" + Enter
		cQuery += " , TIPO_PED=C5_YSUBTP " + Enter
		cQuery += " , TP_SEG=A1.A1_YTPSEG " + Enter
		cQuery += " , CATEGORIA=A1.A1_YCAT " + Enter
		cQuery += " , GRP_CLI=A1.A1_GRPVEN " + Enter
		cQuery += " , DIAS_EMP=DATEDIFF(day, C6.C9_DATALIB, GETDATE()) " + Enter


		cQuery += " , DESCPACOTE = ISNULL((SELECT TOP 1 X5_DESCRI FROM SX5010 PCT WITH (NOLOCK) WHERE PCT.X5_TABELA = 'ZH' AND PCT.X5_CHAVE = B1.B1_YPCGMR3 AND PCT.D_E_L_E_T_=''),' ') " + Enter
		cQuery += " , MARCA = ISNULL((SELECT TOP 1 ZZ7_EMP FROM ZZ7010 ZZ7 WITH (NOLOCK) WHERE ZZ7_FILIAL = ' ' AND ZZ7_COD = B1_YLINHA AND ZZ7_LINSEQ = B1_YLINSEQ AND ZZ7.D_E_L_E_T_=' '),' ') " + Enter

		//Fernando em 07/01 - transportadora original do orcamento
		cQuery += " , TRANSP_ORC = (SELECT TOP 1 A42.A4_NOME FROM "+RetSqlName("SCJ")+" CJ WITH (NOLOCK), "+RetSqlName("SCK")+" CK WITH (NOLOCK), SA4010 A42 WITH (NOLOCK) WHERE CJ_FILIAL = CK_FILIAL and CJ_NUM = CK_NUM and CK_NUM+CK_ITEM = C6.C6_NUMORC and CJ.CJ_YTRANSP = A42.A4_COD and CK.D_E_L_E_T_=' ' and CJ.D_E_L_E_T_=' ' and A42.D_E_L_E_T_=' ') " + Enter

		//11/02/2016 - ALTERAÇÃO DE MODIFICAÇÃO DOS SELECTS, INCLUINDO JOINS - LUANA MARIN RIBEIRO
		cQuery += "FROM " + nNomeSC5 + " AS C5 " + Enter
		cQuery += "	INNER JOIN  (SELECT * " + Enter
		cQuery += "					,(SELECT MAX(C9_DATALIB) FROM " + nNomeSC9 + " AS XXX WHERE C9_FILIAL = '" + xFilial('SC9') + "' AND C9_PRODUTO = C6_PRODUTO AND C9_PEDIDO = C6_NUM AND C9_ITEM = C6_ITEM AND XXX.EMPRESA = ZZZ.EMPRESA) C9_DATALIB " + Enter
		cQuery += "			FROM " + nNomeSC6 + " AS ZZZ WHERE C6_FILIAL = '" + xFilial('SC6') + "') C6 " + Enter
		cQuery += "		ON C5.EMPRESA		= C6.EMPRESA	AND " + Enter
		cQuery += "			C5.C5_NUM		= C6.C6_NUM		AND " + Enter
		cQuery += "			C5.C5_CLIENTE	= C6.C6_CLI		AND " + Enter
		cQuery += "			C5.C5_LOJACLI	= C6.C6_LOJA	AND " + Enter
		
		If (cEmpAnt+cFilAnt != '0705')
			cQuery += "			C5.C5_YEMPPED   = C6.C6_YEMPPED	AND " + Enter
		Endif
		
		cQuery += "			C6_FILIAL = '" + xFilial('SC6') + "' AND " + Enter
		IF MV_PAR13 = 1
			cQuery += "			C6.F4_DUPLIC = 'S' AND " + Enter
		ELSEIF MV_PAR13 = 2
			cQuery += "			C6.F4_DUPLIC = 'N' AND " + Enter
		END IF
		IF MV_PAR14 = 1
			cQuery += "			C6.F4_ESTOQUE = 'S' AND " + Enter
		ELSEIF MV_PAR14 = 2
			cQuery += "			C6.F4_ESTOQUE = 'N' AND " + Enter
		END IF
		cQuery += "			C6.C6_BLQ		<>	'R'				AND " + Enter
		cQuery += "			(ROUND(C6.C6_QTDVEN,2) - ROUND(C6.C6_QTDENT,2)) > 0 " + Enter
		cQuery += "	INNER JOIN (SELECT * " + Enter
		cQuery += "			FROM " + Enter
		cQuery += "			(SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_BAIRRO, A1_CEP, A1_EST, A1_COD_MUN, A1_RISCO, A1_GRPVEN, A1_YREDCOM, A1_SATIV1, A1_YVENDB2, A1_YVENDB3, A1_YTPSEG, A1_VENCLC, A1_YCAT, A1_VEND, A1_YVENDI " + Enter
		cQuery += "			FROM " + RetSqlName("SA1") + " WITH (NOLOCK) " + Enter
		cQuery += "			WHERE A1_FILIAL = '" + xFilial('SA1') + "' AND D_E_L_E_T_ = '' ) AS TMP)  A1 " + Enter
		cQuery += "		ON C5.CLI_ORIG     = A1.A1_COD      AND " + Enter
		cQuery += "		   C5.LOJ_ORIG     = A1.A1_LOJA     AND " + Enter
		IF alltrim(cRepAtu) <> ""
			// VERIFICANDO SE E O GERENTE // BRUNO MADALENO
			IF SUBSTRING(cRepAtu,1,1) = "1"
				IF CEMPANT == "01"
					cQuery += "			(A1_YVENDB2 = '"+cRepAtu+"' OR  A1_YVENDB3 = '"+cRepAtu+"') AND " + Enter
				ELSE
					cQuery += "			(A1_YVENDI2 = '"+cRepAtu+"' OR  A1_YVENDI3 = '"+cRepAtu+"') AND " + Enter
				END IF
			END IF
		END IF

		cQuery += "			A1.A1_GRPVEN BETWEEN '"+MV_PAR16+"' AND '"+MV_PAR17+"' AND " + Enter
		cQuery += "			A1.A1_SATIV1 BETWEEN '"+MV_PAR20+"' AND '"+MV_PAR21+"' AND " + Enter 
		If MV_PAR33 == "5"
            cQuery += "			A1.A1_YTPSEG in ('R','E','H','X') AND " + Enter
        Else
            cQuery += "			A1.A1_YTPSEG = '"+MV_PAR33+"' AND " + Enter
        EndIf
        
        cQuery += "			A1.A1_YREDCOM BETWEEN '"+MV_PAR31+"' AND '"+MV_PAR32+"' " + Enter
		cQuery += "	INNER JOIN " + RetSqlName("SE4") + " E4 WITH (NOLOCK) " + Enter
		cQuery += "		ON C5.C5_CONDPAG	= E4.E4_CODIGO	  AND " + Enter
		cQuery += "			E4_FILIAL = '" + xFilial('SE4') + "' AND " + Enter
		cQuery += "			E4.D_E_L_E_T_ = '' " + Enter
		cQuery += "	INNER JOIN " + RetSqlName("SA3") + " A3 WITH (NOLOCK) " + Enter
		cQuery += "		ON ISNULL(C5.C5_VEND,'999999')	= A3.A3_COD		  AND " + Enter
		cQuery += "			A3_FILIAL = '" + xFilial('SA3') + "' AND " + Enter
		cQuery += "			A3.D_E_L_E_T_ = '' " + Enter
		cQuery += "	INNER JOIN " + RetSqlName("SB1") + " B1 WITH (NOLOCK) " + Enter
		cQuery += "		ON C6.C6_PRODUTO	= B1.B1_COD		  AND " + Enter
		cQuery += "			B1.B1_COD BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' AND " + Enter
		IF !EMPTY(MV_PAR27)
			cQuery += " 		B1.B1_YCLASSE >= '"+MV_PAR27+"' AND " + Enter
		ENDIF

		IF !EMPTY(MV_PAR28)
			cQuery += " 		B1.B1_YCLASSE <= '"+MV_PAR28+"' AND " + Enter
		ENDIF
		cQuery += "			B1.B1_TIPO	IN ('PA','PR')			AND " + Enter  //colocado o IN PA,PR ticket 4910 - produto ISOMANTA
		cQuery += "			B1_FILIAL = '" + xFilial('SB1') + "' AND " + Enter
		cQuery += "			B1.D_E_L_E_T_ = '' " + Enter
		cQuery += "	LEFT JOIN " + RetSqlName("ZZ9") + " Z9 WITH (NOLOCK) -- LEFT? INNER? " + Enter  //modificado para LEFT ticket 4910 - produto ISOMANTA
		cQuery += "		ON C6.C6_LOTECTL = Z9.ZZ9_LOTE  AND " + Enter
		cQuery += "			(B1.B1_YFORMAT+B1.B1_YFATOR+B1.B1_YLINHA+B1.B1_YCLASSE) = Z9.ZZ9_PRODUT AND " + Enter
		cQuery += "			ZZ9_FILIAL  = '" + xFilial('ZZ9') + "' AND " + Enter
		cQuery += "			Z9.D_E_L_E_T_ = '' " + Enter
		cQuery += "	LEFT JOIN " + RetSqlName("SA4") + " A4 WITH (NOLOCK) " + Enter
		cQuery += "		ON C5.C5_TRANSP1	= A4.A4_COD		  AND " + Enter
		cQuery += "			A4_FILIAL = '" + xFilial('SA4') + "' AND " + Enter
		cQuery += "			A4.D_E_L_E_T_ = '' " + Enter
		cQuery += "WHERE C5_FILIAL = '"+xFilial('SC5')+"' AND	" + Enter
		cQuery += "			C5.C5_NUM BETWEEN '"+MV_PAR01+"'  AND '"+MV_PAR02+"' AND	" + Enter
		IF alltrim(cRepAtu) = ""
			IF MV_PAR18 == 2
				cQuery += "			C5.C5_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + Enter
			ELSE
				cQuery += "			C5.C5_VEND IN ("+cVend+") AND " + Enter
			ENDIF
			If Alltrim(MV_PAR19) <> ""
				
				cQuery += " ISNULL((SELECT ATENDE FROM [dbo].[GET_ZKP] (A1.A1_YTPSEG, C5_YEMP, A1.A1_EST, C5_VEND, A1.A1_YCAT, A1.A1_GRPVEN)), '') = '"+MV_PAR19+"'  AND "+ Enter
				
				//cQuery += " ( SELECT COUNT(*) FROM [dbo].[GET_ZKP] (A1.A1_YTPSEG, C5.C5_YEMP, A1.A1_EST, C5.C5_VEND, '', '') where ATENDE = '"+MV_PAR19+"'  > 0) AND "+ Enter
				
					
				/*If cEmpAnt == '01'
					cQuery += "			C5.C5_VEND IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+" WITH (NOLOCK) WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND ZZI_ATENDE = '"+MV_PAR19+"'	AND D_E_L_E_T_ = '') AND " + Enter
				Else
					cQuery += "			C5.C5_VEND IN (SELECT ZZI_VEND FROM ZZI050 WITH (NOLOCK) WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND ZZI_ATENDE = '"+MV_PAR19+"'	AND D_E_L_E_T_ = '') AND " + Enter
				EndIf*/
			EndIf
		ELSE
			// VERIFICANDO SE E O GERENTE // BRUNO MADALENO
			IF SUBSTRING(cRepAtu,1,1) = "1"
				IF CEMPANT == "01"
					cQuery += "			C5.C5_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + Enter
				ELSE
					cQuery += "			C5.C5_VEND BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND " + Enter
				END IF
			ELSE
				cQuery += "			C5.C5_VEND = '"+cRepAtu+"' AND " + Enter
			END IF

			MV_PAR03 := cRepAtu
			MV_PAR04 := cRepAtu
		END IF
		cQuery += "			C5.C5_EMISSAO BETWEEN '"+cData_ini+"' AND '"+cData_fim+"' AND " + Enter
		If !Empty(cLinPed)
			cQuery += "			C5.C5_YLINHA IN ("+cLinPed+") AND " + Enter
		EndIf
		cQuery += "			C5.CLI_ORIG BETWEEN '"+MV_PAR09+"' AND '" + MV_PAR10 + "' AND " + Enter
		IF MV_PAR15 = 1
			cQuery += "			C5.C5_TIPOCLI <> 'X' AND " + Enter
		ELSEIF MV_PAR15 = 2
			cQuery += "			C5.C5_TIPOCLI = 'X' AND " + Enter
		END IF
		IF !EMPTY(MV_PAR22)
			cQuery += "			C5.C5_YSUBTP = '"+MV_PAR22+"' AND " + Enter
		ENDIF
		IF !EMPTY(MV_PAR24)
			cQuery += "			C5.C5_YPC = '"+MV_PAR24+"' AND " + Enter
		ENDIF

		// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
		cQuery += " CASE WHEN C5_TIPO = 'N' THEN (RTRIM(A1.A1_EST))	"
		cQuery += " ELSE (SELECT RTRIM(A2_EST) FROM SA2010 WITH (NOLOCK) WHERE A2_FILIAL = '' AND A2_COD = C5.CLI_ORIG AND A2_LOJA = C5.LOJ_ORIG AND D_E_L_E_T_ = '') END BETWEEN "+ ValToSQL(MV_PAR29) + " AND " + ValToSQL(MV_PAR30)

		cQuery += "	AND C5.D_E_L_E_T_ = '' " + Enter

		If (oAceTela:UserTelemaketing())

			// vendedor de = MV_PAR03
			// vendedor até = MV_PAR04

			If (AllTrim(MV_PAR03) == AllTrim(MV_PAR04))
				cQuery += " AND  ( "+oAceTela:FiltroSA1('S', '', MV_PAR03)+" ) 								" + Enter
			Else
				cQuery += " AND  ( "+oAceTela:FiltroSA1('S')+" ) 											" + Enter
			EndIf

		EndIf

		cQuery += "ORDER BY C5.C5_YTPTRAN, A3.A3_COD, A3.A3_NOME, C5.CLI_ORIG, C5.C5_NUM, C6.C6_ITEM " + Enter
		MemoWrite("\SQLMAPAPEDIDOS.TXT",cQuery)
	ENDIF
	IF chkfile("cTrab")
		dbSelectArea("cTrab")
		dbCloseArea()
	ENDIF
	TCQUERY cQuery ALIAS "cTrab" NEW
	cTrab->(dbGoTop())

	//Conta regitros para montar barra
	nTotReg := Contar("cTrab","!Eof()")

Return

/*/{Protheus.doc} Monta_Arq
@description Impressao
@since 25/01/2018
@version 1.0
@type function
/*/
Static Function Impr_Arq(Cabec1,Cabec2,Titulo,nLin)

	xVerLote := .F.

	//Armazenar informacoes do Segmento
	aSegmento :=	{{"SEG"			,"C",20,0},;
		{"PRCVEN"		,"N",12,2},;
		{"QTDVEN"		,"N",12,2},;
		{"QTDENT"		,"N",12,2},;
		{"SALDO"		,"N",12,2},;
		{"SALVLR"		,"N",12,2},;
		{"PBRUTO"		,"N",12,2},;
		{"QUANT"		,"N",12,2}}
	If chkfile("_Segmento")
		dbSelectArea("_Segmento")
		dbCloseArea()
	EndIf
	_Segmento := CriaTrab(aSegmento)
	dbUseArea(.T.,,_Segmento,"_Segmento",.t.)
	dbCreateInd(_Segmento,"SEG",{||SEG})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lFirstCc   := .T.
	lFirstCta  := .T.
	OldPed     := ''
	OldCli     := ''
	OldVend    := ' '
	OldZona    := ''
	OldTrans   := ''
	cTranspAux := ''
	//VARIAVEIS PARA TOTAIS DE PEDIDO
	P_PRCVEN  := 0
	P_QTDVEN  := 0
	P_VALOR   := 0
	P_QTDENT  := 0
	P_SALDO   := 0
	P_SALVLR  := 0
	P_PBRUTO  := 0
	P_QUANT   := 0
	//VARIAVEIS PARA TOTAIS DE CLIENTE
	C_PRCVEN  := 0
	C_QTDVEN  := 0
	C_VALOR   := 0
	C_QTDENT  := 0
	C_SALDO   := 0
	C_SALVLR  := 0
	C_PBRUTO  := 0
	C_QUANT   := 0
	//VARIAVEIS PARA TOTAIS DE VENDEDOR
	V_PRCVEN  := 0
	V_QTDVEN  := 0
	V_QTDENT  := 0
	V_SALDO   := 0
	V_SALVLR  := 0
	V_PBRUTO  := 0
	V_QUANT   := 0
	//VARIAVEIS PARA TOTAIS POR TIPO DE TRANSPORTE
	T_PRCVEN  := 0
	T_QTDVEN  := 0
	T_QTDENT  := 0
	T_SALDO   := 0
	T_SALVLR  := 0
	T_PBRUTO  := 0
	T_QUANT   := 0
	T_MM_MEDIA  := 0
	//VARIAVEIS PARA TOTAIS POR ZONA
	S_PRCVEN  := 0
	S_QTDVEN  := 0
	S_QTDENT  := 0
	S_SALDO   := 0
	S_SALVLR  := 0
	S_PBRUTO  := 0
	S_QUANT   := 0
	S_MM_MEDIA  := 0
	//If cEmpAnt == "01"
	//VARIAVEIS PARA 1-BLOQUEIO/PREÇO
	R_PRCVEN  := 0
	R_QTDVEN  := 0
	R_QTDENT  := 0
	R_SALDO   := 0
	R_SALVLR  := 0
	R_PBRUTO  := 0
	R_QUANT   := 0
	//VARIAVEIS PARA 2-CREDITO
	E_PRCVEN  := 0
	E_QTDVEN  := 0
	E_QTDENT  := 0
	E_SALDO   := 0
	E_SALVLR  := 0
	E_PBRUTO  := 0
	E_QUANT   := 0
	//VARIAVEIS PARA 3-ESTOQUE DISP./CREDITO
	G_PRCVEN  := 0
	G_QTDVEN  := 0
	G_QTDENT  := 0
	G_SALDO   := 0
	G_SALVLR  := 0
	G_PBRUTO  := 0
	G_QUANT   := 0
	//VARIAVEIS PARA 4-ESTOQUE DISP. PARCIAL
	Z_PRCVEN  := 0
	Z_QTDVEN  := 0
	Z_QTDENT  := 0
	Z_SALDO   := 0
	Z_SALVLR  := 0
	Z_PBRUTO  := 0
	Z_QUANT   := 0
	//VARIAVEIS PARA 5-ESTOQUE DISP. TOTAL
	Q_PRCVEN  := 0
	Q_QTDVEN  := 0
	Q_QTDENT  := 0
	Q_SALDO   := 0
	Q_SALVLR  := 0
	Q_PBRUTO  := 0
	Q_QUANT   := 0
	//VARIAVEIS PARA 6-EM CARREGAMENTO PARCIAL
	M_PRCVEN  := 0
	M_QTDVEN  := 0
	M_QTDENT  := 0
	M_SALDO   := 0
	M_SALVLR  := 0
	M_PBRUTO  := 0
	M_QUANT   := 0
	//VARIAVEIS PARA 7-EM CARREGAMENTO TOTAL
	N_PRCVEN  := 0
	N_QTDVEN  := 0
	N_QTDENT  := 0
	N_SALDO   := 0
	N_SALVLR  := 0
	N_PBRUTO  := 0
	N_QUANT   := 0
	//VARIAVEIS PARA 8-VERIFICAR ESTOQUE
	O_PRCVEN  := 0
	O_QTDVEN  := 0
	O_QTDENT  := 0
	O_SALDO   := 0
	O_SALVLR  := 0
	O_PBRUTO  := 0
	O_QUANT   := 0

	//VARIAVEIS PARA 9-LIBERADO/AGUARDANDO
	I_PRCVEN  := 0
	I_QTDVEN  := 0
	I_QTDENT  := 0
	I_SALDO   := 0
	I_SALVLR  := 0
	I_PBRUTO  := 0
	I_QUANT   := 0

	//vARIAVEIS NÃO DECLARADAS
	P_MEDIA	:= 0
	C_MEDIA	:= 0
	V_MEDIA	:= 0
	R_MEDIA	:= 0
	S_MEDIA	:= 0
	T_MEDIA	:= 0

	MM_MEDIA  			    := 0
	V_QTD_TOTAL_GERAL   := 0
	V_PRECO_TOTAL_GERAL := 0
	V_ATENDIDO_GERAL    := 0
	V_SALDO_GERAL       := 0
	V_SALVLR_GERAL      := 0
	V_PESOBR_GERAL      := 0
	V_MM_MEDIA          := 0

	V_MEDIA_GERAL		 := 0
	V_QUANT_GERAL		 := 0
	V_MM_MEDIA_GERAL := 0

	nVlTran  := 0
	nVlTran1 := 0
	nVlTran2 := 0
	nVlTran3 := 0

	nCont    := 0
	lrOK     := .F.
	lcOK     := .F.

	DbSelectArea("cTrab")
	cTrab->(dbGoTop())

	//Prepara montagem da barra de progresso
	SetRegua(nTotReg)

	While !EOF()

		//Monta barra de progresso
		IncRegua()

		If Interrupcao(@lAbortPrint)
			Return
		Endif

		IF ALLTRIM(cTrab->C5_YCLIORI) = ''
			cNumPed  := cTrab->C5_NUM
		ELSE
			cNumPed  := "*"+cTrab->C5_NUM
		ENDIF

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeeK(xFilial("SA1")+cTrab->CLI_ORIG)
		cCliente := SA1->A1_COD+" - "+SA1->A1_NOME
		cCidade  := ALLTRIM(SA1->A1_MUN) +'/'+SA1->A1_EST

		lPassei := .F.
		IF MV_PAR07 <> '123456789' //Todos os pedidos
			IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
				lPassei := .T.
			ENDIF
			IF lPassei
				DbSelectArea("cTrab")
				DbSkip()
				Loop
			ENDIF
		ENDIF

		//Impressao do cabecalho do relatorio
		If nLin > 55
			titulo		 := "MAPA DE PEDIDO NAO ATENDIDOS"
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Endif

		//CONVERTENDO AS MOEDAS PARA OS PEDIDOS DE EXPORTACAO
		IF ALLTRIM(cTrab->C5_TIPOCLI) <> "X"
			pp_PRCVEN  :=  cTrab->C6_PRCVEN
			ppC6_VALOR :=  cTrab->C6_VALOR
		ELSE														//MADALENO
			pp_PRCVEN  :=  XMOEDA(cTrab->C6_PRCVEN,2,1, ddatabase)	//STOD(cTrab->C5_EMISSAO))	//MADALENO
			ppC6_VALOR :=   XMOEDA(cTrab->C6_VALOR,2,1,ddatabase)	//STOD(cTrab->C5_EMISSAO))	//MADALENO
		ENDIF														//MADALENO

		//Imprime Detalhe
		IF nCont = 0
			DO CASE
			CASE cTrab->C5_YTPTRAN == '1'
				cTpTrans := 'Transportadora'
			CASE cTrab->C5_YTPTRAN == '2'
				cTpTrans := 'Autônomo'
			CASE cTrab->C5_YTPTRAN == '3'
				cTpTrans := 'Cliente Retira'
			OTHERWISE
				cTpTrans := ''
			ENDCASE

			IF MV_PAR23 == 1
				DbSelectArea("DA5")
				DbSeek(xFilial("DA5")+cTrab->ZONA)
				@ nLin, 000 PSay Replicate("_",220)
				nLin := nLin + 1
				@ nLin, 000 PSAY "ZONA: " + cTrab->ZONA + " - " + DA5->DA5_DESC
				nLin := nLin + 2
			ENDIF

			@ nLin, 000 PSAY "TIPO DE TRANSPORTE: " + cTrab->C5_YTPTRAN + " - " + cTpTrans
			nLin := nLin + 2
			@ nLin, 000 PSAY "VENDEDOR: " + cTrab->VENDEDOR
			nLin := nLin + 2
			@ nLin, 000 PSAY "CLIENTE: " + cCliente + " CIDADE/ESTADO: " + cCidade  + " " + ALLTRIM(cTrab->C5_YEND)
			nLin := nLin + 2
		ENDIF

		IF nCont >= 1
			IF ( OldPed <> cNumPed )
				@ nLin, 001  PSAY "Total do pedido"
				@ nLin, 062  PSAY Transform(P_SALVLR/P_SALDO,"@E 999.99")
				@ nLin, 070  PSAY Transform(P_QTDVEN,"@E 999,999.99") //PEDIDO
				@ nLin, 082  PSAY Transform(P_QTDENT,"@E 999,999.99") //ATENDIDO
				@ nLin, 094  PSAY Transform(P_SALDO,  "@E 999,999.99")
				@ nLin, 104  PSAY Transform(P_PBRUTO,  "@E 999,999,999.99")
				@ nLin, 120  PSAY LEFT('TRANSP: '+ ALLTRIM(cTranspAux),30)
				@ nLin, 174  PSAY Transform( MM_MEDIA ,"@E 9999") //MADALENO cTrab->E4_YMEDIA
				nLin := nLin + 2
				P_PRCVEN  := 0
				P_QTDVEN  := 0
				P_VALOR   := 0
				P_QTDENT  := 0
				P_SALDO   := 0
				P_SALVLR  := 0
				P_PBRUTO  := 0
				P_QUANT   := 0
				P_MEDIA   := 0
			ENDIF

			IF ( OldCli <> cCliente )
				@ nLin, 001  PSAY "Total do Cliente"
				@ nLin, 062  PSAY Transform(C_SALVLR/C_SALDO,"@E 999.99")
				@ nLin, 070  PSAY Transform(C_QTDVEN,"@E 999,999.99") //PEDIDO
				@ nLin, 082  PSAY Transform(C_QTDENT,"@E 999,999.99") //ATENDIDO
				@ nLin, 094  PSAY Transform(C_SALDO,  "@E 999,999.99")
				@ nLin, 104  PSAY Transform(C_PBRUTO,  "@E 999,999,999.99")
				@ nLin, 120  PSAY LEFT('TRANSP: '+ ALLTRIM(cTranspAux),30)
				@ nLin, 174  PSAY Transform((C_PRCVEN * MM_MEDIA) / C_PRCVEN ,"@E 9999")
				nLin := nLin + 1
				C_PRCVEN  := 0
				C_QTDVEN  := 0
				C_VALOR   := 0
				C_QTDENT  := 0
				C_SALDO   := 0
				C_SALVLR  := 0
				C_PBRUTO  := 0
				C_QUANT   := 0
				C_MEDIA   := 0
			ENDIF

			IF MV_PAR23 == 1
				IF ( OldVend <> cTrab->VENDEDOR) .OR. ( OldTrans <> cTrab->C5_YTPTRAN) .OR. ( OldZona <> cTrab->ZONA)
					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++
					@ nLin, 001  PSAY "Total do Vendedor"
					@ nLin, 062  PSAY Transform(V_SALVLR/V_SALDO,"@E 999.99")
					@ nLin, 070  PSAY Transform(V_QTDVEN,"@E 999,999.99") //PEDIDO
					@ nLin, 082  PSAY Transform(V_QTDENT,"@E 999,999.99") //ATENDIDO
					@ nLin, 094  PSAY Transform(V_SALDO,  "@E 999,999.99")
					@ nLin, 104  PSAY Transform(V_PBRUTO,  "@E 999,999,999.99")
					@ nLin, 174  PSAY Transform(V_MM_MEDIA / V_QUANT ,"@E 9999")

					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++

					V_QTD_TOTAL_GERAL   += V_QTDVEN
					V_PRECO_TOTAL_GERAL += V_PRCVEN/V_QUANT
					V_ATENDIDO_GERAL    += V_QTDENT
					V_SALDO_GERAL       += V_SALDO
					V_SALVLR_GERAL      += V_SALVLR
					V_PESOBR_GERAL      += V_PBRUTO
					V_MEDIA_GERAL	    	+= V_MEDIA		//RANISSES
					V_QUANT_GERAL		    += V_QUANT		//RANISSES
					V_MM_MEDIA_GERAL	  += V_MM_MEDIA	//RANISSES

					V_PRCVEN   := 0
					V_QTDVEN   := 0
					V_QTDENT   := 0
					V_SALDO    := 0
					V_SALVLR   := 0
					V_PBRUTO   := 0
					V_QUANT    := 0
					V_MEDIA    := 0
					V_MM_MEDIA := 0
				ENDIF

				IF ( OldTrans <>cTrab->C5_YTPTRAN) .OR. ( OldZona <>cTrab->ZONA)
					DO CASE
					CASE OldTrans == '1'
						cTpTrans := 'Transportadora'
					CASE OldTrans == '2'
						cTpTrans := 'Autônomo'
					CASE OldTrans == '3'
						cTpTrans := 'Cliente Retira'
					ENDCASE

					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++
					@ nLin, 001  PSAY "Total Tipo Transporte - " + cTpTrans
					@ nLin, 062  PSAY Transform(T_SALVLR/T_SALDO,"@E 999.99")
					@ nLin, 070  PSAY Transform(T_QTDVEN,"@E 999,999.99") //PEDIDO
					@ nLin, 082  PSAY Transform(T_QTDENT,"@E 999,999.99") //ATENDIDO
					@ nLin, 094  PSAY Transform(T_SALDO,  "@E 999,999.99")
					@ nLin, 104  PSAY Transform(T_PBRUTO,  "@E 999,999,999.99")
					@ nLin, 174  PSAY Transform(T_MM_MEDIA / T_QUANT ,"@E 9999")

					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++

					T_PRCVEN   := 0
					T_QTDVEN   := 0
					T_QTDENT   := 0
					T_SALDO    := 0
					T_SALVLR   := 0
					T_PBRUTO   := 0
					T_QUANT    := 0
					T_MEDIA    := 0
					T_MM_MEDIA := 0
				ENDIF

				IF ( OldZona <> cTrab->ZONA)
					DbSelectArea("DA5")
					DbSeek(xFilial("DA5")+OldZona)
					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++
					@ nLin, 001  PSAY "Total da Zona - " + DA5->DA5_DESC
					@ nLin, 062  PSAY Transform(S_SALVLR/S_SALDO,"@E 999.99")
					@ nLin, 070  PSAY Transform(S_QTDVEN,"@E 999,999.99") //PEDIDO
					@ nLin, 082  PSAY Transform(S_QTDENT,"@E 999,999.99") //ATENDIDO
					@ nLin, 094  PSAY Transform(S_SALDO,  "@E 999,999.99")
					@ nLin, 104  PSAY Transform(S_PBRUTO,  "@E 999,999,999.99")
					@ nLin, 174  PSAY Transform(S_MM_MEDIA / S_QUANT ,"@E 9999")

					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++

					S_PRCVEN   := 0
					S_QTDVEN   := 0
					S_QTDENT   := 0
					S_SALDO    := 0
					S_SALVLR   := 0
					S_PBRUTO   := 0
					S_QUANT    := 0
					S_MEDIA    := 0
					S_MM_MEDIA := 0
				ENDIF
			ELSE
				IF ( OldVend <> cTrab->VENDEDOR) .OR. ( OldTrans <> cTrab->C5_YTPTRAN)
					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++
					@ nLin, 001  PSAY "Total do Vendedor"
					@ nLin, 062  PSAY Transform(V_SALVLR/V_SALDO,"@E 999.99")
					@ nLin, 070  PSAY Transform(V_QTDVEN,"@E 999,999.99") //PEDIDO
					@ nLin, 082  PSAY Transform(V_QTDENT,"@E 999,999.99") //ATENDIDO
					@ nLin, 094  PSAY Transform(V_SALDO,  "@E 999,999.99")
					@ nLin, 104  PSAY Transform(V_PBRUTO,  "@E 999,999,999.99")
					@ nLin, 174  PSAY Transform(V_MM_MEDIA / V_QUANT ,"@E 9999")

					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++

					V_QTD_TOTAL_GERAL   += V_QTDVEN
					V_PRECO_TOTAL_GERAL += V_PRCVEN/V_QUANT
					V_ATENDIDO_GERAL    += V_QTDENT
					V_SALDO_GERAL       += V_SALDO
					V_SALVLR_GERAL      += V_SALVLR
					V_PESOBR_GERAL      += V_PBRUTO
					V_MEDIA_GERAL	    	+= V_MEDIA		//RANISSES
					V_QUANT_GERAL		    += V_QUANT		//RANISSES
					V_MM_MEDIA_GERAL	  += V_MM_MEDIA	//RANISSES

					V_PRCVEN   := 0
					V_QTDVEN   := 0
					V_QTDENT   := 0
					V_SALDO    := 0
					V_SALVLR   := 0
					V_PBRUTO   := 0
					V_QUANT    := 0
					V_MEDIA    := 0
					V_MM_MEDIA := 0
				ENDIF

				IF ( OldTrans <>cTrab->C5_YTPTRAN)
					DO CASE
					CASE OldTrans == '1'
						cTpTrans := 'Transportadora'
					CASE OldTrans == '2'
						cTpTrans := 'Autônomo'
					CASE OldTrans == '3'
						cTpTrans := 'Cliente Retira'
					ENDCASE

					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++
					@ nLin, 001  PSAY "Total Tipo Transporte - " + cTpTrans
					@ nLin, 062  PSAY Transform(T_SALVLR/T_SALDO,"@E 999.99")
					@ nLin, 070  PSAY Transform(T_QTDVEN,"@E 999,999.99") //PEDIDO
					@ nLin, 082  PSAY Transform(T_QTDENT,"@E 999,999.99") //ATENDIDO
					@ nLin, 094  PSAY Transform(T_SALDO,  "@E 999,999.99")
					@ nLin, 104  PSAY Transform(T_PBRUTO,  "@E 999,999,999.99")
					@ nLin, 200  PSAY Transform(T_MM_MEDIA / T_QUANT ,"@E 9999")

					nLin := nLin + 1
					@ nLin, 000 PSay Replicate("_",220)
					nlin++

					T_PRCVEN   := 0
					T_QTDVEN   := 0
					T_QTDENT   := 0
					T_SALDO    := 0
					T_SALVLR   := 0
					T_PBRUTO   := 0
					T_QUANT    := 0
					T_MEDIA    := 0
					T_MM_MEDIA := 0
				ENDIF
			ENDIF

			DO CASE
			CASE cTrab->C5_YTPTRAN == '1'
				cTpTrans := 'Transportadora'
			CASE cTrab->C5_YTPTRAN == '2'
				cTpTrans := 'Autônomo'
			CASE cTrab->C5_YTPTRAN == '3'
				cTpTrans := 'Cliente Retira'
			OTHERWISE
				cTpTrans := ''
			ENDCASE

			IF MV_PAR23 == 1
				IF ( OldZona <> cTrab->ZONA)
					DbSelectArea("DA5")
					DbSeek(xFilial("DA5")+cTrab->ZONA)
					nLin := nLin + 1
					@ nLin, 000 PSAY "ZONA: " + cTrab->ZONA + " - "+ DA5->DA5_DESC
					nLin := nLin + 2
					IF ( OldTrans == cTrab->C5_YTPTRAN)
						@ nLin, 000 PSAY "TIPO DE TRANSPORTE: " + cTrab->C5_YTPTRAN + " - " + cTpTrans
						nLin := nLin + 2
					ENDIF
					IF ( OldVend == cTrab->VENDEDOR) .AND. ( OldTrans == cTrab->C5_YTPTRAN)
						@ nLin, 000 PSAY "VENDEDOR: " + cTrab->VENDEDOR
						nLin := nLin + 2
						lrOK := .T.
					ENDIF
					IF ( OldCli == cCliente) .AND. ( OldTrans == cTrab->C5_YTPTRAN)
						@ nLin, 000 PSAY "CLIENTE: " + cCliente + " CIDADE/ESTADO: " + cCidade + " " + ALLTRIM(cTrab->C5_YEND)
						nLin := nLin + 2
						lcOK := .T.
					ENDIF
				ENDIF
			ENDIF

			IF ( OldTrans <> cTrab->C5_YTPTRAN)
				nLin := nLin + 1
				@ nLin, 000 PSAY "TIPO DE TRANSPORTE: " + cTrab->C5_YTPTRAN + " - " + cTpTrans
				nLin := nLin + 2
				IF ( OldVend == cTrab->VENDEDOR) .AND. !lrOK
					@ nLin, 000 PSAY "VENDEDOR: " + cTrab->VENDEDOR
					nLin := nLin + 2
				ENDIF
				IF ( OldCli == cCliente) .AND. !lcOK
					@ nLin, 000 PSAY "CLIENTE: " + cCliente + " CIDADE/ESTADO: " + cCidade + " " + ALLTRIM(cTrab->C5_YEND)
					nLin := nLin + 2
				ENDIF
			ENDIF

			IF ( OldVend <> cTrab->VENDEDOR)
				nLin := nLin + 1
				@ nLin, 000 PSAY "VENDEDOR: " + cTrab->VENDEDOR
				nLin := nLin + 1
			ENDIF

			IF ( OldCli <> cCliente)
				nLin := nLin + 1
				@ nLin, 000 PSAY "CLIENTE: " + cCliente + " CIDADE/ESTADO: " + cCidade + " " + ALLTRIM(cTrab->C5_YEND)
				nLin := nLin + 2
			ENDIF
		ENDIF

		//Checa se o Lote esta cadastrado na tabela ZZ9
		If xVerLote == .F. .And. SUBST( ALLTRIM(cTrab->LOT), LEN(ALLTRIM(cTrab->LOT)) -2, 3)  == "***"
			xVerLote := .T.
		End If

		//Linha de Detalhe
		@ nLin, 000  PSAY ALLTRIM(cNumPed)
		@ nLin, 008  PSAY STOD(cTrab->C5_EMISSAO)
		@ nLin, 017  PSAY ALLTRIM(cTrab->PRO) + " " + ALLTRIM(cTrab->LOT)
		@ nLin, 033  PSAY SUBSTR(cTrab->B1_DESC,1,28)
		@ nLin, 062  PSAY Transform(pp_PRCVEN,				"@E 999.99")			//MADALENO
		@ nLin, 070  PSAY Transform(cTrab->C6_QTDVEN,"@E 999,999.99") 	//PEDIDO
		@ nLin, 082  PSAY Transform(cTrab->C6_QTDENT,"@E 999,999.99") 	//ATENDIDO
		@ nLin, 094  PSAY Transform(cTrab->SALDO,  		"@E 999,999.99")
		@ nLin, 104  PSAY Transform(cTrab->PBRUTO,  	"@E 999,999,999.99")
		@ nLin, 120  PSAY ALLTRIM(cTrab->OBS)
		@ nLin, 144  PSAY STOD(cTrab->C6_YDTNECE)
		@ nLin, 154  PSAY STOD(cTrab->C6_ENTREG) // 188
		@ nLin, 164  PSAY STOD(cTrab->DTDISPOP) // 188
		@ nLin, 174  PSAY cTrab->CONDPAG         // 201
		@ nLin, 192  PSAY cTrab->EMPRESA         // LOCAL 208
		@ nLin, 202  PSAY cTrab->C5_YPC

		//VARIAVEIS PARA TOTAIS DE PEDIDO
		P_PRCVEN  := P_PRCVEN + pp_PRCVEN
		P_QTDVEN  := P_QTDVEN + cTrab->C6_QTDVEN
		P_VALOR   := P_VALOR  + ppC6_VALOR  //MADALENO

		P_QTDENT := P_QTDENT +cTrab->C6_QTDENT
		P_SALDO  := P_SALDO  +cTrab->SALDO
		P_SALVLR := P_SALVLR +(cTrab->SALDO * pp_PRCVEN)
		P_PBRUTO := P_PBRUTO +cTrab->PBRUTO
		P_QUANT  := P_QUANT  + 1 //Contador
		If cTrab->C5_YRECR == "S"
			P_MEDIA += cTrab->C6_QTDVEN * Round(pp_PRCVEN / cTrab->C5_YFATOR,2) //0.47619,2)
		Else
			P_MEDIA += cTrab->C6_QTDVEN * pp_PRCVEN
		EndIf

		//VARIAVEIS PARA TOTAIS DE CLIENTE
		c_PRCVEN   := c_PRCVEN +pp_PRCVEN
		C_QTDVEN   := C_QTDVEN +cTrab->C6_QTDVEN
		C_VALOR    := C_VALOR + ppC6_VALOR
		C_QTDENT   := C_QTDENT +cTrab->C6_QTDENT
		C_SALDO    := C_SALDO  +cTrab->SALDO
		C_SALVLR   := C_SALVLR +(cTrab->SALDO * pp_PRCVEN)
		C_PBRUTO   := C_PBRUTO +cTrab->PBRUTO
		C_QUANT    := C_QUANT + 1 //Contador

		If cTrab->C5_YRECR == "S"
			C_MEDIA += cTrab->C6_QTDVEN * Round(pp_PRCVEN / cTrab->C5_YFATOR,2) //0.47619,2)
		Else
			C_MEDIA += cTrab->C6_QTDVEN * pp_PRCVEN
		EndIf

		//VARIAVEIS PARA TOTAIS DE VENDEDOR
		V_PRCVEN  := V_PRCVEN +pp_PRCVEN
		V_QTDVEN  := V_QTDVEN +cTrab->C6_QTDVEN
		V_QTDENT  := V_QTDENT +cTrab->C6_QTDENT
		V_SALDO   := V_SALDO  +cTrab->SALDO
		V_SALVLR  := V_SALVLR +(cTrab->SALDO * pp_PRCVEN)
		V_PBRUTO  := V_PBRUTO + cTrab->PBRUTO
		V_QUANT   := V_QUANT  + 1

		If cTrab->C5_YRECR == "S"
			V_MEDIA += cTrab->C6_QTDVEN * Round(pp_PRCVEN / cTrab->C5_YFATOR,2) //0.47619,2)
		Else
			V_MEDIA += cTrab->C6_QTDVEN * pp_PRCVEN
		EndIf

		IF MV_PAR23 == 1
			//VARIAVEIS PARA TOTAIS DA ZONA
			S_PRCVEN  := S_PRCVEN +pp_PRCVEN
			S_QTDVEN  := S_QTDVEN +cTrab->C6_QTDVEN
			S_QTDENT  := S_QTDENT +cTrab->C6_QTDENT
			S_SALDO   := S_SALDO  +cTrab->SALDO
			S_SALVLR  := S_SALVLR +(cTrab->SALDO * pp_PRCVEN)
			S_PBRUTO  := S_PBRUTO + cTrab->PBRUTO
			S_QUANT   := S_QUANT  + 1

			If cTrab->C5_YRECR == "S"
				S_MEDIA += cTrab->C6_QTDVEN * Round(pp_PRCVEN / cTrab->C5_YFATOR,2) //0.47619,2)
			Else
				S_MEDIA += cTrab->C6_QTDVEN * pp_PRCVEN
			EndIf
		ENDIF

		//VARIAVEIS PARA TOTAIS DO TIPO DE TRANSPORTE
		T_PRCVEN  := T_PRCVEN +pp_PRCVEN
		T_QTDVEN  := T_QTDVEN +cTrab->C6_QTDVEN
		T_QTDENT  := T_QTDENT +cTrab->C6_QTDENT
		T_SALDO   := T_SALDO  +cTrab->SALDO
		T_SALVLR  := T_SALVLR +(cTrab->SALDO * pp_PRCVEN)
		T_PBRUTO  := T_PBRUTO + cTrab->PBRUTO
		T_QUANT   := T_QUANT  + 1

		If cTrab->C5_YRECR == "S"
			T_MEDIA += cTrab->C6_QTDVEN * Round(pp_PRCVEN / cTrab->C5_YFATOR,2) //0.47619,2)
		Else
			T_MEDIA += cTrab->C6_QTDVEN * pp_PRCVEN
		EndIf

		//If cEmpAnt == "01"
		If Substr(Alltrim(cTrab->OBS),1,1) == '1' //'1-BLOQUEIO/PREÇO'			//VARIAVEIS PARA TOTAIS
			R_PRCVEN  := R_PRCVEN +pp_PRCVEN
			R_QTDVEN  := R_QTDVEN +cTrab->C6_QTDVEN
			R_QTDENT  := R_QTDENT +cTrab->C6_QTDENT
			R_SALDO   := R_SALDO  +cTrab->SALDO
			R_SALVLR  := R_SALVLR +(cTrab->SALDO * pp_PRCVEN)
			R_PBRUTO  := R_PBRUTO +cTrab->PBRUTO
			R_QUANT   := R_QUANT  +1

			If cTrab->C5_YRECR == "S"
				R_MEDIA += cTrab->C6_QTDVEN * Round(pp_PRCVEN / cTrab->C5_YFATOR,2) //0.47619,2)
			Else
				R_MEDIA += cTrab->C6_QTDVEN * pp_PRCVEN
			EndIf

		ElseIf Substr(Alltrim(cTrab->OBS),1,1) == '2' //'2-CREDITO'				//VARIAVEIS PARA TOTAIS
			E_PRCVEN  := E_PRCVEN +pp_PRCVEN
			E_QTDVEN  := E_QTDVEN +cTrab->C6_QTDVEN
			E_QTDENT  := E_QTDENT +cTrab->C6_QTDENT
			E_SALDO   := E_SALDO  +cTrab->SALDO
			E_SALVLR  := E_SALVLR +(cTrab->SALDO * pp_PRCVEN)
			E_PBRUTO  := E_PBRUTO +cTrab->PBRUTO
			E_QUANT   := E_QUANT  +1

		ElseIf Substr(Alltrim(cTrab->OBS),1,1)  == '3' //'3-ESTOQUE DISP./CREDITO'		//VARIAVEIS PARA TOTAIS
			G_PRCVEN  := G_PRCVEN +pp_PRCVEN
			G_QTDVEN  := G_QTDVEN +cTrab->C6_QTDVEN
			G_QTDENT  := G_QTDENT +cTrab->C6_QTDENT
			G_SALDO   := G_SALDO  +cTrab->SALDO
			G_SALVLR  := G_SALVLR +(cTrab->SALDO * pp_PRCVEN)
			G_PBRUTO  := G_PBRUTO +cTrab->PBRUTO
			G_QUANT   := G_QUANT  +1

		ElseIf Substr(Alltrim(cTrab->OBS),1,1) == '4' //'4-ESTOQUE DISP. PARCIAL'		//VARIAVEIS PARA TOTAIS
			Z_PRCVEN  := Z_PRCVEN +pp_PRCVEN
			Z_QTDVEN  := Z_QTDVEN +cTrab->C6_QTDVEN
			Z_QTDENT  := Z_QTDENT +cTrab->C6_QTDENT
			Z_SALDO   := Z_SALDO  +cTrab->SALDO
			Z_SALVLR  := Z_SALVLR +(cTrab->SALDO * pp_PRCVEN)
			Z_PBRUTO  := Z_PBRUTO +cTrab->PBRUTO
			Z_QUANT   := Z_QUANT  +1

		ElseIf Substr(Alltrim(cTrab->OBS),1,1) == '5' //'5-ESTOQUE DISP. TOTAL'		//VARIAVEIS PARA TOTAIS
			Q_PRCVEN  := Q_PRCVEN + pp_PRCVEN
			Q_QTDVEN  := Q_QTDVEN + cTrab->C6_QTDVEN
			Q_QTDENT  := Q_QTDENT + cTrab->C6_QTDENT
			Q_SALDO   := Q_SALDO  + cTrab->SALDO
			Q_SALVLR  := Q_SALVLR + (cTrab->SALDO * pp_PRCVEN)
			Q_PBRUTO  := Q_PBRUTO + cTrab->PBRUTO
			Q_QUANT   := Q_QUANT  + 1

		ElseIf Substr(Alltrim(cTrab->OBS),1,1) == '6' //'6-EM CARREGAMENTO PARCIAL'		//VARIAVEIS PARA TOTAIS
			M_PRCVEN  := M_PRCVEN +pp_PRCVEN
			M_QTDVEN  := M_QTDVEN +cTrab->C6_QTDVEN
			M_QTDENT  := M_QTDENT +cTrab->C6_QTDENT
			M_SALDO   := M_SALDO  +cTrab->SALDO
			M_SALVLR  := M_SALVLR +(cTrab->SALDO * pp_PRCVEN)
			M_PBRUTO  := M_PBRUTO +cTrab->PBRUTO
			M_QUANT   := M_QUANT  +1

		ElseIf Substr(Alltrim(cTrab->OBS),1,1) == '7' //'7-EM CARREGAMENTO TOTAL'		//VARIAVEIS PARA TOTAIS
			N_PRCVEN  := N_PRCVEN +pp_PRCVEN
			N_QTDVEN  := N_QTDVEN +cTrab->C6_QTDVEN
			N_QTDENT  := N_QTDENT +cTrab->C6_QTDENT
			N_SALDO   := N_SALDO  +cTrab->SALDO
			N_SALVLR  := N_SALVLR +(cTrab->SALDO * pp_PRCVEN)
			N_PBRUTO  := N_PBRUTO +cTrab->PBRUTO
			N_QUANT   := N_QUANT  +1

		ElseIf Substr(Alltrim(cTrab->OBS),1,1) == '9' //'9-LIBERADO/AGUARDANDO RA' //VARIAVEIS PARA TOTAIS
			I_PRCVEN  := I_PRCVEN + pp_PRCVEN
			I_QTDVEN  := I_QTDVEN + cTrab->C6_QTDVEN
			I_QTDENT  := I_QTDENT + cTrab->C6_QTDENT
			I_SALDO   := I_SALDO  + cTrab->SALDO
			I_SALVLR  := I_SALVLR + (cTrab->SALDO * pp_PRCVEN)
			I_PBRUTO  := I_PBRUTO + cTrab->PBRUTO
			I_QUANT   := I_QUANT  + 1

		ElseIf Substr(Alltrim(cTrab->OBS),1,1) == '8' //'8-VERIFICAR ESTOQUE'		//VARIAVEIS PARA TOTAIS
			O_PRCVEN  := O_PRCVEN + pp_PRCVEN
			O_QTDVEN  := O_QTDVEN + cTrab->C6_QTDVEN
			O_QTDENT  := O_QTDENT + cTrab->C6_QTDENT
			O_SALDO   := O_SALDO  + cTrab->SALDO
			O_SALVLR  := O_SALVLR + (cTrab->SALDO * pp_PRCVEN)
			O_PBRUTO  := O_PBRUTO + cTrab->PBRUTO
			O_QUANT   := O_QUANT  + 1

		EndIf

		//Armazena Valores Por Segmento
		dbSelectArea("_Segmento")
		dbSetOrder(1)
		If dbSeek(cTrab->SEGMENTO)
			RecLock("_Segmento",.F.)
			_Segmento->PRCVEN	:= _Segmento->PRCVEN + pp_PRCVEN
			_Segmento->QTDVEN	:= _Segmento->QTDVEN + cTrab->C6_QTDVEN
			_Segmento->QTDENT	:= _Segmento->QTDENT + cTrab->C6_QTDENT
			_Segmento->SALDO	:= _Segmento->SALDO  + cTrab->SALDO
			_Segmento->SALVLR	:= _Segmento->SALVLR + cTrab->(cTrab->SALDO * pp_PRCVEN)
			_Segmento->PBRUTO	:= _Segmento->PBRUTO + cTrab->PBRUTO
			_Segmento->QUANT	:= _Segmento->QUANT  + 1
		Else
			RecLock("_Segmento",.T.)
			_Segmento->SEG		:= cTrab->SEGMENTO
			_Segmento->PRCVEN	:= pp_PRCVEN
			_Segmento->QTDVEN	:= cTrab->C6_QTDVEN
			_Segmento->QTDENT	:= cTrab->C6_QTDENT
			_Segmento->SALDO	:= cTrab->SALDO
			_Segmento->SALVLR	:= cTrab->(cTrab->SALDO * pp_PRCVEN)
			_Segmento->PBRUTO	:= cTrab->PBRUTO
			_Segmento->QUANT	:= 1
		EndIf
		msUnLock()

		c001 := " 	SELECT COUNT(*) AS TOTREG					"
		c001 += " 	FROM	"+RetSqlName("SC9")+" WITH (NOLOCK) "
		c001 += " 	WHERE	C9_FILIAL = '"+xFilial('SC6')+"' AND		"
		c001 += " 				C9_AGREG		<> ''			AND			"
		c001 += " 			  C9_PEDIDO	  = '"+cTrab->C5_NUM+"'		AND			"
		c001 += " 	 			C9_PRODUTO	= '"+cTrab->C6_PRODUTO+"' AND		"
		c001 += " 	 			C9_ITEM	   	= '"+cTrab->C6_ITEM+"'	AND			"
		c001 += " 	 			C9_LOTECTL	= '"+cTrab->C6_LOTECTL+"'	AND		"
		c001 += " 	 			C9_BLEST	  = ''	AND			"
		c001 += " 	 			C9_BLCRED	  = ''	AND			"
		c001 += " 	 			D_E_L_E_T_	= ''		"
		IF chkfile("cTRB")
			dbSelectArea("cTRB")
			dbCloseArea()
		ENDIF

		TCQUERY c001 ALIAS "cTRB" NEW

		IF cTRB->TOTREG >= 1
			DO CASE
			CASE cTrab->C5_YTPTRAN == '1'
				cTpTrans := 'Transportadora'
				nVlTran1 := nVlTran1 + cTrab->PBRUTO
			CASE cTrab->C5_YTPTRAN == '2'
				cTpTrans := 'Autônomo'
				nVlTran2 := nVlTran2 + cTrab->PBRUTO
			CASE cTrab->C5_YTPTRAN == '3'
				cTpTrans := 'Cliente Retira'
				nVlTran3 := nVlTran3 + cTrab->PBRUTO
			OTHERWISE
				cTpTrans := ''
				nVlTran  := nVlTran  + cTrab->PBRUTO
			ENDCASE
		ENDIF

		nLin := nLin + 1

		OldPed   := cNumPed
		OldCli   := cCliente
		OldVend  := cTrab->VENDEDOR
		OldTrans := cTrab->C5_YTPTRAN
		cTranspAux := cTrab->TRANSP

		IF MV_PAR23 == 1
			OldZona  := cTrab->ZONA
		ENDIF

		DbSelectArea("cTrab")
		MM_MEDIA   := cTrab->E4_YMEDIA
		V_MM_MEDIA += cTrab->E4_YMEDIA
		S_MM_MEDIA += cTrab->E4_YMEDIA


		dbSkip()
		nCont := nCont + 1
		lrOK  := .F.
		lcOK  := .F.
	End

	nLin := nLin + 1
	@ nLin, 001  PSAY "Total do pedido"
	@ nLin, 062  PSAY Transform(P_SALVLR/P_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(P_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(P_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(P_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(P_PBRUTO,  "@E 999,999,999.99")
	@ nLin, 120  PSAY LEFT('TRANSP: '+ ALLTRIM(cTranspAux),30)
	@ nLin, 174  PSAY Transform((P_PRCVEN * MM_MEDIA) / P_PRCVEN ,"@E 9999") //MADALENO
	nLin := nLin + 1

	//Impressao do cabecalho do relatorio
	If nLin > 55
		titulo		 := "MAPA DE PEDIDO NAO ATENDIDOS"
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	nLin := nLin + 1
	@ nLin, 001  PSAY "Total do Cliente"
	@ nLin, 062  PSAY Transform(C_SALVLR/C_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(C_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(C_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(C_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(C_PBRUTO,  "@E 999,999,999.99")
	@ nLin, 120  PSAY LEFT('TRANSP: '+ ALLTRIM(cTranspAux),30)
	@ nLin, 174  PSAY Transform((C_PRCVEN * MM_MEDIA) / C_PRCVEN ,"@E 9999")
	nLin := nLin + 1

	//Impressao do cabecalho do relatorio
	If nLin > 55
		titulo		 := "MAPA DE PEDIDO NAO ATENDIDOS"
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	V_QTD_TOTAL_GERAL   += V_QTDVEN
	V_PRECO_TOTAL_GERAL += V_PRCVEN/V_QUANT
	V_ATENDIDO_GERAL    += V_QTDENT
	V_SALDO_GERAL       += V_SALDO
	V_SALVLR_GERAL      += V_SALVLR
	V_PESOBR_GERAL      += V_PBRUTO
	V_MEDIA_GERAL		    += V_MEDIA		//RANISSES
	V_QUANT_GERAL		    += V_QUANT		//RANISSES
	V_MM_MEDIA_GERAL	  += V_MM_MEDIA	//RANISSES

	@ nLin, 000 PSay Replicate("_",220)
	nLin := nLin + 1
	@ nLin, 001  PSAY "Total do Vendedor"
	@ nLin, 062  PSAY Transform(V_SALVLR/V_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(V_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(V_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(V_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(V_PBRUTO,  "@E 999,999,999.99")
	@ nLin, 174  PSAY Transform(V_MM_MEDIA / V_QUANT ,"@E 9999")

	@ nLin, 000 PSay Replicate("_",220)
	nLin := nLin + 1

	DO CASE
	CASE OldTrans == '1'
		cTpTrans := 'Transportadora'
	CASE OldTrans == '2'
		cTpTrans := 'Autônomo'
	CASE OldTrans == '3'
		cTpTrans := 'Cliente Retira'
	OTHERWISE
		cTpTrans := ''
	ENDCASE

	nLin := nLin + 1
	@ nLin, 000 PSay Replicate("_",220)
	nlin++
	@ nLin, 001  PSAY "Total Tipo Transporte - " + cTpTrans
	@ nLin, 062  PSAY Transform(T_SALVLR/T_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(T_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(T_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(T_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(T_PBRUTO,  "@E 999,999,999.99")
	@ nLin, 174  PSAY Transform(T_MM_MEDIA / T_QUANT ,"@E 9999")

	nLin := nLin + 1
	@ nLin, 000 PSay Replicate("_",220)
	nLin := nLin + 1

	IF MV_PAR23 == 1
		@ nLin, 000 PSay Replicate("_",220)
		nLin := nLin + 1
		DbSelectArea("DA5")
		DbSeek(xFilial("DA5")+OldZona)
		@ nLin, 001  PSAY "Total da Zona" + DA5->DA5_DESC
		@ nLin, 062  PSAY Transform(S_SALVLR/S_SALDO,"@E 999.99")
		@ nLin, 070  PSAY Transform(S_QTDVEN,"@E 999,999.99") //PEDIDO
		@ nLin, 082  PSAY Transform(S_QTDENT,"@E 999,999.99") //ATENDIDO
		@ nLin, 094  PSAY Transform(S_SALDO,  "@E 999,999.99")
		@ nLin, 104  PSAY Transform(S_PBRUTO,  "@E 999,999,999.99")
		@ nLin, 174  PSAY Transform(S_MM_MEDIA / S_QUANT ,"@E 9999")
		nLin := nLin + 1
		@ nLin, 000 PSay Replicate("_",220)
		nLin := nLin + 1
	ENDIF

	@ nLin, 001   PSAY "TOTAL GERAL"
	@ nLin, 062   PSAY Transform(V_SALVLR_GERAL/V_SALDO_GERAL,"@E 999.99")
	@ nLin, 070   PSAY Transform(V_QTD_TOTAL_GERAL,"@E 999,999.99")
	@ nLin, 082   PSAY Transform(V_ATENDIDO_GERAL,"@E 999,999.99")
	@ nLin, 094   PSAY Transform(V_SALDO_GERAL,"@E 999,999.99")
	@ nLin, 104   PSAY Transform(V_PESOBR_GERAL,"@E 999,999,999.99")
	@ nLin, 174  PSAY Transform(V_MM_MEDIA_GERAL / V_QUANT_GERAL ,"@E 9999") //RANISSES

	nLin := nLin + 1
	@ nLin, 000 PSay Replicate("_",220)

	//Impressao do cabecalho do relatorio
	If nLin > 53
		titulo		 := "MAPA DE PEDIDO NAO ATENDIDOS"
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9
	Endif

	nLin := nLin + 1

	@ nLin, 001   PSAY "Total Tipo de Transporte: "+Transform(nVlTran1+nVlTran2+nVlTran3+nVlTran,"@E 9,999,999.99")
	nLin := nLin + 1
	@ nLin, 001   PSAY "Transportadora: "+Transform(nVlTran1,"@E 9,999,999.99")
	nLin := nLin + 1
	@ nLin, 001   PSAY "Autônomo:       "+Transform(nVlTran2,"@E 9,999,999.99")
	nLin := nLin + 1
	@ nLin, 001   PSAY "Cliente Retira: "+Transform(nVlTran3,"@E 9,999,999.99")
	nLin := nLin + 1
	@ nLin, 001   PSAY "Em Branco:      "+Transform(nVlTran,"@E 9,999,999.99")
	nLin := nLin + 1
	@ nLin, 000 PSay Replicate("_",220)

	nLin := nLin + 1

	//Imprime  Totais do ultimo registro e Total Geral
	@ nLin, 000 PSay Replicate("_",220)
	nlin++

	@ nLin, 001  PSAY "Total 1-Bloqueio/Preço "
	@ nLin, 062  PSAY Transform(R_SALVLR/R_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(R_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(R_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(R_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(R_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 001  PSAY "Total 2-Credito "
	@ nLin, 062  PSAY Transform(E_SALVLR/E_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(E_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(E_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(E_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(E_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 001  PSAY "Total 3-Estoque Disp./Credito "
	@ nLin, 062  PSAY Transform(G_SALVLR/G_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(G_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(G_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(G_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(G_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 001  PSAY "Total 4-Estoque Disp. Parcial"
	@ nLin, 062  PSAY Transform(Z_SALVLR/Z_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(Z_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(Z_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(Z_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(Z_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 001  PSAY "Total 5-Estoque Disp. Total"
	@ nLin, 062  PSAY Transform(Q_SALVLR/Q_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(Q_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(Q_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(Q_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(Q_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 001  PSAY "Total 6-Em Carregamento Parcial "
	@ nLin, 062  PSAY Transform(M_SALVLR/M_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(M_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(M_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(M_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(M_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 001  PSAY "Total 7-Em Carregamento Total "
	@ nLin, 062  PSAY Transform(N_SALVLR/N_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(N_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(N_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(N_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(N_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 001  PSAY "Total 8-Verificar Estoque "
	@ nLin, 062  PSAY Transform(O_SALVLR/O_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(O_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(O_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(O_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(O_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 001  PSAY "Total 9-Liberado/Aguardando RA "
	@ nLin, 062  PSAY Transform(I_SALVLR/I_SALDO,"@E 999.99")
	@ nLin, 070  PSAY Transform(I_QTDVEN,"@E 999,999.99") //PEDIDO
	@ nLin, 082  PSAY Transform(I_QTDENT,"@E 999,999.99") //ATENDIDO
	@ nLin, 094  PSAY Transform(I_SALDO,  "@E 999,999.99")
	@ nLin, 104  PSAY Transform(I_PBRUTO,  "@E 999,999,999.99")

	nlin++
	@ nLin, 000 PSay Replicate("_",220)

	//Imprime Totais por Segmento
	nlin++
	dbSelectArea("_Segmento")
	dbGoTop()
	While !eof()
		@ nLin, 001  PSAY "Total Segmento " + _Segmento->SEG
		@ nLin, 062  PSAY Transform(_Segmento->SALVLR/_Segmento->SALDO,"@E 999.99")
		@ nLin, 070  PSAY Transform(_Segmento->QTDVEN,"@E 999,999.99")
		@ nLin, 082  PSAY Transform(_Segmento->QTDENT,"@E 999,999.99")
		@ nLin, 094  PSAY Transform(_Segmento->SALDO,"@E 999,999.99")
		@ nLin, 104  PSAY Transform(_Segmento->PBRUTO,"@E 999,999,999.99")
		nlin++
		dbSkip()
	End
	@ nLin, 000 PSay Replicate("_",220)

	//Imprime Observacao para verificacao do Lote
	If xVerLote
		nlin++
		@ nLin, 001 PSAY "Favor verificar lotes com ***, pois não estão cadastrados na Tabela de Lotes do Produto!"
	End If

	If chkfile("_Segmento")
		dbSelectArea("_Segmento")
		dbCloseArea()
	EndIf

	//Finaliza a execucao do relatorio
	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(NomeProg)
	Endif

	cTrab->(DbCloseArea())

	MS_FLUSH()

Return

/*/{Protheus.doc} Monta_Arq
@description Finaliza digitacao da Selecao de Vendedores
@since 25/01/2018
@version 1.0
@type function
/*/
Static Function fFinaliza()

	Local nI

	//Repassa os codigos digitados para uma array.
	aVend := {}
	do while len(cVend) > 0
		nPosC := at(";",cVend)
		if nPosC > 0
			cString := substr(cVend,1,nPosC-1)
		else
			cString := substr(cVend,1)
		endif

		//Remove carcteres especiais do codigo.
		cVendedor := cString
		nI    := 1
		do while .T.
			cAux := substr(cVendedor,nI,1)
			if ((Asc(cAux) < 32) .OR. (Asc(cAux) > 126)) .AND. (len(cVendedor) > 0)
				cVendedor := strtran(cVendedor,cAux,"")
				Loop
			else
				nI := nI + 1
			endif
			if nI >= len(cVendedor)
				Exit
			endif
		enddo
		cVendedor := Upper(Alltrim(cVendedor))

		if !empty(cVendedor) .AND. (ASCAN(aVend,cVendedor) == 0)
			AADD(aVend,cVendedor)
		endif

		cVend := substr(cVend,len(cString)+2)
	enddo

	//Repassa os codigos da array para uma variavel texto.
	asort(aVend)
	cVend := ""
	for nI := 1 to len(aVend)
		cVend := cVend + "'" + aVend[nI] + "'" + iif(nI<len(aVend),",","")
	next

	lOk := .F.
	Close(oDialog)

Return

/*/{Protheus.doc} BIA789_2
@description Exportar relatorio para excel
@version 1.0
@type function
/*/
User Function BIA789_2()

	Local oReport

	oReport:= ReportDef()
	oReport:PrintDialog()

Return NIL

/*/{Protheus.doc} BIA789_2
@description Montagem do relatorio
@version 1.0
@type function
/*/
Static Function ReportDef()
	Local oReport
	Local oSection1
	Local cTitle    := "MAPA DE PEDIDO NAO ATENDIDOS"
	Local cQryRel   := ""

	oReport:= TReport():New("BIA789",cTitle,, {|oReport| ReportPrint(oReport)},cTitle)
	oReport:SetLandscape() 	//Define a orientacao de pagina do relatorio como paisagem.
	Pergunte(oReport:GetParam(),.F.)

	//DEFINICAO DE FONTES
	Private oFont1	 := TFont():New( "Arial"/*<cName>*/, 8 /*<nWidth>*/, -8/*<nHeight>*/, /*<.from.>*/, .T./*[<.bold.>]*/, /*<nEscapement>*/, , /*<nWeight>*/, /*[<.italic.>]*/, /*[<.underline.>]*/,,,,,, /*[<oDevice>]*/ )

	oSection1 := TRSection():New(oReport,cTitle,{},/*Ordem*/)
	oSection1:SetHeaderPage()

	TRCell():New(oSection1,'GERAFIM' 	  	,,'Gera Fin?'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'C5_YPC'         ,,'Pedido de Compra'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'VENDEDOR'		,,'Vendedor'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'CLIENTE' 		,,'Cliente'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'CLI_TRANSP'	   	,,'Cli x Transp'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'CIDADE'		   	,,'Cidade'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'ESTADO'		   	,,'UF'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'ROTA'		 	,,'Rota'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'PEDIDO'   		,,'Pedido'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'DT_EMISSAO'		,,'Emissao'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'COD_PROD'   	,,'Codigo'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'LOTE'	 		,,'Lote'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection1,'CLASSE'	 	  	,,'Classe'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'PRODUTO'	 	,,'Produto'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection1,'MARCA'	 	  	,,'Marca'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'PACOTE'	 	  	,,'Pacote'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'PM'		 	  	,,'Pm'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'RS'		 	  	,,'R$'/*Titulo*/,"@E 999,999,999.99"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'QTDE_SALDO' 	,,'M2'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'KG'		 	  	,,'Kg'/*Titulo*/,"@E 999,999,999.99"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'PESO_MEDIO'	  	,,'Peso Médio'/*Titulo*/,"@E 999,999,999.99"/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'SITUACAO' 	  	,,'Situacao'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'SAS'	 	  	,,'Sas'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	//fernando em 20/01 - colunas para o Layout para Representantes.
	TRCell():New(oSection1,'PRECO_UNIT'	  	,,'Preço Unitário'/*Titulo*/,"@E 999,999,999.99",/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'QTD_ORI'	  	,,'Qtd.Original'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'QTD_FAT'	  	,,'Qtd.Faturada'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'QTD_A_FAT'	  	,,'Saldo a Faturar'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	//Fernando em 07/01 - M2 Liberado deveria ser esta coluna?
	TRCell():New(oSection1,'QTDEMP'	 	  	,,'M2 Empenhado'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	//fernando em 20/01 - colunas para o Layout para Representantes.
	TRCell():New(oSection1,'PESO_BR'	  	,,'Peso Bruto'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection1,'MOTIV2'	 	  	,,'Motiv2'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'M2_LIB'		 	,,'M2 Liberado'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'KG_LIB'		  	,,'Kg Liberado'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'M2_SEM_EMPENHO'	,,'M2 Sem Empenho'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'KG_SEM_EMPENHO'	,,'Kg Sem Empenho'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'M2_BLOQUEADO'	,,'M2 Bloqueado'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'KG_BLOQUEADO'	,,'Kg Bloqueado'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'RS_LIBERADO'	,,'R$ Liberado'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'RS_SEM_EMPENHO'	,,'R$ Sem Empenho'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'RS_BLOQUEADO'	,,'R$ Bloqueado'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'TRANSPORTADORA'	,,'Transportadora'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'TRANSP_ORC'		,,'Transp.Orcam.'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'DT_ENTREGA'		,,'Dt Prev. Inicial'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'DT_NECESSI'		,,'Dt Neces. Engen.'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'DT_NEC_CLI'		,,'Dt Neces. Cliente'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'DT_DISPOP'		,,'Dt Disp. OP'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'DT_EMPENHO'		,,'Dt Empenho'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'ASSISTENTE'		,,'Assistente de Venda'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'EST_ENTREGA'	,,'Est. Entrega'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'MUN_ENTREGA'	,,'Mun. Entrega'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'BAI_ENTREGA'	,,'Bairro Entrega'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'END_ENTREGA'	,,'Endereco Entrega'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//TRCell():New(oSection1,'CEP_ENTREGA'	,,'Cep Entrega'/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'FORNO'			,,'Forno',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'FORMATO'		,,'Formato',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'TIPO_PED'		,,'Tipo Pedido',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'CONDPAG'		,,'Cond. Pag',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'GRP_CLI'		,,'Cod. Grp. Cliente',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'TP_SEG'			,,'Tipo Segmento',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'DIAS_EMP'		,,'Dias de Empenho',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'ITEM_PED'		,,'Item do Pedido',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,'CATEGORIA'		,,'Categoria',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)


	oSection1:Cell('GERAFIM'    	):oFontBody := oFont1
	oSection1:Cell('C5_YPC'    		):oFontBody := oFont1
	oSection1:Cell('VENDEDOR'   	):oFontBody := oFont1
	oSection1:Cell('CLIENTE'  		):oFontBody := oFont1
	//oSection1:Cell('CLI_TRANSP'   	):oFontBody := oFont1
	oSection1:Cell('CIDADE'	    	):oFontBody := oFont1
	oSection1:Cell('ESTADO'		  	):oFontBody := oFont1
	//oSection1:Cell('ROTA'		 	):oFontBody := oFont1
	oSection1:Cell('PEDIDO' 		):oFontBody := oFont1
	oSection1:Cell('DT_EMISSAO'    	):oFontBody := oFont1
	oSection1:Cell('COD_PROD'   	):oFontBody := oFont1
	oSection1:Cell('LOTE'	    	):oFontBody := oFont1

	oSection1:Cell('CLASSE'		  	):oFontBody := oFont1
	oSection1:Cell('PRODUTO'    	):oFontBody := oFont1

	oSection1:Cell('MARCA'	  		):oFontBody := oFont1
	oSection1:Cell('PACOTE'		 	):oFontBody := oFont1
	oSection1:Cell('PM'		 		):oFontBody := oFont1
	oSection1:Cell('RS'    			):oFontBody := oFont1
	oSection1:Cell('QTDE_SALDO'		):oFontBody := oFont1
	oSection1:Cell('KG'			  	):oFontBody := oFont1
	oSection1:Cell('SITUACAO'	  	):oFontBody := oFont1
	//oSection1:Cell('SAS'		  	):oFontBody := oFont1
	oSection1:Cell('QTDEMP'		  	):oFontBody := oFont1
	oSection1:Cell('MOTIV2'		  	):oFontBody := oFont1
	oSection1:Cell('M2_LIB'		  	):oFontBody := oFont1
	oSection1:Cell('KG_LIB'		  	):oFontBody := oFont1
	oSection1:Cell('M2_SEM_EMPENHO'	):oFontBody := oFont1
	oSection1:Cell('KG_SEM_EMPENHO'	):oFontBody := oFont1
	oSection1:Cell('M2_BLOQUEADO'  	):oFontBody := oFont1
	oSection1:Cell('KG_BLOQUEADO'  	):oFontBody := oFont1
	oSection1:Cell('RS_LIBERADO'  	):oFontBody := oFont1
	oSection1:Cell('RS_SEM_EMPENHO'	):oFontBody := oFont1
	oSection1:Cell('RS_BLOQUEADO'  	):oFontBody := oFont1
	oSection1:Cell('TRANSPORTADORA'	):oFontBody := oFont1
	oSection1:Cell('TRANSP_ORC'		):oFontBody := oFont1
	oSection1:Cell('DT_ENTREGA'  	):oFontBody := oFont1
	oSection1:Cell('DT_NECESSI'  	):oFontBody := oFont1
	oSection1:Cell('DT_NEC_CLI'  	):oFontBody := oFont1
	oSection1:Cell('DT_DISPOP'  	):oFontBody := oFont1
	oSection1:Cell('DT_EMPENHO'  	):oFontBody := oFont1
	oSection1:Cell('ASSISTENTE'  	):oFontBody := oFont1
	//oSection1:Cell('EST_ENTREGA'  	):oFontBody := oFont1
	//oSection1:Cell('MUN_ENTREGA'  	):oFontBody := oFont1
	//oSection1:Cell('BAI_ENTREGA'  	):oFontBody := oFont1
	//oSection1:Cell('END_ENTREGA'  	):oFontBody := oFont1
	//oSection1:Cell('CEP_ENTREGA'  	):oFontBody := oFont1
	oSection1:Cell('FORNO'	  		):oFontBody := oFont1
	oSection1:Cell('FORMATO'	  	):oFontBody := oFont1
	oSection1:Cell('TIPO_PED'	  	):oFontBody := oFont1
	oSection1:Cell('CONDPAG'	  	):oFontBody := oFont1
	oSection1:Cell('GRP_CLI'	  	):oFontBody := oFont1
	oSection1:Cell('TP_SEG'	  		):oFontBody := oFont1
	oSection1:Cell('DIAS_EMP'	  	):oFontBody := oFont1
	oSection1:Cell('ITEM_PED'	  	):oFontBody := oFont1
	oSection1:Cell('CATEGORIA'	  	):oFontBody := oFont1


	//fernando em 20/01 - colunas para o Layout para Representantes.
	oSection1:Cell('QTD_ORI'	  	):oFontBody := oFont1
	oSection1:Cell('QTD_FAT'	  	):oFontBody := oFont1
	oSection1:Cell('QTD_A_FAT'  	):oFontBody := oFont1
	oSection1:Cell('PESO_BR'	  	):oFontBody := oFont1
	oSection1:Cell('PRECO_UNIT'	  	):oFontBody := oFont1

Return(oReport)


/*/{Protheus.doc} ReportPrint
@description Impressao Excel
/*/
Static Function ReportPrint(oReport)

	Local oSection1   := oReport:Section(1)

	Local cDuplicata:= ''
	Local cClasse
	Local cLinha
	Local nValor
	Local cPacote
	Local cSitua
	Local nMotiv2
	Local dDtEmp
	Local cDescCli
	Local cLinSeq 		:= ''


	//fernando em 20/01 - Layout da planilha para representantes - Desabilitar qualquer coluna nova que seja criada.
	IF MV_PAR26 == 2

		oSection1:Cell('GERAFIM'    	):Disable()
		//oSection1:Cell('CLI_TRANSP'   	):Disable()
		oSection1:Cell('CIDADE'	    	):Disable()
		oSection1:Cell('ESTADO'		  	):Disable()
		//oSection1:Cell('ROTA'		 	):Disable()
		oSection1:Cell('CLASSE'		  	):Disable()
		oSection1:Cell('MARCA'	  		):Disable()
		oSection1:Cell('PACOTE'		 	):Disable()
		oSection1:Cell('PM'		 		):Disable()
		oSection1:Cell('RS'    			):Disable()
		oSection1:Cell('KG'    			):Disable()
		oSection1:Cell('PESO_MEDIO'		):Disable()
		oSection1:Cell('QTDE_SALDO'		):Disable()
		//oSection1:Cell('SAS'		  	):Disable()
		oSection1:Cell('MOTIV2'		  	):Disable()
		oSection1:Cell('M2_LIB'		  	):Disable()
		oSection1:Cell('KG_LIB'		  	):Disable()
		oSection1:Cell('M2_SEM_EMPENHO'	):Disable()
		oSection1:Cell('KG_SEM_EMPENHO'	):Disable()
		oSection1:Cell('M2_BLOQUEADO'  	):Disable()
		oSection1:Cell('KG_BLOQUEADO'  	):Disable()
		oSection1:Cell('RS_LIBERADO'  	):Disable()
		oSection1:Cell('RS_SEM_EMPENHO'	):Disable()
		oSection1:Cell('RS_BLOQUEADO'  	):Disable()
		oSection1:Cell('TRANSP_ORC'		):Disable()
		oSection1:Cell('ASSISTENTE'  	):Disable()
		//oSection1:Cell('EST_ENTREGA'  	):Disable()
		//oSection1:Cell('MUN_ENTREGA'  	):Disable()
		//oSection1:Cell('BAI_ENTREGA'  	):Disable()
		//oSection1:Cell('END_ENTREGA'  	):Disable()
		//oSection1:Cell('CEP_ENTREGA'  	):Disable()
		//oSection1:Cell('CONDPAG'	  	):Disable()

		oSection1:Cell('FORNO'	  		):Disable()
		oSection1:Cell('FORMATO'	  	):Disable()
		oSection1:Cell('TIPO_PED'	  	):Disable()
		oSection1:Cell('CONDPAG'	  	):Disable()
		oSection1:Cell('GRP_CLI'	  	):Disable()
		oSection1:Cell('TP_SEG'	  		):Disable()
		//oSection1:Cell('DIAS_EMP'	  	):Disable()
		oSection1:Cell('ITEM_PED'	  	):Disable()
		oSection1:Cell('CATEGORIA'	  	):Disable()



	ELSE

		oSection1:Cell('QTD_ORI'	  	):Disable()
		oSection1:Cell('QTD_FAT'	  	):Disable()
		oSection1:Cell('QTD_A_FAT'  	):Disable()
		oSection1:Cell('PESO_BR'	  	):Disable()

	ENDIF

	dbSelectArea("CTRAB")
	CTRAB->(DbGotop())

	oReport:SetMeter(nTotReg)
	oSection1:Init()

	While !oReport:Cancel() .And. !CTRAB->(Eof())

		cDuplicata	:= ''
		cClasse		:= ''
		cLinha		:= ''
		cLinSeq		:= ''
		nValor		:= 0
		cPacote		:= ''
		nMotiv2		:= 0
		dDtEmp		:= ''
		cDescCli	:= ''

		cDuplicata := CTRAB->F4_DUPLIC

		//Fernando em 19/12/13 - Duplic tem que ser SIM ou NAO
		Do Case
		Case cDuplicata =='S'
			cDuplicata := "SIM"
		Otherwise
			cDuplicata :='NAO'
		EndCase

		nValor := CTRAB->C6_PRCVEN
		cDescCli := CTRAB->A1_NOME
		oSection1:Cell('ASSISTENTE'  	):SetValue(CTRAB->ATENDE+"-"+GetName(CTRAB->ATENDE) )

		dDtEmp := ''

		If Substr(Alltrim(cTrab->OBS),1,1) $ "1/2/3/8/9"
			dDtEmp := 'NAO LIBERADO'
		Else
			dDtEmp := Dtoc(Stod(CTRAB->C9_DATALIB))
		EndIf

		oSection1:Cell('GERAFIM'    	):SetValue(cDuplicata)
		oSection1:Cell('C5_YPC'   		):SetValue(Alltrim(CTRAB->C5_YPC))
		oSection1:Cell('VENDEDOR'   	):SetValue(Alltrim(CTRAB->VENDEDOR))
		oSection1:Cell('CLIENTE'  		):SetValue(Alltrim(CTRAB->CLIENTE) +" - "+ cDescCli)
		//oSection1:Cell('CLI_TRANSP'   	):SetValue(Alltrim(CTRAB->CLIENTE) +" - "+ cDescCli+" / "+Alltrim(CTRAB->TRANSP))
		oSection1:Cell('CIDADE'	    	):SetValue(RTRIM(CTRAB->MUN_CLI))
		oSection1:Cell('ESTADO'		  	):SetValue(RTRIM(CTRAB->UF_CLI))

		/*IF MV_PAR23 == 1	//Utiliza Roteirização
		oSection1:Cell('ROTA'		 	):SetValue(CTRAB->ZONA +"-"+CTRAB->DESZONA)
	Else
		oSection1:Cell('ROTA'		 	):Hide()
	EndIf
		*/

	oSection1:Cell('PEDIDO' 		):SetValue(CTRAB->C5_NUM)
	oSection1:Cell('DT_EMISSAO'    	):SetValue(CVALTOCHAR(STOD(CTRAB->C5_EMISSAO)))
	oSection1:Cell('COD_PROD'   	):SetValue(ALLTRIM(cTrab->C6_PRODUTO))
	oSection1:Cell('LOTE'		   	):SetValue(ALLTRIM(cTrab->LOT))


	cClasse := CTRAB->B1_YCLASSE
	cLinha	:= CTRAB->B1_YLINHA
	cLinSeq := CTRAB->B1_YLINSEQ
	cPacote	:= CTRAB->B1_YPCGMR3

	cLinha := CTRAB->MARCA

	cPacote := CTRAB->DESCPACOTE

	oSection1:Cell('CLASSE'		  	):SetValue(cClasse)
	oSection1:Cell('PRODUTO'    	):SetValue(Alltrim(CTRAB->B1_DESC))
	DO Case
	Case cLinha == "0101"
		oSection1:Cell('MARCA'	  		):SetValue("Biancogres")
	Case cLinha == "0501"
		oSection1:Cell('MARCA'	  		):SetValue("Incesa")
	Case cLinha == "0599"
		oSection1:Cell('MARCA'	  		):SetValue("Bellacasa")
	Case cLinha == "1399"
		oSection1:Cell('MARCA'	  		):SetValue("Mundialli")
	Case cLinha == "1401"
		oSection1:Cell('MARCA'	  		):SetValue("Vitcer")
	OTHERWISE
		oSection1:Cell('MARCA'	  		):SetValue(cLinha)
	EndCase

	oSection1:Cell('PACOTE'		 	):SetValue(cPacote)
	oSection1:Cell('PM'		 		):SetValue(nValor)
	oSection1:Cell('RS'    			):SetValue(nValor*CTRAB->SALDO)
	oSection1:Cell('QTDE_SALDO'		):SetValue(CTRAB->SALDO)
	oSection1:Cell('KG'			  	):SetValue(CTRAB->PBRUTO)
	oSection1:Cell('PESO_MEDIO'	  	):SetValue(IIF(CTRAB->SALDO > 0,CTRAB->PBRUTO/CTRAB->SALDO,0))
	oSection1:Cell('SITUACAO'	  	):SetValue(CTRAB->OBS)
	//oSection1:Cell('SAS'		  	):SetValue(Substr(Alltrim(CTRAB->OBS),1,1))

	cSitua := Substr(Alltrim(CTRAB->OBS),1,1)

	//Fernando em 07/01 - separando
	oSection1:Cell('QTDEMP'	   		):SetValue(CTRAB->QTDEMP)

	If(Val(Substr(Alltrim(CTRAB->OBS),1,1)) <=3)
		nMotiv2 := 1
	ElseIf (Val(Substr(Alltrim(CTRAB->OBS),1,1)) <=7)
		nMotiv2 := 2
	Else
		nMotiv2 := 3
	EndIf

	oSection1:Cell('MOTIV2'		  	):SetValue(cValtoChar(nMotiv2))

	If(nMotiv2 == 1)
		oSection1:Cell('KG_BLOQUEADO'  	):SetValue(CTRAB->PBRUTO)
		oSection1:Cell('M2_BLOQUEADO'  	):SetValue(CTRAB->SALDO)
		oSection1:Cell('RS_BLOQUEADO'  	):SetValue(nValor*CTRAB->SALDO)
	Else
		oSection1:Cell('KG_BLOQUEADO'  	):SetValue(0)
		oSection1:Cell('M2_BLOQUEADO'  	):SetValue(0)
		oSection1:Cell('RS_BLOQUEADO'  	):SetValue(0)
	EndIf
	If(nMotiv2 == 2)
		oSection1:Cell('KG_LIB'		  	):SetValue(CTRAB->PBRUTO)
		oSection1:Cell('M2_LIB'		  	):SetValue(CTRAB->SALDO)
		oSection1:Cell('RS_LIBERADO'  	):SetValue(nValor*CTRAB->SALDO)
	Else
		oSection1:Cell('KG_LIB'		  	):SetValue(0)
		oSection1:Cell('M2_LIB'		  	):SetValue(0)
		oSection1:Cell('RS_LIBERADO'  	):SetValue(0)
	EndIf
	If(nMotiv2 == 3)
		oSection1:Cell('KG_SEM_EMPENHO'	):SetValue(CTRAB->PBRUTO)
		oSection1:Cell('M2_SEM_EMPENHO'	):SetValue(CTRAB->SALDO)
		oSection1:Cell('RS_SEM_EMPENHO'	):SetValue(nValor*CTRAB->SALDO)
	Else
		oSection1:Cell('KG_SEM_EMPENHO'	):SetValue(0)
		oSection1:Cell('M2_SEM_EMPENHO'	):SetValue(0)
		oSection1:Cell('RS_SEM_EMPENHO'	):SetValue(0)
	EndIf

	//Fernando em 08/01 - Colunas calculadas conforme entendimento do Mateus.
	oSection1:Cell('M2_LIB'		  	):SetValue( IIF(cSitua $ "4_6", CTRAB->QTDEMP, oSection1:Cell('M2_LIB'):GetValue() ) )
	oSection1:Cell('KG_LIB'		  	):SetValue( IIF(cSitua $ "4_6", CTRAB->QTDEMP * oSection1:Cell('PESO_MEDIO'):GetValue() , oSection1:Cell('KG_LIB'):GetValue()) )
	oSection1:Cell('M2_SEM_EMPENHO'	):SetValue( IIF(cSitua $ "4_6", (CTRAB->SALDO - CTRAB->QTDEMP) , oSection1:Cell('M2_SEM_EMPENHO'):GetValue()) )
	oSection1:Cell('KG_SEM_EMPENHO'	):SetValue( IIF(cSitua $ "4_6", (oSection1:Cell('M2_SEM_EMPENHO'):GetValue() * oSection1:Cell('PESO_MEDIO'):GetValue() ), oSection1:Cell('KG_SEM_EMPENHO'):GetValue() ) )
	oSection1:Cell('RS_LIBERADO'	):SetValue( IIF(cSitua $ "4_6", ( oSection1:Cell('PM'):GetValue() * CTRAB->QTDEMP ), oSection1:Cell('RS_LIBERADO'):GetValue() ) )
	oSection1:Cell('RS_SEM_EMPENHO'	):SetValue( IIF(cSitua $ "4_6", ( oSection1:Cell('PM'):GetValue() * oSection1:Cell('M2_SEM_EMPENHO'):GetValue() ), oSection1:Cell('RS_SEM_EMPENHO'):GetValue() ) )

	oSection1:Cell('TRANSPORTADORA'	):SetValue(Alltrim(CTRAB->TRANSP))
	oSection1:Cell('TRANSP_ORC'		):SetValue(Alltrim(CTRAB->TRANSP_ORC))
	oSection1:Cell('DT_ENTREGA'  	):SetValue(CVALTOCHAR(STOD(CTRAB->C6_ENTREG)))
	oSection1:Cell('DT_NECESSI'  	):SetValue(CVALTOCHAR(STOD(CTRAB->C6_YDTNECE)))
	oSection1:Cell('DT_NEC_CLI'  	):SetValue(CVALTOCHAR(STOD(CTRAB->C6_YDTNERE)))
	oSection1:Cell('DT_DISPOP'  	):SetValue(CVALTOCHAR(STOD(CTRAB->DTDISPOP)))
	oSection1:Cell('DT_EMPENHO'  	):SetValue(dDtEmp)
	//oSection1:Cell('EST_ENTREGA'  	):SetValue(Alltrim(CTRAB->ESTADO))
	//oSection1:Cell('MUN_ENTREGA'  	):SetValue(Alltrim(CTRAB->CIDADE))
	//oSection1:Cell('BAI_ENTREGA'  	):SetValue(Alltrim(CTRAB->BAIRRO))
	//oSection1:Cell('END_ENTREGA'  	):SetValue(Alltrim(CTRAB->C5_YEND))
	//oSection1:Cell('CEP_ENTREGA'  	):SetValue(Alltrim(CTRAB->CEP))

	oSection1:Cell('FORNO'	  		):SetValue(Alltrim(CTRAB->FORNO))
	oSection1:Cell('FORMATO'	  	):SetValue(Alltrim(CTRAB->FORMATO))
	oSection1:Cell('TIPO_PED'	  	):SetValue(Alltrim(CTRAB->TIPO_PED))
	oSection1:Cell('CONDPAG'	  	):SetValue(Alltrim(CTRAB->CONDPAG))
	oSection1:Cell('GRP_CLI'	  	):SetValue(Alltrim(CTRAB->GRP_CLI))
	oSection1:Cell('TP_SEG'	  		):SetValue(Alltrim(CTRAB->TP_SEG))
	oSection1:Cell('DIAS_EMP'	  	):SetValue(cvaltochar(CTRAB->DIAS_EMP))
	oSection1:Cell('ITEM_PED'	  	):SetValue(Alltrim(CTRAB->ITEM_PED))
	oSection1:Cell('CATEGORIA'	  	):SetValue(Alltrim(CTRAB->CATEGORIA))


	//Colunas Layout Representante
	oSection1:Cell('QTD_ORI'	  	):SetValue(CTRAB->C6_QTDVEN)
	oSection1:Cell('QTD_FAT'	  	):SetValue(CTRAB->C6_QTDENT)
	oSection1:Cell('QTD_A_FAT'  	):SetValue(CTRAB->C6_QTDVEN - CTRAB->C6_QTDENT)
	oSection1:Cell('PESO_BR'	  	):SetValue(CTRAB->PBRUTO)

	IF ALLTRIM(CTRAB->C5_TIPOCLI) <> "X"
		pp_PRCVEN  :=  CTRAB->C6_PRCVEN
	ELSE
		pp_PRCVEN  :=  XMOEDA(cTrab->C6_PRCVEN,2,1, ddatabase)
	ENDIF

	oSection1:Cell('PRECO_UNIT'	  	):SetValue(pp_PRCVEN)

	oSection1:PrintLine()

	oReport:IncMeter()

	CTRAB->(dbSkip())

EndDo

oSection1:Finish()
CTRAB->(DbCloseArea())

Return Nil

/*/{Protheus.doc} ReportPrint
@description RETORNAR NOME DO USUARIO  
/*/
Static Function GetName(cId)

	Local cUserName

	PswOrder(1)
	IF (!Empty( cId ) .and.PswSeek( cId ))
		cUserName	:= PswRet(1)[1][2]
	Else
		cUserName	:= SPACE(15)
	EndIf

	IF ( cId == "******" )
		cUserName := "All"
	EndIf

	If Empty(cUserName)
		cUserName := "(ATENDENTE EXCLUIDO DO SISTEMA)"
	EndIf

Return( cUserName )


/*/{Protheus.doc} ReportPrint
@author LUANA MARIN RIBEIRO
@since 23/10/2015
@description FAZER O RELATÓRIO COM TREPORT  
/*/
User Function BIA789_3()

	Local oReport

	If MV_PAR23 == 1
		oReport:= RDef3Zona()
		oReport:PrintDialog()
	Else
		oReport:= RDef3()
		oReport:PrintDialog()
	EndIf

Return NIL

//COM SEÇÃO POR ZONA
Static Function RDef3Zona()
	Local oReport
	Local oSection1
	Local Enter := chr(13) + Chr(10)
	Local cTitle    := "MAPA DE PEDIDO NAO ATENDIDOS"
	Local cQryRel   := ""


	oReport:= TReport():New("BIA789",cTitle,, {|oReport| RPt3Zona(oReport)},cTitle,,,.T.)
	oReport:SetLandscape() 			//Define a orientacao de pagina do relatorio como paisagem.
	Pergunte(oReport:GetParam(),.F.)

	oSecZon := TRSection():New(oReport, "Zona", {"CTRAB"})

	//apresenta em linha, não em colunas.
	oSecZon:SetLineStyle(.T.)
	TRCell():New(oSecZon, "ZONA", , "Zona","@!",70)

	oSecTra := TRSection():New(oReport, "Tipo de Transporte", {"CTRAB"})

	//apresenta em linha, não em colunas.
	oSecTra:SetLineStyle(.T.)
	TRCell():New(oSecTra, "C5_YTPTRAN", , "Tipo de Transporte    ","@!",70)

	oSecVen := TRSection():New(oReport, "Vendedor", {"CTRAB"})
	oSecVen:SetLineStyle(.T.)
	TRCell():New(oSecVen, "VENDEDOR", , "Vendedor    ","@!",70)

	oSecCli := TRSection():New(oReport, "Cliente", {"CTRAB"})
	oSecCli:SetLineStyle(.T.)
	TRCell():New(oSecCli, "CLIENTE", , "Cliente    ","@!",50)
	TRCell():New(oSecCli, "CID_UF", , "Município/UF    ","@!",52)
	TRCell():New(oSecCli, "TRANSP", , "Transp    ","@!",50)

	oSecPed := TRSection():New(oReport, "Pedido", {"CTRAB"})
	oSecPed:SetHeaderPage()
	//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	TRCell():New(oSecPed,'PEDIDO',,'CODIGO' + Enter + 'PEDIDO',,8,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSecPed,'DT_EMISSAO',,'DATA DE' + Enter + 'EMISSAO',,10)
	TRCell():New(oSecPed,'COD_PROD',,'CODIGO DO' + Enter + 'PRODUTO',,16)
	TRCell():New(oSecPed,'PRODUTO',,'DESCRICAO DO' + Enter + 'PRODUTO',,29)
	TRCell():New(oSecPed,'AUX1',,'', "@E 999,999,999.99",0,,,,,,,,.F.)
	TRCell():New(oSecPed,'pp_PRCVEN',,'PRECO' + Enter + 'MEDIO',"@E 999.99",06,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'C6_QTDVEN',,'____________' + Enter + 'PEDIDO',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecPed,'C6_QTDENT',,'VOLUME(M2)' + Enter + 'ATENDIDO',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecPed,'SALDO',,'____________' + Enter + 'SALDO',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecPed,'PESO_BR',,'PESO' + Enter + 'BRUTO', "@E 999,999,999.99",15,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'OBS',,Enter + Space(3) + 'OBSERVACAO',,24,,,"LEFT",,"LEFT")
	TRCell():New(oSecPed,'C6_YDTNECE',,'DT NEC.' + Enter + 'ENGEN',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'C6_ENTREG',,'DT PREV' + Enter + 'INICIAL',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'DTDISPOP',,'DT DISP' + Enter + 'OP',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'CONDPAG',,Enter + Space(3) + 'COND. PAG',,18,,,"LEFT",,"LEFT")
	TRCell():New(oSecPed,'EMPRESA',,Enter + Space(3) + 'LOCAL',,10,,,"LEFT",,"LEFT")
	TRCell():New(oSecPed,'C5_YPC',,Enter + Space(3) + 'PC',,10,,,"LEFT",,"LEFT")

	//SESSÃO CRIADA PARA AUXILIAR NA CRIAÇÃO DOS TOTAIS
	oSecTot := TRSection():New(oReport, "Totais", {"CTRAB"})
	//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	TRCell():New(oSecTot,'PEDIDO',,'',,60)
	TRCell():New(oSecTot,'DT_EMISSAO',,'',,1)
	TRCell():New(oSecTot,'COD_PROD',,'',,1)
	TRCell():New(oSecTot,'PRODUTO',,'',,1)
	TRCell():New(oSecTot,'AUX1',,'', "@E 999,999,999.99",0,,,,,,,,.F.)
	TRCell():New(oSecTot,'pp_PRCVEN',,'',"@E 999.99",06,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'C6_QTDVEN',,'',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecTot,'C6_QTDENT',,'',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecTot,'SALDO',,'',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecTot,'PESO_BR',,'', "@E 999,999,999.99",15,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'OBS',,'',,24,,,"LEFT",,"LEFT")
	TRCell():New(oSecTot,'C6_YDTNECE',,'',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'C6_ENTREG',,'',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'DTDISPOP',,'',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'CONDPAG',,'',,18,,,"LEFT",,"LEFT")
	TRCell():New(oSecTot,'EMPRESA',,'',,10,,,"LEFT",,"LEFT")
	TRCell():New(oSecTot,'C5_YPC',,'',,10,,,"LEFT",,"LEFT")

	//SESSÃO CRIADA PARA AUXILIAR NA CRIAÇÃO DOS TOTAIS DE TRANSPORTE
	oSecTtt := TRSection():New(oReport, "Totais Transp.", {"CTRAB"})
	//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	TRCell():New(oSecTtt,'DESCRICAO',,'',,40)
	TRCell():New(oSecTtt,'VALOR',,'', "@E 999,999,999.99",15,,,"RIGHT",,"RIGHT")

	//define as quebras no relatório...
	oBrPed := TRBreak():New(oSecPed,oSecPed:Cell("PEDIDO"),"Total do Pedido")
	oBrCli := TRBreak():New(oSecCli,oSecCli:Cell("CLIENTE"),"Total do Cliente")
	oBrVend := TRBreak():New(oSecVen,oSecVen:Cell("VENDEDOR"),"Total do Vendedor")
	oBrTra := TRBreak():New(oSecTra,oSecTra:Cell("C5_YTPTRAN"),"Total Tipo Transporte")
	oBrZon := TRBreak():New(oSecZon,oSecZon:Cell("ZONA"),"Total Zona")

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1P',"SUM",oBrPed, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOP',"SUM",oBrPed, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENP',"ONPRINT",oBrPed, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENP',"SUM",oBrPed, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTP',"SUM",oBrPed, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRP',"SUM",oBrPed, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENP"):SetFormula({|| oReport:GetFunction("fAUX1P"):uLastValue/oReport:GetFunction("fSALDOP"):uLastValue })

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1C',"SUM",oBrCli, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOC',"SUM",oBrCli, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENC',"ONPRINT",oBrCli, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENC',"SUM",oBrCli, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTC',"SUM",oBrCli, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRC',"SUM",oBrCli, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENC"):SetFormula({|| oReport:GetFunction("fAUX1C"):uLastValue/oReport:GetFunction("fSALDOC"):uLastValue })

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1V',"SUM",oBrVend, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOV',"SUM",oBrVend, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENV',"ONPRINT",oBrVend, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENV',"SUM",oBrVend, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTV',"SUM",oBrVend, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRV',"SUM",oBrVend, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENV"):SetFormula({|| oReport:GetFunction("fAUX1V"):uLastValue/oReport:GetFunction("fSALDOV"):uLastValue })

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1T',"SUM",oBrTra, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOT',"SUM",oBrTra, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENT',"ONPRINT",oBrTra, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENT',"SUM",oBrTra, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTT',"SUM",oBrTra, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRT',"SUM",oBrTra, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENT"):SetFormula({|| oReport:GetFunction("fAUX1T"):uLastValue/oReport:GetFunction("fSALDOT"):uLastValue })

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1Z',"SUM",oBrZon, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOZ',"SUM",oBrZon, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENZ',"ONPRINT",oBrZon, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENZ',"SUM",oBrZon, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTZ',"SUM",oBrZon, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRZ',"SUM",oBrZon, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENZ"):SetFormula({|| oReport:GetFunction("fAUX1Z"):uLastValue/oReport:GetFunction("fSALDOZ"):uLastValue })

Return(oReport)

Static Function RPt3Zona(oReport)

	Local oSecZon := oReport:Section(1)
	Local oSecTra := oReport:Section(2)
	Local oSecVen := oReport:Section(3)
	Local oSecCli := oReport:Section(4)
	Local oSecPed := oReport:Section(5)
	Local oSecTot := oReport:Section(6)
	Local oSecTtt := oReport:Section(7)

	Local col := 0
	Local colPrint := 0
	Local linha := 0
	Local BreakRel


	Local cCliRep := ''
	Local cVenRep := ''
	Local cTraRep := ''
	Local cZonRep := ''

	Local cNumPed := ''
	Local pp_PRCVEN := ''
	Local bImprimeLinha := .F.
	Local lPassei := .F.
	Local lImpRod := .F.

	//tot = total //G = Geral //PM = preço médio //VP = volume pedido //VA = volume atendido //VS = volume saldo //PB = peso bruto
	Local totGPM := 0.0
	Local totGVP := 0.0
	Local totGVA := 0.0
	Local totGVS := 0.0
	Local totGPB := 0.0

	//tot = total //O = Observacao //PM = preço médio //VP = volume pedido //VA = volume atendido //VS = volume saldo //PB = peso bruto
	//1 - Bloqueio/Preço
	Local totOPM1 := 0.0
	Local totOVP1 := 0.0
	Local totOVA1 := 0.0
	Local totOVS1 := 0.0
	Local totOPB1 := 0.0
	//2 - Crédito
	Local totOPM2 := 0.0
	Local totOVP2 := 0.0
	Local totOVA2 := 0.0
	Local totOVS2 := 0.0
	Local totOPB2 := 0.0
	//3 - Estoque Disp./Crédito
	Local totOPM3 := 0.0
	Local totOVP3 := 0.0
	Local totOVA3 := 0.0
	Local totOVS3 := 0.0
	Local totOPB3 := 0.0
	//4 - Estoque Disp. Parcial
	Local totOPM4 := 0.0
	Local totOVP4 := 0.0
	Local totOVA4 := 0.0
	Local totOVS4 := 0.0
	Local totOPB4 := 0.0
	//5 Estoque Disp. Total
	Local totOPM5 := 0.0
	Local totOVP5 := 0.0
	Local totOVA5 := 0.0
	Local totOVS5 := 0.0
	Local totOPB5 := 0.0
	//6 - Em Carregamento Parcial
	Local totOPM6 := 0.0
	Local totOVP6 := 0.0
	Local totOVA6 := 0.0
	Local totOVS6 := 0.0
	Local totOPB6 := 0.0
	//7 - Em Carregamento Total
	Local totOPM7 := 0.0
	Local totOVP7 := 0.0
	Local totOVA7 := 0.0
	Local totOVS7 := 0.0
	Local totOPB7 := 0.0
	//8 - Verificar Estoque
	Local totOPM8 := 0.0
	Local totOVP8 := 0.0
	Local totOVA8 := 0.0
	Local totOVS8 := 0.0
	Local totOPB8 := 0.0
	//9 - Liberado/Aguardando RA
	Local totOPM9 := 0.0
	Local totOVP9 := 0.0
	Local totOVA9 := 0.0
	Local totOVS9 := 0.0
	Local totOPB9 := 0.0

	Local cTpTrans := ''
	Local nVlTran1 := 0.0
	Local nVlTran2 := 0.0
	Local nVlTran3 := 0.0
	Local nVlTran := 0.0

	dbSelectArea("CTRAB")
	CTRAB->(DbGotop())

	//Armazenar informacoes do Segmento
	aSegmento :=	{{"SEG"			,"C",20,0},;
		{"PRCVEN"		,"N",12,2},;
		{"QTDVEN"		,"N",12,2},;
		{"QTDENT"		,"N",12,2},;
		{"SALDO"		,"N",12,2},;
		{"SALVLR"		,"N",12,2},;
		{"PBRUTO"		,"N",12,2},;
		{"QUANT"		,"N",12,2}}
	If chkfile("_Segmento")
		dbSelectArea("_Segmento")
		dbCloseArea()
	EndIf
	_Segmento := CriaTrab(aSegmento)
	dbUseArea(.T.,,_Segmento,"_Segmento",.t.)
	dbCreateInd(_Segmento,"SEG",{||SEG})

	oReport:SetMeter(nTotReg)
	While !oReport:Cancel() .And. !CTRAB->(Eof())
		lPassei := .F.
		IF MV_PAR07 <> '123456789' //Todos os pedidos
			IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
				lPassei := .T.
			ENDIF
			IF lPassei
				DbSelectArea("cTrab")
				DbSkip()
				Loop
			ENDIF
		ENDIF

		oSecZon:SetHeaderSection(.T.)
		oSecZon:Init()

		DbSelectArea("DA5")
		DbSeek(xFilial("DA5")+cTrab->ZONA)

		oSecZon:Cell("ZONA"):SetValue(Alltrim(cTrab->ZONA) + " - " + DA5->DA5_DESC)
		oSecZon:PrintLine()

		cZonRep := CTRAB->ZONA

		While cZonRep == CTRAB->ZONA .And. CTRAB->(!Eof())
			lPassei := .F.
			IF MV_PAR07 <> '123456789' //Todos os pedidos
				IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
					lPassei := .T.
				ENDIF
				IF lPassei
					DbSelectArea("cTrab")
					DbSkip()
					Loop
				ENDIF
			ENDIF

			oSecTra:SetHeaderSection(.T.)
			oSecTra:Init()

			oSecTra:Cell("C5_YTPTRAN"):SetValue(Alltrim(CTRAB->C5_YTPTRAN))
			oSecTra:PrintLine()

			cTraRep := CTRAB->C5_YTPTRAN

			While cTraRep == CTRAB->C5_YTPTRAN .And. CTRAB->(!Eof())
				lPassei := .F.
				IF MV_PAR07 <> '123456789' //Todos os pedidos
					IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
						lPassei := .T.
					ENDIF
					IF lPassei
						DbSelectArea("cTrab")
						DbSkip()
						Loop
					ENDIF
				ENDIF

				oSecVen:SetHeaderSection(.T.)
				oSecVen:Init()

				oSecVen:Cell("VENDEDOR"):SetValue(Alltrim(CTRAB->VENDEDOR))
				oSecVen:PrintLine()

				cVendRep := CTRAB->VENDEDOR


				oSecCli:Init()
				While cVendRep == CTRAB->VENDEDOR .And. CTRAB->(!Eof())
					lPassei := .F.
					IF MV_PAR07 <> '123456789' //Todos os pedidos
						IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
							lPassei := .T.
						ENDIF
						IF lPassei
							DbSelectArea("cTrab")
							DbSkip()
							Loop
						ENDIF
					ENDIF

					If bImprimeLinha == .T.
						oReport:ThinLine()
						bImprimeLinha := .T.
					EndIf

					DbSelectArea("SA1")
					DbSetOrder(1)
					DbSeeK(xFilial("SA1")+cTrab->CLI_ORIG)

					oSecCli:SetHeaderSection(.T.)
					oSecCli:Cell("CLIENTE"):SetValue(Space(5) + SubStr(Alltrim(cTrab->CLIENTE) + " - " + SA1->A1_NOME,1,30))
					oSecCli:Cell("CID_UF"):SetValue(Space(5) + SubStr(ALLTRIM(SA1->A1_MUN) +'/'+SA1->A1_EST,1,30))
					oSecCli:Cell("TRANSP"):SetValue(Space(5) + SubStr(cTrab->TRANSP,1,30))
					oSecCli:PrintLine()

					cCliRep := cTrab->CLIENTE

					oSecPed:Init()
					While cCliRep == cTrab->CLIENTE .And. CTRAB->(!Eof())
						lPassei := .F.
						IF MV_PAR07 <> '123456789' //Todos os pedidos
							IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
								lPassei := .T.
							ENDIF
							IF lPassei
								DbSelectArea("cTrab")
								DbSkip()
								Loop
							ENDIF
						ENDIF

						//Linha de Detalhe
						IF ALLTRIM(cTrab->C5_YCLIORI) = ''
							cNumPed  := cTrab->C5_NUM
						ELSE
							cNumPed  := "*"+cTrab->C5_NUM
						ENDIF

						IF ALLTRIM(cTrab->C5_TIPOCLI) <> "X"
							pp_PRCVEN  :=  cTrab->C6_PRCVEN
						ELSE
							pp_PRCVEN  :=  XMOEDA(cTrab->C6_PRCVEN,2,1, ddatabase)
						ENDIF

						oSecPed:Cell('PEDIDO'):SetValue(cNumPed)
						oSecPed:Cell('DT_EMISSAO'):SetValue(STOD(cTrab->C5_EMISSAO))
						oSecPed:Cell('COD_PROD'):SetValue(ALLTRIM(cTrab->PRO) + " " + ALLTRIM(cTrab->LOT))
						oSecPed:Cell('PRODUTO'):SetValue(SUBSTR(cTrab->B1_DESC,1,26))
						oSecPed:Cell('pp_PRCVEN'):SetValue(pp_PRCVEN)
						oSecPed:Cell('C6_QTDVEN'):SetValue(cTrab->C6_QTDVEN)
						oSecPed:Cell('C6_QTDENT'):SetValue(cTrab->C6_QTDENT)
						oSecPed:Cell('SALDO'):SetValue(cTrab->SALDO)
						oSecPed:Cell('PESO_BR'):SetValue(cTrab->PBRUTO)
						oSecPed:Cell('OBS'):SetValue(Space(3) + SUBSTR(ALLTRIM(cTrab->OBS), 1, 21))
						oSecPed:Cell('C6_YDTNECE'):SetValue(Space(3) + DTOC(STOD(cTrab->C6_YDTNECE)))
						oSecPed:Cell('C6_ENTREG'):SetValue(Space(3) + DTOC(STOD(cTrab->C6_ENTREG)))
						oSecPed:Cell('DTDISPOP'):SetValue(Space(3) +  DTOC(STOD(cTrab->DTDISPOP)))
						oSecPed:Cell('CONDPAG'):SetValue(Space(3) + cTrab->CONDPAG)
						oSecPed:Cell('EMPRESA'):SetValue(Space(3) + cTrab->EMPRESA)
						oSecPed:Cell('C5_YPC'):SetValue(Space(3) + cTrab->C5_YPC)
						oSecPed:Cell('AUX1'):SetValue(cTrab->SALDO * pp_PRCVEN)

						//SOMATÓRIO DO TOTAL GERAL
						totGPM := totGPM + (cTrab->SALDO * pp_PRCVEN)
						totGVP := totGVP + cTrab->C6_QTDVEN
						totGVA := totGVA + cTrab->C6_QTDENT
						totGVS := totGVS + cTrab->SALDO
						totGPB := totGPB + cTrab->PBRUTO

						//SOMATORIO OBS
						If SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '1'
							totOPM1 := totOPM1 + (cTrab->SALDO * pp_PRCVEN)
							totOVP1 := totOVP1 + cTrab->C6_QTDVEN
							totOVA1 := totOVA1 + cTrab->C6_QTDENT
							totOVS1 := totOVS1 + cTrab->SALDO
							totOPB1 := totOPB1 + cTrab->PBRUTO
						ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '2'
							totOPM2 := totOPM2 + (cTrab->SALDO * pp_PRCVEN)
							totOVP2 := totOVP2 + cTrab->C6_QTDVEN
							totOVA2 := totOVA2 + cTrab->C6_QTDENT
							totOVS2 := totOVS2 + cTrab->SALDO
							totOPB2 := totOPB2 + cTrab->PBRUTO
						ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '3'
							totOPM3 := totOPM3 + (cTrab->SALDO * pp_PRCVEN)
							totOVP3 := totOVP3 + cTrab->C6_QTDVEN
							totOVA3 := totOVA3 + cTrab->C6_QTDENT
							totOVS3 := totOVS3 + cTrab->SALDO
							totOPB3 := totOPB3 + cTrab->PBRUTO
						ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '4'
							totOPM4 := totOPM4 + (cTrab->SALDO * pp_PRCVEN)
							totOVP4 := totOVP4 + cTrab->C6_QTDVEN
							totOVA4 := totOVA4 + cTrab->C6_QTDENT
							totOVS4 := totOVS4 + cTrab->SALDO
							totOPB4 := totOPB4 + cTrab->PBRUTO
						ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '5'
							totOPM5 := totOPM5 + (cTrab->SALDO * pp_PRCVEN)
							totOVP5 := totOVP5 + cTrab->C6_QTDVEN
							totOVA5 := totOVA5 + cTrab->C6_QTDENT
							totOVS5 := totOVS5 + cTrab->SALDO
							totOPB5 := totOPB5 + cTrab->PBRUTO
						ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '6'
							totOPM6 := totOPM6 + (cTrab->SALDO * pp_PRCVEN)
							totOVP6 := totOVP6 + cTrab->C6_QTDVEN
							totOVA6 := totOVA6 + cTrab->C6_QTDENT
							totOVS6 := totOVS6 + cTrab->SALDO
							totOPB6 := totOPB6 + cTrab->PBRUTO
						ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '7'
							totOPM7 := totOPM7 + (cTrab->SALDO * pp_PRCVEN)
							totOVP7 := totOVP7 + cTrab->C6_QTDVEN
							totOVA7 := totOVA7 + cTrab->C6_QTDENT
							totOVS7 := totOVS7 + cTrab->SALDO
							totOPB7 := totOPB7 + cTrab->PBRUTO
						ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '8'
							totOPM8 := totOPM8 + (cTrab->SALDO * pp_PRCVEN)
							totOVP8 := totOVP8 + cTrab->C6_QTDVEN
							totOVA8 := totOVA8 + cTrab->C6_QTDENT
							totOVS8 := totOVS8 + cTrab->SALDO
							totOPB8 := totOPB8 + cTrab->PBRUTO
						ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '9'
							totOPM9 := totOPM9 + (cTrab->SALDO * pp_PRCVEN)
							totOVP9 := totOVP9 + cTrab->C6_QTDVEN
							totOVA9 := totOVA9 + cTrab->C6_QTDENT
							totOVS9 := totOVS9 + cTrab->SALDO
							totOPB9 := totOPB9 + cTrab->PBRUTO
						EndIf

						//SOMATÓRIO SEGMENTO
						//Armazena Valores Por Segmento
						dbSelectArea("_Segmento")
						dbSetOrder(1)
						If dbSeek(cTrab->SEGMENTO)
							RecLock("_Segmento",.F.)
							_Segmento->PRCVEN	:= _Segmento->PRCVEN + pp_PRCVEN
							_Segmento->QTDVEN	:= _Segmento->QTDVEN + cTrab->C6_QTDVEN
							_Segmento->QTDENT	:= _Segmento->QTDENT + cTrab->C6_QTDENT
							_Segmento->SALDO	:= _Segmento->SALDO  + cTrab->SALDO
							_Segmento->SALVLR	:= _Segmento->SALVLR + cTrab->(cTrab->SALDO * pp_PRCVEN)
							_Segmento->PBRUTO	:= _Segmento->PBRUTO + cTrab->PBRUTO
							_Segmento->QUANT	:= _Segmento->QUANT  + 1
						Else
							RecLock("_Segmento",.T.)
							_Segmento->SEG		:= cTrab->SEGMENTO
							_Segmento->PRCVEN	:= pp_PRCVEN
							_Segmento->QTDVEN	:= cTrab->C6_QTDVEN
							_Segmento->QTDENT	:= cTrab->C6_QTDENT
							_Segmento->SALDO	:= cTrab->SALDO
							_Segmento->SALVLR	:= cTrab->(cTrab->SALDO * pp_PRCVEN)
							_Segmento->PBRUTO	:= cTrab->PBRUTO
							_Segmento->QUANT	:= 1
						EndIf
						msUnLock()

						c001 := " 	SELECT COUNT(*) AS TOTREG					"
						c001 += " 	FROM	"+RetSqlName("SC9")+" WITH (NOLOCK) "
						c001 += " 	WHERE	C9_FILIAL = '"+xFilial('SC9')+"' AND		"
						c001 += " 				C9_AGREG		<> ''			AND			"
						c001 += " 			  C9_PEDIDO	  = '"+cTrab->C5_NUM+"'		AND			"
						c001 += " 	 			C9_PRODUTO	= '"+cTrab->C6_PRODUTO+"' AND		"
						c001 += " 	 			C9_ITEM	   	= '"+cTrab->C6_ITEM+"'	AND			"
						c001 += " 	 			C9_LOTECTL	= '"+cTrab->C6_LOTECTL+"'	AND		"
						c001 += " 	 			C9_BLEST	  = ''	AND			"
						c001 += " 	 			C9_BLCRED	  = ''	AND			"
						c001 += " 	 			D_E_L_E_T_	= ''		"
						IF chkfile("cTRB")
							dbSelectArea("cTRB")
							dbCloseArea()
						ENDIF
						//c001 := ChangeQuery(c001) //RETIRADO POIS NÃO RECONHECE O COMANDO WITH (NOLOCK)
						TCQUERY c001 ALIAS "cTRB" NEW

						IF cTRB->TOTREG >= 1
							DO CASE
							CASE cTrab->C5_YTPTRAN == '1'
								cTpTrans := 'Transportadora'
								nVlTran1 := nVlTran1 + cTrab->PBRUTO
							CASE cTrab->C5_YTPTRAN == '2'
								cTpTrans := 'Autônomo'
								nVlTran2 := nVlTran2 + cTrab->PBRUTO
							CASE cTrab->C5_YTPTRAN == '3'
								cTpTrans := 'Cliente Retira'
								nVlTran3 := nVlTran3 + cTrab->PBRUTO
							OTHERWISE
								cTpTrans := ''
								nVlTran  := nVlTran  + cTrab->PBRUTO
							ENDCASE
						ENDIF

						oSecPed:PrintLine()
						lImpRod := .T.

						oReport:IncMeter()                     //Incrementa a barra de progresso
						CTRAB->(dbSkip())

					End
					oSecPed:Finish()
				End
				oSecCli:Finish()
				oSecVen:Finish()

				bImprimeLinha := .F.
			End
			oSecTra:Finish()
		End

		DA5->(DbCloseArea())
		oSecZon:Finish()
	End

	If lImpRod == .T.
		oSecTot:Init()

		//IMPRIMINDO AS TOTALIZAÇÕES FINAIS, INCLUSIVE TOTAL GERAL
		oReport:SkipLine(2)

		oSecTot:Cell("PEDIDO"):SetValue("TOTAL GERAL")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totGPM/totGVS,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totGVP,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totGVA,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totGVS,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totGPB,2))
		oSecTot:PrintLine()

		oReport:SkipLine(2)
		oReport:FatLine()

		//TOTAIS OBS
		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("1 - Bloqueio/Preço")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM1/totOVS1,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP1,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA1,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS1,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB1,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("2 - Credito")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM2/totOVS2,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP2,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA2,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS2,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB2,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("3 - Estoque Disp./Credito")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM3/totOVS3,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP3,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA3,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS3,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB3,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("4 - Estoque Disp. Parcial")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM4/totOVS4,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP4,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA4,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS4,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB4,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("5 - Estoque Disp. Total")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM5/totOVS5,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP5,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA5,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS5,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB5,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("6 - Em Carregamento Parcial")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM6/totOVS6,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP6,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA6,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS6,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB6,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("7 - Em Carregamento Total")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM7/totOVS7,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP7,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA7,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS7,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB7,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("8 - Verificar Estoque")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM8/totOVS8,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP8,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA8,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS8,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB8,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("9 - Liberado/Aguardando RA")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM9/totOVS9,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP9,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA9,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS9,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB9,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)
		oReport:ThinLine()

		//Imprime Totais por Segmento
		dbSelectArea("_Segmento")
		dbGoTop()
		While !eof()
			oReport:SkipLine(1)

			oSecTot:Cell("PEDIDO"):SetValue("Total Segmento " + _Segmento->SEG)
			oSecTot:Cell("pp_PRCVEN"):SetValue(Round(_Segmento->SALVLR/_Segmento->SALDO,2))
			oSecTot:Cell("C6_QTDVEN"):SetValue(Round(_Segmento->QTDVEN,2))
			oSecTot:Cell("C6_QTDENT"):SetValue(Round(_Segmento->QTDENT,2))
			oSecTot:Cell("SALDO"):SetValue(Round(_Segmento->SALDO,2))
			oSecTot:Cell("PESO_BR"):SetValue(Round(_Segmento->PBRUTO,2))
			oSecTot:PrintLine()

			dbSkip()
		End

		If chkfile("_Segmento")
			dbSelectArea("_Segmento")
			dbCloseArea()
		EndIf

		oReport:SkipLine(1)
		oReport:ThinLine()
		oReport:SkipLine(1)

		oSecTot:Finish()

		oSecTtt:Init()

		oSecTtt:Cell("DESCRICAO"):SetValue("Total Tipo de Transporte")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran1+nVlTran2+nVlTran3+nVlTran)
		oSecTtt:PrintLine()
		oSecTtt:Cell("DESCRICAO"):SetValue("Transportadora")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran1)
		oSecTtt:PrintLine()
		oSecTtt:Cell("DESCRICAO"):SetValue("Autônomo")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran2)
		oSecTtt:PrintLine()
		oSecTtt:Cell("DESCRICAO"):SetValue("Cliente Retira")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran3)
		oSecTtt:PrintLine()
		oSecTtt:Cell("DESCRICAO"):SetValue("Em Branco")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran)
		oSecTtt:PrintLine()

		oSecTtt:Finish()

	EndIf

	CTRAB->(DbCloseArea())

Return

//SEM SEÇÃO POR ZONA
Static Function RDef3()
	Local oReport
	Local oSection1
	Local Enter := chr(13) + Chr(10)
	Local cTitle    := "MAPA DE PEDIDO NAO ATENDIDOS"
	Local cQryRel   := ""


	oReport:= TReport():New("BIA789",cTitle,, {|oReport| RPt3(oReport)},cTitle,,,.T.)
	oReport:SetLandscape() 			//Define a orientacao de pagina do relatorio como paisagem.
	Pergunte(oReport:GetParam(),.F.)

	oSecTra := TRSection():New(oReport, "Tipo de Transporte", {"CTRAB"})

	//apresenta em linha, não em colunas.
	oSecTra:SetLineStyle(.T.)
	TRCell():New(oSecTra, "C5_YTPTRAN", , "Tipo de Transporte    ","@!",70)

	oSecVen := TRSection():New(oReport, "Vendedor", {"CTRAB"})
	oSecVen:SetLineStyle(.T.)
	TRCell():New(oSecVen, "VENDEDOR", , "Vendedor    ","@!",70)

	oSecCli := TRSection():New(oReport, "Cliente", {"CTRAB"})
	oSecCli:SetLineStyle(.T.)
	TRCell():New(oSecCli, "CLIENTE", , "Cliente    ","@!",50)
	TRCell():New(oSecCli, "CID_UF", , "Município/UF   ","@!",50)
	TRCell():New(oSecCli, "TRANSP", , "Transp    ","@!",50)

	oSecPed := TRSection():New(oReport, "Pedido", {"CTRAB"})
	oSecPed:SetHeaderPage()
	//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	TRCell():New(oSecPed,'PEDIDO',,'CODIGO' + Enter + 'PEDIDO',,8,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSecPed,'DT_EMISSAO',,'DATA DE' + Enter + 'EMISSAO',,10)
	TRCell():New(oSecPed,'COD_PROD',,'CODIGO DO' + Enter + 'PRODUTO',,16)
	TRCell():New(oSecPed,'PRODUTO',,'DESCRICAO DO' + Enter + 'PRODUTO',,29)
	TRCell():New(oSecPed,'AUX1',,'', "@E 999,999,999.99",0,,,,,,,,.F.)
	TRCell():New(oSecPed,'pp_PRCVEN',,'PRECO' + Enter + 'MEDIO',"@E 999.99",06,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'C6_QTDVEN',,'____________' + Enter + 'PEDIDO',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecPed,'C6_QTDENT',,'VOLUME(M2)' + Enter + 'ATENDIDO',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecPed,'SALDO',,'____________' + Enter + 'SALDO',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecPed,'PESO_BR',,'PESO' + Enter + 'BRUTO', "@E 999,999,999.99",15,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'OBS',,Enter + Space(3) + 'OBSERVACAO',,24,,,"LEFT",,"LEFT")
	TRCell():New(oSecPed,'C6_YDTNECE',,'DT NEC.' + Enter + 'ENGEN',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'C6_ENTREG',,'DT PREV' + Enter + 'INICIAL',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'DTDISPOP',,'DT DISP' + Enter + 'OP',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecPed,'CONDPAG',,Enter + Space(3) + 'COND. PAG',,18,,,"LEFT",,"LEFT")
	TRCell():New(oSecPed,'EMPRESA',,Enter + Space(3) + 'LOCAL',,10,,,"LEFT",,"LEFT")
	TRCell():New(oSecPed,'C5_YPC',,Enter + Space(3) + 'PC',,10,,,"LEFT",,"LEFT")

	//SESSÃO CRIADA PARA AUXILIAR NA CRIAÇÃO DOS TOTAIS
	oSecTot := TRSection():New(oReport, "Totais", {"CTRAB"})
	//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	TRCell():New(oSecTot,'PEDIDO',,'',,60)
	TRCell():New(oSecTot,'DT_EMISSAO',,'',,1)
	TRCell():New(oSecTot,'COD_PROD',,'',,1)
	TRCell():New(oSecTot,'PRODUTO',,'',,1)
	TRCell():New(oSecTot,'AUX1',,'', "@E 999,999,999.99",0,,,,,,,,.F.)
	TRCell():New(oSecTot,'pp_PRCVEN',,'',"@E 999.99",06,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'C6_QTDVEN',,'',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecTot,'C6_QTDENT',,'',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecTot,'SALDO',,'',"@E 999,999.99",12,,,"RIGHT",,"CENTER")
	TRCell():New(oSecTot,'PESO_BR',,'', "@E 999,999,999.99",15,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'OBS',,'',,24,,,"LEFT",,"LEFT")
	TRCell():New(oSecTot,'C6_YDTNECE',,'',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'C6_ENTREG',,'',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'DTDISPOP',,'',,10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSecTot,'CONDPAG',,'',,18,,,"LEFT",,"LEFT")
	TRCell():New(oSecTot,'EMPRESA',,'',,10,,,"LEFT",,"LEFT")
	TRCell():New(oSecTot,'C5_YPC',,'',,10,,,"LEFT",,"LEFT")

	//SESSÃO CRIADA PARA AUXILIAR NA CRIAÇÃO DOS TOTAIS DE TRANSPORTE
	oSecTtt := TRSection():New(oReport, "Totais Transp.", {"CTRAB"})
	//New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore,lBold)
	TRCell():New(oSecTtt,'DESCRICAO',,'',,40)
	TRCell():New(oSecTtt,'VALOR',,'', "@E 999,999,999.99",15,,,"RIGHT",,"RIGHT")

	//define as quebras no relatório...
	oBrPed := TRBreak():New(oSecPed,oSecPed:Cell("PEDIDO"),"Total do Pedido")
	oBrCli := TRBreak():New(oSecCli,oSecCli:Cell("CLIENTE"),"Total do Cliente")
	oBrVend := TRBreak():New(oSecVen,oSecVen:Cell("VENDEDOR"),"Total do Vendedor")
	oBrTra := TRBreak():New(oSecTra,oSecTra:Cell("C5_YTPTRAN"),"Total Tipo Transporte")
	//oBreak := TRBreak():New(oReport,{||.T.}, "Total Geral")

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1P',"SUM",oBrPed, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOP',"SUM",oBrPed, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENP',"ONPRINT",oBrPed, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENP',"SUM",oBrPed, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTP',"SUM",oBrPed, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRP',"SUM",oBrPed, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENP"):SetFormula({|| oReport:GetFunction("fAUX1P"):uLastValue/oReport:GetFunction("fSALDOP"):uLastValue })

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1C',"SUM",oBrCli, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOC',"SUM",oBrCli, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENC',"ONPRINT",oBrCli, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENC',"SUM",oBrCli, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTC',"SUM",oBrCli, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRC',"SUM",oBrCli, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENC"):SetFormula({|| oReport:GetFunction("fAUX1C"):uLastValue/oReport:GetFunction("fSALDOC"):uLastValue })

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1V',"SUM",oBrVend, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOV',"SUM",oBrVend, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENV',"ONPRINT",oBrVend, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENV',"SUM",oBrVend, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTV',"SUM",oBrVend, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRV',"SUM",oBrVend, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENV"):SetFormula({|| oReport:GetFunction("fAUX1V"):uLastValue/oReport:GetFunction("fSALDOV"):uLastValue })

	TRFunction():New(oSecPed:Cell('AUX1'),'fAUX1T',"SUM",oBrTra, ,"@E 999,999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('SALDO'),'fSALDOT',"SUM",oBrTra, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('pp_PRCVEN'),'fpp_PRCVENT',"ONPRINT",oBrTra, ,"@E 999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDVEN'),'fC6_QTDVENT',"SUM",oBrTra, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('C6_QTDENT'),'fC6_QTDENTT',"SUM",oBrTra, ,"@E 999,999.99",NIL,.F.,.F.)
	TRFunction():New(oSecPed:Cell('PESO_BR'),'fPESO_BRT',"SUM",oBrTra, ,"@E 999,999,999.99",NIL,.F.,.F.)
	oReport:GetFunction("fpp_PRCVENT"):SetFormula({|| oReport:GetFunction("fAUX1T"):uLastValue/oReport:GetFunction("fSALDOT"):uLastValue })

Return(oReport)

Static Function RPt3(oReport)

	Local oSecTra := oReport:Section(1)
	Local oSecVen := oReport:Section(2)
	Local oSecCli := oReport:Section(3)
	Local oSecPed := oReport:Section(4)
	Local oSecTot := oReport:Section(5)
	Local oSecTtt := oReport:Section(6)

	Local col := 0
	Local colPrint := 0
	Local linha := 0
	Local BreakRel

	Local cCliRep := ''
	Local cVenRep := ''
	Local cTraRep := ''

	Local cNumPed := ''
	Local pp_PRCVEN := ''
	Local bImprimeLinha := .F.
	Local lPassei := .F.
	Local lImpRod := .F.

	//tot = total //G = Geral //PM = preço médio //VP = volume pedido //VA = volume atendido //VS = volume saldo //PB = peso bruto
	Local totGPM := 0.0
	Local totGVP := 0.0
	Local totGVA := 0.0
	Local totGVS := 0.0
	Local totGPB := 0.0

	//tot = total //O = Observacao //PM = preço médio //VP = volume pedido //VA = volume atendido //VS = volume saldo //PB = peso bruto
	//1 - Bloqueio/Preço
	Local totOPM1 := 0.0
	Local totOVP1 := 0.0
	Local totOVA1 := 0.0
	Local totOVS1 := 0.0
	Local totOPB1 := 0.0
	//2 - Crédito
	Local totOPM2 := 0.0
	Local totOVP2 := 0.0
	Local totOVA2 := 0.0
	Local totOVS2 := 0.0
	Local totOPB2 := 0.0
	//3 - Estoque Disp./Crédito
	Local totOPM3 := 0.0
	Local totOVP3 := 0.0
	Local totOVA3 := 0.0
	Local totOVS3 := 0.0
	Local totOPB3 := 0.0
	//4 - Estoque Disp. Parcial
	Local totOPM4 := 0.0
	Local totOVP4 := 0.0
	Local totOVA4 := 0.0
	Local totOVS4 := 0.0
	Local totOPB4 := 0.0
	//5 Estoque Disp. Total
	Local totOPM5 := 0.0
	Local totOVP5 := 0.0
	Local totOVA5 := 0.0
	Local totOVS5 := 0.0
	Local totOPB5 := 0.0
	//6 - Em Carregamento Parcial
	Local totOPM6 := 0.0
	Local totOVP6 := 0.0
	Local totOVA6 := 0.0
	Local totOVS6 := 0.0
	Local totOPB6 := 0.0
	//7 - Em Carregamento Total
	Local totOPM7 := 0.0
	Local totOVP7 := 0.0
	Local totOVA7 := 0.0
	Local totOVS7 := 0.0
	Local totOPB7 := 0.0
	//8 - Verificar Estoque
	Local totOPM8 := 0.0
	Local totOVP8 := 0.0
	Local totOVA8 := 0.0
	Local totOVS8 := 0.0
	Local totOPB8 := 0.0
	//9 - Liberado/Aguardando RA
	Local totOPM9 := 0.0
	Local totOVP9 := 0.0
	Local totOVA9 := 0.0
	Local totOVS9 := 0.0
	Local totOPB9 := 0.0

	Local cTpTrans := ''
	Local nVlTran1 := 0.0
	Local nVlTran2 := 0.0
	Local nVlTran3 := 0.0
	Local nVlTran := 0.0

	dbSelectArea("CTRAB")
	CTRAB->(DbGotop())

	//Armazenar informacoes do Segmento
	aSegmento :=	{{"SEG"			,"C",20,0},;
		{"PRCVEN"		,"N",12,2},;
		{"QTDVEN"		,"N",12,2},;
		{"QTDENT"		,"N",12,2},;
		{"SALDO"		,"N",12,2},;
		{"SALVLR"		,"N",12,2},;
		{"PBRUTO"		,"N",12,2},;
		{"QUANT"		,"N",12,2}}
	If chkfile("_Segmento")
		dbSelectArea("_Segmento")
		dbCloseArea()
	EndIf
	_Segmento := CriaTrab(aSegmento)
	dbUseArea(.T.,,_Segmento,"_Segmento",.t.)
	dbCreateInd(_Segmento,"SEG",{||SEG})

	oReport:SetMeter(nTotReg)
	While !oReport:Cancel() .And. !CTRAB->(Eof())
		lPassei := .F.
		IF MV_PAR07 <> '123456789' //Todos os pedidos
			IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
				lPassei := .T.
			ENDIF
			IF lPassei
				DbSelectArea("cTrab")
				DbSkip()
				Loop
			ENDIF
		ENDIF

		oSecTra:SetHeaderSection(.T.)
		oSecTra:Init()

		oSecTra:Cell("C5_YTPTRAN"):SetValue(Alltrim(CTRAB->C5_YTPTRAN))
		oSecTra:PrintLine()

		cTraRep := CTRAB->C5_YTPTRAN

		While cTraRep == CTRAB->C5_YTPTRAN .And. CTRAB->(!Eof())
			lPassei := .F.
			IF MV_PAR07 <> '123456789' //Todos os pedidos
				IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
					lPassei := .T.
				ENDIF
				IF lPassei
					DbSelectArea("cTrab")
					DbSkip()
					Loop
				ENDIF
			ENDIF

			oSecVen:SetHeaderSection(.T.)
			oSecVen:Init()

			oSecVen:Cell("VENDEDOR"):SetValue(Alltrim(CTRAB->VENDEDOR))
			oSecVen:PrintLine()

			cVendRep := CTRAB->VENDEDOR

			oSecCli:Init()
			While cVendRep == CTRAB->VENDEDOR .And. CTRAB->(!Eof())
				lPassei := .F.
				IF MV_PAR07 <> '123456789' //Todos os pedidos
					IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
						lPassei := .T.
					ENDIF
					IF lPassei
						DbSelectArea("cTrab")
						DbSkip()
						Loop
					ENDIF
				ENDIF

				If bImprimeLinha == .T.
					oReport:ThinLine()
					bImprimeLinha := .T.
				EndIf

				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeeK(xFilial("SA1")+cTrab->CLI_ORIG)

				oSecCli:SetHeaderSection(.T.)
				oSecCli:Cell("CLIENTE"):SetValue(Space(5) + SubStr(Alltrim(cTrab->CLIENTE) + " - " + SA1->A1_NOME,1,30))
				oSecCli:Cell("CID_UF"):SetValue(Space(5) + SubStr(ALLTRIM(SA1->A1_MUN) +'/'+SA1->A1_EST,1,30))
				oSecCli:Cell("TRANSP"):SetValue(Space(5) + SubStr(cTrab->TRANSP,1,30))
				oSecCli:PrintLine()

				cCliRep := cTrab->CLIENTE

				oSecPed:Init()
				While cCliRep == cTrab->CLIENTE .And. CTRAB->(!Eof())
					lPassei := .F.
					IF MV_PAR07 <> '123456789' //Todos os pedidos
						IF !SUBSTR(cTrab->OBS,1,1) $ MV_PAR07
							lPassei := .T.
						ENDIF
						IF lPassei
							DbSelectArea("cTrab")
							DbSkip()
							Loop
						ENDIF
					ENDIF

					//Linha de Detalhe
					IF ALLTRIM(cTrab->C5_YCLIORI) = ''
						cNumPed  := cTrab->C5_NUM
					ELSE
						cNumPed  := "*"+cTrab->C5_NUM
					ENDIF

					IF ALLTRIM(cTrab->C5_TIPOCLI) <> "X"
						pp_PRCVEN  :=  cTrab->C6_PRCVEN

					ELSE
						pp_PRCVEN  :=  XMOEDA(cTrab->C6_PRCVEN,2,1, ddatabase)
					ENDIF

					oSecPed:Cell('PEDIDO'):SetValue(cNumPed)
					oSecPed:Cell('DT_EMISSAO'):SetValue(STOD(cTrab->C5_EMISSAO))
					oSecPed:Cell('COD_PROD'):SetValue(ALLTRIM(cTrab->PRO) + " " + ALLTRIM(cTrab->LOT))
					oSecPed:Cell('PRODUTO'):SetValue(SUBSTR(cTrab->B1_DESC,1,26))
					oSecPed:Cell('pp_PRCVEN'):SetValue(pp_PRCVEN)
					oSecPed:Cell('C6_QTDVEN'):SetValue(cTrab->C6_QTDVEN)
					oSecPed:Cell('C6_QTDENT'):SetValue(cTrab->C6_QTDENT)
					oSecPed:Cell('SALDO'):SetValue(cTrab->SALDO)
					oSecPed:Cell('PESO_BR'):SetValue(cTrab->PBRUTO)
					oSecPed:Cell('OBS'):SetValue(Space(3) + SUBSTR(ALLTRIM(cTrab->OBS), 1, 21))
					oSecPed:Cell('C6_YDTNECE'):SetValue(Space(3) + DTOC(STOD(cTrab->C6_YDTNECE)))
					oSecPed:Cell('C6_ENTREG'):SetValue(Space(3) + DTOC(STOD(cTrab->C6_ENTREG)))
					oSecPed:Cell('DTDISPOP'):SetValue(Space(3) +  DTOC(STOD(cTrab->DTDISPOP)))
					oSecPed:Cell('CONDPAG'):SetValue(Space(3) + cTrab->CONDPAG)
					oSecPed:Cell('EMPRESA'):SetValue(Space(3) + cTrab->EMPRESA)
					oSecPed:Cell('C5_YPC'):SetValue(Space(3) + cTrab->C5_YPC)
					oSecPed:Cell('AUX1'):SetValue(cTrab->SALDO * pp_PRCVEN)

					//SOMATÓRIO DO TOTAL GERAL
					totGPM := totGPM + (cTrab->SALDO * pp_PRCVEN)
					totGVP := totGVP + cTrab->C6_QTDVEN
					totGVA := totGVA + cTrab->C6_QTDENT
					totGVS := totGVS + cTrab->SALDO
					totGPB := totGPB + cTrab->PBRUTO

					//SOMATORIO OBS
					If SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '1'
						totOPM1 := totOPM1 + (cTrab->SALDO * pp_PRCVEN)
						totOVP1 := totOVP1 + cTrab->C6_QTDVEN
						totOVA1 := totOVA1 + cTrab->C6_QTDENT
						totOVS1 := totOVS1 + cTrab->SALDO
						totOPB1 := totOPB1 + cTrab->PBRUTO
					ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '2'
						totOPM2 := totOPM2 + (cTrab->SALDO * pp_PRCVEN)
						totOVP2 := totOVP2 + cTrab->C6_QTDVEN
						totOVA2 := totOVA2 + cTrab->C6_QTDENT
						totOVS2 := totOVS2 + cTrab->SALDO
						totOPB2 := totOPB2 + cTrab->PBRUTO
					ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '3'
						totOPM3 := totOPM3 + (cTrab->SALDO * pp_PRCVEN)
						totOVP3 := totOVP3 + cTrab->C6_QTDVEN
						totOVA3 := totOVA3 + cTrab->C6_QTDENT
						totOVS3 := totOVS3 + cTrab->SALDO
						totOPB3 := totOPB3 + cTrab->PBRUTO
					ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '4'
						totOPM4 := totOPM4 + (cTrab->SALDO * pp_PRCVEN)
						totOVP4 := totOVP4 + cTrab->C6_QTDVEN
						totOVA4 := totOVA4 + cTrab->C6_QTDENT
						totOVS4 := totOVS4 + cTrab->SALDO
						totOPB4 := totOPB4 + cTrab->PBRUTO
					ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '5'
						totOPM5 := totOPM5 + (cTrab->SALDO * pp_PRCVEN)
						totOVP5 := totOVP5 + cTrab->C6_QTDVEN
						totOVA5 := totOVA5 + cTrab->C6_QTDENT
						totOVS5 := totOVS5 + cTrab->SALDO
						totOPB5 := totOPB5 + cTrab->PBRUTO
					ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '6'
						totOPM6 := totOPM6 + (cTrab->SALDO * pp_PRCVEN)
						totOVP6 := totOVP6 + cTrab->C6_QTDVEN
						totOVA6 := totOVA6 + cTrab->C6_QTDENT
						totOVS6 := totOVS6 + cTrab->SALDO
						totOPB6 := totOPB6 + cTrab->PBRUTO
					ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '7'
						totOPM7 := totOPM7 + (cTrab->SALDO * pp_PRCVEN)
						totOVP7 := totOVP7 + cTrab->C6_QTDVEN
						totOVA7 := totOVA7 + cTrab->C6_QTDENT
						totOVS7 := totOVS7 + cTrab->SALDO
						totOPB7 := totOPB7 + cTrab->PBRUTO
					ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '8'
						totOPM8 := totOPM8 + (cTrab->SALDO * pp_PRCVEN)
						totOVP8 := totOVP8 + cTrab->C6_QTDVEN
						totOVA8 := totOVA8 + cTrab->C6_QTDENT
						totOVS8 := totOVS8 + cTrab->SALDO
						totOPB8 := totOPB8 + cTrab->PBRUTO
					ElseIf SubStr(ALLTRIM(cTrab->OBS), 1, 1) == '9'
						totOPM9 := totOPM9 + (cTrab->SALDO * pp_PRCVEN)
						totOVP9 := totOVP9 + cTrab->C6_QTDVEN
						totOVA9 := totOVA9 + cTrab->C6_QTDENT
						totOVS9 := totOVS9 + cTrab->SALDO
						totOPB9 := totOPB9 + cTrab->PBRUTO
					EndIf

					//SOMATÓRIO SEGMENTO
					//Armazena Valores Por Segmento
					dbSelectArea("_Segmento")
					dbSetOrder(1)
					If dbSeek(cTrab->SEGMENTO)
						RecLock("_Segmento",.F.)
						_Segmento->PRCVEN	:= _Segmento->PRCVEN + pp_PRCVEN
						_Segmento->QTDVEN	:= _Segmento->QTDVEN + cTrab->C6_QTDVEN
						_Segmento->QTDENT	:= _Segmento->QTDENT + cTrab->C6_QTDENT
						_Segmento->SALDO	:= _Segmento->SALDO  + cTrab->SALDO
						_Segmento->SALVLR	:= _Segmento->SALVLR + cTrab->(cTrab->SALDO * pp_PRCVEN)
						_Segmento->PBRUTO	:= _Segmento->PBRUTO + cTrab->PBRUTO
						_Segmento->QUANT	:= _Segmento->QUANT  + 1
					Else
						RecLock("_Segmento",.T.)
						_Segmento->SEG		:= cTrab->SEGMENTO
						_Segmento->PRCVEN	:= pp_PRCVEN
						_Segmento->QTDVEN	:= cTrab->C6_QTDVEN
						_Segmento->QTDENT	:= cTrab->C6_QTDENT
						_Segmento->SALDO	:= cTrab->SALDO
						_Segmento->SALVLR	:= cTrab->(cTrab->SALDO * pp_PRCVEN)
						_Segmento->PBRUTO	:= cTrab->PBRUTO
						_Segmento->QUANT	:= 1
					EndIf
					msUnLock()

					c001 := " 	SELECT COUNT(*) AS TOTREG					"
					c001 += " 	FROM	"+RetSqlName("SC9")+" WITH (NOLOCK) "
					c001 += " 	WHERE	C9_FILIAL = '"+xFilial('SC6')+"' AND		"
					c001 += " 				C9_AGREG		<> ''			AND			"
					c001 += " 			  C9_PEDIDO	  = '"+cTrab->C5_NUM+"'		AND			"
					c001 += " 	 			C9_PRODUTO	= '"+cTrab->C6_PRODUTO+"' AND		"
					c001 += " 	 			C9_ITEM	   	= '"+cTrab->C6_ITEM+"'	AND			"
					c001 += " 	 			C9_LOTECTL	= '"+cTrab->C6_LOTECTL+"'	AND		"
					c001 += " 	 			C9_BLEST	  = ''	AND			"
					c001 += " 	 			C9_BLCRED	  = ''	AND			"
					c001 += " 	 			D_E_L_E_T_	= ''		"
					IF chkfile("cTRB")
						dbSelectArea("cTRB")
						dbCloseArea()
					ENDIF
					//c001 := ChangeQuery(c001) //RETIRADO POIS NÃO RECONHECE O COMANDO WITH (NOLOCK)
					TCQUERY c001 ALIAS "cTRB" NEW

					IF cTRB->TOTREG >= 1
						DO CASE
						CASE cTrab->C5_YTPTRAN == '1'
							cTpTrans := 'Transportadora'
							nVlTran1 := nVlTran1 + cTrab->PBRUTO
						CASE cTrab->C5_YTPTRAN == '2'
							cTpTrans := 'Autônomo'
							nVlTran2 := nVlTran2 + cTrab->PBRUTO
						CASE cTrab->C5_YTPTRAN == '3'
							cTpTrans := 'Cliente Retira'
							nVlTran3 := nVlTran3 + cTrab->PBRUTO
						OTHERWISE
							cTpTrans := ''
							nVlTran  := nVlTran  + cTrab->PBRUTO
						ENDCASE
					ENDIF

					oSecPed:PrintLine()
					lImpRod := .T.

					oReport:IncMeter()                     //Incrementa a barra de progresso
					CTRAB->(dbSkip())

				End
				oSecPed:Finish()
			End
			oSecCli:Finish()
			oSecVen:Finish()

			bImprimeLinha := .F.
		End
		oSecTra:Finish()
	End

	If lImpRod == .T.

		oSecTot:Init()

		//IMPRIMINDO AS TOTALIZAÇÕES FINAIS, INCLUSIVE TOTAL GERAL
		oReport:SkipLine(2)

		oSecTot:Cell("PEDIDO"):SetValue("TOTAL GERAL")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totGPM/totGVS,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totGVP,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totGVA,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totGVS,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totGPB,2))
		oSecTot:PrintLine()

		oReport:SkipLine(2)
		oReport:FatLine()

		//TOTAIS OBS
		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("1 - Bloqueio/Preço")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM1/totOVS1,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP1,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA1,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS1,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB1,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("2 - Credito")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM2/totOVS2,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP2,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA2,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS2,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB2,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("3 - Estoque Disp./Credito")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM3/totOVS3,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP3,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA3,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS3,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB3,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("4 - Estoque Disp. Parcial")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM4/totOVS4,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP4,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA4,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS4,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB4,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("5 - Estoque Disp. Total")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM5/totOVS5,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP5,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA5,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS5,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB5,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("6 - Em Carregamento Parcial")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM6/totOVS6,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP6,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA6,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS6,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB6,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("7 - Em Carregamento Total")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM7/totOVS7,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP7,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA7,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS7,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB7,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("8 - Verificar Estoque")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM8/totOVS8,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP8,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA8,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS8,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB8,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)

		oSecTot:Cell("PEDIDO"):SetValue("9 - Liberado/Aguardando RA")
		oSecTot:Cell("pp_PRCVEN"):SetValue(Round(totOPM9/totOVS9,2))
		oSecTot:Cell("C6_QTDVEN"):SetValue(Round(totOVP9,2))
		oSecTot:Cell("C6_QTDENT"):SetValue(Round(totOVA9,2))
		oSecTot:Cell("SALDO"):SetValue(Round(totOVS9,2))
		oSecTot:Cell("PESO_BR"):SetValue(Round(totOPB9,2))
		oSecTot:PrintLine()

		oReport:SkipLine(1)
		oReport:ThinLine()

		//Imprime Totais por Segmento
		dbSelectArea("_Segmento")
		dbGoTop()
		While !eof()
			oReport:SkipLine(1)

			oSecTot:Cell("PEDIDO"):SetValue("Total Segmento " + _Segmento->SEG)
			oSecTot:Cell("pp_PRCVEN"):SetValue(Round(_Segmento->SALVLR/_Segmento->SALDO,2))
			oSecTot:Cell("C6_QTDVEN"):SetValue(Round(_Segmento->QTDVEN,2))
			oSecTot:Cell("C6_QTDENT"):SetValue(Round(_Segmento->QTDENT,2))
			oSecTot:Cell("SALDO"):SetValue(Round(_Segmento->SALDO,2))
			oSecTot:Cell("PESO_BR"):SetValue(Round(_Segmento->PBRUTO,2))
			oSecTot:PrintLine()

			dbSkip()
		End

		If chkfile("_Segmento")
			dbSelectArea("_Segmento")
			dbCloseArea()
		EndIf

		oReport:SkipLine(1)
		oReport:ThinLine()
		oReport:SkipLine(1)

		oSecTot:Finish()

		oSecTtt:Init()

		oSecTtt:Cell("DESCRICAO"):SetValue("Total Tipo de Transporte")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran1+nVlTran2+nVlTran3+nVlTran)
		oSecTtt:PrintLine()
		oSecTtt:Cell("DESCRICAO"):SetValue("Transportadora")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran1)
		oSecTtt:PrintLine()
		oSecTtt:Cell("DESCRICAO"):SetValue("Autônomo")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran2)
		oSecTtt:PrintLine()
		oSecTtt:Cell("DESCRICAO"):SetValue("Cliente Retira")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran3)
		oSecTtt:PrintLine()
		oSecTtt:Cell("DESCRICAO"):SetValue("Em Branco")
		oSecTtt:Cell("VALOR"):SetValue(nVlTran)
		oSecTtt:PrintLine()

		oSecTtt:Finish()
	EndIf

	CTRAB->(DbCloseArea())

Return
