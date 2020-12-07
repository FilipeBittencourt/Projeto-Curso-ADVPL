#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BIA932
@author Mileir 
@since 05/11/14
@version 1.0
@description Relatório de Conferência de Comissao p/ Titulo Recebido
@type function
/*/

User Function BIA932()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2       := "de acordo com os parametros informados pelo usuario."
Local cDesc3       := "Comissoes por titulos Recebidos"
Local cPict        := ""
Local titulo       := "Comissoes por titulos Recebidos - Por data da baixa"
Local nLin         := 80
Local Cabec1       := "Serie Representante                                                 Cliente                                                  Titulo Par   Baixa       Vr. Recebido      Vr. Base    %Comis    Valor Comissao"
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd 				 := {}
Private lEnd       := .F.
Private lAbortPrint:= .F.
Private CbTxt      := ""
Private limite     := 220
Private tamanho    := "G"
Private nomeprog   := "BIA932"
Private nTipo      := 15
Private aReturn    := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey   := 0
Private cPerg      := "BIA932"
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "BIA932"
Private ddta_ini, ddta_fin, ccli_ini, cloj_ini, ccli_fin, cloj_fin,cvend_ini, cvend_fin
Private cString	   := "SE5"
Private Enter 	   := CHR(13)+CHR(10)

dbSelectArea("SE5")
dbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif
pergunte(cPerg,.F.)
ddta_ini  := mv_par01
ddta_fin  := mv_par02
ccli_ini  := mv_par03
cloj_ini  := mv_par04
ccli_fin  := mv_par05
cloj_fin  := mv_par06
cvend_ini := mv_par07
cvend_fin := mv_par08

SetDefault(aReturn,cString)


If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)


Private ntotrec:=0,ntotcom:=0,ngerrec:=0,ngercom:=0,ntotbas:=0,ngerbas:=0
Private ntotrec1:=0,ntotcom1:=0,ntotbas1:=0
Private ntotrec2:=0,ntotcom2:=0,ntotbas2:=0
Private cSQL, cRecebido,nComisAnt:=0, cVendAnt, cEstorno, cTitulo, _acampos, cVendedor
Private nrep1:=0, nrep2:=0, nrep3:=0

//Variavel para filtro da Marca
Private nMarca := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criar arquivo de trabalho³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {{"PREFIXO", "C", 03, 0} ,;
{"NUMERO"		, "C", 09,0},;
{"PARCELA"	, "C", 01,0},;
{"CLIENTE"	, "C", 06,0},;
{"LOJA"			, "C", 02,0},;
{"NOME"			, "C", 35,0},;
{"TIPO"			, "C", 03,0},;
{"VEND"			, "C", 06,0},;
{"VALOR"  	, "N", 12,2},;
{"ESTORNO"	, "N", 12,2},;
{"COMIS"		, "N", 12,2},;
{"PERCOMIS"	, "N", 06,2},; 
{"CFCOM"		, "C", 01,0},;
{"BASECALC"	, "N", 12,2},;
{"DATATIT"	, "D", 08,0},;
{"DATAEXT"	, "D", 08,0},;
{"DATACOM"	, "D", 08,0}}
cTitulo := CriaTrab(aCampos, .T.)
DbUseArea(.T.,,cTitulo,"cTitulo")
cInd1 := CriaTrab(NIL,.F.)
IndRegua("cTitulo",cInd1,"PREFIXO+NUMERO+PARCELA+CLIENTE+LOJA+TIPO+VEND",,,"Selecionando Registros...")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criar total Representante³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCampos := {{"CODIGO", "C", 06, 0} ,;
{"VALOR"			, "N", 12, 2},;
{"BASE"				, "N", 12, 2},;
{"COMISSAO"		, "N", 12, 2} }
cVendedor := CriaTrab(aCampos, .T.)
DbUseArea(.T.,,cVendedor,"cVendedor")
cInd2 := CriaTrab(NIL,.F.)
IndRegua("cVendedor",cInd2,"CODIGO",,,"Selecionando Registros...")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Processa({|| fRecebido() },"Recebidos")
Processa({|| fEstorno() },"Estornos")
Processa({|| fComissao() },"Comissao")

RptStatus({|| fImprime(Cabec1,Cabec2,Titulo,nLin) },Titulo)
//processa({|| fMILEIR() },"MILEIR")

cTitulo->(DbCloseArea())
cVendedor->(DbCloseArea())

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfRecebido ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fRecebido()
Local nTotReg := 0

//titulos recebidos
cSql := "SELECT * " + Enter
cSql += "FROM " + Enter
cSql += "(SELECT SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPO, SE5.E5_VALOR, SE5.E5_DATA, " + Enter
cSql += "		 VEND = CASE " + Enter
cSql += "			WHEN SE5.E5_TIPO = 'FT' THEN (SELECT MAX(E1_VEND1) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '01' AND E1_FATPREF = SE5.E5_PREFIXO AND E1_FATURA = SE5.E5_NUMERO AND D_E_L_E_T_ = '') " + Enter
cSql += "			ELSE (SELECT MAX(E1_VEND1) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '01' AND E1_PREFIXO = SE5.E5_PREFIXO AND E1_NUM = SE5.E5_NUMERO AND E1_PARCELA = SE5.E5_PARCELA AND E1_TIPO = SE5.E5_TIPO AND D_E_L_E_T_ = '') " + Enter
//cSql += "			ELSE '999999' " + Enter
cSql += "		 END " + Enter
cSql += "FROM "+RetSqlName("SE5")+" SE5"  + Enter
cSql += "WHERE SE5.E5_FILIAL= '"+XFilial("SE5")+"'"  + Enter
cSql += " 	AND SE5.E5_TIPODOC	NOT IN ('MT','CM','D2','J2','M2','C2','V2','TL','JR', 'DC')"  + Enter
cSql += "	AND SE5.E5_TIPO		NOT IN ('NCC', 'DEV','CH','RA','PA','')"  + Enter
cSql += "	AND SE5.E5_NATUREZ	IN ('1121', '1131')"  + Enter
If cempant == "01" 
	cSql += " AND SE5.E5_PREFIXO IN ('01','S1','S1F','S2','1','2','3','4','NDI','')"  + Enter
Else
	//cSql += " AND SE5.E5_PREFIXO = ''"  + Enter
	cSql += " AND SE5.E5_PREFIXO IN ('01','S1','','1','2','3','4','6','7','NDI') "  + Enter
EndIf
cSql += "	AND SE5.E5_RECPAG			= 'R'"  + Enter
cSql += "	AND SE5.E5_SITUACA		<> 'C'"  + Enter
cSql += "	AND SE5.E5_MOTBX			<> 'FAT'"  + Enter
cSql += "	AND SE5.E5_DATA BETWEEN	'"+DToS(dDta_ini)+"' AND '"+DToS(dDta_fin)+"'"  + Enter
cSql += "	AND SE5.E5_CLIFOR BETWEEN	'"+ccli_ini+"' AND '"+ccli_fin+"'"  + Enter
cSql += "	AND SE5.E5_LOJA BETWEEN	'"+cloj_ini+"' AND '"+cloj_fin+"'"  + Enter
cSql += "	AND SE5.D_E_L_E_T_		= '') AS REC " + Enter  
//cSql += "	AND SE5.E5_NUMERO = '026084') AS REC " + Enter  //RANISSES
cSql += "WHERE VEND >= '"+cvend_ini+"' AND VEND <= '"+cvend_fin+"' " + Enter
cSql += "ORDER BY E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, E5_LOJA, E5_TIPO"  + Enter
TCQUERY cSql NEW ALIAS "cRecebido"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gravar os titulos recebidos     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("cRecebido")
cRecebido->(DbGotop())
nTotReg := Contar("cRecebido","!Eof()")
Procregua(nTotReg)
cRecebido->(DbGotop())
Do while ! cRecebido->(EOF())
	IncProc()       
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+cRecebido->E5_PREFIXO+cRecebido->E5_NUMERO+cRecebido->E5_PARCELA+cRecebido->E5_TIPO+cRecebido->E5_CLIFOR+cRecebido->E5_LOJA)
	
	lInclui := .T.
	IF cTitulo->(dbSeek(cRecebido->E5_PREFIXO+cRecebido->E5_NUMERO+cRecebido->E5_PARCELA+cRecebido->E5_CLIFOR+cRecebido->E5_LOJA+cRecebido->E5_TIPO+cRecebido->VEND))
		lInclui := .F.
	Endif

	Reclock("cTitulo",lInclui)
	cTitulo->PREFIXO     := cRecebido->E5_PREFIXO
	cTitulo->NUMERO      := cRecebido->E5_NUMERO
	cTitulo->PARCELA     := cRecebido->E5_PARCELA
	cTitulo->CLIENTE     := cRecebido->E5_CLIFOR
	cTitulo->LOJA        := cRecebido->E5_LOJA
	cTitulo->NOME        := Posicione("SA1",1,XFILIAL("SA1")+cRecebido->E5_CLIFOR+cRecebido->E5_LOJA,"A1_NREDUZ")
	cTitulo->TIPO        := cRecebido->E5_TIPO
	cTitulo->DATATIT     := SToD(cRecebido->E5_DATA)
	cTitulo->VALOR       += cRecebido->E5_VALOR
	cTitulo->VEND		     := cRecebido->VEND
	cTitulo->CFCOM       := SE1->E1_YCFCOM		
	/*SE1->(DbSetOrder(1))
	If SE1->(DbSeek(xFilial("SE1")+cRecebido->E5_PREFIXO+cRecebido->E5_NUMERO+cRecebido->E5_PARCELA+cRecebido->E5_TIPO))  //Ranisses
		cTitulo->VEND := SE1->E1_VEND1
	EndIf	*/
	cTitulo->(MsUnlock())
	cRecebido->(DbSkip())
