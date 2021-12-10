#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIA086
@description Mapa de Pedidos Atendidos.
@author Fernando Rocha
@since 08/09/05 
@version 1.0
@version V12 revisado por Fernando Rocha

@type function
/*/
User Function BIA086()

	Local cLoad				:= "BIA086" + cEmpAnt
	Local cFileName			:= RetCodUsr() +"_"+ cLoad

	Local cArq    := ""
	Local cInd    := 0
	Local cReg	  := 0

	Local cArqSF4	:= ""
	Local cIndSF4	:= 0
	Local cRegSF4	:= 0

	Local cArqSA1	:= ""
	Local cIndSA1	:= 0
	Local cRegSA1	:= 0

	Local cArqSB1	:= ""
	Local cIndSB1	:= 0
	Local cRegSB1	:= 0

	Local cArqSA4	:= ""
	Local cIndSA4	:= 0
	Local cRegSA4	:= 0

	Local cArqSA3	:= ""
	Local cIndSA3 	:= 0
	Local cRegSA3	:= 0

	Local cArqSE4	:= ""
	Local cIndSE4	:= 0
	Local cRegSE4	:= 0

	Local cArqSC5	:= ""
	Local cIndSC5	:= 0
	Local cRegSC5	:= 0

	Local cArqSD2	:= ""
	Local cIndSD2	:= 0
	Local cRegSD2	:= 0

	Local cArqSF2	:= ""
	Local cIndSF2	:= 0
	Local cRegSF2	:= 0

	Private oAceTela 	:= TAcessoTelemarketing():New()

	Private Enter 	:= CHR(13)+CHR(10)
	Private nNomeSF2
	Private nNomeSD2

	cArq := Alias()
	cInd := IndexOrd()
	cReg := Recno()

	DbSelectArea("SF4")
	cArqSF4 := Alias()
	cIndSF4 := IndexOrd()
	cRegSF4 := Recno()

	DbSelectArea("SA1")
	cArqSA1 := Alias()
	cIndSA1 := IndexOrd()
	cRegSA1 := Recno()

	DbSelectArea("SB1")
	cArqSB1 := Alias()
	cIndSB1 := IndexOrd()
	cRegSB1 := Recno()

	DbSelectArea("SA4")
	cArqSA4 := Alias()
	cIndSA4 := IndexOrd()
	cRegSA4 := Recno()

	DbSelectArea("SA3")
	cArqSA3 := Alias()
	cIndSA3 := IndexOrd()
	cRegSA3 := Recno()

	DbSelectArea("SE4")
	cArqSE4 := Alias()
	cIndSE4 := IndexOrd()
	cRegSE4 := Recno()

	DbSelectArea("SC5")
	cArqSC5 := Alias()
	cIndSC5 := IndexOrd()
	cRegSC5 := Recno()

	DbSelectArea("SD2")
	cArqSD2 := Alias()
	cIndSD2 := IndexOrd()
	cRegSD2 := Recno()

	DbSelectArea("SF2")
	cArqSF2 := Alias()
	cIndSF2 := IndexOrd()
	cRegSF2 := Recno()

	SetPrvt("CDESC1,CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
	SetPrvt("TITULO,ARETURN,NOMEPROG,NLASTKEY,CBCONT")
	SetPrvt("CABEC1,CABEC2,CBTXT,LI,M_PAG")
	SetPrvt("WNFDE,WNFATE,WVENDDE,WVENDATE,WENTRDE,WENTRATE")
	SetPrvt("ACAMPO,WOLDDATA,WINCREGUA,WCTRANSP,WTRANSP")
	SetPrvt("TOTNF,TOTCLIENTE,TOTREPRESE,TOTGERAL,MEDIAS,OLDVEND")
	SetPrvt("OLDCLI,OLDNF,WPRIMVEZ,WLINDEIMP,cPerg")
	Private cTrab2, cTrab, cInd1, cInd2

	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	Private cRegDe := ""
	Private cRegAte := "ZZ"

	//Inicializa variaveis
	aOrd 				:= {}
	cDesc1			:= "Este programa tem como objetivo emitir um mapa de Pedidos"
	cDesc2			:= "atendidos por vendedor.             "
	cDesc3	    	:= ""
	tamanho			:= "G"
	limite			:= 200
	cString			:= "SF2"
	titulo			:= "MAPA DE PEDIDO ATENDIDOS"
	aReturn	    	:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	NomeProg 		:= "BIA086"
	cPerg	 		:= "BIA086"
	nLastKey 		:= cbcont := 0
	Cabec1			:= "NUMERO     DATA DE   CODIGO DO  DESCRICAO DO                         "
	Cabec1			:= Cabec1 + "       PRECO    QTD  M2        VALOR NF                                   "
	Cabec1			:= Cabec1 + "                                "
	Cabec2			:= "NF         EMISSAO   PRODUTO    PRODUTO                              "
	Cabec2			:= Cabec2 + "       MEDIO    N.FISCAL      (SEM IPI)  TRANSPORTADORA         PEDIDO    "
	Cabec2			:= Cabec2 + "EMISSAO     EMBARQUE  PRAZO                PESO NF  DESC INCOND.      PC "
	cbtxt 			:= space(10)
	li 	        	:= 80
	m_pag       	:= 1


	MV_PAR01 := SPACE(9) 		//		"NFe de 	?"
	MV_PAR02 := SPACE(9)    	//		"NFe ate	?"
	MV_PAR03 := SPACE(6)    	//		"Vendedor de	?"
	MV_PAR04 := SPACE(6)    	//		"Vendedor ate	?     "
	MV_PAR05 := STOD("")    	//		"Emissao NFe de  ?
	MV_PAR06 := STOD("")    	//		"Emissao NFe ate ?
	MV_PAR07 := 0    			//		"Preço Unitario de  ?
	MV_PAR08 := 0    			//		"Preço Unitario ate ?
	MV_PAR09 := SPACE(1)    	//		"CFO 511,611,618,711?
	MV_PAR10 := SPACE(1)    	//		"Somente sem Dt.Emb.?
	MV_PAR11 := SPACE(1)   		//		"Indice 14§ Salario ?
	MV_PAR12 := SPACE(6)   		//		"Cliente de	?"
	MV_PAR13 := SPACE(6)    	//		"Cliente ate	?     "
	MV_PAR14 := SPACE(8)    	//		"Produto de	?"
	MV_PAR15 := SPACE(8)    	//		"Produto ate	?     "
	MV_PAR16 := SPACE(1)    	//		"Distribuidor ?
	MV_PAR17 := SPACE(6)    	//		"Grupo de	?"
	MV_PAR18 := SPACE(6)    	//		"Grupo ate	?     "
	//MV_PAR19 := SPACE(1)    	//		"Tipo de Cliente ?
	MV_PAR19 := SPACE(1)    	//		"Tipo de Segmento ?
	MV_PAR20 := SPACE(2)    	//		"Tipo do Pedido ?
	MV_PAR21 := SPACE(1)    	//		"Qual Tipo          ?
	MV_PAR22 := SPACE(10)    	//		"Lote Inicial	?"
	MV_PAR23 := SPACE(10)    	//		"Lote Final	?"
	MV_PAR24 := SPACE(15)   	//		"Atendente?	"
	MV_PAR25 := SPACE(6)    	//		"Segmento De? "
	MV_PAR26 := SPACE(6)    	//		"Segmento Ate? "
	MV_PAR27 := SPACE(1)    	//		"Marca		?""
	MV_PAR28 := SPACE(15)    	//		"Pedido de Compra Cliente?	"
	MV_PAR29 := SPACE(1)    	//		"Exportar Para Excel?	"
	MV_PAR30 := SPACE(2)    	//		"Regiao De?  "
	MV_PAR31 := SPACE(2)    	//		"Regiao Ate? "
	MV_PAR32 := SPACE(6)    	//		"Rede de Compras De?  	"
	MV_PAR33 := SPACE(6)    	//		"Rede de Compras Ate? "
	MV_PAR34 := SPACE(6)    	//		"Pedido De	?"
	MV_PAR35 := SPACE(6)   		//		"Pedido Ate?"

	aMarca		:= {'1=Biancogres', '2=Incesa', '3=Bellacasa', '4=Incesa/Bellacasa', '5=Pegasus','6=Vinilico', '7=Todas'}
	aPergs		:= {}

	aAdd( aPergs ,{1,"NFe de"				, MV_PAR01	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"NFe ate"				, MV_PAR02	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Vendedor de"	   		, MV_PAR03	,"",,"SA3",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Vendedor ate"     		, MV_PAR04	,"",,"SA3",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Emissao NFe de"		, MV_PAR05	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Emissao NFe ate"		, MV_PAR06	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Preço Unitario de"		, MV_PAR07	,"@E 999,999,999.99","","",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Preço Unitario ate "		, MV_PAR08	,"@E 999,999,999.99","MV_PAR08>0", "",'.T.',50,.F.})
	aAdd( aPergs ,{2,"CFO 511,611,618,711"		, MV_PAR09, {'1=Sim', '2=Não'}, 50, ".T.",.F.})
	aAdd( aPergs ,{2,"Somente sem Dt.Emb."		, MV_PAR10, {'1=Sim', '2=Não'}, 50, ".T.",.F.})
	aAdd( aPergs ,{2,"Imprime Resumo"		, MV_PAR11, {'1=Sim', '2=Não'}, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Cliente de"	   		, MV_PAR12	,"",,"SA1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Cliente ate"     		, MV_PAR13	,"",,"SA1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto de"	   		, MV_PAR14	,"",,"SB1",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Produto ate"     		, MV_PAR15	,"",,"SB1",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Distribuidor "			, MV_PAR16, {'1=Sim', '2=Não', '3=Ambas'}, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Grupo de"	   			, MV_PAR17	,"",,"ACY",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Grupo ate"     			, MV_PAR18	,"",,"ACY",'.T.',50,.F.})
	//aAdd( aPergs ,{2,"Tipo de Cliente"		, MV_PAR19, {'1=Revenda', '2=Construtora', '3=Ambos'}, 50, ".T.",.F.})
	aAdd( aPergs ,{2,"Tipo de Segmento"		, MV_PAR19, {'1=Engenharia', '2=Home Center', '3=Revenda', '4=Exportação', '5=Todos'}, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Tipo do Pedido"			, MV_PAR20	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{2,"Qual Tipo"		, MV_PAR21, {'1=Tipo A', '2=Tipo C', '3=Tipo D', '4=Tipo Caco', '5=Ambos'}, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Lote Inicial"			, MV_PAR22	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Lote Final"			, MV_PAR23	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Atendente"	   			, MV_PAR24	,"",,"USR",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Segmento De"     		, MV_PAR25	,"",,"T3",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Segmento Ate"     		, MV_PAR26	,"",,"T3",'.T.',50,.F.})

	aAdd( aPergs ,{2,"Marca"				, MV_PAR27, aMarca, 50, ".T.",.F.})
	aAdd( aPergs ,{1,"Pedido de Compra Cliente", MV_PAR28	,"",,"",'.T.',50,.F.})

	aAdd( aPergs ,{2,"Exportar Para Excel"		, MV_PAR29, {'1=Sim', '2=Não'}, 50, ".T.",.F.})

	aAdd( aPergs ,{1,"Regiao De"     			, MV_PAR30	,"",,"12",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Regiao Ate"     			, MV_PAR31	,"",,"12",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Rede de Compras De"  	, MV_PAR32	,"",,"Z79",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Rede de Compras Ate" 	, MV_PAR33	,"",,"Z79",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Pedido De"				, MV_PAR34	,"",,"",'.T.',50,.F.})
	aAdd( aPergs ,{1,"Pedido Ate"				, MV_PAR35	,"",,"",'.T.',50,.F.})



	//Envia controle para a funcao SETPRINT
	//se não está entrando pelo browser
	If !GetRemoteType() == 5

		If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
			Return()
		EndIf

		//PERGUNTE(cPerg,.F.)

		NomeProg := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,tamanho,,.F.)

		IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
			Return
		ENDIF

		MV_PAR29 := Val(ParamLoad(cFileName,,29,MV_PAR29))

		//Verifica Posicao do Formulario na Impressora
		If MV_PAR29 == 2
			SetDefault(aReturn,cString)
		EndIf

		IF ( nLastKey == 27 ) .OR. ( LastKey() == 27 )
			Return
		ENDIF
		//entrando pelo browser
	Else
		/*If !Pergunte(cPerg,.T.)
			Return
	EndIf*/
	If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
			Return()
	EndIf
