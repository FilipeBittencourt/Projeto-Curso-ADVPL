#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFG028
@author Gabriel Rossi Mafioletti
@since 02/01/2018
@version 1.0
@description Tela principal do projeto MRP
@type function
/*/

User Function BIAFG028()

	Local _nDaysRet	:=	365	//Criar Parametro para Dias a Retroceder
	Local _nDaysSum	:=	365 //Criar Parâmetro para dias a Avançar

	If !ValidPerg()
		Return
	EndIf

	Private _cTabTemp	:=	'##TMP_ARQTRABTMP_MRP' + cEmpAnt + __cUserID + strzero(seconds()*3500,10)

	//PAra Primeira SemanaSempre Pegará a próxima segunda-feira, caso o dia não seja segunda
	Private _dIniSem1	:=	Iif(Dow(MV_PAR02) == 2, MV_PAR02,Iif(Dow(MV_PAR02) == 1,DaySum(MV_PAR02,1),DaySum(MV_PAR02,7-Dow(MV_PAR02)+2)))
	//Para as demais, somente incremento 7 dias na anterior
	Private _dIniSem2	:=	DaySum(_dIniSem1,7)
	Private _dIniSem3	:=	DaySum(_dIniSem2,7)
	Private _dIniSem4	:=	DaySum(_dIniSem3,7)
	Private _dIniSem5	:=	DaySum(_dIniSem4,7)
	//O Início do Histórico Utilizará a variável definida por parâmetro
	Private _dIniHist	:=	DaySub(_dIniSem1,_nDaysRet)
	//O Fim do Histórico Utilizará a variável definida por parâmetro
	Private _dFimHist	:=	DaySum(_dIniSem5,_nDaysSum)

	If !fCriaTemp() //Cria Tabela ## no banco de Dados
		Return
	EndIf


	Private oDlgMRP		:=	Nil		//Dialog
	Private oGpMRP1		:=	Nil		//Grupo
	Private oGpMRP1GR	:=	Nil		//Grupo Grafico
	Private oPnGraf		:=	Nil		//Painel Onde Ficará o Gráfico
	Private oSyDsProd	:=	Nil
	Private cSyDsProd	:=	SPACE(250)
	Private	oFntMRP		:=	TFont():New("Arial",,022,,.T.,,,,,.F.,.F.)

	Private aSolProd	:=	{} //Contém as Solicitações por Produto

	Private	aBkpCGeral	:=	{}	//Contém um BKP Do Acols Geral para tratar as atualizações em tempo real

	Private oGdGeral	:=	Nil		//GetDados Geral
	Private oGdDet		:=	Nil		//Getdados de Detalhamento
	Private	oGdSol		:=	Nil		//Getdados de Solicitações
	Private oChart		:=	Nil		//Contém o Gráfico

	// Descritivo da Method MsAdvSize
	//   1 -> Linha inicial área trabalho.
	//   2 -> Coluna inicial área trabalho.
	//   3 -> Linha final área trabalho.
	//   4 -> Coluna final área trabalho.
	//   5 -> Coluna final dialog (janela).
	//   6 -> Linha final dialog (janela).
	//   7 -> Linha inicial dialog (janela).

	Private aSize := MsAdvSize(.F.) //Sem Enchoice

	aObjects := {}
	// Quantos mais objetos, mais o Method MsObjSize Trabalha para subdividir
	//                 | Fracionamento Horizontal
	//                      | Fracionamento Vertical

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos1                                         |
	+-------------------------------------------------------------------------*/
	AAdd( aObjects, { 100, 215, .T., .T. } )
	AAdd( aObjects, { 100, 185, .T., .T. } )
	AAdd( aObjects, { 100, 025, .T., .F. } )

	aInfo1   := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

	aPosObj1 := MsObjSize( aInfo1, aObjects, .T. )

	/*-------------------------------------------------------------------------+
	|Resolve as dimensoes dos objetos2                                         |
	+-------------------------------------------------------------------------*/
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	aSize2 := aClone( aPosObj1[2] )
	aInfo2   := { aSize2[2], aSize2[1], aSize2[4], aSize2[3], 3, 3 }
	aPosObj2 := MsObjSize( aInfo2, aObjects, ,.T. )

	//Montagem da Tela

	DEFINE MSDIALOG oDlgMRP TITLE "MRP" FROM aSize[7], aSize[7] TO aSize[6], aSize[5] COLORS 0, 16777215 PIXEL

	// Painel Solicitações
	@ aPosObj2[2][1], aPosObj2[2][2] GROUP oGpMRP1 TO aPosObj2[2][3], aPosObj2[2][4] PROMPT "Solicitar Compras..." OF oDlgMRP COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Quadro Solicitações)",,{|| fGeraSol() })

	// Painel Gráfico ->Monto ele antes para que o objeto do grupo esteja setado quando for montar o grafico
	@ aPosObj2[3][1], aPosObj2[3][2] GROUP oGpMRP1GR TO aPosObj2[3][3], aPosObj2[3][4] PROMPT "Gráfico Y=(Saldo/Compras/Saída), X=Semanas..." OF oDlgMRP COLOR 0, 16777215 PIXEL
	fGeraGraf()

	// Painel Produto(Rodapé)
	@ aPosObj1[3][1], aPosObj1[3][2] GROUP oGpMRP1 TO aPosObj1[3][3], aPosObj1[3][4] PROMPT "Produto" OF oDlgMRP COLOR 0, 16777215 PIXEL
	@ aPosObj1[3][1]+10, aPosObj1[3][2]+05 SAY oSyDsProd PROMPT cSyDsProd SIZE 446, 011 OF oDlgMRP FONT oFntMRP COLORS 0, 16777215 PIXEL

	// Painel Detalhamento
	@ aPosObj2[1][1], aPosObj2[1][2] GROUP oGpMRP1 TO aPosObj2[1][3], aPosObj2[1][4] PROMPT "Detalhamento dos Movimentos Existentes da Base de Dados..." OF oDlgMRP COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Detalhamento)",,{|| fGeraDet() })

	// Painel Geral(Deve estar por último pois o mesmo utiliza os objetos anteriores)
	@ aPosObj1[1][1], aPosObj1[1][2] GROUP oGpMRP1 TO aPosObj1[1][3], aPosObj1[1][4] PROMPT "Quadro Geral..." OF oDlgMRP COLOR 0, 16777215 PIXEL
	U_BIAMsgRun("Aguarde... Carregando dados (Quadro Geral)",,{|| fGeraGer() })

	//Projeta Solicitações
	If MV_PAR03	==	'1'
		fProjSol()
		fAltGeral()
	EndIf

	If MV_PAR03	==	'1'
		U_BIAMsgRun("Aguarde... Carregando Projeções",,{|| fRefrGer() }) //Faz Refresh no Acols Geral
	EndIf

	@ aPosObj1[3][1]+08, aPosObj1[3][4]-040 BUTTON oBt1CockSim PROMPT "Cancelar" SIZE 037, 012 OF oDlgMRP ACTION (cj_Fecha := .F., fh_Esc := .T., oDlgMRP:End()) PIXEL
	If !Empty(oGdGeral:aCols[1,2])
		@ aPosObj1[3][1]+08, aPosObj1[3][4]-103 BUTTON oBt2CockSim PROMPT "Gravar Solicitações"   SIZE 060, 012 OF oDlgMRP ACTION Processa({|| fGrava() }) PIXEL
	EndIf

	ACTIVATE MSDIALOG oDlgMRP CENTERED

Return