Enddo
cRecebido->(DbCloseArea())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfEstorno  ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fEstorno()
Local nTotReg := 0

//titulos estornados
cSql := "SELECT * " + Enter
cSql += "FROM " + Enter
cSql += "(SELECT SE5.E5_PREFIXO, SE5.E5_NUMERO, SE5.E5_PARCELA, SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_TIPO, " + Enter
cSql += " CASE WHEN SE5.E5_MOTBX = 'CEC' AND SE5.E5_VLJUROS > 0 THEN SE5.E5_VALOR - SE5.E5_VLJUROS ELSE SE5.E5_VALOR END AS E5_VALOR, SE5.E5_DATA, " + Enter
cSql += "		 VEND = CASE " + Enter
cSql += "			WHEN SE5.E5_TIPO = 'FT' THEN (SELECT MAX(E1_VEND1) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '01' AND E1_FATPREF = SE5.E5_PREFIXO AND E1_FATURA = SE5.E5_NUMERO AND D_E_L_E_T_ = '') " + Enter
cSql += "			WHEN SE5.E5_TIPO = 'NF' THEN (SELECT MAX(E1_VEND1) FROM "+RetSqlName("SE1")+" WHERE E1_FILIAL = '01' AND E1_PREFIXO = SE5.E5_PREFIXO AND E1_NUM = SE5.E5_NUMERO AND E1_PARCELA = SE5.E5_PARCELA AND E1_TIPO = SE5.E5_TIPO AND D_E_L_E_T_ = '') " + Enter
cSql += "			ELSE '999999' " + Enter
cSql += "		 END " + Enter
cSql += "FROM "+RetSqlName("SE5")+" SE5" + Enter
cSql += "WHERE SE5.E5_FILIAL= '"+XFilial("SE5")+"'" + Enter
cSql += "	AND SE5.E5_TIPODOC IN ('ES') " + Enter
cSql += "	AND SE5.E5_TIPO    NOT IN ('NCC', 'DEV','CH') " + Enter
If cempant == "01" 
	cSql += "	AND SE5.E5_PREFIXO IN ('01','S1','S1F','S2','1','2','3','4','NDI','')" + Enter
