#include "OMSA200.CH"
#include "PROTHEUS.CH"
#include "MSGRAPHI.CH"
#include "topconn.ch"
#include "rwmake.ch"

#define CARGA_ENABLE 1
#define CARGA_COD    2
#define CARGA_DESC   3
#define CARGA_PESO   4
#define CARGA_VALOR  5
#define CARGA_VOLUM  6
#define CARGA_PTOENT 7
#define CARGA_VEIC   8
#define CARGA_MOTOR  9
#define CARGA_AJUD1  10
#define CARGA_AJUD2  11
#define CARGA_AJUD3  12
/*
BEGINSQL ALIAS cSC9
COLUMN A1_DATA AS DATE
SELECT * 
FROM %Table:SA1010% SA1
WHERE A1_FILIAL = %xFilial:SA1%
AND A1_COD = %Exp:mv_par01%
SA1.%NOTDEL%
ENDSQL
*/

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    | OMSA200  | Rev.  | Henry Fila            | Data | 19.07.2001|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Programa de Geracao de carga                                |
+----------+-------------------------------------------------------------+
|Sintaxe   | Void OMSA200(void)                                          |
+----------+-------------------------------------------------------------+
|Uso       | Generico                                                    |
+----------+-------------------------------------------------------------+
| ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      |
+--------------+--------+------+-----------------------------------------+
| PROGRAMADOR  | DATA   | BOPS |  MOTIVO DA ALTERACAO                    |
+--------------+--------+------+-----------------------------------------+
|              |        |      |                                         |
+--------------+--------+------+-----------------------------------------+*/

/*+--------------------------------------------------------------+
| Define Array contendo as Rotinas a executar do programa      |
| ----------- Elementos contidos por dimensao ------------     |
| 1. Nome a aparecer no cabecalho                              |
| 2. Nome da Rotina associada                                  |
| 3. Usado pela rotina                                         |
| 4. Tipo de Transação a ser efetuada                          |
|    1 - Pesquisa e Posiciona em um Banco de Dados             |
|    2 - Simplesmente Mostra os Campos                         |
|    3 - Inclui registros no Bancos de Dados                   |
|    4 - Altera o registro corrente                            |
|    5 - Remove o registro corrente do Banco de Dados          |
+--------------------------------------------------------------+*/

User Function MOVMONTC
	Local aArea     := GetArea()
	Local aCores    := {}
	Local aIndDAK   := {}
	Local cCondicao := ""

	Private bFiltraBrw := {|| Nil}
	Private cCadastro  := OemtoAnsi(STR0001) //"Montagem de Carga"
	Private cOMS200End := CriaVar('DB_LOCALIZ')
	Private cOMS200Est := CriaVar('DB_ESTFIS')
	Private lBloq      := .F.
	Private aPedidos   := {}
	Private aPedido    := {}
	Private wcRota     := ""
	Private cIndice    := ""
	Private nMarcados  := 0
	Private nPedidos   := 0
	Private cHInicio
	Private cTempo
	Private xnCapVol   := 0
	/*+--------------------------------------------------------------+
	| Perguntas :                                                  |
	|                                                              |
	| mv_par01  // Pedidos do Tipo (PalmTop / Manual / Ambos )     |
	| mv_par02  // Do Vendedor                                     |
	| mv_par03  // Ate o Vendedor                                  |
	| mv_par04  // Da Emissao                                      |
	| mv_par05  // Ate a Emissao                                   |
	| mv_par06  // Do Pedido                                       |
	| mv_par07  // Ate o Pedido                                    |
	| mv_par08  // Do Cliente                                      |
	| mv_par09  // Ate o Cliente                                   |
	| mv_par10  // Trazer Tudo Marcado ?                           |
	| mv_par11  // Do Pedido Palm-Top                              |
	| mv_par12  // Ate Pedido Palm-Top                             |
	| mv_par13  // Utiliza Restricoes                              |
	| mv_par14  // Considera Todo Dia Quantio as Restricoes        |
	+--------------------------------------------------------------+*/

	aSubRotina := {{ OemtoAnsi("Carregamento") ,'u_OsA200Mont' , 0, 3 },; //Carregamento
	{ OemtoAnsi("Juntar")       ,'u_OS200Junta' , 0, 4 },; //Unifica
	{ OemtoAnsi("Manutencao")   ,'u_MANUTENCAO' , 0, 4 },; //Manutencao
	{ OemtoAnsi("Estorno")      ,'u_Os200Estor' , 0, 4 },; //Estorno
	{ OemtoAnsi("Sequencia")    ,'u_MOVSEQENT'  , 0, 4 },; //Bloqueio
	{ OemtoAnsi("Motorista")    ,'u_Os200Assoc' , 0, 4 },; //Motorista
	{ OemtoAnsi("Bloqueio")     ,'u_Os200Blq'   , 0, 4 }}  //Bloqueio
	//{ OemtoAnsi("Sel.Users")    ,'u_fSelUsr'    , 0, 4 },; //Limpar tabela compartilhada de saldos
	//{ OemtoAnsi("Exc. Compart."),'u_fLPTela'    , 0, 4 }}  //Limpar tabela compartilhada de saldos

	aRotina :=    {{ OemtoAnsi("Pesquisar")    ,'PesqBrw'      , 0, 1 },; //Pesquisar
	{ OemtoAnsi("Liberacao")    ,'u_Os200Liber' , 0, 0 },; //Liberacao
	{ OemtoAnsi("Carregamento") ,aSubRotina     , 0, 3 },; //Legenda
	{ OemtoAnsi("Observação")   ,'u_fObserv'    , 0, 4 },; //Observação
	{ OemtoAnsi("Legenda")      ,'u_Os200Leg'   , 0, 3 },; //Legenda
	{ OemtoAnsi("Alterar TES")  ,'u_fAltTES'    , 0, 4 }}  //Alterar TES

	If ( AMIIn(5,39) )         // SigaFat - SigaOms

		If DAK->(FieldPos("DAK_BLQCAR")) > 0
			Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '1'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","DISABLE"}) //Faturada e acertada
			Aadd(aCores,{"DAK_FEZNF == '2' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","ENABLE"})    //Totalmente em aberto
			Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '2'.And.(DAK_BLQCAR == '2' .Or. DAK_BLQCAR == ' ') .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_LARANJA"}) //Somente faturada e nao acertada
			Aadd(aCores,{"DAK_FEZNF == '2' .And. DAK_ACECAR == '2'.And.DAK_BLQCAR == '1' .And. (DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_PRETO"}) //Somente faturada e nao acertada
		Else
			Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '1'.And.(DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","DISABLE"}) //Faturada e acertada
			Aadd(aCores,{"DAK_FEZNF == '2' .And. DAK_ACECAR == '2'.And.(DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","ENABLE"})    //Totalmente em aberto
			Aadd(aCores,{"DAK_FEZNF == '1' .And. DAK_ACECAR == '2'.And.(DAK_JUNTOU=='MANUAL'.Or.DAK_JUNTOU=='ASSOCI'.Or.DAK_JUNTOU=='JUNTOU')","BR_LARANJA"}) //Somente faturada e nao acertada
		EndIf

		/*+------------------------------------------------------------------------+
		|Inclui Filial de / ate nos parametros OM341B                            |
		+------------------------------------------------------------------------+*/

		If Pergunte("OMS20A",.T.)
			cCondicao += "DAK_COD >= '"+mv_par01+"' .And. DAK_COD <= '"+mv_par02+"' .And. "
			cCondicao += "Dtos(DAK_DATA) >= '"+Dtos(mv_par03)+"' .And. Dtos(DAK_DATA) <= '"+Dtos(mv_par04)+"' "
			If mv_par05 == 1
				cCondicao += " .And. DAK_FEZNF=='2' .And. DAK_ACECAR == '2'"
			ElseIf mv_par05 == 2
				cCondicao += " .And. DAK_FEZNF =='1' .And. DAK_ACECAR == '2'"
			ElseIf mv_par05 == 3
				cCondicao += " .And. DAK_FEZNF =='1' .And. DAK_ACECAR == '1' "
			EndIf
			/*+------------------------------------------------------------------------+
			|Realiza a Filtragem                                                     |
			+------------------------------------------------------------------------+*/
			bFiltraBrw := {|| FilBrowse("DAK",@aIndDAK,@cCondicao) }
			Eval(bFiltraBrw)

			Mbrowse(6,1,22,75,"DAK",,,,,,aCores)

		EndIf
		/*+----------------------------------------------------------------+
		|Restaura a integridade da rotina                                |
		+----------------------------------------------------------------+*/
		dbSelectArea("DAK")
		RetIndex("DAK")
		dbClearFilter()
		aEval(aIndDAK,{|x| Ferase(x[1]+OrdBagExt())})
		RestArea(aArea)
	EndIf
Return(.T.)

/*
+----------+----------+-------+-----------------------+------+------------+
|Fun‡…o    |OsA200Mont| Autor |Henry Fila             | Data |02.03.2001  |
+----------+----------+-------+-----------------------+------+------------+
|Descri‡…o |Rotina de interface da Montagem de Carga                      |
+----------+--------------------------------------------------------------+
|Retorno   |Nenhum                                                        |
+----------+--------------------------------------------------------------+
|Parametros|ExpC1: Alias do Arquivo                                       |
|          |ExpN2: Numero do Registro                                     |
|          |ExpN3: Opcao do aRotina                                       |
|          |                                                              |
+----------+--------------------------------------------------------------+
|Uso       | Materiais/Distribuicao/Logistica                             |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+--------------+--------+------+------------------------------------------+
| Programador  | Data   | BOPS |  Motivo da Alteracao                     |
+--------------+--------+------+------------------------------------------+
|              |        |      |                                          |
+--------------+--------+------+------------------------------------------+*/
User Function OsA200Mont()
	Local  lAllMark     := .T.
	Local  aArea        := GetArea()
	Local   aSize       := MsAdvSize( .T. )
	Local   aPosObj1    := {}
	Local   aPosObj2    := {}
	Local   aPosObj3    := {}
	Local   aObjects    := {}
	Local   aArrayCarga := {}
	Local   aArrayZona  := {}
	Local   aArraySetor := {}
	Local   aArrayMan   := {}
	Local   aLock       := {}
	Local   aArrayMod   := {}
	Local   aArrayTipo  := {}
	Local   aCpoBrw     := {}
	// Retirada a opção de abrir nova carga, devido a necessidade de nova analise de estoque
	//{ "CARGANEW", { || OmsAbreCarga(@oEnable,@oDisable,@oMarked,@oNoMarked,@aArrayCarga) }, OemtoAnsi(STR0008) },; //"Abre Carga"
	Local   aButtons    := {}

	//Local   oProcess
	Local   aCampos     := {}

	Local   nTipoOper   := OsVlEntCom()
	Local   cCarga      := GetSx8Num("DAK","DAK_COD")
	Local   cMarca      := GetMark()
	Local   oEnable     := LoadBitmap( GetResources(), "ENABLE" )
	Local   oDisable    := LoadBitmap( GetResources(), "DISABLE" )
	Local   oNoMarked   := LoadBitmap( GetResources(), "LBNO" )
	Local   oMarked     := LoadBitmap( GetResources(), "LBOK" )
	Local cPictPeso     := "99999999." + Replicate("9",TamSx3("DAK_PESO")[2])
	Local   oDlg
	Local   oAllMark

	Private cxMarca     := cMarca
	Private aArrayRota  := {}
	Private cInd1       := ""
	Private cInd2       := ""
	Private oProcess
	Private cHrStart    := SuperGetMv("MV_CGSTART",.F.,"08:00")
	Private wcUsuario   := StrTran(Upper(Alltrim(cUsername))," ","")
	Private TRBPED      := ""
	Private TRBSALDOS   := ""

	Pergunte("MOVCAR",.F.)

	dbSelectArea("DAK")
	dbSetOrder(1)
	dbClearFilter()
	aButtons    := { { "CARGASEQ"  , { || Os200VisCg(@aArrayCarga,@aArrayMan,@cHrStart)}, OemtoAnsi(STR0009) },; //"Sequencia deEntrega"
	{ "CARGA"     , { || u_OmsTransp(@aArrayMan,@aArrayCarga,@oEnable,@oDisable,@oMarked,@oNoMarked,@cHrStart) } , OemtoAnsi(STR0012) },;
	{ "VENDEDOR"  , { || u_Os200VisCF()                          }, OemtoAnsi(STR0010)},; //"Visualizar Dados do Cliente"
	{ "PEDIDO"    , { || Os200VisPv()                            }, OemtoAnsi(STR0011) },; //"Visualizar Pedido"
	{ "S4WB011N"  , { || u_OmsPesqPed("TRBPED",aCampos,aCpoBrw)  }, OemtoAnsi(STR0117)},; //"Pesquisa de pedidos"
	{ "GRAF3D"    , { || u_OmsVisGraph(@aArrayCarga,cMarca)      }, OemtoAnsi(STR0098)},;
	{ "PMSDOC"    , { || fLibera()                               }, OemtoAnsi("Lib.Ped.")},; // Liberar item pedido
	{ "CLIENTE"   , { || fVlPed(cMarca)                          }, OemtoAnsi("Vld.Ped")},; // Valida valor mínimo dos pedidos.
	{ "RELATORIO" , { || Processa({|| fVldVinc(cMarca)})         }, OemtoAnsi("Vinculados")},; // Valida pedidos com vínculo.
	{ "PARAMETROS", { || u_MovCEst(TRBPED->PED_CODPRO,mv_par22,2)}, OemtoAnsi("Estoque")},;
	{ "RELOAD"    , { || fRefresh()                              }, OemtoAnsi("Refresh")}}
	// { "VERNOTA"   , { || u_Mov161()                              }, OemtoAnsi("Alt.Cond.Pg")}}

	/*+------------------------------------------------------------------------+
	| Traz janelas de perguntas e filtro para a montagem                     |
	+------------------------------------------------------------------------+*/
	If OmsFilTipo(@oMarked,@oNoMarked,aArrayMod,aArrayTipo)
		/*+------------------------------------------------------------------------+
		| Filtra pedidos e monta o mapa de cargas                                |
		+------------------------------------------------------------------------+*/
		cHInicio := Time()
		oProcess := MsNewProcess():New({|lEnd| OmsBuscaPed(@oEnable,;
		@oDisable,;
		@oMarked,;
		@oNoMarked,;
		@aCampos,;
		cCarga,;
		aArrayCarga,;
		aArrayRota,;
		aArrayZona,;
		aArraySetor,;
		aArrayMod,;
		aArrayTipo,;
		oProcess)},"","",.F.)

		oProcess:Activate()

		/*+------------------------------------------------------------------------+
		| Verifica se e por pedido ou item para alterar colunas na MsSelect      |
		+------------------------------------------------------------------------+*/
		Aadd(aCpoBrw,{"PED_MARCA" ,               ," "," "})
		Aadd(aCpoBrw,{"PED_CODCLI",,OemtoAnsi(STR0030)}) //"Cliente"
		Aadd(aCpoBrw,{"PED_LOJA"  ,,OemtoAnsi(STR0031)}) //"Loja"
		Aadd(aCpoBrw,{"PED_NOME"  ,,OemtoAnsi(STR0032)}) //"Nome"
		Aadd(aCpoBrw,{"PED_ROTA"  ,,"Rota"})	
		Aadd(aCpoBrw,{"PED_VEND",,"Consultor"})
		Aadd(aCpoBrw,{"PED_OBS",,"Observação"})
		Aadd(aCpoBrw,{"PED_REGRA" ,,"Blq Fin"     ,"       "})
		Aadd(aCpoBrw,{"PED_BLOQ"  ,,"Blq Siga"    ," "})
		Aadd(aCpoBrw,{"PED_BLQPED",,"Blq Ped"     ," "})       
		Aadd(aCpoBrw,{"PED_CODPRO",,"Codigo"})//"Produto"
		Aadd(aCpoBrw,{"PED_DESPRO",,"Produto"     ,Replicate(" ",80)})//"Produto"
		Aadd(aCpoBrw,{"PED_PESO"  ,,OemtoAnsi(STR0033),"99999999."+Replicate("9",TamSx3("DAK_PESO")[2])})   //"Qtde"	
		Aadd(aCpoBrw,{"PED_PEDIDO",,"Pedido"})                                                                        
		Aadd(aCpoBrw,{"PED_ITEM"  ,,"Item"})	
		Aadd(aCpoBrw,{"PED_QTDLIB",,"Qtde Liberada"})//"Quantidade" OemtoAnsi(STR0132)
		Aadd(aCpoBrw,{"PED_QTDPED",,"Qtde Pedido"})//"Quantidade" OemtoAnsi(STR0132)
		Aadd(aCpoBrw,{"PED_EMISS" ,,"Emissao"})	
		Aadd(aCpoBrw,{"PED_VALOR" ,,OemtoAnsi(STR0016),"99999999."+Replicate("9",TamSx3("DAK_VALOR")[2])})  //"Valor"
		Aadd(aCpoBrw,{"PED_VOLUM" ,,OemtoAnsi(STR0034),"99999999."+Replicate("9",TamSx3("DAK_CAPVOL")[2])}) //"Volume"
		//Aadd(aCpoBrw,{"PED_RESERV",,"Reserva"     ," "})
		Aadd(aCpoBrw,{"PED_RESERV",,"Reserva"     })
		Aadd(aCpoBrw,{"PED_USO",,"Usado"})
		Aadd(aCpoBrw,{"PED_TPENTR",,"Tipo Entrega"," "})
		/*+--------------------------------------------------------------------------+
		|Inclui campo de filial origem caso o tipo de operacao use todas as filiais|
		+--------------------------------------------------------------------------+*/
		If nTipoOper <> 1
			Aadd(aCpoBrw,{"PED_FILORI",,RetTitle("DAI_FILIAL")})
		EndIf
		//Aadd(aCpoBrw,{"PED_VOLUM" ,,OemtoAnsi(STR0034),PesqPict("SB1","B1_YM3")}) //"Volume"
		Aadd(aCpoBrw,{"PED_SEQLIB",,"Seq. Lib","  "})
		Aadd(aCpoBrw,{"PED_CARGA" ,,OemtoAnsi(STR0014)}) //"Carga"
		Aadd(aCpoBrw,{"PED_SEQROT",,"Entrega"})

		If ExistBlock("DL200BRW")
			aCpoBrw := Execblock("DL200BRW",.F.,.F.,aCpoBrw)
		EndIf
		/*+--------------------------------------------------------------------------+
		|Passo parametros para calculo da resolucao da tela                        |
		+--------------------------------------------------------------------------+*/
		aObjects := {}
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T. } )
		AAdd( aObjects, { 100, 150, .T., .T. } )
		AAdd( aObjects, { 100, 10 , .T., .F. } )
		aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
		aPosObj1 := MsObjSize( aInfo, aObjects, .T. )
		/*+--------------------------------------------------------------------------+
		|Resolve as dimensoes dos objetos da parte esquerda da tela                |
		+--------------------------------------------------------------------------+*/
		aObjects := {}
		AAdd( aObjects, { 100, 100, .T., .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T., .T. } )
		aSize2 := aClone( aPosObj1[1] )
		aInfo    := { aSize2[ 2 ], aSize2[ 1 ], aSize2[ 4 ], aSize2[ 3 ], 3, 3  }
		aPosObj2 := MsObjSize( aInfo, aObjects, ,.T. )
		/*+--------------------------------------------------------------------------+
		|Resolve as dimensoes dos objetos da parte direita da tela                 |
		+--------------------------------------------------------------------------+*/
		aObjects := {}
		AAdd( aObjects, { 100, 100, .T., .T., .T. } )
		AAdd( aObjects, { 100, 100, .T., .T., .T. } )
		aSize3 := aClone( aPosObj1[2] )
		aInfo    := { aSize3[ 2 ], aSize3[ 1 ], aSize3[ 4 ], aSize3[ 3 ], 3, 3 }
		aPosObj3 := MsObjSize( aInfo, aObjects, ,.T. )
		/*+--------------------------------------------------------------------------+
		|Montagem da Interface                                                     |
		+--------------------------------------------------------------------------+*/
		DEFINE MSDIALOG oDlg FROM aSize[7], 000 TO aSize[6], aSize[5] TITLE OemtoAnsi(STR0001) PIXEL //"Montagem de Carga"

		@ aPosObj2[1,1]+2,aPosObj2[1,2] Say OemtoAnsi(STR0074) Of oDlg PIXEL //"Cargas"
		@ aPosObj2[2,1]+2,aPosObj2[2,2] Say OemtoAnsi(STR0075) Of oDlg PIXEL //"Rotas"
		@ aPosObj3[1,1]+2,aPosObj3[1,2] Say OemtoAnsi(STR0076) Of oDlg PIXEL //"Zonas"
		@ aPosObj3[2,1]+2,aPosObj3[2,2] Say OemtoAnsi(STR0077) Of oDlg PIXEL //"Setores"
		@ aPosObj1[3,1]+2,aPosObj1[3,2] Say OemtoAnsi(STR0078) Of oDlg PIXEL //"Pedidos"

		/*+---------------------------------------------------------------------+
		| Monta Listbox de Cargas                                             |
		+---------------------------------------------------------------------+*/
		@ aPosObj2[1,1]+10,aPosObj2[1,2] LISTBOX oCargas VAR cVar ;
		Fields HEADER " ",;
		OemToAnsi(STR0013),; //"Codigo"
		OemtoAnsi(STR0014),; //"Carga"
		OemtoAnsi(STR0015),; //"Peso"
		OemtoAnsi(STR0016),; //"Valor"
		OemtoAnsi(STR0017),; //"Volume"
		OemtoAnsi(STR0018),; //"Ptos. Entrega"
		OemtoAnsi(STR0019),; //"Veiculo"
		OemtoAnsi(STR0069),; //"Motorista"
		OemtoAnsi(STR0092),; //"Ajudante 1"
		OemtoAnsi(STR0093),; //"Ajudante 2"
		OemtoAnsi(STR0094);  //"Ajudante 3"
		SIZE aPosObj2[1,3],aPosObj2[1,4]-10 ;
		ON DBLCLICK (u_OmsTroca(0,;
		cHrStart,;
		@aArrayCarga,;
		@aArrayRota,;
		@aArrayZona,;
		@aArraySetor,;
		@aArrayMan,;
		@aLock,;
		@oEnable,;
		@oDisable,;
		@oMarked,;
		@oNoMarked,;
		cMarca,;
		lAllMark)) OF oDlg PIXEL

		oCargas:nFreeze := 1
		oCargas:SetArray(aArrayCarga)
		oCargas:bLine:={ ||{Iif(aArrayCarga[oCargas:nAT,CARGA_ENABLE],oEnable,oDisable),;
		aArrayCarga[oCargas:nAT,CARGA_COD],;
		aArrayCarga[oCargas:nAT,CARGA_DESC],;
		aArrayCarga[oCargas:nAT,CARGA_PESO],;
		aArrayCarga[oCargas:nAT,CARGA_VALOR],;
		aArrayCarga[oCargas:nAT,CARGA_VOLUM],;
		aArrayCarga[oCargas:nAT,CARGA_PTOENT],;
		aArrayCarga[oCargas:nAT,CARGA_VEIC],;
		aArrayCarga[oCargas:nAT,CARGA_MOTOR],;
		aArrayCarga[oCargas:nAT,CARGA_AJUD1],;
		aArrayCarga[oCargas:nAT,CARGA_AJUD2],;
		aArrayCarga[oCargas:nAT,CARGA_AJUD3]}}

		oCargas:Refresh()

		/*+---------------------------------------------------------------------+
		| Monta Listbox de Rotas                                              |
		+---------------------------------------------------------------------+*/
		@ aPosObj2[2,1]+10,aPosObj2[2,2] LISTBOX oRotas VAR cVar ;
		Fields HEADER " ",;
		" ",;
		OemToAnsi(STR0013),; //"Codigo"
		OemToAnsi(STR0020),; //"Descricao"
		OemToAnsi(STR0014),; //"Carga"
		"Peso total da rota";
		SIZE aPosObj2[2,3],aPosObj2[2,4]-10 ;
		ON DBLCLICK (u_OmsTroca(1,;
		cHrStart,;
		@aArrayCarga,;
		@aArrayRota,;
		@aArrayZona,;
		@aArraySetor,;
		@aArrayMan,;
		@aLock,;
		@oEnable,;
		@oDisable,;
		@oMarked,;
		@oNoMarked,;
		cMarca,;
		.T.)) OF oDlg PIXEL

		oRotas:nFreeze := 2
		oRotas:SetArray(aArrayRota) // ZAGO
		oRotas:bLine:={ ||{Iif(aArrayRota[oRotas:nAT,1],oEnable,oDisable),;
		Iif(aArrayRota[oRotas:nAT,2],oMarked,oNoMarked),;
		aArrayRota[oRotas:nAT,3],;
		aArrayRota[oRotas:nAT,4],;
		aArrayRota[oRotas:nAt,5],;
		aArrayRota[oRotas:nAt,6]}}
		oRotas:cToolTip := OemToAnsi(STR0021) //"Duplo click para Habilitar/Desabilitar"
		oRotas:Refresh()
		/*+---------------------------------------------------------------------+
		| Monta Listbox de Zonas                                              |
		+---------------------------------------------------------------------+*/

		@ aPosObj3[1,1]+10,aPosObj3[1,2] LISTBOX oZonas VAR cVar ;
		Fields HEADER " ",;
		" ",;
		OemtoAnsi(STR0022),; //"Rota"
		OemtoAnsi(STR0023),; //"Zona"
		OemToAnsi(STR0024),; //"Descricao da zona"
		OemToAnsi(STR0014);  //"Carga"
		SIZE aPosObj3[1,3],aPosObj3[1,4]-10 ;
		ON DBLCLICK (u_OmsTroca(2,;
		cHrStart,;
		@aArrayCarga,;
		@aArrayRota,;
		@aArrayZona,;
		@aArraySetor,;
		@aArrayMan,;
		@aLock,;
		@oEnable,;
		@oDisable,;
		@oMarked,;
		@oNoMarked,;
		cMarca,;
		.T.)) OF oDlg PIXEL

		oZonas:nFreeze := 2
		oZonas:SetArray(aArrayZona)
		oZonas:bLine:={ ||{Iif(aArrayZona[oZonas:nAT,1],oEnable,oDisable),;
		Iif(aArrayZona[oZonas:nAT,2],oMarked,oNoMarked),;
		aArrayZona[oZonas:nAT,3],;
		aArrayZona[oZonas:nAT,4],;
		aArrayZona[oZonas:nAT,5],;
		aArrayZona[oZonas:nAT,6]}}
		oZonas:cToolTip := OemToAnsi(STR0021) //"Duplo click para Habilitar/Desabilitar"
		oZonas:Refresh()

		/*+---------------------------------------------------------------------+
		| Monta Listbox de Setor                                              |
		+---------------------------------------------------------------------+*/
		@ aPosObj3[2,1]+10,aPosObj3[2,2] LISTBOX oSetores VAR cVar ;
		Fields HEADER " ",;
		" ",;
		OemtoAnsi(STR0022),; //"Rota"
		OemtoAnsi(STR0023),; //"Zona"
		OemtoAnsi(STR0025),; //"Setor"
		OemToAnsi(STR0026),; //"Descricao do Setor"
		OemToAnsi(STR0014);  //"Carga"
		SIZE aPosObj3[2,3],aPosObj3[2,4]-10 ;
		ON DBLCLICK (u_OmsTroca(3,;
		cHrStart,;
		@aArrayCarga,;
		@aArrayRota,;
		@aArrayZona,;
		@aArraySetor,;
		@aArrayMan,;
		@aLock,;
		@oEnable,;
		@oDisable,;
		@oMarked,;
		@oNoMarked,;
		cMarca,;
		.T.)) OF oDlg PIXEL

		oSetores:nFreeze := 2
		oSetores:SetArray(aArraySetor)
		oSetores:bLine := {||{IIf(aArraySetor[oSetores:nAT,1],oEnable,oDisable),;
		Iif(aArraySetor[oSetores:nAT,2],oMarked,oNoMarked),;
		aArraySetor[oSetores:nAT,3],;
		aArraySetor[oSetores:nAT,4],;
		aArraySetor[oSetores:nAT,5],;
		aArraySetor[oSetores:nAT,6],;
		aArraySetor[oSetores:nAT,7]}}
		oSetores:cToolTip := OemToAnsi(STR0021) //"Duplo click para Habilitar/Desabilitar"
		oSetores:Refresh()

		/*+---------------------------------------------------------------------+
		| Monta Listbox de Pedidos                                            |
		+---------------------------------------------------------------------+*/
		dbSelectArea("TRBPED")
		dbGotop()
		//oMark :=MsSelect():New("TRBPED","PED_MARCA","(PED_GERA == 'S' .Or. PED_USO == 'S')",aCpoBrw,.F.,@cMarca,{aPosObj1[3,1]+10,aPosObj1[3,2],aPosObj1[3,3]-3,aPosObj1[3,4]})
		oMark :=MsSelect():New("TRBPED","PED_MARCA","PED_GERA == 'S'",aCpoBrw,.F.,@cMarca,{aPosObj1[3,1]+10,aPosObj1[3,2],aPosObj1[3,3]-3,aPosObj1[3,4]})
		oMark:bAval := {||u_OmsTroca(4,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,.F.)}
		oMark:oBrowse:lhasMark    := .T.
		oMark:oBrowse:lCanAllmark := .F.

		nPedidos := TRBPED->(LastRec())
		@ aPosObj1[3,3]+1,5   Say "Total de pedidos encontrados: "
		@ aPosObj1[3,3]+1,80  Get nPedidos Object oPedidos  When .F. Picture "@E 99999" Size 050,010
		@ aPosObj1[3,3]+1,150 Say "Tempo total de processamento: "
		@ aPosObj1[3,3]+1,230 Get cTempo   Object    oTempo When .F. Size 025,010

		xaArea := GetArea()
		aPedidos:= aSort(aPedidos)
		// Atualiza os pesos totais no grid de rotas
		fGetPesos(@aArrayRota, cPictPeso)

		Processa({|| fMarkPed(4,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,.F.)}, "Carregamento","Marcando itens com base no estoque.")

		RestArea(xaArea)
		DbSetOrder(15) // Nova ordem PED_VEND+PED_NOME+PED_CODCLI+PED_LOJA+PED_PEDIDO+PED_ITEM

		oCargas:Refresh()
		oRotas:Refresh()
		oZonas:Refresh()
		oSetores:Refresh()
		oMark:oBrowse:Refresh()
		cTempo := Alltrim(ElapTime(cHInicio, Time()))
		oTempo:Refresh()

		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || fOmsCarreg(@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,@aArrayCarga,@aArrayRota,@aArrayZona,@aArraySetor,@aArrayMan) }, {||nopca := 0,oDlg:End()},,aButtons)
		/*+---------------------------------------------------------------------+
		| Restaura a integridade da rotina                                    |
		+---------------------------------------------------------------------+*/
		MsUnLockAll()
		If ( __lSx8 )
			RollBackSx8()
		EndIf
		fLmpExit(cMarca, wcUsuario)
		DbSelectArea("TRBPED")
		DbCloseArea()
		//U_DelTrab(TRBPED)

		DbSelectArea("DAK")
		//QRYCART->(dbcloseArea())
		//QRYLIM->(dbcloseArea())
		//QRYSLDATU->(dbcloseArea())
		//TRBSALDOS->(dbcloseArea())
		//DbSelectArea("TRBSALDOS")
		//DbCloseArea()
		//U_DelTrab(TRBSALDOS)

		Ferase(cInd1+OrdBagExt())
		Ferase(cInd2+OrdBagExt())
	EndIf

	//+---------------------------------------------------------------------+
	//| Restaura a integridade da rotina                                    |
	//+---------------------------------------------------------------------+
	Eval(bFiltraBrw)
	RestArea(aArea)
Return .T.

/* +----------+----------+-------+-----------------------+------+------------+
|Função    |Os200VisCg| Autor |Henry Fila             | Data |02.03.2001  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Rotina de interface da visualizacao da carga                  |
+----------+--------------------------------------------------------------+
|Retorno   |Nenhum                                                        |
+----------+--------------------------------------------------------------+
|Parametros|ExpA1: Array da Carga                                         |
|          |ExpA2: Array dos Pedidos                                      |
|          |ExpC2: Hora de inicio da carga                                |
+----------+--------------------------------------------------------------+
|Uso       | Materiais/Distribuicao/Logistica                             |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+--------------+--------+------+------------------------------------------+
| Programador  | Data   | BOPS |  Motivo da Alteracao                     |
+--------------+--------+------+------------------------------------------+
|              |        |      |                                          |
+--------------+--------+------+------------------------------------------+*/
Static Function Os200VisCg(aArrayCarga,aArrayMan,cHrStart)
	local i
	Local aArrayAnt  := aClone(aArrayMan)
	Local aButtons   := {{ "DOWN"      , { || OmsTrocaSeq(@cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,1)}, OemtoAnsi(STR0127) },; //"Sequencia anterior"
	{ "UP"        , { || OmsTrocaSeq(@cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,2)}, OemtoAnsi(STR0128)},; //"Sequencia posterior"
	{ "DESTINOS2" , { || OmsTrocaSeq(@cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,3)}, OemtoAnsi(STR0129)},; //"Mover para..."
	{ "CLOCK02"   , { || OmsHrStart(@cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova)}, OemtoAnsi(STR0138)},;
	{ "DBG12"     , { || OmsVisRegra(aArrayAnt,oPedMan)  }, OemtoAnsi(STR0140) },;      //"Visualiza regra de entrega"
	{ "RELATORIO" , { || OmsVisLeg()             }, OemtoAnsi(STR0007) }} 				//"Hora Inicial"
	Local aObj       := {}
	Local aSize      := MsAdvSize( .T. )
	Local aPosObj1   := {}
	Local aObjects   := {}

	Local nSequencia := 0
	Local nOpcA      := 0
	Local nC         := 0
	Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
	Local cCarga     := ""
	Local cVar       := ""
	Local cSeqAtual  := ""
	Local cSeqNova   := ""

	Local lSeq       := .F.

	Local oDlgman
	Local oPedMan
	Local oSayNewSeq
	Local oNewSeq
	Local oSaySeqAtu
	Local oSeqAtual
	Local oMenu
	Local oLiberado   := LoadBitmap( GetResources(), "PMSTASK4" )
	Local oCalend     := LoadBitmap( GetResources(), "PMSTASK1" )
	Local oHorario    := LoadBitmap( GetResources(), "PMSTASK2" )
	Local oVeiculo    := LoadBitmap( GetResources(), "PMSTASK3" )
	Local oSayCli
	Local oSayEnd
	Local oSayChP
	Local oSayTmSrv
	Local oSaySdP
	Local oSayBai
	Local oSayEst
	Local oSayMun
	Local oSayCep

	/*+--------------------------------------------------------------------------+
	| Verifica os pedidos marcados                                             |
	+--------------------------------------------------------------------------+*/
	If !Len( aArrayAnt ) == 0 .And. nPosCarga > 0
		/*+--------------------------------------------------------------------------+
		| Obtem o numero da carga                                                  |
		+--------------------------------------------------------------------------+*/
		cCarga := aArrayCarga[nPosCarga,CARGA_COD]
		/*+----------------------+
		|Dimensoes da matriz   |
		|[1]Ativo              |
		|[2]Marcado            |
		|[3]Rota               |
		|[4]Zona               |
		|[5]Setor              |
		|[6]Sequencia na Rota  |
		|[7]Pedido             |
		|[8]Item               |
		|[9]Cliente            |
		|[10Loja               |
		|[11]Nome              |
		|[12]Peso              |
		|[13]Carga             |
		|[14]Sequencia no Setor|
		|[15]Sequencia final   |
		+----------------------+*/

		/*+--------------------------------------------------------------------------+
		| Renumera a sequencia de entrega considerando intervalo de 5              |
		+--------------------------------------------------------------------------+*/
		For nC := 1 to Len(aArrayAnt)
			nSequencia+=5
			aArrayAnt[nC,1] := StrZero(nSequencia,6)
		Next nC
		/*+--------------------------------------------------------------------------+
		| Montagem da Interface                                                    |
		+--------------------------------------------------------------------------+*/

		aObjects := {}
		aAdd( aObjects, { 100, 100 , .t., .t.,.t. } )
		aAdd( aObjects, { 100, 50 , .t., .f. } )

		aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
		aPosObj1 := MsObjSize( aInfo, aObjects)

		DEFINE MSDIALOG oDlgMan FROM aSize[7], 000 TO aSize[6],aSize[5] TITLE OemtoAnsi(STR0035+cCarga) OF oMainWnd PIXEL //"Sequencia da Carga "

		@ 013,233 to 075,317 of oDlgMan Pixel

		@ 017,(aSize[5]/2)-75 Say oSaySeqAtu Prompt OemToAnsi(STR0045) Size 50,10  Of oDlgMan Pixel //"Seq. Atual" //235
		@ 030,(aSize[5]/2)-75 MSGet oSeqAtual VAR cSeqAtual Picture "999999"  When .F. Size 30,10 Of oDlgMan Pixel //285

		@ 052,(aSize[5]/2)-75 Say oSayNewSeq Prompt OemToAnsi(STR0046) Size 50,10  Of oDlgMan Pixel //"Nova Seq."
		@ 065,(aSize[5]/2)-75  MSGet oNewSeq VAR cSeqNova Picture "999999"  Valid OmsVldSeq(cSeqNova,aArrayAnt[oPedMan:nAt,2]) When .T. Size 30,10 Of oDlgMan Pixel

		DEFINE SBUTTON oButton1 FROM 90,(aSize[5]/2)-75 TYPE 1 ACTION OmsTrocaSeq(cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,5) ENABLE OF oDlgMan
		DEFINE SBUTTON oButton2 FROM 90,(aSize[5]/2)-45 TYPE 2 ACTION OmsTrocaSeq(cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,@lSeq,@cSeqAtual,@cSeqNova,4) ENABLE OF oDlgMan

		aAdd(aObj,oSaySeqAtu)
		aAdd(aObj,oSeqAtual)
		aAdd(aObj,oSayNewSeq)
		aAdd(aObj,oNewSeq)
		aAdd(aObj,oButton1)
		aAdd(aObj,oButton2)
		aEval(aObj,{|x| x:hide()})
		/*+--------------------------------------------------------+
		|ListBox dos pedido                                      |
		+--------------------------------------------------------+*/
		@ aPosObj1[1,1],aPosObj1[1,2] LISTBOX oPedMan VAR cVar Fields HEADER OemtoAnsi(" "),;
		OemtoAnsi(STR0036),; //"Sequencia"
		OemtoAnsi(STR0022),; //"Rota"
		OemtoAnsi(STR0028),; //"Pedido"
		OemtoAnsi(STR0133),; //"Chegada Prevista"
		OemtoAnsi(STR0134),; //"Time Service"
		OemtoAnsi(STR0030),; //"Cliente"
		OemtoAnsi(STR0031),; //"Loja"
		OemToAnsi(STR0032),; // "Nome"
		OemToAnsi(STR0108),; //'Bairro'
		OemToAnsi(STR0109),; //'Cidade'
		OemToAnsi(STR0110), ; //'UF'
		OemToAnsi("Transportadora"); // Transportadora (redespacho)
		SIZE aPosObj1[1,3],aPosObj1[1,4] OF oDlgMan PIXEL
		SA1->(dbSetOrder(1))
		For i:= 1 to Len(aArrayAnt)
			If SA1->(MsSeek(xFilial("SA1")+aArrayAnt[i,6]+aArrayAnt[i,7]))
				If !Empty(SA1->A1_ENDENT)
					aArrayAnt[i,9]  := SA1->A1_BAIRROE
					aArrayAnt[i,10] := SA1->A1_MUNE
					aArrayAnt[i,11] := SA1->A1_ESTE
				EndIf
			EndIf
		Next i
		oPedMan:SetArray(aArrayAnt)
		oPedMan:bLine:={ ||{Iif(aArrayAnt[oPedMan:nAT,18]==1,oLiberado,;
		Iif(aArrayAnt[oPedMan:nAT,18]==2,oVeiculo,;
		Iif(aArrayAnt[oPedMan:nAT,18]==3,oHorario,;
		Iif(aArrayAnt[oPedMan:nAT,18]==4,oCalend,oLiberado)))),;
		aArrayAnt[oPedMan:nAT,1],;
		aArrayAnt[oPedMan:nAT,2],;
		aArrayAnt[oPedMan:nAT,5],;
		aArrayAnt[oPedMan:nAT,16],;
		aArrayAnt[oPedMan:nAT,17],;
		aArrayAnt[oPedMan:nAT,6],;
		aArrayAnt[oPedMan:nAT,7],;
		aArrayAnt[oPedMan:nAT,8],;
		aArrayAnt[oPedMan:nAT,9],;  // BAIRRO
		aArrayAnt[oPedMan:nAT,10],; // CIDADE
		aArrayAnt[oPedMan:nAT,11],; // UF
		fGetRedesp(aArrayAnt[oPedMan:nAT,5])}} // Passa o pedido como parametro
		oPedMan:bChange  := {|| Oms200Msg(aArrayAnt,oPedMan,oSayCli,oSayEnd,oSayBai,oSayMun,oSayEst,oSayCep,oSayChP,oSayTmSrv,oSaySdP) }
		oPedMan:Refresh()

		/*+--------------------------------------------------------+
		|Rodape da janela                                        |
		+--------------------------------------------------------+*/
		@ aPosObj1[2,1]+2, aPosObj1[2,2] TO  aPosObj1[2,3], aPosObj1[2,4] LABEL  OemToAnsi(STR0137)   OF oDlgMan PIXEL   //"Dados da Entrega:"

		@ aPosObj1[2,1]+10,05 Say OemtoAnsi(STR0030)+":" SIZE 040,08 Of oDlgMan PIXEL   //"Cliente: "
		@ aPosObj1[2,1]+10,30 Say oSayCli Prompt "" SIZE 300,08 Of oDlgMan PIXEL

		@ aPosObj1[2,1]+20,05 Say OemtoAnsi(STR0114)+":" SIZE 060,08 Of oDlgMan PIXEL   //"Endereco:"
		@ aPosObj1[2,1]+20,30 Say oSayEnd Prompt "" SIZE 300,08 Of oDlgMan PIXEL

		@ aPosObj1[2,1]+20,170 Say OemtoAnsi(STR0108)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Bairro"
		@ aPosObj1[2,1]+20,210 Say oSayBai Prompt "" SIZE 300,08 Of oDlgMan PIXEL

		@ aPosObj1[2,1]+30,05  Say OemtoAnsi(STR0109)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Cidade"
		@ aPosObj1[2,1]+30,30  Say oSayMun Prompt ""      SIZE 300,08 Of oDlgMan PIXEL

		@ aPosObj1[2,1]+30,90  Say OemtoAnsi(STR0110)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Estado"
		@ aPosObj1[2,1]+30,120 Say oSayEst Prompt ""      SIZE 040,08 Of oDlgMan PIXEL

		@ aPosObj1[2,1]+30,170 Say OemtoAnsi(STR0136)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Cep"
		@ aPosObj1[2,1]+30,210 Say oSayCep Prompt ""      SIZE 040,08 Of oDlgMan PIXEL

		@ aPosObj1[2,1]+40,05  Say OemtoAnsi(STR0133)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Chegada Prevista"
		@ aPosObj1[2,1]+40,50  Say oSayChP Prompt ""      SIZE 040,08 Of oDlgMan PIXEL

		@ aPosObj1[2,1]+40,90  Say OemtoAnsi(STR0134)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Time Service:"
		@ aPosObj1[2,1]+40,125 Say oSayTmSrv Prompt ""    SIZE 040,08 Of oDlgMan PIXEL

		@ aPosObj1[2,1]+40,170 Say OemtoAnsi(STR0135)+":" SIZE 060,08 Of oDlgMan PIXEL  //"Saida Prevista"
		@ aPosObj1[2,1]+40,210 Say oSaySdP Prompt ""      SIZE 040,08 Of oDlgMan PIXEL


		ACTIVATE MSDIALOG  oDlgMan ON INIT EnchoiceBar( oDlgMan, { || nOpca := 1,oDlgMan:End()}, {||oDlgMan:End()},,aButtons)

		/*+--------------------------------------------------------------------------+
		| Atualizo o Array principal                                               |
		+--------------------------------------------------------------------------+*/
		If nOpca == 1
			aArrayMan := aClone(aArrayAnt)
		EndIf
	Else
		Help(" ",1,"OMSPEDMARK") //Nao existem pedidos marcados
	EndIf
Return(.T.)

/* +----------+-----------+-------+----------------------+------+------------+
|Fun‡…o    |OmsVisRegra| Autor |Henry Fila            | Data |22.07.2002  |
+----------+-----------+-------+----------------------+------+------------+
|Descri‡…o |Rotina de visualizacao das regras de entrega do cliente       |
+----------+--------------------------------------------------------------+
|Retorno   |Nenhum                                                        |
+----------+--------------------------------------------------------------+
|Parametros|ExpA1: Array com os dados dos clientes                        |
+----------+--------------------------------------------------------------+
|Uso       | Materiais/Distribuicao/Logistica                             |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+--------------+--------+------+------------------------------------------+
| Programador  | Data   | BOPS |  Motivo da Alteracao                     |
+--------------+--------+------+------------------------------------------+
|              |        |      |                                          |
+--------------+--------+------+------------------------------------------+*/
Static Function OmsVisRegra(aArrayAnt,oPedMan)
	Local aArea    := GetArea()
	Local aAreaSA1 := SA1->(GetArea())
	Local lIncluiBk:= INCLUI

	INCLUI := .F.

	/*+--------------------------------------------------------------------+
	|Verifica se existe janela de entrega para o cliente ou grupo        |
	+--------------------------------------------------------------------+*/

	SA1->(dbSetOrder(1))
	//If SA1->(MsSeek(OsFilial("SA1",aArrayAnt[oPedMan:nAt][12])+aArrayAnt[oPedMan:nAt][6]+aArrayAnt[oPedMan:nAt][7] ))
	If SA1->(MsSeek(xFilial("SA1")))
		DAD->(dbSetOrder(2))
		If DAD->(MsSeek(xFilial("DAD")+Space(Len(SA1->A1_GRPVEN))+aArrayAnt[oPedMan:nAt][6]+aArrayAnt[oPedMan:nAt][7]))
			Oms120Mnt("DAD", DAD->(Recno()), 2)
		Else
			If DAD->(MsSeek(xFilial("DAD")+SA1->A1_GRPVEN+Space(Len(SA1->A1_COD))+Space(Len(SA1->A1_LOJA))))
				Oms120Mnt("DAD", DAD->(Recno()), 2)
			Else
				Help(" ",1,"OMS200REGR")
			Endif
		Endif
	Endif

	INCLUI := lIncluiBk

	RestArea(aAreaSA1)
	RestArea(aArea)
Return


/*+----------+----------+-------+-----------------------+------+----------+
|Program   | OmsVisLeg| Autor | Henry Fila            | Data |23/01/2001|
+----------+----------+-------+-----------------------+------+----------+
|Descri‡Æo | Exibe a legenda dos status do pedido                       |
+----------+------------------------------------------------------------+
|Retorno   | Nil                                                        |
+----------+------------------------------------------------------------+
|Parametros| Nenhum                                                     |
+----------+---------------+--------------------------------------------+
|   DATA   | Programador   |Manutencao efetuada                         |
+----------+---------------+--------------------------------------------+
|          |               |                                            |
+----------+---------------+--------------------------------------------+*/
Static Function OmsVisLeg()
	Local aLegenda := {{ "PMSTASK4", OemToAnsi(STR0142)},; //"Entrega permitida"
	{ "PMSTASK1", OemToAnsi(STR0143)},; //"Restricao por calendario"
	{ "PMSTASK2", OemToAnsi(STR0144)},; //"Restricao por horario"
	{ "PMSTASK3", OemToAnsi(STR0145)}}  //"Restricao por veiculo"
	BrwLegenda( cCadastro, OemToAnsi( STR0146 ), aLegenda) //"Status"
Return( Nil )


/*+----------+----------+-------+-----------------------+------+------------+
|Fun‡…o    |OmsHrStart| Autor |Henry Fila             | Data |02.03.2001  |
+----------+----------+-------+-----------------------+------+------------+
|Descri‡…o |Rotina alteracao da hora de inicio da entrega                 |
+----------+--------------------------------------------------------------+
|Retorno   |Nenhum                                                        |
+----------+--------------------------------------------------------------+
|Parametros|ExpA1: Array da Carga                                         |
|          |ExpA2: Array dos Pedidos                                      |
|          |                                                              |
+----------+--------------------------------------------------------------+
|Uso       | Materiais/Distribuicao/Logistica                             |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+--------------+--------+------+------------------------------------------+
| Programador  | Data   | BOPS |  Motivo da Alteracao                     |
+--------------+--------+------+------------------------------------------+
|              |        |      |                                          |
+--------------+--------+------+------------------------------------------+*/
User Function OmsHrStart(cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,lSeq,cSeqAtual,cSeqNova)
	Local nOpca    := 0
	Local cNewHr   := cHrStart

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0139) From 0,0 To 100,235 OF oMainWnd PIXEL //"Hora Inicial da Entrega"

	@ 005,005 Say OemtoAnsi(STR0138) Of oDlg PIXEL SIZE 45,10 //"Hora"
	@ 005,078 MSGET cNewHr  Of oDlg Valid OmsVldHr(cNewHr) PIXEL SIZE 34,10 Picture "99:99"
	DEFINE SBUTTON FROM 035, 055 TYPE 1 ENABLE OF oDlg ACTION( nOpcA := 1,oDlg:End())
	DEFINE SBUTTON FROM 035, 085 TYPE 2 ENABLE OF oDlg ACTION( oDlg:End())

	ACTIVATE DIALOG oDlg Centered

	If nOpca ==1
		cHrStart := cNewHr
		OmsTrocaSeq(cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,.T.,cSeqAtual,cSeqNova,6)
	Endif
Return


/*+----------+----------+-------+-----------------------+------+------------+
|Fun‡…o    |OmsVldHr  | Autor |Henry Fila             | Data |02.03.2001  |
+----------+----------+-------+-----------------------+------+------------+
|Descri‡…o |Validacao da hora inicial digitada                            |
+----------+--------------------------------------------------------------+
|Retorno   |.T. ou .F.                                                    |
+----------+--------------------------------------------------------------+
|Parametros|ExpC1: Hora                                                   |
+----------+--------------------------------------------------------------+
|Uso       | Materiais/Distribuicao/Logistica                             |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+--------------+--------+------+------------------------------------------+
| Programador  | Data   | BOPS |  Motivo da Alteracao                     |
+--------------+--------+------+------------------------------------------+
|              |        |      |                                          |
+--------------+--------+------+------------------------------------------+*/
Static Function OmsVldHr(cNewHr)
	Local lRet := .T.
	Do Case
		Case Val(SubStr(cNewHr,1,2)) > 23
		Help(" ",1,"OMS200HORA") //Horario invalido
		lRet := .F.
		Case Val(SubStr(cNewHr,3,2)) > 60
		Help(" ",1,"OMS200MIN") //Horario invalido
		lRet := .F.
	EndCase
Return(lRet)


/*+----------+----------+-------+-----------------------+------+------------+
|Fun‡…o    |Oms200Msg | Autor |Henry Fila             | Data |02.03.2001  |
+----------+----------+-------+-----------------------+------+------------+
|Descri‡…o |Rotina de mensagem do rodape da sequencia de carga            |
+----------+--------------------------------------------------------------+
|Retorno   |Nenhum                                                        |
+----------+--------------------------------------------------------------+
|Parametros|ExpA1: Array da Carga                                         |
|          |ExpO2: Objeto do ListBox                                      |
|          |ExpO3: Objeto do Cliente                                      |
|          |ExpO4: Objeto do Endereco                                     |
|          |ExpO5: Objeto da chegada prevista                             |
|          |ExpO6: Objeto dO TIME SERVICE                                 |
|          |ExpO7: Objeto da SAIDA PREVISTA                               |
+----------+--------------------------------------------------------------+
|Uso       | Materiais/Distribuicao/Logistica                             |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+--------------+--------+------+------------------------------------------+
| Programador  | Data   | BOPS |  Motivo da Alteracao                     |
+--------------+--------+------+------------------------------------------+
|              |        |      |                                          |
+--------------+--------+------+------------------------------------------+*/
Static Function Oms200Msg(aArrayAnt,oPedMan,oSayCli,oSayEnd,oSayBai,oSayMun,oSayEst,oSayCep,oSayChP,oSayTmSrv,oSaySdP)
	Local aArea    := GetArea()
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaSA4 := SA4->(GetArea()) //ALTERADO POR PANETTO
	SA1->(dbSetOrder(1))
	//If SA1->(MsSeek(OsFilial("SA1",aArrayAnt[oPedMan:nAt][12])+aArrayAnt[oPedMan:nAt][6]+aArrayAnt[oPedMan:nAt][7]))
	If SA1->(MsSeek(xFilial("SA1")+aArrayAnt[oPedMan:nAt][6]+aArrayAnt[oPedMan:nAt][7]))
		oSayCli:SetText(aArrayAnt[oPedMan:nAt][6]+"-"+aArrayAnt[oPedMan:nAt][7]+"   "+SA1->A1_NOME)
		If !Empty(SA1->A1_ENDENT)
			oSayEnd:SetText(Alltrim(SA1->A1_ENDENT))
			oSayBai:SetText(SA1->A1_BAIRROE)
			oSayMun:SetText(SA1->A1_MUNE)
			oSayEst:SetText(SA1->A1_ESTE)
			oSayCep:SetText(SA1->A1_CEPE)
		Else
			oSayEnd:SetText(Alltrim(SA1->A1_END))
			oSayBai:SetText(SA1->A1_BAIRRO)
			oSayMun:SetText(SA1->A1_MUN)
			oSayEst:SetText(SA1->A1_EST)
			oSayCep:SetText(SA1->A1_CEP)
		EndIf
		oSayChP:SetText(aArrayAnt[oPedMan:nAt][16])
		oSayTmSrv:SetText(aArrayAnt[oPedMan:nAt][17])
		oSaySdP:SetText(IntToHora(HoraToInt(aArrayAnt[oPedMan:nAt][16],2)+HoraToInt(aArrayAnt[oPedMan:nAt][17],4),2))
	Endif
	RestArea(aAreaSA1)
	RestArea(aArea)
Return

/*+----------+----------+-------+-----------------------+------+------------+
|Fun‡…o    |Os200VisCf| Autor |Henry Fila             | Data |17.01.2001  |
+----------+----------+-------+-----------------------+------+------------+
|Descri‡…o |Rotina de interface da visualizacao de cliente/fornecedor     |
+----------+--------------------------------------------------------------+
|Retorno   |Nenhum                                                        |
+----------+--------------------------------------------------------------+
|Parametros|Nenhum                                                        |
|          |                                                              |
+----------+--------------------------------------------------------------+
|Uso       | Materiais/Distribuicao/Logistica                             |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+--------------+--------+------+------------------------------------------+
| Programador  | Data   | BOPS |  Motivo da Alteracao                     |
+--------------+--------+------+------------------------------------------+
|              |        |      |                                          |
+--------------+--------+------+------------------------------------------+*/
User Function Os200VisCF()
	Local aArea     := GetArea()
	Local aAreaSC5  := SC5->(GetArea())
	Local aAreaSA1  := SA1->(GetArea())
	Local aAreaSA2  := SA2->(GetArea())
	Local cAliasArq := ""
	Local cSavFil   := cFilAnt
	/*+--------------------------------------------------------------------------+
	| Verifica a filial correta do Pedido de Venda                             |
	+--------------------------------------------------------------------------+*/
	If OsVlEntCom() <> 1
		cFilAnt := TRBPED->PED_FILORI
	EndIf
	/*+--------------------------------------------------------------------------+
	| Verifica-se se o pedido eh para um cliente ou Fornecedor                 |
	+--------------------------------------------------------------------------+*/
	DbSelectArea("SC5")
	DbSetOrder(1)
	//If MsSeek(OsFilial("SC5",TRBPED->PED_FILORI)+TRBPED->PED_PEDIDO)
	If MsSeek(xFilial("SC5")+TRBPED->PED_PEDIDO)
		If SC5->C5_TIPO == "B".Or. SC5->C5_TIPO == "D"
			cAliasArq := "SA2"
		Else
			cAliasArq := "SA1"
		EndIf
	EndIf
	/*+--------------------------------------------------------------------------+
	| Montagem da Interface                                                    |
	+--------------------------------------------------------------------------+*/

	If !Empty(cAliasArq)
		DbSelectArea(cAliasArq)
		DbSetOrder(1)
		//If MsSeek(OsFilial(cAliasArq,TRBPED->PED_FILORI)+TRBPED->PED_CODCLI+TRBPED->PED_LOJA)
		If MsSeek(xFilial(cAliasArq)+TRBPED->PED_CODCLI+TRBPED->PED_LOJA)
			AxVisual(cAliasArq,Recno(),2)
		EndIf
	Endif
	/*+--------------------------------------------------------------------------+
	| Restaura a integridade da rotina                                         |
	+--------------------------------------------------------------------------+*/
	cFilAnt := cSavFil
	RestArea(aAreaSC5)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)
	RestArea(aArea)
Return(.T.)


/*+----------+----------+-------+-----------------------+------+------------+
|Fun‡…o    |Os200VisPv| Autor |Henry Fila             | Data |17.01.2001  |
+----------+----------+-------+-----------------------+------+------------+
|Descri‡…o |Rotina de interface da visualizacao do Pedido de Venda        |
+----------+--------------------------------------------------------------+
|Retorno   |Nenhum                                                        |
+----------+--------------------------------------------------------------+
|Parametros|Nenhum                                                        |
|          |                                                              |
+----------+--------------------------------------------------------------+
|Uso       | Materiais/Distribuicao/Logistica                             |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+--------------+--------+------+------------------------------------------+
| Programador  | Data   | BOPS |  Motivo da Alteracao                     |
+--------------+--------+------+------------------------------------------+
|              |        |      |                                          |
+--------------+--------+------+------------------------------------------+*/
Static Function Os200VisPv()
	Local aArea     := GetArea()
	Local cSavFil   := cFilAnt
	/*+--------------------------------------------------------------------------+
	| Verifica a filial correta do Pedido de Venda                             |
	+--------------------------------------------------------------------------+*/
	If OsVlEntCom() <> 1
		cFilAnt := TRBPED->PED_FILORI
	EndIf
	/*+--------------------------------------------------------------------------+
	| Montagem da interface                                                    |
	+--------------------------------------------------------------------------+*/
	DbSelectArea("SC5")
	DbSetOrder(1)
	//If MsSeek(OsFilial("SC5",TRBPED->PED_FILORI)+TRBPED->PED_PEDIDO)
	If MsSeek(xFilial("SC5")+TRBPED->PED_PEDIDO)
		A410Visual("SC5",Recno(),2)
	EndIf
	/*+--------------------------------------------------------------------------+
	| Restaura a integridade da rotina                                         |
	+--------------------------------------------------------------------------+*/
	cFilAnt := cSavFil
	RestArea(aArea)
Return(.T.)

/*+----------+----------+-------+--------------------+------+-------------+
|Programa  |OmsTroca  |Autor  |Henry Fila          | Data |  12/26/00   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Marca e valida as amarracoes da geracao de carga           |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros| nEscolha - Analisa o listbox escolhido   a                 |
|          | aArrayCarga - aArray de cargas passado por referencia      |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+*/

User Function OmsTroca(nEscolha,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,oEnable,oDisable,oMarked,oNoMarked,cMarca,lAllMark)
	local nc2,nc
	Local lTroca      := .F.
	Local nPosMan     := 0
	Local nPosCarga

	Local cCarga      := ""
	Local cBusca      := ""
	Local cPictVal    := "99999999." + Replicate("9",TamSx3("DAK_VALOR") [2])
	Local cPictVol    := "99999999." + Replicate("9",TamSx3("DAK_CAPVOL")[2])
	//Local cPictVol    := PesqPict("SB1","B1_YM3")
	Local cPictPeso   := "99999999." + Replicate("9",TamSx3("DAK_PESO")  [2])

	Local aArrayPto   := {}
	Local nPtoEntr    := 0
	Local nRecnoTRB   := TRBPED->(Recno())
	Local nPesoItem   := 0
	Local nVolItem    := 0
	Local nValorItem  := 0
	Local lSomaCarga  := .T.
	Local lAbatCarga  := .T.
	Local lDelMan     := .F.
	Local cPedido     := ''
	Private wcUsuario := StrTran(Upper(Alltrim(cUsername))," ","")

	/*+------------------------------------------+
	|Verifico se existe carga disponivel aberta|
	+------------------------------------------+*/

	nPosCarga := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
	If nPosCarga == 0
		Help(" ",1,"DLACGDISP") //Nao existe carga disponivel aberta
		Return
	Else
		cCarga := aArrayCarga[nPosCarga,CARGA_COD]
	EndIf

	/*+----------------------------------------------+
	|Escolha da rota                               |
	+----------------------------------------------+*/

	Do Case

		Case nEscolha == 1
		/*+---------------------------------------------------------------+
		|Verifico o flag se esta habliitado ou se esta como rota inativa|
		|para deixar marcar para geracao                                |
		+---------------------------------------------------------------+*/
		aArrayRota[oRotas:nAt,2] := Iif((!aArrayRota[oRotas:nAt,2] ) .And. ;
		(aArrayRota[oRotas:nAt,1]),;
		.T., .F.)
		/*+----------------------------------------------+
		|Procura pelas zonas                           |
		+----------------------------------------------+*/

		// Codigo da rota
		wcRota := aArrayRota[oRotas:nAt,3]

		For nC := 1 to Len(aArrayZona)

			/*+------------------------------------------+
			|Verifica flag da zona no browse           |
			+------------------------------------------+*/

			If (aArrayZona[nC,3] == aArrayRota[oRotas:nAt,3] ) .And. (aArrayZona[nC,1])

				aArrayZona[nC,2] := aArrayRota[oRotas:nAt,2]

				/*+---------------------------------------+
				|Procura por setores da zona            |
				+---------------------------------------+*/

				For nC2 := 1 To Len( aArraySetor )
					If (aArraySetor[nC2,3]+aArraySetor[nC2,4] == aArrayZona[nC,3]+aArrayZona[nC,4] ) .And. (aArraySetor[nC2,1] )

						aArraySetor[nC2,2] := aArrayRota[oRotas:nAt,2]
						/*+-------------------------------------------+
						|Procura por pedidos do setor               |
						+-------------------------------------------+*/
						dbSelectArea("TRBPED")
						dbSetOrder(4)
						MsSeek(aArraySetor[nC2,3]+aArraySetor[nC2,4]+aArraySetor[nC2,5])
						While !Eof() .And. TRBPED->PED_ROTA+TRBPED->PED_ZONA+TRBPED->PED_SETOR == ;
						aArraySetor[nC2,3]+aArraySetor[nC2,4]+aArraySetor[nC2,5]
							/*+-----------------------+
							|Verifico Flag do pedido|
							+-----------------------+*/
							//If (TRBPED->PED_GERA == "N" .And. TRBPED->PED_ESTOQ == "S") .And. Oms200Lock(TRBPED->PED_FILORI,TRBPED->PED_PEDIDO, aLock, aArrayRota[oRotas:nAt,2],cMarca)
							If (TRBPED->PED_GERA == "N") .And. Oms200Lock(TRBPED->PED_FILORI,TRBPED->PED_PEDIDO, aLock, aArrayRota[oRotas:nAt,2],cMarca)
								lSomaCarga := Iif(TRBPED->PED_MARCA == cMarca,.F.,.T.)
								lAbatCarga := Iif(TRBPED->PED_MARCA != cMarca,.F.,.T.)

								/*+--------------------------------------------------+
								|Verifico se a rota foi marcada e atualizo o pedido|
								+--------------------------------------------------+*/
								RecLock("TRBPED",.F.)
								TRBPED->PED_MARCA  := Iif( aArrayRota[oRotas:nAt,2], cMarca,"  ")
								TRBPED->PED_CARGA  := Iif(TRBPED->PED_MARCA == cMarca ,cCarga,"ZZZZZZ")
								TRBPED->(MsUnlock())
								//fMarca()

								/*+-----------------------------------------------------------+
								|Verifico se existe no array de sequencia e incluo ou excluo|
								|caso a opcao escolhida pelo usuario                        |
								+-----------------------------------------------------------+*/

								cBusca  := TRBPED->PED_PEDIDO+TRBPED->PED_CODCLI+TRBPED->PED_LOJA+TRBPED->PED_FILORI
								nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == cBusca })

								/*+----------------------------------------+
								|Incluo no array de manutencao os dados :|
								|-Sequencia                              |
								|-Rota                                   |
								|-Zona                                   |
								|-Setor                                  |
								|-Pedido                                 |
								|-Cliente                                |
								|-Loja                                   |
								+----------------------------------------+*/

								/*+-----------------------------------------------------------+
								|Verifico se o pedido foi marcado para inclusao no array de |
								|sequencia                                                  |
								+-----------------------------------------------------------+*/

								If (TRBPED->PED_MARCA == cMarca )

									If nPosMan == 0
										Aadd(aArrayMan,{TRBPED->PED_SEQROT,;
										TRBPED->PED_ROTA,;
										TRBPED->PED_ZONA,;
										TRBPED->PED_SETOR,;
										TRBPED->PED_PEDIDO,;
										TRBPED->PED_CODCLI,;
										TRBPED->PED_LOJA,;
										TRBPED->PED_NOME,;
										TRBPED->PED_BAIRRO,;
										TRBPED->PED_MUN,;
										TRBPED->PED_EST,;
										TRBPED->PED_FILORI,;
										TRBPED->PED_FILCLI,;
										TRBPED->PED_PESO,;
										TRBPED->PED_VOLUM,,,,,})
									Else
										aArrayMan[nPosMan][14] += TRBPED->PED_PESO
										aArrayMan[nPosMan][15] += TRBPED->PED_VOLUM
									EndIf

									/*+-----------------------------------------------------+
									|Atualizo no array de carga os dados de volume, peso, |
									|valor e ptos de entrega                              |
									+-----------------------------------------------------+*/

									If lSomaCarga
										aArrayCarga[nPosCarga,CARGA_PESO]  := Transform(Val(aArrayCarga[nPosCarga,CARGA_PESO])  + TRBPED->PED_PESO,cPictPeso)
										aArrayCarga[nPosCarga,CARGA_VALOR] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VALOR]) + TRBPED->PED_VALOR,cPictVal)
										aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VOLUM]) + TRBPED->PED_VOLUM,cPictVol)
									EndIf

								ElseIf(TRBPED->PED_MARCA != cMarca)
									If nPosMan > 0
										aDel(aArrayMan,nPosMan)
										aSize(aArrayMan,Len(aArrayMan)-1)
									EndIf

									/*+-----------------------------------------------------+
									|Atualizo no array de carga os dados de volume, peso, |
									|valor e ptos de entrega                              |
									+-----------------------------------------------------+*/

									If lAbatCarga
										aArrayCarga[nPosCarga,CARGA_PESO]  := Transform(Val(aArrayCarga[nPosCarga,CARGA_PESO]) - TRBPED->PED_PESO,cPictPeso)
										aArrayCarga[nPosCarga,CARGA_VALOR] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VALOR]) - TRBPED->PED_VALOR,cPictVal)
										aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VOLUM]) - TRBPED->PED_VOLUM,cPictVol)
									EndIf

								EndIf

							EndIf

							dbSelectArea("TRBPED")
							dbSkip()
						EndDo

					EndIf
				Next nC2

			EndIf

		Next

		Case nEscolha == 2

		/*+---------------------------------------------------------------+
		|Verifico o flag se esta habliitado ou se esta como rota inativa|
		|para deixar marcar para geracao                                |
		+---------------------------------------------------------------+*/

		aArrayZona[oZonas:nAt,2] := Iif(( !aArrayZona[oZonas:nAt,2]) .And. ;
		( aArrayZona[oZonas:nAt,1]),;
		.T., .F.)

		/*+---------------------------------+
		|Varro setores da zona selecionada|
		+---------------------------------+*/

		For nC := 1 to Len(aArraySetor)

			/*+----------------------------------+
			|Verifico flag do setor para marcar|
			+----------------------------------+*/

			If (aArraySetor[nC,3]+aArraySetor[nC,4] == aArrayZona[oZonas:nAt,3]+aArrayZona[oZonas:nAt,4] ) .And. ;
			( ( aArraySetor[nC,1] ) )

				aArraySetor[nC,2] := aArrayZona[oZonas:nAt,2]

				/*+----------------------+
				|Varro pedidos do setor|
				+----------------------+*/
				DbSelectArea("TRBPED")
				DbSetOrder(4)
				MsSeek(aArraySetor[nC,3]+aArraySetor[nC,4]+aArraySetor[nC,5])

				While !Eof() .And. TRBPED->PED_ROTA+TRBPED->PED_ZONA+TRBPED->PED_SETOR == ;
				aArraySetor[nC,3]+aArraySetor[nC,4]+aArraySetor[nC,5]

					If ( TRBPED->PED_GERA == "N" .And. TRBPED->PED_ESTOQ == "S") .And. Oms200Lock(TRBPED->PED_FILORI,TRBPED->PED_PEDIDO, aLock, aArrayZonas[oZonas:nAt,2],cMarca)

						lSomaCarga := Iif(TRBPED->PED_MARCA == cMarca,.F.,.T.)
						lAbatCarga := Iif(TRBPED->PED_MARCA != cMarca,.F.,.T.)

						RecLock("TRBPED",.F.)
						TRBPED->PED_MARCA := Iif(aArrayZonas[oZonas:nAt,2], cMarca, "  ")
						TRBPED->PED_CARGA := Iif(TRBPED->PED_CARGA==cMarca,cCarga,"ZZZZZZ")
						TRBPED->(MsUnlock())

						/*+-----------------------------------------------------------+
						|Verifico se existe no array de sequencia e incluo ou excluo|
						|caso a opcao escolhida pelo usuario                        |
						+-----------------------------------------------------------+*/

						cBusca := TRBPED->PED_PEDIDO+TRBPED->PED_CODCLI+TRBPED->PED_LOJA+TRBPED->PED_FILORI
						nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == cBusca})

						/*+-----------------------------------------------------------+
						|Verifico se o pedido foi marcado para inclusao no array de |
						|sequencia                                                  |
						+-----------------------------------------------------------+*/

						If ( TRBPED->PED_MARCA == cMarca )

							If ( nPosMan == 0 )
								Aadd(aArrayMan,{;
								TRBPED->PED_SEQROT,;
								TRBPED->PED_ROTA,;
								TRBPED->PED_ZONA,;
								TRBPED->PED_SETOR,;
								TRBPED->PED_PEDIDO,;
								TRBPED->PED_CODCLI,;
								TRBPED->PED_LOJA,;
								TRBPED->PED_NOME,;
								TRBPED->PED_BAIRRO,;
								TRBPED->PED_MUN,;
								TRBPED->PED_EST,;
								TRBPED->PED_FILORI,;
								TRBPED->PED_FILCLI,;
								TRBPED->PED_PESO,;
								TRBPED->PED_VOLUM,,,,,})
								//TRBPED->PED_VOLUM,,,})
							Else
								aArrayMan[nPosMan][14] += TRBPED->PED_PESO
								aArrayMan[nPosMan][15] += TRBPED->PED_VOLUM
							EndIf

							/*+-----------------------------------------------------+
							|Atualizo no array de carga os dados de volume, peso, |
							|valor e ptos de entrega                              |
							+-----------------------------------------------------+*/

							If lSomaCarga
								aArrayCarga[nPosCarga,CARGA_PESO]  := Transform(Val(aArrayCarga[nPosCarga,CARGA_PESO]) + TRBPED->PED_PESO,cPictPeso)
								aArrayCarga[nPosCarga,CARGA_VALOR] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VALOR]) + TRBPED->PED_VALOR,cPictVal)
								aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VOLUM]) + TRBPED->PED_VOLUM,cPictVol)
							EndIf

						ElseIf(TRBPED->PED_MARCA != cMarca)

							If ( nPosMan > 0 )
								aDel(aArrayMan,nPosMan)
								aSize(aArrayMan,Len(aArrayMan)-1)
							EndIf

							/*+-----------------------------------------------------+
							|Atualizo no array de carga os dados de volume, peso, |
							|valor e ptos de entrega                              |
							+-----------------------------------------------------+*/

							If lAbatCarga
								aArrayCarga[nPosCarga,CARGA_PESO]  := Transform(Val(aArrayCarga[nPosCarga,CARGA_PESO]) - TRBPED->PED_PESO,cPictPeso)
								aArrayCarga[nPosCarga,CARGA_VALOR] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VALOR]) - TRBPED->PED_VALOR,cPictVal)
								aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VOLUM]) - TRBPED->PED_VOLUM,cPictVol)
							EndIf

						EndIf

					EndIf

					dbSelectArea("TRBPED")
					TRBPED->(dbSkip())

				EndDo

			EndIf
		Next

		Case nEscolha == 3

		/*+---------------------------------------------------------------+
		|Verifico o flag se esta habliitado ou se esta como rota inativa|
		|para deixar marcar para geracao                                |
		+---------------------------------------------------------------+*/

		aArraySetor[oSetores:nAt,2] := Iif((!aArraySetor[oSetores:nAt,2] ) .And. ;
		(aArraySetor[oSetores:nAt,1] ),;
		.T., .F.)

		//+----------------------+
		//|Varro pedidos do setor|
		//+----------------------+
		dbSelectArea("TRBPED")
		dbSetOrder(4)
		MsSeek(aArraySetor[oSetores:nAt,3]+aArraySetor[oSetores:nAt,4]+aArraySetor[oSetores:nAt,5])
		While !Eof() .And. TRBPED->PED_ROTA+TRBPED->PED_ZONA+TRBPED->PED_SETOR == ;
		aArraySetor[oSetores:nAt,3]+aArraySetor[oSetores:nAt,4]+aArraySetor[oSetores:nAt,5]

			/*+-----------------------------------+
			|Verifico flag do pedido para marcar|
			+-----------------------------------+*/

			If ( TRBPED->PED_GERA == "N" .And. TRBPED->PED_ESTOQ == "S") .And. Oms200Lock(TRBPED->PED_FILORI,TRBPED->PED_PEDIDO, aLock, aArraySetor[oSetores:nAt,2],cMarca)

				lSomaCarga := Iif(TRBPED->PED_MARCA == cMarca,.F.,.T.)
				lAbatCarga := Iif(TRBPED->PED_MARCA != cMarca,.F.,.T.)

				RecLock("TRBPED",.F.)
				TRBPED->PED_MARCA  := Iif(aArraySetor[oSetores:nAt,2], cMarca, "  ")
				TRBPED->PED_CARGA  := Iif(TRBPED->PED_MARCA==cMarca,cCarga,"ZZZZZZ")
				TRBPED->(MsUnlock())

				/*+-----------------------------------------------------------+
				|Verifico se existe no array de sequencia e incluo ou excluo|
				|caso a opcao escolhida pelo usuario                        |
				+-----------------------------------------------------------+*/

				cBusca := TRBPED->PED_PEDIDO+TRBPED->PED_CODCLI+TRBPED->PED_LOJA+TRBPED->PED_FILORI
				nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == cBusca})

				/*+-----------------------------------------------------------+
				|Verifico se o pedido foi marcado para inclusao no array de |
				|sequencia                                                  |
				+-----------------------------------------------------------+*/

				If ( TRBPED->PED_MARCA == cMarca )

					If (nPosMan == 0)
						Aadd(aArrayMan,{TRBPED->PED_SEQROT,;
						TRBPED->PED_ROTA,;
						TRBPED->PED_ZONA,;
						TRBPED->PED_SETOR,;
						TRBPED->PED_PEDIDO,;
						TRBPED->PED_CODCLI,;
						TRBPED->PED_LOJA,;
						TRBPED->PED_NOME,;
						TRBPED->PED_BAIRRO,;
						TRBPED->PED_MUN,;
						TRBPED->PED_EST,;
						TRBPED->PED_FILORI,;
						TRBPED->PED_FILCLI,;
						TRBPED->PED_PESO,;
						TRBPED->PED_VOLUM,,,,,})
					Else
						aArrayMan[nPosMan][14] += TRBPED->PED_PESO
						aArrayMan[nPosMan][15] += TRBPED->PED_VOLUM
					EndIf

					/*+-----------------------------------------------------+
					|Atualizo no array de carga os dados de volume, peso, |
					|valor e ptos de entrega                              |
					+-----------------------------------------------------+*/

					If lSomaCarga
						aArrayCarga[nPosCarga,CARGA_PESO]  := Transform(Val(aArrayCarga[nPosCarga,CARGA_PESO]) + TRBPED->PED_PESO,cPictPeso)
						aArrayCarga[nPosCarga,CARGA_VALOR] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VALOR]) + TRBPED->PED_VALOR,cPictVal)
						aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VOLUM]) + TRBPED->PED_VOLUM,cPictVol)
						xnCapVol := Val(aArrayCarga[nPosCarga,CARGA_VOLUM])
					EndIf
				ElseIf(TRBPED->PED_MARCA != cMarca)

					If nPosMan > 0
						aDel(aArrayMan,nPosMan)
						aSize(aArrayMan,Len(aArrayMan)-1)
					EndIf

					/*+-----------------------------------------------------+
					|Atualizo no array de carga os dados de volume, peso, |
					|valor e ptos de entrega                              |
					+-----------------------------------------------------+*/

					If lAbatCarga
						aArrayCarga[nPosCarga,CARGA_PESO]  := Transform(Val(aArrayCarga[nPosCarga,CARGA_PESO])  - TRBPED->PED_PESO,cPictPeso)
						aArrayCarga[nPosCarga,CARGA_VALOR] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VALOR]) - TRBPED->PED_VALOR,cPictVal)
						aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VOLUM]) - TRBPED->PED_VOLUM,cPictVol)
						xnCapVol := Val(aArrayCarga[nPosCarga,CARGA_VOLUM])
					EndIf
				EndIf

			EndIf
			DbSelectArea("TRBPED")
			TRBPED->(dbSkip())
		EndDo
		Case nEscolha == 4
		/*+---------------------------------------------------------------+
		|Verifico o flag se esta habliitado ou se esta como rota inativa|
		|para deixar marcar para geracao                                |
		+---------------------------------------------------------------+*/
		If Oms200Lock(TRBPED->PED_FILORI,TRBPED->PED_PEDIDO, aLock, (TRBPED->PED_MARCA != cMarca),cMarca) .And. TRBPED->PED_GERA == "N"
			TRBPED->PED_MARCA  := Iif(TRBPED->PED_MARCA != cMarca .And.( TRBPED->PED_GERA == "N" ),cMarca, "  ")
			TRBPED->PED_CARGA  := Iif(TRBPED->PED_MARCA == cMarca   , cCarga ,"ZZZZZZ")
			TRBPED->PED_ESTOQ  := Iif(TRBPED->PED_MARCA == cMarca .And.( TRBPED->PED_GERA == "N" ),"S"," ")
			// Procede a inclusão ou exclusão do item na tabela de saldos compartilhada // zago 10.05.06
			fMarkItem(wcUsuario,cMarca)

			/*+-----------------------------------------------------------+
			|Verifico se existe no array de sequencia e incluo ou excluo|
			|caso a opcao escolhida pelo usuario                        |
			+-----------------------------------------------------------+*/
			cBusca := TRBPED->PED_PEDIDO+TRBPED->PED_CODCLI+TRBPED->PED_LOJA+TRBPED->PED_FILORI
			nPosMan := Ascan(aArrayMan,{|x| x[5]+x[6]+x[7]+x[12] == cBusca})
			/*+-----------------------------------------------------------+
			|Verifico se o pedido foi marcado para inclusao no array de |
			|sequencia                                                  |
			+-----------------------------------------------------------+*/
			If ( TRBPED->PED_MARCA == cMarca )
				/*+-----------------------------------------------------+
				|Se nao estiver pego apenas os valores do item marcado|
				+-----------------------------------------------------+*/
				nPesoItem  := TRBPED->PED_PESO
				nValorItem := TRBPED->PED_VALOR
				nVolItem   := TRBPED->PED_VOLUM
				/*+------------------------------------------------------------+
				|Verifico se a montagem e por item e se esta ativo a marcacao|
				|de todos os itens do pedido automatica                      |
				+------------------------------------------------------------+*/
				lAllMark := .T.
				If lAllMark
					cPedido := TRBPED->PED_FILORI+TRBPED->PED_PEDIDO
					TRBPED->(dbSetOrder(1))
					If TRBPED->(MsSeek(cPedido))
						While !TRBPED->(Eof()) .And. ( TRBPED->PED_FILORI+TRBPED->PED_PEDIDO == cPedido )
							/*+--------------------------------------------+
							|Marco todos os itens se o flag estiver ativo|
							+--------------------------------------------+*/
							If ( TRBPED->PED_MARCA <> cMarca )
								TRBPED->PED_MARCA  := cMarca
								nPesoItem  += TRBPED->PED_PESO
								nValorItem += TRBPED->PED_VALOR
								nVolItem   += TRBPED->PED_VOLUM
							EndIf
							TRBPED->(dbSkip())
						EndDo
					EndIf
				EndIf
				/*+-----------------------------------------------------+
				|Atualizo no array de carga os dados de volume, peso, |
				|valor e ptos de entrega                              |
				+-----------------------------------------------------+*/
				aArrayCarga[nPosCarga,CARGA_PESO]  := Transform(Val(aArrayCarga[nPosCarga,CARGA_PESO])  + nPesoItem ,cPictPeso)
				aArrayCarga[nPosCarga,CARGA_VALOR] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VALOR]) + nValorItem,cPictVal)
				aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VOLUM]) + nVolItem  ,cPictVol)
				xnCapVol := Val(aArrayCarga[nPosCarga,CARGA_VOLUM])
				If nPosMan == 0
					//-- Posiciona no pedido
					If lAllMark  .And. !Empty(cPedido)
						TRBPED->(dbSetOrder(1))
						TRBPED->(MsSeek(cPedido))
					EndIf
					Aadd(aArrayMan,{TRBPED->PED_SEQROT,;
					TRBPED->PED_ROTA,;
					TRBPED->PED_ZONA,;
					TRBPED->PED_SETOR,;
					TRBPED->PED_PEDIDO,;
					TRBPED->PED_CODCLI,;
					TRBPED->PED_LOJA,;
					TRBPED->PED_NOME,;
					TRBPED->PED_BAIRRO,;
					TRBPED->PED_MUN,;
					TRBPED->PED_EST,;
					TRBPED->PED_FILORI,;
					TRBPED->PED_FILCLI,;
					nPesoItem,;
					nVolItem,,,,,})
				Else
					aArrayMan[nPosMan][14] += nPesoItem
					aArrayMan[nPosMan][15] += nVolItem
				EndIf
				Oms200Rot(aArrayRota,aArrayZona,aArraySetor,TRBPED->PED_ROTA,TRBPED->PED_ZONA,TRBPED->PED_SETOR,cMarca)

			ElseIf(TRBPED->PED_MARCA != cMarca) // .And. nPosMan > 0
				/*+-----------------------------------------------------+
				|Se nao estiver pego apenas os valores do item marcado|
				+-----------------------------------------------------+*/
				nPesoItem  := TRBPED->PED_PESO
				nValorItem := TRBPED->PED_VALOR
				nVolItem   := TRBPED->PED_VOLUM
				/*+------------------------------------------------------------+
				|Verifico se a montagem e por item e se esta ativo a marcacao|
				|de todos os itens do pedido automatica                      |
				+------------------------------------------------------------+*/
				If lAllMark
					cPedido := TRBPED->PED_FILORI+TRBPED->PED_PEDIDO
					TRBPED->(dbSetOrder(1))
					If TRBPED->(MsSeek(cPedido))
						While !TRBPED->(Eof()) .And. ( TRBPED->PED_FILORI+TRBPED->PED_PEDIDO == cPedido )
							/*+--------------------------------------------+
							|Marco todos os itens se o flag estiver ativo|
							+--------------------------------------------+*/
							If (TRBPED->PED_MARCA = cMarca)
								TRBPED->PED_MARCA  := "  "
								nPesoItem  += TRBPED->PED_PESO
								nValorItem += TRBPED->PED_VALOR
								nVolItem   += TRBPED->PED_VOLUM
							EndIf
							TRBPED->(dbSkip())
						EndDo
					EndIf
					lDelMan := .T.
				Else
					lDelMan := .T.
					cPedido := TRBPED->PED_FILORI+TRBPED->PED_PEDIDO
					TRBPED->(dbSetOrder(1))
					If TRBPED->(MsSeek(cPedido))
						While !TRBPED->(Eof()) .And. ( TRBPED->PED_FILORI+TRBPED->PED_PEDIDO == cPedido )
							If ( TRBPED->PED_MARCA == cMarca )
								lDelMan := .F.
								Exit
							EndIf
							TRBPED->(dbSkip())
						EndDo
					EndIf

				EndIf
				/*+-----------------------------------------------------+
				|Atualizo no array de carga os dados de volume, peso, |
				|valor e ptos de entrega                              |
				+-----------------------------------------------------+*/
				aArrayCarga[nPosCarga,CARGA_PESO]  := Transform(Val(aArrayCarga[nPosCarga,CARGA_PESO])  - nPesoItem ,cPictPeso)
				aArrayCarga[nPosCarga,CARGA_VALOR] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VALOR]) - nValorItem,cPictVal)
				aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(Val(aArrayCarga[nPosCarga,CARGA_VOLUM]) - nVolItem,cPictVol)
				xnCapVol := Val(aArrayCarga[nPosCarga,CARGA_VOLUM])

				If nPosMan == 0
					Aadd(aArrayMan,{TRBPED->PED_SEQROT,;
					TRBPED->PED_ROTA,;
					TRBPED->PED_ZONA,;
					TRBPED->PED_SETOR,;
					TRBPED->PED_PEDIDO,;
					TRBPED->PED_CODCLI,;
					TRBPED->PED_LOJA,;
					TRBPED->PED_NOME,;
					TRBPED->PED_BAIRRO,;
					TRBPED->PED_MUN,;
					TRBPED->PED_EST,;
					TRBPED->PED_FILORI,;
					TRBPED->PED_FILCLI,;
					0,;
					0,,,,,})
				Else
					aArrayMan[nPosMan][14] -= nPesoItem
					aArrayMan[nPosMan][15] -= nVolItem
				EndIf
				Oms200Rot(aArrayRota,aArrayZona,aArraySetor,TRBPED->PED_ROTA,TRBPED->PED_ZONA,TRBPED->PED_SETOR,cMarca)
				If lDelMan
					If nPosMan > 0
						aDel(aArrayMan,nPosMan)
						aSize(aArrayMan,Len(aArrayMan)-1)
					EndIf
				EndIf
			EndIf
		Endif
	EndCase
	/*+-------------------------+
	|Calculo pontos de entrega|
	+-------------------------+*/
	If GetNewPar("MV_SEQENT","1") == "1" //-- Sequencia + Rota + Pedido
		aArrayMan := aSort(aArrayMan,,,{|x,y| x[1]+x[2]+x[5] < y[1]+y[2]+y[5] })
	Else //-- Rota + Sequencia + Pedido
		aArrayMan := aSort(aArrayMan,,,{|x,y| x[2]+x[1]+x[5] < y[2]+y[1]+y[5] })
	EndIf
	/*+------------------------------------------------+
	|Calculo janela de entregas dos clientes da carga|
	+------------------------------------------------+*/
	Oms200Time(cHrStart,aArrayMan,aArrayCarga[nPosCarga,CARGA_VEIC],12,6,7,2,3,4,14,15,16,17,18)
	For nC := 1 to Len(aArrayMan)
		If ( Ascan(aArrayPto,{|x| x[1]+x[2]+x[3] == aArrayMan[nC,6]+aArrayMan[nC,7]+aArrayMan[nC,13]}) == 0 )
			Aadd(aArrayPto, { aArrayMan[nC,6],aArrayMan[nC,7],aArrayMan[nC,13]})
		EndIf
	Next
	aArrayCarga[nPosCarga,CARGA_PTOENT] := StrZero(Len(aArrayPto),6)
	/*+----------------------------------------------------+
	|Posiciono no registro inicial do arquivo de trabalho|
	+----------------------------------------------------+*/
	//nPosCarga := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})

	TRBPED->(DbGoTop())
	nVol := 0
	TRBPED->(DbEval({|| iif(TRBPED->PED_MARCA == cMarca, nVol += TRBPED->PED_VOLUM,) }))

	//aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(nVol,PesqPict("SB1","B1_YM3"))
	aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(nVol,PesqPict("DAK","DAK_CAPVOL"))

	TRBPED->(DbSetOrder(15))
	TRBPED->(DbGoto(nRecnoTRB))

	oCargas:Refresh()
	oRotas:Refresh()
	oZonas:Refresh()
	oSetores:Refresh()
	oMark:oBrowse:Refresh()
	//oMarcados:Refresh()
Return

/*+----------+----------+-------+--------------------+------+-------------+
|Programa  |OmsCarrega|Autor  |Henry Fila          | Data |  12/22/00   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     |  Gera carregamento                                         |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros| aArrayCarga - Array  de cargas passado por referencia      |
|          | aArrayRota  - Array  de rotas  passado por referencia      |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+*/
Static Function fOmsCarreg(oEnable,oDisable,oMarked,oNoMarked,cMarca,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan)
	local nc,nrota,nzona,nsetor
	Local aArrayGera := {}
	Local cCarga     := ""
	Local cVeiculo   := ""
	Local cMotorista := ""
	Local cAjuda1    := ""
	Local cAjuda2    := ""
	Local cAjuda3    := ""
	Local cRota      := ""
	Local cEndereco  := ""
	Local cCliente   := ""
	Local cLoja      := ""
	Local cQuery     := ""
	Local cAliasSC9  := "SC9"

	Local nRecTRB    := TRBPED->(Recno())
	Local nPosRota   := 0
	Local nPosZona   := 0
	Local nPosSetor  := 0
	Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
	Local nTipoOper  := OsVlEntCom()

	Local lProcSC9   := .T.
	Local lQuery     := .F.
	Local lProcessa  := .T.
	Local lOms200Ok  := ExistBlock("OM200OK")
	Local lOms200Fim := ExistBlock("OM200FIM")
	Local i

	If Len( aArrayMan ) == 0
		Help(" ",1,"OMSPEDMARK") //Nao existem pedidos marcados
		lProcessa := .F.
	EndIf

	If lProcessa
		/*+------------------------------------------+
		|Verifico se existe carga disponivel aberta|
		+------------------------------------------+*/
		If nPosCarga == 0
			Help(" ",1,"DLACGDISP") //Nao existe carga \ aberta
			lProcessa := .F.
		EndIf
	Endif

	//lProcessa := fPesoZero(cMarca)

	If lProcessa
		cCarga    := aArrayCarga[nPosCarga,CARGA_COD]
		cVeiculo  := aArrayCarga[nPosCarga,CARGA_VEIC]
		cMotorista:= aArrayCarga[nPosCarga,CARGA_MOTOR]
		cAjuda1   := aArrayCarga[nPosCarga,CARGA_AJUD1]
		cAjuda2   := aArrayCarga[nPosCarga,CARGA_AJUD2]
		cAjuda3   := aArrayCarga[nPosCarga,CARGA_AJUD3]

		/*+----------------------------------------------------------+
		|Verifico se o total da carga esta fechado com a capacidade|
		|do caminhao se parametro considerar restricoes            |
		+----------------------------------------------------------+*/

		If mv_par13 == 1 .And. !Empty(cVeiculo)

			DA3->(dbSetOrder(1))
			If DA3->(MsSeek(xFilial("DA3")+cVeiculo))
				If (Val(aArraycarga[oCargas:nAt,CARGA_PESO]) > DA3->DA3_CAPACN).Or.;
				(Val(aArrayCarga[oCargas:nAt,CARGA_VOLUM]) > DA3->DA3_VOLMAX).Or.;
				(Val(aArrayCarga[oCargas:nAt,CARGA_PTOENT]) > DA3->DA3_LIMMAX)
					Help(" ",1,"OMSULTCARG") //Caminhao nao suporta carga montada
					lProcessa := .F.
				EndIf
			EndIf
		EndIf
	Endif

	/*+----------------------------------------------------+
	//|Verifico o numero de rotas que existem na carga para|
	//|a escolha de apenas uma caso haja mais do que uma   |
	//+----------------------------------------------------+*/

	If lProcessa
		If !Oms200ARota(@aArrayMan)
			lProcessa := .F.
		EndIf
	Endif

	If lProcessa
		If IntDL()
			If !Oms200EPad(@aArrayMan,@cEndereco)
				lProcessa := .F.
			EndIf
		EndIf
	Endif

	/*
	If lOms200Ok
	lProcessa := ExecBlock("OM200OK",.F.,.F.,{ aArrayMan, aArrayCarga, nPosCarga})
	If ValType(lProcessa) <> "L"
	lProcessa := .T.
	EndIf
	Endif
	*/

	//+----------------------------------+
	//|Sem pedidos bloqueados na seleção?|
	//+----------------------------------+
	lProcessa:= (lProcessa .And. Regra01(cMarca))

	//+-------------------------------------------------------+
	//|Não há pedidos normais que dependem de mostruário que, |
	//|por sua vez, não estão marcados                        |
	//+-------------------------------------------------------+
	lProcessa:= (lProcessa .And. Regra02(cMarca))

	// Esta regra 03 foi desabilitada em 30/12/05 pois existe uma nova forma de
	// verificação do valor minimo do pedido - será feito pela menor parcela
	// no financeiro. Haverá uma conversa com Wanisay para definir todo o processo
	//+------------------------------------------------+
	//|Cliente tem restricao no valor minimo para frete|
	//+------------------------------------------------+
	//lProcessa:= (lProcessa .And. Regra03(cMarca)) //Rotina comentada para futura definicao com a Mariana - 30/01/2007

	//+-----------------------------------------------+
	//|Cliente exige ser avisado da entrega do pedido |
	//+-----------------------------------------------+
	lProcessa:= (lProcessa .And. Regra04(cMarca))

	If lProcessa
		nPosCarga := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
		aArrayAux := {}
		nQtdEnt := 0
		For i := 1 to Len(aArrayMan)
			If !Empty(aArrayMan[i,12])
				If aScan(aArrayAux,{|x| x == aArrayMan[i,12]}) == 0
					aAdd(aArrayAux, aArrayMan[i,12])
				EndIf
			Else
				nQtdEnt++
			EndIf
		Next i
		//lProcessa := lProcessa .And. (Len(aArrayAux)+nQtdEnt <= GetMv("MV_YMAXENT"))
		lProcessa := lProcessa .And. (Len(aArrayAux)+nQtdEnt <= 50)
		If !lProcessa
			Alert("Passou do numero de entregas")
		EndIf
	EndIf

	//+-------------------------------------+
	//|Se todo ok confirmo geracao da carga |
	//+-------------------------------------+
	If lProcessa
		Begin Transaction
			xArea := GetArea()
			xRec  := TRBPED->(RecNo())
			TRBPED->(DbGoTop())
			While !TRBPED->(Eof())
				If TRBPED->PED_MARCA == cMarca
					DbSelectArea("SC9")
					If DbSeek(xFilial("SC9")+TRBPED->PED_PEDIDO + TRBPED->PED_ITEM + TRBPED->PED_SEQLIB)
						RecLock("SC9",.F.)
						//SC9->C9_BLEST  := "  "
						//SC9->C9_BLCRED := "  "
						SC9->(MsUnlock())
					EndIf
				EndIf
				TRBPED->(DbSkip())
			EndDo
			TRBPED->(DbGoTo(xRec))
			RestArea(xArea)

			//+------------------------------------------------------------------+
			//|Prepara array para a funcao de geracao                            |
			//+------------------------------------------------------------------+

			For nC := 1 to Len(aArrayMan)

				//+---------------------------------------------------------------+
				//|Busca com a filial de origem do SC9                            |
				//+---------------------------------------------------------------+
				cBusca := aArrayMan[nC][12]+aArrayMan[nC,5]

				lQuery := .T.

				cAliasSC9 := "QRYSC9"

				cQuery := "SELECT C9_FILIAL,C9_CARGA,C9_SEQCAR,C9_BLCRED,C9_BLEST,C9_PEDIDO,C9_ITEM,C9_SEQUEN,"
				cQuery += "C9_CLIENTE,C9_LOJA,SC9.R_E_C_N_O_ RECSC9 "
				cQuery += " FROM "
				cQuery += RetSqlName("SC9")+ " SC9 "
				cQuery += " WHERE "
				cQuery += "C9_FILIAL  = '"+aArrayMan[nC][12]+"' AND "
				cQuery += "C9_PEDIDO  = '"+aArrayMan[nC,5]+"' AND "
				cQuery += "C9_BLCRED  = ' ' AND "
				cQuery += "C9_BLEST   = ' ' AND "
				cQuery += "C9_CARGA   = ' ' AND "
				cQuery += "C9_SEQCAR  = ' ' AND "
				cQuery += "C9_NFISCAL = ' ' AND "     // ADICIONADO POR FELIPE ZAGO
				cQuery += "SC9.D_E_L_E_T_ = ' ' "

				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSC9,.F.,.T.)

				While !Eof() .And. (cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_PEDIDO == cBusca

					lProcSC9 := .T.

					//+----------------------------------------------------------+
					//|Se for por item verifica se ele foi marcado para a geracao|
					//+----------------------------------------------------------+

					If !lQuery
						If !Empty((cAliasSC9)->C9_CARGA+(cAliasSC9)->C9_BLCRED+(cAliasSC9)->C9_BLEST)
							lProcSC9 := .F.
						EndIf
					Endif

					If .T.

						//+--------------------------------------------------------------+
						//|Verifico se este item do pedido foi gerado carga anteriormente|
						//+--------------------------------------------------------------+

						If lProcSC9

							TRBPED->(dbSetOrder(1))
							If TRBPED->(MsSeek((cAliasSC9)->C9_FILIAL+(cAliasSC9)->C9_PEDIDO+(cAliasSC9)->C9_ITEM+(cAliasSC9)->C9_SEQUEN))
								If TRBPED->PED_MARCA != cMarca
									lProcSC9 := .F.
								Endif
							Else
								lProcSC9 := .F.
							EndIf

						EndIf

					EndIf

					If lProcSC9 .And. ExistBlock("OS200PC9")
						lProcSC9 := Execblock("OS200PC9",.F.,.F.,{cAliasSC9})
					EndIf

					If lProcSC9

						If nTipoOper == 3
							DCK->(dbSetOrder(2))
							If DCK->(MsSeek(xFilial("DCK")+(cAliasSC9)->C9_CLIENTE+(cAliasSC9)->C9_LOJA))
								cCliente := DCK->DCK_CODOPL
								cLoja    := DCK->DCK_LOJOPL
							Else
								cCliente := (cAliasSC9)->C9_CLIENTE
								cLoja    := (cAliasSC9)->C9_LOJA
							EndIf
						Else
							cCliente := (cAliasSC9)->C9_CLIENTE
							cLoja    := (cAliasSC9)->C9_LOJA
						EndIf
						Aadd(aArrayGera, {aArrayMan[nC,1],aArrayMan[nC,2],aArrayMan[nC,3],aArrayMan[nC,4],;
						(cAliasSC9)->C9_PEDIDO, (cAliasSC9)->C9_ITEM, cCliente, cLoja,;
						Iif(!lQuery,(cAliasSC9)->(Recno()),(cAliasSC9)->RECSC9),cEndereco,;
						(cAliasSC9)->C9_FILIAL,aArrayMan[nC][13],aArrayMan[nC][16],aArrayMan[nC][17],;
						aArrayMan[nC][19],aArrayMan[nC][20] } )
					EndIf

					lProcSC9 := .T.

					dbSelectarea(cAliasSC9)
					dbSkip()

				EndDo

				If lQuery
					dbSelectArea(cAliasSC9)
					dbCloseArea()
					dbSelectArea("SC9")
				Endif

			Next

			//+-------------------------------------------------------------------+
			//|Gero a carga baseado no array                                      |
			//+-------------------------------------------------------------------+
			Processa({ || u_Oms200Carga(@aArrayGera, cCarga, Nil, cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3) })

			//+-------------------------------------------------------------------+
			//|Atualiza flags de geracao na markbrowse                            |
			//+-------------------------------------------------------------------+
			aArrayCarga[nPosCarga,CARGA_ENABLE] := .F.

			For nRota := 1 to Len(aArrayRota)
				If ( aArrayRota[nRota,2] )
					aArrayRota[nRota,1] := .F.
					aArrayRota[nRota,2] := .F.
					aArrayRota[nRota,5] := cCarga
				EndIf
			Next

			For nZona := 1 to Len(aArrayZona)
				If ( aArrayZona[nZona,2] )
					aArrayZona[nZona,1] := .F.
					aArrayZona[nZona,2] := .F.
					aArrayZona[nZona,6] := cCarga
				EndIf
			Next

			For nSetor := 1 to Len(aArraySetor)
				If ( aArraySetor[nSetor,2] )
					aArraySetor[nSetor,1] := .F.
					aArraySetor[nSetor,2] := .F.
					aArraySetor[nSetor,7] := cCarga
				EndIf
			Next

			dbSelectArea("TRBPED")
			dbGotop()
			While !Eof()
				If ( TRBPED->PED_MARCA == cMarca )
					TRBPED->PED_GERA  := "S"
					TRBPED->PED_MARCA := "  "
					TRBPED->PED_CARGA := cCarga
				EndIf
				dbSkip()
			EndDo

			//+-------------------------------------------------------+
			//|Verifico o array de pedidos para ver se sobraram alguns|
			//|pedidos das rotas para nao desbilitar                  |
			//+-------------------------------------------------------+

			dbSelectArea("TRBPED")
			dbGotop()
			While !Eof()

				If TRBPED->PED_GERA == "N"
					nPosRota := Ascan(aArrayRota,{|x| x[3] == TRBPED->PED_ROTA})
					aArrayRota[nPosRota,1] := .T.
					aArrayRota[nPosRota,2] := .F.

					nPosZona := Ascan(aArrayZona,{|x| x[3]+x[4] == TRBPED->PED_ROTA+TRBPED->PED_ZONA})
					aArrayZona[nPosZona,1] := .T.
					aArrayZona[nPosZona,2] := .F.

					nPosSetor := Ascan(aArraySetor,{|x| x[3]+x[4]+x[5] == TRBPED->PED_ROTA+TRBPED->PED_ZONA+TRBPED->PED_SETOR})
					aArraySetor[nPosSetor,1] := .T.
					aArraySetor[nPosSetor,2] := .F.

				EndIf

				dbSkip()
			EndDo

		End Transaction

		//+----------------------------------+
		//|Zero o array de sequencia na carga|
		//+----------------------------------+

		aArrayMan := {}

		dbSelectArea("TRBPED")
		//dbSetOrder(3) // alterado em 15/02/06
		dbSetOrder(15)
		dbGoto(nRecTRB)

		oCargas:Refresh()
		oRotas:Refresh()
		oZonas:Refresh()
		oSetores:Refresh()
		oMark:oBrowse:Refresh()

		If lOms200Fim
			ExecBlock("OM200FIM",.F.,.F.)
		EndIf
	Endif
Return

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |Oms200Carg|Autor  |Henry Fila          | Data |  01/17/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Funcao de geracao de carga                                 |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros| aArrayMan - Array contendo os pedidos que deve ser gerados |
|          |             ja na sequencia de entrega                     |
|          |             [1] - Sequencia                                |
|          |             [2] - Rota                                     |
|          |             [3] - Zona                                     |
|          |             [4] - Setor                                    |
|          |             [5] - Pedido                                   |
|          |             [6] - Cliente                                  |
|          |             [7] - Loja                                     |
|          | cCarga    - Numero da carga a ser gerada                   |
|          | cSeqCarga - Sequencia da carga                             |
|          | cVeiculo - Caminhao a ser gerado a carga                   |
|          | cRota     - Rota associada a ser gerada a carga            |
|          | lPedido   - .T. Pedido total /  .F. Por Item               |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

User Function Oms200Carga(aArrayGera, cCarga,cSeqCar, cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3)
	Local nc
	Local aArrayPto  := {}
	Local aArraySeq  := {}
	Local aRotas     := {}
	Local cBusca     := ""
	Local cMay       := ""

	Local lGerou     := .F.
	Local lOs200DAK := ExistBlock("OS200DAK")

	Local nPtoEntr   := 0
	Local nSequencia := 0

	Default cMotorista := Criavar("DA4_COD",.F.)
	Default cAjuda1    := Criavar("DAU_COD",.F.)
	Default cAjuda2    := Criavar("DAU_COD",.F.)
	Default cAjuda3    := Criavar("DAU_COD",.F.)
	Default cSeqCar    := "01"

	/*+----------------------------------------------------------+
	|Reordeno o array pois o usuario pode nao ter solicitado a |
	|visualizacao ordenada                                     |
	+----------------------------------------------------------+*/

	For nC := 1 to Len(aArrayGera)
		/*+-------------------------+
		|Calculo pontos de entrega|
		+-------------------------+*/

		If ( Ascan(aArrayPto,{|x| x[1]+x[2]+x[3] == aArrayGera[nC,7]+aArrayGera[nC,8]+aArrayGera[nC,11]}) == 0 )
			Aadd(aArrayPto, { aArrayGera[nC,7],aArrayGera[nC,8],aArrayGera[nC,11]})
		EndIf

		If ( Ascan(aArraySeq,{|x| x[1]+x[2] == aArrayGera[nC,11]+aArrayGera[nC,5]}) == 0 )
			nSequencia+=5
			Aadd(aArraySeq,{ aArrayGera[nC,11],aArrayGera[nC,5] })
		Endif
		aArrayGera[nC,1] := StrZero(nSequencia,6)
	Next
	nPtoEntr := Len(aArrayPto)

	/*+--------------------------------------------------------+
	|Verifico se tenho um numero de carga pre-definido ou se |
	|terei que gerar                                         |
	+--------------------------------------------------------+*/
	cCarga := Iif(cCarga == Nil, CriaVar("DAK_COD",.T.),cCarga)

	dbSelectArea("DAK")
	cMay := "DAK"+ Alltrim(xFilial("DAK"))
	DAK->(dbSetOrder(1))
	While ( DbSeek(xFilial("DAK")+cCarga) .or. !MayIUseCode(cMay+cCarga) )
		cCarga := Soma1(cCarga,Len(DAK->DAK_COD))
	EndDo

	ProcRegua(Len(aArrayGera))
	/*+-------------------------------------------------------------+
	| Gera o Arquivo DAK.                                         |
	+-------------------------------------------------------------+*/
	DbSelectArea("DAK")
	RecLock("DAK",.T.)
	DAK->DAK_COD    := cCarga
	DAK->DAK_SEQCAR := "01"
	DAK->DAK_FILIAL := xFilial()
	DAK->DAK_CAMINH := cVeiculo
	DAK->DAK_MOTORI := cMotorista
	DAK->DAK_AJUDA1 := cAjuda1
	DAK->DAK_AJUDA2 := cAjuda2
	DAK->DAK_AJUDA3 := cAjuda3
	DAK->DAK_ROTEIR := wcRota
	DAK->DAK_DATA   := dDatabase
	DAK->DAK_HORA   := Time()
	DAK->DAK_PESO   := 0
	DAK->DAK_CAPVOL := xnCapVol
	DAK->DAK_PTOENT := 0
	DAK->DAK_VALOR  := 0
	DAK->DAK_JUNTOU := "MANUAL"
	DAK->DAK_FLGUNI := "2"
	DAK->DAK_FEZNF  := "2"
	DAK->DAK_ACECAR := "2"
	DAK->DAK_ACEFIN := "2"
	DAK->DAK_ACEVAS := "2"
	DAK->(MsUnlock())

	If lOs200Dak
		ExecBlock("OS200DAK",.F.,.F.)
	Endif

	/*+-------------------------------------------------------------+
	| Gera o Arquivo DAI e atualizo os acumuladores do DAK        |
	+-------------------------------------------------------------+*/
	For nSequencia := 1 to Len(aArrayGera)
		IncProc()
		aRotas := {}
		SC9->(dbGoto(aArrayGera[nSequencia,9]))

		/*+--------------------------------------------------------------------+
		|Atualiza o SC9 com os dados da carga gerada                         |
		+--------------------------------------------------------------------+*/
		Reclock("SC9",.F.)
		SC9->C9_CARGA   := cCarga
		SC9->C9_SEQCAR  := cSeqCar
		SC9->C9_SEQENT  := aArrayGera[nSequencia,01]
		SC9->C9_ENDPAD  := aArrayGera[nSequencia,10]
		//SC9->C9_AGREG   := MV_PAR24
		SC9->(MsUnlock())
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO))
		RecLock("SC5",.F.)
		//SC5->C5_YCARGA := MV_PAR24
		//SC5->C5_YORDEM := Substr(SC9->C9_SEQENT,4)
		SC5->(MsUnlock())
		/*+--------------------------------------------------------------------+
		|Avalia o SC9 para inclusao do DAI                                   |
		+--------------------------------------------------------------------+*/
		aAdd(aRotas,aArrayGera[nSequencia,2])
		aAdd(aRotas,aArrayGera[nSequencia,3])
		aAdd(aRotas,aArrayGera[nSequencia,4])
		aAdd(aRotas,cVeiculo)
		aAdd(aRotas,cMotorista)
		aAdd(aRotas,cAjuda1)
		aAdd(aRotas,cAjuda2)
		aAdd(aRotas,cAjuda3)
		aAdd(aRotas,aArrayGera[nSequencia,13])
		aAdd(aRotas,aArrayGera[nSequencia,14])
		/*TESTE*/
		Aadd(aRotas,aArrayGera[nSequencia,15])
		Aadd(aRotas,aArrayGera[nSequencia,16])
		Aadd(aRotas,cHrStart)
		/*TESTE*/
		MaAvalSC9("SC9",7,,,,,,aRotas)
		//MaAvalSC9("SC9",7,,,,,,@aRotas)
		lGerou := .T.
		/*+--------------------------------------------------------------------+
		|Gera o Servico de WMS na montagem da Carga                          |
		+--------------------------------------------------------------------+*/
		If IntDL(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC) .And. SC9->C9_TPCARGA=='3'
			CriaDCF('SC9')
		EndIf
	Next
	If lGerou
		ConfirmSX8()
		//fCondPag(cxMarca) /* A troca de condicao de pagamento por valores minimos foi cancelado por solicitacao da Movelar em 23/01/2007 */
		fExcRes(cxMarca)

		/* A rotina de aglutinacao de pedidos foi deixada de lado pela expedição em 24/01/06 - Aclimar */
		//fAglutina(cxMarca)
	Else
		RollBackSX8()
	EndIf
Return

/*+----------+----------+-------+--------------------+------+-------------+
|Programa  |OmsAbreCar|Autor  |Henry Fila          | Data |  12/26/00   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     |Abre Carga Disponivel                                       |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros| aArrayCarga - Array  de cargas passado por referencia      |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+*/

Static Function OmsAbreCarga(oEnable,oDisable,oMarked,oNoMarked,aArrayCarga)
	Local lGerou := .F.,nc
	Local cPictVal   := "99999999." + Replicate("9",TamSx3("DAK_VALOR")[2])
	//Local cPictVol   := PesqPict("SB1","B1_YM3")
	Local cPictVol   := "99999999." + Replicate("9",TamSx3("DAK_CAPVOL")[2])
	Local cPictPeso  := "99999999." + Replicate("9",TamSx3("DAK_PESO")[2])
	/*+-----------------------------------------------
	|Verifico se existem cargas abertas para geracao|
	+-----------------------------------------------+*/

	For nC := 1 to Len(aArrayCarga)
		If aArrayCarga[nC,CARGA_ENABLE]
			Help(" ",1,"OMSCGABER") //Ja existem cargas abertas para geracao
			Return
		EndIf
	Next
	If Len(aArrayCarga) >= 1 .And. !Empty(aArrayCarga[1,CARGA_COD])
		aAdd(aArrayCarga,{.T.,cCarga,OemtoAnsi(STR0040)+cCarga,TransForm(0,cPictPeso),TransForm(0,cPictVal),; //"CARGA "
		TransForm(0,cPictVol),StrZero(0,6),Space(7),Space(Len(DA3->DA3_COD)),,Space(Len(DA4->DA4_COD)),Space(Len(DAU->DAU_COD)),;
		,Space(Len(DAU->DAU_COD)),Space(Len(DAU->DAU_COD))})
	Else
		aArrayCarga[1,CARGA_ENABLE] := .T.
		aArrayCarga[1,CARGA_COD]    := cCarga
		aArrayCarga[1,CARGA_DESC]   := OemtoAnsi(STR0040) + cCarga //"CARGA "
		aArrayCarga[1,CARGA_PESO]   := TransForm(0,cPictPeso)
		aArrayCarga[1,CARGA_VALOR]  := TransForm(0,cPictVal)
		aArrayCarga[1,CARGA_VOLUM]  := TransForm(0,cPictVol)
		aArrayCarga[1,CARGA_PTOENT] := StrZero(0,6)
		aArrayCarga[1,CARGA_VEIC]   := Space(Len(DA3->DA3_COD))
		aArrayCarga[1,CARGA_MOTOR]  := Space(Len(DA4->DA4_COD))
		aArrayCarga[1,CARGA_AJUD1]  := Space(Len(DAU->DAU_COD))
		aArrayCarga[1,CARGA_AJUD2]  := Space(Len(DAU->DAU_COD))
		aArrayCarga[1,CARGA_AJUD3]  := Space(Len(DAU->DAU_COD))
	EndIf
	oCargas:Refresh()
Return


/*+----------+----------+-------+--------------------+------+-------------+
|Programa  |OmsFilTipo|Autor  |Henry Fila          | Data |  05/04/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     |Mastra janela inicial da montagem de carga para filtrar os  |
|          |tipos de carga.                                             |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+*/
Static Function OmsFilTipo(oMarked,oNoMarked,aArrayMod,aArrayTipo)
	Local lRet    := .F.
	Local cBitMap := ""
	Local lDisable:= .F.

	//+--------------------------------------+
	//|Busca modelos de carga e joga no array|
	//+--------------------------------------+

	dbSelectArea("DB0")
	dbSetOrder(1)
	MsSeek(xFilial("DB0"))

	While !Eof() .And. DB0_FILIAL == xFilial("DB0")
		aAdd(aArrayMod,{.F.,DB0->DB0_CODMOD,DB0->DB0_DESMOD,DB0->DB0_TIPCAR})
		dbSkip()
	EndDo

	If Len(aArrayMod) == 0
		aAdd(aArrayMod,{.F.,CriaVar("DB0_CODMOD",.F.),CriaVar("DB0_DESMOD",.F.),CriaVar("DB0_TIPCAR",.F.)})
		lDisable := .T.
	EndIf

	//+------------------------------------+
	//|Busca tipos de carga e joga no array|
	//+------------------------------------+

	dbSelectArea("SX5")
	dbSetOrder(1)
	MsSeek(xFilial("SX5")+"DU")

	While !Eof() .And. X5_FILIAL+X5_TABELA == xFilial("SX5")+"DU"
		aAdd(aArrayTipo,{.F.,X5_CHAVE,X5Descri()})
		dbSkip()
	EndDo

	If Len(aArrayTipo) == 0
		aAdd(aArrayTipo,{.F.,Space(6),Space(30)})
	EndIf

	DEFINE FONT oFont NAME "Arial" SIZE 0, -11

	cBitmap := "PROJETOAP"

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0079) FROM 0,0 TO 300,620 OF oMainWnd PIXEL //"Tipos de Cargas"
	@ 0 , 0 BITMAP oBmp RESNAME cBitMap oF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL
	@ 25,50 TO 26,500 Of oDlg Pixel
	@ 03, 50 SAY OemtoAnsi(STR0080) Of oDlg Pixel //"Esta rotina ira montar o mapa de Rotas, Zonas, Setores e Pedidos disponiveis"
	@ 10, 50 SAY OemtoAnsi(STR0081) Of oDlg Pixel //"para a montagem de carga de acordo com os parametros escolhidos pelo usuario."

	@ 28,50  SAY OemtoAnsi(STR0082) OF oDlg Pixel //"Grupos de Carga"
	@ 28,180 SAY OemtoAnsi(STR0079) OF oDlg Pixel //"Tipos de Carga"

	@ 35,50 LISTBOX oModelo Var cModelo FIELDS HEADER " ",;
	OemToAnsi(STR0013),;//"Codigo"
	OemtoAnsi(STR0020) SIZE 125,85 ; //"Descricao"
	ON DBLCLICK (OmsTrocaTip(1,;
	@aArrayMod,;
	@aArrayTipo,;
	@oMarked,;
	@oNoMarked)) OF oDlg PIXEL

	oModelo:nFreeze := 1
	oModelo:SetArray(aArrayMod)
	oModelo:bLine:={ ||{Iif(aArrayMod[oModelo:nAT,1],oMarked,oNoMarked),;
	aArrayMod[oModelo:nAT,2],;
	aArrayMod[oModelo:nAT,3]}}

	@ 35,180 LISTBOX oTipo Var cTipo FIELDS HEADER " ",;
	OemToAnsi(STR0013),;//"Codigo"
	OemtoAnsi(STR0020) SIZE 125,85 ;  //"Descricao"
	ON DBLCLICK (OmsTrocaTip(2,;
	@aArrayMod,;
	@aArrayTipo,;
	@oMarked,;
	@oNoMarked)) OF oDlg PIXEL

	oTipo:nFreeze := 1
	oTipo:SetArray(aArrayTipo)
	oTipo:bLine:={ ||{Iif(aArrayTipo[oTipo:nAT,1],oMarked,oNoMarked),;
	aArrayTipo[oTipo:nAT,2],;
	aArrayTipo[oTipo:nAT,3]}}

	If lDisable
		oTipo:Disable()
		oModelo:Disable()
	Endif

	DEFINE SBUTTON oBut1 FROM 130, 220 TYPE 5 ENABLE OF oDlg PIXEL ACTION Pergunte("MOVCAR",.T.)
	DEFINE SBUTTON oBut2 FROM 130, 250 TYPE 1 ENABLE OF oDlg PIXEL ACTION (lRet := .T.,oDlg:End())
	DEFINE SBUTTON oBut3 FROM 130, 280 TYPE 2 ENABLE OF oDlg PIXEL ACTION (lRet := .F.,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
Return(lRet)

/*
+----------+-----------+-------+--------------------+------+------------+
|Programa  |OmsTrocaTip|Autor  |Microsiga           | Data |  05/04/01  |
+----------+-----------+-------+--------------------+------+------------+
|Desc.     |Troca a marca no filtro de grupos de cargas                 |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

Static Function OmsTrocaTip(nOpcao,aArrayMod,aArrayTipo,oMarked,oNoMarked)
	local ncntfor
	Local lMarca   := .T.
	Local nPosTipo := 0

	If nOpcao == 1
		oObjMark := Iif(aArrayMod[oModelo:nAt,1],.F.,.T. )
		nPosTipo := Ascan(aArrayTipo,{|x| Trim(x[2]) == Trim(aArrayMod[oModelo:nAt,4])})
		If nPosTipo > 0
			aArrayMod[oModelo:nAt,1] := oObjMark
			aArrayTipo[nPosTipo,1]   := oObjMark
		EndIf
	Else
		oObjMark := Iif(aArrayTipo[oTipo:nAt,1] ,.F.,.T. )
		aArrayTipo[oTipo:nAt,1] := oObjMark
		For nCntFor := 1 to Len(aArrayMod)
			If Trim(aArrayMod[nCntFor,4]) == Trim(aArrayTipo[oTipo:nAt,2])
				aArrayMod[nCntFor,1] := oObjMark
			EndIf
		Next
	EndIf
	oModelo:Refresh()
	oTipo:Refresh()
Return

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |DLGABUSCAP|Autor  |Henry Fila          | Data |  01/02/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     |  Monta Pedidos nos arrays para marcacao                    |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros| aArrayCarga - Array  de cargas passado por referencia      |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/
Static Function OmsBuscaPed(oEnable,;
	oDisable,;
	oMarked,;
	oNoMarked,;
	aCampos,;
	cCarga,;
	aArrayCarga,;
	aArrayRota,;
	aArrayZona,;
	aArraySetor,;
	aArrayMod,;
	aArrayTipo,;
	oProcess)
	Local aRegDA7    := {}
	Local cIndSc9    := ""
	Local cCondicao  := ""
	Local cKey       := ""
	Local cCliente   := ""
	Local cLoja      := ""
	Local cQry       := ""
	Local cCodRota   := CriaVar("DA8_COD",.F.)
	Local cDescRota  := CriaVar("DA8_DESC",.F.)
	Local cZona      := CriaVar("DA7_PERCUR",.F.)
	Local cSetor     := CriaVar("DA7_ROTA",.F.)
	Local cSequencia := Space(6)
	Local cCpoPeso   := IIf(Getmv("MV_PESOCAR") == "L","B1_PESO","B1_PESBRU")
	Local cPtoRefDA6 := ""
	Local cPtoRefDA5 := ""
	Local cSeqRota   := ""
	Local cPictVal   := "99999999." + Replicate("9",TamSx3("DAK_VALOR")[2])
	//Local cPictVol   := PesqPict("SB1","B1_YM3")
	Local cPictVol   := PesqPict("DAK","DAK_CAPVOL")
	//Local cPictVol   := "99999999." + Replicate("9",TamSx3("DAK_CAPVOL")[2])
	Local cPictPeso  := "99999999." + Replicate("9",TamSx3("DAK_PESO")[2])
	Local cAlias     := ""
	Local cAliasSB1  := ""
	Local cAliasSC5  := ""
	Local cAliasCli  := ""
	Local cCpoNomCli := ""
	Local cCpoBaiCli := ""
	Local cCpoMunCli := ""
	Local cCpoEstCli := ""
	Local cArq       := ""
	Local cNomInd1   := ""
	Local cNomInd2   := ""
	Local cNomInd3   := ""
	Local cFilBack   := cFilAnt
	Local cSeekSb1   := ""
	Local cRota      := ""

	//Local bWhile     := {||}
	Local lValido    := .F.
	Local lEnable    := .F.
	Local lQuery     := .F.
	Local lLocalEnt  := SC5->(FieldPos("C5_CLIENT"))  > 0
	Local lContinua  := .F.
	Local lLockSC5   := SuperGetMv("MV_CGLOCK",.F.,.F.)

	Local nIndSc9 := 0
	Local nRecno     := 0
	Local nPesoProd  := 0
	Local nPosPedido := 0
	Local nSequencia := 0
	Local nValor     := 0
	Local nCapVol    := 0
	Local nCapArm    := 0
	Local nTipoOper  := OsVlEntCom()

	Local cConsultor := mv_par01 // Consultores a serem considerados
	Local cPedidoDe  := mv_par02
	Local cPedidoAte := mv_par03
	Local cDataDe    := DtoS(mv_par04)
	Local cDataAte   := DtoS(mv_par05)
	Local cLiberSiga := mv_par06 // Liberacao Siga (1=Liberados/2=Bloqueados/3=Todos)
	Local cLiberFin  := mv_par07 // Liberacao Fin  (1=Liberados/2=Bloqueados/3=Todos)
	Local cBloqPed   := mv_par08 // Pedidos Bloqueados (1=Nao/2=Sim/3=Todos)
	Local cTpEntrega := mv_par09 // Integral, parcial ou Todas (1=Nao,2=Sim,3=Todos)
	Local cTpPedido  := mv_par10 // Tipo de Pedido (Asstec, etc)
	Local cRotas     := mv_par11 // Rotas a serem consideradas
	Local cClientes  := mv_par12 // Clientes
	Local cRestric   := mv_par13 // Considera Restrições (1=Sim/2=Não)
	Local cFilialDe  := mv_par14
	Local cFilialAte := mv_par15
	Local lAnEstoque := iif(mv_par16=1,.T.,.F.) // Analisar Estoque (1=Sim/2=Não)
	// os parametros a seguir só serão considerados na query caso o parametro 'lAnEstoque' estiver preenchido com (1)
	Local cClientes2 := mv_par17 // Clientes que não deverão ser considerados para análise de estoque
	Local cClientes3 := mv_par18 // Clientes que não deverão ser considerados para análise de estoque
	Local cClientes4 := mv_par19 // Clientes que não deverão ser considerados para análise de estoque
	Local cClientes5 := mv_par20 // Clientes que não deverão ser considerados para análise de estoque
	Local cClientes6 := mv_par21 // Clientes que não deverão ser considerados para análise de estoque
	Local cArmazens  := mv_par22 // Armazéns que deverão fazer parte da análise de estoque
	Local cDescPed   := mv_par23 // Desconsiderar pedido+item
	Local cAgreg     := mv_par24 // Carga no sistema antigo, para compatibilização com relatórios
	Local cEstoque   := mv_par26
	Local cDtIFatD   := DtoS(mv_par27) // Data Inicial para Liberação para Faturamento De.
	Local cDtIFatA   := DtoS(mv_par28) // Data Inicial para Liberação para Faturamento Até.
	Local cCliGran   := mv_par29       // Filtro para clientes Grandes Sim/Nao
	Local cSegIni    := mv_par30       // Filtro para Segmentos
	Local cSegFim    := mv_par31       // Filtro para Segmentos
	Local cExporta   := mv_par32       // Filtro para clientes Exportacao Sim/Nao
	Local cGrpIni    := mv_par33       // Filtro para Grupo de Clientes
	Local cGrpFim    := mv_par34       // Filtro para Grupo de Clientes
	Local cDuplic    := mv_par35       // Filtro para Duplicata
	Local cLinha     := mv_par36       // Filtro para Linha de venda de produtos

	Local cQrySldAtu := ""
	Local cQrySldAnt := ""

	Private cDescVend:= mv_par24 // Desconsiderar os vendedores
	Private nConsVend:= mv_par25 // (1=Não/2=Sim) Considerar apenas os consultores informados para análise de estoque?

	Private cSA1   := RetSqlName("SA1")
	Private cSB1   := RetSqlName("SB1")
	Private cSB2 	 := RetSqlName("SB2")
	Private cSC5 	 := RetSqlName("SC5")
	Private cSC6 	 := RetSqlName("SC6")
	Private cSC9 	 := RetSqlName("SC9")
	Private cSG1 	 := RetSqlName("SG1")
	Private cDAK 	 := RetSqlName("DAK") 
	Private cDA6 	 := RetSqlName("DA6")
	Private cDA7 	 := RetSqlName("DA7")
	Private cDA9 	 := RetSqlName("DA9")
	Private cSF4 	 := RetSqlName("SF4")
	Private cSC0	 := RetSqlName("SC0")
	//Private cZZ4	 := RetSqlName("ZZ4")

	Private wcUsuario := StrTran(Upper(Alltrim(cUsername))," ","") 

	Pergunte("MOVCAR",.F.)

	aRotasEst := Separa(cRotas,",")
	cTemp := ""
	aRotasEst := aEval(aRotasEst,{|x| cTemp += LEFT(x,2)+","})
	cRotasEst := Left(cTemp,Len(cTemp)-1)
	cRotasEst := FORMATIN(cRotasEst,",")
	cConsultor := fGetItens(cConsultor,06)
	cClientes  := fGetItens(cClientes ,08)
	cRotas     := fGetItens(cRotas    ,06)
	cTpPedido  := fGetItens(cTpPedido ,02)
	cDescPed   := fGetItens(cDescPed  ,08)

	If lAnEstoque
		cClientes2 := fGetItens(cClientes2 ,08)
		cClientes3 := fGetItens(cClientes3 ,08)
		cClientes4 := fGetItens(cClientes4 ,08)
		cClientes5 := fGetItens(cClientes5 ,08)
		cClientes6 := fGetItens(cClientes6 ,08)

		cClientes2 += Iif(!Empty(cClientes3),","+cClientes3," ")+;
		Iif(!Empty(cClientes4),","+cClientes4," ")+;
		Iif(!Empty(cClientes5),","+cClientes5," ")+;
		Iif(!Empty(cClientes6),","+cClientes6," ")

		cArmazens  := fGetItens(cArmazens ,02)
		cDescVend  := fGetItens(cDescVend ,06) // Desconsiderar os vendedores
	EndIf

	// Liberacao Siga (1=Liberados/2=Bloqueados/3=Todos)
	If cLiberSiga = 1
		cLiberSiga := 'S'
	ElseIf cLiberSiga = 2
		cLiberSiga := 'N'
	ElseIf cLiberSiga = 3
		cLiberSiga := 'T'
	EndIf
	// Liberacao Fin  (1=Liberados/2=Bloqueados/3=Todos)
	If cLiberFin = 1
		cLiberFin := 'L'
	ElseIf cLiberFin = 2
		cLiberFin := 'B'
	ElseIf cLiberFin = 3
		cLiberFin := 'T'
	EndIf
	// Tipo de Entrega (1=Parcial/2=Integral/3=Todos)
	If cTpEntrega = 1
		cTpEntrega := 'N'
	ElseIf cTpEntrega = 2
		cTpEntrega := 'S'
	ElseIf cTpEntrega = 3
		cTpEntrega := 'T'
	EndIf
	// Considera Restrições (S=Sim/N=Não)
	If cRestric = 1
		cRestric := 'S'
	ElseIf cRestric = 2
		cRestric := 'N'
	EndIf
	// Liberacao do Pedido (N=Liberados/S=Bloqueados/T=Todos)
	If cBloqPed = 1
		cBloqPed := 'N'
	ElseIf cBloqPed = 2
		cBloqPed := 'S'
	ElseIf cBloqPed = 3
		cBloqPed := 'T'
	EndIf

	//+----------------------------------------+
	//|Crio TRB de Pedidos para uso na MsSelect|
	//+----------------------------------------+
	Os200CriaTrb(@aCampos)

	/*+----------------------------------------------------------------------------------------------------+
	| SELECT DE TODOS OS PEDIDOS QUE SERÃO LISTADOS NA TELA COM BASE NO PREENCHIMENTO DOS PARAMETROS     |
	+----------------------------------------------------------------------------------------------------+*/
	oProcess:IncRegua1("Selecionando pedidos...")
	oProcess:SetRegua1(9)
	cFim := Chr(13)

	If cLiberSiga $ "S/T"
		cQry += " SELECT  C9_FILIAL AS FILIAL,"+cFim
		cQry += "     C9_PRODUTO AS PRODUTO,"+cFim
		cQry += "     C9_CLIENTE AS CLIENTE,"+cFim
		cQry += "     C9_LOJA  AS LOJA, "+cFim
		cQry += "     0 AS QTDVEN,"+cFim
		cQry += "     C9_QTDLIB AS QTDLIB,"+cFim
		cQry += "     C9_PRCVEN AS PRCVEN,"+cFim
		cQry += "     C9_PEDIDO AS PEDIDO,"+cFim
		cQry += "     C9_ENDPAD AS ENDPAD,"+cFim
		cQry += "     ' '       AS BLQPED,"+cFim
		cQry += "     C9_SEQUEN AS SEQUEN,"+cFim
		cQry += "     C9_ITEM  AS ITEM,"+cFim
		//cQry += "     A1_YVLMPED,"+cFim
		//cQry += "     A1_YEXMOST,"+cFim
		//cQry += "     A1_YAGENDA,"+cFim
		//cQry += "     A1_YBLOQ,"+cFim
		//cQry += "     A1_YAGLUT AS AGLUT2,"+cFim
		cQry += "     B1_TIPCAR,"+cFim
		//cQry += "     B1_CAIXAS CAIXAS,"+cFim
		//cQry += "     B1_YPABARR BARR,"+cFim	  //INCLUÍDO POR PANETO EM 04/04/2006
		cQry += "     SC9.R_E_C_N_O_ RECNO,"+cFim
		cQry += "     SC5.C5_LOJAENT,"+cFim
		cQry += "     SC5.C5_TIPO, "+cFim
		cQry += "     SC5.C5_YSUBTP, "+cFim
		//cQry += "     SC5.C5_YENTPAR TPENTR, "+cFim
		cQry += "     SC5.C5_EMISSAO EMISSAO, "+cFim
		cQry += "     SC5.C5_CLIENT, "+cFim
		cQry += "     SC5.R_E_C_N_O_ RECSC5, "+cFim
		cQry += "     SC5.C5_CONDPAG CONDPAG, "+cFim
		//cQry += "     SC5.C5_YCONPG YCONDPG, "+cFim
		cQry += "     SC5.C5_VEND1 VEND,"+cFim
		cQry += "     'SC9' AS ORIGEM, "+cFim

		cQry += " 	 	OBS	= CASE														"+cFim
		cQry += "				WHEN C5_YAPROV = '' THEN '1-BLOQUEIO/PREÇO'				"+cFim
		cQry += "				WHEN													"+cFim
		cQry += " 	 				(SELECT ISNULL(SUM(C9.C9_QTDLIB),0)					"+cFim
		cQry += " 	 				FROM	"+RetSqlName("SC9")+" C9 					"+cFim
		cQry += " 	 				WHERE	C9_FILIAL = '"+xFilial('SC9')+"' AND		"+cFim
		cQry += " 	 						C9.C9_AGREG		<> ''			AND			"+cFim
		cQry += " 	 						C9.C9_NFISCAL	= ''			AND			"+cFim
		cQry += " 	 						C9.C9_BLCRED	= ''			AND 		"+cFim
		cQry += " 	 						C9.C9_PEDIDO	= SC6.C6_NUM		AND			"+cFim
		cQry += " 	 						C9.C9_PRODUTO	= SC6.C6_PRODUTO AND			"+cFim
		cQry += " 	 						C9.C9_ITEM		= SC6.C6_ITEM	AND			"+cFim
		cQry += " 	 						C9.C9_LOTECTL	= SC6.C6_LOTECTL	AND			"+cFim
		cQry += " 	 						C9.D_E_L_E_T_	= '') <> 0		AND			"+cFim
		cQry += " 	 				((SELECT SUM(E1_SALDO) SALDO FROM 					"+cFim
		cQry += " 	 					(SELECT E1_SALDO FROM SE1010  					"+cFim
		cQry += " 	 					WHERE	E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND	"+cFim
		cQry += " 	 							E1_SALDO        > 0					AND "+cFim
		cQry += " 	 							E1_TIPO    NOT IN ('NCC','RA','BOL')		AND "+cFim
		cQry += " 	 							DATEDIFF(D,E1_VENCTO,GETDATE())> A1.RISCO AND "+cFim
		cQry += " 	 							D_E_L_E_T_ = ''							"+cFim
		cQry += " 	 					UNION											"+cFim
		cQry += " 	 					SELECT E1_SALDO FROM SE1050  					"+cFim
		cQry += " 	 					WHERE	E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND	"+cFim
		cQry += " 	 							E1_SALDO        > 0					AND	"+cFim
		cQry += " 	 							E1_TIPO    NOT IN ('NCC','RA','BOL')		AND	"+cFim
		cQry += " 	 							DATEDIFF(D,E1_VENCTO,GETDATE())> A1.RISCO AND "+cFim
		cQry += " 	 							D_E_L_E_T_ = '') SE1)>0)  THEN '3-ROMANEIO/CREDITO' "+cFim
		cQry += " 	 			WHEN	"+cFim
		cQry += " 	 				((SELECT SUM(E1_SALDO) SALDO FROM	"+cFim
		cQry += " 	 					(SELECT E1_SALDO FROM SE1010	"+cFim
		cQry += " 	 					WHERE	E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND	"+cFim
		cQry += " 	 							E1_SALDO        > 0					AND	"+cFim
		cQry += " 	 							E1_TIPO    NOT IN ('NCC','RA','BOL')		AND	"+cFim
		cQry += " 	 							DATEDIFF(D,E1_VENCTO,GETDATE())> A1.RISCO AND "+cFim
		cQry += " 	 							D_E_L_E_T_ = ''							"+cFim
		cQry += " 	 					UNION	"+cFim
		cQry += " 	 					SELECT E1_SALDO FROM SE1050  "+cFim
		cQry += " 	 					WHERE	E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND	"+cFim
		cQry += " 	 							E1_SALDO        > 0					AND	"+cFim
		cQry += " 	 							E1_TIPO    NOT IN ('NCC','RA','BOL')		AND	"+cFim
		cQry += " 	 							DATEDIFF(D,E1_VENCTO,GETDATE())> A1.RISCO AND "+cFim
		cQry += " 	 							D_E_L_E_T_ = '') SE1)>0) THEN '2-CREDITO' "+cFim
		cQry += " 	 			WHEN "+cFim
		cQry += " 	 				(SELECT ISNULL(SUM(C9.C9_QTDLIB),0) FROM "+RetSqlName("SC9")+" C9 "+cFim
		cQry += " 	 				WHERE	C9_FILIAL = '"+xFilial('SC9')+"' AND"+cFim
		cQry += "							C9.C9_AGREG   <> ''					 AND	"+cFim
		cQry += " 	 						C9.C9_NFISCAL = ''				 AND	"+cFim
		cQry += " 	 						C9.C9_BLCRED  = ''				 AND	"+cFim
		cQry += " 	 						C9.C9_PEDIDO  = SC6.C6_NUM		 AND	"+cFim
		cQry += " 	 						C9.C9_PRODUTO = SC6.C6_PRODUTO 	 AND   	"+cFim
		cQry += " 	 						C9.C9_ITEM	  = SC6.C6_ITEM  	 AND	"+cFim
		cQry += " 	 						C9.D_E_L_E_T_ = '') = SC6.C6_QTDVEN THEN '5-ROMANEIO TOTAL'	"+cFim
		cQry += " 	 			WHEN "+cFim
		cQry += "					(SELECT ISNULL(SUM(C9.C9_QTDLIB),9999999999999) FROM "+RetSqlName("SC9")+" C9 		"+cFim
		cQry += " 	 				WHERE	C9_FILIAL = '"+xFilial('SC9')+"' AND	"+cFim
		cQry += "								C9.C9_AGREG 	<> ''			AND		"+cFim
		cQry += " 	 						C9.C9_NFISCAL 	= ''			AND 	"+cFim
		cQry += " 	 						C9.C9_BLCRED  	= ''			AND		"+cFim
		cQry += " 	 						C9.C9_PEDIDO 	= SC6.C6_NUM 	AND		"+cFim
		cQry += " 	 						C9.C9_PRODUTO 	= SC6.C6_PRODUTO AND 	"+cFim
		cQry += " 	 						C9.C9_ITEM	  	= SC6.C6_ITEM  	AND		"+cFim
		cQry += " 	 						C9.D_E_L_E_T_ 	= '')  <= SC6.C6_QTDVEN	THEN '4-ROMANEIO PARCIAL' "+cFim
		cQry += " 	 			ELSE '6-VERIFICAR ESTOQUE' 													"+cFim
		cQry += "		END "+cFim


		cQry += "  FROM "+cSC9+" SC9,"+cSC5+" SC5, "+cSB1+" SB1 ,"+cSA1+" SA1, " +cSC6+" SC6, " +cSF4+ " SF4, "+cFim

		cQry += "		(SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_EST, A1_RISCO, A1_GRPVEN, A1_SATIV1, A1_YVENDB2, A1_YVENDB3, 			"+cFim
		cQry += "				RISCO = CASE															"+cFim
		cQry += "							WHEN A1_RISCO = 'B' THEN "+STR(GETMV('MV_RISCOB'))+" "+cFim
		cQry += "							WHEN A1_RISCO = 'C' THEN "+STR(GETMV('MV_RISCOC'))+" "+cFim
		cQry += "							WHEN A1_RISCO = 'D' THEN "+STR(GETMV('MV_RISCOD'))+" "+cFim
		cQry += "							WHEN A1_RISCO = 'E' THEN 0			"+cFim
		cQry += "							ELSE 999999							"+cFim
		cQry += "						END										"+cFim
		cQry += "		FROM "+RetSqlName("SA1")+"  							"+cFim
		cQry += "   	WHERE A1_FILIAL = '"+xFilial('SA1')+"' AND D_E_L_E_T_ = '' ) A1	"+cFim

		If !Empty(cRotas)
			cQry += ","+cDA7+" DA7, "+cDA9+" DA9, "+cDA6+" DA6 "+cFim 
			//cQry += ","+cDA7+" DA7, "+cDA9+" DA9 "+cFim		
		EndIf
		cQry += "  WHERE SC9.D_E_L_E_T_ = ' ' "+cFim
		If !Empty(cRotas)
			cQry += "  AND DA7_CLIENT = SC9.C9_CLIENTE "+cFim 
			cQry += "  AND DA7_LOJA   = SC9.C9_LOJA "+cFim		
			cQry += "  AND DA7_ROTA   = DA9_ROTA       "+cFim
			cQry += "  AND DA9_ROTEIR IN ("+cRotas+") "+cFim
			cQry += "  AND DA7_ROTA   = DA6_ROTA    "+cFim
			cQry += "  AND DA7_PERCUR = DA6_PERCUR  "+cFim		
			cQry += "  AND DA6_YEST   = SA1.A1_EST "+cFim
			cQry += "  AND DA7_YEST IN "+cRotasEst+cFim
			cQry += "  AND DA7.D_E_L_E_T_ = ' ' "+cFim 
			cQry += "  AND DA9.D_E_L_E_T_ = ' ' "+cFim		 
			cQry += "  AND DA6.D_E_L_E_T_ = ' ' "+cFim				
		EndIf
		cQry += "  AND SC9.C9_CARGA = ' ' "+cFim
		cQry += "  AND SC9.C9_NFISCAL = ' ' "+cFim
		cQry += "  AND SA1.A1_FILIAL = ' ' "+cFim
		cQry += "  AND SA1.A1_COD + SA1.A1_LOJA = SC9.C9_CLIENTE + SC9.C9_LOJA"+cFim
		IF cCliGran = 2
			//cQry += "  AND SA1.A1_YAGENDA <> '1' "+cFim
		EndIF
		cQry += "  AND SA1.D_E_L_E_T_ = ' ' "+cFim
		If cLiberFin <> 'T'
			//cQry += "  AND A1_YBLOQ = '"+cLiberFin+"' "+cFim
		EndIf
		cQry += "  AND SB1.B1_COD = C9_PRODUTO "+cFim
		cQry += "  AND SB1.D_E_L_E_T_ = ' ' "+cFim
		cQry += "  AND SC5.C5_FILIAL = SC9.C9_FILIAL "+cFim
		cQry += "  AND SC5.C5_NUM = SC9.C9_PEDIDO "+cFim

		If !Empty(cTpPedido)
			cQry += "  AND RTRIM(SC5.C5_YSUBTP) IN ("+cTpPedido+")"+cFim
		EndIf
		If cTpEntrega <> 'T'
			//cQry += "  AND SC5.C5_YENTPAR = '"+cTpEntrega+"' "+cFim
		EndIf
		cQry += "  AND SC5.D_E_L_E_T_ = ' ' "+cFim
		If !Empty(cConsultor)
			cQry += "  AND SC5.C5_VEND1     IN ("+cConsultor+") "+cFim
		EndIf
		If !Empty(cDescVend)
			cQry += "  AND SC5.C5_VEND1 NOT IN ("+cDescVend+") "+cFim
		EndIf
		cQry += "  AND C9_PEDIDO BETWEEN '"+cPedidoDe+"' AND '"+cPedidoAte+"'"+cFim
		If !Empty(cDescPed)
			cQry += "  AND C9_PEDIDO + C9_ITEM NOT IN ("+cDescPed+")"+cFim
		EndIf
		cQry += "  AND C5_EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "+cFim
		If !Empty(cClientes)
			cQry += "  AND C9_CLIENTE + C9_LOJA  IN ("+cClientes+") "+cFim
		EndIf
		If !Empty(cClientes2)
			cQry += "  AND C9_CLIENTE + C9_LOJA NOT IN ("+cClientes2+") "+cFim
		EndIf
		cQry += "  AND C9_FILIAL BETWEEN '"+cFilialDe+"' AND '"+cFilialAte+"' "+cFim

		cQry += "  AND SC6.C6_FILIAL = C9_FILIAL "
		cQry += "  AND SC6.C6_NUM    = C9_PEDIDO "
		cQry += "  AND SC6.C6_ITEM   = C9_ITEM "
		cQry += "  AND SC6.D_E_L_E_T_ = ' ' "

		//cQry += "  AND C6_YDTLIB BETWEEN '"+cDtIFatD+"' AND '"+cDtIFatA+"' "+cFim //Coluna Incluída por solicitação do Wanisay - 26/06/2006 - PANETTO

		cQry += "    AND SF4.F4_CODIGO > '500' "+cFim        //INCLUÍDO A PARTE DO SF4 PARA OS PEDIDOS LIBERADOS
		cQry += "    AND SF4.F4_CODIGO = SC6.C6_TES "+cFim
		If cEstoque = 2
			cQry += "    AND SF4.F4_ESTOQUE <> 'N' "+cFim
		End

		//cQry += "		 AND SC5.C5_YLINHA =  '"+cLinha+"' "+cFim
		If cDuplic = 2
			cQry += "    AND SF4.F4_DUPLIC <> 'N' "+cFim
		End
		IF cExporta = 1
			cQry += "	 AND SC5.C5_TIPOCLI = 'X' "+cFim
		ELSEIF cExporta = 2
			cQry += "	 AND SC5.C5_TIPOCLI <> 'X' "+cFim
		ENDIF
		cQry += "	AND SA1.A1_GRPVEN BETWEEN '"+cGrpIni+"' AND '"+cGrpFim+"' "+cFim
		cQry += "	AND SA1.A1_SATIV1 BETWEEN '"+cSegIni+"' AND '"+cSegFim+"' "+cFim
		cQry += "	AND SC6.C6_BLQ		<>	'R'				"+cFim
		cQry += "	AND SB1.B1_TIPO		=	'PA' 			"+cFim
		cQry += "	AND (SC6.C6_QTDVEN - SC6.C6_QTDENT) > 0	"+cFim

		cQry += "    AND SF4.D_E_L_E_T_ = ' ' "
	EndIf

	If cLiberSiga = "T"
		cQry += " UNION "+cFim
	EndIf

	If cLiberSiga $ "N/T"
		cQry += "  SELECT C6_FILIAL AS FILIAL, "+cFim
		cQry += "     C6_PRODUTO AS PRODUTO, "+cFim
		cQry += "     C6_CLI AS CLIENTE, "+cFim
		cQry += "     C6_LOJA AS LOJA, "+cFim
		cQry += "     (C6_QTDVEN - C6_QTDENT) AS QTDVEN, "+cFim
		cQry += "     0 AS QTDLIB, "+cFim
		cQry += "     C6_PRCVEN AS PRCVEN, "+cFim
		cQry += "     C6_NUM AS PEDIDO, "+cFim
		cQry += "     C6_ENDPAD AS ENDPAD, "+cFim
		cQry += "     SUBSTRING(C6_BLQ,1,1) AS BLQPED, "+cFim
		cQry += "     ' ' AS SEQUEN, "+cFim
		cQry += "     C6_ITEM AS ITEM, "+cFim
		//cQry += "     A1_YVLMPED, "+cFim
		//cQry += "     A1_YEXMOST, "+cFim
		//cQry += "     A1_YAGENDA, "+cFim
		//cQry += "     A1_YBLOQ, "+cFim
		//cQry += "     A1_YAGLUT AS AGLUT2,"+cFim
		cQry += "     B1_TIPCAR, "+cFim
		//cQry += "     B1_CAIXAS CAIXAS, "+cFim
		//cQry += "     B1_YPABARR BARR,"+cFim        //INCLUÍDO POR PANETTO EM 04/04/2006
		cQry += "     SC6.R_E_C_N_O_ RECNO, "+cFim
		cQry += "     SC5.C5_LOJAENT, "+cFim
		cQry += "     SC5.C5_TIPO, "+cFim
		cQry += "     SC5.C5_YSUBTP, "+cFim //N="Venda Normal";M="Mostruario";B="Bonificacao";P="Promocao";I="Vinculados";V="Vendor";A="Pagamento Antecipado;T=Astec"
		//cQry += "     SC5.C5_YENTPAR TPENTR, "+cFim
		cQry += "     SC5.C5_EMISSAO EMISSAO, "+cFim
		cQry += "     SC5.C5_CLIENT, "+cFim
		cQry += "     SC5.R_E_C_N_O_ RECSC5,"+cFim
		cQry += "     SC5.C5_CONDPAG CONDPAG,"+cFim
		//cQry += "     SC5.C5_YCONPG YCONDPG, "+cFim
		cQry += "     SC5.C5_VEND1 VEND, "+cFim
		cQry += "     'SC6' AS ORIGEM, "+cFim

		cQry += " 	 	OBS	= CASE														"+cFim
		cQry += "				WHEN C5_YAPROV = '' THEN '1-BLOQUEIO/PREÇO'				"+cFim
		cQry += "				WHEN													"+cFim
		cQry += " 	 				(SELECT ISNULL(SUM(C9.C9_QTDLIB),0)					"+cFim
		cQry += " 	 				FROM	"+RetSqlName("SC9")+" C9 					"+cFim
		cQry += " 	 				WHERE	C9_FILIAL = '"+xFilial('SC9')+"' AND		"+cFim
		cQry += " 	 						C9.C9_AGREG		<> ''			AND			"+cFim
		cQry += " 	 						C9.C9_NFISCAL	= ''			AND			"+cFim
		cQry += " 	 						C9.C9_BLCRED	= ''			AND 		"+cFim
		cQry += " 	 						C9.C9_PEDIDO	= SC6.C6_NUM		AND			"+cFim
		cQry += " 	 						C9.C9_PRODUTO	= SC6.C6_PRODUTO AND			"+cFim
		cQry += " 	 						C9.C9_ITEM		= SC6.C6_ITEM	AND			"+cFim
		cQry += " 	 						C9.C9_LOTECTL	= SC6.C6_LOTECTL	AND			"+cFim
		cQry += " 	 						C9.D_E_L_E_T_	= '') <> 0		AND			"+cFim
		cQry += " 	 				((SELECT SUM(E1_SALDO) SALDO FROM 					"+cFim
		cQry += " 	 					(SELECT E1_SALDO FROM SE1010  					"+cFim
		cQry += " 	 					WHERE	E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND	"+cFim
		cQry += " 	 							E1_SALDO        > 0					AND "+cFim
		cQry += " 	 							E1_TIPO    NOT IN ('NCC','RA','BOL')		AND "+cFim
		cQry += " 	 							DATEDIFF(D,E1_VENCTO,GETDATE())> A1.RISCO AND "+cFim
		cQry += " 	 							D_E_L_E_T_ = ''							"+cFim
		cQry += " 	 					UNION											"+cFim
		cQry += " 	 					SELECT E1_SALDO FROM SE1050  					"+cFim
		cQry += " 	 					WHERE	E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND	"+cFim
		cQry += " 	 							E1_SALDO        > 0					AND	"+cFim
		cQry += " 	 							E1_TIPO    NOT IN ('NCC','RA','BOL')		AND	"+cFim
		cQry += " 	 							DATEDIFF(D,E1_VENCTO,GETDATE())> A1.RISCO AND "+cFim
		cQry += " 	 							D_E_L_E_T_ = '') SE1)>0)  THEN '3-ROMANEIO/CREDITO' "+cFim
		cQry += " 	 			WHEN	"+cFim
		cQry += " 	 				((SELECT SUM(E1_SALDO) SALDO FROM	"+cFim
		cQry += " 	 					(SELECT E1_SALDO FROM SE1010	"+cFim
		cQry += " 	 					WHERE	E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND	"+cFim
		cQry += " 	 				 				E1_SALDO        > 0					AND	"+cFim
		cQry += " 	 							E1_TIPO    NOT IN ('NCC','RA','BOL')		AND	"+cFim
		cQry += " 	 							DATEDIFF(D,E1_VENCTO,GETDATE())> A1.RISCO AND "+cFim
		cQry += " 	 							D_E_L_E_T_ = ''							"+cFim
		cQry += " 	 					UNION	"+cFim
		cQry += " 	 					SELECT E1_SALDO FROM SE1050  "+cFim
		cQry += " 	 					WHERE	E1_FILIAL = '"+xFilial('SE1')+"' AND E1_CLIENTE = SC5.C5_CLIENTE AND E1_LOJA = SC5.C5_LOJACLI AND	"+cFim
		cQry += " 	 							E1_SALDO        > 0					AND	"+cFim
		cQry += " 	 							E1_TIPO    NOT IN ('NCC','RA','BOL')		AND	"+cFim
		cQry += " 	 							DATEDIFF(D,E1_VENCTO,GETDATE())> A1.RISCO AND "+cFim
		cQry += " 	 							D_E_L_E_T_ = '') SE1)>0) THEN '2-CREDITO' "+cFim
		cQry += " 	 			WHEN "+cFim
		cQry += " 	 				(SELECT ISNULL(SUM(C9.C9_QTDLIB),0) FROM "+RetSqlName("SC9")+" C9 "+cFim
		cQry += " 	 				WHERE	C9_FILIAL = '"+xFilial('SC9')+"' AND"+cFim
		cQry += "							C9.C9_AGREG   <> ''					 AND	"+cFim
		cQry += " 	 						C9.C9_NFISCAL = ''				 AND	"+cFim
		cQry += " 	 						C9.C9_BLCRED  = ''				 AND	"+cFim
		cQry += " 	 						C9.C9_PEDIDO  = SC6.C6_NUM		 AND	"+cFim
		cQry += " 	 						C9.C9_PRODUTO = SC6.C6_PRODUTO 	 AND   	"+cFim
		cQry += " 	 						C9.C9_ITEM	  = SC6.C6_ITEM  	 AND	"+cFim
		cQry += " 	 						C9.D_E_L_E_T_ = '') = SC6.C6_QTDVEN THEN '5-ROMANEIO TOTAL'	"+cFim
		cQry += " 	 			WHEN "+cFim
		cQry += "					(SELECT ISNULL(SUM(C9.C9_QTDLIB),9999999999999) FROM "+RetSqlName("SC9")+" C9 		"+cFim
		cQry += " 	 				WHERE	C9_FILIAL = '"+xFilial('SC9')+"' AND	"+cFim
		cQry += "								C9.C9_AGREG 	<> ''			AND		"+cFim
		cQry += " 	 						C9.C9_NFISCAL 	= ''			AND 	"+cFim
		cQry += " 	 						C9.C9_BLCRED  	= ''			AND		"+cFim
		cQry += " 	 						C9.C9_PEDIDO 	= SC6.C6_NUM 	AND		"+cFim
		cQry += " 	 						C9.C9_PRODUTO 	= SC6.C6_PRODUTO AND 	"+cFim
		cQry += " 	 						C9.C9_ITEM	  	= SC6.C6_ITEM  	AND		"+cFim
		cQry += " 	 						C9.D_E_L_E_T_ 	= '')  <= SC6.C6_QTDVEN	THEN '4-ROMANEIO PARCIAL' "+cFim
		cQry += " 	 			ELSE '6-VERIFICAR ESTOQUE' 													"+cFim
		cQry += "		END "+cFim

		cQry += "  FROM "+cSC6+" SC6, "+cSC5+" SC5, "+cSB1+" SB1 ,"+cSA1+" SA1 ,"+cSF4+" SF4, "+cFim


		cQry += "		(SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_MUN, A1_EST, A1_RISCO, A1_GRPVEN, A1_SATIV1, A1_YVENDB2, A1_YVENDB3, 			"+cFim
		cQry += "				RISCO = CASE															"+cFim
		cQry += "							WHEN A1_RISCO = 'B' THEN "+STR(GETMV('MV_RISCOB'))+" "+cFim
		cQry += "							WHEN A1_RISCO = 'C' THEN "+STR(GETMV('MV_RISCOC'))+" "+cFim
		cQry += "							WHEN A1_RISCO = 'D' THEN "+STR(GETMV('MV_RISCOD'))+" "+cFim
		cQry += "							WHEN A1_RISCO = 'E' THEN 0			"+cFim
		cQry += "							ELSE 999999							"+cFim
		cQry += "						END										"+cFim
		cQry += "		FROM "+RetSqlName("SA1")+"  							"+cFim
		cQry += "   	WHERE A1_FILIAL = '"+xFilial('SA1')+"' AND D_E_L_E_T_ = '' ) A1	"+cFim

		If !Empty(cRotas)
			cQry += ","+cDA7+" DA7, "+cDA9+" DA9, "+cDA6+" DA6 "+cFim
			//cQry += ","+cDA7+" DA7, "+cDA9+" DA9 "+cFim				
		EndIf
		cQry += "  WHERE SC6.D_E_L_E_T_ = ' ' "+cFim
		If !Empty(cRotas)
			cQry += "  AND DA7_CLIENT = SC6.C6_CLI "+cFim 
			cQry += "  AND DA7_LOJA   = SC6.C6_LOJA "+cFim		
			cQry += "  AND DA7_ROTA   = DA9_ROTA "+cFim
			cQry += "  AND DA9_ROTEIR IN ("+cRotas+")"+cFim
			cQry += "  AND DA7_ROTA   = DA6_ROTA "+cFim
			cQry += "  AND DA7_PERCUR = DA6_PERCUR "+cFim		
			cQry += "  AND DA6_YEST   = SA1.A1_EST "+cFim				
			cQry += "  AND DA7_YEST IN "+cRotasEst+cFim
			cQry += "  AND DA7.D_E_L_E_T_ = ' ' "+cFim 
			cQry += "  AND DA9.D_E_L_E_T_ = ' ' "+cFim		
			cQry += "  AND DA6.D_E_L_E_T_ = ' ' "+cFim				
		EndIf
		cQry += "  AND C6_QTDVEN > (SELECT ISNULL(SUM(SC9.C9_QTDLIB),0) "+cFim
		cQry += "                  FROM "+cSC9+" SC9 "+cFim
		cQry += "                  WHERE SC9.C9_PEDIDO = SC6.C6_NUM "+cFim
		cQry += "                  AND SC9.C9_ITEM = SC6.C6_ITEM "+cFim
		cQry += "                  AND SC9.D_E_L_E_T_ = ' ') "+cFim

		cQry += "  AND SA1.A1_COD + SA1.A1_LOJA = SC6.C6_CLI + SC6.C6_LOJA"+cFim
		cQry += "  AND SA1.A1_FILIAL = ' ' "+cFim
		cQry += "  AND SA1.D_E_L_E_T_ = ' '"+cFim
		If cLiberFin <> 'T'
			//cQry += "  AND A1_YBLOQ = '"+cLiberFin+"' "+cFim
		EndIf
		IF cCliGran = 2
			//cQry += "  AND SA1.A1_YAGENDA <> '1' "+cFim
		EndIF
		cQry += "  AND SB1.B1_COD = SC6.C6_PRODUTO "+cFim
		cQry += "  AND SB1.D_E_L_E_T_ = ' ' "+cFim
		cQry += "  AND SC5.C5_FILIAL = SC6.C6_FILIAL "+cFim
		cQry += "  AND SC5.C5_NUM = C6_NUM "+cFim
		If !Empty(cTpPedido)
			cQry += "  AND RTRIM(SC5.C5_YSUBTP) IN ("+cTpPedido+")"+cFim
		EndIf
		If cTpEntrega <> 'T'
			//cQry += "  AND SC5.C5_YENTPAR = '"+cTpEntrega+"' "+cFim
		EndIf
		cQry += "  AND SC5.D_E_L_E_T_ = ' ' "+cFim
		cQry += "  AND (SC6.C6_QTDVEN - SC6.C6_QTDENT) > 0 "+cFim
		If cBloqPed <> 'T'
			If cBloqPed == 'N'
				cQry += " AND SC6.C6_BLQ IN ('N',' ') "+cFim
			Else
				cQry += " AND SC6.C6_BLQ = 'S' "+cFim
			EndIf
		EndIf
		cQry += " AND SC6.C6_BLQ <> 'R' "+cFim
		If !Empty(cConsultor)
			cQry += "  AND SC5.C5_VEND1 IN ("+cConsultor+") "+cFim
		EndIf
		If !Empty(cDescVend)
			cQry += "  AND SC5.C5_VEND1 NOT IN ("+cDescVend+") "+cFim
		EndIf
		cQry += "  AND C6_NUM BETWEEN '"+cPedidoDe+"' AND '"+cPedidoAte+"' "+cFim
		If !Empty(cDescPed)
			cQry += "  AND C6_NUM + C6_ITEM NOT IN ("+cDescPed+") "+cFim
		EndIf
		cQry += "  AND C5_EMISSAO BETWEEN '"+cDataDe+"' AND '"+cDataAte+"' "+cFim
		If !Empty(cClientes)
			cQry += "  AND C5_CLIENTE + C5_LOJACLI IN ("+cClientes+") "+cFim
		EndIf
		If !Empty(cClientes2)
			cQry += "  AND C5_CLIENTE + C5_LOJACLI NOT IN ("+cClientes2+") "+cFim
		EndIf
		cQry += "  AND C6_FILIAL BETWEEN '"+cFilialDe+"' AND '"+cFilialAte+"' "+cFim
		cQry += "    AND SF4.F4_CODIGO > '500' "+cFim
		cQry += "    AND SF4.F4_CODIGO = SC6.C6_TES "+cFim
		If cEstoque = 2
			cQry += "    AND SF4.F4_ESTOQUE <> 'N' "+cFim
		End

		//cQry += "		 AND SC5.C5_YLINHA =  '"+cLinha+"' "+cFim
		If cDuplic = 2
			cQry += "    AND SF4.F4_DUPLIC <> 'N' "+cFim
		End
		IF cExporta = 1
			cQry += "	 AND SC5.C5_TIPOCLI = 'X' "+cFim
		ELSEIF cExporta = 2
			cQry += "	 AND SC5.C5_TIPOCLI <> 'X' "+cFim
		ENDIF
		cQry += "	AND SA1.A1_GRPVEN BETWEEN '"+cGrpIni+"' AND '"+cGrpFim+"' "+cFim
		cQry += "	AND SA1.A1_SATIV1 BETWEEN '"+cSegIni+"' AND '"+cSegFim+"' "+cFim
		cQry += "	AND SC6.C6_BLQ		<>	'R'				"+cFim
		cQry += "	AND SB1.B1_TIPO		=	'PA' 			"+cFim
		cQry += "    AND SF4.D_E_L_E_T_ = ' ' "

		//cQry += "  AND C6_YDTLIB BETWEEN '"+cDtIFatD+"' AND '"+cDtIFatA+"' "+cFim //Coluna Incluída por solicitação do Wanisay - 26/06/2006
	EndIf

	memowrite("\qry.txt",cQry)

	If !TCCanOpen("PED_TELA_"+wcUsuario)
		TcSqlExec("INSERT * INTO PED_TELA_"+wcUsuario+" FROM ("+cQry+")")
		//TcSqlExec("COMMIT")
	Else
		TcSqlExec("DELETE FROM PED_TELA_"+wcUsuario)
		//TcSqlExec("COMMIT")
		TcSqlExec("DELETE FROM PED_TELA_"+wcUsuario)
		//TcSqlExec("COMMIT")
		//cCampos := "FILIAL, PRODUTO, CLIENTE, LOJA, QTDVEN, QTDLIB, PRCVEN, PEDIDO, ENDPAD, BLQPED, SEQUEN, ITEM, A1_YVLMPED, A1_YEXMOST, A1_YAGENDA,"
		//cCampos += "A1_YBLOQ, AGLUT2, B1_TIPCAR, CAIXAS, RECNO, C5_LOJAENT, C5_TIPO, C5_YSUBTP, TPENTR, EMISSAO, C5_CLIENT, RECSC5, CONDPAG, YCONDPG, VEND, ORIGEM "
		cCampos := "FILIAL, PRODUTO, CLIENTE, LOJA, QTDVEN, QTDLIB, PRCVEN, PEDIDO, ENDPAD, BLQPED, SEQUEN, ITEM, "
		cCampos += "AGLUT2, B1_TIPCAR, CAIXAS, RECNO, C5_LOJAENT, C5_TIPO, TPENTR, EMISSAO, C5_CLIENT, RECSC5, CONDPAG, YCONDPG, VEND, ORIGEM "
		cQryXyz := "INSERT INTO PED_TELA_"+wcUsuario+ " ("+cCampos+") "+cQry
		TcSqlExec(cQryXyz)
		//TcSqlExec("COMMIT")
	EndIf

	cQryXyz := "SELECT * FROM PED_TELA_"+wcUsuario+ " ORDER BY CLIENTE, LOJA, PEDIDO, ITEM"
	cQryXyz := ChangeQuery(cQryXyz)

	//dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryXyz),"TRBSC9",.F.,.T.)
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"TRBSC9",.F.,.T.)
	lQuery := .T.
	cAlias    := "TRBSC9"
	cAliasSB1 := "TRBSC9"
	cAliasSC5 := "TRBSC9"

	/*+----------------------------------------------------------------------------------------------------+
	| SELECT DE TODOS OS PRODUTOS DOS PEDIDOS LISTADOS NA TELA COM OS SALDOS ATUAIS DOS PA´S E DOS PI´S. |
	+----------------------------------------------------------------------------------------------------+*/
	If lAnEstoque
		oProcess:IncRegua1("Iniciando análise de estoque...")

		cQrySldAtu += "	SELECT 	TAB.PRODUTO AS COD_PA,  ' ' AS COD_PI,  0 AS QUANT,
		cQrySldAtu += "  (SELECT ISNULL(SUM(B2.B2_QATU),0) - ISNULL(SUM(B2.B2_RESERVA),0)
		cQrySldAtu += "  FROM "+cSB2+" B2  "+cFim
		cQrySldAtu += "  WHERE B2.B2_FILIAL = '"+xFilial("SB2")+"' "+cFim
		If !Empty(cArmazens)
			cQrySldAtu += " AND B2.B2_LOCAL IN ("+cArmazens+")"+cFim
		EndIf
		cQrySldAtu += " AND B2.B2_COD = TAB.PRODUTO
		cQrySldAtu += " AND B2.D_E_L_E_T_ = ' ') AS SALDO_PROD

		cQrySldAtu += " FROM (SELECT TAB.PRODUTO FROM (SELECT DISTINCT (PRODUTO) PRODUTO FROM PED_TELA_"+wcUsuario+") TAB) TAB

		memowrite('qrysldatu1.txt',cQrySldAtu) //zago 14.04.06
		If ChkFile("QRYSLDATU",.F.)
			QRYSLDATU->(DbCloseArea())
		EndIf
		cQrySldAtu := ChangeQuery(memoread('qrysldatu1.txt'))
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,memoread('qrysldatu1.txt')),"QRYSLDATU",.F.,.T.)

		aCpos := {}

		aAdd(aCpos,{"COD_PA"      ,"C",15,0})
		aAdd(aCpos,{"COD_PI"      ,"C",15,0})
		aAdd(aCpos,{"QUANT"       ,"N",14,2})
		aAdd(aCpos,{"SALDO_PROD"  ,"N",14,2})

		cAliasSld := "TRBSALDOS"
		cArqSLD := CriaTrab(aCpos,.T.)
		DbUseArea(.T.,,cArqSLD,cAliasSld,.F.)

		While !QRYSLDATU->(Eof())
			RecLock("TRBSALDOS",.T.)
			TRBSALDOS->COD_PA     := QRYSLDATU->COD_PA
			TRBSALDOS->COD_PI     := QRYSLDATU->COD_PI
			TRBSALDOS->QUANT      := QRYSLDATU->QUANT
			TRBSALDOS->SALDO_PROD := QRYSLDATU->SALDO_PROD
			TRBSALDOS->(MsUnlock())
			QRYSLDATU->(DbSkip())
		EndDo

		DbSelectArea("TRBSALDOS")
		cInd1 := "TRBSLDA"+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7)
		IndRegua("TRBSALDOS",cInd1,"COD_PA+COD_PI")

		cInd2 := "TRBSLDA2"+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7)
		IndRegua("TRBSALDOS",cInd2,"COD_PI")
		dbClearIndex()
		DbSetIndex(cInd1+OrdBagExt())
		DbSetIndex(cInd2+OrdBagExt())

		oProcess:IncRegua1("Obtendo saldo atual...")
		/*+------------------------------------------------------------------------------------------------------+
		| DEVE-SE ABATER DO SALDO ATUAL, O SALDO ANTERIOR AO PRIMEIRO PEDIDO NA TELA                           |
		+------------------------------------------------------------------------------------------------------+*/
		cQryMin := "SELECT MIN(PEDIDO) PRIMEIRO FROM PED_TELA_"+wcUsuario
		TcQuery cQryMin New Alias "QRYMIN"
		cPrimeiro := QRYMIN->PRIMEIRO

		// Dedução do saldo anterior
		//fSldAnt(cPrimeiro,cClientes2,wcUsuario,cConsultor)
		//oProcess:IncRegua1("Calculando reservas...")
		// Dedução da reserva
		//fReserva2(cClientes22, wcUsuario)
		//oProcess:IncRegua1("Apurando cargas não faturadas...")
		//Dedução dos pedidos liberados fora de cargas
		//fPedLib(wcUsuario)
		//Dedução da Carga não faturada
		//fCarga(wcUsuario)
		//Dedução dos Pedidos na tela de outros usuários
		//fPedTela(wcUsuario)

		QRYMIN->(DbCloseArea())
		oProcess:IncRegua1("Calculando saldo anterior...")
		/*+------------------------------------------------------------------------------------------------------+
		| SELECT DO PRIMEIRO E ULTIMO PEDIDOS NA TELA PARA CALCULO DO SALDO ANTERIOR PARA CADA PEDIDO NA FAIXA |
		+------------------------------------------------------------------------------------------------------+*/
		cQryLim := " SELECT MIN(PEDIDO) LIMINF, MAX(PEDIDO) LIMSUP FROM PED_TELA_"+wcUsuario

		cQryLim := ChangeQuery(cQryLim)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryLim),"QRYLIM",.F.,.T.)

		cLimInf := QRYLIM->LIMINF
		cLimSup := QRYLIM->LIMSUP

		/*+------------------------------------------------------------------------------------------------------+
		| SELECT DE TODOS OS PEDIDOS QUE ESTÃO NA FAIXA ENTRE O MENOR E O MAIOR PEDIDO NA TELA, EM CARTEIRA,   |
		| DESCONSIDERANDO OS FILTROS DO USUARIO                                                                |
		+------------------------------------------------------------------------------------------------------+*/
		oProcess:IncRegua1("Analisando pedidos em carteira...")

		cQry :="  SELECT C6_FILIAL AS FILIAL, "+cFim
		cQry +="     C6_PRODUTO AS PRODUTO, "+cFim
		cQry +="     (C6_QTDVEN - C6_QTDENT) AS QTDVEN, "+cFim
		cQry +="     C6_NUM AS PEDIDO, "+cFim
		cQry +="     C6_ITEM AS ITEM, "	+cFim
		cQry +="     SC6.R_E_C_N_O_ RECNO "+cFim
		cQry +="  FROM "+cSC6+" SC6 "+cFim
		cQry +="  INNER JOIN "+cSC5+" SC5 "+cFim
		cQry +="          ON C5_NUM = C6_NUM "+cFim
		cQry +="  WHERE SC6.D_E_L_E_T_ = ' ' "+cFim
		cQry +="    AND C6_NUM BETWEEN '"+cLimInf+"' AND '"+cLimSup+"'"+cFim
		cQry +="    AND (C6_QTDVEN - SC6.C6_QTDENT) > 0 "+cFim
		cQry +="    AND SC6.C6_BLQ <> 'R' "+cFim
		If !Empty(cClientes2)
			cQry +="  AND C6_CLI + C6_LOJA NOT IN ("+cClientes2+") "+cFim
		EndIf
		If !Empty(cDescVend)
			cQry +="    AND C5_VEND1 NOT IN ("+cDescVend+") "+cFim
		EndIf
		If !Empty(cConsultor)
			cQry +="  AND C5_VEND1 IN ("+cConsultor+") "+cFim
		EndIf
		cQry +="  ORDER BY PEDIDO"

		cQuery := ChangeQuery(cQry)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"QRYCART",.F.,.T.)

		QRYLIM->(DbCloseArea())
	EndIf
	DbSelectArea(cAlias)

	/*+---------------------------------------------------------------------+
	|Montagem do arquivo temporario de pedidos                            |
	+---------------------------------------------------------------------+*/
	cCliente := ""
	cLoja    := ""
	DbSelectarea(cAlias)
	oProcess:SetRegua1(LastRec())
	DbgoTop() //IndRegua
	While !Eof()
		oProcess:IncRegua1("Selecionando pedidos filtrados") // Selecionando Registros...
		lContinua := .T.
		/*+---------------------------------------------------------------------+
		|Selecao dos registros                                                |
		+---------------------------------------------------------------------+*/
		/*+---------------------------------------------------------------------+
		|Verifica se o SC9 eh valido para este ponto de entrada               |
		+---------------------------------------------------------------------+*/
		If ExistBlock("OM200VLD")
			If !ExecBlock("OM200VLD",.F.,.F.)
				lContinua := .F.
			EndIf
		EndIf
		/*+---------------------------------------------------------------------+
		| Posiciona Registros                                                 |
		+---------------------------------------------------------------------+*/

		If lQuery
			SC5->(MsGoto((cAlias)->RECSC5))
		Else
			SB1->(dbSetOrder(1))
			//SB1->(MsSeek(OsFilial("SB1",(cAlias)->C9_FILIAL)+(cAlias)->C9_PRODUTO))
			SB1->(MsSeek(xFilial("SB1")+(cAlias)->C9_PRODUTO))

			SC5->(dbSetOrder(1))
			//SC5->(MsSeek(OsFilial("SC5",(cAlias)->C9_FILIAL)+(cAlias)->C9_PEDIDO))
			SC5->(MsSeek(xFilial("SC5")+(cAlias)->C9_PEDIDO))
		EndIf
		/*+---------------------------------------------------------------------+
		| Filtra os pedidos para entrega futura - Localizacoes                |
		+---------------------------------------------------------------------+*/
		If cPaisLoc <> 'BRA'.And. !lQuery
			If SC5->C5_DOCGER == '3'
				lContinua := .F.
			EndIf
		EndIf
		/*+---------------------------------------------------------------------+
		| Verifica os tipo de carga                                           |
		+---------------------------------------------------------------------+*/
		nPosModelo := Ascan(aArrayMod,{|x| Trim(x[2]) == (cAliasSB1)->B1_TIPCAR})
		If nPosModelo > 0
			If !aArrayMod[nPosModelo,1]
				lContinua := .F.
			EndIf
		EndIf
		If lLockSC5
			If !SoftLock("SC5")
				Exit
			Endif
		Endif

		If ExistBlock("OM200TPC")
			lContinua := ExecBlock("OM200TPC",.F.,.F.,{(cAlias)->C9_PRODUTO,(cAliasSB1)->B1_TIPCAR})
		Endif

		If lContinua
			/*+---------------------------------------------------------------------+
			| Verifica os tipo de pedido e o codigo/loja do cliente/fornecedor    |
			+---------------------------------------------------------------------+*/
			cCliente   := Iif(lLocalEnt.And.!Empty((cAliasSC5)->C5_CLIENT), (cAliasSC5)->C5_CLIENT ,(cAlias)->CLIENTE)
			cLoja      := Iif(lLocalEnt.And.!Empty((cAliasSC5)->C5_LOJAENT), (cAliasSC5)->C5_LOJAENT,(cAlias)->LOJA   )
			cAliasCli  := Iif( (cAliasSC5)->C5_TIPO $ "BD", "SA2","SA1")
			cCpoNomCli := Iif( (cAliasSC5)->C5_TIPO $ "BD", "A2_NOME","A1_NOME")
			cCpoBaiCli := Iif( (cAliasSC5)->C5_TIPO $ "BD", "A2_BAIRRO","A1_BAIRRO")
			cCpoMunCli := Iif( (cAliasSC5)->C5_TIPO $ "BD", "A2_MUN","A1_MUN")
			cCpoEstCli := Iif( (cAliasSC5)->C5_TIPO $ "BD", "A2_EST","A1_EST")
			/*+---------------------------------------------------------------------+
			| Verifica o codigo de referencia para o operador logistico           |
			+---------------------------------------------------------------------+*/
			If nTipoOper == 3
				DCK->(dbSetOrder(2))
				If DCK->(MsSeek(xFilial("DCK")+(cAlias)->C9_CLIENTE+(cAlias)->C9_LOJA)) .And. (cAlias)->C9_FILIAL != cFilAnt
					cCliente := DCK->DCK_CODOPL
					cLoja    := DCK->DCK_LOJOPL
				EndIf
			EndIf
			/*+-------------------------------------------------------+
			|Garanto a intergridade do pedido no momento da montagem|
			|de carga com SoftLock                                  |
			+-------------------------------------------------------+*/
			If ( lQuery )
				DbSelectArea("SC9")
				DbGoto((cAlias)->RECNO)
			EndIf
			/*+---------------------------------------------------------------------+
			| Inicializa as variaveis                                             |
			+---------------------------------------------------------------------+*/
			nPesoProd  := 0
			cCodRota   := Space(Len(DA8->DA8_COD))
			cDescRota  := OemToAnsi(STR0042) //"PEDIDOS SEM ROTA"
			cZona      := Space(Len(DA7->DA7_PERCUR))
			cSetor     := Space(Len(DA7->DA7_ROTA))
			cSeqRota   := Space(Len(DA9->DA9_SEQUEN))
			cSequencia := Space(Len(DA7->DA7_SEQUEN))
			lValido    := .T.
			lEnable    := .T.
			/*+---------------------------------------------------------------------+
			| Pesquisa o cliente/fornecedor em clientes por setor                 |
			+---------------------------------------------------------------------+*/
			dbSelectArea("DA7")

			//aRegDA7      := OmsHasDA7((cAlias)->FILIAL,cCliente,cLoja)
			aRegDA7      := OmsHasDA7(xFilial("DA7"),cCliente,cLoja)   //ALTERADO POR PANETTO 16/03/2006 - MOTIVO: Compartilhamento das talebas SC5, SC6, SC9
			cSA4_END     := ''
			//cSA4_YBAIRRO :=  ''
			cSA4_MUN     := ''
			cSA4_CEP     := ''
			cSA4_EST     := ''
			If ExistBlock("OM200DA7")
				//aRegDA7 := ExecBlock("OM200DA7",.F.,.F.,{(cAlias)->FILIAL,cCliente,cLoja,(cAlias)->PEDIDO,aRegDA7})
				aRegDA7 := ExecBlock("OM200DA7",.F.,.F.,{xFilial("DA7"),cCliente,cLoja,(cAlias)->PEDIDO,aRegDA7})//ALTERADO POR PANETTO 16/03/2006 - MOTIVO: Compartilhamento das talebas SC5, SC6, SC9
			Endif

			If Len(aRegDA7) > 0
				//Bloco referente aos dados da Transportadora incluido por Panetto
				//cQry := "  SELECT A4.A4_END, A4_YBAIRRO, A4_MUN, A4_CEP, A4_EST "+cFim
				cQry := "  SELECT A4.A4_END, A4_MUN, A4_CEP, A4_EST "+cFim
				cQry += "    FROM "+RetSqlName("SA4")+" A4 INNER JOIN "+RetSqlName("SC5")+" SC5 "+cFim
				cQry += "                   ON  SC5.C5_REDESP = A4.A4_COD "+cFim
				cQry += "                   AND SC5.C5_NUM = '"+(cAlias)->PEDIDO+"' "+cFim
				cQry += "                   AND SC5.D_E_L_E_T_ = ' ' "+cFim
				cQry += "  WHERE A4.D_E_L_E_T_ = ' ' "

				TcQuery cQry New Alias "cSA4"
				dbselectarea("cSA4")
				cSA4_END     := cSA4->A4_END
				//cSA4_YBAIRRO := cSA4->A4_YBAIRRO
				cSA4_MUN     := cSA4->A4_MUN
				cSA4_EST     := cSA4->A4_EST
				cSA4->(DbCloseArea())
				// Fim do bloco incluido
				DA7->(MsGoto(aRegDA7[1]))
				cZona      := DA7->DA7_PERCUR
				cSetor     := DA7->DA7_ROTA
				cSequencia := DA7->DA7_SEQUEN
				/*+---------------------------------------------------------------------+
				| Pesquisa o cliente/fornecedor na zona/setor                         |
				+---------------------------------------------------------------------+*/
				DA9->(dbSetOrder(2))
				If DA9->(MsSeek(xFilial("DA9")+cZona+cSetor))
					/*+---------------------------------------------------------------------+
					| Verifica se busca a primeira rota ativa                             |
					+---------------------------------------------------------------------+*/
					If SuperGetMv("MV_ROTATV",.F.,"2") == "2"
						/*+---------------------------------------------------------------------+
						| Pesquisa a Rota                                                     |
						+---------------------------------------------------------------------+*/
						DA8->(dbSetOrder(1))
						If DA8->(MsSeek(xFilial("DA8")+DA9->DA9_ROTEIR))
							cCodRota := DA8->DA8_COD
							cDescRota:= DA8->DA8_DESC
							cSeqRota := DA9->DA9_SEQUEN
							/*+---------------------------------------------------------------------+
							| Verifica os tipo de carga da rota se esta incluido                  |
							+---------------------------------------------------------------------+*/
							If DA8->(FieldPos("DA8_TIPCAR")) > 0 .And. !Empty(DA8->DA8_TIPCAR)
								nPosModelo := Ascan(aArrayTipo,{|x| Trim(x[2]) == DA8->DA8_TIPCAR})
								If nPosModelo > 0
									If !aArrayTipo[nPosModelo,1]
										lValido := .F.
									EndIf
								EndIf
							EndIf
						Else
							cCodRota   := Repl("9",Len(DA8->DA8_COD))
							cDescRota  := OemToAnsi(STR0042) //"PEDIDOS SEM ROTA"
							cZona      := Repl("9",Len(DA7->DA7_PERCUR))
							cSetor     := Repl("9",Len(DA7->DA7_ROTA))
							cSeqRota   := Repl("9",Len(DA9->DA9_SEQUEN))
							cSequencia := Repl("9",Len(DA7->DA7_SEQUEN))
						EndIf
					Else
						While DA9->(!Eof()) .And. DA9->DA9_FILIAL  == xFilial("DA9") .And.;
						DA9->DA9_PERCUR == cZona .And.;
						DA9->DA9_ROTA   == cSetor
							/*+---------------------------------------------------------------------+
							| Pesquisa a Rota                                                     |
							+---------------------------------------------------------------------+*/
							DA8->(dbSetOrder(1))
							If DA8->(MsSeek(xFilial("DA8")+DA9->DA9_ROTEIR))
								If DA8->DA8_ATIVO == "1"
									cCodRota := DA8->DA8_COD
									cDescRota:= DA8->DA8_DESC
									cSeqRota := DA9->DA9_SEQUEN
									//+---------------------------------------------------------------------+
									//| Verifica os tipo de carga da rota se esta incluido                  |
									//+---------------------------------------------------------------------+
									If DA8->(FieldPos("DA8_TIPCAR")) > 0 .And. !Empty(DA8->DA8_TIPCAR)
										nPosModelo := Ascan(aArrayTipo,{|x| Trim(x[2]) == DA8->DA8_TIPCAR})
										If nPosModelo > 0
											If !aArrayTipo[nPosModelo,1]
												lValido := .F.
											EndIf
										EndIf
									EndIf
									Exit
								Endif
							Else
								cCodRota   := Repl("9",Len(DA8->DA8_COD))
								cDescRota  := OemToAnsi(STR0042) //"PEDIDOS SEM ROTA"
								cZona      := Repl("9",Len(DA7->DA7_PERCUR))
								cSetor     := Repl("9",Len(DA7->DA7_ROTA))
								cSeqRota   := Repl("9",Len(DA9->DA9_SEQUEN))
								cSequencia := Repl("9",Len(DA7->DA7_SEQUEN))
								Exit
							EndIf
							DA9->(DbSkip())
						EndDo
					Endif
				Else
					cCodRota   := Repl("9",Len(DA8->DA8_COD))
					cDescRota  := OemToAnsi(STR0042) //"PEDIDOS SEM ROTA"
					cZona      := Repl("9",Len(DA7->DA7_PERCUR))
					cSetor     := Repl("9",Len(DA7->DA7_ROTA))
					cSeqRota   := Repl("9",Len(DA9->DA9_SEQUEN))
					cSequencia := Repl("9",Len(DA7->DA7_SEQUEN))
					lEnable    := .T.
					lValido    := .T.
				EndIf
				/*+---------------------------------------------------------------------+
				| Pesquisa os Setores por Zona                                        |
				+---------------------------------------------------------------------+*/
				DbSelectarea("DA6")
				DbSetOrder(1)
				If MsSeek(xFilial("DA6")+cZona+cSetor)
					//cPtoRefDA6 := DA6->DA6_YDESC
					cPtoRefDA6 := DA6->DA6_REF
					/*+---------------------------------------------------------------------+
					| Pesquisa as Zonas                                                   |
					+---------------------------------------------------------------------+*/
					DbSelectArea("DA5")
					DbSetOrder(1)
					If MsSeek(xFilial("DA5")+DA6->DA6_PERCUR)
						cPtoRefDA5 := DA5->DA5_DESC
					Else
						cPtoRefDA5 := ""
					EndIf
				Else
					cCodRota   := Repl("9",Len(DA8->DA8_COD))
					cDescRota  := OemToAnsi(STR0042) //"PEDIDOS SEM ROTA"
					cZona      := Repl("9",Len(DA7->DA7_PERCUR))
					cSetor     := Repl("9",Len(DA7->DA7_ROTA))
					cSeqRota   := Repl("9",Len(DA9->DA9_SEQUEN))
					cSequencia := Repl("9",Len(DA7->DA7_SEQUEN))
					cPtoRefDA5 := ""
					cPtoRefDA6 := ""
				EndIf
				If Ascan(aArrayRota,{|x| x[3] == cCodRota}) == 0 .And. lValido
					aAdd( aArrayRota  , { .T.,.F.,cCodRota,cDescRota,Space(6),0} )
				EndIf
				/*+-------------------------------------------------------------+
				|Verifico se existe setor para pegar descricao e acrescento no|
				|array                                                        |
				+-------------------------------------------------------------+*/
				If Ascan(aArraySetor,{|x| x[3]+x[4]+x[5] == cCodRota+cZona+cSetor}) == 0 .And. lValido
					aAdd( aArraySetor, { .T.,.F.,cCodRota,cZona,cSetor,cPtoRefDA6,"      ",cSeqRota} )
					/*+------------------------------------------------------------+
					//|Busco se ja existe a zona no array , caso nao exista,a mesma|
					//|e incluida                                                  |
					//+------------------------------------------------------------+*/
					If Ascan(aArrayZona,{|x| x[3]+x[4] == cCodRota+cZona}) == 0
						aAdd( aArrayZona , { .T.,.F.,cCodRota,cZona,cPtoRefDA5,"      ",cSeqRota} )
					EndIf
				EndIf
			Else
				cCodRota   := Repl("9",Len(DA8->DA8_COD))
				cDescRota  := OemToAnsi(STR0043) //"PEDIDOS SEM ROTEIRIZACAO"
				cZona      := Repl("9",Len(DA7->DA7_PERCUR))
				cSetor     := Repl("9",Len(DA7->DA7_ROTA))
				cSeqRota   := Repl("9",Len(DA9->DA9_SEQUEN))
				cSequencia := Repl("9",Len(DA7->DA7_SEQUEN))
				lEnable    := .T.
				lValido    := .T.
				If Ascan(aArrayRota,{|x| x[3] == cCodRota}) == 0
					aAdd( aArrayRota  , { .T.,.F.,cCodRota,cDescRota,Space(6),0} )
				EndIf
				If Ascan(aArrayZona ,{|x| x[3]+x[4] == cCodRota+cZona}) == 0
					aAdd( aArrayZona , { .T.,.F.,cCodRota,cSetor,cDescRota,"      ",cSeqRota} )
				EndIf

				If Ascan(aArraySetor ,{|x| x[3]+x[4]+x[5] == cCodRota+cZona+cSetor}) == 0
					aAdd( aArraySetor, { .T.,.F.,cCodRota,cZona,cSetor,cDescRota,"      ",cSeqRota} )
				EndIf
			EndIf
			/*+-------------------------------------------------------+
			|Verifico se consiste os dados do pedido e se a rota foi|
			|valida                                                 |
			+-------------------------------------------------------+*/
			(cAliasCli)->(dbSetOrder(1))
			//If (cAliasCli)->(MsSeek(OsFilial(cAliasCli,(cAlias)->FILIAL)+cCliente+cLoja)) .And. lValido
			If (cAliasCli)->(MsSeek(xFilial(cAliasCli)+cCliente+cLoja)) .And. lValido
				SB1->(dbSetOrder(1))
				//If SB1->(MsSeek(OsFilial("SB1",(cAlias)->FILIAL)+(cAlias)->PRODUTO))
				If SB1->(MsSeek(xFilial("SB1")+(cAlias)->PRODUTO))
					/*+------------------------------+
					|Calculo peso do item do pedido|
					+------------------------------+*/
					nPesoUnit := SB1->(FieldGet(FieldPos(cCpoPeso)))
					nCapArm   := OsPrCapArm((SC9->C9_PRODUTO,(cAlias)->FILIAL))
					// Existe no SC9
					lSC9:= ((cAlias)->ORIGEM == "SC9")
					If lSC9
						nPesoProd := nPesoUnit * (cAlias)->QTDLIB
						nValor    := ( (cAlias)->QTDLIB * (cAlias)->PRCVEN)
						nCapVol   := ( nCapArm * (cAlias)->QTDLIB) // alterado em 16/07/07 por felipe
						//nCapVol   := Posicione("SB1",1,xFilial("SB1")+(cAlias)->PRODUTO,"B1_YM3") * (cAlias)->QTDLIB
					Else
						nPesoProd := nPesoUnit * (cAlias)->QTDVEN
						nValor    := ( (cAlias)->QTDVEN * (cAlias)->PRCVEN)
						nCapVol   := nCapArm * (cAlias)->QTDVEN // alterado em 16/07/07 por felipe
						//nCapVol   := Posicione("SB1",1,xFilial("SB1")+(cAlias)->PRODUTO,"B1_YM3") * (cAlias)->QTDVEN
					EndIf
					/*+--------------------------------------------------------+
					|Se ja existe no array de pedido apenas incremento o peso|
					+--------------------------------------------------------+*/
					RecLock("TRBPED",.T.)
					TRBPED->PED_GERA   := "N"
					TRBPED->PED_ROTA   := cCodRota
					TRBPED->PED_ZONA   := cZona
					TRBPED->PED_SETOR  := cSetor
					TRBPED->PED_SEQROT := cSeqRota
					TRBPED->PED_EMISS  := StoD((cAlias)->EMISSAO)
					TRBPED->PED_PEDIDO := (cAlias)->PEDIDO
					// Bloqueio do cliente - alterado 31/03/06 - Clientes bloqueados pelo fin, mas com pedidos de pagamento antecipado.
					//cBloqueio          := fGetBlq((cAlias)->PEDIDO)//(cAlias)->A1_YBLOQ
					TRBPED->PED_BLOQ   := Iif((cAlias)->ORIGEM == "SC6","B","L")
					//TRBPED->PED_RESERV := Posicione("ZZ4",3,xFilial("ZZ4")+(cAlias)->PEDIDO+cCliente+cLoja+SB1->B1_COD,"ZZ4_QUANT") // RESERVA INCLUIDO POR ZAGO 19/10/06
					TRBPED->PED_RESERV := Posicione("SC0",3,xFilial("SC0")+(cAlias)->PEDIDO+cCliente+cLoja+SB1->B1_COD,"C0_QUANT") // RESERVA INCLUIDO POR ZAGO 19/10/06
					//TRBPED->PED_TPENTR := iif((cAlias)->TPENTR == "N","PARCIAL","INTEGRAL")
					//TRBPED->PED_USO    := fGetUso(SB1->B1_COD) // incluído por zago, 11.05.06 - carga simultanea
					TRBPED->PED_BLQPED := (cAlias)->BLQPED
					TRBPED->PED_REGRA  := " " //Iif(Alltrim(cBloqueio)=='B',"#","  ")
					TRBPED->PED_ITEM   := (cAlias)->ITEM
					TRBPED->PED_SEQLIB := (cAlias)->SEQUEN
					TRBPED->PED_CODPRO := SB1->B1_COD
					TRBPED->PED_DESPRO := SB1->B1_DESC
					TRBPED->PED_QTDLIB := (cAlias)->QTDLIB
					TRBPED->PED_QTDPED := Iif((cAlias)->ORIGEM == "SC6",(cAlias)->QTDVEN,0)
					TRBPED->PED_CONDPG := (cAlias)->CONDPAG
					//TRBPED->PED_YCONDP := (cAlias)->YCONDPG

					/*+-------------------------------------------------------------+
					|Verifca se eh operador logistico e grava a filial solicitante|
					+-------------------------------------------------------------+*/
					TRBPED->PED_FILORI := (cAlias)->FILIAL
					//TRBPED->PED_FILCLI := OsFilial("SA1",(cAlias)->FILIAL)
					TRBPED->PED_FILCLI := xFilial("SA1")
					TRBPED->PED_VEND   := (cAlias)->VEND
					TRBPED->PED_CODCLI := cCliente
					TRBPED->PED_LOJA   := cLoja
					TRBPED->PED_NOME   := (cAliasCli)->(FieldGet(FieldPos(cCpoNomCli)))
					TRBPED->PED_PESO   := nPesoProd
					TRBPED->PED_CARGA  := "ZZZZZZ"
					TRBPED->PED_SEQSET := cSequencia
					TRBPED->PED_SEQORI := cSeqRota
					TRBPED->PED_VALOR  := nValor
					TRBPED->PED_VOLUM  := nCapVol
					If !VAZIO(cSA4_END) //Condicao incluida por Panetto
						TRBPED->PED_ENDPAD := cSA4_END
						//TRBPED->PED_BAIRRO := csA4_YBAIRRO
						TRBPED->PED_MUN    := csA4_MUN
						TRBPED->PED_EST    := csA4_EST
					Else
						TRBPED->PED_ENDPAD := Space(Len((cAlias)->ENDPAD))
						TRBPED->PED_BAIRRO := (cAliasCli)->(FieldGet(FieldPos(cCpoBaiCli)))
						TRBPED->PED_MUN    := (cAliasCli)->(FieldGet(FieldPos(cCpoMunCli)))
						TRBPED->PED_EST    := (cAliasCli)->(FieldGet(FieldPos(cCpoEstCli)))
					EndIf
					//TRBPED->PED_EXMOST := (cAlias)->A1_YEXMOST
					TRBPED->PED_TIPPED := (cAlias)->C5_YSUBTP
					//TRBPED->PED_VLMPED := (cAlias)->A1_YVLMPED
					//TRBPED->PED_AGLUT2 := (cAlias)->AGLUT2
					TRBPED->PED_OBS := (cAlias)->OBS
					TRBPED->(MsUnlock())
				EndIf
			EndIf
			If ExistBlock("OM200GRV")
				ExecBlock("OM200GRV",.F.,.F.)
			EndIf
		EndIf
		DbSelectArea(cAlias)
		DbSkip()
	EndDo

	/*+----------------------------------------------------------------------------------------------------+
	| PROCEDIMENTO PARA MARCAÇÃO AUTOMÁGICA DOS PEDIDOS EM TELA DE ACORDO COM O SALDO EM ESTOQUE         |
	+----------------------------------------------------------------------------------------------------+*/
	If lAnEstoque
		oProcess:IncRegua1("Verificando pedidos para marcação automática...")
		fSldAtual()
	EndIf

	//+----------------------------------------------+
	//|Ordena por: Rota                              |
	//|            SeqRota                           |
	//|            Sequencia de clientes             |
	//|            Zona                              |
	//|            Setor                             |
	//|            Pedido                            |
	//|            Item                              |
	//+----------------------------------------------+
	dbSelectArea("TRBPED")
	dbSetOrder(2)
	oProcess:SetRegua2(TRBPED->(LastRec()))
	dbGotop()
	nSequencia := 5

	cRota    := TRBPED->PED_ROTA
	cCliente := TRBPED->PED_CODCLI
	cLoja    := TRBPED->PED_LOJA

	While !Eof()
		oProcess:IncRegua2(OemtoAnsi(STR0111)) //"Roteirizando pedidos..."

		If TRBPED->PED_ROTA != cRota
			cRota := TRBPED->PED_ROTA
			nSequencia := 0
		EndIf

		If TRBPED->PED_CODCLI != cCliente .Or.TRBPED->PED_LOJA != cLoja
			cCliente   := TRBPED->PED_CODCLI
			cLoja      := TRBPED->PED_LOJA
			nSequencia += 5
		EndIf

		RecLock("TRBPED",.F.)
		TRBPED->PED_SEQROT := StrZero(nSequencia,6)
		TRBPED->(MsUnlock())

		dbSkip()
	EndDo
	//+-------------------------------------------------------+
	//|Ordeno o array de pedidos de acordo com a sequencia de |
	//|geracao                                                |
	//+-------------------------------------------------------+
	TRBPED->(dbSetOrder(3))
	//+------------------------------------+
	//|Adiciono no array de carga a inicial|
	//+------------------------------------+

	aAdd(aArrayCarga,{.T.,cCarga,OemtoAnsi(STR0040) + cCarga,TransForm(0,cPictPeso),TransForm(0,cPictVal),TransForm(0,cPictVol),StrZero(0,6),Space(7),Space(Len(DA3->DA3_COD));
	,Space(Len(DA4->DA4_COD)),Space(Len(DAU->DAU_COD)),Space(Len(DAU->DAU_COD)),Space(Len(DAU->DAU_COD))}) //"CARGA "

	//+-------------------------------------------------------+
	//|Verifico se existe algum em branco pois  nao e possivel|
	//| criar uma dialog com array vazio                      |
	//+-------------------------------------------------------+
	If Len(aArrayRota) == 0
		aAdd( aArrayRota  , { .T.,.F.,Space(6),Space(20),Space(6),0} )
	EndIf
	If Len(aArrayZona) == 0
		aAdd( aArrayZona , { .T.,.F.,Space(6),Space(6),Space(20),Space(6)} )
	EndIf
	If Len(aArraySetor) == 0
		aAdd( aArraySetor , { .T.,.F.,Space(6),Space(6),Space(6),Space(20),Space(6)} )
	EndIf

	/*+-----------------------------------------------------------------+
	|Ordena os browses de rota, zona e setor de acordo com a sequencia|
	+-----------------------------------------------------------------+*/
	aArrayRota  := aSort(aArrayRota ,,,{|x,y| x[3] < y[3]})
	aArrayZona  := aSort(aArrayZona ,,,{|x,y| x[3]+x[7]+x[4] < y[3]+y[7]+y[4] })
	aArraySetor := aSort(aArraySetor,,,{|x,y| x[3]+x[8]+x[4]+x[5] < y[3]+y[8]+y[4]+x[5] })

	If lQuery
		dbSelectArea("TRBSC9")
		dbCloseArea()
	Else
		dbSelectArea("SC9")
		dbClearFilter()
		RetIndex("SC9")
		Ferase(cIndSC9+OrdBagExt())
	EndIf
	//f4 = 115
	SetKey(120,{||u_OmsPesqPed()})
	SetKey(121,{||fLibera()})
	SetKey(122,{||u_MovCEst(TRBPED->PED_CODPRO,cArmazens,2)})
	SetKey(123,{||u_Mov161()})
Return(.T.)

/*
+----------+------------+-------+--------------------+------+-----------+
|Programa  |OmsTrocaSeq |Autor  |Henry Fila          | Data |  01/02/01 |
+----------+------------+-------+--------------------+------+-----------+
|Desc.     |  Monta Pedidos nos arrays para marcacao                    |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros| ExpC1 - Horario inicial da carga                           |
|          | ExpA2 - Array da carga                                     |
|          | ExpA3 - Array da carga anterior para alteracao             |
|          | ExpO4 - Array com os objetos a dar refresh                 |
|          | ExpL5 - Se ira trocar a sequencia de entrega               |
|          | ExpC6 - Sequencia atual                                    |
|          | ExpC7 - Nova sequencia                                     |
|          | ExpN8 - Tipo de aplicacao ao registro                      |
|          |         [1]-Move para baixo pela toolbar                   |
|          |         [2]-Move para cima pela toolbar                    |
|          |         [3]-Habilita a janela de mover para                |
|          |         [4]-Cancela  a janela de mover para                |
|          |         [6]-Confirma a janela de mover para                |
|          |         [7]-Apenas troca o horario                         |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

Static Function OmsTrocaSeq(cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,lSeq,cSeqAtual,cSeqNova,nUpDown)
	Local nSequencia  := 0,nc
	Local nOpca       := 0
	Local nPos        := oPedMan:nAt
	Local nPosAnt     := 0
	Local nPosCarga := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})

	Local oLiberado   := LoadBitmap( GetResources(), "PMSTASK4" )
	Local oCalend     := LoadBitmap( GetResources(), "PMSTASK1" )
	Local oHorario    := LoadBitmap( GetResources(), "PMSTASK2" )
	Local oVeiculo    := LoadBitmap( GetResources(), "PMSTASK3" )
	Local oDlgCarga

	cSeqAtual   := aArrayAnt[oPedMan:nAt,1]


	//+---------------------------------------------------------+
	//|Verifico se o pedido esta marcado para a geracao da carga|
	//|disponivel                                               |
	//+---------------------------------------------------------+

	nPosAnt := nPos

	Do Case

		//+---------------------------------------------------------+
		//|Move registro para baixo pelas setas da toolbar          |
		//+---------------------------------------------------------+
		Case nUpDown == 1

		OmsTrocaSeq(cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,lSeq,cSeqAtual,cSeqNova,4)

		If nPos <> Len(aArrayAnt)
			nPos++
		Endif

		cSeqNova := StrZero(Val(aArrayAnt[nPos,1])+1,6)
		lSeq     := .T.

		//+---------------------------------------------------------+
		//|Move registro para cima  pelas setas da toolbar          |
		//+---------------------------------------------------------+
		Case nUpDown == 2

		OmsTrocaSeq(cHrStart,aArrayCarga,aArrayAnt,oPedMan,aObj,lSeq,cSeqAtual,cSeqNova,4)

		If nPos <> 1
			nPos--
		Endif

		cSeqNova := StrZero(Val(aArrayAnt[nPos,1])-1,6)
		lSeq     := .T.

		//+---------------------------------------------------------+
		//|Habilita janela para digitacao de Mover para....         |
		//+---------------------------------------------------------+
		Case nUpDown == 3

		If !lSeq
			cSeqNova    := Space(6)
			oPedMan:nRight -= 160
			aEval(aObj,{|x| x:show()})
			lSeq := .T.
		Endif

		//+---------------------------------------------------------+
		//|Cancela janela de Mover para.                            |
		//+---------------------------------------------------------+
		Case nUpDown == 4

		If lSeq
			aEval(aObj,{|x| x:hide()})
			oPedMan:nRight += 160
			lSeq := .F.
		Endif

		//+---------------------------------------------------------+
		//|Confirmacao da janela mover para...                      |
		//+---------------------------------------------------------+
		Case nUpDown == 5

		If lSeq
			aEval(aObj,{|x| x:hide()})
			oPedMan:nRight += 160
			lSeq := .T.
		Endif
		Case nUpDown == 6
		lSeq := .F.
	EndCase

	If lSeq

		If !Empty(cSeqNova)
			aArrayAnt[oPedMan:nAt,1] := cSeqNova

			aArrayAnt := aSort(aArrayAnt,,,{|x,y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3]})

			For nC := 1 to Len(aArrayAnt)
				nSequencia+=5
				aArrayAnt[nC,1] := StrZero(nSequencia,6)
			Next
		EndIf

		If nUpDown == 1 .Or. nUpDown == 2 .Or. nUpDown == 5
			lSeq := .F.
		Endif
	Endif

	//+-----------------------------------------------------+
	//|Verifica se a opcao e de alguma alteracao            |
	//+-----------------------------------------------------+
	If nUpDown == 1 .Or. nUpDown == 2 .Or. nUpDown == 5 .Or. nUpDown == 6

		//+-------------------------------------------------+
		//|Atualiza as horas de entrega                     |
		//+-------------------------------------------------+
		Oms200Time(cHrStart,aArrayAnt,aArrayCarga[nPosCarga,CARGA_VEIC],12,6,7,2,3,4,14,15,16,17,18)

	Endif

	//+-----------------------------------------------------+
	//|Da refresh no objeto da listbox                      |
	//+-----------------------------------------------------+
	oPedMan:bLine:={ ||{Iif(aArrayAnt[oPedMan:nAT,18]==1,oLiberado,;
	Iif(aArrayAnt[oPedMan:nAT,18]==2,oVeiculo,;
	Iif(aArrayAnt[oPedMan:nAT,18]==3,oHorario,;
	Iif(aArrayAnt[oPedMan:nAT,18]==4,oCalend,oLiberado)))),;
	aArrayAnt[oPedMan:nAT,1],;
	aArrayAnt[oPedMan:nAT,2],;
	aArrayAnt[oPedMan:nAT,5],;
	aArrayAnt[oPedMan:nAT,16],;
	aArrayAnt[oPedMan:nAT,17],;
	aArrayAnt[oPedMan:nAT,6],;
	aArrayAnt[oPedMan:nAT,7],;
	aArrayAnt[oPedMan:nAT,8],;
	aArrayAnt[oPedMan:nAT,9],;
	aArrayAnt[oPedMan:nAT,10],;
	aArrayAnt[oPedMan:nAT,11],;
	fGetRedesp(aArrayAnt[oPedMan:nAT,5])}}

	oPedMan:nAt := nPos

	oPedMan:Refresh()
Return .T.

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |DLGTRANSP |Autor  |Henry Fila          | Data |  01/22/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     |Associa caminhao para a carga                               |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5Dl                                                      |
+----------+------------------------------------------------------------+
*/

User Function OmsTransp(aArrayMan,aArrayCarga,oEnable,oDisable,oMarked,oNoMarked,cHrStart)
	Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T. })
	Local cCarga     := ""
	Local nPeso      := 0
	Local nVolume    := 0
	Local nPtoEntr   := 0

	Local cVeiculo   := Criavar("DA3_COD",.F.)
	Local cMotorista := Criavar("DA4_COD",.F.)
	Local cAjuda1    := Criavar("DAU_COD",.F.)
	Local cAjuda2    := Criavar("DAU_COD",.F.)
	Local cAjuda3    := Criavar("DAU_COD",.F.)
	Local cNomeAju1  := ""
	Local cNomeAju2  := ""
	Local cNomeAju3  := ""
	Local cBitmap    := "PROJETOAP"
	Local nOpca      := 0
	Local oDlg

	Local cPlaca     := Criavar("DA3_PLACA",.F.)
	Local cNomeCam   := Criavar("DA3_DESC",.F.)
	Local nCapacMax  := 0
	Local nLimMax    := 0
	Local cNomeMot   := Criavar("DA4_NOME",.F.)

	//+---------------------------------------------------+
	//|Se existir carga em aberto abro a tela de caminhoes|
	//+---------------------------------------------------+

	If nPosCarga == 0
		Help(" ",1,"DLACGDISP")
	Else
		cCarga   := aArrayCarga[nPosCarga,CARGA_COD]
		cNomeCam := ""
		cPlaca   := ""
		nCapaxMax:= 0
		nLimMax  := 0
		nPeso    := Val(aArrayCarga[nPosCarga,CARGA_PESO])
		nVolume  := Val(aArrayCarga[nPosCarga,CARGA_VOLUM])
		nPtoEntr := Val(aArrayCarga[nPosCarga,CARGA_PTOENT])

		DEFINE MSDIALOG oDlg Title OemtoAnsi(STR0112) From 200,001 to 500,600 Pixel //"Associacao do Veiculo"

		@ 0 , 0 BITMAP oBmp RESNAME cBitMap oF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

		@ 007,060 Say OemtoAnsi(STR0014) Size 30,7 Of oDlg Pixel //"Carga:"
		@ 007,090 MsGet cCarga Picture "@!" When .F. Size 25,10 Of oDlg Pixel

		@ 019,050 to 55,295 of oDlg Pixel
		@ 056,050 to 130,295 of oDlg Pixel

		@ 025,060 Say OemToAnsi(STR0019)  Size 30,10  Of oDlg Pixel //"Caminhao"
		@ 025,090 MSGet cVeiculo Valid U_OmsVldTransp(cVeiculo,@cNomeCam,@cPlaca,@nCapacMax,@nLimMax,nPeso,nVolume,nPtoEntr,@cMotorista,@cNomeMot,;
		@cAjuda1,@cNomeAju1,@cAjuda2,@cNomeAju2,@cAjuda3,@cNomeAju3) F3 "DA3" Size 30,10 Of oDlg Pixel
		@ 025,130 MSGet oNomeCam VAR cNomeCam When .F. Size 148,10  Of oDlg Pixel

		@ 040,060 Say OemtoAnsi(STR0095) Size 30,10  Of oDlg Pixel //"Placa"
		@ 040,090 MSGet oPlaca VAR cPlaca When .F. Size 35,10  Of oDlg Pixel

		@ 040,135 Say OemtoAnsi(STR0096) Size 30,10  Of oDlg Pixel //"Capac.Max"
		@ 040,166 MSGet oCapacMax VAR nCapacMax When .F. Size 35,10  Of oDlg Pixel

		@ 040,210 Say OemtoAnsi(STR0097) Size 30,10  Of oDlg Pixel //
		@ 040,243 MSGet oLimMax VAR nLimMax When .F. Size 35,10  Of oDlg Pixel

		@ 061,060 Say OemtoAnsi(STR0069) Size 30,10  Of oDlg Pixel //"Motorista"
		@ 061,090 MSGet cMotorista Picture "@!" Valid u_Os200Motor(cMotorista,@cNomeMot) F3 "DA4" Size 30,10 Of oDlg Pixel
		@ 061,130 MsGet oNomeMot VAR cNomeMot When .F. Size 148,10  Of oDlg Pixel

		@ 076,055 Say OemtoAnsi(STR0092) Size 40,10  Of oDlg Pixel //"1o. Ajudante"
		@ 076,090 MSGet cAjuda1 Picture "@!" Valid u_Oms200Aju(cAjuda1,@cNomeAju1) F3 "DAU" Size 30,10 Of oDlg Pixel
		@ 076,130 MsGet oNomeAju1 VAR cNomeAju1 When .F. Size 148,10  Of oDlg Pixel

		@ 091,055 Say OemtoAnsi(STR0093) Size 40,10  Of oDlg Pixel //"2o. Ajudante"
		@ 091,090 MSGet cAjuda2 Picture "@!" Valid u_Oms200Aju(cAjuda2,@cNomeAju2) F3 "DAU" Size 30,10 Of oDlg Pixel
		@ 091,130 MsGet oNomeAju1 VAR cNomeAju2 When .F. Size 148,10  Of oDlg Pixel

		@ 106,055 Say OemtoAnsi(STR0094) Size 40,10  Of oDlg Pixel //"3o. Ajudante"
		@ 106,090 MSGet cAjuda3 Picture "@!" Valid u_Oms200Aju(cAjuda3,@cNomeAju3) F3 "DAU" Size 30,10 Of oDlg Pixel
		@ 106,130 MsGet oNomeAju1 VAR cNomeAju3 When .F. Size 148,10  Of oDlg Pixel

		DEFINE SBUTTON FROM 135,235 TYPE 1 ACTION ( nOpca := 1,oDlg:End() ) ENABLE OF oDlg WHEN !Empty(cVeiculo) .And. !Empty(cMotorista)
		DEFINE SBUTTON FROM 135,265 TYPE 2 ACTION ( oDlg:End() ) ENABLE OF oDlg

		ACTIVATE DIALOG oDlg CENTERED

		//+-----------------------------+
		//|Atualizo carga com o caminhao|
		//+-----------------------------+

		If nOpca == 1
			aArrayCarga[nPosCarga, CARGA_VEIC  ] := cVeiculo
			aArrayCarga[nPosCarga, CARGA_MOTOR ] := cMotorista
			aArrayCarga[nPosCarga, CARGA_AJUD1 ] := cAjuda1
			aArrayCarga[nPosCarga, CARGA_AJUD2 ] := cAjuda2
			aArrayCarga[nPosCarga, CARGA_AJUD3 ] := cAjuda3
		EndIf

		Oms200Time(cHrStart,aArrayMan,aArrayCarga[nPosCarga,CARGA_VEIC],12,6,7,2,3,4,14,15,16,17,18)
	EndIf
Return

/*+----------+----------+-------+--------------------+------+-------------+
|Programa  |OmsVLDTRAN|Autor  |Henry Fila          | Data |  01/22/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Valida caminhao na associacao da carga                     |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5Dl                                                      |
+----------+------------------------------------------------------------+*/

User Function OmsVldTransp(cVeiculo, cNomeCam, cPlaca,nCapacMax ,nLimMax ,nPeso,nVolume,nPtoEntr,cMotorista,cNomeMot,cAjuda1,cNomeAju1,cAjuda2,cNomeAju2,cAjuda3,cNomeAju3)
	Local lRet := .T.
	//+-----------------------------------------------------+
	//|Verifico se o parametro de considerar restricoes esta|
	//|ativo  e consisto a capacidade do caminhao           |
	//+-----------------------------------------------------+
	Default  cMotorista := ""
	Default  cNomeMot   := ""
	Default  cAjuda1    := ""
	Default  cNomeAju1  := ""
	Default  cAjuda2    := ""
	Default  cNomeAju2  := ""
	Default  cAjuda3    := ""
	Default  cNomeAju3  := ""

	dbSelectArea("DA3")
	dbSetOrder(1)
	If MsSeek(xFilial("DA3")+ cVeiculo)
		//+--------------------------------------------------------------------------+
		//|Verifica se o peso, o volume e os pontos de entrega ultrapassan os limites|
		//+--------------------------------------------------------------------------+
		/*
		If mv_par13 == 1
		If ( (nPeso > DA3->DA3_CAPACN).Or. (nVolume > DA3->DA3_VOLMAX).Or. (nPtoEntr > DA3->DA3_LIMMAX ) ) .And.;
		DA3->DA3_ATIVO == "1"
		Help(" ",1,"OMSULTCARGA") //Caminhao nao suporta carga montada
		lRet := .F.
		ElseIf DA3->DA3_ATIVO == "2"
		Help(" ",1,"OMSCAMINDS")  //Caminhao indisponivel
		lRet := .F.
		EndIf
		EndIf
		*/
		If Empty(cMotorista)
			cMotorista := DA3->DA3_MOTORI
		EndIf

		cNomeCam   := DA3->DA3_DESC
		cPlaca     := DA3->DA3_PLACA
		nCapacMax  := DA3->DA3_CAPACM
		nLimMax    := DA3->DA3_LIMMAX

		If !Empty(cMotorista)
			DA4->(dbSetOrder(1))
			If DA4->(MsSeek(xFilial()+DA3->DA3_MOTORI))
				cNomeMot := DA4->DA4_NOME

				DAU->(dbSetOrder(1))
				If DAU->(MsSeek(xFilial("DAU")+DA4->DA4_AJUDA1))
					cAjuda1   := DAU->DAU_COD
					cNomeAju1 := DAU->DAU_NOME
				EndIf

				DAU->(dbSetOrder(1))
				If DAU->(MsSeek(xFilial("DAU")+DA4->DA4_AJUDA2))
					cAjuda2   := DAU->DAU_COD
					cNomeAju2 := DAU->DAU_NOME
				EndIf

				DAU->(dbSetOrder(1))
				If DAU->(MsSeek(xFilial("DAU")+DA4->DA4_AJUDA3))
					cAjuda3   := DAU->DAU_COD
					cNomeAju3 := DAU->DAU_NOME
				EndIf
			EndIf
		EndIf

		oNomeCam:Refresh()
		oPlaca:Refresh()
		oCapacMax:Refresh()
		oLimMax:Refresh()
		oNomeMot:Refresh()

	EndIf
Return(lRet)

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |OmsSEQPED |Autor  |Henry Fila          | Data |  01/05/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Funcao de ordenacao de pedidos                             |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametro | lTroca = .T. Indexa po ordem de carga disponivel           |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

Static Function OmsSeqPed()
	Local cRota      := ""
	//+---------------------------------------------------+
	//|Gero a sequencia de entrega de acordo com cada rota|
	//+---------------------------------------------------+
Return

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |OmsVLDSEQ |Autor  |Henry Fila          | Data |  01/05/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Funcao Validacao da sequencia na carga se ja existe        |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros| cSequencia := Sequencia digitada                           |
|          | cCarga     := Carga Disponivel para verificacao            |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

Static Function OmsVldSeq(cSequencia,cRota,aArrayMan)
	Local lRet := .T.

	If Ascan(aArrayMan,{|x| x[1]+x[2] == cSequencia+cRota}) > 0
		lRet := .F.
		Help(" ",1,"OMSSEQEXIS") //Sequencia ja existe na carga disponivel
	EndIf
Return(lRet)

/*
+----------+----------+-------+-----------------------+------+------------+
| Funcao   |A270PROCES| Autor | Henry Fila            | Data | 19/01/2001 |
+----------+----------+-------+-----------------------+------+------------+
| Descricao| Processa o estorno de cargas indicadas                       |
+----------+--------------------------------------------------------------+
| Uso      | Ap5Dl                                                        |
+----------+------------------------------------------+------+------------+
| Revisao  |                                          | Data | 27.01.00   |
|          |                                          |      |            |
|          |                                          |      |            |
+----------+------------------------------------------+------+------------+
*/

User Function Os200Estor()
	Local cMens      := ""
	Local nProcRegu  := 0
	Local lProcessa  := .T.
	Local lBlqCar    := ( DAK->(FieldPos("DAK_BLQCAR")) > 0 )
	Local lBloqueio  := OsBlqExec(DAK->DAK_COD, DAK->DAK_SEQCAR)

	Local aAreaAnt   := {}
	Local aAreaSC9   := {}
	Local cSeekSC9   := ''
	Local cDCFPed    := ''
	Local cDCFItem   := ''
	Local cSeekDCF   := ''

	//+---------------------------------------------------------------+
	//|Verifico se a carga ja foi unitizada impossibilitando o estorno|
	//+---------------------------------------------------------------+
	If ( DAK->DAK_FLGUNI == "1" )
		Help(" ",1,"OMS200CUNI") //Carga ja unitizada
		lProcessa := .F.
	EndIf
	If ( DAK->DAK_FEZNF == "1" )
		Help(" ",1,"OMS200CFAT") //Carga ja unitizada
		lProcessa := .F.
	EndIf

	//+-------------------------------------------------------------------+
	//|Verifica se existe o campo e se esta bloqueada                     |
	//+-------------------------------------------------------------------+
	If ( lBlqCar .And. DAK->DAK_BLQCAR == '1' ) .Or. lBloqueio
		lProcessa := .F.
		Aviso(OemtoAnsi(STR0121),OemtoAnsi(STR0123),{OemtoAnsi(STR0122)})
	EndIf
	/*
	//+------------------------------------------------------------+
	//|Impede o estorno de Cargas com Servico de WMS jah executado |
	//+------------------------------------------------------------+
	If lProcessa .And. IntDL()
	aAreaAnt := GetArea()
	aAreaSC9 := SC9->(GetArea())
	cSeekSC9 := xFilial('SC9')+DAK->DAK_COD+DAK->DAK_SEQCAR
	dbSelectArea('SC9')
	dbSetorder(5) //-- C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT
	If MsSeek(cSeekSC9, .F.)
	Do While !Eof() .And. lProcessa .And. cSeekSC9 == C9_FILIAL+C9_CARGA+C9_SEQCAR
	If !Empty(C9_SERVIC)
	cDCFPed    := PadR(C9_PEDIDO , TamSX3('DCF_DOCTO' )[1])
	cDCFItem   := PadR(C9_ITEM, TamSX3('DCF_SERIE' )[1])
	DCF->(dbSetOrder(2)) //-- DCF_FILIAL+DCF_SERVIC+DCF_DOCTO+DCF_SERIE+DCF_CLIFOR+DCF_LOJA+DCF_CODPRO
	If DCF->(MSSeek(cSeekDCF:=xFilial('DCF')+SC9->C9_SERVIC+cDCFPed+cDCFItem+SC9->C9_CLIENTE+SC9->C9_LOJA+SC9->C9_PRODUTO, .F.))
	Do While !DCF->(Eof()) .And. lProcessa .And. cSeekDCF==DCF->DCF_FILIAL+DCF->DCF_SERVIC+DCF->DCF_DOCTO+DCF->DCF_SERIE+DCF->DCF_CLIFOR+DCF->DCF_LOJA+DCF->DCF_CODPRO
	If !(DCF->DCF_STSERV=='1')
	Aviso('SigaWMS', 'Esta Carga nao pode ser estornada porque possui Servicos de WMS Pendentes. Estorne estes Servicos para proceder com o estorno.', {'Ok'})
	lProcessa := .F.
	Exit
	EndIf
	DCF->(dbSkip())
	EndDo
	If !lProcessa
	Exit
	EndIf
	EndIf
	EndIf
	dbSkip()
	EndDo
	EndIf
	RestArea(aAreaSC9)
	RestArea(aAreaAnt)
	EndIf
	*/ // movelar não usa wms

	If lProcessa

		cMens := OemToAnsi(STR0052) //"Confirma estorno das Cargas selecionadas ? Os Pedidos de Venda contidos nestas "
		cMens := cMens + OemToAnsi(STR0053) //"Cargas voltarao a ficar sem carga definida e aptos a serem utilizados em outras Cargas."

		If MsgYesNo(cMens,OemToAnsi(STR0054)) //"ATEN€AO"
			Processa( { || u_ESTORNO(DAK->DAK_COD) }, cCadastro, OemtoAnsi(STR0055) ) //"Estornando Cargas..."
		EndIf
	EndIf
Return

/*
+----------+----------+-------+-----------------------+------+------------+
| Funcao   |A200ProcEs| Autor | Henry Fila            | Data | 19/01/2001 |
+----------+----------+-------+-----------------------+------+------------+
| Descricao| Efetivamente estorna as cargas indicadas                     |
+----------+--------------------------------------------------------------+
| Uso      | Ap5Dl                                                        |
+----------+------------------------------------------+------+------------+
| Revisao  |                                          | Data |            |
+----------+------------------------------------------+------+------------+
*/
User Function ESTORNO(cCarga)
	Local aArea    := GetArea()
	Local aAreaSC9 := SC9->(GetArea())
	Local nTpVlEnt := OsVlEntCom()
	Local nRegSC9  := 0
	Local cFilPV   := ""
	Local lOS200Est:= ExistBlock("OS200EST")

	Begin Transaction

		//   If lOS200Est
		//      ExecBlock("OS200EST",.F.,.F.,{DAK->DAK_COD,DAK->DAK_SEQCAR})
		//   Endif

		dbSelectArea("DAI")
		dbSetOrder(1)
		MsSeek(xFilial("DAI")+DAK->DAK_COD+DAK->DAK_SEQCAR)

		While !Eof() .And. xFilial("DAI") == DAI->DAI_FILIAL .And.;
		DAK->DAK_COD == DAI->DAI_COD .And.;
		DAK->DAK_SEQCAR == DAI->DAI_SEQCAR

			//cFilPv := IIf(nTpVlEnt<>1,DAI->DAI_FILPV,xFilial("SC9"))
			cFilPv := xFilial("SC9")

			dbSelectArea("SC9")
			dbSetOrder(5)
			//MsSeek(OsFilial("SC9",cFilPv)+DAK->DAK_COD+DAK->DAK_SEQCAR)
			MsSeek(xFilial("SC9")+DAK->DAK_COD+DAK->DAK_SEQCAR)

			//+--------------------------------------------------------------+
			//|Limpa a carga do SC9                                          |
			//+--------------------------------------------------------------+
			While !Eof() .And. SC9->C9_FILIAL == cFilPv .And.;
			SC9->C9_CARGA == DAK->DAK_COD .And.;
			SC9->C9_SEQCAR == DAK->DAK_SEQCAR

				dbSelectArea("SC9")
				dbSkip()
				nRegSC9 := SC9->(Recno())
				dbSkip(-1)

				MaAvalSC9("SC9",8)

				dbSelectArea("SC9")
				SC9->(Msgoto(nRegSC9))

			EndDo
			dbSelectArea("DAI")
			dbSkip()
		EndDo
		If ExistBlock("OS200ES2")
			ExecBlock("OS200ES2",.F.,.F.,{DAK->DAK_COD,DAK->DAK_SEQCAR})
		EndIf
	End Transaction

	RestArea(aAreaSC9)
	RestArea(aArea)
Return

/*
+----------+----------+-------+-----------------------+------+----------+
|Função    |D260MANUT | Autor | Octavio Moreira       | Data | 02/07/99 |
+----------+----------+-------+-----------------------+------+----------+
|Nome Orig.| DFATA214 |                                                 |
+----------+----------+-------------------------------------------------+
|Descrição | Manipulacao de Pedidos por Carga                           |
+----------+------------------------------------------------------------+
|Uso       | Especifico (DISTRIBUIDORES)                                |
+----------+------------------------------------------+------+----------+
|Revis„o   |                                          | Data |          |
+----------+------------------------------------------+------+----------+
*/

User Function MANUTENCAO(cAlias,nReg,nOpc)
	Local aPosObj   := {},ni
	Local aObjects  := {}
	Local aSize     := {}
	Local aInfo     := {}
	Local aRecno    := {}
	Local aButtons  := { { "S4WB011N"   , { || GdSeek(oGetD,OemtoAnsi(STR0060)) }, OemtoAnsi(STR0060) } }

	Local cNFiscal  := ""
	Local cSerie    := ""
	Local cCliente  := ""
	Local cLoja     := ""
	Local cProxSeq  := ""
	Local cCarOri   := ""
	Local cChaveBus := ""
	Local nOpca     := 0
	Local nPosCar   := 0
	Local nPosSeq   := 0

	Local lCargaSF2 := .F.
	Local lRet      := .F.
	Local lProcessa := .T.
	Local lBlqCar   := ( DAK->(FieldPos("DAK_BLQCAR")) > 0 )
	Local lBloqueio := OsBlqExec(DAK->DAK_COD, DAK->DAK_SEQCAR)

	Private cCadastro      := OemtoAnsi(STR0056) //"Manipulacao de Pedidos Por Carga"
	Private aTela[0][0],aGets[0]

	If ( DAK->DAK_FEZNF == "1" )
		Help(" ",1,"OMS200CFAT") //Carga ja unitizada
		Return
	EndIf

	//+--------------------------------------------------------------+
	//| Primeiro verifica se a carga selecionada ainda pode ser edit.|
	//+--------------------------------------------------------------+
	If !Empty(DAK->DAK_JUNTOU) .And. DAK->DAK_JUNTOU != "JUNTOU" .And. DAK->DAK_JUNTOU != "MANUAL" .And. DAK->DAK_JUNTOU != "ASSOCI"
		Help(" ",1,"DS2602141")
		lProcessa := .F.
	EndIf

	If DAK->DAK_ACECAR == "1"
		Help(" ",1,"DS2602143")
		lProcessa := .F.
	EndIf

	//+-------------------------------------------------------------------+
	//|Verifica se existe o campo e se esta bloqueada                     |
	//+-------------------------------------------------------------------+
	If ( lBlqCar .And. DAK->DAK_BLQCAR == '1' ) .Or. lBloqueio
		lProcessa := .F.
		Aviso(OemtoAnsi(STR0121),OemtoAnsi(STR0123),{OemtoAnsi(STR0122)})
	EndIf

	If lProcessa

		//+--------------------------------------------------------------+
		//| Cria variaveis M->????? da Enchoice                          |
		//+--------------------------------------------------------------+

		RegToMemory( "DAK", .F., .F. )
		SoftLock("DAK")

		//+--------------------------------------------------------------+
		//| Cria aHeader e aCols da GetDados                             |
		//+--------------------------------------------------------------+
		nUsado  := 0
		aHeader := {}
		aCols   := {}

		dbSelectArea("SX3")
		MsSeek("DAI")
		While !Eof().And.(x3_arquivo=="DAI")
			If X3USO(x3_usado).And.cNivel>=x3_nivel
				nUsado := nUsado+1
				aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,;
				Iif(x3_campo=="DAI_COD   ",'D200VlCg2()',x3_valid),;
				x3_usado, x3_tipo,x3_arquivo,x3_context } )
			EndIf
			dbSkip()
		EndDo

		dbSelectArea("DAI")
		dbSetOrder(1)
		MsSeek(xFilial()+DAK->DAK_COD+DAK_SEQCAR)

		While !Eof() .And. DAI_FILIAL + DAI_COD + DAI_SEQCAR == xFilial() + DAK->DAK_COD + DAK->DAK_SEQCAR
			aAdd(aCols,Array(nUsado+1))
			aAdd(aRecno,Recno())
			For ni:=1 to nUsado
				aCols[Len(aCols),ni]   := FieldGet(FieldPos(aHeader[ni,2]))
			Next
			aCols[Len(aCols),nUsado+1] := .F.
			dbSkip()
		EndDo
		//+--------------------------------------------------------------+
		//| Executa a Modelo 3                                           |
		//+--------------------------------------------------------------+
		aSize := MsAdvSize()
		aAdd( aObjects, { 100, 100, .T., .T. } )
		aAdd( aObjects, { 200, 200, .T., .T. } )
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
		aPosObj := MsObjSize( aInfo, aObjects,.T.)

		DEFINE MSDIALOG oDlg1 TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
		//+--------------------------------------------------------------+
		//| Exibe as informacoes fixas de acordo com a opcao escolhida.  |
		//+--------------------------------------------------------------+
		dbSelectarea("DAK")
		EnChoice( "DAK", nReg, 2   ,,,,,aPosObj[1], , 3, , , , , ,.F. )

		dbSelectArea("DAI")
		oGetD     := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],4 ,"AllWaysTrue()","AllWaysTrue()", ,.T.,,,,Len(aCols))

		ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{||nOpcA := 1,If(oGetd:TudoOk(),If(!Obrigatorio(aGets,aTela),nOpcA := 0,oDlg1:End()),nOpcA := 0)},{||oDlg1:End()},,aButtons)

		//+--------------------------------------------------------------+
		//| Se o retorno for verdadeiro, grava os dados alterados        |
		//+--------------------------------------------------------------+
		If nOpca == 1
			Begin Transaction
				lGravou := u_Os200ProcMan(aRecno)
				If ( !lGravou )
				Else
					If ( __lSX8 )
						ConfirmSX8()
						EvalTrigger()
					EndIf
				EndIf
			End Transaction
		Else
			If ( __lSX8 )
				RollBackSX8()
			EndIf
		EndIf

		MsUnlockAll()

	EndIf

/*
+----------+-----------+-------+--------------------+------+------------+
|Programa  |A200ProcMan|Autor  |Henry Fila          | Data |  01/19/01  |
+----------+-----------+-------+--------------------+------+------------+
|Desc.     |Processamento da manipulacao da carga                       |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros|                                                            |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5Dl                                                      |
+----------+------------------------------------------------------------+
*/

User Function Os200ProcMan()
	Local aRotas     := {}	,nelem
	Local nPosCar    := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_COD"})
	Local nPosSeq    := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_SEQUEN"})
	Local nPosSeqCar := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_SEQCAR"})
	Local nPosPed    := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_PEDIDO"})
	Local nPosCli    := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_CLIENT"})
	Local nPosLoja   := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_LOJA"})
	Local nPosRota   := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_ROTEIR"})
	Local nPosZona   := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_PERCUR"})
	Local nPosSetor  := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_ROTA"})
	Local nPosTime   := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_CHEGAD"})
	Local nPosSrv    := AScan(aHeader,{|x|Alltrim(x[2])=="DAI_TMSERV"})

	Local nRegAtu    := 0
	Local nRegSC9    := 0
	Local nUsado     := Len(aHeader)+1
	Local nTpVlEnt   := OsVlEntCom()

	Local cCarOri    := M->DAK_COD
	Local cSeqOri    := M->DAK_SEQCAR
	Local cRota      := ""

	Local lGravou    := .F.

	Local Carga      := ""
	Local cSequencia := ""

	//Local cFilPv     := IIf(nTpVlEnt<>1,DAI->DAI_FILPV,xFilial("SC9"))
	Local cFilPv     := xFilial("SC9")
	//+--------------------------------------------------------------+
	//| Varre todas as linhas do aCols                               |
	//+--------------------------------------------------------------+

	aCols := aSort(aCols,,,{|x,y| x[nPosCar]+x[nPosSeqCar]+x[nPosSeq] < y[nPosCar]+y[nPosSeqCar]+y[nPosSeq]})

	For nElem := 1 to Len(aCols)
		//+--------------------------------------------------------------+
		//| Posiciona o item de carga correspondente a linha do aCols    |
		//+--------------------------------------------------------------+
		dbSelectArea("DAI")
		dbSetOrder(4)
		If MsSeek(xFilial("DAI")+aCols[nElem][nPosPed]+M->DAK_COD+M->DAK_SEQCAR)

			//cFilPv := IIf(nTpVlEnt<>1,DAI->DAI_FILPV,xFilial("SC9"))
			cFilPv := xFilial("SC9")

			//+--------------------------------------------------------------+
			//| Verifica se houve regravacao do numero da carga              |
			//+--------------------------------------------------------------+

			Do Case
				Case !aCols[nElem][nUsado] .And.( aCols[nElem][nPosSeq] <> DAI->DAI_SEQUEN )

				//+--------------------------------------------------------------+
				//| Procura no SC9 o registro correspondente e atualiza a carga  |
				//+--------------------------------------------------------------+
				dbSelectArea("SC9")
				dbSetOrder(5)
				//If MsSeek(OsFilial("SC9",cFilPv)+DAI->DAI_COD+DAI->DAI_SEQCAR+DAI->DAI_SEQUEN)
				If MsSeek(xFilial("SC9")+DAI->DAI_COD+DAI->DAI_SEQCAR+DAI->DAI_SEQUEN)

					While !Eof() .And. SC9->C9_FILIAL + SC9->C9_CARGA+SC9->C9_SEQCAR+SC9->C9_SEQUEN == ;
					xFilial("SC9")+DAI->DAI_COD+DAI->DAI_SEQCAR+DAI->DAI_SEQUEN
						//OsFilial("SC9",cFilPv)+DAI->DAI_COD+DAI->DAI_SEQCAR+DAI->DAI_SEQUEN

						SC9->(dbSkip())
						nRegAtu := SC9->(Recno())
						SC9->(dbSkip(-1))

						Reclock("SC9")
						SC9->C9_SEQUEN := aCols[nElem][nPosSeq]
						SC9->(MsUnlock())

						SC9->(MsGoto(nRegAtu))
					Enddo
				EndIf

				Reclock("DAI")
				DAI->DAI_SEQUEN := aCols[nElem][nPosSeq]
				DAI->(MsUnlock())

				Case !aCols[nElem][nUsado] .And. ( aCols[nElem][nPosCar] <> DAI->DAI_COD .Or. ;
				aCols[nElem][nPosSeqcar] <> DAI->DAI_SEQCAR )

				dbSelectArea("SC9")
				dbSetOrder(1)
				//If MsSeek(OsFilial("SC9",cFilPv)+aCols[nElem][nPosPed])
				If MsSeek(xFilial("SC9")+aCols[nElem][nPosPed])
					//While !Eof() .And. SC9->C9_FILIAL == OsFilial("SC9",cFilPv) .And.;
					While !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.;
					SC9->C9_PEDIDO  == aCols[nElem][nPosPed]

						If SC9->C9_CARGA == cCarOri .And. SC9->C9_SEQCAR == cSeqOri

							//+---------------------------------------------------------------+
							//|Exclui o SC9 da carga origem                                   |
							//+---------------------------------------------------------------+

							MaAvalSC9("SC9",8)

							//+---------------------------------------------------------------+
							//|Atualiza SC9 com a nova carga                                  |
							//+---------------------------------------------------------------+

							Reclock("SC9",.F.)
							SC9->C9_CARGA   := aCols[nElem][nPosCar]
							SC9->C9_SEQCAR  := aCols[nElem][nPosSeqCar]
							SC9->C9_SEQUEN  := OsSeqEnt(SC9->C9_CARGA,SC9->C9_SEQCAR,SC9->C9_PEDIDO)
							SC9->(MsUnlock())

							aAdd(aRotas,aCols[nElem,nPosRota] )
							aAdd(aRotas,aCols[nElem,nPosZona] )
							aAdd(aRotas,aCols[nElem,nPosSetor])
							aAdd(aRotas,"")
							aAdd(aRotas,"")
							aAdd(aRotas,"")
							aAdd(aRotas,"")
							aAdd(aRotas,"")
							aAdd(aRotas,aCols[nElem][nPosTime])
							aAdd(aRotas,aCols[nElem][nPosSrv])

							MaAvalSC9("SC9",7,,,,,,aRotas)

						EndIf

						SC9->(dbSkip())

					EndDo
				EndIf

				//+--------------------------------------------------------------+
				//| Verifica se o pedido corrente foi deletado da carga          |
				//+--------------------------------------------------------------+

				Case aCols[nElem][Len(aHeader)+1]

				dbSelectArea("SC9")
				dbSetOrder(1)
				//If MsSeek(OsFilial("SC9",cFilPv)+aCols[nElem][nPosPed])
				If MsSeek(xFilial("SC9")+aCols[nElem][nPosPed])
					//While !Eof() .And. SC9->C9_FILIAL == OsFilial("SC9",cFilPv) .And.;
					While !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.;
					SC9->C9_PEDIDO  == aCols[nElem][nPosPed]

						//+------------------------------------------------------+
						//|Verifica se o item do SC9 pertence a carga selecionada|
						//+------------------------------------------------------+

						If SC9->C9_CARGA == cCarOri .And. SC9->C9_SEQCAR == cSeqOri

							MaAvalSC9("SC9",8)

						EndIf

						dbSelectArea("SC9")
						dbSkip()

					Enddo
				EndIf
			EndCase
		EndIf
	Next

	If ExistBlock("OS200PM")
		ExecBlock("OS200PM",.F.,.F.)
	Endif
	lGravou := .T.
Return(lGravou)

/*
+----------+-----------+-------+--------------------+------+------------+
|Programa  |Oms200AROTA|Autor  |Henry Fila          | Data |  01/31/01  |
+----------+-----------+-------+--------------------+------+------------+
|Desc.     | Verifica se existe mais de uma rota  no range de pedidos   |
|          | e obriga o usuario a escolher apenas uma                   |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

Static Function Oms200ARota(aArrayMan)
	Local oDlgRot,nc
	Local nOpca      := 1
	//Local nOpca      := 0
	Local nPosRota   := 0
	Local aArrayRt   := {}
	Local cDescRota  := ""
	//Local cRota      := ""

	For nC := 1 to Len(aArrayMan)
		If ( Ascan(aArrayRt,{|x| x[1] == aArrayMan[nC,3]}) == 0)
			DA8->(dbSetOrder(1))
			If DA8->(MsSeek(xFilial("DA8")+aArrayMan[nC,2]))
				cDescRota:= DA8->DA8_DESC
			EndIf
			aAdd(aArrayRt, {aArrayMan[nC,3],cDescRota})
		EndIf
	Next

	aArrayRt := aSort(aArrayRt,,,{|x,y| x[1] < y[1]})

	//+---------------------------------------------------------+
	//|Se existir mais de uma rota monto checkbox para o usuario|
	//|escolher apenas uma para associar                        |
	//+---------------------------------------------------------+
	If Len(aArrayRt) > 1
		MsgAlert("Os pedidos marcados pertencem a mais de uma rota.")
		//MsgAlert("Deixe apenas uma rota marcada.")
		/*
		DEFINE MSDIALOG oDlgRot FROM 009, 000 TO 28,80 TITLE OemtoAnsi(STR0061) OF oMainWnd //"Composicao de Rotas na Carga"
		@ 015,005 LISTBOX oRt VAR cVar Fields HEADER OemtoAnsi(STR0022), ;//"Rota"
		OemtoAnsi(STR0020) ; //"Descricao"
		SIZE 300,120  OF oDlgRot PIXEL
		oRt:SetArray(aArrayRt)
		oRt:bLine:={ ||{aArrayRt[oRt:nAT,1] , aArrayRt[oRt:nAT,2]}}
		oRt:Refresh()
		ACTIVATE MSDIALOG  oDlgRot ON INIT EnchoiceBar( oDlgRot, { || nOpca := 1, wcRota:= aArrayRt[oRt:nAT,1], oDlgRot:End()}, {||oDlgRot:End()}) CENTERED
		//   Else
		//      nOpca := 1
		//   EndIf
		*/
	EndIf
Return(nOpca == 1)

/*
+----------+-----------+-------+--------------------+------+------------+
|Programa  |OmsTROCAROT|Autor  |Henry Fila          | Data |  01/04/01  |
+----------+-----------+-------+--------------------+------+------------+
|Desc.     |Troca sequencia de entrega de pedidos                       |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

Static Function OmsTrocaRot(aArrayRt,oMarked,oNoMarked)
	Local nPosRot := oRt:nAt,nc

	aArrayRt[oRt:nAt,1] := !aArrayRt[oRt:nAt,1]
	For nC := 1 to Len(aArrayRt)
		If nC != nPosRot
			aArrayRt[nC,1] := .F.
		EndIf
	Next
	oRt:Refresh()
Return

/*
+----------+------------+-------+--------------------+------+-----------+
|Programa  |Os200CRIATRB|Autor  |Henry Fila          | Data |  02/13/01 |
+----------+------------+-------+--------------------+------+-----------+
|Desc.     | Cria arquivo temporarios para MsSelect da tela de montagem |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5dl                                                      |
+----------+------------------------------------------------------------+
*/

Static Function Os200CriaTrb(aCampos)
	Local cAlias     := ""
	Local cArqTrb    := ""
	Local cNomInd1,cNomInd2,cNomInd3,cNomInd4 := ""

	aAdd(aCampos,{"PED_MARCA"  ,"C", 2,0})
	aAdd(aCampos,{"PED_REGRA"  ,"C", 1,0}) // Regra de liberação Movelar
	aAdd(aCampos,{"PED_BLOQ"   ,"C", 1,0})
	aAdd(aCampos,{"PED_GERA"   ,"C", 1,0})
	aAdd(aCampos,{"PED_TPENTR" ,"C", 8,0})
	aAdd(aCampos,{"PED_BLQPED" ,"C", 1,0})
	aAdd(aCampos,{"PED_RESERV" ,"N", 6,0}) //alterado para caracter em 23/10/2006 por PANETTO
	aAdd(aCampos,{"PED_ROTA"   ,"C", 6,0})
	aAdd(aCampos,{"PED_EMISS"  ,"D", 8,0})
	aAdd(aCampos,{"PED_ZONA"   ,"C", 6,0})
	aAdd(aCampos,{"PED_SETOR"  ,"C", 6,0})
	aAdd(aCampos,{"PED_SEQROT" ,"C", 6,0})
	aAdd(aCampos,{"PED_PEDIDO" ,"C", 6,0})
	aAdd(aCampos,{"PED_ITEM"   ,"C", 2,0})
	aAdd(aCampos,{"PED_SEQLIB" ,"C", 2,0})
	aAdd(aCampos,{"PED_CODPRO","C", 15,0})
	aAdd(aCampos,{"PED_DESPRO","C", 40,0})
	aAdd(aCampos,{"PED_QTDLIB","N", 14,2})
	aAdd(aCampos,{"PED_QTDPED","N", 14,2})
	//+--------------------------------------------------------------------------------------+
	//|Cria o campo de filiai de origem caso o tipo de operacao trabalhe com todas as filiais|
	//+--------------------------------------------------------------------------------------+
	aAdd(aCampos,{"PED_FILORI" ,"C",2,0})
	aAdd(aCampos,{"PED_FILCLI" ,"C",2,0})
	aAdd(aCampos,{"PED_CODCLI" ,"C",6,0})
	aAdd(aCampos,{"PED_LOJA"   ,"C",2,0})
	aAdd(aCampos,{"PED_NOME"   ,"C",30,0})
	aAdd(aCampos,{"PED_PESO"   ,"N",TamSx3("DAK_PESO")[1],TamSx3("DAK_PESO")[2]})
	aAdd(aCampos,{"PED_CARGA"  ,"C",6,0})
	aAdd(aCampos,{"PED_SEQSET" ,"C",6,0})
	aAdd(aCampos,{"PED_SEQORI" ,"C",6,0})
	aAdd(aCampos,{"PED_VALOR"  ,"N",TamSx3("DAK_VALOR")[1],TamSx3("DAK_VALOR")[2]})
	aAdd(aCampos,{"PED_VOLUM"  ,"N",TamSx3("DAK_CAPVOL")[1],TamSx3("DAK_CAPVOL")[2]})
	//aAdd(aCampos,{"PED_VOLUM"  ,"N",TamSx3("B1_YM3")[1],TamSx3("B1_YM3")[2]})
	aAdd(aCampos,{"PED_ENDPAD" ,"C",15,0})
	aAdd(aCampos,{"PED_BAIRRO" ,"C",30,0})
	aAdd(aCampos,{"PED_MUN"    ,"C",15,0})
	aAdd(aCampos,{"PED_EST"    ,"C",2, 0})
	// Zago 06/09/05, atendendo regra 02
	aAdd(aCampos,{"PED_TIPPED" ,"C",2,0}) // Tipo de Pedido
	//aAdd(aCampos,{"PED_EXMOST" ,"C",1,0}) // Exige Mostruário
	//aAdd(aCampos,{"PED_VLMPED" ,"N",TamSx3("A1_YVLMPED")[1],TamSx3("A1_YVLMPED")[2]}) // Valor minimo para frete
	//aAdd(aCampos,{"PED_VLMPED" ,"N",12,2}) // Valor minimo para frete
	//aAdd(aCampos,{"PED_AGENDA" ,"C",1,0}) // Exige agendamento prévio
	// Zago, adicionado em 16/01/06
	aAdd(aCampos,{"PED_CONDPG" ,"C",3,0}) // Código da cond. pagto
	aAdd(aCampos,{"PED_PRZMED" ,"N",3,0}) // Prazo médio
	aAdd(aCampos,{"PED_NUMPAR" ,"N",3,0}) // Número de parcelas
	// Zago, adicionado em 04/02/06
	aAdd(aCampos,{"PED_VEND"   ,"C",6,0}) // Consultor
	//aAdd(aCampos,{"PED_AGLUT"  ,"C",1,0}) // Ja agutinado S/' '
	aAdd(aCampos,{"PED_ESTOQ"  ,"C",1,0}) // Foi marcado pela analise de estoque
	//aAdd(aCampos,{"PED_YCONDP" ,"C",3,0})
	// Zago, adicionado em 11.05.06 // para uso em carga simultânea
	aAdd(aCampos,{"PED_USO"    ,"C",1,0})
	aAdd(aCampos,{"PED_AGLUT2" ,"C",1,0})
	aAdd(aCampos,{"PED_OBS" ,"C",20,0})
	/*
	If ExistBlock("DL200TRB")
	aCampos := Execblock("DL200TRB",.F.,.F.,aCampos)
	EndIf
	*/

	cAlias  := "TRBPED"
	cArqTRB := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTRB,cAlias,.F.)
	//+-----------------------------------------------------------------+
	//|Mesmo em processadores velozes, a CriaTrab nunca provocara erros:|
	//+-----------------------------------------------------------------+
	cNomInd1  :=Left(cArqTRB,7) + "B"
	cNomInd2  :=Left(cArqTRB,7) + "C"
	cNomInd3  :=Left(cArqTRB,7) + "D"
	cNomInd4  :=Left(cArqTRB,7) + "E"
	cNomInd5  :=Left(cArqTRB,7) + "F"
	cNomInd6  :=Left(cArqTRB,7) + "G"
	cNomInd7  :=Left(cArqTRB,7) + "H"
	cNomInd8  :=Left(cArqTRB,7) + "I"
	cNomInd9  :=Left(cArqTRB,7) + "J"
	cNomInd10 :=Left(cArqTRB,7) + "K"
	cNomInd11 :=Left(cArqTRB,7) + "L"
	cNomInd12 :=Left(cArqTRB,7) + "M"
	cNomInd13 :=Left(cArqTRB,7) + "N"
	cNomInd14 :=Left(cArqTRB,7) + "O"
	cNomInd15 :=Left(cArqTRB,7) + "P"

	IndRegua("TRBPED",cNomInd1 ,"PED_FILORI+PED_PEDIDO+PED_ITEM+PED_SEQLIB+PED_CODCLI+PED_LOJA")
	IndRegua("TRBPED",cNomInd2 ,"PED_ROTA+PED_SEQORI+PED_SEQSET+PED_ZONA+PED_SETOR+PED_FILORI+PED_PEDIDO+PED_ITEM")
	IndRegua("TRBPED",cNomInd3 ,"PED_ROTA+PED_SEQROT+PED_FILORI+PED_PEDIDO")
	IndRegua("TRBPED",cNomInd4 ,"PED_ROTA+PED_ZONA+PED_SETOR+PED_FILORI+PED_PEDIDO")
	IndRegua("TRBPED",cNomInd5 ,"PED_CODCLI+PED_CODPRO+PED_TIPPED")
	IndRegua("TRBPED",cNomInd6 ,"PED_PEDIDO+PED_ITEM")
	IndRegua("TRBPED",cNomInd7 ,"PED_CODPRO")
	IndRegua("TRBPED",cNomInd8 ,"PED_DESPRO")
	IndRegua("TRBPED",cNomInd9 ,"PED_NOME")
	IndRegua("TRBPED",cNomInd10,"PED_CODCLI+PED_LOJA")
	IndRegua("TRBPED",cNomInd11,"PED_ROTA+PED_CODCLI+PED_LOJA+PED_PEDIDO+PED_ITEM")
	IndRegua("TRBPED",cNomInd12,"PED_MARCA")
	IndRegua("TRBPED",cNomInd13,"PED_CODCLI+PED_LOJA+PED_PEDIDO+PED_ITEM")
	IndRegua("TRBPED",cNomInd14,"PED_PEDIDO")
	IndRegua("TRBPED",cNomInd15,"PED_VEND+PED_NOME+PED_CODCLI+PED_LOJA+PED_PEDIDO+PED_ITEM")
	dbClearIndex()

	dbSetIndex(cNomInd1  + OrdBagExt())
	dbSetIndex(cNomInd2  + OrdBagExt())
	dbSetIndex(cNomInd3  + OrdBagExt())
	dbSetIndex(cNomInd4  + OrdBagExt())
	dbSetIndex(cNomInd5  + OrdBagExt())
	dbSetIndex(cNomInd6  + OrdBagExt())
	dbSetIndex(cNomInd7  + OrdBagExt())
	dbSetIndex(cNomInd8  + OrdBagExt())
	dbSetIndex(cNomInd9  + OrdBagExt())
	dbSetIndex(cNomInd10 + OrdBagExt())
	dbSetIndex(cNomInd11 + OrdBagExt())
	dbSetIndex(cNomInd12 + OrdBagExt())
	dbSetIndex(cNomInd13 + OrdBagExt())
	dbSetIndex(cNomInd14 + OrdBagExt())
	dbSetIndex(cNomInd15 + OrdBagExt())
Return
/*/
+----------+----------+-------+-----------------------+------+-----------+
|Função    |Os200Junta| Autor | Eduardo Riera         | Data |29.10.2001 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Rotina de agrupamento de cargas                              |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|Nenhum                                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Retorno   |Nenhum                                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo controlar a interface com o    |
|          |usuario.                                                     |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Uso       | Distribuicao                                                |
+----------+-------------------------------------------------------------+
*/
User Function Os200Junta()
	Local cCodCarOri := DAK->DAK_COD
	Local cRoteirOri := DAK->DAK_ROTEIR
	Local cCaminhOri := DAK->DAK_CAMINH
	Local cMotoriOri := DAK->DAK_MOTORI
	Local cSeqCarOri := DAK->DAK_SEQCAR
	Local cCodCarDes := CriaVar("DAK_COD",.F.)
	Local cRoteirDes := CriaVar("DAK_ROTEIR",.F.)
	Local cCaminhDes := CriaVar("DAK_CAMINH",.F.)
	Local cMotoriDes := CriaVar("DAK_MOTORI",.F.)
	Local cSeqCarDes := CriaVar("DAK_SEQCAR",.F.)
	Local aAreaSC9   := {}
	Local dDatCarOri := DAK->DAK_DATA
	Local dDatCarDes := CriaVar("DAK_DATA",.F.)
	Local lJunta     := .T.
	Local cSeekSC9   := ''

	Local oDlg

	If DAK->DAK_ACECAR == '1' .Or. OsBlqExec(DAK->DAK_COD,DAK->DAK_SEQCAR) .Or. (DAK->(FieldPos('DAK_BLQCAR'))>0 .And. DAK->DAK_BLQCAR == '1')
		Aviso(OemtoAnsi(STR0121),OemtoAnsi(STR0123),{OemtoAnsi(STR0122)})
		Return(.F.)
	EndIf

	If IntDL()
		//+-------------------------------------------------------------------+
		//|Nao permite agutinar Cargas Unitizadas quando utilizar WMS         |
		//+-------------------------------------------------------------------+
		If DAK->DAK_FLGUNI == '1'
			Aviso('SIGAWMS', STR0147, {'Ok'}) //'Esta Carga ja foi Unitizada. A aglutinacao so sera permitida apos o estorno desta Unitizacao.'
			Return(.F.)
		EndIf
		//+-------------------------------------------------------------------------------------+
		//|Nao permite agutinar Cargas quando utilizar WMS e o Servico jah tiver sido executado |
		//+-------------------------------------------------------------------------------------+
		aAreaSC9 := SC9->(GetArea())
		SC9->(dbSetOrder(5)) //-- C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT
		If SC9->(MsSeek(cSeekSC9:=xFilial('SC9')+DAK->DAK_COD+DAK->DAK_SEQCAR, .F.))
			Do While !SC9->(Eof())  .And. cSeekSC9 == SC9->C9_FILIAL+SC9->C9_CARGA+SC9->C9_SEQCAR
				If !Empty(SC9->C9_SERVIC) .And. (SC9->C9_STSERV $'23')
					Aviso('SIGAWMS', 'Esta Carga possui um servico de WMS executado. A aglutinacao so sera permitida apos o estorno deste Servico.', {'Ok'})
					lJunta     := .F.
					Exit
				EndIf
				SC9->(dbSkip())
			EndDo
		EndIf
		SC9->(dbSetOrder(aAreaSc9[2]))
		SC9->(dbGoto(aAreaSc9[3]))
		If !lJunta
			Return(.F.)
		EndIf
	EndIf
	//+--------------------------------------------------------------+
	//| Dialog Principal.                                  |
	//+--------------------------------------------------------------+
	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0064) FROM 000,000 TO 260,380 OF oMainWnd PIXEL //"Agrupa Cargas"
	@ 004,004 TO 102,090 OF oDlg PIXEL LABEL OemToAnsi(STR0065)
	@ 016,008 SAY OemToAnsi(STR0014) OF oDlg PIXEL //"CARGA"
	@ 016,038 MSGET cCodCarOri WHEN .F. OF oDlg PIXEL
	@ 030,008 SAY RetTitle("DAK_SEQCAR") OF oDlg PIXEL
	@ 030,038 MSGET cSeqCarOri WHEN  .F. OF oDlg PIXEL
	@ 044,008 SAY OemToAnsi(STR0067) OF oDlg PIXEL //"ROTA"
	@ 044,038 MSGET cRoteirOri WHEN .F.OF oDlg PIXEL
	@ 058,008 SAY OemToAnsi(STR0068) OF oDlg PIXEL //"VEICULO"
	@ 058,038 MSGET cCaminhOri WHEN .F. OF oDlg PIXEL
	@ 072,008 SAY OemToAnsi(STR0069) OF oDlg PIXEL //"MOTORISTA"
	@ 072,038 MSGET cMotoriOri WHEN .F. OF oDlg PIXEL
	@ 086,008 SAY OemToAnsi(STR0070) OF oDlg PIXEL //"DATA"
	@ 086,038 MSGET dDatcarOri WHEN .F. OF oDlg PIXEL

	@ 004,094 TO 102,180 OF oDlg PIXEL LABEL OemToAnsi(STR0071)
	@ 016,098 SAY OemToAnsi(STR0066) OF oDlg PIXEL //"CARGA"
	@ 016,128 MSGET cCodCarDes VALID Os200VldCg(cCodCarDes,@cSeqCarDes,cCodCarOri,cSeqCarOri,dDatCarOri,@cRoteirDes,@cCaminhDes,@cMotOriDes,@dDatCarDes) F3 "DAK" OF oDlg PIXEL
	@ 030,098 SAY RetTitle("DAK_SEQCAR") OF oDlg PIXEL
	@ 030,128 MSGET cSeqCarDes VALID Os200VldCg(cCodCarDes,cSeqCarDes,cCodCarOri,cSeqCarOri,dDatCarOri,@cRoteirDes,@cCaminhDes,@cMotOriDes,@dDatCarDes) OF oDlg PIXEL
	@ 044,098 SAY OemToAnsi(STR0067) OF oDlg PIXEL //"ROTA"
	@ 044,128 MSGET cRoteirDes WHEN .F.OF oDlg PIXEL
	@ 058,098 SAY OemToAnsi(STR0068) OF oDlg PIXEL //"CAMINHAO"
	@ 058,128 MSGET cCaminhDes WHEN  .F. OF oDlg PIXEL
	@ 072,098 SAY OemToAnsi(STR0069) OF oDlg PIXEL //"MOTORISTA"
	@ 072,128 MSGET cMotoriDes WHEN .F. OF oDlg PIXEL
	@ 086,098 SAY OemToAnsi(STR0070) OF oDlg PIXEL //"DATA"
	@ 086,128 MSGET dDatCarDes WHEN .F. OF oDlg PIXEL

	DEFINE SBUTTON FROM 108,115 TYPE 1 ENABLE OF oDlg ACTION( u_OSAgrCarga({{cCodCarOri,cSeqCarOri}},cCodCarDes,cSeqCarDes),oDlg:End() )
	DEFINE SBUTTON FROM 108,150 TYPE 2 ENABLE OF oDlg ACTION( oDlg:End() )

	ACTIVATE MSDIALOG oDlg CENTERED
Return(.T.)
/*
+----------+----------+-------+-----------------------+------+-----------+
|Função    |OSAgrCarga| Autor | Eduardo Riera         | Data |29.10.2001 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Rotina de atualizacao do processo de agrupamento de cargas   |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|ExpA1: Array com as cargas de origem                         |
|          |       [1] Codigo da Carga                                   |
|          |       [2] Sequencia da Carga                                |
|          |ExpC2: Carga de Destino                                      |
|          |ExpC3: Sequencia da carga de Destino                         |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Retorno   |Nenhum                                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo atualizar os dados necessarios |
|          |para agrupar as cargas                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Uso       | Distribuicao                                                |
+----------+-------------------------------------------------------------+
*/
User Function OSAgrCarga(aOrigem,cCarga,cSeqCar)
	Local aArea     := GetArea()
	Local aStruDAI  := {}
	Local aCarga    := {}
	Local aItens    := {}
	Local aCliente  := {}
	Local lQuery    := .F.

	Local cQuery    := ""
	Local cAliasDAI := "DAI"
	Local cCodCli   := ""
	Local cLoja     := ""
	Local cSeqAnt   := ""
	LocaL cSeqProx  := ""
	Local cCpoPeso  := IIf(Getmv("MV_PESOCAR")=="L","B1_PESO","B1_PESBRU")
	Local cFilPed   := ""
	Local cPedido   := ""
	Local cEndereco := ""

	Local nX        := 0
	Local nY        := 0
	Local nPeso     := 0
	Local nCapVol   := 0
	Local nCapArm   := 0
	Local ISNULLCarga  := 0
	Local nRecSC9   := 0
	Local nTipoOper := OsVlEntCom()
	Local nSeqTemp  := 0
	Local nPosPedOri:= 0

	Local cFilPV    := ""

	Local cCargaAnt := ''

	Begin Transaction
		//+--------------------------------------------------------------+
		//| Inicio do processamento das cargas                           |
		//+--------------------------------------------------------------+

		cQryC  := ""
		cQryC  += " SELECT DISTINCT(C9_AGREG) AS AGREG  "
		cQryC  += "   FROM "+RETSQLNAME("SC9")+" SC9  "
		cQryC  += " WHERE C9_CARGA = '"+cCarga+"' "
		cQryC  += "   AND D_E_L_E_T_ = ' '"
		TcQuery cQryC New Alias "cTraC"
		dbselectarea("cTraC")
		AgregAnt := cTraC->AGREG
		cTraC->(DbCloseArea())

		aAdd(aCarga,cCarga+cSeqCar)
		For nX := 1 To Len(aOrigem)
			aAdd(aCarga,aOrigem[nX][1]+aOrigem[nX][2])
			//+--------------------------------------------------------------+
			//| Exclui as cargas de origem                                   |
			//+--------------------------------------------------------------+
			dbSelectArea("DAK")
			dbSetOrder(1)
			If MsSeek(xFilial("DAK")+aOrigem[nX][1]+aOrigem[nX][2])
				RecLock("DAK")
				dbDelete()
			EndIf
		Next nX
		//+--------------------------------------------------------------+
		//| Atualiza os dados da carga de destino                        |
		//+--------------------------------------------------------------+
		If MsSeek(xFilial("DAK")+cCarga+cSeqCar)

			//+--------------------------------------------------------------+
			//| Busca o endereco padrao da carga                             |
			//+--------------------------------------------------------------+
			cEndereco := u_Om200EndOri(cCarga,cSeqCar)

			//+--------------------------------------------------------------+
			//| Atualizo variaveis com os dados da carga origem              |
			//+--------------------------------------------------------------+
			RecLock("DAK")
			DAK->DAK_JUNTOU := "JUNTOU"
			DAK->DAK_PESO   := 0
			DAK->DAK_CAPVOL := 0
			DAK->DAK_VALOR  := 0
			DAK->DAK_PTOENT := 0
			//+--------------------------------------------------------------+
			//| Selecao dos itens das cargas para coloca-las em ordem        |
			//+--------------------------------------------------------------+
			For nX := 1 To 2
				dbSelectArea("DAI")
				dbSetOrder(1)
				lQuery    := .T.
				cAliasDAI := "Oms200Proc"
				aStruDAI  := DAI->(dbStruct())

				cQuery := "SELECT DAI.*,DAI.R_E_C_N_O_ DAIRECNO "
				cQuery += "FROM "+RetSqlName("DAI")+" DAI "
				cQuery += "WHERE DAI.DAI_FILIAL='"+xFilial("DAI")+"' AND "
				cQuery += "DAI.DAI_COD='"+SubStr(aCarga[nX],1,6)+"' AND "
				cQuery += "DAI.DAI_SEQCAR='"+SubStr(aCarga[nX],7)+"' AND "
				cQuery += "DAI.D_E_L_E_T_=' ' "
				cQuery += "ORDER BY "+SqlOrder(DAI->(IndexKey()))

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAI,.T.,.T.)

				For nY := 1 To Len(aStruDAI)
					If aStruDAI[nY][2]<>"C"
						TcSetField(cAliasDAI,aStruDAI[nY][1],aStruDAI[nY][2],aStruDAI[nY][3],aStruDAI[nY][4])
					EndIf
				Next nY

				While ( !Eof() .And. (cAliasDAI)->DAI_FILIAL==xFilial("DAI") .And.;
				(cAliasDAI)->DAI_COD+(cAliasDAI)->DAI_SEQCAR==aCarga[nX] )

					nSeqTemp++

					aAdd(aItens,{ (cAliasDAI)->DAI_COD,;
					(cAliasDAI)->DAI_SEQCAR,;
					StrZero(nSeqTemp,6),;
					(cAliasDAI)->DAI_CLIENT,;
					(cAliasDAI)->DAI_LOJA,;
					(cAliasDAI)->DAI_PEDIDO,;
					(cAliasDAI)->DAI_ROTEIR,;
					(cAliasDAI)->DAI_PERCUR,;
					(cAliasDAI)->DAI_ROTA,;
					(cAliasDAI)->DAIRECNO,;
					xFilial("DAI"),;
					(cAliasDAI)->DAI_PEDIDO})

					dbSelectArea(cAliasDAI)
					dbSkip()

				EndDo
				If lQuery
					dbSelectArea(cAliasDAI)
					dbCloseArea()
					dbSelectArea("DAI")
				EndIf
			Next nX
			//+--------------------------------------------------------------+
			//| Marca os pedidos repetidos para delecao                      |
			//+--------------------------------------------------------------+
			For nX := 1 To Len(aItens)
				cPedido := aItens[nX][12]+aItens[nX][6]
				If aItens[nX][11]<>"z"
					While ( nY := aScan(aItens,{|x| x[12]+x[6]==cPedido .And. x[11]=="z" }) )>0
						aItens[nY][6] := ""
					EndDo
				Else
					nX := Len(aItens)+1
				EndIf
			Next nX

			//+--------------------------------------------------------------+
			//| Pedidos iguais devem permancer na mesma sequencia            |
			//+--------------------------------------------------------------+
			For nX := 1 To Len(aItens)
				cFilPed := aItens[nX][12]
				cPedido := aItens[nX][13]
				If aItens[nX][11]<>"z"
					nY := 0
					While (nY := aScan(aItens,{|x| x[12] == cFilPed .And. x[13]==cPedido .And. x[11]=="z" },nY+1))>0
						aItens[nY][3] := aItens[nX][3]
					EndDo
				Else
					nX := Len(aItens)+1
				EndIf
			Next nX

			//+--------------------------------------------------------------+
			//| Clientes iguais deve permancer na mesma sequencia            |
			//+--------------------------------------------------------------+
			For nX := 1 To Len(aItens)
				cFilPed := aItens[nX][12]
				cCodCli := aItens[nX][4]
				cLoja   := aItens[nX][5]
				If aItens[nX][11]<>"z"
					nY := 0
					While (nY := aScan(aItens,{|x| x[12] == cFilPed .And. x[4]==cCodCli .And. x[5]==cLoja .And. x[11]=="z" },nY+1))>0
						aItens[nY][3] := aItens[nX][3]
					EndDo

				Else
					nX := Len(aItens)+1
				EndIf
			Next nX
			//+--------------------------------------------------------------+
			//| Ordena os itens da carga                                     |
			//+--------------------------------------------------------------+

			aItens := aSort(aItens,,,{|x,y| x[2]+x[3]+x[7]+x[8]+x[9]+X[6]+x[11] < y[2]+y[3]+y[7]+y[8]+y[9]+y[6]+y[11] })
			//+--------------------------------------------------------------+
			//| Renumera a sequencia de entrega                              |
			//+--------------------------------------------------------------+

			cProxSeq := "000001"

			For nX := 1 To Len(aItens)
				cSeqAnt       := aItens[nX][13]+aItens[nX][3]
				aItens[nX][3] := cProxSeq
				If cSeqAnt <> aItens[Min(nX+1,Len(aItens))][13]+aItens[Min(nX+1,Len(aItens))][3]
					cProxSeq := Soma1(cProxSeq)
				EndIf
			Next nX

			cProxSeq := "000005"
			For nX := 1 To Len(aItens)
				aItens[nX][3] := cProxSeq
				cPedido := aItens[nX][12]+aItens[nX][13]

				If cPedido <> aItens[Min(nX+1,Len(aItens))][12]+aItens[Min(nX+1,Len(aItens))][13]
					cProxSeq := Soma1(cProxSeq)
					While Mod(Val(cProxSeq),5)<>0
						cProxSeq := Soma1(cProxSeq)
					EndDo
				Endif
			Next nX

			//+--------------------------------------------------------------+
			//| Atualiza os dados da nova carga                              |
			//+--------------------------------------------------------------+
			For nX := 1 To Len(aItens)

				nPeso    := 0
				nCapVol  := 0
				ISNULLCarga := 0

				//+--------------------------------------------------------------+
				//| Posiciona registros                                          |
				//+--------------------------------------------------------------+
				dbSelectArea("DAI")
				MsGoto(aItens[nX][10])

				//+--------------------------------------------------------------+
				//| Procura no SC9 o registro correspondente e atualiza a carga  |
				//+--------------------------------------------------------------+
				dbSelectArea("SC9")
				dbSetOrder(5)

				//cFilPv := IIf(nTipoOper<>1,DAI->DAI_FILPV,xFilial("SC9"))
				cFilPv := xFilial("SC9")

				//If MsSeek(OsFilial("SC9",cFilPv)+DAI->DAI_COD+DAI->DAI_SEQCAR+DAI->DAI_SEQUEN)
				If MsSeek(xFilial("SC9")+DAI->DAI_COD+DAI->DAI_SEQCAR+DAI->DAI_SEQUEN)
					//While !Eof() .And. SC9->C9_FILIAL == OsFilial("SC9",cFilPv) .And.;
					While !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.;
					SC9->C9_CARGA == DAI->DAI_COD .And.;
					SC9->C9_SEQCAR == DAI->DAI_SEQCAR .And.;
					SC9->C9_SEQENT == DAI->DAI_SEQUEN

						SC9->(dbSkip())
						nRecSc9 := SC9->(Recno())
						SC9->(dbSkip(-1))

						If DAI->DAI_PEDIDO == SC9->C9_PEDIDO

							//+--------------------------------------------------------------+
							//| Apaga os Servicos de WMS a executar                          |
							//+--------------------------------------------------------------+
							If IntDL(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC)
								MADeletDCF()
							EndIf

							Reclock("SC9")
							SC9->C9_CARGA  := DAK->DAK_COD
							SC9->C9_SEQCAR := DAK->DAK_SEQCAR
							SC9->C9_SEQENT := aItens[nX][3]
							SC9->C9_ENDPAD := cEndereco
							//SC9->C9_AGREG  := AgregAnt // Linha adicionada em 06/02/06 por Alexandre Panetto
							SC9->(MsUnlock())

							//Bloco adcionado por Alexandre Panetto em 06/02/2006
							SC5->(DbSetOrder(1))
							SC5->(DbSeek(SC9->C9_FILIAL+SC9->C9_PEDIDO))
							RecLock("SC5",.F.)
							//SC5->C5_YCARGA := AgregAnt
							//SC5->C5_YORDEM := right(SC9->C9_SEQENT,4)
							SC5->(MsUnlock())

							//+--------------------------------------------------------------+
							//| Gera os Servicos com a nova Carga                            |
							//+--------------------------------------------------------------+
							If IntDL(SC9->C9_PRODUTO) .And. !Empty(SC9->C9_SERVIC) .And. SC9->C9_TPCARGA=='3'
								CriaDCF('SC9')
							EndIf

							//+--------------------------------------------------------------+
							//| Pesquisa o Arquivo SF2 (Header da Nota Fiscal de Saida).     |
							//+--------------------------------------------------------------+
							If !Empty(SC9->C9_NFISCAL)
								dbSelectArea("SF2")
								dbSetOrder(1)
								//If MsSeek(OsFilial("SF2",SC9->C9_FILIAL)+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE+SC9->C9_LOJA)
								If MsSeek(xFilial("SF2")+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE+SC9->C9_LOJA)
									RecLock("SF2", .F.)
									SF2->F2_CARGA  := DAK->DAK_COD
									SF2->F2_SEQCAR := DAK->DAK_SEQCAR
								EndIf
							EndIf
							//+--------------------------------------------------------------+
							//| Calcula os dados acumulados do DAI/DAK                       |
							//+--------------------------------------------------------------+
							dbSelectArea("SB1")
							dbSetOrder(1)
							//MsSeek(OsFilial("SB1",SC9->C9_FILIAL)+SC9->C9_PRODUTO)
							MsSeek(xFilial("SB1")+SC9->C9_PRODUTO)

							nPeso    += ( SB1->(FieldGet(FieldPos(cCpoPeso))) * SC9->C9_QTDLIB )
							nCapVol  += ( OsPrCapArm(SB1->B1_COD,SC9->C9_FILIAL) * SC9->C9_QTDLIB )
							ISNULLCarga += ( SC9->C9_QTDLIB * SC9->C9_PRCVEN )

						Endif

						//+--------------------------------------------------------------+
						//| Vai para o proximo registro do SC9                           |
						//+--------------------------------------------------------------+
						SC9->(MsGoto(nRecSc9))

					EndDo

				EndIf
				//+--------------------------------------------------------------+
				//| Verifica se o pedido de venda ja possui um item vinculado    |
				//+--------------------------------------------------------------+
				If Empty(aItens[nX][6])
					//+--------------------------------------------------------------+
					//| Estorna o item duplicado do DAI e posiciona no novo item     |
					//+--------------------------------------------------------------+

					//cPedido := If(nTipoOper<>1,(cAliasDAI)->DAI_FILPV,xFilial("SC9"))+DAI->DAI_PEDIDO
					cPedido := xFilial("SC9")+DAI->DAI_PEDIDO

					dbSelectArea("DAI")
					Reclock("DAI")
					dbDelete()
					DAI->(MsUnLock())

					nPosPedOri := aScan(aItens,{|x| x[12]+x[6]==cPedido .And. x[11]==" " })

					If nPosPedOri > 0
						dbSelectArea("DAI")
						MsGoto(aItens[nPosPedOri][10])
					Endif

					nPeso   += DAI->DAI_PESO
					nCapVol += DAI->DAI_CAPVOL

				EndIf

				//+--------------------------------------------------------------+
				//| Atualiza os dados do item da carga                           |
				//+--------------------------------------------------------------+
				Reclock("DAI")
				DAI->DAI_COD    := DAK->DAK_COD
				DAI->DAI_SEQCAR := DAK->DAK_SEQCAR
				DAI->DAI_SEQUEN := aItens[nX][3]
				DAI->DAI_CARORI := aItens[nX][1]
				DAI->DAI_PESO   := nPeso
				DAI->DAI_CAPVOL := nCapVol

				//+--------------------------------------------------------------+
				//| Atualiza os dados da carga                                   |
				//+--------------------------------------------------------------+
				nY := aScan(aCliente,DAI->DAI_CLIENT+DAI->DAI_LOJA)
				RecLock("DAK")
				DAK->DAK_PESO   += nPeso
				DAK->DAK_CAPVOL += nCapVol
				DAK->DAK_VALOR  += ISNULLCarga
				DAK->DAK_PTOENT += If(nY>0,0,1)

				aAdd(aCliente,DAI->DAI_CLIENT+DAI->DAI_LOJA)

			Next nX
		EndIf
	End Transaction
	RestArea(aArea)
Return(.T.)
/*
+----------+----------+-------+-----------------------+------+-----------+
|Função    |Oms200VlCg| Autor | Eduardo Riera         | Data |29.10.2001 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Validacao da rotina de agrupamento de cargas                 |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|ExpC1: Carga de Origem                                       |
|          |ExpC2: Sequencia de Origem                                   |
|          |ExpC3: Carga de destino                                      |
|          |ExpC4: Sequencia de destino                                  |
|          |ExpD5: Data de Origem                                        |
|          |ExpC6: Roteiro de Destino                                    |
|          |ExpC7: Caminhao de Destino                                   |
|          |ExpC8: Motorista de Destino                                  |
|          |ExpD9: Data de Destino                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Retorno   |Nenhum                                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo validar os dados informados na |
|          |interface                                                    |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Uso       | Distribuicao                                                |
+----------+-------------------------------------------------------------+
*/
Static Function Os200VldCg(cCodCarDes,cSeqCarDes,cCodCarOri,cSeqCarOri,dDatCarOri,cRoteirDes,cCaminhDes,cMotoriDes,dDatCarDes)
	Local aArea    := GetArea()
	Local aAreaDAK := DAK->(GetArea())
	Local aAreaSC9 := {}
	Local cSeekSC9 := ''
	Local lRet     := .T.
	Local cStatOri := ""
	Local cStatDes := ""

	cSeqCarDes := If(Empty(cSeqCarDes),DAK->DAK_SEQCAR,cSeqCarDes)

	dbSelectArea("DAK")
	dbSetOrder(1)
	If MsSeek(xFilial("DAK")+cCodCarOri+cSeqCarOri)
		cStatOri := DAK->DAK_FEZNF
	Endif

	//+--------------------------------------------------------------+
	//| Valida no cadastro de cargas o codigo de carga informado     |
	//+--------------------------------------------------------------+
	dbSelectArea("DAK")
	dbSetOrder(1)
	If MsSeek(xFilial("DAK")+cCodCarDes+cSeqCarDes)

		// +------------------------------------------------------------------------+
		// | Verifica se o Acerto de Cargas realizado ou j  iniciado                |
		// +------------------------------------------------------------------------+
		If DAK->DAK_ACECAR == "1"
			Help(" ",1,"OMS320JAAC")
			lRet := .F.
		Else
			cStatDes := DAK->DAK_FEZNF
		Endif
	Else
		Help(" ",1,"DS2602131")
		lRet := .F.
	Endif

	If lRet

		Do Case
			Case DAK->DAK_COD == cCodCarOri .And. !Empty(cSeqCarOri) .And. DAK->DAK_SEQCAR == cSeqCarOri
			Help(" ",1,"DS2602134")
			lRet := .F.
			Case !Empty(DAK_JUNTOU) .And. DAK_JUNTOU != "JUNTOU" .And. DAK_JUNTOU != "MANUAL" .And. DAK_JUNTOU != "ASSOCI"
			Help(" ",1,"DS2602135")
			lRet := .F.
			Case cStatOri != cStatDes
			Help(" ",1,"DS2602136")
			lRet := .F.
			Case IntDL()
			//+-------------------------------------------------------------------+
			//|Nao permite agutinar Cargas Unitizadas quando utilizar WMS         |
			//+-------------------------------------------------------------------+
			If DAK->DAK_FLGUNI == '1'
				Aviso('SIGAWMS', STR0148, {'Ok'}) //'A Carga Destino ja foi Unitizada. A aglutinacao so sera permitida apos o estorno desta Unitizacao.'
				lRet := .F.
			Else
				//+-------------------------------------------------------------------------------------+
				//|Nao permite agutinar Cargas quando utilizar WMS e o Servico jah tiver sido executado |
				//+-------------------------------------------------------------------------------------+
				aAreaSC9 := SC9->(GetArea())
				SC9->(dbSetOrder(5)) //-- C9_FILIAL+C9_CARGA+C9_SEQCAR+C9_SEQENT
				If SC9->(MsSeek(cSeekSC9:=xFilial('SC9')+DAK->DAK_COD+DAK->DAK_SEQCAR, .F.))
					Do While !SC9->(Eof())  .And. cSeekSC9 == SC9->C9_FILIAL+SC9->C9_CARGA+SC9->C9_SEQCAR
						If !Empty(SC9->C9_SERVIC) .And. (SC9->C9_STSERV $'23')
							Aviso('SIGAWMS', 'A Carga Destino possui um servico de WMS executado. A aglutinacao so sera permitida apos o estorno deste Servico.', {'Ok'})
							lRet := .F.
							Exit
						EndIf
						SC9->(dbSkip())
					EndDo
				EndIf
				SC9->(dbSetOrder(aAreaSc9[2]))
				SC9->(dbGoto(aAreaSc9[3]))
			EndIf
		EndCase

	Endif

	If lRet
		cRoteirDes := DAK->DAK_ROTEIR
		cCaminhDes := DAK->DAK_CAMINH
		cMotoriDes := DAK->DAK_MOTORI
		dDatCarDes := DAK->DAK_DATA
	EndIf

	dbSetOrder(1)
	dbSelectArea("DAK")

	//+--------------------------------------------------------------+
	//| Restaura a entrada da rotina                                 |
	//+--------------------------------------------------------------+
	RestArea(aAreaDAK)
	RestArea(aArea)
Return(lRet)

/*
+----------+----------+-------+-----------------------+------+----------+
|Program   | Os200Leg | Autor | Henry Fila            | Data |23/01/2001|
+----------+----------+-------+-----------------------+------+----------+
|Descri‡Æo | Exibe a legenda dos status da carga                        |
+----------+------------------------------------------------------------+
|Retorno   | Nil                                                        |
+----------+------------------------------------------------------------+
|Parametros| Nenhum                                                     |
+----------+---------------+--------------------------------------------+
|   DATA   | Programador   |Manutencao efetuada                         |
+----------+---------------+--------------------------------------------+
|          |               |                                            |
+----------+---------------+--------------------------------------------+
*/
User Function Os200Leg()
	Local aLegenda := { { "BR_VERMELHO"  , OemToAnsi( STR0057 ) },; //"Faturada e acertos efetuados"
	{ "BR_VERDE"    , OemToAnsi( STR0058) },;  //"Totalmente em aberto"
	{ "BR_LARANJA"  , OemToAnsi( STR0059 ) } }

	If DAK->(FieldPos("DAK_BLQCAR")) > 0
		aAdd(aLegenda,{"BR_PRETO", OemtoAnsi( STR0141 ) } )
	EndIf

	BrwLegenda( cCadastro, OemToAnsi( "Status" ), aLegenda  ) //"Somente faturada e nao acertada"
Return( Nil )

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |OMSA200EPA|Autor  |Henry Fila          | Data |  06/01/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Busca enredeco padrao para os itens                        |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP6                                                        |
+----------+------------------------------------------------------------+
*/

Static Function Oms200ePad(aArrayMan,cEndereco)
	Local cBusca    := "",nc
	Local aArrayEnd := {}
	Local lEndereco := .T.
	Local nOpca     := 0
	Local cBitmap   := "PROJETOAP"
	Local cMens1    := ""
	Local cMens2    := ""
	Local cMens3    := ""
	Local cMens4    := ""
	Local cMens5    := ""
	Local lProcessa := .T.
	Local cDescEnd  := ""
	Local aRetPE     := {}
	Local lPergWMS   := .T.
	Local lSai       := .F.
	Local oDlg

	If lProcessa

		cBusca := aArrayMan[1,12]+aArrayMan[1,5]

		//+-----------------------------------------------------+
		//|Pego o primeiro endereco de um determinado pedido da |
		//|carga                                                |
		//+-----------------------------------------------------+

		dbSelectArea("SC9")
		dbSetOrder(1)
		If MsSeek(cBusca)
			cEndereco := SC9->C9_ENDPAD
		EndIf

		//+-------------------------------------------------------+
		//|Verifico se existem mais de um endereco entre os itens |
		//|dos pedidos, se existirem, trago o endereco em branco  |
		//|como sugestao, caso contrario, trago o proprio endereco|
		//+-------------------------------------------------------+
		If SuperGetMV('MV_WMSEOMS', .F., 'S') == 'S'
			For nC := 1 to Len(aArrayMan)

				cBusca := aArrayMan[nC,5]+aArrayMan[nC,5]

				dbSelectArea("SC9")
				dbSetOrder(1)
				If MsSeek(cBusca)
					While !Eof() .And. C9_FILIAL+C9_PEDIDO == cBusca

						If cEndereco != SC9->C9_ENDPAD
							lEndereco := .F.
							Exit
						EndIf

						dbSelectArea("SC9")
						dbSkip()
					EndDo

				EndIf

				If !lEndereco
					Exit
				EndIf

			Next
		Else
			cOMS200End := Space(Len(SC9->C9_ENDPAD))
			cEndereco  := Space(Len(SC9->C9_ENDPAD))
		EndIf

		//+-------------------------------------------------------+
		//|Se existirem enderecos diferentes trago o get em branco|
		//+-------------------------------------------------------+

		If !lEndereco
			cEndereco := Space(Len(SC9->C9_ENDPAD))
			cMens1 := OemtoAnsi(STR0084)
			cMens2 := OemtoAnsi(STR0085)
			cMens3 := OemtoAnsi(STR0086)
			cMens4 := OemtoAnsi(STR0087)
		Else
			cMens1 := OemtoAnsi(STR0084)
			cMens2 := OemtoAnsi(STR0088)
			cMens3 := OemtoAnsi(STR0089)
			cMens4 := OemtoAnsi(STR0090)
			cMens5 := OemtoAnsi(STR0091)
		EndIf

		cOMS200End := cEndereco

		//-- Permite a informacao do Endereco e da Estrutura de Origem via Ponto de Entrada
		If ExistBlock('OMSA200E')
			//-- Retorno esperado do RDMAKE
			//-- Array[1] = cOMS200End
			//-- Array[2] = cOMS200Est
			aRetPE := ExecBlock('OMSA200E', Nil, Nil, {SC9->C9_PRODUTO, SC9->C9_PEDIDO})
			If Len(aRetPE) > 0
				lPergWMS   := .F.
				cOMS200End := aRetPE[1]
				cOMS200Est := aRetPE[2]
			EndIf
		EndIf
		If lPergWMS .And. (Type('l250Auto') == 'U' .Or. (Type('l250Auto') == 'L' .And. !l250Auto))
			oDlg := Nil
			Do While (Empty(cOMS200End) .Or. Empty(cOMS200Est))
				DEFINE MSDIALOG oDlg FROM 0, 0 TO 140, 295 TITLE 'SIGAWMS' PIXEL
				@ 20, 10 SAY   'Identifique o Destino do Servico de WMS:' OF oDlg PIXEL
				@ 35, 10 SAY   'Endereco'                                 OF oDlg PIXEL //'Endereco'
				@ 35, 50 MSGET cOMS200End PICTURE PesqPict('SBE', 'BE_LOCALIZ') F3 'SBE' VALID ExistCpo('SBE', cOMS200End, 9) OF oDlg PIXEL
				@ 50, 10 SAY   'Estrutura Fisica'                         OF oDlg PIXEL //'Estrutura Fisica'
				@ 50, 50 MSGET cOMS200Est PICTURE PesqPict('SBE', 'BE_ESTFIS')  F3 'DC8' VALID ExistCpo('DC8', cOMS200Est) OF oDlg PIXEL
				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||If(A240VldWMS(cOMS200End,cOMS200Est), (lSai:=.T.,oDlg:End()), lSai:=.F.)}, {||If(A240VldWMS(cOMS200End,cOMS200Est), (lSai:=.T.,oDlg:End()), lSai:=.F.)})
				If lSai .Or. (!lSai .And. A240VldWMS(cOMS200End,cOMS200Est)) //-- Quando pressionar "CANCELA" na dialog
					Exit
				EndIf
			EndDo
		EndIf

		cEndereco := cOMS200End
		nOpca     := 1
		/*
		DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0113) FROM 0,0 TO 180,600 OF oMainWnd PIXEL //"Endereco padrao da carga"

		@ 0 , 0 BITMAP oBmp RESNAME cBitMap oF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

		@ 03, 48 SAY cMens1 Of oDlg Pixel
		@ 10, 48 SAY cMens2 Of oDlg Pixel
		@ 17, 48 SAY cMens3 Of oDlg Pixel
		@ 24, 48 SAY cMens4 Of oDlg Pixel
		@ 31, 48 SAY cMens5 Of oDlg Pixel

		@ 40,040 TO 40,500 Of oDlg Pixel

		@ 048,048 Say OemtoAnsi(STR0114) Of oDlg PIXEL //"Endereco"
		@ 048,072 MSGet cEndereco  F3 "SBE" Valid Oms200VlEnd(cEndereco,@cDescEnd) Size 56,10 Of oDlg PIXEL
		@ 048,130 MSGet cDescEnd  Size 120,10 Of oDlg When .F. PIXEL

		DEFINE SBUTTON FROM 70, 235 TYPE 1 ACTION( nOpca := 1,oDlg:End() ) ENABLE OF oDlg
		DEFINE SBUTTON FROM 70, 265 TYPE 2 ACTION( oDlg:End() ) ENABLE OF oDlg

		ACTIVATE MSDIALOG oDlg CENTERED
		*/

	EndIf
Return (nOpca == 1)

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |Os200liber|Autor  |Henry Fila          | Data |  06/01/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Liberacao automatica de pedidos                            |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP6                                                        |
+----------+------------------------------------------------------------+
*/

User Function Os200Liber(cAlias,nReg,nOpc)
	Pergunte("MTA440",.F.)
	//+------------------------------------------------------+
	//| Transfere locais para a liberacao                    |
	//+------------------------------------------------------+
	lTransf  :=IIF(mv_par01==1,.T.,.F.)
	//+------------------------------------------------------+
	//| Libera Parcial pedidos de vendas                     |
	//+------------------------------------------------------+
	lLiber   :=IIF(mv_par02==1,.T.,.F.)
	A440Automa(cAlias,nReg,nOpc)
Return

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |Os200Motor|Autor  |Henry Fila          | Data |  06/01/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Verifica o motorista informado na associacao               |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP6                                                        |
+----------+------------------------------------------------------------+
*/

User Function Os200Motor(cMotorista,cNomeMot)
	Local lRet := .T.
	//+------------------------------+
	//|Busca nome do motorista padrao|
	//+------------------------------+
	DA4->(dbSetOrder(1))
	If cMotorista != Nil
		If DA4->(MsSeek(xFilial()+cMotorista))
			cNomeMot := DA4->DA4_NOME
			oNomeMot:Refresh()
		Else
			Help(" ",1,"REGNOIS")
			lRet := .F.
		EndIf
	EndIf
Return(lRet)

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |Oms200Aju |Autor  |Henry Fila          | Data |  07/05/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Busca ajudante e traz seu respectivo nome                  |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

User Function Oms200Aju(cAjuda,cDescAju)
	Local lRet := .T.
	Local aArea := GetArea()

	If !Empty(cAjuda)
		DAU->(dbSetOrder(1))
		If DAU->(MsSeek(xFilial("DAU")+cAjuda))
			cDescAju := DAU->DAU_NOME
		Else
			Help(" ",1,"REGNOIS")
			lRet := .F.
		EndIf
	EndIf
	RestArea(aArea)
Return(lRet)


/*
+----------+------------+-------+--------------------+------+-----------+
|Programa  |OmsVisGraph |Autor  |Henry Fila          | Data |  07/05/01 |
+----------+------------+-------+--------------------+------+-----------+
|Desc.     | Busca endereco padrao e traz a descricao                   |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametros|aExp1 : Array das cargas                                    |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

User Function OmsVisGraph(aArrayCarga,cMarca)
	Local nPosCarga  := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})
	Local nPerKg     := 0,nx
	Local nPerM3     := 0
	Local nPerPto    := 0
	Local cVeiculo  := ""
	Local oGraph
	Local aSize      := MsAdvSize( .F. )
	Local aPosObj    := {}
	Local aObjects   := {}
	Local aColors    := {}
	Local nColor     := 1
	Local aSeries    := {}
	Local nPosSerie  := 0
	Local nTrbRec    := TRBPED->(Recno())
	Local oFont
	Local aCbx       := {OemtoAnsi(STR0103),OemtoAnsi(STR0104),OemtoAnsi(STR0105),OemtoAnsi(STR0106),OemtoAnsi(STR0107)}
	Local nModelo    := 1
	Local cCbx       := ""

	aAdd( aColors,  CLR_HBLUE     )
	aAdd( aColors,  CLR_HGREEN    )
	aAdd( aColors,  CLR_HCYAN     )
	aAdd( aColors,  CLR_HRED      )
	aAdd( aColors,  CLR_HMAGENTA  )
	aAdd( aColors,  CLR_YELLOW    )
	aAdd( aColors,  CLR_WHITE     )
	aAdd( aColors,  CLR_BLACK     )
	aAdd( aColors,  CLR_BLUE      )
	aAdd( aColors,  CLR_GREEN     )
	aAdd( aColors,  CLR_CYAN      )
	aAdd( aColors,  CLR_RED       )
	aAdd( aColors,  CLR_MAGENTA   )
	aAdd( aColors,  CLR_BROWN     )
	aAdd( aColors,  CLR_HGRAY     )
	aAdd( aColors,  CLR_LIGHTGRAY )
	aAdd( aColors,  CLR_GRAY      )

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0101)  FROM 09,0 TO 20,40 OF oMainWnd  //Dados do Grafico

	@ 000, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 30, 1000 NOBORDER WHEN .F. PIXEL ADJUST
	@ 014, 35 MSCOMBOBOX oCbx VAR cCbx ITEMS aCbx SIZE 115, 65 OF oDlg PIXEL ON CHANGE nModelo := oCbx:nAt
	DEFINE SBUTTON oBut1 FROM 062, 120 TYPE 1 ACTION ( nOpca := 1, oDlg:End() )  ENABLE of oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	aSize := MsAdvSize()
	aAdd( aObjects, { 100, 020, .T., .F. } )
	aAdd( aObjects, { 100, 100, .T., .T., .T. } )
	aAdd( aObjects, { 100, 15, .T., .F. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	DEFINE FONT oFontLbl SIZE 10,0 BOLD
	DEFINE MSDIALOG oDlg FROM aSize[7],00 TO aSize[6],aSize[5] TITLE OemtoAnsi(STR0102) OF oMainWnd PIXEL //Grafico de Disposicao da carga

	If nPosCarga > 0
		cVeiculo := aArrayCarga[nPosCarga,CARGA_VEIC]
	EndIf

	Do Case
		Case nModelo == 1
		@ 10,10 Say OemtoAnsi(STR0103) Of oDlg PIXEL FONT oFontLbl //"Disposicao em Peso por produto na carga"
		Case nModelo == 2
		@ 10,10 Say OemtoAnsi(STR0104) Of oDlg PIXEL FONT oFontLbl  //"Disposicao em Volume por produto na carga"
		Case nModelo == 3
		@ 10,10 Say OemtoAnsi(STR0105) Of oDlg PIXEL FONT oFontLbl  //"Disposicao em Valor por produto na carga"
		Case nModelo == 4
		@ 10,10 Say OemtoAnsi(STR0106) Of oDlg PIXEL FONT oFontLbl  //"Ocupacao do Veiculo em Peso"
		Case nModelo == 5
		@ 10,10 Say OemtoAnsi(STR0107) Of oDlg PIXEL FONT oFontLbl  //"Ocupacao do Veiculo em Volume"

	EndCase

	@ aPosObj[2,1], aPosObj[2,2] MSGRAPHIC oGraph SIZE aPosObj[2,3], aPosObj[2,4] OF oDlg
	oGraph:SetMargins( 5, 5, 5, 5 )
	oGraph:SetGradient( GDBOTTOMTOP, CLR_HGRAY, CLR_WHITE )
	nSerie := oGraph:CreateSerie( 10 )

	If nModelo == 4 .Or. nModelo == 5

		If !Empty(cVeiculo)
			DA3->(dbSetOrder(1))
			If DA3->(MsSeek(xFilial("DA3")+cVeiculo))
				nPerM3 := Val(aArrayCarga[nPosCarga,CARGA_VOLUM])
				nPerKg := Val(aArrayCarga[nPosCarga,CARGA_PESO])
				oGraph:Add(nSerie,Iif(nModelo == 4,nPerKg,nPerM3) ,Iif(nModelo == 4,OemtoAnsi(STR0106),OemtoAnsi(STR0107)),aColors[ 1 ]) //"OCUPACAO EM KG"###"OCUPACAO EM VOLUME"
				oGraph:Add(nSerie,Iif(nModelo == 4,DA3->DA3_CAPACN-nPerKg ,DA3->DA3_VOLMAX-nPerM3) ,OemtoAnsi(STR0115),aColors[ 5 ]) //"LIVRE"      EndIf
			Endif
		EndIf
	Else
		//+------------------------------------------------------+
		//|Crio o acumulado por produto para passar par as series|
		//+------------------------------------------------------+
		dbSelectArea("TRBPED")
		dbGotop()
		While !Eof()
			If TRBPED->PED_MARCA == cMarca
				nPosSerie := Ascan(aSeries,{ |x| x[1] == Iif(1==2,TRBPED->PED_PEDIDO,TRBPED->PED_DESPRO)})
				If    nPosSerie == 0
					aAdd(aSeries,{Iif(1==2,TRBPED->PED_PEDIDO,TRBPED->PED_DESPRO),TRBPED->PED_PESO,TRBPED->PED_VOLUM,TRBPED->PED_VALOR})
				Else
					aSeries[nPosSerie][2] += TRBPED->PED_PESO
					aSeries[nPosSerie][3] += TRBPED->PED_VOLUM
					aSeries[nPosSerie][4] += TRBPED->PED_VALOR
				EndIf
			EndIf
			dbSkip()
		EndDo
		For nX := 1 to Len(aSeries)
			oGraph:Add(nSerie,Iif(nModelo == 1,aSeries[nX][2],Iif(nModelo == 2,aSeries[nX][3],Iif(nModelo == 3,aSeries[nX][4],aSeries[nX][2]))) ,aSeries[nX][1],aColors[ nColor ])
			nColor++
			If nColor > 18
				nColor := 1
			EndIf
		Next
	EndIf
	oGraph:l3D := .T.
	DEFINE SBUTTON FROM aPosObj[3,1],(aSize[5]/2)-33 TYPE 1 ACTION oDlg:End() ENABLE

	ACTIVATE MSDIALOG oDlg

	//+--------------------------------------------------------------+
	//|Volta a posicionar no registro corrente do arquivo de trabalho|
	//+--------------------------------------------------------------+
	dbSelectArea("TRBPED")
	dbGoto(nTrbRec)
Return

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |Oms200VlEn|Autor  |Henry Fila          | Data |  07/05/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     | Busca endereco padrao e traz a descricao                   |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP5                                                        |
+----------+------------------------------------------------------------+
*/

User Function Oms200VlEnd(cLocaliza,cDescEnd)
	Local lRet := .T.
	cDescEnd := SBE->BE_DESCRIC
Return(lRet)

/*
+----------+----------+-------+--------------------+------+-------------+
|Programa  |OMSA200Rot|Autor  |Henry Fila          | Data |  08/23/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     |Faz consistencia nas marcacoes na montagem da carga         |
|          |                                                            |
+----------+------------------------------------------------------------+
|Parametro |ExpA1 - Array das rotas                                     |
|          |ExpA2 - Array das Zonas                                     |
|          |ExpA3 - Array dos Setores                                   |
|          |ExpC4 - Rota corrente                                       |
|          |ExpC5 - Zona corrente                                       |
|          |ExpC6 - Setor corrente                                      |
|          |ExpC7 - Marca                                               |
+----------+------------------------------------------------------------+
|Uso       | AP6                                                        |
+----------+------------------------------------------------------------+
*/

Static Function Oms200Rot(aArrayRota,aArrayZona,aArraySetor,cRotaPed,cZonaPed,cSetorPed,cMarca)
	Local nRegTRB   := TRBPED->(Recno()),nx
	Local lDesSetor := .T.
	Local lDesZona  := .T.
	Local lDesRota  := .T.

	dbSelectArea("TRBPED")
	dbSetOrder(4)
	If MsSeek(cRotaPed+cZonaPed+cSetorPed)

		While !Eof() .And. TRBPED->PED_ROTA+TRBPED->PED_ZONA+TRBPED->PED_SETOR == ;
		cRotaPed+cZonaPed+cSetorPed

			If TRBPED->PED_MARCA == cMarca
				lDesSetor := .F.
				Exit
			EndIf

			dbSelectArea("TRBPED")
			dbSkip()

		EndDo

		If lDesSetor

			nPosSetor := Ascan(aArraySetor,{|x| x[3]+x[4]+x[5] == cRotaPed+cZonaPed+cSetorPed})
			aArraySetor[nPosSetor,2] := .F.

			For nX := 1 to Len(aArraySetor)
				If ( aArraySetor[nX,1] .And. aArraySetor[nX,2] )
					lDesZona := .F.
				EndIf
			Next

			If lDesZona

				nPosZona := Ascan(aArrayZona,{|x| x[3]+x[4] == cRotaPed+cZonaPed})
				aArrayZona[nPosZona,2] := .F.

				For nX := 1 to Len(aArrayZona)
					If ( aArrayZona[nX,1] .And. aArrayZona[nX,2] )
						lDesRota := .F.
					EndIf
				Next

				If lDesRota
					nPosRota := Ascan(aArrayRota,{|x| x[3] == cRotaPed})
					aArrayRota[nPosRota,2] := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	TRBPED->(dbgoto(nRegTrb))
	oCargas:Refresh()
	oRotas:Refresh()
	oZonas:Refresh()
	oSetores:Refresh()
	oMark:oBrowse:Refresh()
Return

/*
+----------+------------+-------+---------------------+------+------------+
| Fun‡…o   |D200VLCG2   |Autor  | Henry Fila          | Data | 02/07/1999 |
+----------+------------+-------+---------------------+------+------------+
| Descri‡…o| Valida a carga de destino selecionada                        |
+----------+--------------------------------------------------------------+
| Uso      | DFATA214                                                     |
+----------+------------------------------------------+------+------------+
| Revis„o  |                                          | Data |            |
+----------+------------------------------------------+------+------------+
*/
User Function D200VlCg2()
	Local lRet
	Local cAlias := Alias()
	Local nReg := Recno()

	//+--------------------------------------------------------------+
	//| Valida no cadastro de cargas o codigo de carga informado     |
	//+--------------------------------------------------------------+
	lRet := .T.
	dbSelectArea("DAK")
	dbSetOrder(1)
	MsSeek(xFilial("DAK")+M->DAI_COD)

	If Eof()
		Help(" ",1,"DS2602131")
		lRet := .F.
	ElseIf DAK->DAK_DATA <> M->DAK_DATA
		Help(" ",1,"DS2602132")
		lRet := .F.
	ElseIf !Empty(DAK_JUNTOU) .And. DAK_JUNTOU != "JUNTOU" .And. DAK_JUNTOU != "MANUAL" .And. DAK_JUNTOU != "ASSOCI"
		Help(" ",1,"DS2602135")
		lRet := .F.
	ElseIf GetMV("MV_MANCARG") == "N" .And. DAK->DAK_FEZNF == "1"
		Help(" ",1,"DS2602136")
		lRet := .F.
	Else
		// +------------------------------------------------------------------------+
		// | Verifico se o Acerto de Cargas realizado ou j  iniciado (DAN)          |
		// +------------------------------------------------------------------------+
		If DAK->DAK_ACECAR == "1"
			Help(" ",1,"DS2412133")
			lRet := .F.
		EndIf
		dbSetOrder(1)
		dbSelectArea("DAK")
	EndIf

	//+--------------------------------------------------------------+
	//| Reposiciona o registro original e retorna o resultado da val.|
	//+--------------------------------------------------------------+
	dbSelectArea(cAlias)
	dbgoto(nReg)
Return lRet

/*+----------+----------+-------+--------------------+------+-------------+
|Programa  |Os200Assoc|Autor  |Henry Fila          | Data |  03/09/01   |
+----------+----------+-------+--------------------+------+-------------+
|Desc.     |Associacao do motorista apos geracao de carga               |
|          |                                                            |
+----------+------------------------------------------------------------+
|Uso       | AP6                                                        |
+----------+------------------------------------------------------------+*/
User Function Os200Assoc
	/*+--------------------------------------------------------------+
	| Define variaveis proprias da rotina                          |
	+--------------------------------------------------------------+*/
	Local cCarga     := DAK->DAK_COD
	Local cSeqCar    := DAK->DAK_SEQCAR
	//Local cMotorista := DAK->DAK_MOTORI
	Local cNomeMot   := ""
	Local cVeiculo   := DAK->DAK_CAMINH
	Local cNomeCam   := Criavar("DA3_DESC",.F.)
	Local cPlaca     := Criavar("DA3_PLACA",.F.)
	Local nCapacMax  := 0
	Local nLimMax    := 0
	Local cAjuda1    := DAK->DAK_AJUDA1
	Local cNomeAju1  := Criavar("DAU_NOME",.F.)
	Local cAjuda2    := DAK->DAK_AJUDA2
	Local cNomeAju2  := Criavar("DAU_NOME",.F.)
	Local cAjuda3    := DAK->DAK_AJUDA3
	Local cNomeAju3  := Criavar("DAU_NOME",.F.)
	Local lProcessa  := .T.
	Local nPeso      := DAK->DAK_PESO
	Local nVolume    := DAK->DAK_CAPVOL
	Local nPtoEntr   := DAK->DAK_PTOENT
	Local cBitmap   := "PROJETOAP"

	Private cMotorista := DAK->DAK_MOTORI

	//+--------------------------------------------------------------+
	//| Verifica se houve acerto financeiro                          |
	//+--------------------------------------------------------------+
	If DAK->DAK_ACEFIN <> "2"
		Help(" ",1,"OMS200ACE")
		lProcessa := .F.
	Endif

	If lProcessa

		//+--------------------------------------------------------------+
		//| Dialog Principal.                                            |
		//+--------------------------------------------------------------+
		If !Empty(cVeiculo)
			DA3->(dbSetOrder(1))
			If DA3->(MsSeek(xFilial("DA4")+cVeiculo))
				cNomeCam   := DA3->DA3_DESC
				cPlaca     := DA3->DA3_PLACA
				nCapacMax  := DA3->DA3_CAPACM
				nLimMax    := DA3->DA3_LIMMAX
			EndIf
		EndIf

		If !Empty(cMotorista)
			DA4->(dbSetOrder(1))
			If DA4->(MsSeek(xFilial()+cMotorista))
				cNomeMot := DA4->DA4_NOME
			EndIf
		Else
			cNomeMot := ""
		EndIf

		If !Empty(cAjuda1)
			DAU->(dbSetOrder(1))
			If DAU->(MsSeek(xFilial("DAU")+cAjuda1))
				cNomeAju1 := DAU->DAU_NOME
			EndIf
		Else
			cNomeAju1 := ""
		EndIf

		If !Empty(cAjuda2)
			DAU->(dbSetOrder(1))
			If DAU->(MsSeek(xFilial("DAU")+cAjuda2))
				cNomeAju2 := DAU->DAU_NOME
			EndIf
		Else
			cNomeAju2 := ""
		EndIf

		If !Empty(cAjuda3)
			DAU->(dbSetOrder(1))
			If DAU->(MsSeek(xFilial("DAU")+cAjuda3))
				cNomeAju3 := DAU->DAU_NOME
			EndIf
		Else
			cNomeAju3 := ""
		EndIf

		DEFINE MSDIALOG oDlg Title OemtoAnsi(STR0012) From 200,001 to 500,600 Pixel //"Associacao do Veiculo"

		@ 0 , 0 BITMAP oBmp RESNAME cBitMap oF oDlg SIZE 48,488 NOBORDER WHEN .F. PIXEL

		@ 007,060 Say OemtoAnsi(STR0014) Size 30,7 Of oDlg Pixel //"Carga:"
		@ 007,090 MsGet cCarga  Picture "@!" When .F. Size 25,10 Of oDlg Pixel
		@ 007,130 MsGet cSeqCar Picture "@!" When .F. Size 15,10 Of oDlg Pixel

		@ 019,050 to 55,295 of oDlg Pixel
		@ 056,050 to 130,295 of oDlg Pixel

		@ 025,060 Say OemToAnsi(STR0019)  Size 30,10  Of oDlg Pixel //"Caminhao"
		@ 025,090 MSGet cVeiculo Valid U_OmsVldTransp(cVeiculo,@cNomeCam,@cPlaca,@nCapacMax,@nLimMax,nPeso,nVolume,nPtoEntr,@cMotorista,@cNomeMot,;
		@cAjuda1,@cNomeAju1,@cAjuda2,@cNomeAju2,@cAjuda3,@cNomeAju3) F3 "DA3" Size 30,10 Of oDlg Pixel
		@ 025,130 MSGet oNomeCam VAR cNomeCam When .F. Size 148,10  Of oDlg Pixel

		@ 040,060 Say OemtoAnsi(STR0095) Size 30,10  Of oDlg Pixel //"Placa"
		@ 040,090 MSGet oPlaca VAR cPlaca When .F. Size 35,10  Of oDlg Pixel

		@ 040,135 Say OemtoAnsi(STR0096) Size 30,10  Of oDlg Pixel //"Capac.Max"
		@ 040,166 MSGet oCapacMax VAR nCapacMax When .F. Size 35,10  Of oDlg Pixel

		@ 040,210 Say OemtoAnsi(STR0097) Size 30,10  Of oDlg Pixel //
		@ 040,243 MSGet oLimMax VAR nLimMax When .F. Size 35,10  Of oDlg Pixel

		@ 061,060 Say OemtoAnsi(STR0069) Size 30,10  Of oDlg Pixel //"Motorista"
		@ 061,090 MSGet cMotorista Picture "@!" Valid U_Os200Motor(cMotorista,@cNomeMot) F3 "DA4" Size 30,10 Of oDlg Pixel
		@ 061,130 MsGet oNomeMot VAR cNomeMot When .F. Size 148,10  Of oDlg Pixel

		@ 076,055 Say OemtoAnsi(STR0092) Size 40,10  Of oDlg Pixel //"1o. Ajudante"
		@ 076,090 MSGet cAjuda1 Picture "@!" Valid u_Oms200Aju(cAjuda1,@cNomeAju1) F3 "DAU" Size 30,10 Of oDlg Pixel
		@ 076,130 MsGet oNomeAju1 VAR cNomeAju1 When .F. Size 148,10  Of oDlg Pixel

		@ 091,055 Say OemtoAnsi(STR0093) Size 40,10  Of oDlg Pixel //"2o. Ajudante"
		@ 091,090 MSGet cAjuda2 Picture "@!" Valid u_Oms200Aju(cAjuda2,@cNomeAju2) F3 "DAU" Size 30,10 Of oDlg Pixel
		@ 091,130 MsGet oNomeAju1 VAR cNomeAju2 When .F. Size 148,10  Of oDlg Pixel

		@ 106,055 Say OemtoAnsi(STR0094) Size 40,10  Of oDlg Pixel //"3o. Ajudante"
		@ 106,090 MSGet cAjuda3 Picture "@!" Valid u_Oms200Aju(cAjuda3,@cNomeAju3) F3 "DAU" Size 30,10 Of oDlg Pixel
		@ 106,130 MsGet oNomeAju1 VAR cNomeAju3 When .F. Size 148,10  Of oDlg Pixel

		DEFINE SBUTTON FROM 135,235 TYPE 1 ACTION( Oms200PMot(cCarga,cSeqCar,cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3),oDlg:End() ) ENABLE OF oDlg WHEN !Empty(cVeiculo) .And. !Empty(cMotorista)
		DEFINE SBUTTON FROM 135,265 TYPE 2 ACTION ( oDlg:End() ) ENABLE OF oDlg
		ACTIVATE DIALOG oDlg CENTERED
	Endif
Return NIL

/*
+----------+----------+-------+-----------------------+------+------------+
| Funcao   |Oms200Proc| Autor | Octavio Moreira       | Data | 22/07/1999 |
+----------+----------+-------+-----------------------+------+------------+
| Descricao| Chamada do Processamento.                                    |
+----------+--------------------------------------------------------------+
| Uso      | DFATA431                                                     |
+----------+------------------------------------------+------+------------+
| Revisao  |                                          | Data |            |
+----------+------------------------------------------+------+------------+
*/
Static Function Oms200PMot(cCarga,cSeqCar,cVeiculo,cMotorista,cAjuda1,cAjuda2,cAjuda3)
	Local aCargas   := {{cCarga,cSeqCar}}
	Local aArea     := GetArea()
	Local aAreaDAK  := DAK->(GetArea())
	Local aAreaDAI  := DAI->(GetArea())
	Local cArqTRB   := ""

	Local lOs200Mot := ExistBlock("OS200MOT")

	/*+--------------------------------------------------------------+
	| Regrava a carga atual com o codigo da carga de destino       |
	+--------------------------------------------------------------+*/
	DbSelectArea("DA3")
	DbSetOrder(1)
	If MsSeek(xFilial("DA3")+cVeiculo)
		/*+---------------------------------------------------------------------+
		|Pergunta a quebra de carga caso a carga ainda nao tenha sido faturada|
		|e nao caiba no caminhao selecionado                                  |
		+---------------------------------------------------------------------+*/
		If ((DAK->DAK_PESO > DA3->DA3_CAPACN) .Or. (DAK->DAK_CAPVOL > DA3->DA3_VOLMAX) ) .And. DAK->DAK_FEZNF == '2'
			If MsgYesNo(OemtoAnsi(STR0126))
				/*+---------------------------------------------------------+
				|Processa a diferenca de itens para a quebra de carga     |
				+---------------------------------------------------------+*/
				Processa({ ||Oms210Unt(aCargas,cVeiculo,@cArqTRB,1,1,DA3->DA3_CAPACN,DA3->DA3_VOLMAX,.T.,.T.) })
				/*+---------------------------------------------------------+
				|Cria nova carga para quebra                              |
				+---------------------------------------------------------+*/
				DbSelectArea("DAK")
				RecLock("DAK",.T.)
				DAK->DAK_COD    := aCargas[1][1]
				DAK->DAK_SEQCAR := OsSeqCar(aCargas[1][1])
				DAK->DAK_FILIAL := xFilial()
				DAK->DAK_CAMINH := ""
				DAK->DAK_MOTORI := ""
				DAK->DAK_AJUDA1 := ""
				DAK->DAK_AJUDA2 := ""
				DAK->DAK_AJUDA3 := ""
				DAK->DAK_DATA   := dDatabase
				DAK->DAK_HORA   := Time()
				DAK->DAK_PESO   := 0
				DAK->DAK_CAPVOL := 0
				DAK->DAK_PTOENT := 0
				DAK->DAK_VALOR  := 0
				DAK->DAK_JUNTOU := "MANUAL"
				DAK->DAK_FLGUNI := "2"
				DAK->DAK_FEZNF  := "2"
				DAK->DAK_ACECAR := "2"
				DAK->DAK_ACEFIN := "2"
				DAK->DAK_ACEVAS := "2"
				DAK->(MsUnlock())
				DbSelectArea("TRB")
				DbGotop()
				While !(Eof())
					SC9->(MsGoto(TRB->TRB_RECNO))
					/*+-----------------------------------------------------+
					|Exclui o item do SC9 da carga atual                  |
					+-----------------------------------------------------+*/
					MaAvalSC9("SC9",8)
					Reclock("SC9",.F.)
					SC9->C9_CARGA   := aCargas[1][1]
					SC9->C9_SEQCAR  := "02"
					SC9->C9_SEQUEN  := OsSeqEnt(SC9->C9_CARGA,SC9->C9_SEQCAR,SC9->C9_PEDIDO)
					SC9(MsUnlock())
					/*+-----------------------------------------------------+
					|Inclui o item do SC9 na nova carga                   |
					+-----------------------------------------------------+*/
					MaAvalSC9("SC9",7)//,,,,,,aRotas)
					DbSelectArea("TRB")
					DbSkip()
				Enddo
				If Select("TRB") > 0
					DbSelectArea("TRB")
					DbCloseArea()
					//U_DelTrab(CARQTRB)
					//Ferase(cArqTrb+".DBF")
				EndIf
			EndIf
		EndIf
	EndIf
	DbSelectArea("DAK")
	DbsetOrder(1)
	If MsSeek(xFilial()+cCarga+cSeqCar)
		RecLock("DAK",.F.)
		DAK->DAK_CAMINH := cVeiculo
		DAK->DAK_MOTORI := cMotorista
		DAK->DAK_AJUDA1 := cAjuda1
		DAK->DAK_AJUDA2 := cAjuda2
		DAK->DAK_AJUDA3 := cAjuda3
		DAK->(MsUnLock())
	EndIf

	If lOs200Mot
		ExecBlock("OS200MOT",.F.,.F.)
	Endif

	RestArea(aAreaDAK)
	RestArea(aAreaDAI)
	RestArea(aArea)
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |OMSPESQPED| Autor | Henry Fila            | Data |08.08.2001 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Pesquisa registro em um arquivo temporario                   |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|ExpA1 : Array com a estrutura do TRB                         |
|          |ExpA2 : Array com os dados de exibicao do TRB                |
+----------+-------------------------------------------------------------+
|Retorno   |Nenhum                                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo cancelar as movimentacoes      |
|          |feitas do cliente                                            |
+----------+-------------------------------------------------------------+
|Uso       | APDL                                                        |
+----------+-------------------------------------------------------------+*/
User Function OmsPesqPed(cAliasTRB,aCampos,aCpoBrw)
	Local aCpoLbl  := {}
	Local aCpo     := {}

	Local cCpoLbl  := ""
	Local cCpo     := ""
	Local xPesq := Space(20)

	Local nX       := 0
	Local nTipo    := 0
	Local nOpca    := 0
	Local nRegTRB  := TRBPED->(Recno())
	Local wnOrdem  := 1
	Local oDlg

	aAdd(aCpoLbl,"Pedido + Item")      // Ordem  6
	aAdd(aCpoLbl,"Produto")            // Ordem  7
	aAdd(aCpoLbl,"Descricao Produto")  // Ordem  8
	aAdd(aCpoLbl,"Cliente + Loja")     // Ordem 10
	aAdd(aCpoLbl,"Nome")               // Ordem  9

	aAdd(aCpo,06) // Ordem 06
	aAdd(aCpo,07) // Ordem 07
	aAdd(aCpo,08) // Ordem 08
	aAdd(aCpo,10) // Ordem 10
	aAdd(aCpo,09) // Ordem 09
	wnOrdem := aCpo[1]

	DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0117)  FROM 09,0 TO 20,50 OF oMainWnd

	@ 000, 0 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 30, 1000 NOBORDER WHEN .F. PIXEL ADJUST

	@ 014,035 SAY OemtoAnsi(STR0118) of oDlg PIXEL
	//@ 014,075 MSCOMBOBOX oCpo VAR cCpoLbl ITEMS aCpoLbl SIZE 55, 65 OF oDlg PIXEL ON CHANGE (nTipo := oCpo:nAt,OmsChgPict(nTipo,aCampos,aCpo,@xPesq,oPesq,@cCpo))
	@ 014,075 MSCOMBOBOX oCpo VAR cCpoLbl ITEMS aCpoLbl SIZE 55, 65 OF oDlg PIXEL ON CHANGE (wnOrdem := aCpo[oCpo:nAt])

	@ 028,035 SAY OemtoAnsi(STR0119) of oDlg PIXEL
	@ 028,075 MSGET oPesq VAR xPesq Picture "@!" SIZE 113, 10 Of oDlg PIXEL

	DEFINE SBUTTON oBut1 FROM 062, 130 TYPE 1 ACTION ( nOpca := 1, oDlg:End() )  ENABLE of oDlg
	DEFINE SBUTTON oBut1 FROM 062, 160 TYPE 2 ACTION ( nOpca := 0, oDlg:End() )  ENABLE of oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1
		DbSelectArea("TRBPED")
		DbSetOrder(wnOrdem)
		If wnOrdem = 8 .Or. wnOrdem = 9
			SET SOFTSEEK ON
			xPesq := Alltrim(xPesq)
		EndIf
		If !DbSeek(xPesq)
			TRBPED->(MsGoto(nRegTRB))
			MsgAlert("Não encontrado.")
		EndIf
		If wnOrdem = 8 .Or. wnOrdem = 9
			SET SOFTSEEK OFF
		EndIf
		//DbSetOrder(10)
		DbSetOrder(15)
		oMark:oBrowse:SetFocus()
	EndIf
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |OMSCHGPICT| Autor | Henry Fila            | Data |08.08.2001 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Tratamento da pesquisa de arquivos temporarios               |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|ExpN1 : Posicao do campo no Array                            |
|          |ExpA2 : Array com a estrutura do arquivo                     |
|          |ExpA3 : Array com os campos e labels do arquivo              |
|          |ExpX4 : Variavel de pesquisa                                 |
|          |ExpN5 : Objeto da variavel de pesquisa                       |
|          |ExpC6 : Nome do campo por referencia para ser pesquisado     |
+----------+-------------------------------------------------------------+
|Retorno   |Nenhum                                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo tratar a pesquisa a ser reali  |
|          |zada no arquivo temporario                                   |
+----------+-------------------------------------------------------------+
|Uso       | APDL                                                        |
+----------+-------------------------------------------------------------+*/
Static Function OmsChgPict(nTipo,aCampos,aCpo,xPesq,oPesq,cCpo)
	Local nPosCpo := 0
	Local cPict   := ""

	nPosCpo := Ascan(aCampos,{|x| x[1] == Alltrim(aCpo[nTipo])})
	If nPosCpo > 0
		cCpo  := aCampos[nPosCpo][1]
		Do Case
			Case aCampos[nPosCpo][2] == "N"
			xPesq := 0
			cPict := "@E 99,999,999.99"
			Case aCampos[nPosCpo][2] == "D"
			xPesq := dDataBase
			cPict := "@D"
			Case aCampos[nPosCpo][2] == "C"
			xPesq := Space(aCampos[nPosCpo][3])
			cPict := Replicate("!",aCampos[nPosCpo][3])
		EndCase
	EndIf
	oPesq:oGet:Picture := cPict
	oPesq:Refresh()
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |Os200BLQ  | Autor | Henry Fila            | Data |08.08.2001 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Bloqueio de carga manual                                     |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|Nenhum                                                       |
+----------+-------------------------------------------------------------+
|Retorno   |Nenhum                                                       |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo bloquear as cargas manualmente |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Uso       | APDL                                                        |
+----------+-------------------------------------------------------------+*/
User Function Os200Blq()
	Local aArea    := GetArea()
	Local cTexto    := ""
	Local cCarga    := DAK->DAK_COD
	Local cSeqCar   := DAK->DAK_SEQCAR
	Local cTipoOper := ""
	Local lBloqueio := .F.

	If DAK->(FieldPos("DAK_BLQCAR")) > 0
		Do Case
			Case DAK->DAK_BLQCAR == "1"
			cTexto    := OemtoAnsi(STR0124)
			cTipoOper := "2"
			Case DAK->DAK_BLQCAR == "2" .Or. DAK->DAK_BLQCAR == ' '
			cTexto    := OemtoAnsi(STR0125)
			cTipoOper := "1"
		EndCase
		lBloqueio := OsBlqExec(cCarga,cSeqCar)
		If lBloqueio
			Aviso(OemtoAnsi(STR0121),OemtoAnsi(STR0123),{OemtoAnsi(STR0122)})
		Else
			If MsgYesNo(cTexto)
				Do Case
					Case cTipoOper == "1"
					OsAvalDAK("DAK",11)
					Case cTipoOper == "2"
					OsAvalDAK("DAK",12)
				EndCase
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |Oms200Lock| Autor | Henry Fila            | Data |12.04.2002 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Lock do registro do pedido                                   |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|ExpC1 - Filial de origem do pedido                           |
|          |ExpC2 - Pedido                                               |
|          |ExpA3 - Array par armezenamento dos pedidos                  |
|          |ExpL4 - .T. Marca o pedido / .F. Desmarca                    |
|          |ExpC5 - Marca da MsSelect                                    |
+----------+-------------------------------------------------------------+
|Retorno   |ExpL1 - .T. Sucesso no Lock ou no Unlock                     |
|          |        .F. Nao realizou o lock ou Unlock                    |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo bloquear os registros dos pe-  |
|          |didos marcados no browse de cargas                           |
+----------+-------------------------------------------------------------+
|Uso       | APDL                                                        |
+----------+-------------------------------------------------------------+*/
Static Function Oms200Lock(cFilOri,cPedido,aLock,lMarca,cMarca)
	Local lRet     := .T.
	Local lLock    := .T.
	Local lLockSC5 := SuperGetMv("MV_CGLOCK",.F.,.F.)

	Local aArea    := GetArea()
	Local aAreaSC5 := SC5->(GetArea())
	Local nRecTRB  := TRBPED->(Recno())
	Local nPosPed  := 0

	If !lLockSC5
		nPosPed := Ascan(aLock,{|x| x[1]+x[2] == cFilOri+cPedido})
		If lMarca
			If nPosPed  == 0
				dbSelectArea("SC5")
				dbSetOrder(1)
				If MsSeek(cFilOri+cPedido)
					If SoftLock("SC5")
						aAdd(aLock,{cFilOri,cPedido})
					Else
						lRet := .F.
					Endif
				Endif
			Endif
		Else
			If nPosPed > 0
				TRBPED->(dbSetOrder(1))
				If TRBPED->(MsSeek(cFilori+cPedido))
					While !Eof() .And. ( TRBPED->PED_FILORI+TRBPED->PED_PEDIDO == cFilOri+cPedido )
						If nRecTRB != TRBPED->(Recno())
							If TRBPED->PED_MARCA == cMarca
								lLock := .F.
							Endif
						Endif
						dbSkip()
					Enddo
				Endif
				If lLock
					dbSelectArea("SC5")
					dbSetOrder(1)
					If MsSeek(cFilOri+cPedido)
						SC5->(MsUnlock())
						aDel(aLock,nPosPed)
						aSize(aLock,Len(aLock)-1)
					Endif
				Endif
			Endif
		Endif
		TRBPED->(MsGoto(nRecTrb))
	Else
		lRet := .T.
	Endif
	RestArea(aAreaSC5)
	RestArea(aArea)
Return lRet

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |Oms200Time| Autor | Henry Fila            | Data |12.04.2002 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Calcula hora de chegada no cliente                           |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|ExpA1 - Array com os dados dos contendo e nao importando a   |
|          |        ordem pois a posicao sera passada nos outros parame- |
|          |        tros da funcao.                                      |
|          |      [1]-Filial                                             |
|          |      [2]-Rota                                               |
|          |      [3]-Zona                                               |
|          |      [4]-Setor                                              |
|          |      [5]-Cliente                                            |
|          |      [6]-Loja                                               |
|          |      [7]-Peso                                               |
|          |      [8]-Volume                                             |
|          |      [9]-Hora (a ser retornado pela funcao)                 |
|          |      [10]-Time Service (a ser retornado pela funcao)        |
|          |ExpC2 - Veiculo                                              |
|          |ExpN3 - Posicao da Filial de origem no array                 |
|          |ExpN4 - Posicao do cliente no array                          |
|          |ExpN5 - Posicao da Loja no array                             |
|          |ExpN6 - Posicao da Rota no Array                             |
|          |ExpN7 - Posicao da Zona no array                             |
|          |ExpN8 - Posicao do Setor no array                            |
|          |ExpN9 - Posicao da Peso no array                             |
|          |ExpN10- Posicao do Volume no array                           |
|          |ExpN11 - Posicao da Hora no array  (retorno)                 |
|          |ExpN12 - Posicao do Time Service   (retorno)                 |
|          |ExpN13 - Posicao do retorno da janela (.T. ou .F.)           |
+----------+-------------------------------------------------------------+
|Retorno   |ExpL1 - .T. Sucesso no Lock ou no Unlock                     |
|          |        .F. Nao realizou o lock ou Unlock                    |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo bloquear os registros dos pe-  |
|          |didos marcados no browse de cargas                           |
+----------+-------------------------------------------------------------+
|Uso       | APDL                                                        |
+----------+-------------------------------------------------------------+*/
Static Function Oms200Time(cHrStart,aTime,cVeiculo,nPosFil,nPosCli,nPosLoja,nPosRota,nPosZona,nPosSetor,nPosPeso,nPosVol,nPosHora,nPosTime,nPosJan)
	Local aRotas     := {}
	Local cFilSA1    := ""
	Local cRotaAnt   := ""
	Local cZonaAnt   := ""
	Local cSetorAnt  := ""
	Local cCliAnt    := ""
	Local cLojaAnt   := ""

	Local nX         := 0
	Local nTempo     := 0
	Local nSetor     := 0
	Local nZona      := 0
	Local nRota      := 0
	Local nIntHora   := 0

	Local lNew       := .F.
	Local lJanela    := Iif(Valtype(nPosJan) <> "U",.T.,.F.)

	DEFAULT nPosFil  := 1
	DEFAULT nPosCli  := 2
	DEFAULT nPosLoja := 3
	DEFAULT nPosRota := 4
	DEFAULT nPosZona := 5
	DEFAULT nPosSetor:= 6
	DEFAULT nPosPeso := 7
	DEFAULT nPosVol  := 8
	DEFAULT nPosHora := 9
	DEFAULT nPosTime := 10
	DEFAULT nPosJan  := 0
	DEFAULT cHrStart := GetNewPar("MV_CGSTART","08:00")

	If Len(aTime) > 0
		cRotaAnt  := aTime[1][nPosRota]
		cZonaAnt  := aTime[1][nPosZona]
		cSetorAnt := aTime[1][nPosSetor]
		cCliAnt   := aTime[1][nPosCli]
		cLojaAnt  := aTime[1][nPosLoja]
		For nX := 1 to Len(aTime)
			nTempo := 0
			lNew   := .F.
			//cFilSA1 := Iif(nPosFil == 0, xFilial("SA1"),OsFilial("SA1",aTime[nX][nPosFil]))
			cFilSA1 := xFilial("SA1")

			DbSelectArea("SA1")
			DbSetOrder(1)
			MsSeek(cFilSA1+aTime[nX][nPosCli]+aTime[nX][nPosLoja])

			/*+----------------------------------------+
			|Inclui no array caso seja a primeira vez|
			+----------------------------------------+*/
			If Len(aRotas) == 0
				DbSelectARea("DA8")
				DbSetOrder(1)
				If MsSeek(xFilial("DA8")+aTime[nX][nPosRota])
					nTempo += HoratoInt(DA8->DA8_TEMPO,4)
					aAdd(aRotas,{aTime[nX][nPosRota],aTime[nX][nPosZona],aTime[nX][nPosSetor],aTime[nX][nPosCli],aTime[nX][nPosLoja] })
				Endif
			Endif
			/*+--------------------------------------------------------+
			|Busca se existe troca de cliente no setor               |
			+--------------------------------------------------------+*/
			nSetor := Ascan(aRotas,{|x| x[3] == aTime[nX][nPosSetor]})
			If nSetor > 0
				lNew := ( Ascan(aRotas,{|x| x[3]+x[4]+x[5] == aTime[nX][nPosSetor]+aTime[nX][nPosCli]+aTime[nX][nPosLoja] } ) == 0 )
				If lNew .Or. cSetorAnt+cCliAnt+cLojaAnt <> aTime[nX][nPosSetor]+aTime[nX][nPosCli]+aTime[nX][nPosLoja]
					DbSelectArea("DA6")
					DbSetOrder(1)
					If MsSeek(xFilial("DA6")+aTime[nX][nPosZona]+aTime[nX][nPosSetor])
						nTempo += HoratoInt(DA6->DA6_TEMPO,4)
						If lNew
							aAdd(aRotas,{aTime[nX][nPosRota],aTime[nX][nPosZona],aTime[nX][nPosSetor],aTime[nX][nPosCli],aTime[nX][nPosLoja] })
						Endif
					Endif
				Endif
			Endif
			/*+--------------------------------------------------------+
			|Busca se existe troca de Setores nas zonas              |
			+--------------------------------------------------------+*/
			nZona := Ascan(aRotas,{|x| x[2] == aTime[nX][nPosZona]})
			If nZona > 0
				lNew := ( Ascan(aRotas,{|x| x[2]+x[3] == aTime[nX][nPosZona]+aTime[nX][nPosSetor]}) == 0 )
				If lNew .Or. cZonaAnt+cSetorAnt <> aTime[nX][nPosZona]+aTime[nX][nPosSetor]
					DbSelectArea("DA5")
					DbSetOrder(1)
					If MsSeek(xFilial("DA5")+aTime[nX][nPosZona])
						nTempo := HoratoInt(DA5->DA5_TEMPO,4)
						If lNew
							aAdd(aRotas,{aTime[nX][nPosRota],aTime[nX][nPosZona],aTime[nX][nPosSetor],aTime[nX][nPosCli],aTime[nX][nPosLoja] })
						Endif
					Endif
				Endif
			Endif
			/*+--------------------------------------------------------+
			|Busca se existe troca de zonas e setores na rota        |
			+--------------------------------------------------------+*/
			nRota := Ascan(aRotas,{|x| x[1] == aTime[nX][nPosRota]})
			If nRota > 0
				lNew := ( Ascan(aRotas,{|x| x[1]+x[2]+x[3] == aTime[nX][nPosRota]+aTime[nX][nPosZona]+aTime[nX][nPosSetor]}) == 0 )
				If lNew .Or. cRotaAnt+cZonaAnt+cSetorAnt <>  aTime[nX][nPosRota]+aTime[nX][nPosZona]+aTime[nX][nPosSetor]
					dbSelectARea("DA8")
					dbSetOrder(1)
					If MsSeek(xFilial("DA8")+aTime[nX][nPosRota])
						nTempo += HoratoInt(DA8->DA8_TEMPO,4)
						If lNew
							aAdd(aRotas,{aTime[nX][nPosRota],aTime[nX][nPosZona],aTime[nX][nPosSetor],aTime[nX][nPosCli],aTime[nX][nPosLoja] })
						Endif
					Endif
				Endif
			Endif
			/*+------------------------------------------------------+
			|Calcula hora de parada                                |
			+------------------------------------------------------+*/
			cHrStart := IntToHora(HoratoInt(cHrStart,2)+nTempo)
			aTime[nX][nPosHora] := cHrStart
			aTime[nX][nPosTime] := OmsSrvTime(SA1->A1_GRPVEN,aTime[nX][nPosCli],aTime[nX][nPosLoja],aTime[nX][nPosPeso],aTime[nX][nPosVol])
			If nPosJan <> 0
				aTime[nX][nPosJan]  := OmsJanEntr(SA1->A1_GRPVEN,aTime[nX][nPosCli],aTime[nX][nPosLoja],aTime[nX][nPosHora],cVeiculo,dDataBase)
			Endif
			/*+------------------------------------------------------+
			|Calcula proxima hora  de parada incluindo time service|
			+------------------------------------------------------+*/
			nIntHora := HoratoInt(cHrStart,2)+HoraToInt(aTime[nX][nPosTime],4)
			/*+------------------------------------------------------------------+
			|Verifica se a hora ira passar da meia noite para iniciar o horario|
			+------------------------------------------------------------------+*/
			Do Case
				Case nIntHora > 24
				nIntHora := nIntHora - 24
				Case nIntHora == 24
				nIntHora := 0
			EndCase
			/*+------------------------------------------------------------------+
			|Atribui os Valores                                                |
			+------------------------------------------------------------------+*/
			cHrStart  := IntToHora(nIntHora,2)
			cRotaAnt  := aTime[nx][nPosRota]
			cZonaAnt  := aTime[nx][nPosZona]
			cSetorAnt := aTime[nx][nPosSetor]
			cCliAnt   := aTime[nx][nPosCli]
			cLojaAnt  := aTime[nx][nPosLoja]
		Next
	Endif
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |Oms200Seq | Autor | Henry Fila            | Data |12.04.2002 |
+----------+----------+-------+-----------------------+------+-----------+
|          |Reordena e recalcula horas no acols na manutencao de carga   |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Parametros|Nenhum                                                       |
+----------+-------------------------------------------------------------+
|Retorno   |ExpL1 - .T.                                                  |
+----------+-------------------------------------------------------------+
|Descrição |Esta rotina tem como objetivo ordenar o acols de acordo com  |
|          |o digitado para recalculo das horas de entrega               |
+----------+-------------------------------------------------------------+
|Uso       | APDL                                                        |
+----------+-------------------------------------------------------------+*/
User Function Oms200Seq()
	Local nPosSeq  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_SEQUEN" })
	Local nPosFil  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_FILPV"  })
	Local nPosCli  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_CLIENT" })
	Local nPosLoja := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_LOJA"   })
	Local nPosRota := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_ROTEIR" })
	Local nPosZona := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_PERCUR" })
	Local nPosSetor:= Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_ROTA"   })
	Local nPosPeso := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_PESO"   })
	Local nPosVol  := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_CAPVOL" })
	Local nPosHora := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_CHEGAD" })
	Local nPosTime := Ascan(aHeader,{|x| Alltrim(x[2]) == "DAI_TMSERV" })

	aCols[n][nPosSeq] := M->DAI_SEQUEN
	aCols := aSort(aCols,,,{|x,y| x[nPosSeq] < y[nPosSeq] })
	Oms200Time(aCols,nPosFil,nPosCli,nPosLoja,nPosRota,nPosZona,nPosSetor,nPosPeso,nPosVol,nPosHora,nPosTime)
	oGetD:oBrowse:Refresh()
Return .T.

/*+----------+-------------+-------+--------------------+------+-----------+
|Função    |Oms200EndOri | Autor | Henry Fila         | Data |06.12.2004 |
+----------+-------------+-------+--------------------+------+-----------+
|          |Retorna o endereco padrao da carga                           |
+----------+-------------------------------------------------------------+
|Parametros|ExpC1 - Cargal de origem do pedido                           |
|          |ExpC2 - Sequencia                                            |
+----------+-------------------------------------------------------------+
|Retorno   |ExpC1 - Endereco padrao da carga                             |
+----------+-------------------------------------------------------------+
|Descri‡„o |Esta rotina tem como objetivo retornar o endereco padrao de  |
|          |uma determinada carga                                        |
+----------+-------------------------------------------------------------+
|Uso       | APDL                                                        |
+----------+-------------------------------------------------------------+*/

User Function Om200EndOri(cCarga,cSeqCar)
	Local aArea    := GetArea()
	Local aAreaDAK := DAK->(GetArea())
	Local aAreaDAI := DAI->(GetArea())
	Local cFilPv   := ""
	Local nTpVlEnt := OsVlEntCom()

	DbSelectArea("DAI")
	DbSetOrder(1)
	If MsSeek(xFilial("DAI")+cCarga+cSeqCar)
		//cFilPv := IIf(nTpVlEnt<>1,DAI->DAI_FILPV,xFilial("SC9"))
		cFilPv := xFilial("SC9")
		DbSelectArea("SC9")
		DbSetOrder(5)
		//If MsSeek(OsFilial("SC9",cFilPv)+DAK->DAK_COD+DAK->DAK_SEQCAR)
		If MsSeek(xFilial("SC9")+DAK->DAK_COD+DAK->DAK_SEQCAR)
			cEndereco := SC9->C9_ENDPAD
		Endif
	Endif
	RestArea(aAreaDAK)
	RestArea(aAreaDAI)
	RestArea(aArea)
Return cEndereco

/*+------------+----------+-------+--------------------+------+---------------+
|  Programa  |REGRA01   |Autor  |Microsiga Vitoria   | Data |  09/06/05     |
+------------+----------+-------+--------------------+------+---------------+
|  Parametros| ExpC1 - Marca usada no browse                                |
+------------+--------------------------------------------------------------+
|  Retorno   | ExpL1 - Continua sim ou não                                  |
+------------+--------------------------------------------------------------+
|  Desc.     | Regra que verifica se há pedidos bloqueados na seleção, seja |
|            | por crédito/estoque ou por regra de negócios da Movelar.     |
+------------+--------------------------------------------------------------+
|  Uso       | MOVELAR                                                      |
+------------+--------------------------------------------------------------+*/
Static Function Regra01(cMarca)
	Local nRec  := TRBPED->(Recno())
	Local lBloq := .F.
	Local aArea
	DbSelectArea("TRBPED")
	aArea:= GetArea()
	DbGotop()
	While !Eof()
		// Pedido encontra-se bloqueado?
		lBloq:= PED_MARCA == cMarca .And. (PED_BLOQ == "B" .Or. PED_REGRA == "#")
		If lBloq
			MsgAlert("Existem pedidos bloqueados na seleção.")
			RestArea(aArea)
			Return .F.
		EndIf
		DbSkip()
	EndDo
	RestArea(aArea)
Return .T.

/*+------------+----------+-------+--------------------+------+---------------+
|  Programa  |REGRA02   |Autor  |Microsiga Vitoria   | Data |  09/05/05     |
+------------+----------+-------+--------------------+------+---------------+
|  Parametros| ExpC1 - Marca usada no browse                                |
+------------+--------------------------------------------------------------+
|  Retorno   | ExpL1 - Continua sim ou não                                  |
+------------+--------------------------------------------------------------+
|  Desc.     | Regra para verificar se existe algum pedido de mostruario    |
|            | que não esteja marcado para cliente que exige o mesmo.       |
+------------+--------------------------------------------------------------+
|  Uso       | MOVELAR                                                      |
+------------+--------------------------------------------------------------+*/
Static Function Regra02(cMarca)
	/*
	A rotina deve verificar, item por item, os pedidos normais que estiverem
	marcados para saber se existe algum pedido com as mesmas características
	mas que seja de mostruário e que não esteja marcado.
	*/
	Local aArea
	Local cTipPed
	Local nRec
	Local cCodCli
	Local cClient
	Local cCodPro
	Local cPedido

	DbSelectArea("TRBPED")
	aArea:= GetArea()
	cTipPed   := "M "
	DbSetOrder(5) //PED_CODCLI+PED_CODPRO+PED_TIPPED
	DbGoTop()
	While !Eof()
		// Ignora os itens de pedido não-marcados
		If TRBPED->PED_MARCA <> cMarca
			DbSkip()
			Loop
		EndIf
		nRec     := TRBPED->(RecNo())
		cCodCli  := TRBPED->PED_CODCLI
		cClient  := TRBPED->PED_NOME
		cCodPro  := TRBPED->PED_CODPRO
		cPedido  := TRBPED->PED_PEDIDO
		DbGoTop()
		// Procura apenas itens de pedido não-marcados
		If DbSeek(cCodCli+cCodPro+cTipPed)
			If TRBPED->PED_MARCA <> cMarca
				If !MsgYesNo("O Pedido "+cPedido+" do Cliente "+cClient+" possui um pedido mostruário ("+TRBPED->PED_PEDIDO+") que não foi marcado. Deseja continuar mesmo assim?","Atenção")
					RestArea(aArea)
					Return .F.
				EndIf
			EndIf
		EndIf
		DbGoto(nRec)
		DbSkip()
	EndDo
	RestArea(aArea)
Return .T.

/*+------------+----------+-------+--------------------+------+---------------+
|  Programa  |REGRA03   |Autor  |Microsiga Vitoria   | Data |  09/06/05     |
+------------+----------+-------+--------------------+------+---------------+
|  Parametros| ExpC1 - Marca usada no browse                                |
+------------+--------------------------------------------------------------+
|  Retorno   | ExpL1 - Continua sim ou não                                  |
+------------+--------------------------------------------------------------+
|  Desc.     | Regra que define se a carga pode se montada com os pedidos   |
|            | selecionados. Esta regra verifica se o campo A1_YVLMPED esta |
|            | preenchido e varre os pedidos selecionados para saber se     |
|            | pode ser montada carga com apenas esses pedidos.             |
+------------+--------------------------------------------------------------+
|  Uso       | OMS MOVELAR                                                  |
+------------+--------------------------------------------------------------+*/
Static Function Regra03(cMarca)
	local i
	/* A rotina deve verificar, os clientes que possuem restrição no valor do
	frete. Os pedidos, somados, devem atingir um valor mínimo, em A1_YVLMPED. */
	Local aClientes   := {}

	Local cCliente
	Local nPos
	Local aArea
	Local nRec
	Local nValor
	DbSelectArea("TRBPED")
	aArea:= GetArea()
	nRec := TRBPED->(RecNo())
	DbGoTop()
	While !Eof()
		If TRBPED->PED_MARCA == cMarca
			If TRBPED->PED_VLMPED > 0
				nPos:= aScan(aClientes, {|x| x[1] == TRBPED->PED_CODCLI})
				If nPos == 0
					aAdd(aClientes, {TRBPED->PED_CODCLI,TRBPED->PED_VLMPED})
				EndIf
			EndIf
		EndIf
		DbSkip()
	EndDo

	If Len(aClientes) > 0
		For i:= 1 to Len(aClientes)
			DbGoTop()
			nValor:= 0
			IF TRBPED->PED_AGLUT2 = 'S'
				While !Eof() .And. nValor < aClientes[i][2]
					If TRBPED->PED_CODCLI == aClientes[i][1] .And. TRBPED->PED_MARCA == cMarca .And. ;
					TRBPED->PED_BLOQ == "L" .And. TRBPED->PED_REGRA <> "#"
						cCliente:= TRBPED->PED_NOME
						nValor  += TRBPED->PED_VALOR
					EndIf
					DbSkip()
				EndDo
			ELSE
				nValor  += TRBPED->PED_VALOR
			ENDIF
			If nValor < aClientes[i][2]
				//Se quiser liberar a questão da liberação de pedidos com valores menores que o valor mínimo é só retirar o comentário abaixo e
				//comentar o bloco marcado abaixo -
				//Alterado em 23/01/2007 por PANETTO - Solicitação Wanisay
				//If !MsgYesNo(OemtoAnsi("Existem restrições quanto ao valor minimo a ser faturado para o cliente ")+;
				//                       cCliente+OemtoAnsi(". Deseja continuar?"),OemtoAnsi("Atenção"))
				RestArea(aArea)
				DbGoTo(nRec)
				Return .T.   //Wanisay colocou para liberar esta consistencia
				//Return .F.
				//EndIf
				//Código novo - 23/01/2007
				MsgInfo("Existem restrições quanto ao valor minimo a ser faturado para o cliente "+ALLTRIM(TRBPED->PED_NOME)+". Favor desmarcar os pedidos deste cliente.")
				//RestArea(aArea)
				//DbGoTo(nRec)
				//Return .F.
				//Fim do Código novo
			EndIf
		Next i
	EndIf
	RestArea(aArea)
	DbGoTo(nRec)
Return .T.


/*+------------+----------+-------+--------------------+------+---------------+
|  Programa  |fVlPed    |Autor  |Microsiga Vitoria   | Data |  05/03/07     |
+------------+----------+-------+--------------------+------+---------------+
|  Parametros| ExpC1 - Marca usada no browse                                |
+------------+--------------------------------------------------------------+
|  Retorno   | ExpL1 - Mensagem com os clientes com valores abaixo do mínimo|
+------------+--------------------------------------------------------------+
|  Desc.     | Essa funcao lista todos os clientes com pedidos selecionados |
|            | que não atingiram o valor mínimo. Esta funcao verifica se o  |
|            | campo A1_YVLMPED esta preenchido e varre os pedidos          |
|            | selecionados para saber se pode ser montada carga com apenas |
|            | esses pedidos.                                               |
+------------+--------------------------------------------------------------+
|  Uso       | OMS MOVELAR                                                  |
+------------+--------------------------------------------------------------+*/
Static Function fVlPed(cMarca)
	Local aClientes   := {},i,x
	Local aCliente2   := {}
	Local cCliente
	Local nPos
	Local aArea
	Local nRec
	Local nValor
	DbSelectArea("TRBPED")
	aArea:= GetArea()
	nRec := TRBPED->(RecNo())
	DbGoTop()
	While !Eof()   //Carregando os clientes com pedidos marcados.
		If TRBPED->PED_MARCA == cMarca
			If (TRBPED->PED_VLMPED > 0) .AND. (Alltrim(TRBPED->PED_TIPPED) $ "N/V/P/A/PV/MV/M")
				nPos:= aScan(aClientes, {|x| x[1] == TRBPED->PED_CODCLI+TRBPED->PED_LOJA})
				If nPos == 0
					aAdd(aClientes, {TRBPED->PED_CODCLI+TRBPED->PED_LOJA,TRBPED->PED_VLMPED})
				EndIf
			EndIf
		EndIf
		DbSkip()
	EndDo

	If Len(aClientes) > 0
		cCli := ''
		For i:= 1 to Len(aClientes)
			DbGoTop()
			nValor:= 0
			cBand := 0
			While !Eof() .And. nValor < aClientes[i][2]
				If TRBPED->PED_CODCLI+TRBPED->PED_LOJA == aClientes[i][1] .And. TRBPED->PED_MARCA == cMarca
					cCliente:= TRBPED->PED_NOME
					nValor  += TRBPED->PED_VALOR
					cBand := 1
				EndIf
				DbSkip()
			EndDo
			If cBand = 1
				If nValor < aClientes[i][2]
					aAdd(aCliente2, {cCliente,nValor})
				EndIf
			EndIf
		Next i
		For x := 1 to Len(aCliente2)
			cCli += (Alltrim(aCliente2[x][1])+"  - R$"+Alltrim(Str(aCliente2[x][2]))+Chr(13))
		Next
		If Len(aCliente2) > 0
			MsgInfo("Existem restrições quanto ao valor minimo a ser faturado para os clientes abaixo: "+Chr(13)+cCli)
		Else
			MsgInfo("Clientes Liberados.")
		EndIf
	EndIf
	RestArea(aArea)
	DbGoTo(nRec)
Return .T.

/*+------------+----------+-------+--------------------+------+--------------+
|  Programa  |REGRA04   |Autor  |Microsiga Vitoria   | Data |  09/05/05    |
+------------+----------+-------+--------------------+------+--------------+
|  Parametros| ExpC1 - Marca usada no browse                               |
+------------+-------------------------------------------------------------+
|  Retorno   | ExpL1 - Continua sim ou não                                 |
+------------+-------------------------------------------------------------+
|  Desc.     | Regra para verificar se existe algum cliente, entre os pe-  |
|            | didos selecionados, que exige agendamento prévio da entrega.|
+------------+-------------------------------------------------------------+
|  Uso       | MOVELAR                                                     |
+------------+-------------------------------------------------------------+*/
Static Function Regra04(cMarca)
	local i
	/*
	A rotina verifica se existem clientes que exigem ser avisados previamente
	da entrega da mercadoria.
	*/
	Local aClientes := {}
	Local cCliente
	Local nPos
	Local aArea
	Local nRec
	Local nValor

	DbSelectArea("TRBPED")
	aArea:= GetArea()
	nRec := TRBPED->(RecNo())
	DbGoTop()
	While !Eof()
		If TRBPED->PED_MARCA == cMarca
			If TRBPED->PED_AGENDA == 'S'
				nPos:= aScan(aClientes, {|x| x[1] == TRBPED->PED_CLIENT})
				If nPos == 0
					aAdd(aClientes, {TRBPED->PED_CLIENT,TRBPED->PED_VLMPED})
				EndIf
			EndIf
		EndIf
		DbSkip()
	EndDo

	If Len(aClientes) > 0
		For i:= 1 to Len(aClientes)
			cCliente:= Posicione("SA1",1,xFilial("SA1"),"A1_NOME")
			If !MsgYesNo("O cliente "+aClientes[i]+"/"+cCliente+" exige ser avisado previamente de entregas. Deseja continuar?",OemtoAnsi("Atenção"))
				RestArea(aArea)
				DbGoTo(nRec)
				Return .F.
			EndIf
		Next i
	EndIf
	RestArea(aArea)
	DbGoTo(nRec)
Return .T.

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FLIBERA   | Autor | Felipe Zago Zechini   | Data | 15.10.2005|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Libera os itens do pedido e atualiza na tela de montagem de |
|          | carga as quantidades e valores                              |
+----------+-------------------------------------------------------------+
|Parametros| cString  - String com os itens a serem separados            |
|          | nTamItem - Tamanho de cada item                             |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fLibera(cAlias,nReg,nOpc)
	Local aArea    := GetArea()
	Local aArea2
	Local cPedido  := TRBPED->PED_PEDIDO
	Local nPeso    := 0
	Local nRecno   := TRBPED->(RecNo())
	Local cChave   := ""
	Local _Lib     := 0
	Local _Blq     := 0

	Private lSugere := .T.
	Private lLiber  := .F.
	Private lTransf := .F.
	/*
	If TRBPED->PED_BLOQ == 'L'
	Return
	EndIf
	*/
	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek(xFilial("SC5")+cPedido)
		SetKey(VK_F5,{||fQuant(cPedido)})
		If A440Libera(Alias(),RecNo(),6) == 1
			fTrabSC9(cPedido)
			aArea2 := GetArea()
			DbSelectArea("TRBPED")
			DbSetOrder(1)
			DbGoTop()
			While !QRY_ITENS->(Eof())
				If DbSeek(xFilial("SC9")+cPedido+QRY_ITENS->ITEM) .And. TRBPED->PED_MARCA == cxMarca
					nPeso:= NoRound(TRBPED->PED_PESO / iif(!Empty(TRBPED->PED_SEQLIB),TRBPED->PED_QTDLIB,TRBPED->PED_QTDPED),2)
					RecLock("TRBPED",.F.)
					TRBPED->PED_PESO   := nPeso * QRY_ITENS->QTDLIB
					TRBPED->PED_BLOQ   := 'L'
					TRBPED->PED_QTDLIB := QRY_ITENS->QTDLIB
					TRBPED->PED_SEQLIB := QRY_ITENS->SEQLIB
					TRBPED->PED_VALOR  := QRY_ITENS->VALOR
					TRBPED->(MsUnlock())
				EndIf
				QRY_ITENS->(DbSkip())
			EndDo
			// Limpa o Bloqueio do Pedido
			RecLock("SC5",.F.)
			//SC5->C5_YBLQ := "N "
			SC5->(MsUnLock())

			DbSelectArea("SC6")
			DbSetOrder(1)
			If DbSeek(xFilial("SC6")+cPedido)
				While !SC6->(Eof()) .And. cPedido == SC6->C6_NUM
					If Alltrim(SC6->C6_BLQ) == "R"
						DbSelectArea("SC6")
						DbSkip()
						Loop
					EndIf
					RecLock("SC6",.F.)
					//SC6->C6_BLOQUEI := "  "
					//SC6->C6_BLQ     := "  "
					SC6->(MsUnLock())

					cChave := xFilial("SC9")+SC6->C6_NUM
					DbSelectArea("SC9")
					DbSetOrder(1)
					DbSeek(cChave)

					While SC9->C9_PEDIDO == SC6->C6_NUM .And. SC9->C9_FILIAL  == xFilial("SC9") .And. !Eof()
						If SC9->C9_BLEST == "02"
							RecLock("SC9",.F.)
							//SC9->C9_BLEST  := "  "
							SC9->(MsUnLock())

							DbSelectArea("SB2")
							DbSetOrder(1)
							If !DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC6->C6_LOCAL,.F.)
								RecLock("SB2",.T.)
								//SB2->B2_FILIAL := xFilial("SB2")
								//SB2->B2_COD    := SC9->C9_PRODUTO
								//SB2->B2_LOCAL  := SC6->C6_LOCAL
							EndIf
							SB2->(MsUnLock())
						EndIf

						If SC9->C9_BLCRED  == "01"
							RecLock("SC9",.F.)
							//SC9->C9_BLCRED := "  "
							SC9->(MsUnLock())

							cChave := xFilial("SA1")+SC9->C9_CLIENTE+"  "
							DbSelectArea("SA1")
							DbSetOrder(1)
							DbSeek(cChave)

							_Lib := SA1->A1_SALPEDL + (SC9->C9_QTDLIB*SC9->C9_PRCVEN)
							_Blq := SA1->A1_SALPEDB - (SC9->C9_QTDLIB*SC9->C9_PRCVEN)

							RecLock("SA1",.F.)
							//SA1->A1_SALPEDL := _Lib
							//SA1->A1_SALPEDB := _Blq
							SA1->(MsUnLock())
						EndIf
						SC9->(DbSkip())
					EndDo
					SC6->(DbSkip())
				EndDo
				RestArea(aArea2)
				TRBPED->(DbGoTo(nRecNo))
			EndIf
		EndIf
		SetKey(VK_F5,)
	EndIf
	RestArea(aArea)
	If Chkfile("QRY_ITENS")
		QRY_ITENS->(DbCloseArea())
	EndIf
	TRBPED->(DbSetOrder(15))   ///Era utilizado 11
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FGETITENS | Autor | Felipe Zago Zechini   | Data | 15.12.2005|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição |Separa os itens dos parametros para inclusão na cláusula IN  |
|          | dos selects.                                                |
+----------+-------------------------------------------------------------+
|Parametros| cString  - String com os itens a serem separados            |
|          | nTamItem - Tamanho de cada item                             |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fGetItens(cString,nTamItem)
	Local nTam := Len(Alltrim(cString)),i
	Local cTmp := ""
	If Empty(cString)
		Return ""
	EndIf
	For i:= 1 To nTam Step nTamItem+1
		cTmp += "'"+AllTrim(Substr(cString,i,nTamItem))+"'"
		If i <= nTam - (nTamItem+1)
			cTmp += ','
		EndIf
	Next i
Return cTmp

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FTRABSC9  | Autor | Felipe Zago Zechini   | Data | 20.12.2005|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Query para obter a ultima sequencia do item que foi liberado|
|          | na tela de montagem de carga.                               |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fTrabSC9(cPedido)
	Local cQry := ""
	Local cSC9 := RetSqlName("SC9")

	cQry += " SELECT "
	cQry += "   TAB.PEDIDO PEDIDO, "
	cQry += "   TAB.ITEM ITEM, "
	cQry += "   TAB.SEQUEN SEQLIB, "
	cQry += "   C9.R_E_C_N_O_               RECNO, "
	cQry += "   C9.C9_QTDLIB                QTDLIB, "
	cQry += "   C9.C9_PRCVEN                PRCVEN, "
	cQry += "   (C9.C9_PRCVEN*C9.C9_QTDLIB) VALOR "
	cQry += " FROM "+cSC9+" C9, "
	cQry += "   (SELECT "
	cQry += "      C9_PEDIDO      PEDIDO, "
	cQry += "      C9_ITEM        ITEM, "
	cQry += "      MAX(C9_SEQUEN) SEQUEN "
	cQry += "    FROM "
	cQry += "      "+cSC9+"         C9 "
	cQry += "    WHERE "
	cQry += "      C9_FILIAL    = '"+xFilial("SC9")+"' AND "
	cQry += "      C9.C9_PEDIDO = '"+cPedido+"' AND "
	cQry += "      C9.D_E_L_E_T_= ' ' "
	cQry += "    GROUP BY "
	cQry += "      C9_PEDIDO, "
	cQry += "      C9_ITEM "
	cQry += "   ) TAB "
	cQry += " WHERE "
	cQry += "    C9.C9_PEDIDO = TAB.PEDIDO AND "
	cQry += "    C9.C9_ITEM   = TAB.ITEM   AND "
	cQry += "    C9.C9_SEQUEN = TAB.SEQUEN AND "
	cQry += "    C9.D_E_L_E_T_= ' ' "
	cQry += " ORDER BY PEDIDO, ITEM, SEQUEN "

	cQry := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),"QRY_ITENS",.F.,.T.)
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    | FSLDATUAL| Autor | Felipe Zago Zechini   | Data | 27.12.2005|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Processo para obtenção do saldo atual, bem como marcação    |
|          | automágica dos pedidos com saldo na tela de carga.          |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fSldAtual
	Local nQTD := 0
	aPedidos   := {}

	DbSelectArea("TRBSALDOS")
	DbSetOrder(1) /* ORDENADO PELO COD_PA //+ COD_PI */
	DbGoTop()
	DbSelectArea("QRYCART")
	QRYCART->(DbGoTop())
	oProcess:SetRegua2(QRYCART->(LastRec()))
	DbGoTop()
	/* Percorrer o arquivo de pedidos em carteira */
	While !QRYCART->(Eof())
		DbSelectArea("TRBPED")   // Pedidos na Tela
		DbSetOrder(6) // PED_PEDIDO + PED_ITEM
		/* Procurar para saber o pedido está sendo listado na tela */
		If DbSeek(QRYCART->PEDIDO + QRYCART->ITEM)
			DbSelectArea("TRBSALDOS")
			DbSetOrder(1)
			/* Procurar pelo produto na lista de saldos */
			If DbSeek(TRBPED->PED_CODPRO)
				/* Verificar se o produto tem sete digitos, onde pega-se direto o valor do PA pela menor caixa */
				If Len(AllTrim(TRBPED->PED_CODPRO)) = 7
					/* Verificar a origem, se é C6 ou C9 */
					If TRBPED->PED_BLOQ == "L"
						nRec := TRBSALDOS->(RecNo())
						nMin := 999999
						/* Encontrar o menor saldo entre os PI's */
						While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == TRBPED->PED_CODPRO
							nVal := TRBSALDOS->SALDO_PROD * TRBSALDOS->QUANT
							nMin := Iif(nVal < nMin,nVal,nMin)
							nQTD := Iif(nVal < nMin,TRBSALDOS->QUANT,1)
							TRBSALDOS->(DbSkip())
						EndDo
						/* Caso o saldo seja positivo, abater a quantidade */
						TRBSALDOS->(DbGoTo(nRec))
						//If TRBPED->PED_QTDLIB <= nMin/nQTD
						If TRBPED->PED_QTDLIB <= nMin/nQTD
							/* Marco o pedido na tela */
							aAdd(aPedidos, TRBPED->PED_PEDIDO + TRBPED->PED_ITEM)
						EndIf
						While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == TRBPED->PED_CODPRO
							/* Abato os saldos */
							RecLock("TRBSALDOS",.F.)
							TRBSALDOS->SALDO_PROD -= TRBPED->PED_QTDLIB * TRBSALDOS->QUANT
							TRBSALDOS->(MsUnlock())
							TRBSALDOS->(DbSkip())
						EndDo

					Else
						nRec := TRBSALDOS->(RecNo())
						nMin := 999999
						While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == TRBPED->PED_CODPRO
							nVal := TRBSALDOS->SALDO_PROD * TRBSALDOS->QUANT
							nMin := Iif(nVal < nMin,nVal,nMin)
							nQTD := Iif(nVal < nMin,TRBSALDOS->QUANT,1)
							TRBSALDOS->(DbSkip())
						EndDo
						/* Caso o saldo seja positivo, abater a quantidade */
						TRBSALDOS->(DbGoTo(nRec))
						//If TRBPED->PED_QTDPED <= nMin/nQTD
						If TRBPED->PED_QTDPED <= nMin/nQTD
							/* Marco o pedido na tela */
							aAdd(aPedidos, TRBPED->PED_PEDIDO + TRBPED->PED_ITEM)
						EndIf
						While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == TRBPED->PED_CODPRO
							/* Abato os saldos */
							RecLock("TRBSALDOS",.F.)
							TRBSALDOS->SALDO_PROD -= TRBPED->PED_QTDPED * TRBSALDOS->QUANT
							TRBSALDOS->(MsUnlock())
							TRBSALDOS->(DbSkip())
						EndDo
					EndIf
					/* Se for a nova codificação de produtos */
				Else
					/* Verificar a origem, se é C6 ou C9 */
					If TRBPED->PED_BLOQ == "L"
						nRec := TRBSALDOS->(RecNo())
						nMin := 999999
						/* Encontrar o menor saldo entre os PI's */
						While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == TRBPED->PED_CODPRO
							nVal := TRBSALDOS->SALDO_PROD * TRBSALDOS->QUANT
							nMin := Iif(nVal < nMin,nVal,nMin)
							nQTD := Iif(nVal < nMin,TRBSALDOS->QUANT,1)
							TRBSALDOS->(DbSkip())
						EndDo
						/* Caso o saldo seja positivo, abater a quantidade */
						TRBSALDOS->(DbGoTo(nRec))
						//If TRBPED->PED_QTDLIB <= nMin/nQTD
						If TRBPED->PED_QTDLIB <= nMin/nQTD
							/* Marco o pedido na tela */
							aAdd(aPedidos, TRBPED->PED_PEDIDO + TRBPED->PED_ITEM)
						EndIf
						While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == TRBPED->PED_CODPRO
							/* Abato os saldos */
							RecLock("TRBSALDOS",.F.)
							TRBSALDOS->SALDO_PROD -= TRBPED->PED_QTDLIB * TRBSALDOS->QUANT
							TRBSALDOS->(MsUnlock())
							TRBSALDOS->(DbSkip())
						EndDo
					Else
						nRec := TRBSALDOS->(RecNo())
						nMin := 999999
						While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == TRBPED->PED_CODPRO
							nVal := TRBSALDOS->SALDO_PROD * TRBSALDOS->QUANT
							nMin := Iif(nVal < nMin,nVal,nMin)
							nQTD := Iif(nVal < nMin,TRBSALDOS->QUANT,1)
							TRBSALDOS->(DbSkip())
						EndDo
						/* Caso o saldo seja positivo, abater a quantidade */
						TRBSALDOS->(DbGoTo(nRec))
						//If TRBPED->PED_QTDPED <= nMin/nQTD
						If TRBPED->PED_QTDPED <= nMin/nQTD
							/* Marco o pedido na tela */
							aAdd(aPedidos, TRBPED->PED_PEDIDO + TRBPED->PED_ITEM)
						EndIf
						While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == TRBPED->PED_CODPRO
							/* Abato os saldos */
							RecLock("TRBSALDOS",.F.)
							TRBSALDOS->SALDO_PROD -= TRBPED->PED_QTDPED * TRBSALDOS->QUANT
							TRBSALDOS->(MsUnlock())
							TRBSALDOS->(DbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
			/* Tratamos aqui os pedidos que não se encontram listados na tela */
		Else
			DbSelectArea("TRBSALDOS")
			DbSetOrder(1)
			/* Procurar pelo produto na lista de saldos */
			If DbSeek(QRYCART->PRODUTO)
				/* Verificar se o produto tem sete digitos, onde pega-se direto o valor do PA pela menor caixa */
				If Len(AllTrim(QRYCART->PRODUTO)) == 7
					//If QRYCART->QTDVEN <= TRBSALDOS->SALDO_PROD
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYCART->QTDVEN
					TRBSALDOS->(MsUnlock())
					//EndIf
				Else
					nRec := TRBSALDOS->(RecNo())
					nMin := 99999999999999999999
					/* Encontrar o menor saldo entre os PI's */
					While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == QRYCART->PRODUTO
						nVal := TRBSALDOS->SALDO_PROD * TRBSALDOS->QUANT
						nMin := Iif(nVal < nMin,nVal,nMin)
						nQTD := Iif(nVal < nMin,TRBSALDOS->QUANT,1)
						TRBSALDOS->(DbSkip())
					EndDo
					/* Caso o saldo seja positivo, abater a quantidade */
					//If QRYCART->QTDVEN <= nMin/nQTD  Retirado porque o Aclimar disse que os pedidos devem ser considerados de qualquer forma
					TRBSALDOS->(DbGoTo(nRec))
					While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == QRYCART->PRODUTO
						/* Abato os saldos */
						RecLock("TRBSALDOS",.F.)
						TRBSALDOS->SALDO_PROD -= QRYCART->QTDVEN * TRBSALDOS->QUANT
						TRBSALDOS->(MsUnlock())
						TRBSALDOS->(DbSkip())
					EndDo
					//EndIf
				EndIf
			EndIf
		EndIf
		QRYCART->(DbSkip())
		oProcess:IncRegua2("Marcando pedidos com saldo...")
	EndDo
	QRYCART->(DbCloseArea())
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FSLDANT   | Autor | Felipe Zago Zechini   | Data | 27.12.2005|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Processo para obtencao do saldo anterior ao primeiro pedido |
|          | na tela, para ser descontado do saldo atual.                |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fSldAnt(cPrimeiro, cCli2,wcUsuario,cConsultor)
	Local cQrySldAnt := ""

	cQrySldAnt += " SELECT TAB.PRODUTO AS COD_PA, ISNULL(SUM(C6.C6_QTDVEN)-SUM(C6.C6_QTDENT), 0) AS QUANT_VEND"
	cQrySldAnt += "   FROM (SELECT TAB.PRODUTO, TAB.VEND "
	cQrySldAnt += "           FROM (SELECT DISTINCT (PRODUTO) AS PRODUTO, VEND "
	cQrySldAnt += "                   FROM PED_TELA_"+wcUsuario+") TAB) TAB "
	cQrySldAnt += "  INNER JOIN "+cSC6+" C6 ON C6.C6_PRODUTO = TAB.PRODUTO "
	cQrySldAnt += "                      AND C6.D_E_L_E_T_ = ' ' "
	cQrySldAnt += "                      AND C6.C6_NUM < '"+cPrimeiro+"' "
	cQrySldAnt += "                      AND (C6.C6_QTDVEN - C6.C6_QTDENT) > 0"
	If !Empty(cCli2)
		cQrySldAnt += "                  AND (C6.C6_CLI + C6.C6_LOJA) NOT IN ("+cCli2+")"
	EndIf
	If !Empty(cDescVend)
		cQrySldAnt += "  INNER JOIN "+cSC5+" C5 ON C5.C5_NUM = C6.C6_NUM "
		cQrySldAnt += "  AND C5.C5_VEND1 NOT IN ("+cDescVend+") "+cFim
	EndIf
	// Este parametro foi incluído por solicitação de Wanisay, após reunião com a diretoria em 22/03/06 - zago
	If nConsVend == 2 // Caso o usuário deseje considerar apenas os vendedores digitados
		If Empty(cDescVend)
			cQrySldAnt += "  INNER JOIN "+cSC5+" C5 ON C5.C5_NUM = C6.C6_NUM "
		EndIf
		cQrySldAnt += " AND C5.C5_VEND1 IN ("+cConsultor+") "+cFim
	EndIf
	cQrySldAnt += "  GROUP BY TAB.PRODUTO"
	cQrySldAnt += "  ORDER BY COD_PA "

	TcQuery cQrySldAnt New Alias "QRYSLDANT"

	DbSelectArea("QRYSLDANT")
	TRBSALDOS->(DbGoTop())
	While !QRYSLDANT->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(1)
		If DbSeek(QRYSLDANT->COD_PA)
			If Len(AllTrim(QRYSLDANT->COD_PA)) == 7
				While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == QRYSLDANT->COD_PA
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYSLDANT->QUANT_VEND
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			Else
				While !TRBSALDOS->(Eof()) .And. TRBSALDOS->COD_PA == QRYSLDANT->COD_PA
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYSLDANT->QUANT_VEND * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYSLDANT->(DbSkip())
	EndDo
	QRYSLDANT->(DbCloseArea())
Return

Static Function fCarga(wcUsuario)
	Local cQryCarga := ""
	Local cFim      := Chr(13)

	// Deduzindo os saldos dos produtos com 10 dígitos.
	cQryCarga := ""
	cQryCarga += " SELECT G12.G1_COMP  AS COD_PA, SUM(C9.C9_QTDLIB)*G12.G1_QUANT AS QUANT_CARGA "
	cQryCarga += "   FROM SC9010 C9 INNER JOIN " + RetSqlName("SG1") + " G12 "
	cQryCarga += "                  ON  G12.G1_COD     = C9.C9_PRODUTO "
	cQryCarga += "                  AND G12.D_E_L_E_T_ = ' '  "
	cQryCarga += "                  INNER JOIN SB1010 SB1 "
	cQryCarga += "                  ON  SB1.B1_COD     = C9.C9_PRODUTO  "
	cQryCarga += "                  AND SB1.D_E_L_E_T_ = ' ' "
	cQryCarga += "  WHERE C9.D_E_L_E_T_  = ' '  "
	cQryCarga += "    AND C9.C9_CARGA   <> ' '  "
	cQryCarga += "    AND C9.C9_NFISCAL  = ' '  "
	cQryCarga += "    AND LENGTH(RTRIM(C9.C9_PRODUTO)) = 10 "
	cQryCarga += "  GROUP BY G12.G1_COMP, G12.G1_QUANT "
	cQryCarga += "  ORDER BY G12.G1_COMP "

	TcQuery cQryCarga New Alias "QRYCARGA"

	DbSelectArea("QRYCARGA")
	TRBSALDOS->(DbGoTop())
	While !QRYCARGA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(1)
		If DbSeek(QRYCARGA->COD_PA)
			If Len(AllTrim(QRYCARGA->COD_PA)) == 7
				RecLock("TRBSALDOS",.F.)
				TRBSALDOS->SALDO_PROD -= QRYCARGA->QUANT_CARGA
				TRBSALDOS->(MsUnlock())
			EndIf
		EndIf
		QRYCARGA->(DbSkip())
	EndDo
	DbSelectArea("QRYCARGA")
	QRYCARGA->(DbGoTop())
	While !QRYCARGA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(2) //Indice do campo COD_PI
		If DbSeek(QRYCARGA->COD_PA)
			If Len(AllTrim(QRYCARGA->COD_PA)) == 13   //TRATAMENTO PARA CARGAS DE PA - INCLUÍDO 24/03/2006 - ALEXANDRE N. PANETTO
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYCARGA->COD_PA
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYCARGA->QUANT_CARGA * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYCARGA->(DbSkip())
	EndDo
	QRYCARGA->(DbCloseArea())

	// Deduzindo os saldos dos produtos com 7 e 13 dígitos.
	cQryCarga := ""
	cQryCarga += " SELECT TAB.PRODUTO AS COD_PA, ISNULL(SUM(SC9.C9_QTDLIB), 0) AS QUANT_CARGA "+cFim
	cQryCarga += "  FROM (SELECT TAB.PRODUTO "+cFim
	cQryCarga += "            FROM (SELECT DISTINCT (PRODUTO) AS PRODUTO "+cFim
	cQryCarga += "                    FROM PED_TELA_"+wcUsuario+") TAB) TAB "+cFim
	cQryCarga += "        INNER JOIN "+cSC9+" SC9 "+cFim
	cQryCarga += "          ON  SC9.C9_PRODUTO = TAB.PRODUTO "+cFim
	cQryCarga += "          AND SC9.D_E_L_E_T_ = ' ' "+cFim
	cQryCarga += "          AND SC9.C9_NFISCAL = ' ' "+cFim
	cQryCarga += "          AND SC9.C9_CARGA <> ' ' "+cFim
	cQryCarga += "          AND LENGTH(RTRIM(SC9.C9_PRODUTO)) IN (7,13) "+cFim
	cQryCarga += "   GROUP BY TAB.PRODUTO  "+cFim
	cQryCarga += "   ORDER BY COD_PA "

	TcQuery cQryCarga New Alias "QRYCARGA"

	DbSelectArea("QRYCARGA")
	TRBSALDOS->(DbGoTop())
	While !QRYCARGA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(1)
		If DbSeek(QRYCARGA->COD_PA)
			If Len(AllTrim(QRYCARGA->COD_PA)) == 7
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PA == QRYCARGA->COD_PA
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYCARGA->QUANT_CARGA
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYCARGA->(DbSkip())
	EndDo
	DbSelectArea("QRYCARGA")
	QRYCARGA->(DbGoTop())
	While !QRYCARGA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(2) //Indice do campo COD_PI
		If DbSeek(QRYCARGA->COD_PA)
			If Len(AllTrim(QRYCARGA->COD_PA)) == 13   //TRATAMENTO PARA CARGAS DE PI - INCLUÍDO 24/03/2006 - ALEXANDRE N. PANETTO
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYCARGA->COD_PA
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYCARGA->QUANT_CARGA * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
			//TRATAMENTO PARA CARGAS DE PI - INCLUÍDO 10/04/2006 - ALEXANDRE N. PANETTO
			If Len(AllTrim(QRYCARGA->COD_PA)) == 7
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYCARGA->COD_PA .AND. TRBSALDOS->COD_PA <> TRBSALDOS->COD_PI
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYCARGA->QUANT_CARGA * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf

		EndIf
		QRYCARGA->(DbSkip())
	EndDo
	QRYCARGA->(DbCloseArea())

Return

/*+----------+----------+-------+----------- ------------+------+-----------+
|Função    |FRESERVA2 | Autor | Felipe Zago Zechini   | Data | 12.01.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Processo para dedução dos saldos dos produtos com reserva,  |
|          | a ser executado após a obtenção do saldo anterior.          |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fReserva2(cCli2, wcUsuario)
	Local cQryReserv := ""
	Local cFim       := Chr(13)

	cQryReserv += "    SELECT C0_PRODUTO AS COD_PA, SUM(C0.C0_QUANT) AS QUANT_RES "+cFim
	cQryReserv += "    FROM "+cSC0+" C0 "+cFim
	cQryReserv += "    WHERE C0.D_E_L_E_T_ = ' '  "+cFim
	cQryReserv += "    GROUP BY C0_PRODUTO "+cFim

	TcQuery cQryReserv New Alias "QRYRESERVA"

	DbSelectArea("QRYRESERVA")
	QRYRESERVA->(DbGoTop())
	//TRBSALDOS->(DbGoTop())

	While !QRYRESERVA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(1)
		If DbSeek(QRYRESERVA->COD_PA)
			//If Len(AllTrim(QRYRESERVA->COD_PA)) == 7
			RecLock("TRBSALDOS",.F.)
			TRBSALDOS->SALDO_PROD -= QRYRESERVA->QUANT_RES
			TRBSALDOS->(MsUnlock())
			//EndIf
		EndIf
		QRYRESERVA->(DbSkip())
	EndDo
	QRYRESERVA->(DbCloseArea())
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    | FCONDPAG | Autor | Felipe Zago Zechini   | Data | 16.01.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Processo para ajuste automatico da condição de pagamento do |
|          | pedido.                                                     |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fCondPag(cMarca)
	Local aArea   := GetArea(),i
	Local nPrzMed := 0
	local nQtdPar := 0
	Local nSoma   := 0
	Local nMedia  := 0
	Local nMinimo := 0
	Local cCondP  := ""
	Local cCondPO := ""
	Local cPedAtu := ""
	Local nNumPar := 0 // Número de parcelas calculado
	Local cQry    := ""
	Local cSE4    := RetSqlName("SE4")
	Local cCodCond:= ""
	Local nPercFre:= 0
	Local cCliente:= ""

	DbSelectArea("TRBPED")
	DbGoTop()
	DbSetOrder(6) /* PED_PEDIDO+PED_ITEM */
	cPedAtu := TRBPED->PED_PEDIDO
	While !TRBPED->(Eof())
		nMinimo := TRBPED->PED_VLMPED
		nPercFre:= (Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_YFRETE"))/100
		cCliente:= TRBPED->PED_CODCLI+"/"+TRBPED->PED_LOJA
		// Pedidos do Tipo "Vendor" devem ser descosiderados na alteração de Cond. Pag.
		//If TRBPED->PED_MARCA <> '  ' .AND. TRBPED->PED_VLMPED > 0 .And. TRBPED->PED_TIPPED != 'V ' .AND. TRBPED->PED_TIPPED != 'PV' .AND.;
		//   TRBPED->PED_TIPPED != 'MV'
		If TRBPED->PED_MARCA <> '  ' .AND. TRBPED->PED_VLMPED > 0 .And. TRBPED->PED_TIPPED != 'V ' .AND. TRBPED->PED_TIPPED != 'X ' .AND.;
		TRBPED->PED_TIPPED != 'Y ' .AND. TRBPED->PED_TIPPED != 'F '
			nSoma   := 0
			cCondP  := TRBPED->PED_CONDPG // CONDIÇÃO DE PAGAMENTO ATUAL
			cCondPO := TRBPED->PED_YCONDP // CONDIÇÃO DE PAGAMENTO ORIGINAL
			While !TRBPED->(Eof()) .And. cPedAtu == TRBPED->PED_PEDIDO
				If TRBPED->PED_MARCA <> '  '
					nSoma += TRBPED->PED_VALOR
				EndIf
				TRBPED->(DbSkip())
			EndDo
			If nPercFre > 0
				nSoma := nSoma * (1 + nPercFre)
			EndIf
			/*
			NOVO! CONVERSANDO COM ACLIMAR, DESCOBRIU-SE QUE DEVE-SE SEMPRE CONSIDERAR A CONDPAG ORIGINAL PARA O CÁLCULO DA MÉDIA - 26/01/05 - 18:25
			nQtdPar := Posicione("SE4",1,xFilial("SE4")+cCondP,"E4_YNROPAR") // QUANTIDADE DE PARCELAS ATUAL
			cCondP  := Posicione("SE4",1,xFilial("SE4")+cCondP,"E4_COND")
			*/
			nQtdPar := Posicione("SE4",1,xFilial("SE4")+cCondPO,"E4_YNROPAR") // QUANTIDADE DE PARCELAS ATUAL
			cCondP  := Posicione("SE4",1,xFilial("SE4")+cCondPO,"E4_COND")

			nMedia  := Int(fGetCondP(cCondP) / nQtdPar)
			nNumPar := Int(nSoma / nMinimo)  // NÚMERO DE PARCELAS CALCULADO
			nQtdParO := Posicione("SE4",1,xFilial("SE4")+cCondPO,"E4_YNROPAR") // QUANTIDADE DE PARCELAS ORIGINAL

			If nNumPar < 1
				nNumPar := 1
			EndIf

			If nNumPar >= nQtdParO
				nNumPar := nQtdParO
				SC5->(DbSetOrder(1))
				If SC5->(DbSeek(xFilial("SC5")+cPedAtu))
					RecLock("SC5",.F.)
					//SC5->C5_CONDPAG := cCondPO
					SC5->(MsUnlock())
				EndIf
			Else
				cQry := "SELECT E4_CODIGO, E4_COND FROM "+cSE4
				cQry += " WHERE E4_YNROPAR = "+Str(nNumPar)
				cQry += " AND E4_YPRZMED = "+Str(nMedia)
				cQry += " AND D_E_L_E_T_ = ' '"
				If ChkFile("QRYCONDP",.F.)
					DbSelectArea("QRYCONDP")
					DbCloseArea("QRYCONDP")
				EndIf
				TcQuery cQry New Alias "QRYCONDP"

				cQry2 := "SELECT COUNT(*) QTD FROM "+cSE4
				cQry2 += " WHERE E4_YNROPAR = "+Str(nNumPar)
				cQry2 += " AND E4_YPRZMED = "+Str(nMedia)
				cQry2 += " AND D_E_L_E_T_ = ' '"
				If ChkFile("QRYCOUNT",.F.)
					DbSelectArea("QRYCOUNT")
					DbCloseArea("QRYCOUNT")
				EndIf
				TcQuery cQry2 New Alias "QRYCOUNT"

				If QRYCOUNT->QTD > 0
					QRYCONDP->(DbGoTop())
					cCodCond := QRYCONDP->E4_CODIGO
					SC5->(DbSetOrder(1))
					If SC5->(DbSeek(xFilial("SC5")+cPedAtu))
						RecLock("SC5",.F.)
						//SC5->C5_CONDPAG := cCodCond
						SC5->(MsUnlock())
					EndIf
				Else
					If ChkFile("QRYCONDP",.F.)
						DbCloseArea("QRYCONDP")
					EndIf
					If ChkFile("QRYCOUNT",.F.)
						DbCloseArea("QRYCOUNT")
					EndIf
					/* NOVO! - 25/01/06 às 16:00
					Existe uma tolerância de até 15 dias, caso não exista um prazo médio exato.
					Deve-se exibir uma mensagem indicando que não foi possível alterar a cond. pagto.*/
					For i:= 1 to 15
						nMedia++
						cQry := "SELECT E4_CODIGO, E4_COND FROM "+cSE4
						cQry += " WHERE E4_YNROPAR = "+Str(nNumPar)
						cQry += " AND E4_YPRZMED = "+Str(nMedia)
						cQry += " AND D_E_L_E_T_ = ' '"
						If ChkFile("QRYCP",.F.)
							DbSelectArea("QRYCP")
							DbCloseArea("QRYCP")
						EndIf
						TcQuery cQry New Alias "QRYCP"

						cQry2 := "SELECT COUNT(*) QTD FROM "+cSE4
						cQry2 += " WHERE E4_YNROPAR = "+Str(nNumPar)
						cQry2 += " AND E4_YPRZMED = "+Str(nMedia)
						cQry2 += " AND D_E_L_E_T_ = ' '"
						If ChkFile("QRYCONT",.F.)
							DbSelectArea("QRYCONT")
							DbCloseArea("QRYCONT")
						EndIf
						TcQuery cQry2 New Alias "QRYCONT"

						If QRYCONT->QTD > 0
							QRYCP->(DbGoTop())
							cCodCond := QRYCP->E4_CODIGO
							SC5->(DbSetOrder(1))
							If SC5->(DbSeek(xFilial("SC5")+cPedAtu))
								RecLock("SC5",.F.)
								//SC5->C5_CONDPAG := cCodCond
								SC5->(MsUnlock())
							EndIf
							Exit
						EndIf
						If ChkFile("QRYCP",.F.)
							DbCloseArea("QRYCP")
						EndIf
						If ChkFile("QRYCONT",.F.)
							DbCloseArea("QRYCONT")
						EndIf
					Next i
					If i > 15
						cMsg := "Não foi encontrada uma condição de pagamento apropriada (Acrescida de 15 dias)."+Chr(13)+Chr(13)
						cMsg += "Cliente/Loja: "+cCliente+Chr(13)
						cMsg += "Pedido: "+cPedAtu+Chr(13)
						cMsg += "Prazo médio calculado: "+Alltrim(Str(nMedia))+Chr(13)
						cMsg += "Numero de parcelas calculado: "+Alltrim(Str(nNumPar))+Chr(13)
						cMsg += "Condição original: "+cCondPO+" / "+Posicione("SE4",1,xFilial("SE4")+cCondPO,"E4_DESCRI")
						MsgAlert(cMsg)
					EndIf
				EndIf
			EndIf
		Else
			TRBPED->(DbSkip())
		EndIf
		nPercFre:= Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_YFRETE")
		cPedAtu := TRBPED->PED_PEDIDO
	EndDo
	RestArea(aArea)
Return


/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FEXCRES   | Autor | Alexandre N. Panetto  | Data | 06.11.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Processo para excluir as reservas dos pedidos da carga      |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fExcRes(cMarca)
	Local aArea   := GetArea()
	DbSelectArea("TRBPED")
	DbGoTop()
	DbSetOrder(6) /* PED_PEDIDO+PED_ITEM */
	While !TRBPED->(Eof())
		DbSelectArea("ZZ4")
		DbSetOrder(3)
		If TRBPED->PED_MARCA <> '  '
			If ZZ4->(MsSeek(xFilial("ZZ4")+TRBPED->PED_PEDIDO+TRBPED->PED_CODCLI+TRBPED->PED_LOJA+TRBPED->PED_CODPRO))
				RecLock("ZZ4",.F.)
				ZZ4->ZZ4_QUANT -= TRBPED->PED_QTDLIB
				ZZ4->(MsUnlock())
				If ZZ4->ZZ4_QUANT <= 0
					RecLock("ZZ4")
					ZZ4->(dbDelete())
				EndIf
			EndIf
		EndIf
		TRBPED->(DbSkip())
	EndDo
	RestArea(aArea)
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FGETCONDP | Autor | Felipe Zago Zechini   | Data | 16.01.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Processo para soma do numero de dias das parcelas.          |
|          |                                                             |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fGetCondP(cCondP)
	Local nPos   := 0
	Local nProx  := 0
	Local nSoma  := 0
	Local nQtdP  := 0

	cCondP := Alltrim(cCondP)

	// Verifica se há apenas um item
	nPos := At(",",cCondP)
	If nPos == 0
		Return Val(cCondP)
	Else
		nSoma += Val(Substr(cCondP,1,nPos-1))
		cCondP := Substr(cCondP,nPos+1)
		nPos := At(",",cCondP)
		nQtdP ++
		If nPos != 0
			While nPos != 0
				nSoma += Val(Substr(cCondP,1,nPos-1))
				cCondP := Substr(cCondP, nPos+1)
				nPos := At(",",cCondP)
				nQtdP ++
			EndDo
			nSoma += Val(Substr(cCondP,1))
			nQtdP ++
		ElseIf !Vazio(cCondP)
			nSoma += Val(Substr(cCondP,1,3))
		EndIf
	EndIf
Return nSoma

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FAGLUTINA | Autor | Felipe Zago Zechini   | Data | 18.01.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Processo para aglutinar os pedidos com as mesmas caracteris |
|          | ticas na mesma condicao de pagamento.                       |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fAglutina(cMarca)
	Static _PEDIDO    := 1
	Static _ITEM      := 2
	Static _CONSULTOR := 3
	Static _TRANSPORT := 4
	Static _TES       := 5
	Static _TABELA    := 6
	Static _DESCONTO  := 7
	Static _CODCONDP  := 8
	Static _CONDPAG   := 9
	Static _NROPARC   := 10
	Static _VALOR     := 11
	Static _VUNIT     := 12
	Static _PRODUTO   := 13
	Static _PERCFRE   := 14
	Static _PARCMAX   := 15
	Static _PARCORI   := 16
	Static nTam       := 16

	Local  cSE4       := RetSqlName("SE4")

	Local  aArea      := GetArea()
	Local  aMatriz    := {}
	Local  aLinha
	Local  cCliAtu    := ""
	Local  cQry       := ""
	Local  nRecno     := 0

	Local cTransp     := "" // Transportadora - Buscar do C5_TRANSP
	Local cVend1      := "" // Consultor - Buscar do C5_VEND1
	Local cTes        := "" // TES - Buscar do C6_TES
	Local cDescont    := 0  // Descontos - Buscar do TRBPED
	Local cTabela     := "" // Buscar do C5_TABELA

	Local nPrzMed     := 0
	local nQtdPar     := 0
	local nQtdParO    := 0
	Local cCondPO     := ""
	Local nSoma       := 0
	Local nMedia      := 0
	Local nMinimo     := 0
	Local cCondP      := ""
	Local cPedAtu     := ""
	Local nNumPar     := 0 // Número de parcelas calculado
	Local cCodCond    := ""
	Local nValor      := 0

	Local i           := 0

	DbSelectArea("TRBPED")
	DbSetOrder(13)
	DbGoTop()

	/* Inicializar o primeiro cliente */
	cCliAtu := TRBPED->PED_CODCLI + TRBPED->PED_LOJA
	While !TRBPED->(Eof())
		If TRBPED->PED_MARCA == cMarca .And. TRBPED->PED_AGLUT <> "S" //.And. CAMPO ONDE INDICA SE CLIENTE PERMITE AGLUTINAR PEDIDOS
			cCondPO := TRBPED->PED_YCONDP // CONDIÇÃO DE PAGAMENTO ORIGINAL
			/* Pega o registro atual, para retornar ao mesmo após a análise dos pedidos */
			nRecNo  := TRBPED->(RecNo())
			/* Adiciona este pedido a matriz e marca o registro como aglutinado (para que não entre em nova análise) */
			nMinimo := TRBPED->PED_VLMPED
			aLinha  := Array(nTam)
			aLinha[_PEDIDO   ] := TRBPED->PED_PEDIDO
			aLinha[_ITEM     ] := TRBPED->PED_ITEM
			aLinha[_CONSULTOR] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_VEND1")
			aLinha[_TRANSPORT] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_REDESP")
			aLinha[_TES      ] := Posicione("SC6",1,xFilial("SC6")+TRBPED->PED_PEDIDO+TRBPED->PED_ITEM,"C6_TES")
			aLinha[_TABELA   ] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_TABELA")
			aLinha[_DESCONTO ] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_YDESC01")
			aLinha[_CODCONDP ] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_CONDPAG") //TRBPED->PED_CONDPG
			aLinha[_CONDPAG  ] := Posicione("SE4",1,xFilial("SE4")+aLinha[_CODCONDP ],"E4_COND")
			aLinha[_NROPARC  ] := Posicione("SE4",1,xFilial("SE4")+aLinha[_CODCONDP],"E4_YNROPAR")
			aLinha[_VALOR    ] := TRBPED->PED_VALOR
			aLinha[_VUNIT    ] := NoRound(TRBPED->PED_VALOR / TRBPED->PED_QTDLIB,2)
			aLinha[_PRODUTO  ] := TRBPED->PED_CODPRO
			aLinha[_PERCFRE  ] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_YFRETE")//TRBPED->PED_CODPRO
			aLinha[_PARCMAX  ] := Posicione("SE4",1,xFilial("SE4")+cCondPO,"E4_YNROPAR") // QUANTIDADE DE PARCELAS ORIGINAL
			aLinha[_PARCORI  ] := TRBPED->PED_YCONDP //CÓDIGO DA CONDIÇÃO DE PAGAMENTO ORIGINAL
			aAdd(aMatriz, aLinha)

			nMedia  := Int(fGetCondP(aLinha[_CONDPAG]) / aLinha[_NROPARC])
			RecLock("TRBPED",.F.)
			TRBPED->PED_AGLUT := "S"
			TRBPED->(MsUnlock())
			nQtdPar  := aLinha[_NROPARC]
			nQtdParO := Posicione("SE4",1,xFilial("SE4")+cCondPO,"E4_YNROPAR") // QUANTIDADE DE PARCELAS ORIGINAL

			TRBPED->(DbSkip())
			/* Repetir enquanto for o mesmo cliente, adicionando à matriz os que sejam iguais ao primeiro */
			While !TRBPED->(Eof()) .And. TRBPED->PED_CODCLI + TRBPED->PED_LOJA == cCliAtu
				If TRBPED->PED_MARCA == cMarca .And. TRBPED->PED_AGLUT <> "S"
					cCondPO := TRBPED->PED_YCONDP // CONDIÇÃO DE PAGAMENTO ORIGINAL
					/* Verifica se o pedido atual encaixa-se na matriz */
					aLinha := Array(nTam)
					aLinha[_PEDIDO   ] := TRBPED->PED_PEDIDO
					aLinha[_ITEM     ] := TRBPED->PED_ITEM
					aLinha[_CONSULTOR] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_VEND1")
					aLinha[_TRANSPORT] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_REDESP")
					aLinha[_TES      ] := Posicione("SC6",1,xFilial("SC6")+TRBPED->PED_PEDIDO+TRBPED->PED_ITEM,"C6_TES")
					aLinha[_TABELA   ] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_TABELA")
					aLinha[_DESCONTO ] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_YDESC01")
					aLinha[_CODCONDP ] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_CONDPAG") //TRBPED->PED_CONDPG
					aLinha[_CONDPAG  ] := Posicione("SE4",1,xFilial("SE4")+aLinha[_CODCONDP],"E4_COND")
					aLinha[_NROPARC  ] := Posicione("SE4",1,xFilial("SE4")+aLinha[_CODCONDP],"E4_YNROPAR")
					aLinha[_VALOR    ] := TRBPED->PED_VALOR
					aLinha[_VUNIT    ] := NoRound(TRBPED->PED_VALOR / TRBPED->PED_QTDLIB,2)
					aLinha[_PRODUTO  ] := TRBPED->PED_CODPRO
					aLinha[_PERCFRE  ] := Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_YFRETE")//TRBPED->PED_CODPRO
					aLinha[_PARCMAX  ] := Posicione("SE4",1,xFilial("SE4")+cCondPO,"E4_YNROPAR") // QUANTIDADE DE PARCELAS ORIGINAL
					aLinha[_PARCORI  ] := TRBPED->PED_YCONDP //CÓDIGO DA CONDIÇÃO DE PAGAMENTO ORIGINAL
					/* Verificar se o pedido atual é semelhante ao principal da matriz */
					If fSaoIguais(aLinha, aMatriz, nMedia)
						/* Ocorrências do mesmo produto na matriz */
						If aScan(aMatriz, {|x| x[13] == aLinha[13]}) <> 0
							/* Verificar se o produto que está sendo incluído possui o mesmo valor */
							If fValidProd(aMatriz, aLinha[_PRODUTO],aLinha[_VUNIT])
								aAdd(aMatriz, aLinha)
								RecLock("TRBPED",.F.)
								TRBPED->PED_AGLUT := "S"
								TRBPED->(MsUnlock())
							EndIf
						Else
							aAdd(aMatriz, aLinha)
							RecLock("TRBPED",.F.)
							TRBPED->PED_AGLUT := "S"
							TRBPED->(MsUnlock())
						EndIf
					EndIf
				EndIf
				TRBPED->(DbSkip())
			EndDo
			/* Existe mais de um pedido semelhante na matriz */
			If Len(aMatriz) > 1
				/* Caso existam registros que possam ser aglutinados, procedemos o ajuste das condições de pagamento */
				For i:= 1 to Len(aMatriz)
					nValor += aMatriz[i,_VALOR]
				Next i

				nNumPar := Int(nValor / nMinimo) //NÚMERO DE PARCELAS CALCULADO

				If nNumPar < 1
					nNumPar := 1
				EndIf
				nParMax := 0
				//Busca a maior quantidade de parcelas das condições originais.
				For i:= 1 to Len(aMatriz)
					If aMatriz[i,_PARCMAX] > nParMax
						nParMax := aMatriz[i,_PARCMAX]
						cCondPO := aMatriz[i,_PARCORI]
					EndIf
				Next i
				If nNumPar > nQtdParO
					nNumPar := nQtdParO
					SC5->(DbSetOrder(1))
					If SC5->(DbSeek(xFilial("SC5")+cPedAtu))
						RecLock("SC5",.F.)
						//SC5->C5_CONDPAG := cCondPO
						SC5->(MsUnlock())
					EndIf
				Else
					cQry := "SELECT E4_CODIGO, E4_COND FROM "+cSE4
					cQry += " WHERE E4_YNROPAR = "+Str(nNumPar)
					cQry += " AND E4_YPRZMED = "+Str(nMedia)
					cQry += " AND D_E_L_E_T_ = ' '"
					TcQuery cQry New Alias "QRYCONDP"

					cQry2 := "SELECT COUNT(*) QTD FROM "+cSE4
					cQry2 += " WHERE E4_YNROPAR = "+Str(nNumPar)
					cQry2 += " AND E4_YPRZMED = "+Str(nMedia)
					cQry2 += " AND D_E_L_E_T_ = ' '"
					TcQuery cQry2 New Alias "QRYCOUNT"
				EndIf
			EndIf
		EndIf
		nSoma   := 0
		aMatriz := {}
		cCliAtu := TRBPED->PED_CODCLI + TRBPED->PED_LOJA
	EndDo
	RestArea(aArea)
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FSAOIGUAIS| Autor | Felipe Zago Zechini   | Data | 18.01.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Verifica se as caracteristicas do pedido batem com as do 1º |
|          | na matriz.                                                  |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fSaoIguais(aLinha, aMatriz, nMediaPed)
	Local nMedia
	nMedia := Int(fGetCondP(aLinha[_CONDPAG]) / aLinha[_NROPARC])
	If 	aLinha[_CONSULTOR] == aMatriz[1,_CONSULTOR] .And. ;
	aLinha[_TRANSPORT] == aMatriz[1,_TRANSPORT] .And. ;
	aLinha[_TES      ] == aMatriz[1,_TES      ] .And. ;
	aLinha[_TABELA   ] == aMatriz[1,_TABELA   ] .And. ;
	aLinha[_DESCONTO ] == aMatriz[1,_DESCONTO ]	.And. ;
	aLinha[_PERCFRE  ] == aMatriz[1,_PERCFRE  ]	.And. ;
	nMedia == nMediaPed
		Return .T.
	EndIf
Return .F.

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FVALIDPROD| Autor | Felipe Zago Zechini   | Data | 18.01.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Verifica se o produto encontrado na matriz bate com o valor |
|          | unitário esperado.                                          |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fValidProd(aMatriz, cProduto, nVunit)
	If aScan(aMatriz, {|x| x[13]+Str(x[12]) == cProduto+Str(nVunit)}) <> 0
		Return .T.
	EndIf
Return .F.

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FQUANT    | Autor | Felipe Zago Zechini   | Data | 04.02.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Verifica se o item do pedido está marcado na tela de carga. |
|          | Caso não esteja, zera a quantidade a ser liberada.          |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fQuant(cPedido)
	Local aArea  := GetArea()
	Local i      := 0
	Local x      := 0
	DbSelectArea("TRBPED")
	DbSetOrder(6) // PEDIDO + ITEM
	For i:= 1 to Len(aCols)
		//If DbSeek(cPedido + GdFieldGet("C6_ITEM",i)) .And. TRBPED->PED_MARCA <> "  "
		If !DbSeek(cPedido + GdFieldGet("C6_ITEM",i)) .OR. TRBPED->PED_MARCA == "  "
			GdFieldPut("C6_QTDLIB",0,i)
		EndIf
		If DbSeek(cPedido + GdFieldGet("C6_ITEM",i)) .AND. TRBPED->PED_MARCA <> "  "
			If (TRBPED->PED_QTDPED > TRBPED->PED_RESERV) .AND. TRBPED->PED_RESERV > 0
				Alert('A quantidade do pedido e maior que a quantidade reservada.'+CHR(13)+' ITEM = '+TRBPED->PED_ITEM +CHR(13)+'QTD. Pedido = '+ALLTRIM(STR(TRBPED->PED_QTDPED)) +CHR(13)+'QTD. Reservada = '+ALLTRIM(STR(TRBPED->PED_RESERV)) )
			EndIf
		EndIf

	Next i
	RestArea(aArea)
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FGETREDESP| Autor | Felipe Zago Zechini   | Data | 05.02.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Preenche coluna de redespacho na tela de sequencia de       |
|          | entrega.                                                    |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fGetRedesp(cChave)
	Local cTransp := Posicione("SC5",1,xFilial("SC5")+cChave,"C5_REDESP")
	Local cNome   := Posicione("SA4",1,xFilial("SA4")+cTransp,"A4_NOME")
	If Empty(cNome)
		Return ""
	EndIf
Return cNome

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FGETPESOS | Autor | Felipe Zago Zechini   | Data | 08.02.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Preenche o peso total direcionado para cada rota no grid    |
|          | da montagem de carga.                                       |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fGetPesos(aRotas, cPictPeso)
	Local nPosRota := 0
	Local aArea    := GetArea()
	Local nPeso    := 0
	Local cRota    := ""

	For nPosRota := 1 to Len(aRotas)
		nPeso := 0
		cRota := aRotas[nPosRota,3]
		TRBPED->(DbGoTop())
		While !TRBPED->(Eof())
			If TRBPED->PED_ROTA == cRota
				nPeso += TRBPED->PED_PESO
			EndIf
			aRotas[nPosRota,6] := Transform(nPeso,cPictPeso)
			TRBPED->(DbSkip())
		EndDo
	Next nPosRota
	RestArea(aArea)
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FGETBLQ   | Autor | Felipe Zago Zechini   | Data | 31.03.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Retorna o bloqueio do pedido para a tela de formação de     |
|          | cargas. Caso o pedido seja do tipo A (antecipado), o pedido |
|          | será listado na tela como não bloqueado, mesmo que o cliente|
|          | pelo financeiro.                                            |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fGetBlq(cPedido)
	Local aArea    := GetArea()
	Local cCliente := Posicione()
	Local cRet     := ""

	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek(xFilial("SC5")+cPedido)
		cTipo    := SC5->C5_YSUBTP
		cCliente := SC5->C5_CLIENTE + SC5->C5_LOJACLI
		cStatus  := Posicione("SA1",1,xFilial("SA1")+cCliente,"A1_YBLOQ")
	EndIf
	If cTipo == 'A' .And. cStatus == 'B'
		cRet := 'L'
	Else
		cRet := cStatus
	EndIf
	RestArea(aArea)
Return cRet

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |FMARKPED  | Autor | Felipe Zago Zechini   | Data | 09.05.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Procede a marcação dos pedidos que possuem saldo positivo   |
|          | em estoque, de forma automática, antes da apresentação da   |
|          | tela de carregamento ao usuário, como forma de sugestão da  |
|          | montagem de carga.                                          |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fMarkPed(nEscolha,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,oEnable,oDisable,oMarked,oNoMarked,cMarca,lAllMark)
	Local nVol      := 0,i
	Local nPosCarga := Ascan(aArrayCarga,{|x| x[CARGA_ENABLE] == .T.})

	ProcRegua(TRBPED->(LastRec()))
	For i:= 1 to Len(aPedidos)
		TRBPED->(DbSetOrder(6))
		If TRBPED->(DbSeek(aPedidos[i]))
			RecLock("TRBPED",.F.)
			TRBPED->PED_ESTOQ := "S"
			nVol += TRBPED->PED_VOLUM
			TRBPED->(MsUnlock())
			U_OmsTroca(4,cHrStart,aArrayCarga,aArrayRota,aArrayZona,aArraySetor,aArrayMan,aLock,@oEnable,@oDisable,@oMarked,@oNoMarked,cMarca,.F.)
		EndIf
		IncProc()
	Next i

	//aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(nVol,PesqPict("SB1","B1_YM3"))
	aArrayCarga[nPosCarga,CARGA_VOLUM] := Transform(nVol,PesqPict("DAK","DAK_CAPVOL"))
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |fPEDTELA  | Autor | Alexandre N. Panetto  | Data | 17.04.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Processo para dedução dos saldos dos produtos com pedidos   |
|          | marcados na tela de outro usuário.                          |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fPedTela(wcUsuario)
	cQryPedTela := "SELECT PRODUTO, SUM(QUANT) AS QUANT  "+cFim
	cQryPedTela += " FROM MARK_TELA "+cFim
	cQryPedTela += " WHERE LENGTH(RTRIM(PRODUTO)) IN  (7,13) "+cFim
	cQryPedTela += " GROUP BY PRODUTO "+cFim

	If ChkFile("QRYPEDTELA")
		QRYPEDTELA->(DbCloseArea())
	EndIf

	TcQuery cQryPedTela New Alias "QRYPEDTELA"

	DbSelectArea("QRYPEDTELA")
	QRYPEDTELA->(DbGoTop())

	While !QRYPEDTELA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(1)
		If DbSeek(QRYPEDTELA->PRODUTO)
			If Len(AllTrim(QRYPEDTELA->PRODUTO)) == 7
				RecLock("TRBSALDOS",.F.)
				TRBSALDOS->SALDO_PROD -= QRYPEDTELA->QUANT
				TRBSALDOS->(MsUnlock())
			EndIf
		EndIf
		QRYPEDTELA->(DbSkip())
	EndDo

	DbSelectArea("QRYPEDTELA")
	QRYPEDTELA->(DbGoTop())
	While !QRYPEDTELA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(2) //Indice do campo COD_PI
		If DbSeek(QRYPEDTELA->PRODUTO)
			If Len(AllTrim(QRYPEDTELA->PRODUTO)) == 13   //TRATAMENTO PARA RESERVAS DE PI
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYPEDTELA->PRODUTO
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYPEDTELA->QUANT * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYPEDTELA->(DbSkip())
	EndDo
	QRYPEDTELA->(DbCloseArea())

	cQryPedTela := "SELECT PRODUTO, SUM(QUANT) AS QUANT "+cFim
	cQryPedTela += " FROM MARK_TELA "+cFim
	cQryPedTela += " WHERE LENGTH(RTRIM(PRODUTO)) IN  (7,13) "+cFim
	cQryPedTela += " GROUP BY PRODUTO "+cFim

	TcQuery cQryPedTela New Alias "QRYPEDTELA"

	DbSelectArea("QRYPEDTELA")
	TRBSALDOS->(DbGoTop())
	While !QRYPEDTELA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(1)
		If DbSeek(QRYPEDTELA->PRODUTO)
			If Len(AllTrim(QRYPEDTELA->PRODUTO)) == 7
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PA == QRYPEDTELA->PRODUTO
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYPEDTELA->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYPEDTELA->(DbSkip())
	EndDo
	DbSelectArea("QRYPEDTELA")
	QRYPEDTELA->(DbGoTop())
	While !QRYPEDTELA->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(2) //Indice do campo COD_PI
		If DbSeek(QRYPEDTELA->PRODUTO)
			If Len(AllTrim(QRYPEDTELA->PRODUTO)) == 13   //TRATAMENTO PARA RESERVAS DE PI
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYPEDTELA->PRODUTO
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYPEDTELA->QUANT * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
			//////TRATAMENTO PARA RESERVAS DE PI ESPECÍFICO PARA BARRA DE CAMA
			If Len(AllTrim(QRYPEDTELA->PRODUTO)) == 7
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYPEDTELA->PRODUTO .AND. TRBSALDOS->COD_PA <> TRBSALDOS->COD_PI
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYPEDTELA->QUANT * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYPEDTELA->(DbSkip())
	EndDo
	QRYPEDTELA->(DbCloseArea())
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |fLPTela   | Autor | Alexandre N. Panetto  | Data | 17.04.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Função para limpar todos os dados da tabela MARK_TELA.      |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
User Function fLPTela
	Local cMsg
	cMsg := "Esta ação irá apagar todos os dados do saldo compartilhado entre os usuários. "+Chr(13)+;
	"É recomendado que esta ação seja executada somente no final do expediente "    +Chr(13)+;
	"ou no caso de travamento do sistema de algum usuário - neste caso, todos os "  +Chr(13)+;
	"outros usuários deverão sair do sistema para recriação do saldo. Confirma? "

	If MsgYesNo(cMsg,"Atenção")
		TcSqlExec("DELETE FROM MARK_TELA")
		TcSqlExec("COMMIT")
		//TcRefresh("MARK_TELA")
	EndIf
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |fMarkItem | Autor | Alexandre N. Panetto  | Data | 10.05.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Função para incluir ou excluir uma linha da MARK_TELA, no   |
|          | momento em que um usuario marca um item de pedido.          |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fMarkItem(wcUsuario,cMarca)
	Local lInclui := (TRBPED->PED_MARCA == cMarca)
	If lInclui
		fInclui(wcUsuario)
	Else
		fExclui(wcUsuario)
	Endif
Return

Static Function fInclui(wcUsuario)
	Local cSql
	Local cFilPed := TRBPED->PED_FILORI
	Local cPedido := TRBPED->PED_PEDIDO
	Local cItem   := TRBPED->PED_ITEM
	Local cProd   := TRBPED->PED_CODPRO
	Local cOrigem := TRBPED->PED_BLOQ
	Local nQtd    := Str(Iif(TRBPED->PED_BLOQ == 'B',TRBPED->PED_QTDPED, TRBPED->PED_QTDLIB))
	////Local nQtd    := Str(Iif(cOrigem == 'B',TRBPED->PED_QTDPED, TRBPED->PED_QTDLIB))
	//If TRBPED->PED_BLOQ == 'B'
	//	cSql := "INSERT INTO MARK_TELA"
	//	cSql += " VALUES ('"+cFilPed  +"','"+;
	//	cPedido  +"','"+;
	//	cItem    +"','"+;
	//	cProd    +"',"+;
	//	nQtd     +",'"+;
	//	wcUsuario+"','"+;
	//	cOrigem  +"')"
	//	TcSqlExec(cSql)
	//	TcSqlExec("COMMIT")
	////TcRefresh("MARK_TELA")
	//EndIf
Return

Static Function fExclui(wcUsuario)
	Local cSql
	Local cFilPed := TRBPED->PED_FILORI
	Local cPedido := TRBPED->PED_PEDIDO
	Local cItem   := TRBPED->PED_ITEM
	Local cProd   := TRBPED->PED_CODPRO
	Local cOrigem := TRBPED->PED_BLOQ
	////Local nQtd    := Iif(cOrigem == 'B',TRBPED->PED_QTDPED, TRBPED->PED_QTDLIB)
	//Local nQtd    := Str(Iif(TRBPED->PED_BLOQ == 'B',TRBPED->PED_QTDPED, TRBPED->PED_QTDLIB))
	//
	//cSql := "DELETE MARK_TELA "
	//cSql += " WHERE FILIAL = '"+cFilPed +"'"+;
	//" AND PEDIDO   = '"+cPedido  +"'"+;
	//" AND ITEM     = '"+cItem    +"'"+;
	//" AND USUARIO  = '"+wcUsuario+"'"+;
	//" AND PRODUTO  = '"+cProd    +"'"
	//TcSqlExec(cSql)
	//TcSqlExec("COMMIT")
	////TcRefresh("MARK_TELA")
Return

/*+----------+----------+-------+-----------------------+------+-----------+
|Função    |fLmpExit  | Autor | Felipe Zago Zechini   | Data | 10.05.2006|
+----------+----------+-------+-----------------------+------+-----------+
|Descrição | Função para limpar os registros marcados pelo usuário no mo-|
|          | mento da geração da carga/abandono da rotina de carga.      |
+----------+-------------------------------------------------------------+
|Uso       | Movelar                                                     |
+----------+-------------------------------------------------------------+*/
Static Function fLmpExit(cMarca, wcUsuario)
	Local aArea := GetArea()

	DbSelectArea("TRBPED")
	TRBPED->(DbGoTop())
	While !TRBPED->(Eof())
		fExclui(wcUsuario)
		TRBPED->(DbSkip())
	EndDo

	RestArea(aArea)
Return

Static Function fGetUso(cProduto)
	Local cUso    := ""
	Local cQryUso := ""

	//TcRefresh("MARK_TELA")

	cQryUso := "SELECT COUNT(*) QTD FROM MARK_TELA "
	cQryUso += "WHERE PRODUTO = '"+cProduto+"'"

	If ChkFile("QRYUSO")
		QRYUSO->(DbCloseArea())
	EndIf

	TcQuery cQryUso New Alias "QRYUSO"

	QRYUSO->(DbGoTop())
	cUso := iif(QRYUSO->QTD > 0, "S","N")
	QRYUSO->(DbCloseArea())
Return cUso

Static Function fRefresh
	Local aArea := GetArea("TRBPED")
	Local cUso  := ""

	TRBPED->(DbGoTop())
	While !Eof()
		cUso := fGetUso(TRBPED->PED_CODPRO)
		If TRBPED->PED_USO <> cUso
			RecLock("TRBPED",.F.)
			TRBPED->PED_USO := cUso
			TRBPED->(MsUnlock())
		EndIf
		TRBPED->(DbSkip())
	EndDo
	RestArea(aArea)
	oMark:oBrowse:Refresh()
Return

/*+-----------+----------+-------+--------------------+------+-------------+
| Programa  |FSELUSR   |Autor  |Felipe Zago         | Data |  15/05/06   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     |Selecao dos usuarios a serem limpos da base de marcacao     |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | AP7, Movelar                                               |
+-----------+------------------------------------------------------------+*/
User Function fSelUsr
	Local   cQry    := ""
	Local   aArea   := GetArea()
	Local   cMark   := GetMark()
	Local   oMark
	Private aCampos := {}
	Private aCpoBrw := {}

	cQry := "SELECT DISTINCT(USUARIO) FROM MARK_TELA"
	TCQuery cQry New Alias "QRYMRK"

	aAdd(aCampos,{"MARCA"  ,"C",04,0})
	aAdd(aCampos,{"USUARIO","C",15,0})

	cAlias  := "ARQTRA"
	cArqTRB := CriaTrab(aCampos,.T.)
	dbUseArea(.T.,,cArqTRB,cAlias,.F.)

	Aadd(aCpoBrw,{"MARCA"  ,,""})
	Aadd(aCpoBrw,{"USUARIO",,"Usuario"})

	DbSelectArea("QRYMRK")
	QRYMRK->(DbGoTop())
	While !Eof()
		RecLock("ARQTRA",.T.)
		ARQTRA->USUARIO := QRYMRK->USUARIO
		ARQTRA->(MsUnlock())
		DbSkip()
	EndDo

	DbSelectArea("ARQTRA")
	DbGotop()

	DEFINE MSDIALOG oDlg TITLE "Selecionar usuário(s)" FROM 000,000 TO 300,350 PIXEL
	oMark := MsSelect():New("ARQTRA","MARCA","",aCpoBrw,.F.,@cMark,{015,005,145,170})
	oMark:bAval := {|| fMarcar(@cMark, @oMark),Alert(ARQTRA->MARCA)}
	oMark:oBrowse:lhasMark    := .T.

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg, {|| fDeleta(),oDlg:End() }, {|| oDlg:End()},,)

	QRYMRK->(dbCloseArea())
	//ARQTRA->(dbCloseArea())
	DbSelectArea("ARQTRA")
	DbCloseArea()
	//U_DelTrab(cArqTRB)
	RestArea(aArea)
Return

Static Function fDeleta(cMark)
	Local cQry := ""
	ARQTRA->(DbGoTop())
	While !ARQTRA->(Eof())
		//If ARQTRA->MARCA == cMark
		//	TcSqlExec("DELETE MARK_TELA WHERE USUARIO = '"+ARQTRA->USUARIO+"'")
		//	TcSqlExec("COMMIT")
		//EndIf
		ARQTRA->(DbSkip())
	EndDo
Return

Static Function fMarcar(cMark,oMark)
	RecLock("ARQTRA",.F.)
	If ARQTRA->MARCA != cMark
		ARQTRA->MARCA := cMark
	Else
		ARQTRA->MARCA := Space(4)
	EndIf
	ARQTRA->(MsUnlock())
	oMark:oBrowse:Refresh()
Return

/*+-----------+----------+-------+--------------------+------+-------------+
| Programa  | FPEDLIB  |Autor  |Felipe Zago         | Data |  14/06/06   |
+-----------+----------+-------+--------------------+------+-------------+
| Desc.     | Dedução da estrutura do produto (pedidos liberados)        |
|           |                                                            |
+-----------+------------------------------------------------------------+
| Uso       | Protheus 8, Movelar                                        |
+-----------+------------------------------------------------------------+*/
Static Function fPedLib(wcUsuario)
	Local cQryPedLib := ""
	Local cFim      := Chr(13)

	// Deduzindo os saldos dos produtos com 10 dígitos.
	cQryPedLib := ""
	cQryPedLib += " SELECT G12.G1_COMP  AS COD_PA, SUM(C9.C9_QTDLIB)*G12.G1_QUANT AS QUANT_CARGA "
	cQryPedLib += "   FROM SC9010 C9 INNER JOIN " + RetSqlName("SG1") + " G12 "
	cQryPedLib += "                  ON  G12.G1_COD     = C9.C9_PRODUTO "
	cQryPedLib += "                  AND G12.D_E_L_E_T_ = ' ' "
	cQryPedLib += "                  INNER JOIN SB1010 SB1 "
	cQryPedLib += "                  ON  SB1.B1_COD     = C9.C9_PRODUTO "
	cQryPedLib += "                  AND SB1.D_E_L_E_T_ = ' ' "
	cQryPedLib += "  WHERE C9.D_E_L_E_T_  = ' ' "
	cQryPedLib += "    AND C9.C9_CARGA    = ' ' "
	cQryPedLib += "    AND C9.C9_NFISCAL  = ' ' "
	cQryPedLib += "    AND LENGTH(RTRIM(C9.C9_PRODUTO)) = 10 "
	cQryPedLib += "  GROUP BY G12.G1_COMP, G12.G1_QUANT "
	cQryPedLib += "  ORDER BY G12.G1_COMP "

	TcQuery cQryPedLib New Alias "QRYPEDLIB"

	DbSelectArea("QRYPEDLIB")
	TRBSALDOS->(DbGoTop())
	While !QRYPEDLIB->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(1)
		If DbSeek(QRYPEDLIB->COD_PA)
			If Len(AllTrim(QRYPEDLIB->COD_PA)) == 7
				RecLock("TRBSALDOS",.F.)
				TRBSALDOS->SALDO_PROD -= QRYPEDLIB->QUANT_CARGA
				TRBSALDOS->(MsUnlock())
			EndIf
		EndIf
		QRYPEDLIB->(DbSkip())
	EndDo

	DbSelectArea("QRYPEDLIB")
	QRYPEDLIB->(DbGoTop())
	While !QRYPEDLIB->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(2) //Indice do campo COD_PI
		If DbSeek(QRYPEDLIB->COD_PA)
			If Len(AllTrim(QRYPEDLIB->COD_PA)) == 13   //TRATAMENTO PARA CARGAS DE PA - INCLUÍDO 24/03/2006 - ALEXANDRE N. PANETTO
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYPEDLIB->COD_PA
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYPEDLIB->QUANT_CARGA * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYPEDLIB->(DbSkip())
	EndDo
	QRYPEDLIB->(DbCloseArea())

	// Deduzindo os saldos dos produtos com 7 e 13 dígitos.
	cQryPedLib := ""
	cQryPedLib += " SELECT TAB.PRODUTO AS COD_PA, ISNULL(SUM(SC9.C9_QTDLIB), 0) AS QUANT_CARGA "+cFim
	cQryPedLib += "  FROM (SELECT TAB.PRODUTO "+cFim
	cQryPedLib += "            FROM (SELECT DISTINCT (PRODUTO) AS PRODUTO "+cFim
	cQryPedLib += "                    FROM PED_TELA_"+wcUsuario+") TAB) TAB "+cFim
	cQryPedLib += "        INNER JOIN "+cSC9+" SC9 "+cFim
	cQryPedLib += "          ON  SC9.C9_PRODUTO = TAB.PRODUTO "+cFim
	cQryPedLib += "          AND SC9.D_E_L_E_T_ = ' ' "+cFim
	cQryPedLib += "          AND SC9.C9_NFISCAL = ' ' "+cFim
	cQryPedLib += "          AND SC9.C9_CARGA   = ' ' "+cFim
	cQryPedLib += "          AND LENGTH(RTRIM(SC9.C9_PRODUTO)) IN (7,13) "+cFim
	cQryPedLib += "   GROUP BY TAB.PRODUTO  "+cFim
	cQryPedLib += "   ORDER BY COD_PA "

	TcQuery cQryPedLib New Alias "QRYPEDLIB"

	DbSelectArea("QRYPEDLIB")
	TRBSALDOS->(DbGoTop())
	While !QRYPEDLIB->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(1)
		If DbSeek(QRYPEDLIB->COD_PA)
			If Len(AllTrim(QRYPEDLIB->COD_PA)) == 7
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PA == QRYPEDLIB->COD_PA
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYPEDLIB->QUANT_CARGA
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYPEDLIB->(DbSkip())
	EndDo

	DbSelectArea("QRYPEDLIB")
	QRYPEDLIB->(DbGoTop())
	While !QRYPEDLIB->(Eof())
		DbSelectArea("TRBSALDOS")
		DbSetOrder(2) //Indice do campo COD_PI
		If DbSeek(QRYPEDLIB->COD_PA)
			If Len(AllTrim(QRYPEDLIB->COD_PA)) == 13 //TRATAMENTO PARA CARGAS DE PI - INCLUÍDO 24/03/2006 - ALEXANDRE N. PANETTO
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYPEDLIB->COD_PA
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYPEDLIB->QUANT_CARGA * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
			//TRATAMENTO PARA CARGAS DE PI - INCLUÍDO 10/04/2006 - ALEXANDRE N. PANETTO
			If Len(AllTrim(QRYPEDLIB->COD_PA)) == 7
				While !TRBSALDOS->(Eof()) .AND. TRBSALDOS->COD_PI == QRYPEDLIB->COD_PA .AND. TRBSALDOS->COD_PA <> TRBSALDOS->COD_PI
					RecLock("TRBSALDOS",.F.)
					TRBSALDOS->SALDO_PROD -= QRYPEDLIB->QUANT_CARGA * TRBSALDOS->QUANT
					TRBSALDOS->(MsUnlock())
					TRBSALDOS->(DbSkip())
				EndDo
			EndIf
		EndIf
		QRYPEDLIB->(DbSkip())
	EndDo
	QRYPEDLIB->(DbCloseArea())
Return

// Validação da digitação do pedido na tela
User Function CARGAOK
	Local aArea
	Local cPedido
	Local nSaldo

	If Upper(Alltrim(Funname())) <> 'MOVMONTC'
		Return .T.
	EndIf
	aArea  := TRBPED->(GetArea())
	nSaldo := GdFieldGet("C6_SLDALIB",n)
	If M->C6_QTDLIB > nSaldo
		Alert("Este item já foi liberado em sua totalidade.")
		Return .F.
	EndIf
Return .T.

/*+------------+----------+-------+--------------------+------+---------------+
|  Programa  |fVldVinc  |Autor  |FELIPE ZAGO ZECHINI | Data |  21/05/07     |
+------------+----------+-------+--------------------+------+---------------+
|  Parametros| ExpC1 - Marca usada no browse                                |
+------------+--------------------------------------------------------------+
|  Retorno   | ExpL1 - Mensagem com os pedidos sem mostruário enviado       |
+------------+--------------------------------------------------------------+
|  Desc.     | Essa funcao lista todos os pedidos que possuem vínculos de   |
|            | mostruário, que devem ser enviados antes do pedido normal.   |
|            | Verifica os pedidos marcados que possuem o campo C5_YVINCUL  |
|            | preenchido e olha nas notas de saída se já foi despachado    |
|            | o mostruário.                                                |
+------------+--------------------------------------------------------------+
|  Uso       | OMS MOVELAR                                                  |
+------------+--------------------------------------------------------------+*/
Static Function fVldVinc(cMarca)
	Local nPos     := 0,j,i
	Local aArea    := {}
	Local nRec     := 0
	Local cSD2     := RetSqlName("SD2")
	Local cSQL     := ""
	Local cEOL     := Chr(13)
	Local aPedido  := {}
	Local cPedido  := ""
	Local cProduto := ""
	Local cPedidos := ""
	Local aPendenc := {}
	Local aItens   := {}

	DbSelectArea("TRBPED")
	nRec := TRBPED->(RecNo())
	aArea:= GetArea()

	DbGoTop()

	While !TRBPED->(Eof())
		If TRBPED->PED_MARCA <> cMarca
			TRBPED->(DbSkip())
			Loop
		EndIf
		If !Empty(Posicione("SC5",1,xFilial("SC5")+TRBPED->PED_PEDIDO,"C5_YVINCUL"))
			If aScan(aPedido, {|x| x[1] == TRBPED->PED_PEDIDO }) == 0
				aAdd(aPedido, {TRBPED->PED_PEDIDO, SC5->C5_YVINCUL})
			EndIf
		EndIf
		TRBPED->(DbSkip())
	EndDo

	ProcRegua(len(aPedido))

	i := 1
	While i <= Len(aPedido)
		SC5->(DbSetOrder(1))
		If SC5->(DbSeek(xFilial("SC5")+aPedido[i,1]))
			/* VERIFICA SE O PEDIDO ESTÁ TOTALMENTE FATURADO */
			If !Empty(SC5->C5_NOTA) .Or. SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ)
				aDel(aPedido,i)
				aSize(aPedido, Len(aPedido)-1)
				Loop
			Else
				/* VERIFICA SE O PEDIDO ESTÁ PARCIALMENTE FATURADO E SE O RESTANTE ESTÁ NA CARGA */
				SC6->(DbSetOrder(1))
				SC6->(DbSeek(xFilial("SC6")+aPedido[i,2]))
				aItens := {}
				While (SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == aPedido[i,2])
					If SC6->(C6_BLQ <> 'R')
						If SC6->(C6_QTDVEN - C6_QTDENT) <> 0
							aAdd(aItens,{SC6->(C6_NUM+C6_ITEM), SC6->(C6_QTDVEN - C6_QTDENT)})
						EndIf
					EndIf
					SC6->(DbSkip())
				EndDo
				/* VERIFICA SE TODOS OS ITENS RESTANTES DO PEDIDO ESTÃO MARCADOS NA CARGA, COM O SALDO RESTANTE */
				j := 1
				While j <= Len(aItens)
					If Posicione("TRBPED",6,aItens[j,1],"PED_MARCA") == cMarca .And. TRBPED->PED_QTDLIB == aItens[j,2]
						aDel(aItens,j)
						aSize(aItens, Len(aItens)-1)
						Loop
					EndIf
					j++
				EndDo
				/* CASO TODOS OS ITENS RESTANTES ESTEJAM NA CARGA, ELIMINA DA LISTA */
				If Len(aItens) == 0
					aDel(aPedido,i)
					aSize(aPedido, Len(aPedido)-1)
					Loop
				Else
					For j := 1 to Len(aItens)
						aAdd(aPendenc, aItens[j,1])
					Next j
				EndIf
			EndIf
		EndIf
		IncProc()
		i++
	EndDo

	/* CASO EXISTAM ITENS PENDENTES, EXIBE A LISTA */
	If Len(aPedido) > 0
		For i := 1 to Len(aPedido)
			xCliente := Posicione("SC5",1,xFilial("SC5")+aPedido[i,1],"C5_CLIENTE")
			xCliente += SC5->C5_LOJACLI

			cPedidos += "Pedido: "+aPedido[i,1]+" - "+Alltrim(Posicione("SA1",1,xFilial("SA1")+xCliente,"A1_NOME"))+cEOL
			cPedidos += "Itens Vinculados (Pedido / Item ):"+cEOL
			cPedidos += "-----------------------------------------------------"+cEOL
			For j := 1 to Len(aPendenc)
				If aPedido[i,2] == Left(aPendenc[j],6)
					cPedidos += Left(aPendenc[j],6)+" / "+Substr(aPendenc[j],7)+cEOL
				EndIf
			Next j
			//aEval(aPendenc, {|aPed| iif(Left(aPed,6) == aPedido[i,2],cPedidos += Left(aPed,6)+" / "+Substr(aPed,7)+" / "+cEOL,Nil)})
		Next i
		MsgInfo("Existem restrições quanto a pedidos vinculados, conforme abaixo: "+Chr(13)+cPedidos+"OBS: O item pode estar marcado mas não liberado.")
		//Help(" ",1,"OMS_PED_VINCULADO1")
	Else
		MsgInfo("Não existe restrição quanto a pedidos vinculados.")
	EndIf

	RestArea(aArea)
	DbGoTo(nRec)
Return .T.

/*
wanisay
ptww@845
*/