//Cria o MsNewgetdados do Quadro Geral
Static Function fGeraGer()

	Local	aHGeral	:=	{}
	Local	aCGeral	:=	{}

	Local 	_cAlias	:=	GetNextAlias()

	Local	_cQry	:=	""

	_cQry	+=	"	WITH    BASSESS	"+CRLF
	_cQry	+=	"	          AS ( SELECT   PRODUTO ,	"+CRLF
	_cQry	+=	"	                        RTRIM(B1_DESC) DESCRIC ,	"+CRLF
	_cQry	+=	"	                        B1_UM UNIDMED ,	"+CRLF
	_cQry	+=	"	                        XLOCAL ,	"+CRLF
	_cQry	+=	"	                        DTREF ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A0-BZ001], 0) AS EMIN ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A0-BZ002], 0) AS LOTECO ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A0-BZSEG], 0) AS BZSEG ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A1-B2ATU], 0) AS B2ATU ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A2-C1ANT], 0) AS C1ANT ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A3-C7ANT], 0) AS C7ANT ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A4-D4ANT], 0) AS D4ANT ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A5-C1AUT], 0) AS C1AUT ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A6-C7ATU], 0) AS C7ATU ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem1)+" AND DTREF < "+ValTosql(_dIniSem2)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A5-C1AUT], 0) + ISNULL([A6-C7ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END ENTR1 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem2)+" AND DTREF < "+ValTosql(_dIniSem3)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A5-C1AUT], 0) + ISNULL([A6-C7ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END ENTR2 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem3)+" AND DTREF < "+ValTosql(_dIniSem4)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A5-C1AUT], 0) + ISNULL([A6-C7ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END ENTR3 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem4)+" AND DTREF < "+ValTosql(_dIniSem5)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A5-C1AUT], 0) + ISNULL([A6-C7ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END ENTR4 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem5)+" AND DTREF < "+ValTosql(_dFimHist)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A5-C1AUT], 0) + ISNULL([A6-C7ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END ENTR5 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem1)+" AND DTREF < "+ValTosql(_dIniSem2)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A7-D4ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END SAID1 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem2)+" AND DTREF < "+ValTosql(_dIniSem3)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A7-D4ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END SAID2 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem3)+" AND DTREF < "+ValTosql(_dIniSem4)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A7-D4ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END SAID3 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem4)+" AND DTREF < "+ValTosql(_dIniSem5)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A7-D4ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END SAID4 ,	"+CRLF
	_cQry	+=	"	                        CASE WHEN DTREF >= "+ValTosql(_dIniSem5)+" AND DTREF < "+ValTosql(_dFimHist)+"	"+CRLF
	_cQry	+=	"	                             THEN ISNULL([A7-D4ATU], 0)	"+CRLF
	_cQry	+=	"	                             ELSE 0	"+CRLF
	_cQry	+=	"	                        END SAID5 ,	"+CRLF
	_cQry	+=	"	                        ISNULL([A7-D4ATU], 0) AS D4ATU	"+CRLF
	_cQry	+=	"	               FROM     ( SELECT    ORIG ,	"+CRLF
	_cQry	+=	"	                                    PRODUTO ,	"+CRLF
	_cQry	+=	"	                                    DTREF ,	"+CRLF
	_cQry	+=	"	                                    XLOCAL ,	"+CRLF
	_cQry	+=	"	                                    QUANT	"+CRLF
	_cQry	+=	"	                          FROM      "+ _cTabTemp +"	"+CRLF
	_cQry	+=	"	                        ) AS TAB	"+CRLF
	_cQry	+=	"	                        INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_COD = PRODUTO	"+CRLF
	_cQry	+=	"	                                                 AND SB1.D_E_L_E_T_ = ''	"+CRLF
	_cQry	+=	"	                        PIVOT ( SUM(QUANT) FOR ORIG IN ( [A0-BZ001],	"+CRLF
	_cQry	+=	"	                                                         [A0-BZ002],	"+CRLF
	_cQry	+=	"	                                                         [A0-BZSEG],	"+CRLF
	_cQry	+=	"	                                                         [A1-B2ATU],	"+CRLF
	_cQry	+=	"	                                                         [A2-C1ANT],	"+CRLF
	_cQry	+=	"	                                                         [A3-C7ANT],	"+CRLF
	_cQry	+=	"	                                                         [A4-D4ANT],	"+CRLF
	_cQry	+=	"	                                                         [A5-C1AUT],	"+CRLF
	_cQry	+=	"	                                                         [A6-C7ATU],	"+CRLF
	_cQry	+=	"	                                                         [A7-D4ATU] ) ) AS FIM	"+CRLF
	_cQry	+=	"	             )	"+CRLF
	_cQry	+=	"	    SELECT  * FROM (	"+CRLF
	_cQry	+=	"	    SELECT  PRODUTO ,	"+CRLF
	_cQry	+=	"	            DESCRIC ,	"+CRLF
	_cQry	+=	"	            UNIDMED ,	"+CRLF
	_cQry	+=	"	            XLOCAL ,	"+CRLF	
	_cQry	+=	"	            SUM(EMIN) EMIN ,	"+CRLF
	_cQry	+=	"	            SUM(LOTECO) LOTECO ,	"+CRLF
	_cQry	+=	"	            SUM(BZSEG) BZSEG ,	"+CRLF
	_cQry	+=	"	            SUM(B2ATU) B2ATU ,	"+CRLF
	_cQry	+=	"	            SUM(C1ANT) + SUM(C7ANT) ENTANT ,	"+CRLF
	_cQry	+=	"	            SUM(D4ANT) SAIANT ,	"+CRLF
	_cQry	+=	"	            SUM(BZSEG) + SUM(B2ATU) + SUM(C1ANT) + SUM(C7ANT) + SUM(D4ANT) SALD1 ,	"+CRLF
	_cQry	+=	"	            SUM(ENTR1) ENTR1 ,	"+CRLF
	_cQry	+=	"	            SUM(SAID1) SAID1 ,	"+CRLF
	_cQry	+=	"	            SUM(BZSEG) + SUM(B2ATU) + SUM(C1ANT) + SUM(C7ANT) + SUM(D4ANT)	"+CRLF
	_cQry	+=	"	            + SUM(ENTR1) + SUM(SAID1) SALD2 ,	"+CRLF
	_cQry	+=	"	            SUM(ENTR2) ENTR2 ,	"+CRLF
	_cQry	+=	"	            SUM(SAID2) SAID2 ,	"+CRLF
	_cQry	+=	"	            SUM(BZSEG) + SUM(B2ATU) + SUM(C1ANT) + SUM(C7ANT) + SUM(D4ANT)	"+CRLF
	_cQry	+=	"	            + SUM(ENTR1) + SUM(SAID1) + SUM(ENTR2) + SUM(SAID2) SALD3 ,	"+CRLF
	_cQry	+=	"	            SUM(ENTR3) ENTR3 ,	"+CRLF
	_cQry	+=	"	            SUM(SAID3) SAID3 ,	"+CRLF
	_cQry	+=	"	            SUM(BZSEG) + SUM(B2ATU) + SUM(C1ANT) + SUM(C7ANT) + SUM(D4ANT)	"+CRLF
	_cQry	+=	"	            + SUM(ENTR1) + SUM(SAID1) + SUM(ENTR2) + SUM(SAID2) + SUM(ENTR3)	"+CRLF
	_cQry	+=	"	            + SUM(SAID3) SALD4 ,	"+CRLF
	_cQry	+=	"	            SUM(ENTR4) ENTR4 ,	"+CRLF
	_cQry	+=	"	            SUM(SAID4) SAID4 ,	"+CRLF
	_cQry	+=	"	            SUM(BZSEG) + SUM(B2ATU) + SUM(C1ANT) + SUM(C7ANT) + SUM(D4ANT)	"+CRLF
	_cQry	+=	"	            + SUM(ENTR1) + SUM(SAID1) + SUM(ENTR2) + SUM(SAID2) + SUM(ENTR3)	"+CRLF
	_cQry	+=	"	            + SUM(SAID3) + SUM(ENTR4) + SUM(SAID4) SALD5 ,	"+CRLF
	_cQry	+=	"	            SUM(SAID5) SAID5 ,	"+CRLF
	_cQry	+=	"	            SUM(ENTR5) ENTR5 ,	"+CRLF
	_cQry	+=	"	            SUM(BZSEG) + SUM(B2ATU) + SUM(C1ANT) + SUM(C7ANT) + SUM(D4ANT)	"+CRLF
	_cQry	+=	"	            + SUM(ENTR1) + SUM(SAID1) + SUM(ENTR2) + SUM(SAID2) + SUM(ENTR3)	"+CRLF
	_cQry	+=	"	            + SUM(SAID3) + SUM(ENTR4) + SUM(SAID4) + SUM(SAID5) + SUM(ENTR5) DISPON	"+CRLF
	_cQry	+=	"	    FROM    BASSESS	"+CRLF
	_cQry	+=	"	    GROUP BY PRODUTO ,	"+CRLF
	_cQry	+=	"	            DESCRIC ,	"+CRLF
	_cQry	+=	"	            XLOCAL ,	"+CRLF	
	_cQry	+=	"	            UNIDMED	)SLD "+CRLF
	If MV_PAR04 == "1"
		_cQry	+=	"	WHERE (SALD1 < 0 OR SALD2 < 0 OR SALD3 < 0 OR SALD4 < 0 OR SALD5 < 0 ) 	"
	EndIf

	IndGeral := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.F.,.T.)

	Aadd(aHGeral,{" "			 ,"CSTATUS","@BMP", 2, 0, ".F." ,""    , "C", "", "V" ,"" , "","","V"})
	aAdd(aHGeral,{"Prod"         ,"PRODUT" ,"@!"               , 15   , 0,,, "C",, })      	// 1
	aAdd(aHGeral,{"UM"           ,"UMPROD" ,"@!"               , 02   , 0,,, "C",, })      	// 3
	aAdd(aHGeral,{"Local"        ,"LOCPRD" ,"@!"               , 02   , 0,,, "C",, })      	// 3
	//aAdd(aHGeral,{"Ponto Ped"    ,"ESTMIN" ,"@E 999,999.99"  , 10   , 2,,, "N",, })      	// 4
	aAdd(aHGeral,{"Lt.Econ"      ,"LOTECO" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 5
	aAdd(aHGeral,{"Est Seg"      ,"ESTSEG" ,"@E 9,999,999.99"  , 10  , 2,,, "N",, })      	// 6
	aAdd(aHGeral,{"Est Atu"      ,"ESTATU" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 7
	aAdd(aHGeral,{"Ent Ant"      ,"ENTANT" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 8
	aAdd(aHGeral,{"Sai Ant"      ,"SAIANT" ,"@E 9,999,999.99"  , 10  , 2,,, "N",, })     	// 9
	aAdd(aHGeral,{"Saldo Ant"    ,"SAL1" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 12
	//aAdd(aHGeral,{"Ent Sm1"      ,"ENT1"   ,"@E 999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"Nec. Com1"      ,"NECOM1"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"PC. Aberto1"      ,"PDCAB1"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"Saida Sm1"    ,"SAI1" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })       	// 11
	aAdd(aHGeral,{"Saldo Sm1"    ,"SAL2" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 15
	//aAdd(aHGeral,{"Ent Sm2"      ,"ENT2"   ,"@E 999,999.99"  , 10   , 2,,, "N",, })      	// 13
	aAdd(aHGeral,{"Nec. Com2"      ,"NECOM2"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"PC. Aberto2"      ,"PDCAB2"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"Saida Sm2"    ,"SAI2" ,"@E 9,999,999.99"  , 10  , 2,,, "N",, })      	// 14
	aAdd(aHGeral,{"Saldo Sm2"    ,"SAL3" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 18
	//aAdd(aHGeral,{"Ent Sm3"      ,"ENT3"   ,"@E 999,999.99"  , 10   , 2,,, "N",, })      	// 16
	aAdd(aHGeral,{"Nec. Com3"      ,"NECOM3"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"PC. Aberto3"      ,"PDCAB3"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"Saida Sm3"    ,"SAI3" ,"@E 9,999,999.99"  , 10  , 2,,, "N",, })      	// 17
	aAdd(aHGeral,{"Saldo Sm3"    ,"SAL4" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 21
	//aAdd(aHGeral,{"Ent Sm4"      ,"ENT4"   ,"@E 999,999.99"  , 10   , 2,,, "N",, })      	// 19
	aAdd(aHGeral,{"Nec. Com4"      ,"NECOM4"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"PC. Aberto4"      ,"PDCAB4"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"Saida Sm4"    ,"SAI4" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 20
	aAdd(aHGeral,{"Saldo Sm4"    ,"SAL5" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 24
	//aAdd(aHGeral,{"Ent Sm5"      ,"ENT5"   ,"@E 999,999.99"  , 10   , 2,,, "N",, })      	// 22
	aAdd(aHGeral,{"Nec. Com5"      ,"NECOM5"   ,"@E 9,999,999.99"  , 10  , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"PC. Aberto5"      ,"PDCAB5"   ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })     	// 10
	aAdd(aHGeral,{"Saida Sm5"    ,"SAI5" ,"@E 9,999,999.99"  , 10  , 2,,, "N",, })      	// 23
	aAdd(aHGeral,{"Saldo Final"   ,"DISPO" ,"@E 9,999,999.99"  , 10   , 2,,, "N",, })      	// 25

	While (_cAlias)->(!EOF())
		If MV_PAR04 == "2" .Or. (MV_PAR04 == "1" .And. (ABS(ROUND((_cAlias)->SAIANT,2)) > 0 ;
							.Or. ROUND((_cAlias)->SAID1,2) > 0 ;
							.Or. ROUND((_cAlias)->SAID2,2) > 0	;
							.Or. ROUND((_cAlias)->SAID3,2) > 0	;
							.Or. ROUND((_cAlias)->SAID4,2) > 0	;
							.Or. ROUND((_cAlias)->SAID1,2) > 0)) 	
	
			aAdd(aCGeral,{	"BR_VERDE"			,;
			(_cAlias)->PRODUTO	,;
			(_cAlias)->UNIDMED	,;
			(_cAlias)->XLOCAL	,;
			ROUND((_cAlias)->LOTECO,2)	,;
			ABS(ROUND((_cAlias)->BZSEG,2))	,;
			ROUND((_cAlias)->B2ATU,2)	,;
			ROUND((_cAlias)->ENTANT,2)	,;
			ABS(ROUND((_cAlias)->SAIANT,2))	,;
			ROUND((_cAlias)->SALD1,2)	,;
			0					,;
			ROUND((_cAlias)->ENTR1,2)	,;
			ROUND((_cAlias)->SAID1,2)	,;
			ROUND((_cAlias)->SALD2,2)	,;
			0					,;
			ROUND((_cAlias)->ENTR2,2)	,;
			ROUND((_cAlias)->SAID2,2)	,;
			ROUND((_cAlias)->SALD3,2)	,;
			0					,;
			ROUND((_cAlias)->ENTR3,2)	,;
			ROUND((_cAlias)->SAID3,2)	,;
			ROUND((_cAlias)->SALD4,2)	,;
			0					,;
			ROUND((_cAlias)->ENTR4,2)	,;
			ROUND((_cAlias)->SAID4,2)	,;
			ROUND((_cAlias)->SALD5,2)	,;
			0					,;
			ROUND((_cAlias)->ENTR5,2)	,;
			ROUND((_cAlias)->SAID5,2)	,;
			ROUND((_cAlias)->DISPON,2)	,;
			.F.	})
		EndIf
		(_cAlias)->(DbSkip())
	EndDo

	aBkpCGeral	:=	aClone(aCGeral)

	Ferase(IndGeral+GetDBExtension())     //arquivo de trabalho
	Ferase(IndGeral+OrdBagExt())          //indice gerado
	(_cAlias)->(DbCloseArea())

	oGdGeral	:=	MsNewGetDados():New( aPosObj1[1][1] + 10, aPosObj1[1][2] + 5, aPosObj1[1][3] - 5, aPosObj1[1][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "", "AllwaysTrue", oDlgMRP, aHGeral, aCGeral, { || fAltGeral() } )

Return

//Função no momento de mudar de linha(alteração do objeto) do getdados do Quadro geral
Static Function fAltGeral()

	Local _nPos
	Local _nI
	Local nPosDel	:= Len(ogdSol:aHeader) + 1
	Local _aSemanas	:=	{0,0,0,0,0}
	Local _nPosDig	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "DATDIG"})
	Local _nPosQtd	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "QTDDIG"})
	

	cSyDsProd := ""
	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1") + oGdGeral:Acols[oGdGeral:nAt][2] ))
	cSyDsProd := Alltrim(SB1->B1_DESC)
	oSyDsProd:Refresh()

	fPopDet()
	fPopSol()

	For _nI	:= 1 to Len(oGdSol:aCols)
		If !oGdSol:aCols[_nI,nPosDel]
			_aSemanas[fSemana(oGdSol:aCols[_nI,_nPosDig])] += oGdSol:aCols[_nI,_nPosQtd]
		EndIf
	Next

	fPopGraf(_aSemanas)


Return

Static Function fGeraDet()

	Local aHDet	:=	{}
	Local aCDet	:=	{}

	aAdd(aHDet,{"Semana"         ,"SEMANA" ,"@!"               , 15   , 0,,, "C",, })      	// 1
	aAdd(aHDet,{"Data Ref"       ,"DATREF" ,"@!"               , 8   , 0,,, "D",, })      	// 3
	aAdd(aHDet,{"Doc Ref"        ,"DOCREF" ,"@!"               , 15   , 0,,, "C",, })      	// 4
	aAdd(aHDet,{"Local"          ,"LOCALX" ,"@!"               , 2   , 0,,, "C",, })      	// 5
	aAdd(aHDet,{"Quant"    	 	 ,"QUANT" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      	// 6
	aAdd(aHDet,{"Saldo"    	 	 ,"SALDO" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      	// 7
	aAdd(aHDet,{"Prod Ref"       ,"PRDREF" ,"@!"               , 15   , 0,,, "C",, })      	// 8
	aAdd(aHDet,{"Desc. Prod"     ,"DPRDREF" ,"@!"               , 50   , 0,,, "C",, })     	// 9
	aAdd(aHDet,{"Origem"         ,"ORIGEM" ,"@!"               , 15   , 0,,, "C",, })      	// 2

	oGdDet	:=	MsNewGetDados():New( aPosObj2[1][1] + 10, aPosObj2[1][2] + 5, aPosObj2[1][3] - 5, aPosObj2[1][4] - 5, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {},, 999, '', "", "AllwaysTrue", oDlgMRP, aHDet, aCDet, { || } )

//Popula Dados para o MsNewGetDados do quadro de Detalhes
Static Function fPopDet()

	Local	aCDet	:=	{}
	Local	_cAlias	:=	GetNextAlias()
	Local	_cSql	:=	""

	_cSql	+=	"	SELECT  CASE WHEN DTREF < "+ValtoSql(_dIniSem1)+" THEN 'Anterior'	"+CRLF
	_cSql	+=	"	             WHEN DTREF >= "+ValtoSql(_dIniSem1)+" AND DTREF < "+ValtoSql(_dIniSem2)+" THEN 'Semana1'	"+CRLF
	_cSql	+=	"	             WHEN DTREF >= "+ValtoSql(_dIniSem2)+" AND DTREF < "+ValtoSql(_dIniSem3)+" THEN 'Semana2'	"+CRLF
	_cSql	+=	"	             WHEN DTREF >= "+ValtoSql(_dIniSem3)+" AND DTREF < "+ValtoSql(_dIniSem4)+" THEN 'Semana3'	"+CRLF
	_cSql	+=	"	             WHEN DTREF >= "+ValtoSql(_dIniSem4)+" AND DTREF < "+ValtoSql(_dIniSem5)+" THEN 'Semana4'	"+CRLF
	_cSql	+=	"	             WHEN DTREF >= "+ValtoSql(_dIniSem5)+" THEN 'Semana5'	"+CRLF
	_cSql	+=	"	        END SEMANA ,	"+CRLF
	_cSql	+=	"	        MRP.* ,	"+CRLF
	_cSql	+=	"	        ISNULL(C2_PRODUTO, SPACE(15)) PRODOP ,	"+CRLF
	_cSql	+=	"	        ISNULL(B1_DESC, SPACE(15)) DESCPRDOP	"+CRLF
	_cSql	+=	"	FROM    "+_cTabTemp+" MRP	"+CRLF
	_cSql	+=	"	        LEFT JOIN "+RetSqlName("SC2")+" SC2 ( NOLOCK ) ON SC2.C2_FILIAL = "+ValtoSql(xFilial("SC2"))+"	"+CRLF
	_cSql	+=	"	                                           AND SC2.C2_NUM = SUBSTRING(MRP.DOCREF,	"+CRLF
	_cSql	+=	"	                                                              1, 6)	"+CRLF
	_cSql	+=	"	                                           AND SC2.C2_ITEM = SUBSTRING(MRP.DOCREF,	"+CRLF
	_cSql	+=	"	                                                              7, 2)	"+CRLF
	_cSql	+=	"	                                           AND SC2.C2_SEQUEN = '001'	"+CRLF
	_cSql	+=	"	                                           AND SC2.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	        LEFT JOIN "+RetSqlName("SB1")+" ZB1 ( NOLOCK ) ON ZB1.B1_FILIAL = "+ValtoSql(xFilial("SB1"))+"	"+CRLF
	_cSql	+=	"	                                           AND ZB1.B1_COD = SC2.C2_PRODUTO	"+CRLF
	_cSql	+=	"	                                           AND ZB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	WHERE   PRODUTO = "+ValtoSql(oGdGeral:Acols[oGdGeral:nAt][2])+"	"+CRLF
	_cSql	+=	"			AND   XLOCAL = "+ValtoSql(oGdGeral:Acols[oGdGeral:nAt][4])+"	"+CRLF
	_cSql	+=	"	ORDER BY DTREF ,	"+CRLF
	_cSql	+=	"	        ORIG ,	"+CRLF
	_cSql	+=	"	        PRODUTO	"+CRLF

	IndDet := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cSql),_cAlias,.F.,.T.)

	While (_cAlias)->(!EOF())
		aAdd(aCDet,{	(_cAlias)->SEMANA		,;
		Stod((_cAlias)->DTREF)	,;
		(_cAlias)->DOCREF		,;
		(_cAlias)->XLOCAL		,;
		(_cAlias)->QUANT		,;
		0						,;
		(_cAlias)->PRODOP		,;
		(_cAlias)->DESCPRDOP	,;
		(_cAlias)->ORIG			,;
		.F.	})
		(_cAlias)->(DbSkip())
	EndDo

	oGdDet:aCols	:=	acDet

	oGdDet:Refresh()

	Ferase(IndDET+GetDBExtension())     //arquivo de trabalho
	Ferase(IndDET+OrdBagExt())          //indice gerado
	(_cAlias)->(DbCloseArea())

Return

//Gera MsNewGetDados do Quadro de Solicitações
Static Function fGeraSol()

	Local	aHSol	:=	{}
	Local	aCSoli	:=	{}

	aAdd(aHSol,{"Dt. Neces."       ,"DATNES" ,"@!"               , 8   , 0,,, "D",,,,Stod("") })      	// 3
	aAdd(aHSol,{"Qtd. Sug."   	   ,"QTDSUG" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      	// 6
	aAdd(aHSol,{"Dt. Info."        ,"DATDIG" ,"@!"               , 8   , 0,,, "D",,,,Stod("") })      	// 3
	aAdd(aHSol,{"Qtd. Info."   	   ,"QTDDIG" ,"@E 9,999,999.99"  , 12   , 2,,, "N",, })      	// 6

	aAdd(aCSoli,{Stod(""),0,Stod(""),0,.F.})

	oGdSol	:=	MsNewGetDados():New( aPosObj2[2][1] + 10, aPosObj2[2][2] + 5, aPosObj2[2][3] - 5, aPosObj2[2][4] - 5, GD_INSERT+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", {"DATDIG","QTDDIG"},, 999, 'U_BG028FOK()', "AllWaysTrue", "", oDlgMRP, aHSol, aCSoli, { || fChgSol() } )

Return

//Popula Getdados de Solicitações
Static Function fPopSol()

	Local	aCSol	:=	{}
	Local	_nPos
	Local	_nI

	If (_nPos := aScan(aSolProd,{|x| x[1] == oGdGeral:Acols[oGdGeral:nAt][2] .And. x[2] == oGdGeral:Acols[oGdGeral:nAt][4]})) > 0
		If Len(aSolProd[_nPos,3])  > 0
			For _nI	:= 1 to Len(aSolProd[_nPos,3])
				aAdd(aCSol,{aSolProd[_nPos,3,_nI,1],aSolProd[_nPos,3,_nI,2],aSolProd[_nPos,3,_nI,3], aSolProd[_nPos,3,_nI,4],.F.})
			Next
		Else
			aAdd(aCSol,{Stod(""),0,Stod(""),0,.F.})
		EndIf
	Else
		aAdd(aCSol,{Stod(""),0,Stod(""),0,.F.})
	EndIf

	oGdSol:aCols	:=	aCSol

	oGdSol:Refresh()

Return

//Gera Gráfico
Static Function fGeraGraf()

	oChart	:= FWChartLine():New()

	oChart:Init(oGpMRP1GR)

	oChart:setLegend( CONTROL_ALIGN_BOTTOM )

	oChart:Build()

Return

//Popula o Gráfico
Static Function fPopGraf(_aSemanas)

	Local _nPosSal1	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL1"})
	Local _nPosSai1 :=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI1"})

	Local _nPosSal2	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL2"})
	Local _nPosSai2 :=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI2"})

	Local _nPosSal3	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL3"})
	Local _nPosSai3 :=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI3"})

	Local _nPosSal4	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL4"})
	Local _nPosSai4 :=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI4"})

	Local _nPosSal5	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL5"})
	Local _nPosSai5 :=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI5"})
	
	Local _nPosEstS	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "ESTSEG"	})
	
	Local _nPosNCom1	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM1"	})
	Local _nPosNCom2	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM2"	})
	Local _nPosNCom3	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM3"	})
	Local _nPosNCom4	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM4"	})
	Local _nPosNCom5	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM5"	})
	Local _nPosPcAb1	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB1"	})
	Local _nPosPcAb2	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB2"	})
	Local _nPosPcAb3	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB3"	})
	Local _nPosPcAb4	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB4"	})
	Local _nPosPcAb5	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB5"	})

	Local _nPosEstS	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "ESTSEG"	})

	Local _nPosDisp	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "DISPO"})
	
	Local nPosDelGer	:= Len(ogdGeral:aHeader) + 1
	
	Local _cStatus	:=	""

	Local _nI
	Local _nSalAcu	:=	0

	Default _aSemanas	:=	{0,0,0,0,0}

	If Len(aBkpCGeral) == 0
		aBkpCGeral	:=	aClone(oGdGeral:aCols)
	EndIf

	oGdSol:Refresh()

	_cStatus	:=	oGdGeral:aCols[oGdGeral:nAt,1]

	oGdGeral:aCols[oGdGeral:nAt] := aClone(aBkpCGeral[oGdGeral:nAt])

	oGdGeral:aCols[oGdGeral:nAt,1]	:=	_cStatus
	
	For _nI	:=	1 to Len(oGdGeral:aCols)

		If _nI == oGdGeral:nAt
			oGdGeral:aCols[_nI,nPosDelGer]	:=	.T.
		Else
			oGdGeral:aCols[_nI,nPosDelGer]	:=	.F.
		End

	Next


	//Atualiza Saldo do Grid Geral
	oGdGeral:aCols[oGdGeral:nAt,_nPosSal2]	+=	_aSemanas[1]
	oGdGeral:aCols[oGdGeral:nAt,_nPosSal3]	+=	_aSemanas[1]+_aSemanas[2]
	oGdGeral:aCols[oGdGeral:nAt,_nPosSal4]	+=	_aSemanas[1]+_aSemanas[2]+_aSemanas[3]
	oGdGeral:aCols[oGdGeral:nAt,_nPosSal5]	+=	_aSemanas[1]+_aSemanas[2]+_aSemanas[3]+_aSemanas[4]

	//Atualiza Entradas do Grid Geral
	oGdGeral:aCols[oGdGeral:nAt,_nPosNCom1]	+=	_aSemanas[1]
	oGdGeral:aCols[oGdGeral:nAt,_nPosNCom2]	+=	_aSemanas[2]
	oGdGeral:aCols[oGdGeral:nAt,_nPosNCom3]	+=	_aSemanas[3]
	oGdGeral:aCols[oGdGeral:nAt,_nPosNCom4]	+=	_aSemanas[4]
	oGdGeral:aCols[oGdGeral:nAt,_nPosNCom5]	+=	_aSemanas[5]
	oGdGeral:aCols[oGdGeral:nAt,_nPosDisp]	+=	_aSemanas[1]+_aSemanas[2]+_aSemanas[3]+_aSemanas[4]+_aSemanas[5]

	oGdGeral:Refresh()

	oChart:aSeries	:=	{}

	//Estoque
	oChart:addSerie("Saldo",{{"Anterior",oGdGeral:aCols[oGdGeral:nAt,_nPosSal1] + oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]},;
	{"Semana1",oGdGeral:aCols[oGdGeral:nAt,_nPosSal2]+ oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]},;
	{"Semana2",oGdGeral:aCols[oGdGeral:nAt,_nPosSal3]+ oGdGeral:aCols[oGdGeral:nAt,_nPosEstS] },;
	{"Semana3",oGdGeral:aCols[oGdGeral:nAt,_nPosSal4]+ oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]},;
	{"Semana4",oGdGeral:aCols[oGdGeral:nAt,_nPosSal5]+ oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]}})

	//Compras
	oChart:addSerie("Nec. Com.",{ {"Semana1",oGdGeral:aCols[oGdGeral:nAt,_nPosNCom1]},;
	{"Semana2",oGdGeral:aCols[oGdGeral:nAt,_nPosNCom2]},;
	{"Semana3",oGdGeral:aCols[oGdGeral:nAt,_nPosNCom3]},;
	{"Semana4",oGdGeral:aCols[oGdGeral:nAt,_nPosNCom4]},;
	{"Semana5",oGdGeral:aCols[oGdGeral:nAt,_nPosNCom5]}})
	
	//Pedidos Aberto
	oChart:addSerie("Pc. Aberto",{ {"Semana1",oGdGeral:aCols[oGdGeral:nAt,_nPosPcAb1]},;
	{"Semana2",oGdGeral:aCols[oGdGeral:nAt,_nPosPcAb2]},;
	{"Semana3",oGdGeral:aCols[oGdGeral:nAt,_nPosPcAb3]},;
	{"Semana4",oGdGeral:aCols[oGdGeral:nAt,_nPosPcAb4]},;
	{"Semana5",oGdGeral:aCols[oGdGeral:nAt,_nPosPcAb5]}})

	//Empenho
	oChart:addSerie("Saída",{{"Semana1" ,ABS(oGdGeral:aCols[oGdGeral:nAt,_nPosSai1])},;
	{"Semana2",ABS(oGdGeral:aCols[oGdGeral:nAt,_nPosSai2])},;
	{"Semana3",ABS(oGdGeral:aCols[oGdGeral:nAt,_nPosSai3])},;
	{"Semana4",ABS(oGdGeral:aCols[oGdGeral:nAt,_nPosSai4])},;
	{"Semana5",ABS(oGdGeral:aCols[oGdGeral:nAt,_nPosSai5])}})


	//Estoque de Segurança
	oChart:addSerie("Est. Seg.",{ {"Semana1",oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]},;
	{"Semana2",oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]},;
	{"Semana3",oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]},;
	{"Semana4",oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]},;
	{"Semana5",oGdGeral:aCols[oGdGeral:nAt,_nPosEstS]}})

	oChart:Refresh()

	oGpMRP1GR:Refresh()

Return

Static Function ValidPerg()

	local cLoad	    := "BIAFG028" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	Local _nPeso	:=	0
	local aOpcs 	:= {"1=Sim","2=Não"}
	Local aPergs	:=	{}

	MV_PAR01 :=	Space(200)
	MV_PAR02 := STOD('')
	MV_PAR03 := "1"
	MV_PAR04 := "2"
	MV_PAR05 := SPACE(200)

	aAdd( aPergs ,{1,"Grupo(s) " 		  	,MV_PAR01 ,""  ,"U_BIAFG28G()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{1,"Data " 		   		,MV_PAR02 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{2,"Considera Projeção" 	,"1" ,aOpcs,60,'.T.',.F.})
	aAdd( aPergs ,{2,"Somente com Necessidade" 	,"1" ,aOpcs,60,'.T.',.F.})	
	aAdd( aPergs ,{1,"Armazém(s) " 		  	,MV_PAR05 ,""  ,"U_B773Loc()",''  ,'.T.',50,.F.})

	If ParamBox(aPergs ,"MRP",,,,,,,,cLoad,.T.,.T.)

		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04)
		MV_PAR05 := ParamLoad(cFileName,,5,MV_PAR05)
	EndIf
Return lRet

User Function BIAFG28G()

	Local _aArea	:=	GetArea()
	Local _aGrupos	:=	{}
	Local MvPar
	Local MvParDef	:=	""
	Local lRet		:= .F.
	Local _nTamKey	:= 0
	Local _nElemen	:= 0

	DbSelectArea("SBM")
	SBM->(DbSetOrder(1))
	SBM->(DbGoTop())

	MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
	mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

	While SBM->(!EOF())
		//		If SUBSTR(SBM->BM_GRUPO,1,3) $ "102/104"
		If aScan(_aGrupos,{|x| x == Alltrim(SBM->BM_GRUPO) + ' - ' + Alltrim(SBM->BM_DESC)}) == 0
			aAdd(_aGrupos,Alltrim(SBM->BM_GRUPO) + ' - ' + Alltrim(SBM->BM_DESC))
			MvParDef	+=	SBM->BM_GRUPO
			_nElemen++
		EndIf
		//		EndIf
		SBM->(DbSkip())
	EndDo

	_nTamKey	:=	Len(MVPARDEF)

	If f_Opcoes(@MvPar,"Seleção de Grupos",_aGrupos,MvParDef,,,.F.,4,_nElemen)
		lRet	:= .T.
		&MvRet := mvpar
	EndIf
	RestArea(_aArea)
Return lRet

//Cria a tabela Temporária No banco de dados para trabalhar com os dados da mesma
Static Function fCriaTemp()

	Local dDataRef	:=	DaySub(_dIniSem1,1)
	Local cInGrp	:=	""
	Local _nI
	Local _cSql		:=	""
	Local _cAlias	:=	GetNextAlias()
	Local _cInLocal	:=	""
	Local _nError	:=	0
	Local _lRet		:=	.T.

	For _nI	:=	1 to Len(MV_PAR01) STEP 4
		If Substr(MV_PAR01,_nI,4) <> '****'
			cInGrp +=	"'" + Substr(MV_PAR01,_nI,4) + "',"
		EndIf
	Next
	If Empty(cInGrp)
		cInGrp	:=	"('')"
	Else
		cInGrp	:=	"(" + Substr(cInGrp,1,Len(cInGrp)-1) + ")"
	End

	MV_PAR05	:=	Alltrim(MV_PAR05)

	For _nI	:=	1 to Len(MV_PAR05) STEP 2
		If Substr(MV_PAR05,_nI,2) <> '**'
			_cInLocal +=	"'" + Substr(MV_PAR05,_nI,2) + "',"
		EndIf
	Next
	If Empty(_cInLocal)
		_cInLocal	:=	"()"
	Else
		_cInLocal	:=	"(" + Substr(_cInLocal,1,Len(_cInLocal)-1) + ")"
	End

	_cSql	+=	"	SELECT  *	"+CRLF
	_cSql	+=	"	INTO    "+ _cTabTemp	+CRLF
	_cSql	+=	"	FROM    ( SELECT    TABFFY.*	"+CRLF
	_cSql	+=	"	          FROM      ( SELECT    'A0-BZ001' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SBZ.BZ_COD	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_COD PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                ZCN.ZCN_LOCAL XLOCAL ,	"+CRLF
	_cSql	+=	"	                                " +ValtoSql(dDataRef) + " DTREF ,	"+CRLF
	_cSql	+=	"	                                'PONTO DE PEDIDO' DOCREF ,	"+CRLF
	_cSql	+=	"	                                ZCN.ZCN_PONPED QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SBZ') + " SBZ ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SBZ.BZ_COD	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1' AND SBZ.BZ_YBLSCPC <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('ZCN') + " ZCN ( NOLOCK ) ON ZCN.ZCN_FILIAL = " +ValtoSql(xFilial("ZCN"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = ZCN.ZCN_COD	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_LOCAL IN "+ _cInLocal +" "+CRLF
	_cSql	+=	"	                                                              AND ZCN.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      WHERE     SBZ.BZ_FILIAL = " +ValtoSql(xFilial("SBZ"))+ "	"+CRLF
	_cSql	+=	"	                                AND ZCN.ZCN_PONPED <> 0	"+CRLF
	//_cSql	+=	"	                                AND SBZ.BZ_YBLSCPC <> '1'	"+CRLF
	_cSql	+=	"	                                AND ZCN.ZCN_POLIT = '2'	"+CRLF
	_cSql	+=	"	                                AND SBZ.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT    'A0-BZ002' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SBZ.BZ_COD	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_COD PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                ZCN.ZCN_LOCAL XLOCAL ,	"+CRLF
	_cSql	+=	"	                                " +ValtoSql(dDataRef) + " DTREF ,	"+CRLF
	_cSql	+=	"	                                'LOTE ECONOMICO' DOCREF ,	"+CRLF
	_cSql	+=	"	                                ZCN.ZCN_LE QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SBZ') + " SBZ ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SBZ.BZ_COD	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1' AND SBZ.BZ_YBLSCPC <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('ZCN') + " ZCN ( NOLOCK ) ON ZCN.ZCN_FILIAL = " +ValtoSql(xFilial("ZCN"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = ZCN.ZCN_COD	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_LOCAL IN "+ _cInLocal +" "+CRLF
	_cSql	+=	"	                                                              AND ZCN.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      WHERE     SBZ.BZ_FILIAL = " +ValtoSql(xFilial("SBZ"))+ "	"+CRLF
	_cSql	+=	"	                                AND ZCN.ZCN_LE <> 0	"+CRLF
	//_cSql	+=	"	                                AND SBZ.BZ_YBLSCPC <> '1'	"+CRLF
	_cSql	+=	"	                                AND ZCN.ZCN_POLIT = '2'	"+CRLF
	_cSql	+=	"	                                AND SBZ.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT    'A0-BZSEG' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SBZ.BZ_COD	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_COD PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                ZCN.ZCN_LOCAL XLOCAL ,	"+CRLF
	_cSql	+=	"	                                " +ValtoSql(dDataRef) + " DTREF ,	"+CRLF
	_cSql	+=	"	                                'ESTOQUE DE SEGURANÇA' DOCREF ,	"+CRLF
	_cSql	+=	"	                                ZCN.ZCN_ESTSEG * ( -1 ) QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SBZ') + " SBZ ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SBZ.BZ_COD	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1' AND SBZ.BZ_YBLSCPC <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('ZCN') + " ZCN ( NOLOCK ) ON ZCN.ZCN_FILIAL = " +ValtoSql(xFilial("ZCN"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = ZCN.ZCN_COD	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_LOCAL IN "+ _cInLocal +" "+CRLF
	_cSql	+=	"	                                                              AND ZCN.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      WHERE     SBZ.BZ_FILIAL = " +ValtoSql(xFilial("SBZ"))+ "	"+CRLF
	_cSql	+=	"	                                AND ZCN.ZCN_ESTSEG <> 0	"+CRLF
	//_cSql	+=	"	                                AND SBZ.BZ_YBLSCPC <> '1'	"+CRLF
	_cSql	+=	"	                                AND ZCN.ZCN_POLIT = '2'	"+CRLF
	_cSql	+=	"	                                AND SBZ.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT    'A1-B2ATU' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SB2.B2_COD	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SB2.B2_COD PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                SB2.B2_LOCAL XLOCAL ,	"+CRLF
	_cSql	+=	"	                                " +ValtoSql(dDataRef) + " DTREF ,	"+CRLF
	_cSql	+=	"	                                'SALDO DE ESTOQUE CORRENTE' DOCREF ,	"+CRLF
	_cSql	+=	"	                                SB2.B2_QATU QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SB2') + " SB2 ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SB2.B2_COD	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      WHERE     SB2.B2_FILIAL = " +ValtoSql(xFilial("SB2"))+ "	"+CRLF
	_cSql	+=	"	                                AND SB2.B2_QATU <> 0	"+CRLF
	_cSql	+=	"	                                AND SB2.B2_LOCAL IN "+ _cInLocal +" "+CRLF
	_cSql	+=	"	                                AND SB2.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT    'A2-C1ANT' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SC1.C1_PRODUTO	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_PRODUTO PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_LOCAL XLOCAL ,	"+CRLF
	_cSql	+=	"	                                " +ValtoSql(dDataRef) + " DTREF ,	"+CRLF
	_cSql	+=	"	                                'ENTRADAS ACUMULADAS ANTERIORES1' DOCREF ,	"+CRLF
	_cSql	+=	"	                                SUM(SC1.C1_QUANT - SC1.C1_QUJE) QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SC1') + " SC1 ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SC1.C1_PRODUTO	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      WHERE     SC1.C1_FILIAL = " +ValtoSql(xFilial("SC1"))+ "	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_DATPRF BETWEEN " + ValtoSql(_dIniHist) + " AND " +ValtoSql(dDataRef) + "	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_PEDIDO = '      '	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_RESIDUO = ' '	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_APROV NOT IN ( 'B', 'R' )	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_LOCAL IN "+ _cInLocal +" "+CRLF	
	_cSql	+=	"	                                AND SC1.C1_QUANT - C1_QUJE <> 0	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_YTOTEST NOT IN ( 'T', 'P' )	"+CRLF
	_cSql	+=	"	                                AND SC1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      GROUP BY  SC1.C1_PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_LOCAL	"+CRLF
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT    'A3-C7ANT' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SC7.C7_PRODUTO	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SC7.C7_PRODUTO PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                SC7.C7_LOCAL XLOCAL ,	"+CRLF
	_cSql	+=	"	                                " +ValtoSql(dDataRef) + " DTREF ,	"+CRLF
	_cSql	+=	"	                                'ENTRADAS ACUMULADAS ANTERIORES1' DOCREF ,	"+CRLF
	_cSql	+=	"	                                SUM(SC7.C7_QUANT - SC7.C7_QUJE) QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SC7') + " SC7 ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SC7.C7_PRODUTO	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      WHERE     SC7.C7_FILIAL = " +ValtoSql(xFilial("SC7"))+ "	"+CRLF
	
	//_cSql	+=	"	                                AND SC7.C7_YDTNECE BETWEEN " + ValtoSql(_dIniHist) + " AND " +ValtoSql(dDataRef) + "	"+CRLF
	_cSql	+=	"	                                AND SC7.C7_YDATCHE BETWEEN " + ValtoSql(_dIniHist) + " AND " +ValtoSql(dDataRef) + "	"+CRLF
	
	_cSql	+=	"	                                AND SC7.C7_RESIDUO = ' '	"+CRLF
	_cSql	+=	"	                                AND SC7.C7_QUANT - SC7.C7_QUJE <> 0	"+CRLF
	_cSql	+=	"	                                AND SC7.C7_LOCAL IN "+ _cInLocal +" "+CRLF	
	_cSql	+=	"	                                AND SC7.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      GROUP BY  SC7.C7_PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM ,	"+CRLF
	_cSql	+=	"	                                SC7.C7_LOCAL	"+CRLF
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT * FROM (SELECT    'A4-D4ANT' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SD4.D4_COD	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SD4.D4_COD PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SD4.D4_LOCAL <> '99' THEN SD4.D4_LOCAL  "+CRLF
	_cSql	+=	"	                                ELSE CASE WHEN ZCO.ZCO_SEQUEN = '1' THEN '01'  "+CRLF
	_cSql	+=	"	                                WHEN ZCO.ZCO_SEQUEN = '2' THEN '20'  "+CRLF
	_cSql	+=	"	                                ELSE '01' END END  XLOCAL ,	"+CRLF
	_cSql	+=	"	                                " +ValtoSql(dDataRef) + " DTREF ,	"+CRLF
	_cSql	+=	"	                                'SAIDAS ACUMULADAS ANTERIORES' DOCREF ,	"+CRLF
	_cSql	+=	"	                                SUM(SD4.D4_QUANT) * ( -1 ) QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SD4') + " SD4 ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SD4.D4_COD	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SC2') + " SC2 ( NOLOCK ) ON SC2.C2_FILIAL = " +ValtoSql(xFilial("SC2"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SC2.C2_NUM = SUBSTRING(SD4.D4_OP,	"+CRLF
	_cSql	+=	"	                                                              1, 6)	"+CRLF
	_cSql	+=	"	                                                              AND SC2.C2_ITEM = SUBSTRING(SD4.D4_OP,	"+CRLF
	_cSql	+=	"	                                                              7, 2)	"+CRLF
	_cSql	+=	"	                                                              AND SC2.C2_SEQUEN = '001'	"+CRLF
	_cSql	+=	"	                                                              AND SC2.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " ZB1 ( NOLOCK ) ON ZB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.B1_COD = SC2.C2_PRODUTO	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.B1_MSBLQL <> '1' "
	_cSql	+=	"	                                                              AND ZB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.B1_YCLASSE = '1'	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                LEFT JOIN "+ RETSQLNAME('ZCO') + " ZCO ( NOLOCK ) ON ZCO.ZCO_FILIAL = " +ValtoSql(xFilial("ZCO"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND ZCO.ZCO_LINHA = SC2.C2_LINHA	"+CRLF
	_cSql	+=	"	                                                              AND ZCO.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('ZCN') + " ZCN ( NOLOCK ) ON ZCN.ZCN_FILIAL = " +ValtoSql(xFilial("ZCO"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_COD = SD4.D4_COD	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_SEQUEN = ZCO.ZCO_SEQUEN	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_POLIT = '2'	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SBZ') + " SBZ ( NOLOCK ) ON SBZ.BZ_FILIAL = " +ValtoSql(xFilial("SBZ"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SBZ.BZ_COD = SD4.D4_COD	"+CRLF
	_cSql	+=	"	                                                              AND SBZ.D_E_L_E_T_ = ' '	"+CRLF
	//_cSql	+=	"	                               								  AND SBZ.BZ_YBLSCPC <> '1'	"+CRLF
	_cSql	+=	"	                      WHERE     SD4.D4_FILIAL = " +ValtoSql(xFilial("SD4"))+ "	"+CRLF
	_cSql	+=	"	                                AND SD4.D4_DATA BETWEEN " + ValtoSql(_dIniHist) + " AND " +ValtoSql(dDataRef) + "	"+CRLF
	_cSql	+=	"	                                AND (SD4.D4_LOCAL IN "+ _cInLocal +" OR D4_LOCAL = '99') "+CRLF	
	_cSql	+=	"	                                AND SD4.D4_QUANT > 0	"+CRLF
	_cSql	+=	"	                                AND SD4.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      GROUP BY  SD4.D4_COD ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM ,	"+CRLF
	_cSql	+=	"	                                SD4.D4_LOCAL,	"+CRLF
	_cSql	+=	"	                                SC2.C2_NUM ,	"+CRLF
	_cSql	+=	"	                                SC2.C2_ITEM ,	"+CRLF
	_cSql	+=	"	                                SC2.C2_SEQUEN ,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_PE ,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_YTMPFAB,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_YTMPIND,	"+CRLF
	_cSql	+=	"	                                ZCO.ZCO_SEQUEN )D4_GER" + CRLF
	_cSql	+=	"	                                WHERE D4_GER.XLOCAL IN "+ _cInLocal +" "+CRLF	
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT    'A5-C1AUT' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SC1.C1_PRODUTO	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_PRODUTO PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_LOCAL XLOCAL ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_DATPRF DTREF ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_NUM DOCREF ,	"+CRLF
	_cSql	+=	"	                                SUM(SC1.C1_QUANT - SC1.C1_QUJE) QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SC1') + " SC1 ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SC1.C1_PRODUTO	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      WHERE     SC1.C1_FILIAL = " +ValtoSql(xFilial("SC1"))+ "	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_DATPRF BETWEEN "+ValToSql(_dIniSem1)+" AND "+ValToSql(_dFimHist)+"	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_PEDIDO = '      '	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_RESIDUO = ' '	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_APROV NOT IN ( 'B', 'R' )	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_QUANT - C1_QUJE <> 0	"+CRLF
	_cSql	+=	"	                                AND SC1.C1_LOCAL IN "+ _cInLocal +" "+CRLF	
	_cSql	+=	"	                                AND SC1.C1_YTOTEST NOT IN ( 'T', 'P' )	"+CRLF
	_cSql	+=	"	                                AND SC1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      GROUP BY  SC1.C1_PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_LOCAL ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_DATPRF ,	"+CRLF
	_cSql	+=	"	                                SC1.C1_NUM	"+CRLF
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT    'A6-C7ATU' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SC7.C7_PRODUTO	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SC7.C7_PRODUTO PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                SC7.C7_LOCAL XLOCAL ,	"+CRLF
	
	//Solicitação Ticket 28921 - Pablo S Nascimento 04/01/2021
	//_cSql	+=	"	                                SC7.C7_YDTNECE DTREF ,	"+CRLF
	_cSql	+=	"	                                SC7.C7_YDATCHE DTREF ,	"+CRLF
	
	_cSql	+=	"	                                SC7.C7_NUM DOCREF ,	"+CRLF
	_cSql	+=	"	                                SUM(SC7.C7_QUANT - SC7.C7_QUJE) QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SC7') + " SC7 ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SC7.C7_PRODUTO	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      WHERE     SC7.C7_FILIAL = " +ValtoSql(xFilial("SC7"))+ "	"+CRLF
	
	//Solicitação Ticket 28921 - Pablo S Nascimento 04/01/2021
	//_cSql	+=	"	                                AND SC7.C7_YDTNECE BETWEEN "+ValToSql(_dIniSem1)+" AND "+ValToSql(_dFimHist)+"	"+CRLF
	_cSql	+=	"	                                AND SC7.C7_YDATCHE BETWEEN "+ValToSql(_dIniSem1)+" AND "+ValToSql(_dFimHist)+"	"+CRLF
	
	_cSql	+=	"	                                AND SC7.C7_RESIDUO = ' '	"+CRLF
	_cSql	+=	"	                                AND SC7.C7_LOCAL IN "+ _cInLocal +" "+CRLF
	_cSql	+=	"	                                AND SC7.C7_QUANT - SC7.C7_QUJE <> 0	"+CRLF
	_cSql	+=	"	                                AND SC7.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      GROUP BY  SC7.C7_PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM ,	"+CRLF
	_cSql	+=	"	                                SC7.C7_LOCAL ,	"+CRLF
	
	//Solicitação Ticket 28921 - Pablo S Nascimento 04/01/2021
	//_cSql	+=	"	                                SC7.C7_YDTNECE ,	"+CRLF
	_cSql	+=	"	                                SC7.C7_YDATCHE ,	"+CRLF
	
	_cSql	+=	"	                                SC7.C7_NUM	"+CRLF
	_cSql	+=	"	                      UNION ALL	"+CRLF
	_cSql	+=	"	                      SELECT * FROM (SELECT    'A7-D4ATU' ORIG ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SB1.B1_YCODCOM = '               '	"+CRLF
	_cSql	+=	"	                                     THEN SD4.D4_COD	"+CRLF
	_cSql	+=	"	                                     ELSE SB1.B1_YCODCOM	"+CRLF
	_cSql	+=	"	                                END PRODUTO ,	"+CRLF
	_cSql	+=	"	                                SD4.D4_COD PRODATU ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM VIGENTE ,	"+CRLF
	_cSql	+=	"	                                CASE WHEN SD4.D4_LOCAL <> '99' THEN SD4.D4_LOCAL  "+CRLF
	_cSql	+=	"	                                ELSE CASE WHEN ZCO.ZCO_SEQUEN = '1' THEN '01'  "+CRLF
	_cSql	+=	"	                                WHEN ZCO.ZCO_SEQUEN = '2' THEN '20'  "+CRLF
	_cSql	+=	"	                                ELSE '01' END END  XLOCAL ,	"+CRLF
	_cSql	+=	"	                                CONVERT(CHAR(10), CONVERT(DATETIME, SD4.D4_DATA)	"+CRLF
	_cSql	+=	"	                                - ( SBZ.BZ_YTMPIND + SBZ.BZ_YTMPFAB ), 112) DTREF ,	"+CRLF
	_cSql	+=	"	                                SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN DOCREF ,	"+CRLF
	_cSql	+=	"	                                SUM(SD4.D4_QUANT) * ( -1 ) QUANT	"+CRLF
	_cSql	+=	"	                      FROM      "+ RETSQLNAME('SD4') + " SD4 ( NOLOCK )	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ( NOLOCK ) ON SB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SB1.B1_COD = SD4.D4_COD	"+CRLF
	_cSql	+=	"	                                                              AND ((SB1.B1_MSBLQL <> '1') OR ( SB1.B1_YCODCOM <> '' AND EXISTS ( "+CRLF
	_cSql	+=	"																  SELECT 1 " + CRLF
	_cSql	+=	"																  FROM "+ RetSqlName("SB1")+ " B1COM " +CRLF
	_cSql	+=	"																  JOIN "+ RetSqlName("SBZ")+ " BZCOM " +CRLF
	_cSql	+=	"																  ON BZCOM.BZ_COD = B1COM.B1_COD " +CRLF
	_cSql	+=	"																  AND BZCOM.BZ_YBLSCPC <> '1' " +CRLF	
	_cSql	+=	"																  AND BZCOM.D_E_L_E_T_ = '' " +CRLF	
	_cSql	+=	"																  WHERE B1COM.B1_COD = SB1.B1_YCODCOM " +CRLF
	_cSql	+=	"																  	AND B1COM.D_E_L_E_T_ = '' " +CRLF
	_cSql	+=	"																  	AND B1COM.B1_MSBLQL <> '1' )))" +CRLF
	_cSql	+=	"	                                                              AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SC2') + " SC2 ( NOLOCK ) ON SC2.C2_FILIAL = " +ValtoSql(xFilial("SC2"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SC2.C2_NUM = SUBSTRING(SD4.D4_OP,	"+CRLF
	_cSql	+=	"	                                                              1, 6)	"+CRLF
	_cSql	+=	"	                                                              AND SC2.C2_ITEM = SUBSTRING(SD4.D4_OP,	"+CRLF
	_cSql	+=	"	                                                              7, 2)	"+CRLF
	_cSql	+=	"	                                                              AND SC2.C2_SEQUEN = '001'	"+CRLF
	_cSql	+=	"	                                                              AND SC2.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SB1') + " ZB1 ( NOLOCK ) ON ZB1.B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.B1_COD = SC2.C2_PRODUTO	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.B1_MSBLQL <> '1'	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.B1_YCLASSE = '1'	"+CRLF
	_cSql	+=	"	                                                              AND ZB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('SBZ') + " SBZ ( NOLOCK ) ON SBZ.BZ_FILIAL = " +ValtoSql(xFilial("SBZ"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND SBZ.BZ_COD = SD4.D4_COD	"+CRLF
	_cSql	+=	"	                                                              AND SBZ.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                               								  AND SBZ.BZ_YBLSCPC <> '1'	"+CRLF
	_cSql	+=	"	                                LEFT JOIN "+ RETSQLNAME('ZCO') + " ZCO ( NOLOCK ) ON ZCO.ZCO_FILIAL = " +ValtoSql(xFilial("ZCO"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND ZCO.ZCO_LINHA = SC2.C2_LINHA	"+CRLF
	_cSql	+=	"	                                                              AND ZCO.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                                INNER JOIN "+ RETSQLNAME('ZCN') + " ZCN ( NOLOCK ) ON ZCN.ZCN_FILIAL = " +ValtoSql(xFilial("ZCO"))+ "	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_COD = SD4.D4_COD	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_SEQUEN = ZCO.ZCO_SEQUEN	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.ZCN_POLIT = '2'	"+CRLF
	_cSql	+=	"	                                                              AND ZCN.D_E_L_E_T_ = ' '	"+CRLF	
	_cSql	+=	"	                      WHERE     SD4.D4_FILIAL = " +ValtoSql(xFilial("SD4"))+ "	"+CRLF
	_cSql	+=	"	                                AND SD4.D4_DATA BETWEEN "+ValToSql(_dIniSem1)+" AND "+ValToSql(_dFimHist)+"	"+CRLF
	_cSql	+=	"	                                AND (SD4.D4_LOCAL IN "+ _cInLocal +" OR D4_LOCAL = '99') "+CRLF	
	_cSql	+=	"	                                AND SD4.D4_QUANT > 0	"+CRLF
	_cSql	+=	"	                                AND SD4.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	                      GROUP BY  SD4.D4_COD ,	"+CRLF
	_cSql	+=	"	                                SB1.B1_YCODCOM ,	"+CRLF
	_cSql	+=	"	                                SD4.D4_LOCAL ,	"+CRLF
	_cSql	+=	"	                                SD4.D4_DATA ,	"+CRLF
	_cSql	+=	"	                                SC2.C2_NUM ,	"+CRLF
	_cSql	+=	"	                                SC2.C2_ITEM ,	"+CRLF
	_cSql	+=	"	                                SC2.C2_SEQUEN ,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_PE ,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_YTMPFAB,	"+CRLF
	_cSql	+=	"	                                SBZ.BZ_YTMPIND,	"+CRLF
	_cSql	+=	"	                                ZCO.ZCO_SEQUEN	) D4_GER"+CRLF
	_cSql	+=	"	                                WHERE D4_GER.XLOCAL IN "+ _cInLocal +" "+CRLF
	_cSql	+=	"	                    ) AS TABFFY	"+CRLF
	_cSql	+=	"	                    INNER JOIN "+ RETSQLNAME('SB1') + " SB1 ON B1_FILIAL = " +ValtoSql(xFilial("SB1"))+ "	"+CRLF
	_cSql	+=	"	                                             AND B1_COD = PRODUTO	"+CRLF
	_cSql	+=	"	                                             AND B1_GRUPO IN" +cInGrp+"	"+CRLF
	_cSql	+=	"	                                             AND SB1.B1_MSBLQL <> '1'	"+CRLF
	_cSql	+=	"	                                             AND SB1.B1_CONTRAT <> 'S'	"+CRLF
	_cSql	+=	"	                                             AND SB1.D_E_L_E_T_ = ' '	"+CRLF
	_cSql	+=	"	        ) AS ARQTRABTMP	"+CRLF

	_nError := TcSqlExec(_cSql)
	

	If _nError <> 0 .And. !Empty(TcSqlError()) 
		MsgInfo("Ocorreu um Erro ao Gerar os Dados!")
		_lRet	:=	.F.
	Endi
	
Return _lRet

//Validação de campos do grid de Solicitações
User Function BG028FOK()

	Local cVar	:=	ReadVar()
	Local _aSemanas	:=	{0,0,0,0,0}
	Local _nI

	Local _nPosDig	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "DATDIG"})
	Local _nPosQtd	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "QTDDIG"})

	Local _nPosNes	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "DATNES"})
	Local _nPosLtEco	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "LOTECO"})

	Local nPosDel	:=	Len(aHeader)+1

	Local _nPos

	If cVar == "M->DATDIG"
		If M->DATDIG < _dIniSem1
			MsgInfo("Não é possível inserir solicitação com data inderior à da semana 1")
			Return .F.
		EndIf
		For _nI	:= 1 to Len(oGdSol:aCols)
			If !ogdSol:aCols[_nI,nPosDel]
				If _nI == oGdSol:nAt
					_aSemanas[fSemana(M->DATDIG)]	+=	oGdSol:aCols[_nI,_nPosQtd]
				Else
					_aSemanas[fSemana(oGdSol:aCols[_nI,_nPosDig])] += oGdSol:aCols[_nI,_nPosQtd]
				EndIf
			EndIf
		Next
	EndIf

	If cVar	== "M->QTDDIG"
		If oGdGeral:aCols[oGdGeral:nAt,_nPosLtEco] > 0 .And. M->QTDDIG % oGdGeral:aCols[oGdGeral:nAt,_nPosLtEco] > 0
			MsgInfo("Quantidade digitada não é múltipla do lote econômico!")
		EndIf
		For _nI	:= 1 to Len(oGdSol:aCols)
			If !ogdSol:aCols[_nI,nPosDel]
				If _nI == oGdSol:nAt
					_aSemanas[fSemana(oGdSol:aCols[_nI,_nPosDig])]	+=	M->QTDDIG
				Else
					_aSemanas[fSemana(oGdSol:aCols[_nI,_nPosDig])] += oGdSol:aCols[_nI,_nPosQtd]
				EndIf
			EndIF
		Next
	EndIf

	fPopGraf(_aSemanas)

	If (_nPos := aScan(aSolProd,{|x| x[1] == oGdGeral:Acols[oGdGeral:nAt][2] .And. x[2] == oGdGeral:Acols[oGdGeral:nAt][4] })) > 0
		aSolProd[_nPos,3]	:= {}
	Else
		aAdd(aSolProd,{oGdGeral:Acols[oGdGeral:nAt][2],oGdGeral:Acols[oGdGeral:nAt][4],{}})
		_nPos	:=	Len(aSolProd)
	EndIf

	For _nI	:=	1 to Len(ogdSol:aCols)
		If !ogdSol:aCols[_nI,nPosDel]
			aAdd(aSolProd[_nPos,3],{;
			ogdSol:aCols[_nI,1],;
			ogdSol:aCols[_nI,2],;
			Iif(cVar == "M->DATDIG" .And. _nI == oGdSol:nAt, M->DATDIG,ogdSol:aCols[_nI,3]),;
			Iif(cVar == "M->QTDDIG" .And. _nI == oGdSol:nAt, M->QTDDIG,ogdSol:aCols[_nI,4])})
		ElseIf (!Empty(oGdSol:aCols[_nI,_nPosNes]))
			aAdd(aSolProd[_nPos,3],{;
			ogdSol:aCols[_nI,1],;
			ogdSol:aCols[_nI,2],;
			StoD(""),;
			0})
		EndIf
	Next

Return .T.

Static Function fSemana(_dData)

	Local _nSemana	:=	0

	Do Case
		Case _dData >= _dIniSem1 .And. _dData < _dIniSem2
		_nSemana	:=	1
		Case _dData >= _dIniSem2 .And. _dData < _dIniSem3
		_nSemana	:=	2
		Case _dData >= _dIniSem3 .And. _dData < _dIniSem4
		_nSemana	:=	3
		Case _dData >= _dIniSem4 .And. _dData < _dIniSem5
		_nSemana	:=	4
		OtherWise
		_nSemana	:=	5
	EndCase

Return _nSemana

//Função que projeta Solicitações
Static Function fProjSol()

	Local _nI
	Local _nJ
	Local _nPosProd		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "PRODUT"})
	Local _nPosLocal	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "LOCPRD"})
	Local _nPosLtEco	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "LOTECO"})
	Local _nPosSal1		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "SAL1"})
	Local _nPosSal2		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "SAL2"})
	Local _nPosSal3		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "SAL3"})
	Local _nPosSal4		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "SAL4"})
	Local _nPosSal5		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) ==  "SAL5"})
	Local _nSalAcu		:=	0
	Local _aSemanas		:=	{0,0,0,0,0}
	Local _lSugere		:=	.F.

	For _nI	:= 1 To Len(oGdGeral:aCols)
		_aSemanas	:=	{0,0,0,0,0}
		_nSalAcu	:=	0
		_lSugere	:=	.F.

		//Semana 2
		If oGdGeral:aCols[_nI,_nPosSal2] + _nSalAcu < 0

			If oGdGeral:aCols[_nI,_nPosLtEco] > 0
				_aSemanas[2]	:=	oGdGeral:aCols[_nI,_nPosLtEco] * (Ceiling((oGdGeral:aCols[_nI,_nPosSal2]+ _nSalAcu)/oGdGeral:aCols[_nI,_nPosLtEco] * -1 ) )
			Else
				_aSemanas[2]	:=	(oGdGeral:aCols[_nI,_nPosSal2]+ _nSalAcu) * -1
			EndIf
			_lSugere	:=	.T.
			_nSalAcu	+=	_aSemanas[2]

		EndIf

		//Semana 3
		If oGdGeral:aCols[_nI,_nPosSal3] + _nSalAcu < 0

			If oGdGeral:aCols[_nI,_nPosLtEco] > 0
				_aSemanas[3]	:=	oGdGeral:aCols[_nI,_nPosLtEco] * (Ceiling((oGdGeral:aCols[_nI,_nPosSal3]+ _nSalAcu)/oGdGeral:aCols[_nI,_nPosLtEco] * -1) )
			
			Else
				_aSemanas[3]	:=	(oGdGeral:aCols[_nI,_nPosSal3] + _nSalAcu) * -1
			EndIf
			_lSugere	:=	.T.
			_nSalAcu	+=	_aSemanas[3]

		EndIf

		//Semana 4
		If oGdGeral:aCols[_nI,_nPosSal4] + _nSalAcu < 0

			If oGdGeral:aCols[_nI,_nPosLtEco] > 0
				_aSemanas[4]	:=	oGdGeral:aCols[_nI,_nPosLtEco] * (Ceiling((oGdGeral:aCols[_nI,_nPosSal4]+_nSalAcu)/oGdGeral:aCols[_nI,_nPosLtEco] * -1) )

			Else
				_aSemanas[4]	:=	(oGdGeral:aCols[_nI,_nPosSal4] + _nSalAcu) * -1
			EndIf
			_lSugere	:=	.T.
			_nSalAcu	+=	_aSemanas[4]

		EndIf

		//Semana 5
		If oGdGeral:aCols[_nI,_nPosSal5] + _nSalAcu < 0

			If oGdGeral:aCols[_nI,_nPosLtEco] > 0
				_aSemanas[5]	:=	oGdGeral:aCols[_nI,_nPosLtEco] * (Ceiling((oGdGeral:aCols[_nI,_nPosSal5]+ _nSalAcu)/oGdGeral:aCols[_nI,_nPosLtEco] * -1 ) )

			Else
				_aSemanas[5]	:=	(oGdGeral:aCols[_nI,_nPosSal5]+ _nSalAcu) * -1
			EndIf
			_lSugere	:=	.T.

		EndIf

		If _lSugere

			oGdGeral:aCols[_nI,1]	:=	"BR_AZUL"

			aAdd(aSolProd,{oGdGeral:aCols[_nI,_nPosProd],oGdGeral:aCols[_nI,_nPosLocal] ,{}})

			//Semana 2
			If _aSemanas[2] > 0
				aAdd(aSolProd[Len(aSolProd),3],{;
				_dIniSem1,;
				_aSemanas[2],;
				Iif(MV_PAR03 == "1",_dIniSem1,Stod("")),;
				Iif(MV_PAR03 == "1",_aSemanas[2],0)})

			EndIf

			//Semana 3
			If _aSemanas[3] > 0
				aAdd(aSolProd[Len(aSolProd),3],{;
				_dIniSem2,;
				_aSemanas[3],;
				Iif(MV_PAR03 == "1",_dIniSem2,Stod("")),;
				Iif(MV_PAR03 == "1",_aSemanas[3],0)})

			EndIf

			//Semana 4
			If _aSemanas[4] > 0
				aAdd(aSolProd[Len(aSolProd),3],{;
				_dIniSem3,;
				_aSemanas[4],;
				Iif(MV_PAR03 == "1",_dIniSem3,Stod("")),;
				Iif(MV_PAR03 == "1",_aSemanas[4],0)})

			EndIf

			//Semana 5
			If _aSemanas[5] > 0
				aAdd(aSolProd[Len(aSolProd),3],{;
				_dIniSem4,;
				_aSemanas[5],;
				Iif(MV_PAR03 == "1",_dIniSem4,Stod("")),;
				Iif(MV_PAR03 == "1",_aSemanas[5],0)})

			EndIf

		EndIf

	Next