Else
	//cSql += "	AND SE5.E5_PREFIXO = ''" + Enter
	cSql += " AND SE5.E5_PREFIXO IN ('01','S1','','1','2','3','4','6','7','NDI') "  + Enter
EndIf
cSql += "	AND SE5.E5_RECPAG	= 'P' " + Enter
cSql += "	AND SE5.E5_SITUACA	<> 'C' " + Enter
cSql += "	AND SE5.E5_DATA 	>= '"+DToS(dDta_ini)+"'" + Enter
cSql += "	AND SE5.E5_CLIFOR	BETWEEN '"+ccli_ini+"' AND '"+ccli_fin+"'" + Enter
cSql += "	AND SE5.E5_LOJA 	BETWEEN '"+cloj_ini+"' AND '"+cloj_fin+"'" + Enter  
cSql += "	AND SE5.D_E_L_E_T_	= '' ) AS EST " + Enter
//cSql += "	AND SE5.E5_NUMERO = '026084' ) AS EST " + Enter //RANISSES
cSql += "WHERE VEND >= '"+cvend_ini+"' AND VEND <= '"+cvend_fin+"' " + Enter
cSql += "ORDER BY E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_CLIFOR, E5_LOJA, E5_TIPO " + Enter 

TCQUERY cSql NEW ALIAS "cEstorno"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³gravar os valores com estornados   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("cEstorno")
cEstorno->(DbGotop())
nTotReg := Contar("cEstorno","!Eof()")
Procregua(nTotReg)
cEstorno->(DbGotop())
Do while ! cEstorno->(EOF())
    Incproc()               
    
    DbSelectArea("SE1")
    DbSetOrder(1)
    DbSeek(xFilial("SE1")+cEstorno->E5_PREFIXO+cEstorno->E5_NUMERO+cEstorno->E5_PARCELA+cEstorno->E5_TIPO+cEstorno->E5_CLIFOR+cEstorno->E5_LOJA)
    
	IF cTitulo->(dbSeek(cEstorno->E5_PREFIXO+cEstorno->E5_NUMERO+cEstorno->E5_PARCELA+cEstorno->E5_CLIFOR+cEstorno->E5_LOJA+cEstorno->E5_TIPO+cEstorno->VEND))
		Reclock("cTitulo",.F.)
		cTitulo->PREFIXO     := cEstorno->E5_PREFIXO
		cTitulo->NUMERO      := cEstorno->E5_NUMERO
		cTitulo->PARCELA     := cEstorno->E5_PARCELA
		cTitulo->CLIENTE     := cEstorno->E5_CLIFOR
		cTitulo->LOJA        := cEstorno->E5_LOJA
   	cTitulo->NOME        := Posicione("SA1",1,XFILIAL("SA1")+cEstorno->E5_CLIFOR+cEstorno->E5_LOJA,"A1_NREDUZ")
		cTitulo->TIPO        := cEstorno->E5_TIPO
		cTitulo->DATAEXT     := SToD(cEstorno->E5_DATA)
		cTitulo->ESTORNO     += cEstorno->E5_VALOR                
		cTitulo->VEND 		   := cEstorno->VEND
  	cTitulo->CFCOM       := SE1->E1_YCFCOM
		/*SE1->(DbSetOrder(1))
		If SE1->(DbSeek(xFilial("SE1")+cEstorno->E5_PREFIXO+cEstorno->E5_NUMERO+cEstorno->E5_PARCELA+cEstorno->E5_TIPO))
			cTitulo->VEND := SE1->E1_VEND1
		EndIf*/	
		cTitulo->(MsUnlock())
	Endif
	cEstorno->(DbSkip())