EndIf
	
	
	MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
	MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
	MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
	MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
	MV_PAR05 := ((ParamLoad(cFileName,,5,MV_PAR05)))
	MV_PAR06 := ((ParamLoad(cFileName,,6,MV_PAR06)))
	MV_PAR07 := (ParamLoad(cFileName,,7,MV_PAR07))
	MV_PAR08 := (ParamLoad(cFileName,,8,MV_PAR08))
	MV_PAR09 := Val(Alltrim(ParamLoad(cFileName,,9,MV_PAR09)))
	MV_PAR10 := Val(Alltrim(ParamLoad(cFileName,,10,MV_PAR10)))
	MV_PAR11 := Val(AllTrim(ParamLoad(cFileName,,11,MV_PAR11)))
	MV_PAR12 := ParamLoad(cFileName,,12,MV_PAR12)
	MV_PAR13 := ParamLoad(cFileName,,13,MV_PAR13)
	MV_PAR14 := ParamLoad(cFileName,,14,MV_PAR14)
	MV_PAR15 := ParamLoad(cFileName,,15,MV_PAR15)
	MV_PAR16 := Val(ParamLoad(cFileName,,16,MV_PAR16))
	MV_PAR17 := ParamLoad(cFileName,,17,MV_PAR17)
	MV_PAR18 := ParamLoad(cFileName,,18,MV_PAR18)
	MV_PAR19 := Val(ParamLoad(cFileName,,19,MV_PAR19))
	MV_PAR20 := ParamLoad(cFileName,,20,MV_PAR20)
	MV_PAR21 := Val(ParamLoad(cFileName,,21,MV_PAR21))
	MV_PAR22 := ParamLoad(cFileName,,22,MV_PAR22)
	MV_PAR23 := ParamLoad(cFileName,,23,MV_PAR23)
	MV_PAR24 := ParamLoad(cFileName,,24,MV_PAR24)
	MV_PAR25 := ParamLoad(cFileName,,25,MV_PAR25)
	MV_PAR26 := ParamLoad(cFileName,,26,MV_PAR26)
	MV_PAR27 := Val(ParamLoad(cFileName,,27,MV_PAR27))
	MV_PAR28 := ParamLoad(cFileName,,28,MV_PAR28)
	MV_PAR29 := Val(cvaltochar(ParamLoad(cFileName,,29,MV_PAR29)))
	MV_PAR30 := ParamLoad(cFileName,,30,MV_PAR30)
	MV_PAR31 := ParamLoad(cFileName,,31,MV_PAR31)
	MV_PAR32 := ParamLoad(cFileName,,32,MV_PAR32)
	MV_PAR33 := ParamLoad(cFileName,,33,MV_PAR33)
	MV_PAR34 := ParamLoad(cFileName,,34,MV_PAR34)
	MV_PAR35 := ParamLoad(cFileName,,35,MV_PAR35)
	
	
	

	wNfDe 	  := mv_par01 	// NF de
	wNfAte	  := mv_par02 	// NF ate
	wVendDe	  := IF(!EMPTY(CREPATU),CREPATU,MV_PAR03)
	wVendAte  := IF(!EMPTY(CREPATU),CREPATU,MV_PAR04)

IF !EMPTY(CREPATU) 		//SE REPRESENTANTE (VARIAVEL PRG BIA125)
		//Este período foi alterado por Wanisay no dia 10/12/15 conforme solicitação por e-mail e OS 4636-15  
		//Esta parametrização fará com que a performance do relatório seja prejudicada.
		//wEntrDe	  := IF(DTOS(MV_PAR05)<DTOS(ddatabase - 90),(ddatabase - 90),MV_PAR05) // emissao da NF 90 DIAS ANTES DA DATABASE
		//wEntrDe	  := IF(DTOS(MV_PAR05)<DTOS(ddatabase - 360),(ddatabase - 360),MV_PAR05) // emissao da NF 360 DIAS ANTES DA DATABASE	
		wEntrDe	  := IF(DTOS(MV_PAR05)<DTOS(ddatabase - 1825),(ddatabase - 1825),MV_PAR05) // emissao da NF 360 DIAS ANTES DA DATABASE	
		wEntrAte  := mv_par06	// emissao da NF ate
ELSE
		wEntrDe	  := mv_par05	// emissao da NF de
		wEntrAte  := mv_par06 	// emissao da NF ate
ENDIF

	wPrecoDe  := mv_par07 // Preco Unitario de
	wPrecoAte := mv_par08 // Preco Unitario Ate
	nCfo      := MV_PAR09 //1-sim, 2-nao
	nEmbarque := MV_PAR10 //1-sim, 2-nao
	wImpResumo:= mv_par11 // Imprime Resumo (1 = Sim ou 2 = Nao)

	wCliDe	  := MV_PAR12
	wCliAte   := MV_PAR13
	wGRUDe	  := MV_PAR17
	wGRUAte   := MV_PAR18
	wProdDe   := MV_PAR14
	wProdAte  := MV_PAR15
	wRestri	  := iif(mv_par16 = 1,"S","N")   // MADALENO   SOLICITADIO POR VAGNER E DIOGO
	cAtend    := MV_PAR24
	cPC       := MV_PAR28
	nEmp	  := "" 
	
	

	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	cRegDe := MV_PAR30
	cRegAte := MV_PAR31

If cEmpAnt == "01"
	Do Case
	Case MV_PAR27 == 1 	//BIANCOGRES
			nEmp	:= "0101"
	Case MV_PAR27 == 2 	//INCESA
			nEmp	:= "0501"
	Case MV_PAR27 == 3 	//BELLACASA
			nEmp	:= "0599"
	Case MV_PAR27 == 4	//INCESA/BELLACASA
			nEmp	:= "05"
	Case MV_PAR27 == 5	//Pegaus
			nEmp	:= "0199"
	Case MV_PAR27 == 6	//VINILICO
			nEmp	:= "1302"
	Case MV_PAR27 == 7	//TODAS
			nEmp	:= "XXXX"
	EndCase
Elseif cEmpAnt == "05"
	Do Case
	Case MV_PAR27 == 1 	//BIANCOGRES
			nEmp	:= "0101"
	Case MV_PAR27 == 2 	//INCESA
			nEmp	:= "0501"
	Case MV_PAR27 == 3 	//BELLACASA
			nEmp	:= "0599"
	Case MV_PAR27 == 4	//INCESA/BELLACASA
			nEmp	:= "05"
	Case MV_PAR27 == 5	//Pegaus
			nEmp	:= "0199"
	Case MV_PAR27 == 6	//VINILICO
			nEmp	:= "1302"
	Case MV_PAR27 == 7	//TODAS
			nEmp	:= "XXXX"
	EndCase
ElseIf cEmpAnt == "07"
	Do Case
	Case MV_PAR27 == 1 	//BIANCOGRES
			nEmp	:= "0101"
	Case MV_PAR27 == 2 	//INCESA
			nEmp	:= "0501"
	Case MV_PAR27 == 3 	//BELLACASA
			nEmp	:= "0599"
	Case MV_PAR27 == 4	//INCESA/BELLACASA
			nEmp	:= "05"
	Case MV_PAR27 == 5	//Pegaus
			nEmp	:= "0199"
	Case MV_PAR27 == 6	//VINILICO
			nEmp	:= "1302"
	Case MV_PAR27 == 7	//TODAS
			nEmp	:= "XXXX"
	EndCase
ElseIf cEmpAnt == "14"
	Do Case
	Case MV_PAR27 == 1 	//BIANCOGRES
			nEmp	:= "0101"
	Case MV_PAR27 == 2 	//INCESA
			nEmp	:= "0501"
	Case MV_PAR27 == 3 	//BELLACASA
			nEmp	:= "0599"
	Case MV_PAR27 == 4	//INCESA/BELLACASA
			nEmp	:= "05"
	Case MV_PAR27 == 5	//Pegaus
			nEmp	:= "0199"
	Case MV_PAR27 == 6	//VINILICO
			nEmp	:= "1302"
	Case MV_PAR27 == 7	//TODAS
			nEmp	:= "XXXX"
	EndCase
ElseIf cEmpAnt == "13"
	Do Case
	Case MV_PAR27 == 6	//VINILICO
			nEmp	:= "1302"
	EndCase
Else
	Do Case
	Case MV_PAR27 == 1 	//MUNDI
			nEmp	:= "1301"
	Case MV_PAR27 == 2 	//MUNDIALLI
			nEmp	:= "1399"
	Case MV_PAR27 == 2 	//MUNDIALLI
			nEmp	:= "13"
	EndCase
EndIf
	
if MV_PAR19 <> 5
	Do Case
	Case MV_PAR19 == 1 	//Engenharia
			nTipoSeg	:= "E"
	Case MV_PAR19 == 2 	//Home Center
			nTipoSeg	:= "H"
	Case MV_PAR19 == 3 	//Revenda
			nTipoSeg	:= "R"
	Case MV_PAR19 == 4 	//Exportação
			nTipoSeg	:= "X"
	EndCase