Return

//Funcao Criada para tratar campos data
Static Function fChgSol()

	Local _nPosDig	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "DATDIG"})
	Local _nPosNes	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "DATNES"})
	Local _nPosQtSu	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "QTDSUG"})
	Local _nPosQtDi	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "QTDDIG"})

	If oGdSol:lNewLine .And. (Empty(oGdSol:Acols[oGdSol:nAt,_nPosQtSu]) .And. (Empty(oGdSol:Acols[oGdSol:nAt,_nPosQtSu]) .And. Empty(oGdSol:Acols[oGdSol:nAt,_nPosQtDi])))

		oGdSol:Acols[oGdSol:nAt,_nPosDig]	:=	Stod("")
		oGdSol:Acols[oGdSol:nAt,_nPosNes]	:=	Stod("")

		oGdSol:ReFresh()
	EndIf

Return

//Função ao deletar para garantir integridade
User Function BG028DOK()

	Local _aSemanas	:=	{0,0,0,0,0}
	Local _nI
	Local nPosDel	:= Len(ogdSol:aHeader) + 1
	Local _nPos
	Local _nPosDig	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "DATDIG"})
	Local _nPosQtd	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "QTDDIG"})
	Local _nPosNes	:=	aScan(oGdSol:aHeader,{|x| Alltrim(x[2]) == "DATNES"})

	For _nI	:= 1 to Len(oGdSol:aCols)
		If (!ogdSol:aCols[_nI,nPosDel] .And. _nI <> oGdSol:nAt) .Or. (_nI == oGdSol:nAt .And. ogdSol:aCols[_nI,nPosDel])
			_aSemanas[fSemana(oGdSol:aCols[_nI,_nPosDig])] += oGdSol:aCols[_nI,_nPosQtd]
		EndIF
	Next

	fPopGraf(_aSemanas)

	If (_nPos := aScan(aSolProd,{|x| x[1] == oGdGeral:Acols[oGdGeral:nAt][2] .And. x[2] == oGdGeral:Acols[oGdGeral:nAt][4]})) > 0
		aSolProd[_nPos,3]	:= {}
	Else
		aAdd(aSolProd,{oGdGeral:Acols[oGdGeral:nAt][3],{}})
		_nPos	:=	Len(aSolProd)
	EndIf

	For _nI	:=	1 to Len(ogdSol:aCols)
		If (!ogdSol:aCols[_nI,nPosDel] .And. _nI <> oGdSol:nAt) .Or. (_nI == oGdSol:nAt .And. ogdSol:aCols[_nI,nPosDel])
			aAdd(aSolProd[_nPos,3],{;
			ogdSol:aCols[_nI,1],;
			ogdSol:aCols[_nI,2],;
			ogdSol:aCols[_nI,3],;
			ogdSol:aCols[_nI,4]})
		ElseIf (!Empty(oGdSol:aCols[_nI,_nPosNes]))
			If MV_PAR03 == "1"
				aAdd(aSolProd[_nPos,3],{;
				ogdSol:aCols[_nI,1],;
				ogdSol:aCols[_nI,2],;
				ogdSol:aCols[_nI,1],;
				ogdSol:aCols[_nI,2]})
			Else
				aAdd(aSolProd[_nPos,3],{;
				ogdSol:aCols[_nI,1],;
				ogdSol:aCols[_nI,2],;
				StoD(""),;
				0})
			EndIf
		EndIf
	Next

	oGdSol:Refresh()