Enddo
cEstorno->(DbCloseArea())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfcomissao ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fComissao()
Local nTotReg := 0

//titulos recebidos com comissao
cSql := "SELECT SE3.E3_PREFIXO, SE3.E3_NUM, SE3.E3_PARCELA, SE3.E3_CODCLI, SE3.E3_LOJA, SE3.E3_TIPO, SE3.E3_EMISSAO, SE3.E3_VEND, SE3.E3_PORC, SE3.E3_COMIS, SE3.E3_BASE " + Enter  
cSql += "FROM "+RetSqlName("SE3")+" SE3 " + Enter  
cSql += "WHERE	SE3.E3_FILIAL= '"+XFilial("SE3")+"' " + Enter  
If cempant == "01"
	cSql += "	AND SE3.E3_PREFIXO IN ('01','S1','S1F','S2','1','2','3','4','NDI') " + Enter  
Else
	//cSql += "	AND SE3.E3_PREFIXO = '' " + Enter  
	cSql += " AND SE3.E3_PREFIXO IN ('01','S1','','1','2','3','4','6','7','NDI') "  + Enter
EndIf
cSql += "	AND SE3.E3_TIPO NOT IN ('NCC', 'DEV','CH') " + Enter  
cSql += "	AND SE3.E3_EMISSAO BETWEEN '"+DToS(dDta_ini)+"' AND '"+DToS(dDta_fin)+"' " + Enter  
cSql += "	AND SE3.E3_CODCLI BETWEEN '"+ccli_ini+"' AND '"+ccli_fin+"' " + Enter  
cSql += "	AND SE3.E3_LOJA BETWEEN '"+cloj_ini+"' AND '"+cloj_fin+"' " + Enter  
cSql += "	AND SE3.E3_VEND   BETWEEN '"+cvend_ini+"' AND '"+cvend_fin+"' " + Enter  
cSql += "	AND SE3.D_E_L_E_T_ = '' " + Enter  
//cSql += "	AND SE3.E3_NUM = '026084' " + Enter  //RANISSES
cSql += "ORDER BY SE3.E3_PREFIXO, SE3.E3_NUM, SE3.E3_PARCELA, SE3.E3_CODCLI, SE3.E3_LOJA, SE3.E3_TIPO " + Enter  