endif

	//Analisar qual o vendedor/representante ativo
	DBSELECTAREA("SF4")
	DBSETORDER(1)
	DBSELECTAREA("SA1")
	DBSETORDER(1)
	DBSELECTAREA("SB1")
	DBSETORDER(1)
	DBSELECTAREA("SA4")
	DBSETORDER(1)
	DBSELECTAREA("SA3")
	DBSETORDER(1)
	DBSELECTAREA("SE4")
	DBSETORDER(1)
	DBSELECTAREA("SC5")
	DBSETORDER(1)
	DBSELECTAREA("SD2")
	DBSETORDER(3)
	DBSELECTAREA("SF2")
	DBSETORDER(10) 

	//caso seja representante entrado pelo browser
If GetRemoteType() == 5
		RptStatus({|| BIA086TR() })
		Return
EndIf

	// Se deseja exportar para Excel - TReport
If MV_PAR29 == 1
		RptStatus({|| BIA086TR() })
		Return
EndIf

	fCriaArq() 

	RptStatus({|| fMapAtePed() })  // Fun‡Æo Mapa de Pedidos Atendidos// Substituido pelo assistente de conversao do AP5 IDE em 29/01/01 ==> 	RptStatus({|| Execute(fMapAtePed) })  // Fun‡Æo Mapa de Pedidos Atendidos

	DBSELECTAREA("cTrab")
	cTrab->(DBCLOSEAREA())

	FERASE(cTrab+".*")
	FERASE(cInd1+".*")

	DBSELECTAREA("cTrab2")
	cTrab2->(DBCLOSEAREA())

	FERASE(cTrab2+".*")
	FERASE(cInd2+".*")

If cArqSF4 <> ""
		DbSelectArea(cArqSF4)
		DbSetOrder(cIndSF4)
		DbGoTo(cRegSF4)
		RetIndex("SF4")
EndIf

If cArqSA1 <> ""
		dbSelectArea(cArqSA1)
		dbSetOrder(cIndSA1)
		dbGoTo(cRegSA1)
		RetIndex("SA1")
EndIf

If cArqSB1 <> ""
		DbSelectArea(cArqSB1)
		DbSetOrder(cIndSB1)
		DbGoTo(cRegSB1)
		RetIndex("SB1")
EndIf

If cArqSA4 <> ""
		DbSelectArea(cArqSA4)
		DbSetOrder(cIndSA4)
		DbGoTo(cRegSA4)
		RetIndex("SA4")
EndIf

If cArqSA3 <> ""
		dbSelectArea(cArqSA3)
		dbSetOrder(cIndSA3)
		dbGoTo(cRegSA3)
		RetIndex("SA3")
EndIf

If cArqSE4 <> ""
		dbSelectArea(cArqSE4)
		dbSetOrder(cIndSE4)
		dbGoTo(cRegSE4)
		RetIndex("SE4")
EndIf

If cArqSC5 <> ""
		dbSelectArea(cArqSC5)
		dbSetOrder(cIndSC5)
		dbGoTo(cRegSC5)
		RetIndex("SC5")
EndIf

If cArqSD2 <> ""
		dbSelectArea(cArqSD2)
		dbSetOrder(cIndSD2)
		dbGoTo(cRegSD2)
		RetIndex("SD2")
EndIf

If cArqSF2 <> ""
		dbSelectArea(cArqSF2)
		dbSetOrder(cIndSF2)
		dbGoTo(cRegSF2)
		RetIndex("SF2")
EndIf

If chkfile("_SX5")
		dbSelectArea("_SX5")
		dbCloseArea()
EndIf

	DbSelectArea(cArq)
	DbSetOrder(cInd)
	DbGoTo(cReg)

	//Libera impressao
IF aReturn[5] == 1
		Set Printer To
		Ourspool(NomeProg)
ENDIF

	MS_FLUSH()

RETURN( NIL )

Static FUNCTION fCriaArq()

	//Verifica se area de trabalho esta aberta e fecha
	If chkfile("cTrab")
		dbSelectArea("cTrab")
		dbCloseArea()
	EndIf

	//Cria Arquivo Temporario cTrab
	aCampo	  := ARRAY(24,4)
	aCampo[01] := { "PRODUTO ", "C", 15, 0 }
	aCampo[02] := { "CLIENTE ", "C", 50, 0 }
	aCampo[03] := { "ENDENT"  , "C", 40, 0 }
	aCampo[04] := { "NRNF"    , "C", 10, 0 }
	aCampo[05] := { "VENDEDOR", "C", 50, 0 }
	aCampo[06] := { "CONDPAG" , "C", 20, 0 }
	aCampo[07] := { "PEDIDO  ", "C", 06, 0 }
	aCampo[08] := { "TES     ", "C", 03, 0 }
	aCampo[09] := { "ITEM    ", "C", 02, 0 }
	aCampo[10] := { "EMISSAO" , "D", 08, 0 }
	aCampo[11] := { "EMBARQUE", "D", 08, 0 }
	aCampo[12] := { "EMISNF"  , "D", 08, 0 }
	aCampo[13] := { "DESC    ", "C", 30, 0 }
	aCampo[14] := { "PRCUNI  ", "N", 14, 2 }
	aCampo[15] := { "VLRTOT  ", "N", 14, 2 }
	aCampo[16] := { "QTDPED  ", "N", 14, 2 }
	aCampo[17] := { "PESOBRUT", "N", 14, 2 }
	aCampo[18] := { "TRANSP  ", "C", 15, 0 } 
	aCampo[19] := { "LOTE "   , "C", 10, 0 }
	aCampo[20] := { "DESC_INCO"   , "N", 14, 2 }
	aCampo[21] := { "PC      ", "C", 06, 0 }	
	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	aCampo[22] := {"CIDADE", "C", 36, 0 }
	aCampo[23] := {"ESTADO", "C", 02, 0 }
	aCampo[24] := {"YDTNERE", "D", 08, 0 }

	cTrab := CriaTrab(aCampo,.T.)
	dbUseArea(.T.,,cTrab,"cTrab",.F.,.F.)
	cInd1 := CriaTrab(NIL,.F.)
	IndRegua("cTrab",cInd1,"VENDEDOR+CLIENTE+NRNF",,,"Selecionando Registros...")

	If chkfile("cTrab2")
		dbSelectArea("cTrab2")
		dbCloseArea()
	EndIf

	//Cria Arquivo Temporario cTrab2
	aCampo2     := ARRAY(4,4)
	aCampo2[01] := { "CLIENTE ", "C", 50, 0 }
	aCampo2[02] := { "VENDEDOR", "C", 50, 0 }
	aCampo2[03] := { "EMISSAO" , "D", 08, 0 }
	aCampo2[04] := { "VLRTOT  ", "N", 12, 2 }

	cTrab2 := CriaTrab(aCampo2,.T.)
	dbUseArea(.T.,,cTrab2,"cTrab2",.F.,.F.)
	cInd2 := CriaTrab(NIL,.F.)
	IndRegua("cTrab2",cInd2,"CLIENTE",,,"Selecionando Registros...")

	//Monta arquivo de trabalho para impressao do Total por Segmento
	If chkfile("cTrab3")
		dbSelectArea("cTrab3")
		dbCloseArea()
	EndIf

	//Cria Arquivo Temporario cTrab3
	aCampo3     := ARRAY(3,4)
	aCampo3[01] := { "SEG"		, "C", 20, 0 }
	aCampo3[02] := { "QTDVEN"	, "N", 12, 2 }
	aCampo3[03] := { "VLRVEN"	, "N", 12, 2 }

	cTrab3 := CriaTrab(aCampo3,.T.)
	dbUseArea(.T.,,cTrab3,"cTrab3",.F.,.F.)
	cInd3 := CriaTrab(NIL,.F.)
	IndRegua("cTrab3",cInd3,"SEG",,,"Selecionando Registros...")

RETURN

Static FUNCTION fMapAtePed()
Local cQrySF2  := ""
Local cQrySD2  := ""
Local cQryPED  := ""
Local cDropSf2 := ""
Local cDropSd2 := ""

	nNomeSF2	:= "##BIA086SF2"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //strzero(seconds()*3500,10)
	nNomeSD2	:= "##BIA086SD2"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

	//Monta as querys para excluir as tabelas temporarias
	cDropSf2 := "DROP TABLE IF EXISTS " + nNomeSF2
	cDropSd2 := "DROP TABLE IF EXISTS " + nNomeSD2

	//Gerando tabela temporaria SF2
	cQrySF2 := GetSqlSF2()
	U_BIAMsgRun("Aguarde... Gerando Base... Cabeçalho da NF",,{|| TcSQLExec(cQrySF2)})

	//Gerando tabela temporaria SD2
	cQrySD2 := GetSqlSD2()	
	U_BIAMsgRun("Aguarde... Gerando Base... Itens da NF",,{|| TcSQLExec(cQrySD2)})

	// Carrega o sql dos pedidos..
	cQryPED := GetSqlPed()

	IF chkfile("cPed")
		dbSelectArea("cPed")
		dbCloseArea()
	ENDIF
	cQryPED := ChangeQuery(cQryPED)
	TCQUERY cQryPED ALIAS "cPed" NEW
	cPed->(dbGoTop())

	DBSELECTAREA("cPed")
	SETREGUA( RECCOUNT())

	WHILE !EOF()
		INCREGUA()

		IF ( LASTKEY() == 27 )
			EXIT
		ENDIF

		//Analisar
		/*IF (cPed->A1_SATIV1 == '000099' .AND. MV_PAR19 == 1) .OR. (cPed->A1_SATIV1 <> '000099' .AND. MV_PAR19 == 2)
			DBSELECTAREA("cPed")			
			DBSKIP()
			LOOP
	ENDIF*/

	IF EMPTY(CREPATU)
		IF mv_par16 <> 3
			IF wRestri = "S"
				If cempant = "01"
					IF cPed->A1_YRECR = "2" .OR. cPed->A1_YRECR = "4"
							DBSELECTAREA("cPed")							
							DBSKIP()
							LOOP
					END IF
				else
					IF cPed->A1_YRECR = "1" .OR. cPed->A1_YRECR = "4"
							DBSELECTAREA("cPed")							
							DBSKIP()
							LOOP
					END IF
				end if
			ELSE
				IF cPed->A1_YRECR <> "4"
						DBSELECTAREA("cPed")						
						DBSKIP()
						LOOP
				END IF
			END IF
		END IF
	END IF

		wcTransp := SPACE(6)
	If Empty(cPed->C5_TRANSP)
			wcTransp	:= "      "
			wTransp		:= "SEM FRETE     "
	Else
			wcTransp := cPed->C5_TRANSP
			wTransp  := cPed->A4_NREDUZ
	EndIf

		fGrava()

		DBSELECTAREA("cPed")
		DBSKIP()
END

	fImprime()

//Exclui as tabelas temporárias
U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(cDropSf2)})
U_BIAMsgRun("Aguarde... Gerando Base...",,{|| TcSQLExec(cDropSd2)})

RETURN( NIL )