Return .T.

//Função para gravar solicitações e log
Static Function fGrava()

	Local _nI
	Local _nJ
	Local _nPosProd		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PRODUT"})
	Local _nPosUm		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "UMPROD"})
	Local _nPosLocal	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "LOCPRD"})
	Local _nPosEstm		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "ESTMIN"})
	Local _nPosLtEco	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "LOTECO"})
	Local _nPosEstSe	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "ESTSEG"})
	Local _nPosEstAt	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "ESTATU"})
	Local _nPosEntAn	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "ENTANT"})
	Local _nPosSaiAn	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAIANT"})
	Local _nPosSai1		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI1"	})
	Local _nPosSal1		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL1"	})
	Local _nPosSai2		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI2"	})
	Local _nPosSal2		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL2"	})
	Local _nPosSai3		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI3"	})
	Local _nPosSal3		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL3"	})
	Local _nPosSai4		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI4"	})
	Local _nPosSal4		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL4"	})
	Local _nPosSai5		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAI5"	})
	Local _nPosSal5		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "SAL5"	})
	Local _nPosDisp		:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "DISPO"})
	Local _nPosNCom1	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM1"	})
	Local _nPosNCom2	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM2"	})
	Local _nPosNCom3	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM3"	})
	Local _nPosNCom4	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM4"	})
	Local _nPosNCom5	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "NECOM5"	})
	Local _nPosPcAb1	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB1"	})
	Local _nPosPcAb2	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB2"	})
	Local _nPosPcAb3	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB3"	})
	Local _nPosPcAb4	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB4"	})
	Local _nPosPcAb5	:=	aScan(oGdGeral:aHeader,{|x| Alltrim(x[2]) == "PDCAB5"	})

	Local _cCodigo	:=	fGetCod()

	Local _aCabSol	:=	{}
	Local _aLinSol	:=	{}
	Local _aIteSol	:=	{}

	Local _cDoc

	Local _cNumSc

	BEGIN TRANSACTION
		For _nI	:= 1 To Len(oGdGeral:aCols)

			Reclock("ZC3",.T.)

			ZC3->ZC3_FILIAL :=	xFilial("ZC3")
			ZC3->ZC3_CODIGO	:=	_cCodigo
			ZC3->ZC3_DATREF	:=	dDataBase
			ZC3->ZC3_TPGRID	:=	"GERAL"

			ZC3->ZC3_PRODUT	:=	oGdGeral:aCols[_nI,_nPosProd]
			ZC3->ZC3_UM		:=	oGdGeral:aCols[_nI,_nPosUm]
			ZC3->ZC3_LOCAL	:=	oGdGeral:aCols[_nI,_nPosLocal]
			ZC3->ZC3_LTECON	:=	oGdGeral:aCols[_nI,_nPosLtEco]
			ZC3->ZC3_ESTSEG	:=	oGdGeral:aCols[_nI,_nPosEstSe]
			ZC3->ZC3_ESTATU	:=	oGdGeral:aCols[_nI,_nPosEstAt]
			ZC3->ZC3_ENTANT	:=	oGdGeral:aCols[_nI,_nPosEntAn]
			ZC3->ZC3_SAIANT	:=	oGdGeral:aCols[_nI,_nPosSaiAn]
			ZC3->ZC3_SAISM1	:=	oGdGeral:aCols[_nI,_nPosSai1]
			ZC3->ZC3_SLDSM1	:=	oGdGeral:aCols[_nI,_nPosSal1]
			ZC3->ZC3_SAISM2	:=	oGdGeral:aCols[_nI,_nPosSai2]
			ZC3->ZC3_SLDSM2	:=	oGdGeral:aCols[_nI,_nPosSal2]
			ZC3->ZC3_SAISM3	:=	oGdGeral:aCols[_nI,_nPosSai3]
			ZC3->ZC3_SLDSM3	:=	oGdGeral:aCols[_nI,_nPosSal3]
			ZC3->ZC3_SAISM4	:=	oGdGeral:aCols[_nI,_nPosSai4]
			ZC3->ZC3_SLDSM4	:=	oGdGeral:aCols[_nI,_nPosSal4]
			ZC3->ZC3_SAISM5	:=	oGdGeral:aCols[_nI,_nPosSai5]
			ZC3->ZC3_SLDSM5	:=	oGdGeral:aCols[_nI,_nPosSal5]
			ZC3->ZC3_DISPON	:=	oGdGeral:aCols[_nI,_nPosDisp]
			
			ZC3->ZC3_NECOM1	:=	oGdGeral:aCols[_nI,_nPosNCom1]
			ZC3->ZC3_NECOM2	:=	oGdGeral:aCols[_nI,_nPosNCom2]
			ZC3->ZC3_NECOM3	:=	oGdGeral:aCols[_nI,_nPosNCom3]
			ZC3->ZC3_NECOM4	:=	oGdGeral:aCols[_nI,_nPosNCom4]
			ZC3->ZC3_NECOM5	:=	oGdGeral:aCols[_nI,_nPosNCom5]

			ZC3->ZC3_PDCAB1	:=	oGdGeral:aCols[_nI,_nPosPcAb1]
			ZC3->ZC3_PDCAB2	:=	oGdGeral:aCols[_nI,_nPosPcAb2]
			ZC3->ZC3_PDCAB3	:=	oGdGeral:aCols[_nI,_nPosPcAb3]
			ZC3->ZC3_PDCAB4	:=	oGdGeral:aCols[_nI,_nPosPcAb4]
			ZC3->ZC3_PDCAB5	:=	oGdGeral:aCols[_nI,_nPosPcAb5]

			ZC3->(MsUnlock())
		Next

		For _nI	:=	1 to Len(aSolProd)

			For _nJ	:=	1 to Len(aSolProd[_nI,3])

				_cNumSc	:=	""
				If !Empty(aSolProd[_nI,3,_nJ,3]) .And. !Empty(aSolProd[_nI,3,_nJ,4])

					_cDoc := GetNumSC1()

					_aCabSol	:=	{}
					aadd(_aCabSol,{"C1_NUM"     , _cDoc })
					aadd(_aCabSol,{"C1_SOLICIT" , UsrRetName(RetCodUsr()) })
					aadd(_aCabSol,{"C1_EMISSAO" , dDataBase })
					aadd(_aCabSol,{"C1_FILENT"  , cFilAnt })

					_aLinSol	:=	{}
					_aIteSol	:=	{}
					aadd(_aLinSol,{"C1_ITEM"    , PADL("1",TAMSX3("C1_ITEM")[1],"0") 	                                   , Nil})
					aadd(_aLinSol,{"C1_PRODUTO" , aSolProd[_nI][1]                                                   , Nil})
					aadd(_aLinSol,{"C1_LOCAL" , aSolProd[_nI][2]                                                   , Nil})
					aadd(_aLinSol,{"C1_YSTATUS" , "N"                                                                   , Nil})
					aadd(_aLinSol,{"C1_DATPRF"  ,aSolProd[_nI,3,_nJ,3]			                                      , Nil})
					aadd(_aLinSol,{"C1_YAPLIC"  , "0"                                                                   , Nil})
					aadd(_aLinSol,{"C1_QUANT"   , aSolProd[_nI,3,_nJ,4]                                                 , Nil})
					aadd(_aLinSol,{"C1_QTSEGUM" , ConvUm(aSolProd[_nI][1], aSolProd[_nI,3,_nJ,4], 0, 2)               , Nil})

					aAdd(_aIteSol,_aLinSol)

					lMsErroAuto	:=	.F.
					MSExecAuto({|x,y| mata110(x,y)}, _aCabSol, _aIteSol, 3, .F., .T.)
					If !lMsErroAuto
						_cNumSc	:=	_cDoc
					else
						MostraErro()
						_cNumSc	:=	"XXXXXX"
					EndIf
				EndIf

				Reclock("ZC3",.T.)

				ZC3->ZC3_FILIAL :=	xFilial("ZC3")
				ZC3->ZC3_CODIGO	:=	_cCodigo
				ZC3->ZC3_DATREF	:=	dDataBase
				ZC3->ZC3_TPGRID	:=	"SOLIC"
				ZC3->ZC3_PRODUT :=	aSolProd[_nI][1]  
				ZC3->ZC3_LOCAL := aSolProd[_nI][2]
				ZC3->ZC3_DTSUGE	:=	aSolProd[_nI,3,_nJ,1]
				ZC3->ZC3_QTDSUG	:=	aSolProd[_nI,3,_nJ,2]
				ZC3->ZC3_DATDIG	:=	aSolProd[_nI,3,_nJ,3]
				ZC3->ZC3_QTDDIG	:=	aSolProd[_nI,3,_nJ,4]
				ZC3->ZC3_NUMSC	:=	_cNumSc
				ZC3->ZC3_USER	:=	__CUserId

				ZC3->(MsUnlock())

			Next

		Next
		MsgInfo("Processo de Gravação de Solicitações de Compra Concluído!")
		oDlgMRP:End()
	END TRANSACTION