TCQUERY cSql NEW ALIAS "cComissao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³gravar os valores com comissoes    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("cComissao")
cComissao->(DbGotop())
nTotReg := Contar("cComissao","!Eof()")
Procregua(nTotReg)
cComissao->(DbGotop())
Do while ! cComissao->(EOF())
    IncProc()

	lInclui := .T.                                                    

	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1")+cComissao->E3_PREFIXO+cComissao->E3_NUM+cComissao->E3_PARCELA+cComissao->E3_TIPO+cComissao->E3_CODCLI+cComissao->E3_LOJA)

	If cTitulo->(dbSeek(cComissao->E3_PREFIXO+cComissao->E3_NUM+cComissao->E3_PARCELA+cComissao->E3_CODCLI+cComissao->E3_LOJA+cComissao->E3_TIPO+cComissao->E3_VEND))
		lInclui := .F.
	Endif

	Reclock("cTitulo",lInclui)
	cTitulo->PREFIXO     := cComissao->E3_PREFIXO
	cTitulo->NUMERO      := cComissao->E3_NUM
	cTitulo->PARCELA     := cComissao->E3_PARCELA
	cTitulo->CLIENTE     := cComissao->E3_CODCLI
	cTitulo->LOJA        := cComissao->E3_LOJA
	cTitulo->NOME        := Posicione("SA1",1,XFILIAL("SA1")+cComissao->E3_CODCLI+cComissao->E3_LOJA,"A1_NREDUZ")
	cTitulo->TIPO        := cComissao->E3_TIPO
	cTitulo->VEND        := cComissao->E3_VEND
	cTitulo->DATACOM     := SToD(cComissao->E3_EMISSAO)
	cTitulo->PERCOMIS    := cComissao->E3_PORC
	cTitulo->BASECALC    += cComissao->E3_BASE
	cTitulo->COMIS       += cComissao->E3_COMIS
	cTitulo->CFCOM       := SE1->E1_YCFCOM	
	cTitulo->(MsUnlock())
	cComissao->(DbSkip())
Enddo
cComissao->(DbCloseArea())
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºfImprime  ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function fImprime(Cabec1,Cabec2,Titulo,nLin)
Local _cCliImp,_cLojImp
// imprimir titulos
dbSelectArea("cTitulo")
cInd3 := CriaTrab(NIL,.F.)
IndRegua("cTitulo",cInd3,"PREFIXO+STR(PERCOMIS,6,2)+VEND+CLIENTE+LOJA",,,"Selecionando Registros...")