STATIC FUNCTION fGrava()
	RECLOCK("cTrab",.T.)

	cTrab->VENDEDOR := cPed->F2_VEND1 + "-" + cPed->A3_NOME
	cTrab->CLIENTE  := cPed->A1_COD+"-"+cPed->A1_NOME
	cTrab->ENDENT   := cPed->A1_ENDENT

	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	cTrab->CIDADE   := AllTrim(cPed->A1_MUN)
	cTrab->ESTADO   := cPed->A1_EST

	IF !EMPTY(cPed->C5_YPEDORI)
		cTrab->NRNF	:= "*"+cPed->F2_DOC
	ELSE
		cTrab->NRNF	:= cPed->F2_DOC
	ENDIF

	IF !EMPTY(cPed->C5_YPEDORI)
		cTrab->PEDIDO   := cPed->C5_YPEDORI
	ELSE
		cTrab->PEDIDO   := cPed->C5_NUM
	ENDIF

	cTrab->ITEM	    := cPed->D2_ITEMPV
	cTrab->PRODUTO  := cPed->D2_COD
	cTrab->LOTE     := cPed->D2_LOTECTL
	cTrab->TES 	    := cPed->D2_TES
	cTrab->DESC	    := cPed->B1_YREF
	cTrab->EMISSAO  := STOD(cPed->C5_EMISSAO)
	cTrab->EMISNF   := STOD(cPed->F2_EMISSAO)
	cTrab->CONDPAG  := ALLTRIM(cPed->E4_DESCRI)
	cTrab->EMBARQUE := STOD(cPed->F2_YDES)
	cTrab->PRCUNI   := cPed->D2_PRCVEN
	cTrab->QTDPED   := cPed->D2_QUANT
	cTrab->VLRTOT   := cPed->D2_TOTAL
	cTrab->PESOBRUT := cPed->D2_QUANT * cPed->D2_PESO
	cTrab->TRANSP   := wTransp
	cTrab->DESC_INCO:= cPed->D2_DESCON
	cTrab->PC       := cPed->C5_YPC
	cTrab->YDTNERE  := STOD(cPed->C6_YDTNERE)


	cTrab->(MSUNLOCK())

	IF ! cTrab2->(DBSEEK(cPed->A1_COD+"-"+cPed->A1_NOME))
		RECLOCK("cTrab2",.T.)
		cTrab2->VENDEDOR := cPed->F2_VEND1+"-"+cPed->A3_NOME
		cTrab2->CLIENTE  := cPed->A1_COD+"-"+cPed->A1_NOME
		cTrab2->EMISSAO  := STOD(cPed->C5_EMISSAO)
		cTrab2->VLRTOT   := cPed->D2_TOTAL
	ELSE
		RECLOCK("cTrab2",.F.)
		cTrab2->VENDEDOR := cPed->F2_VEND1+"-"+cPed->A3_NOME
		cTrab2->CLIENTE  := cPed->A1_COD+"-"+cPed->A1_NOME
		cTrab2->EMISSAO  := STOD(cPed->C5_EMISSAO)
		cTrab2->VLRTOT   := cTrab2->VLRTOT + cPed->D2_TOTAL
	EndIf
	cTrab2->(MSUNLOCK())

	cQuery := " SELECT X5_DESCRI FROM "+RetSqlName("SX5")+" WHERE X5_TABELA = 'T3' AND X5_CHAVE = '"+cPed->A1_SATIV1+"' AND D_E_L_E_T_ = '' "
	If chkfile("_SX5")
		dbSelectArea("_SX5")
		dbCloseArea()
	EndIf
	TCQuery cQuery Alias "_SX5" New

	//Grava os totais por Segmento de Cliente
	dbSelectArea("cTrab3")
	dbSetOrder(1)
	If dbSeek(_SX5->X5_DESCRI)
		RecLock("cTrab3",.F.)
		cTrab3->QTDVEN	:= cTrab3->QTDVEN + cPed->D2_QUANT
		cTrab3->VLRVEN	:= cTrab3->VLRVEN + cPed->D2_TOTAL
	Else
		RecLock("cTrab3",.T.)
		cTrab3->SEG		:= _SX5->X5_DESCRI
		cTrab3->QTDVEN	:= cPed->D2_QUANT
		cTrab3->VLRVEN	:= cPed->D2_TOTAL
	EndIf
	cTrab3->(MSUNLOCK())

	DBCOMMIT()
RETURN( NIL )