Return

Static Function fGetCod()

	Local _cAlias	:=	GetNextAlias()
	Local _cCod		:=	""

	BeginSql Alias _cAlias

		SELECT ISNULL(MAX(ZC3_CODIGO),'000000') COD
		FROM %TABLE:ZC3% ZC3
		WHERE ZC3_FILIAL = %XFILIAL:ZC3%
		AND %NotDel%
	EndSql

	_cCod	:=	Soma1((_cAlias)->COD)

	(_cAlias)->(DbCloseArea())

Return _cCod

Static Function fRefrGer()

	Local _nI

	For _nI	:= 1 to Len(oGdGeral:aCols)

		oGdGeral:nAt	:=	_nI

		fAltGeral()

	Next

	oGdGeral:nAt	:=	1

	fAltGeral()
Return

Static Function fVerTemp()

	Local _cInd
	Local _cAlias	:=	GetNextAlias()
	Local _cQry		:=	""
	Local _lret
	
	_cQry	+=	" SELECT COUNT(*) QTD FROM "+ _cTabTemp +"	"+CRLF
		
	_cInd := CriaTrab(Nil,.f.)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),_cAlias,.F.,.T.)

	_lRet	:=	(_cAlias)->QTD > 0
	
	
	Ferase(_cInd+GetDBExtension())     //arquivo de trabalho
	Ferase(_cInd+OrdBagExt())          //indice gerado
	(_cAlias)->(DbCloseArea())

Return _lRet