SetRegua(RecCount())
cTitulo->(DbGotop())
Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
While !cTitulo->(EOF())
	cPrfAnt := cTitulo->PREFIXO
	While !cTitulo->(EOF()) .and. cTitulo->PREFIXO == cPrfAnt
		nComisAnt := cTitulo->PERCOMIS
		While !cTitulo->(EOF()) .and. cTitulo->PREFIXO == cPrfAnt .and. cTitulo->PERCOMIS == nComisAnt
			SA3->(DbSetOrder(1))
			SA3->(DbSeek(xFilial("SA3")+cTitulo->VEND))
			cVendAnt := cTitulo->VEND
			While !cTitulo->(EOF()) .and. cTitulo->PREFIXO == cPrfAnt .and. cTitulo->PERCOMIS == nComisAnt .and. cTitulo->VEND == cVendAnt
				IncRegua()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica o cancelamento pelo usuario...                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lAbortPrint
					@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
					Exit
				Endif   
				
				//ALTERACAO PARA BUSCA NOME DO CLIENTE ORIGINAL QUANDO LM - FERNANDO - 06/08/2010
				_cCliImp	:= cTitulo->CLIENTE
			 	_cLojImp    := cTitulo->LOJA
				IF cTitulo->CLIENTE == '010064'
				    //busca primeiro item da nota
					SD2->(DbSetOrder(3))
					If SD2->(DbSeek(XFILIAL("SD2")+cTitulo->(NUMERO+PREFIXO+CLIENTE+LOJA)))
						//busca primeiro pedido SC5 para obter o cliente original
						SC5->(DbSetOrder(1))
						IF SC5->(DbSeek(XFilial("SC5")+SD2->D2_PEDIDO)) .AND. (!Empty(SC5->C5_YCLIORI))
						 	_cCliImp	:= SC5->C5_YCLIORI
						 	_cLojImp    := SC5->C5_YLOJORI
						ENDIF
					EndIf
				ENDIF
				
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1")+_cCliImp+_cLojImp))
				@ Prow()+1,1      Psay cTitulo->PREFIXO+"-"+cTitulo->TIPO
			//	@ Prow(),Pcol()+1 Psay Transform(cTitulo->PERCOMIS, "@e 99.9") + "%"
				@ Prow(),Pcol()+1 Psay cTitulo->VEND
				
				//Define a Marca
				If cEmpAnt == "07"
					If Alltrim(cTitulo->PREFIXO) $ "1"
						nMarca	:= "0101"
					ElseIf Alltrim(cTitulo->PREFIXO) $ "2"
						nMarca	:= "0501"
					ElseIf Alltrim(cTitulo->PREFIXO) $ "3"
						nMarca	:= "0599"
					ElseIf Alltrim(cTitulo->PREFIXO) $ "4"								
						nMarca	:= "1399"
					ElseIf Alltrim(cTitulo->PREFIXO) $ "6"								
						nMarca	:= "0199"
					ElseIf Alltrim(cTitulo->PREFIXO) $ "7"								
						nMarca	:= "1302"
					EndIf					
				Else
					nMarca	:= ""
				EndIf 
				
				//Busca informação na tabela de Rescisão
				Z78->(DbSetOrder(2))
				If Z78->(DbSeek(xFilial("Z78")+SA3->A3_COD+nMarca))
					@ Prow(),Pcol()+1 Psay SUBSTR(SA3->A3_NOME,1,30) + Z78->Z78_MARCA + " - RESC: " + DTOC(Z78->Z78_DTRESC)
				Else
					Z78->(DbSetOrder(1))	
					If Z78->(DbSeek(xFilial("Z78")+SA3->A3_COD))
						@ Prow(),Pcol()+1 Psay SUBSTR(SA3->A3_NOME,1,30) + Z78->Z78_MARCA + " - RESC: " + DTOC(Z78->Z78_DTRESC)					
					Else
						@ Prow(),Pcol()+1 Psay SUBSTR(SA3->A3_NOME,1,30) + SPACE(21)
					EndIf
				EndIf
				
				@ Prow(),Pcol()+1 Psay _cCliImp  //cTitulo->CLIENTE
				@ Prow(),Pcol()+1 Psay SUBSTR(SA1->A1_NOME,1,50)
				@ Prow(),Pcol()+1 Psay Alltrim(cTitulo->NUMERO)
				@ Prow(),Pcol()+1 Psay cTitulo->PARCELA //Iif(cTitulo->E1_SALDO=0,"B","A")
				@ Prow(),Pcol()+2 Psay cTitulo->DATATIT
				@ Prow(),Pcol()+1 Psay Transform((cTitulo->VALOR - cTitulo->ESTORNO),"@E 999,999,999.99") 	//valor recebido
				@ Prow(),Pcol()+2 Psay Transform(cTitulo->BASECALC,"@E 999,999,999.99") 											//BASE DE CALCULO DA COMISSAO
				@ Prow(),Pcol()+3 Psay Transform(cTitulo->PERCOMIS, "@E 99.99") +"%" 												//PERCENTUAL COMISSAO
				@ Prow(),Pcol()+2 Psay Transform(cTitulo->COMIS,"@E 999,999,999.99") 												//VALOR DA COMISSAO 
				IF cTitulo->CFCOM == 'S' 
					@ Prow(),Pcol()+2 Psay 'X'
				ENDIF
				ntotrec += (cTitulo->VALOR - cTitulo->ESTORNO)
				ntotcom += cTitulo->COMIS
				ntotbas += Iif(!Subst(cTitulo->VEND,1,1)$"1_2",cTitulo->BASECALC,0)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Atualizar o arquivo de representantes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DbSelectArea("cVendedor")
				DbSetOrder(1)
				If !cVendedor->(DbSeek(cTitulo->VEND))
					Reclock("cVendedor",.t.)
				Else
					Reclock("cVendedor",.f.)
				EndIf
				cVendedor->CODIGO   := cTitulo->VEND
				cVendedor->VALOR    += (cTitulo->VALOR - cTitulo->ESTORNO)
				cVendedor->BASE     += Iif(!Subst(cTitulo->VEND,1,1)$"1_2",cTitulo->BASECALC,0)
				cVendedor->COMISSAO += cTitulo->COMIS
				cVendedor->(MsUnlock())
				If Prow() >= 60
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				EndIf
				cTitulo->(DbSkip())
			EndDo //vendedor
			@ Prow()+1,70 Psay Repli("-",148)
			@ Prow()+1,70 Psay "Total do Representante "+SUBSTR(SA3->A3_NOME,1,30)
			@ Prow(),148  Psay Transform(ntotrec,"@E 999,999,999.99")
			@ Prow(),164  Psay Transform(ntotbas,"@E 999,999,999.99")
			@ Prow(),181  Psay Transform(Round((ntotcom / ntotbas * 100),1) , "@E 99.99") +"%"
			@ Prow(),189  Psay Transform(ntotcom,"@E 999,999,999.99")
			@ Prow()+1,0  Psay ""
			ngerrec+=ntotrec
			ngercom+=ntotcom
			ngerbas+=ntotbas
			ntotrec1+=ntotrec
			ntotcom1+=ntotcom
			ntotbas1+=ntotbas
			ntotrec2+=ntotrec
			ntotcom2+=ntotcom
			ntotbas2+=ntotbas
			ntotrec := 0
			ntotcom := 0
			ntotbas := 0
		EndDo //comissao
		@ Prow()+1,70 Psay Repli("-",148)
		@ Prow()+1,70 Psay "Total da comissao "+Transform(nComisAnt,"@e 99.99")+"%"
		@ Prow(),148  Psay Transform(ntotrec1,"@E 999,999,999.99")
		@ Prow(),164  Psay Transform(ntotbas1,"@E 999,999,999.99")
		@ Prow(),181  Psay Transform(Round((ntotcom1 / ntotbas1 * 100),1) , "@E 99.99") +"%"
		@ Prow(),189  Psay Transform(ntotcom1,"@E 999,999,999.99")
		@ Prow()+1,0  Psay ""
		ntotrec1 := 0
		ntotcom1 := 0
		ntotbas1 := 0
	EndDo //prefixo
	@ Prow()+1,70 Psay Repli("-",148)
	@ Prow()+1,70 Psay "Total da Serie "+cPrfAnt
	@ Prow(),162  Psay Transform(ntotrec2,"@E 999,999,999.99")
	@ Prow(),178  Psay Transform(ntotbas2,"@E 999,999,999.99")
	@ Prow(),195  Psay Transform(Round((ntotcom2 / ntotbas2 * 100),1) , "@E 99.99") +"%"
	@ Prow(),204  Psay Transform(ntotcom2,"@E 999,999,999.99")
	@ Prow()+1,0  Psay ""
	ntotrec2 := 0
	ntotcom2 := 0
	ntotbas2 := 0