Static FUNCTION fImprime()

	cTrab->(DBGOTOP())
	SETREGUA( cTrab->( LASTREC() ) )

	totNF 	  := { 0, 0, 0, 0, 0, 0 }
	totCliente := { 0, 0, 0, 0, 0, 0 }
	totReprese := { 0, 0, 0, 0, 0, 0 }
	totGeral   := { 0, 0, 0, 0, 0, 0 }

	//M.NF   M.CLI	M.VEN  M.GER
	Medias	  := { {0,0}, {0,0}, {0,0}, {0,0} }

	OldVend	  := cTrab->VENDEDOR
	OldCli	  := cTrab->CLIENTE
	OldNF 	  := cTrab->NRNF

	wPrimVez   := .T.           

	DbSelectArea("cTrab")

	WHILE ! cTrab->( EOF() )

		INCREGUA()

		IF li >= 58
			li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 2
		ENDIF

		IF wPrimVez
			@ li, 000 PSAY REPL("-",limite)
			li := li + 1
			@ li, 000 PSAY "VENDEDOR:" + cTrab->VENDEDOR
			li := li + 2
			// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
			@ li, 000 PSAY "CLIENTE: " + cTrab->CLIENTE + "  CIDADE/ESTADO: " + AllTrim(cTrab->CIDADE) + '/' + cTrab->ESTADO
			li := li + 2
			wPrimVez := .F.
		ENDIF

		IF ( OldNF #cTrab->NRNF ) .OR. ( OldCli # cTrab->CLIENTE ) .OR. ( OldVend # cTrab->VENDEDOR )

			wLinDeImp := "Total da N.Fiscal   " + SPACE( 48 ) + SPACE ( 07 )
			wLinDeImp := wLinDeImp + TRANS(Medias[1][2]/Medias[1][1],"@E 999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totNF[2],"@E 999,999.99") + SPACE( 05 )
			wLinDeImp := wLinDeImp + TRANS(totNF[4],"@E 999,999.99") + SPACE( 72 )
			wLinDeImp := wLinDeImp + TRANS(totNF[5],"@E 999,999.99") //+ SPACE( 02 )

			wLinDeImp := wLinDeImp + TRANS(totNF[6],"@E 999,999.99") + SPACE( 02 )

			@ li, 000 PSAY wLinDeImp
			li := li + 2

			totNF[1] 	 := totNF[2] := totNF[3] := totNF[4] := 0
			totNF[5] 	 := 0
			Medias[1][2] := Medias[1][1] := 0
			OldNF 		 := cTrab->NRNF

		ENDIF

		IF ( OldCli #cTrab->CLIENTE ) .OR. ( OldVend # cTrab->VENDEDOR )

			wLinDeImp := "Total do Cliente    "  + SPACE( 48 ) + SPACE ( 07 )
			wLinDeImp := wLinDeImp + TRANS(totCliente[4]/totCliente[2],"@E 999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totCliente[2],"@E 999,999.99") + SPACE( 05 )
			wLinDeImp := wLinDeImp + TRANS(totCliente[4],"@E 999,999.99") + SPACE( 82 )

			wLinDeImp := wLinDeImp + TRANS(totCliente[6],"@E 999,999.99") + SPACE( 02 )

			@ li, 000 PSAY wLinDeImp
			li := li + 1

			totCliente[1]:= totCliente[2]:= totCliente[3]:= totCliente[4]:= 0
			Medias[2][2] := Medias[2][1] := 0

		ENDIF

		IF ( OldVend # cTrab->VENDEDOR )

			wLinDeImp := "TOTAL DO VENDEDOR   "  + SPACE( 48 ) + SPACE ( 07 )
			wLinDeImp := wLinDeImp + TRANS(totReprese[4]/totReprese[2],"@E 999.99") + SPACE( 02 )
			wLinDeImp := wLinDeImp + TRANS(totReprese[2],"@E 999,999.99") + SPACE( 05 )
			wLinDeImp := wLinDeImp + TRANS(totReprese[4],"@E 999,999.99") + SPACE( 82 )

			wLinDeImp := wLinDeImp + TRANS(totReprese[6],"@E 999,999.99") + SPACE( 02 )

			li := li + 1
			@ li, 000 PSAY REPL("-",limite)
			li := li + 1
			@ li, 000 PSAY wLinDeImp
			li := li + 1
			@ li, 000 PSAY REPL("-",limite)
			li := li + 1

			totReprese[1]:= totReprese[2]:= totReprese[3]:= totReprese[4]:= 0
			Medias[3][2] := Medias[3][1] := 0

		ENDIF

		IF ( OldVend #cTrab->VENDEDOR )
			@ li, 000 PSAY "VENDEDOR:" + cTrab->VENDEDOR
			li := li + 2
			// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
			@ li, 000 PSAY "CLIENTE: " + cTrab->CLIENTE + "  CIDADE/ESTADO: " + AllTrim(cTrab->CIDADE) + '/' + cTrab->ESTADO
			li := li + 2
			OldVend := cTrab->VENDEDOR
		ELSEIF ( OldCli #cTrab->CLIENTE )
			li := li + 1
			// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
			@ li, 000 PSAY "CLIENTE: " + cTrab->CLIENTE + "  CIDADE/ESTADO: " + AllTrim(cTrab->CIDADE) + '/' + cTrab->ESTADO
			li := li + 2
			OldCli := cTrab->CLIENTE
		ENDIF

		wLinDeImp := cTrab->NRNF + SPACE( 1 )
		wLinDeImp := wLinDeImp + DTOC(cTrab->EMISNF)							 + SPACE( 2 )
		wLinDeImp := wLinDeImp + SUBS(cTrab->PRODUTO,1,8) 					     + SPACE( 2 )
		wLinDeImp := wLinDeImp + SUBS(cTrab->LOTE,1,6)   					     + SPACE( 2 )
		wLinDeImp := wLinDeImp + SUBS(cTrab->DESC,1,30)						     + SPACE( 6 )
		wLinDeImp := wLinDeImp + TRANS(cTrab->PRCUNI, "@E 999.99")               + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(cTrab->QTDPED, "@E 999,999.99")           + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(cTrab->VLRTOT, "@E 99,999,999.99")        + SPACE( 3 )
		wLinDeImp := wLinDeImp + cTrab->TRANSP									 + SPACE( 8 )
		wLinDeImp := wLinDeImp + cTrab->PEDIDO									 + SPACE( 3 )
		wLinDeImp := wLinDeImp + TRANS(cTrab->EMISSAO,  "@D")                    + SPACE( 4 )
		wLinDeImp := wLinDeImp + TRANS(cTrab->EMBARQUE, "@D")                    + SPACE( 2 )
		wLinDeImp := wLinDeImp + cTrab->CONDPAG 								 + SPACE( 2 )
		wLinDeImp := wLinDeImp + TRANS(cTrab->DESC_INCO, "@E 99,999,999.99")  	 + SPACE( 10 )
		wLinDeImp := wLinDeImp + cTrab->PC

		@ li, 000 PSAY wLinDeImp

		li := li + 1

		OldNF   := cTrab->NRNF
		OldCli  := cTrab->CLIENTE
		OldVend := cTrab->VENDEDOR

		// ACUMULA SOMENTE SE AS NOTAS FISCAIS NAO FOR DE OUTRAS SAIDAS
		totNF[2]  := totNF[2] + cTrab->QTDPED
		totNF[4]  := totNF[4] + cTrab->VLRTOT
		totNF[5]  := totNF[5] + cTrab->PESOBRUT
		totNF[6]  := totNF[6] + cTrab->DESC_INCO

		totCliente[2] := totCliente[2] + cTrab->QTDPED
		totCliente[4] := totCliente[4] + cTrab->VLRTOT
		totCliente[6] := totCliente[6] + cTrab->DESC_INCO

		totReprese[2] := totReprese[2] + cTrab->QTDPED
		totReprese[4] := totReprese[4] + cTrab->VLRTOT
		totReprese[6] := totReprese[6] + cTrab->DESC_INCO

		totGeral[2]   := totGeral[2]	+ cTrab->QTDPED
		totGeral[4]   := totGeral[4]	+ cTrab->VLRTOT
		totGeral[6]   := totGeral[6] 	+ cTrab->DESC_INCO

		Medias[1][1]  := Medias[1][1] + 1
		Medias[2][1]  := Medias[2][1] + 1
		Medias[3][1]  := Medias[3][1] + 1
		Medias[4][1]  := Medias[4][1] + 1

		Medias[1][2]  := Medias[1][2] + cTrab->PRCUNI
		Medias[2][2]  := Medias[2][2] + cTrab->PRCUNI
		Medias[3][2]  := Medias[3][2] + cTrab->PRCUNI
		Medias[4][2]  := Medias[4][2] + cTrab->PRCUNI

		DbSelectArea("cTrab")	
		DBSKIP()
	ENDDO

	wLinDeImp := "Total da N.Fiscal   " + SPACE( 48 ) + SPACE ( 07 )
	wLinDeImp := wLinDeImp + TRANS(totNF[4]/totNF[2],"@E 999.99") + SPACE( 02 )
	wLinDeImp := wLinDeImp + TRANS(totNF[2],"@E 999,999.99") + SPACE( 05 )
	wLinDeImp := wLinDeImp + TRANS(totNF[4],"@E 999,999.99") + SPACE( 72 )
	wLinDeImp := wLinDeImp + TRANS(totNF[6],"@E 999,999.99") + SPACE( 02 )
	@ li, 000 PSAY wLinDeImp
	li := li + 1

	wLinDeImp := "Total do Cliente    "  + SPACE( 48 ) + SPACE ( 07 )
	wLinDeImp := wLinDeImp + TRANS(totCliente[4]/totCliente[2],"@E 999.99") + SPACE( 02 )
	wLinDeImp := wLinDeImp + TRANS(totCliente[2],"@E 99,999,999.99") + SPACE( 02 )
	wLinDeImp := wLinDeImp + TRANS(totCliente[4],"@E 99,999,999.99") + SPACE( 82 )
	wLinDeImp := wLinDeImp + TRANS(totCliente[6],"@E 99,999,999.99") + SPACE( 02 )

	IF li >= 50
		li := Cabec(titulo,cabec1,cabec2,nomeprog,tamanho,15) + 2
	ENDIF

	li := li + 1
	@ li, 000 PSAY wLinDeImp
	li := li + 1

	wLinDeImp := "TOTAL DO VENDEDOR   "  + SPACE( 48 ) + SPACE ( 07 )
	wLinDeImp := wLinDeImp + TRANS(totReprese[4]/totReprese[2],"@E 999.99") + SPACE( 02 )
	wLinDeImp := wLinDeImp + TRANS(totReprese[2],"@E 99,999,999.99") + SPACE( 02 )
	wLinDeImp := wLinDeImp + TRANS(totReprese[4],"@E 99,999,999.99") + SPACE( 82 )
	wLinDeImp := wLinDeImp + TRANS(totReprese[6],"@E 99,999,999.99") + SPACE( 04 )

	li := li + 1
	@ li, 000 PSAY REPL("-",limite)
	li := li + 1
	@ li, 000 PSAY wLinDeImp
	li := li + 1
	@ li, 000 PSAY REPL("-",limite)
	li := li + 1

	wLinDeImp := "TOTAL GERAL         " + SPACE( 48 ) + SPACE ( 07 )
	wLinDeImp := wLinDeImp + TRANS(totGeral[4]/totGeral[2],"@E 999.99") + SPACE( 02 )
	wLinDeImp := wLinDeImp + TRANS(totGeral[2],"@E 99,999,999.99") + SPACE( 02 )
	wLinDeImp := wLinDeImp + TRANS(totGeral[4],"@E 99,999,999.99") + SPACE(82)
	wLinDeImp := wLinDeImp + TRANS(totGeral[6],"@E 99,999,999.99") + SPACE(04)
	@ li, 000 PSAY wLinDeImp
	li := li + 1

	//Imprime Total por Segmento
	@ li, 000 PSAY REPL("-",limite)
	li := li + 1
	dbSelectArea("cTrab3")
	dbGoTop()
	While !eof()
		@ li, 000  PSAY "TOTAL SEGMENTO " + cTrab3->SEG + " % M2 " + Transform(  ((  cTrab3->QTDVEN / totGeral[2] )*100)   ,"@E 99.99")
		@ li, 072  PSAY Transform(cTrab3->VLRVEN/cTrab3->QTDVEN,"@E 999.99")
		@ li, 080  PSAY Transform(cTrab3->QTDVEN,"@E 99,999,999.99")
		@ li, 095  PSAY Transform(cTrab3->VLRVEN,"@E 99,999,999.99")
		li++  
		DbSelectArea("cTrab3")	
		dbSkip()
	End
	@ li, 000 PSAY REPL("-",limite)

	If wImpResumo == 1
		RptStatus({|| fImpResumo() })
	EndIf

	Roda(cbcont,cbtxt,tamanho)

RETURN( NIL )

Static FUNCTION fImpResumo()

	cTrab2->(DBGOTOP())

	SETREGUA( cTrab2->( LASTREC() ) )
	li         := 80
	Cabec3     := "------------------------------------------------ RESUMO DOS CLIENTES ---------------------------------------------------"
	Cabec4     := "Cliente                                             Vendedor                                               Total Cliente"

	totCliente := 0
	OldCli	   := cTrab2->CLIENTE
	OldVend    := cTrab2->VENDEDOR

	// SE€ÇO IMPRESSAO
	WHILE ! cTrab2->( EOF() )

		INCREGUA()
		// IMPRIME CABE€ALHO
		IF li >= 58
			li := Cabec(titulo,Cabec3,Cabec4,nomeprog,tamanho,15) + 2
		ENDIF

		IF ( OldCli # cTrab2->CLIENTE ) .OR. ( OldVend # cTrab2->VENDEDOR )
			wLinDeImp := " " + OldCli + SPACE(3)
			wLinDeImp := wLinDeImp + OldVend + SPACE(3)
			wLinDeImp := wLinDeImp + TRANS(totCliente,"@E 99,999,999.99")
			@ li, 000 PSAY wLinDeImp
			li := li + 1
			totCliente := 0
			OldCli	  := cTrab2->CLIENTE
			OldVend    := cTrab2->VENDEDOR
		ENDIF

		totcliente := totcliente + cTrab2->VLRTOT

		DbSelectArea("cTrab2")	
		cTrab2->(DBSKIP())
	ENDDO

	wLinDeImp := " " + OldCli + SPACE(3)
	wLinDeImp := wLinDeImp + OldVend + SPACE(3)
	wLinDeImp := wLinDeImp + TRANS(totCliente,"@E 99,999,999.99")
	@ li, 000 PSAY wLinDeImp
	li := li + 1
	totCliente := 0
	OldCli	  := cTrab2->CLIENTE
	OldVend   := cTrab2->VENDEDOR

RETURN

//----------------------------------------------------------------------------------
// BLOCO DE CONSULTAS SQLs
//----------------------------------------------------------------------------------
Static Function GetSqlSF2()
Local cSqlRet := ''

cSqlRet := ""
cSqlRet += " SELECT ( " + Enter
cSqlRet += "	SELECT ATENDE FROM dbo.[GET_ZKP] (A1_YTPSEG, F2_YEMP, F2_EST, F2_VEND1, A1_YCAT, A1_GRPVEN) ) ATENDE, * " + Enter 
cSqlRet += "  INTO "+nNomeSF2+" FROM (                                                          " + Enter
cSqlRet += "    SELECT VW_SF2.*, A1_YTPSEG, A1_YCAT, A1_GRPVEN                                  " + Enter
cSqlRet += "     FROM VW_SF2                                                                    " + Enter   
cSqlRet += "      INNER JOIN SA1010 A1                                                          " + Enter
cSqlRet += "       ON      A1_FILIAL       = '"+xFilial('SA1')+"'                               " + Enter
cSqlRet += "       AND     F2_CLIENTE   = A1.A1_COD                                             " + Enter
cSqlRet += "       AND     F2_LOJA      = A1.A1_LOJA                                            " + Enter
cSqlRet += "       AND     A1.D_E_L_E_T_   = ''                                                 " + Enter
cSqlRet += "	 WHERE 	F2_FILIAL 	= '"+xFilial("SF2")+"' AND 									" + Enter
cSqlRet += "			F2_EMISSAO  BETWEEN '"+DTOS(wEntrDe)+"' AND '" +DTOS(wEntrAte)+"'   	" + Enter

If Len(Alltrim(nEmp)) == 4 .And. ( Alltrim(nEmp) <> "XXXX" )
	cSqlRet += "	AND F2_YEMP	= '"+nEmp+"' 													" + Enter
ElseIf Len(Alltrim(nEmp)) == 2
	cSqlRet += "	AND SUBSTRING(F2_YEMP,1,2) = '"+nEmp+"' 									" + Enter
EndIf

If (oAceTela:UserTelemaketing())
	cSqlRet += " AND ( "+oAceTela:FiltroSA1('S')+" ) 											" + Enter	
EndIf
					
cSqlRet += " ) AS TMP 																			" + Enter

Return cSqlRet
//----------------------------------------------------------------------------------
Static Function GetSqlSD2()
	Local cSqlRet := ''

	cSqlRet := ""
	cSqlRet += "SELECT * INTO "+nNomeSD2+" FROM (													" + Enter
	cSqlRet += "	SELECT VWSD2.* , VWSC6.C6_YDTNERE" + Enter
	cSqlRet += "	FROM VW_SD2 VWSD2																" + Enter
 
	cSqlRet += " INNER JOIN VW_SC6  VWSC6	                " + Enter
	cSqlRet += " ON  VWSD2.D2_YEMPORI = VWSC6.C6_YEMPORI 	" + Enter
	cSqlRet += " AND VWSD2.D2_FILIAL  = VWSC6.C6_FILIAL 	" + Enter
	cSqlRet += " AND VWSD2.D2_PEDIDO  = VWSC6.C6_NUM 	    " + Enter
	cSqlRet += " AND VWSD2.D2_COD     = VWSC6.C6_PRODUTO 	" + Enter
	cSqlRet += " AND VWSD2.D2_ITEMPV  = VWSC6.C6_ITEM 	  " + Enter
 
	cSqlRet += "	WHERE 	VWSD2.D2_FILIAL 	= '"+xFilial("SC5")+"' AND 									" + Enter
	cSqlRet += "			VWSD2.D2_EMISSAO  BETWEEN '"+DTOS(wEntrDe)+"' AND '" +DTOS(wEntrAte)+"' 	 	" + Enter
	If Len(Alltrim(nEmp)) == 4 .And. ( Alltrim(nEmp) <> "XXXX" )
		cSqlRet += "	AND VWSD2.D2_YEMP	= '"+nEmp+"' 													" + Enter
	ElseIf Len(Alltrim(nEmp)) == 2
		cSqlRet += "	AND SUBSTRING(VWSD2.D2_YEMP,1,2) = '"+nEmp+"' 									" + Enter
	EndIf
	cSqlRet += " ) AS TMP	 																		" + Enter

Return cSqlRet
//----------------------------------------------------------------------------------
Static Function GetSqlPed(lpOrdena)
	Local cSqlRet := ''

	cSqlRet +=" SELECT F2_FILIAL, F2_EMISSAO, F2_CLIENTE, F2_LOJA, F2_DOC, F2_SERIE, F2_VEND1, F2_YSUBTP,D2_VALBRUT, D2_PEDIDO, F2_YDES, 						" + Enter
	cSqlRet +=" 			A1_YVENDB2, A1_YVENDB3, A1_YVENDB3, A1_YVENDI3, A1_SATIV1, A1_YRECR, A1.A1_GRPVEN, A1_YRECR, A1_COD, A1_NOME, A1_ENDENT,	" + Enter
	cSqlRet +=" 			C5_NUM, C5_YPC, C5_CLIENTE, C5_LOJACLI, C5_TRANSP, C5_CONDPAG, C5_EMISSAO, E4_DESCRI, 						            " + Enter
	cSqlRet +=" 			D2_TIPO, D2_COD, D2_ITEMPV, D2_LOTECTL, D2_PRCVEN, D2_QUANT, D2_TOTAL, D2_PESO, D2_CF, D2_TES, 		             " + Enter
	cSqlRet +=" 			B1_TIPO, B1_YREF, A4_NREDUZ, B1_YCLASSE, F4_DUPLIC, A3_NOME, F2_YEMP, C5_YPEDORI, D2_DESCON, C6_YDTNERE , 					" + Enter
	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	cSqlRet +=" 			A1_EST, A1_MUN			" + Enter
	cSqlRet +=" FROM "+nNomeSF2+" F2                                                                                                     			" + Enter
	cSqlRet +=" INNER JOIN "+nNomeSD2+" D2                                                                                                			" + Enter
	cSqlRet +=" ON		D2_FILIAL		= '"+xFilial('SD2')+"' 	                                                                        			" + Enter
	cSqlRet +=" AND 	F2.F2_DOC		= D2.D2_DOC				                                                                                    " + Enter
	cSqlRet +=" AND		F2.F2_SERIE     = D2.D2_SERIE                                                                                               " + Enter
	cSqlRet +=" AND		F2.F2_CLIENTE   = D2.D2_CLIENTE	                                                                                            " + Enter
	cSqlRet +=" AND		F2.F2_LOJA		= D2.D2_LOJA	                                                                                            " + Enter
	cSqlRet +=" AND		F2.F2_YEMP		= D2.D2_YEMP	                                                                                            " + Enter
	cSqlRet +=" AND 	F2.F2_YEMPORI	= D2.D2_YEMPORI                                                                                             " + Enter
	cSqlRet +=" INNER JOIN VW_SC5 C5                                                                                                                " + Enter
	cSqlRet +=" ON		C5_FILIAL		= '"+xFilial('SC5')+"'                                                                             			" + Enter
	cSqlRet +=" AND		D2.D2_PEDIDO	= C5.C5_NUM		                                                                                            " + Enter
	cSqlRet +=" AND		F2.F2_CLIENTE   = C5.C5_CLIENTE	                                                                                            " + Enter
	cSqlRet +=" AND		F2.F2_YEMPORI	= C5.C5_YEMPORI	                                                                                        	" + Enter
	cSqlRet +=" AND		C5.D_E_L_E_T_	= ''	                                                                                                    " + Enter
	cSqlRet +=" INNER JOIN SA1010 A1                                                                                                                " + Enter
	cSqlRet +=" ON		A1_FILIAL		= '"+xFilial('SA1')+"'                                                                               		" + Enter
	cSqlRet +=" AND		F2.F2_CLIENTE   = A1.A1_COD		                                                                                            " + Enter
	cSqlRet +=" AND		F2.F2_LOJA      = A1.A1_LOJA	                                                                                            " + Enter
	cSqlRet +=" AND		A1.D_E_L_E_T_	= ''                                                                                                        " + Enter
	cSqlRet +=" INNER JOIN SA3010 A3                                                                                                                " + Enter
	cSqlRet +=" ON		A3_FILIAL		= '"+xFilial('SA3')+"'		                                                                               	" + Enter
	cSqlRet +=" AND		F2.F2_VEND1		= A3.A3_COD	                                                                                                " + Enter
	cSqlRet +=" AND		A3.D_E_L_E_T_	= ''                                                                                                        " + Enter
	cSqlRet +=" LEFT JOIN SA4010 A4                                                                                                                 " + Enter
	cSqlRet +=" ON		A4_FILIAL		= '"+xFilial('SA4')+"'                                                                               		" + Enter
	cSqlRet +=" AND		F2.F2_TRANSP	= A4.A4_COD	                                                                                                " + Enter
	cSqlRet +=" AND		A4. D_E_L_E_T_  = ''                                                                                                        " + Enter
	cSqlRet +=" INNER JOIN "+RetSqlName("SE4")+" E4                                                                                    				" + Enter
	cSqlRet +=" ON		E4_FILIAL		= '"+xFilial('SE4')+"'                                                                              		" + Enter
	cSqlRet +=" AND		F2.F2_COND   	= E4.E4_CODIGO                                                                                              " + Enter
	cSqlRet +=" AND		E4.D_E_L_E_T_	= ''	                                                                                                    " + Enter
	cSqlRet +=" INNER JOIN SB1010 B1                                                                                                                " + Enter
	cSqlRet +=" ON		B1_FILIAL		= '"+xFilial('SB1')+"'	                                                                                	" + Enter
	cSqlRet +=" AND		D2.D2_COD   	= B1.B1_COD                                                                                                 " + Enter
	cSqlRet +=" AND		B1.D_E_L_E_T_	= ''                                                                                                        " + Enter
	cSqlRet +=" WHERE 	F2_FILIAL   = '"+xFilial('SF2')+"' 	                                                        								" + Enter
	cSqlRet +=" AND		F2.F2_EMISSAO BETWEEN '"+DTOS(wEntrDe)+"' AND '" +DTOS(wEntrAte)+"'                           		 						" + Enter
	cSqlRet +=" AND		F2.F2_DOC     BETWEEN '"+wNFDe+"'     AND '" +wNFAte+"'                                                         			" + Enter
	cSqlRet +=" AND		A1.A1_SATIV1  BETWEEN '"+MV_PAR25+"'  AND '" +MV_PAR26+"'                                                       			" + Enter
	cSqlRet +=" AND		A1.A1_GRPVEN  BETWEEN '"+wGRUDe+"'    AND '" +wGRUAte+"'                                                        			" + Enter
	cSqlRet +=" AND		A1.A1_COD     BETWEEN '"+wCliDe+"'   AND '" +wCliAte+"'                                                        				" + Enter
	cSqlRet +=" AND		A1.A1_YREDCOM BETWEEN '"+MV_PAR32+"' AND '" +MV_PAR33+"'                                                       				" + Enter
	cSqlRet +=" AND		D2.D2_COD     BETWEEN '"+wProdDe+"'  AND '" +wProdAte+"'                                                       				" + Enter
	cSqlRet +=" AND		D2.D2_LOTECTL BETWEEN '"+MV_PAR22+"' AND '" +MV_PAR23+"'                                                       				" + Enter
	cSqlRet +=" AND		D2.D2_PRCVEN  BETWEEN '"+ALLTRIM(STR(wPrecoDe,12,2))+"'  AND '" +ALLTRIM(STR(wPrecoAte,12,2))+"'                 			" + Enter
	cSqlRet +=" AND		F2.F2_COND  	<> ''	                                                                                                    " + Enter
	cSqlRet +=" AND		F2.F2_VEND1 	<> ''	                                                                                                    " + Enter
	cSqlRet +=" AND		D2.D2_TIPO   	= 'N'	                                                                                                    " + Enter
	cSqlRet +=" AND		B1.B1_TIPO  	in ('PA','PR')                                                                                              " + Enter

	cSqlRet +=" AND		(CASE WHEN C5.C5_YPEDORI <> '' THEN C5.C5_YPEDORI ELSE C5.C5_NUM END )  BETWEEN '"+MV_PAR34+"' AND '" +MV_PAR35+"' 			" + Enter

	If (!Empty(MV_PAR34) .And. !Empty(MV_PAR35))
		cSqlRet +=" AND 	 F2_CLIENTE NOT IN ('010064','000481', '004536', '018410', '014395', '008615')												" + Enter
	EndIf

	If Len(Alltrim(nEmp)) == 4 .And. ( Alltrim(nEmp) <> "XXXX" )
		cSqlRet += "	AND		F2.F2_YEMP	 	= '"+nEmp+"' " + Enter
		cSqlRet += "	AND		C5.C5_YEMP 		= '"+nEmp+"' " + Enter
	ElseIf Len(Alltrim(nEmp)) == 2
		cSqlRet += "	AND		SUBSTRING(F2.F2_YEMP,1,2) = '"+nEmp+"' " + Enter
		cSqlRet += "	AND		SUBSTRING(C5.C5_YEMP,1,2) = '"+nEmp+"' " + Enter
	EndIf

	If Alltrim(cPC) <> ""
		cSqlRet += "	AND		C5.C5_YPC = '"+cPC+"' " + Enter
	EndIf

	If !Empty(CREPATU) .AND. SUBSTRING(CREPATU,1,1) == "1"
		If nEmp == "0101"
			cSqlRet += " AND			(A1.A1_YVENDB2 = '"+CREPATU+"' OR A1.A1_YVENDB3 =  '"+CREPATU+"') " + Enter
		ElseIf nEmp == "0501"
			cSqlRet += "	AND		(A1.A1_YVENDI2 = '"+CREPATU+"' OR A1.A1_YVENDI3 =  '"+CREPATU+"')  " + Enter
		ElseIf nEmp == "0599"
			cSqlRet += "	AND		(A1.A1_YVENBE2 = '"+CREPATU+"' OR A1.A1_YVENBE3 =  '"+CREPATU+"')  " + Enter
		ElseIf nEmp == "05"
			cSqlRet += "	AND		(A1.A1_YVENDI2 = '"+CREPATU+"' OR A1.A1_YVENDI3 =  '"+CREPATU+"' OR A1.A1_YVENBE2 = '"+CREPATU+"' OR A1.A1_YVENBE3 =  '"+CREPATU+"') " + Enter
		EndIf
		cSqlRet += "	AND		F2.F2_VEND1 BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  " + Enter

	Else
		cSqlRet += "	AND		F2.F2_VEND1 BETWEEN '"+wVendDe+"' AND '"+wVendAte+"'  " + Enter
		//Filtra Vendedor por Atendente
		If Alltrim(cAtend) <> ""
            cSqlRet += "    AND F2.ATENDE = '"+cAtend+"'  " + Enter
        EndIf

		/*
		If Alltrim(cAtend) <> ""
			If cEmpAnt == '01'
				cSqlRet += "	AND	F2.F2_VEND1 IN (SELECT ZZI_VEND FROM "+RetSqlName("ZZI")+" WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND ZZI_ATENDE = '"+cAtend+"'	AND D_E_L_E_T_ = '')  " + Enter
			Else
				cSqlRet += "	AND	F2.F2_VEND1 IN (SELECT ZZI_VEND FROM ZZI050 WHERE ZZI_FILIAL = '"+xFilial("ZZI")+"'	AND ZZI_ATENDE = '"+cAtend+"'	AND D_E_L_E_T_ = '')  " + Enter
			EndIf
		EndIf
		*/
	EndIf

	If !Empty(MV_PAR19) .AND. MV_PAR19 <> 5
		//1=Engenharia, 2=Home Center, 3=Revenda, 4=Exportação, 5=Todos
		cSqlRet += " AND A1.A1_YTPSEG = '" + nTipoSeg + "'  " + Enter
	EndIf

	If !Empty(MV_PAR20)
		cSqlRet += " AND F2.F2_YSUBTP = '"+MV_PAR20+"'  " + Enter
	EndIf

	If nEmbarque == 1
		cSqlRet += " AND F2.F2_YDES = '' " + Enter
	EndIf

	If MV_PAR21 <> 5
		cSqlRet += " AND B1.B1_YCLASSE = '"+ALLTRIM(STR(MV_PAR21))+"'  " + Enter
	EndIf

	If Empty(MV_PAR20)
		If nCfo == 1 //CFOS (SIM / NAO)
			cSqlRet += " AND SUBSTRING(D2.D2_CF,1,4) IN ('5101','5102','6101','6102','6107','6109','7101')  " + Enter
		Else
			cSqlRet += " AND D2.F4_DUPLIC = 'S'  " + Enter
		EndIf
	EndIf

	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	cSqlRet += " AND A1.A1_EST BETWEEN " + ValToSQL(cRegDe) + " AND " + ValToSQL(cRegAte) + Enter


	If lpOrdena
		cSqlRet += " ORDER BY F2_VEND1, F2_CLIENTE, F2_DOC, F2.F2_EMISSAO " + Enter
	Else
		cSqlRet += " ORDER BY F2.F2_EMISSAO " + Enter
	EndIf

Return cSqlRet

//----------------------------------------------------------------------------------
// Versão do reltório em TReport.
//----------------------------------------------------------------------------------
Static Function BIA086TR()
Local oReport
Local cQrySF2  := ''
Local cQrySD2  := ''
Local cQryPED  := ''
Local cDropSf2 := ""
Local cDropSd2 := ""

//Define o nome das tabelas temporarias
nNomeSF2	:= "##BIA086SF2"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //strzero(seconds()*3500,10)
nNomeSD2	:= "##BIA086SD2"+cEmpAnt+__cUserID+strzero(seconds()*3500,10) //Alltrim(Str(randomize(1,34000)))

//Monta querys para dropar as tabelas temporárias
cDropSf2 := "DROP TABLE IF EXISTS " + nNomeSF2
cDropSd2 := "DROP TABLE IF EXISTS " + nNomeSD2

//Gerando tabela temporaria SF2
cQrySF2 := GetSqlSF2()
U_BIAMsgRun("Aguarde... Gerando Base... Cabeçalho da NF",,{|| TcSQLExec(cQrySF2)})

//Gerando tabela temporaria SD2
cQrySD2 := GetSqlSD2()
U_BIAMsgRun("Aguarde... Gerando Base... Itens da NF",,{|| TcSQLExec(cQrySD2)})

cQryPED := GetSqlPed(.T.)

If chkfile("BIA086TR")
	dbSelectArea("BIA086TR")
	dbCloseArea()
EndIf
TcQuery cQryPED New Alias "BIA086TR"
DbSelectArea("BIA086TR")

oReport:= ReportDef()
oReport:PrintDialog()

BIA086TR->(DbCloseArea())

//Exclui as tabelas temporárias
U_BIAMsgRun("Aguarde... ",,{|| TcSQLExec(cDropSf2)})
U_BIAMsgRun("Aguarde... ",,{|| TcSQLExec(cDropSd2)})
Return
//----------------------------------------------------------------------------------
Static Function ReportDef()
	Local cNomeRep		:= "BIA086TR"
	Local cTituloRep 	:= "Mapa de Pedidos Atendidos"
	Local cDescRep		:= "Este relatorio ira imprimir a relacao dos Pedidos de Venda Atendidos."
	Local oBrNF
	Local oBrCli
	Local oBrVend

	oReport:= TReport():New(cNomeRep,cTituloRep,cNomeRep, {|oReport| PrintReport(oReport)},cDescRep)
	oReport:SetLandscape()
	Pergunte(oReport:GetParam(),.F.)

	oReport:SetTotalInLine(.F.)
	oReport:lParamPage 		:=.F.
	oReport:lPrtParamPage   :=.F.
	oReport:lXlsParam		:=.F.

	oSection1 := TRSection():New(oReport,OemToAnsi("Pedidos"),{"BIA086TR"})
	oSection1:SetTotalInLine(.F.)

	oSection2 := TRSection():New(oReport,OemToAnsi("Vendedor"),{"BIA086TR"})
	oSection2:SetTotalInLine(.F.)
	oSection2:SetLineStyle(.T.)

	oSection3 := TRSection():New(oReport,OemToAnsi("Cliente"),{"BIA086TR"})
	oSection3:SetTotalInLine(.F.)
	oSection3:SetLineStyle(.T.)

	//cria as células do relatório...
	TRCell():New(oSection2,"VENDEDOR",,"Vendedor","@!",50,,,"LEFT",,"LEFT")
	TRCell():New(oSection2,"PRCUNI",,"Preço Unit.",,14)//disable
	TRCell():New(oSection2,"QTDPED",,"Quant.",,14)//disable
	TRCell():New(oSection2,"VLRTOT",,"Total",,14)//disable

	// Thiago Haagensen - Ticket 24332 - Adicionado coluna com o valor da NF total com impostos (VLRTOTIPI)
	TRCell():New(oSection2,"VLRTOTIPI",,"Total c/ IPI",,14)//disable

	TRCell():New(oSection3,"CLIENTE",,"Cliente","@!", 50,,,"LEFT",,"LEFT")
	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	TRCell():New(oSection3,"CIDADE",,"Cidade/Estado","@!",40,,,"LEFT",,"LEFT")
	TRCell():New(oSection3,"PRCUNI",,"Preço Unit.",,14)//disable
	TRCell():New(oSection3,"QTDPED",,"Quant.",,14)//disable
	TRCell():New(oSection3,"VLRTOT",,"Total",,14)//disable
	TRCell():New(oSection3,"VLRTOTIPI",,"Total c/ IPI",,14)//disable


	TRCell():New(oSection1,"VENDEDOR",,"Vendedor",,50)//disable
	TRCell():New(oSection1,"CLIENTE",,"Cliente",,50)//disable
	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	TRCell():New(oSection1,"CIDADE",,"Cidade/Estado",,40)//disable
	TRCell():New(oSection1,"NRNF",,"NF","@!",12,,,"CENTER",,"CENTER")
	TRCell():New(oSection1,"EMISNF",,"Emis. NF","@!",10,,,"CENTER",,"CENTER")
	TRCell():New(oSection1,"PRODUTO",,"Produto","@!",12,,,"LEFT",,"LEFT")
	TRCell():New(oSection1,"MARCA",,"Marca","@!",12,,,"LEFT",,"LEFT")
	TRCell():New(oSection1,"LOTE",,"Lote ","@!",08,,,"CENTER",,"CENTER")
	TRCell():New(oSection1,"DESC",,"Descrição","@!",30,,,"LEFT",,"LEFT")
	TRCell():New(oSection1,"PRCUNI",,"Preço Unit.","@E 999,999,999.99",14,,,"RIGHT",,"RIGHT")
	TRCell():New(oSection1,"QTDPED",,"Quant.","@E 999,999,999.99",14,,,"RIGHT",,"RIGHT")

	TRCell():New(oSection1,"VLRTOT",,"Total","@E 999,999,999.99",14,,,"RIGHT",,"RIGHT")
	TRCell():New(oSection1,"VLRTOTIPI",,"Total C/ IPI","@E 999,999,999.99",14,,,"RIGHT",,"RIGHT")

	TRCell():New(oSection1,"TRANSP",,".    Transp.","@!",25,,,"LEFT",,"LEFT")
	TRCell():New(oSection1,"PEDIDO",,"Pedido  ","@!",10,,,"CENTER",,"CENTER")
	TRCell():New(oSection1,"EMISSAO",,"Emissão",,12,,,"CENTER",,"CENTER")
	TRCell():New(oSection1,"EMBARQUE",,"Embarque",,12,,,"CENTER",,"CENTER")
	TRCell():New(oSection1,"CONDPAG",,"Prazo","@!",22,,,"LEFT",,"LEFT")
	TRCell():New(oSection1,"PESOBRUT",,"Peso Bruto","@E 999,999,999.99",14,,,"RIGHT",,"RIGHT")
	TRCell():New(oSection1,"DESC_INCO",,"Desc. Incond.","@E 999,999,999.99",18,,,"RIGHT",,"RIGHT")
	TRCell():New(oSection1,"PC",,"PC","@!",10,,,"RIGHT",,"RIGHT")
	TRCell():New(oSection1,"YDTNERE",,"Dt.Nec.Cliente","@!",10,,,"CENTER",,"CENTER")

	oSection1:Cell("VENDEDOR"):Disable()
	oSection1:Cell("CLIENTE"):Disable()
	// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
	oSection1:Cell("CIDADE"):Disable()

	oSection2:Cell("PRCUNI"):Disable()
	oSection2:Cell("QTDPED"):Disable()
	oSection2:Cell("VLRTOT"):Disable()
	oSection2:Cell("VLRTOTIPI"):Disable()

	oSection3:Cell("PRCUNI"):Disable()
	oSection3:Cell("QTDPED"):Disable()
	oSection3:Cell("VLRTOT"):Disable()
	oSection3:Cell("VLRTOTIPI"):Disable()

	//define as quebras no relatório...
	oBrNF := TRBreak():New(oSection1,oSection1:Cell("NRNF"),"Total da NF")
	TRFunction():New(oSection1:Cell("PRCUNI"),NIL,"AVERAGE",oBrNF, ,"@E 999,999,999.99")
	TRFunction():New(oSection1:Cell("QTDPED"),NIL,"SUM",oBrNF, ,"@E 999,999,999.99")
	TRFunction():New(oSection1:Cell("VLRTOT"),NIL,"SUM",oBrNF, ,"@E 999,999,999.99")

	TRFunction():New(oSection1:Cell("VLRTOTIPI"),NIL,"SUM",oBrNF, ,"@E 999,999,999.99")

	oBrCli := TRBreak():New(oSection1,oSection3:Cell("CLIENTE"),"Total do Cliente")
	TRFunction():New(oSection3:Cell("PRCUNI"),NIL,"AVERAGE",oBrCli, ,"@E 999,999,999.99")
	TRFunction():New(oSection3:Cell("QTDPED"),NIL,"SUM",oBrCli, ,"@E 999,999,999.99")
	TRFunction():New(oSection3:Cell("VLRTOT"),NIL,"SUM",oBrCli, ,"@E 999,999,999.99")
	TRFunction():New(oSection3:Cell("VLRTOTIPI"),NIL,"SUM",oBrNF, ,"@E 999,999,999.99")

	oBrVend := TRBreak():New(oSection2,oSection2:Cell("VENDEDOR"),"Total do Vendedor")
	TRFunction():New(oSection2:Cell("PRCUNI"),NIL,"AVERAGE",oBrVend, ,"@E 999,999,999.99")
	TRFunction():New(oSection2:Cell("QTDPED"),NIL,"SUM",oBrVend, ,"@E 999,999,999.99")
	TRFunction():New(oSection2:Cell("VLRTOT"),NIL,"SUM",oBrVend, ,"@E 999,999,999.99")
	TRFunction():New(oSection2:Cell("VLRTOTIPI"),NIL,"SUM",oBrNF, ,"@E 999,999,999.99")

Return oReport
//----------------------------------------------------------------------------------
Static Function PrintReport(oReport)

	Local oSection1 := oReport:Section(1)
	Local oSection2 := oReport:Section(2)
	Local oSection3 := oReport:Section(3)
	Local cCliRep	:= ''
	Local cVendRep  := ''
	Local cNf 		:= ''
	Local cPedido 	:= ''
	Local wTransp 	:= ''

	DbSelectArea("BIA086TR")
	dbGoTop()

	oReport:SetMeter(BIA086TR->(RecCount()))

	If !Eof()

		If oReport:nDevice == 4
			oSection1:Cell("VENDEDOR"	):Enable()
			oSection1:Cell("CLIENTE"	):Enable()
			// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
			oSection1:Cell("CIDADE"  	):Enable()
		EndIf

		While BIA086TR->(!Eof())

			oSection2:SetHeaderSection(.T.)
			oSection2:Init()

			oSection2:Cell("VENDEDOR"	):SetValue(BIA086TR->F2_VEND1 + "-" + BIA086TR->A3_NOME)
			oSection2:PrintLine()

			cVendRep := BIA086TR->F2_VEND1

			While cVendRep == BIA086TR->F2_VEND1 .And. BIA086TR->(!Eof())

				oSection3:SetHeaderSection(.T.)
				oSection3:Init()
				oSection3:Cell("CLIENTE"	):SetValue(SubStr(BIA086TR->A1_COD+"-"+BIA086TR->A1_NOME,1,40))
				// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
				oSection3:Cell("CIDADE"  	):SetValue(AllTrim(BIA086TR->A1_MUN) + '/' + BIA086TR->A1_EST)
				oSection3:PrintLine()

				cCliRep := BIA086TR->A1_COD

				While cCliRep == BIA086TR->A1_COD .And. BIA086TR->(!Eof())

					oSection1:Init()
					oSection1:SetHeaderSection(.T.)

					If oReport:Cancel()
						Exit
					EndIf

					oReport:IncMeter()

					If !EMPTY(BIA086TR->C5_YPEDORI)
						cNf		:= "*"+BIA086TR->F2_DOC
						cPedido := BIA086TR->C5_YPEDORI
					Else
						cNf		:= BIA086TR->F2_DOC
						cPedido := BIA086TR->C5_NUM
					EndIf

					If Empty(BIA086TR->C5_TRANSP)
						wTransp		:= "SEM FRETE"
					Else
						wTransp  := BIA086TR->A4_NREDUZ
					EndIf

					//seta os valores...
					oSection2:Cell("VENDEDOR"	):SetValue(BIA086TR->F2_VEND1 + "-" + BIA086TR->A3_NOME)
					oSection2:Cell("PRCUNI"  	):SetValue(Transform(BIA086TR->D2_PRCVEN,"@E 999,999,999.99"))
					oSection2:Cell("QTDPED"  	):SetValue(Transform(BIA086TR->D2_QUANT,"@E 999,999,999.99"))
					oSection2:Cell("VLRTOT"  	):SetValue(Transform(BIA086TR->D2_TOTAL,"@E 999,999,999.99"))

					oSection3:Cell("CLIENTE"	):SetValue(BIA086TR->A1_COD+"-"+BIA086TR->A1_NOME)
					// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
					oSection3:Cell("CIDADE"  	):SetValue(AllTrim(BIA086TR->A1_MUN) + '/' + BIA086TR->A1_EST)
					oSection3:Cell("PRCUNI"  	):SetValue(Transform(BIA086TR->D2_PRCVEN,"@E 999,999,999.99"))
					oSection3:Cell("QTDPED"  	):SetValue(Transform(BIA086TR->D2_QUANT,"@E 999,999,999.99"))
					oSection3:Cell("VLRTOT"  	):SetValue(Transform(BIA086TR->D2_TOTAL,"@E 999,999,999.99"))
					oSection3:Cell("VLRTOTIPI" 	):SetValue(Transform(BIA086TR->D2_VALBRUT,"@E 999,999,999.99"))

					oSection1:Cell("VENDEDOR"	):SetValue(BIA086TR->F2_VEND1 + "-" + BIA086TR->A3_NOME)
					oSection1:Cell("CLIENTE"	):SetValue(BIA086TR->A1_COD+"-"+BIA086TR->A1_NOME)
					// Tiago Rossini Coradini - 01/06/2016 - OS: 1961-16 - Jaqueline Alves
					oSection1:Cell("CIDADE"  	):SetValue(AllTrim(BIA086TR->A1_MUN) + '/' + BIA086TR->A1_EST)
					oSection1:Cell("NRNF"    	):SetValue(cNf)
					oSection1:Cell("EMISNF"  	):SetValue(DTOC(STOD(BIA086TR->F2_EMISSAO)))
					oSection1:Cell("PRODUTO" 	):SetValue(BIA086TR->D2_COD)

					SB1->(DbSetOrder(1))
					SB1->(DbSeek(XFilial("SB1")+BIA086TR->D2_COD))
					ZZ7->(DbSetOrder(1))
					If ZZ7->(DbSeek(XFilial("ZZ7")+ SB1->(B1_YLINHA+B1_YLINSEQ)))

						cLinha := ZZ7->ZZ7_EMP

						DO Case
						Case cLinha == "0101"
							oSection1:Cell("MARCA"):SetValue("Biancogres")
						Case cLinha == "0501"
							oSection1:Cell("MARCA"):SetValue("Incesa")
						Case cLinha == "0599"
							oSection1:Cell("MARCA"):SetValue("Bellacasa")
						Case cLinha == "1302"
							oSection1:Cell("MARCA"):SetValue("Vinilico")
						Case cLinha == "1399"
							oSection1:Cell("MARCA"):SetValue("Mundialli")
						Case cLinha == "1401"
							oSection1:Cell("MARCA"):SetValue("Vitcer")
						OTHERWISE
							oSection1:Cell("MARCA"):SetValue(cLinha)
						EndCase
					Else

						oSection1:Cell('MARCA'):SetValue("")

					EndIf

					oSection1:Cell("LOTE"   	):SetValue(BIA086TR->D2_LOTECTL)
					oSection1:Cell("DESC"	 	):SetValue(BIA086TR->B1_YREF)
					oSection1:Cell("PRCUNI"  	):SetValue(BIA086TR->D2_PRCVEN)
					oSection1:Cell("QTDPED"  	):SetValue(BIA086TR->D2_QUANT)
					oSection1:Cell("VLRTOT"  	):SetValue(BIA086TR->D2_TOTAL)
					oSection1:Cell("VLRTOTIPI"  ):SetValue(BIA086TR->D2_VALBRUT)


					oSection1:Cell("TRANSP"  	):SetValue(Space(5) + SubStr(wTransp,1,20))
					oSection1:Cell("PEDIDO"  	):SetValue(cPedido)
					oSection1:Cell("EMISSAO" 	):SetValue(DTOC(STOD(BIA086TR->C5_EMISSAO)))
					oSection1:Cell("EMBARQUE"	):SetValue(DTOC(STOD(BIA086TR->F2_YDES)))
					oSection1:Cell("CONDPAG" 	):SetValue(BIA086TR->E4_DESCRI)
					oSection1:Cell("PESOBRUT"	):SetValue(BIA086TR->D2_QUANT * BIA086TR->D2_PESO)
					oSection1:Cell("DESC_INCO"	):SetValue(BIA086TR->D2_DESCON)
					oSection1:Cell("PC"			):SetValue(BIA086TR->C5_YPC)
					oSection1:Cell("YDTNERE"			):SetValue(DTOC(STOD(BIA086TR->C6_YDTNERE)))

					//imprime as células...
					oSection1:PrintLine()
					BIA086TR->(DBSKIP())
				End
				oSection1:Finish()
				oSection3:Finish()
			End
			oSection2:Finish()
		End
	EndIf

Return
//----------------------------------------------------------------------------------