EndDo
@ Prow()+1,84 Psay Repli("-",135)
@ Prow()+1,84 Psay "TOTAL GERAL "
@ Prow(),162  Psay Transform(ngerrec,"@E 999,999,999.99")
@ Prow(),178  Psay Transform(ngerbas,"@E 999,999,999.99")
@ Prow(),195  Psay Transform(Round((ngercom / ngerbas * 100),1) , "@E 99.99") +"%"
@ Prow(),204  Psay Transform(ngercom,"@E 999,999,999.99")
@ Prow()+1,84 Psay Repli("-",135)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprimir o total por representante                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("cVendedor")
DbGotop()
If 60 - Prow() < RecCount(cVendedor)
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
EndIf
@ Prow()+1,1 Psay Repli("-",220)
@ Prow()+1,1 Psay "Representante                                                        Vr. Recebido          Vr. Base    %Comis      Valor Comissao"
@ Prow()+1,1 Psay Repli("-",220)
Do while !cVendedor->(eof())
	SA3->(DbSetOrder(1))
	SA3->(DbSeek(xFilial("SA3")+cVendedor->CODIGO))
	@ Prow()+1,1      Psay SUBSTR(SA3->A3_NOME,1,30)
	@ Prow(),Pcol()+7 Psay Transform(cVendedor->VALOR,"@E 999,999,999.99")
	@ Prow(),Pcol()+4 Psay Transform(cVendedor->BASE,"@E 999,999,999.99")
	@ Prow(),Pcol()+3 Psay Transform(Round((cVendedor->COMISSAO / cVendedor->BASE * 100),1) , "@E 99.99") +"%"
	@ Prow(),Pcol()+6 Psay Transform(cVendedor->COMISSAO,"@E 999,999,999.99")
	nrep1+= cVendedor->VALOR
	nrep2+= cVendedor->BASE
	nrep3+= cVendedor->COMISSAO
	cVendedor->(Dbskip())
	If !eof() .and. prow() >= 60
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		@ Prow()+1,1 Psay Repli("-",220)
		@ Prow()+1,1 Psay "Representante                                                        Vr. Recebido          Vr. Base    %Comis      Valor Comissao"
		@ Prow()+1,1 Psay Repli("-",220)
	EndIf
EndDo
@ Prow()+1,1 Psay Repli("-",220)
@ Prow()+1,1      Psay "TOTAL"
@ Prow(),68       Psay Transform(nrep1,"@E 999,999,999.99")
@ Prow(),Pcol()+4 Psay Transform(nrep2,"@E 999,999,999.99")
@ Prow(),Pcol()+3 Psay Transform(Round((nrep3 / nrep2 * 100),1) , "@E 99.99") +"%"
@ Prow(),Pcol()+6 Psay Transform(nrep3,"@E 999,999,999.99")
@ Prow()+1,1 Psay Repli("-",220)
@ Prow()+1,1 Psay "*OBS.: Os totais das colunas 'Vl. Recebido' e 'Vl Base', para os SUPERVISORES, não serão considerados nos Totais e Sub-Totais do Relatório"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SET DEVICE TO SCREEN
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return

Static Function FMILEIR
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de conferencia por cliente."
Local cDesc3         := ""
Local cPict          := ""
Local titulo       := ""
Local nLin         := 80

Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 132
Private tamanho          := "M"
Private nomeprog         := "MILEIR" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 15
Private aReturn          := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "MILEIR" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "cTitulo"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  26/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

DbSelectArea("cTitulo")
cInd4 := CriaTrab(NIL,.F.)
IndRegua("cTitulo",cInd4,"NOME",,,"Selecionando Registros...")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SetRegua(RecCount())

dbGoTop()

While !EOF()
	NVALOR := 0
	ccod := ctitulo->CLIENTE
	ccli := ctitulo->NOME
	While !EOF() .AND. cTitulo->NOME == ccli
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nvalor += (ctitulo->VALOR-ctitulo->ESTORNO)
		
		dbSkip() // Avanca o ponteiro do registro no arquivo
	EndDo
	
	
	If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif
	
	@nLin,00 PSAY CCOD+" "+ccli+"    " + transform(nvalor,"@e 9999,9999,999.99")
	
	nLin := nLin + 1 // Avanca a linha de impressao
	
ENDDO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return