#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include "rwmake.ch"

USER FUNCTION IMP_SK1()

/*ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMP_SK1         บAutor  ณBRUNO MADALENO      บ Data ณ  28/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ROTINA PARA IMPORTAR OS TITULOS BAIXADOS DO FINANCEIRO PARA      บฑฑ
ฑฑบ          ณ A TABELA SK1 DO CALL CENTER                                      บฑฑ
ฑฑบ          ณ ESSA ROTINA E UMA COPIA DA ROTINA PADRAO DA MICROSIGA (Tk180Atu) บฑฑ
ฑฑบ          ณ QUE ESTA NO FONTE TMKA180.                                       บฑฑ
ฑฑบ          ณ A ALTERACAO REALIZADO FOI PARA PODERMOS IMPORTAR OS TITULOS      บฑฑ
ฑฑบ          ณ DO FINANCEIRO DE TODAS AS EMPRESAS PARA A BIANCOGRES             บฑฑ
ฑฑบ          ณ DIFERENCIANDO APENAS O CAMPO FILIAL ORIGEM                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP 7                                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ*/

Local aArea		:= GetArea()		            // Salva a area atual
Local lExiste	:= .F.						          // Flag para indicar se o usuario esta no cadastro de Operadores
Local cUltimo	:= SuperGetMv("MV_TMKSK1")	// Data e hora da ultima atualizacao
Local lRet		:= .F.						          // Retorno da funcao
Local cModo		:= ""						            // Modo de Acesso do SE1

Private cPerg	:= "TMK180"            		  // Pergunte para filtrar as filiais do SE1
Private oDgVencr
Private oButton1
Private oGet1
Private dGet1 := dDataBase
Private oGroup1

// Implementa็ใo para atender a OS Effetivo 0412-11
If Alltrim(FunName()) <> "TMKA271"
	If Pergunte(cPerg,.T.)
		Processa( {|| TK180Gera() }, "Avaliando Titulos para cobranca...") //"Avaliando Titulos para cobranca..."
	Endif
Else
	Pergunte(cPerg,.F.)
	
	If Empty(M->ACF_CLIENT)
		MsgINFO("Favor informar o c๓digo do cliente!!!")
		Return
	EndIf
	
	DEFINE MSDIALOG oDgVencr TITLE "Data Limite para verifica็ใo do Vencimento" FROM 000, 000  TO 100, 400 COLORS 0, 16777215 PIXEL
	@ 006, 009 GROUP oGroup1 TO 045, 190 OF oDgVencr COLOR 0, 16777215 PIXEL
	@ 013, 068 MSGET oGet1 VAR dGet1 SIZE 060, 012 OF oDgVencr COLORS 0, 16777215 PIXEL
	@ 029, 068 BUTTON oButton1 PROMPT "Confirma" SIZE 060, 012 OF oDgVencr ACTION oDgVencr:End() PIXEL
	ACTIVATE MSDIALOG oDgVencr
	
	Processa( {|| TK180Gera() }, "Avaliando Titulos para cobranca...") //"Avaliando Titulos para cobranca..."
EndIf

lRet := .T.
RestArea(aArea)

//_CRIA_WORK()

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk180Gera บAutor  ณArmando M. Tessaroliบ Data ณ  18/06/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina que busca no cadastro de Titulos a Receber todos os  บฑฑ
ฑฑบ          ณTitulos com saldo maior que zero e com a data de vencimento บฑฑ
ฑฑบ          ณmaior que a data do sistema e atualiza uma tabela de refe-  บฑฑ
ฑฑบ          ณrencias SK1, para pesquisas da Telecobranca.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP8                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAndrea F. ณ25/04/06 ณ 8.11ณ BOPS 97584 - Realizar alteracao no titulo  บฑฑ
ฑฑบ          ณ         ณ     ณ da tabela SK1 quando este foi alterado no  บฑฑ
ฑฑบ          ณ         ณ     ณ SE1.                                       บฑฑ
ฑฑบAndrea F. ณ25/04/06 ณ 8.11ณ BOPS 97567 - Melhorar a performance da ro- บฑฑ
ฑฑบ          ณ         ณ     ณ tina incluindo nova query.                 บฑฑ
ฑฑบHanna C.  ณ01/02/07 ณ 8.11ณ BOPS 118217 - Inclusao do LOG de inconsis- บฑฑ
ฑฑบ          ณ         ณ     ณ tencias do SK1                             บฑฑ
ฑฑบMichel W. ณ13/03/07 ณ 8.11ณ BOPS 120945 - Aplicacao de melhoria na que-บฑฑ
ฑฑบ          ณ         ณ     ณry de selecao de titulos para melhor perfor-บฑฑ
ฑฑบ          ณ         ณ     ณ-mance conforme orientacao do setor Tecnolo-บฑฑ
ฑฑบ          ณ         ณ     ณ-gia.                                       บฑฑ
ฑฑบMADALENO  ณ28/01/10 ณ 8 R4ณ ALTERADO POIS PRECISAVAMOS BUSCAR OS       บฑฑ
ฑฑบ          ณ         ณ     ณ TITULOS DE TODAS AS EMPRESAS JUNTAS PARA   บฑฑ
ฑฑบ          ณ         ณ     ณ ARMAZENAR NA TABELA SK1 DA EMPRESA BIANCO  บฑฑ
ฑฑบ          ณ         ณ     ณ                                            บฑฑ
ฑฑบ          ณ         ณ     ณ                                            บฑฑ
ฑฑศออออออออออฯอออออออออฯอออออฯออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Tk180Gera()

Local nY		:= 0									// Controle de loop
Local cFilOrig	:= ""									// Filial de Origem do titulo
Local cTipo		:= UPPER(GetNewPar("MV_TMKCOBR","")) 	// Contem os tipos de titulos que devem ser utilizados para cobranca
Local cSep		:= ""     								            // Separador dos tipos de titulo utilizado na select
//Local lOrigSK1	:= Tk180Check()							      // Indica se o campo de filial de origem (K1_FILORIG) esta presente no SIX e no SK1
Local aAlias	:= {"SE1"}								            // Alias Utilizados (ASE1 - Processar os titulos a serem incluidos  BSE1- Processar os titulos a serem alterados)
Local nTot		:= 0									                // Total de registros processados

#IFDEF TOP
	Local cQuery	:= ""  								              // Query de pesquisa dos titulos na base de dados
	Local nI		:= 0								                  // Controle de loop
	Local cAbat		:= ""								                // Tipo de titulo de abatimento
	Local lTk180Qry	:= FindFunction("U_TK180QRY") 		// Adiciona expressao na query
#ENDIF

If ( Type("lTk180Auto") == "U" )
	lTk180Auto := .F.
EndIf

DbSelectArea("SK1")
ProcRegua(RecCount())

DbSelectArea("SE1")
DbSetOrder(7)	// FILIAL+DTOS(E1_VENCREA)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtribui os separadores dos tipos de titulos a serem utilizados e os tipos de  titulos de abatimento ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty(cTipo)
	cSep:=	If("/" $ cTipo,"/",",")
Endif

#IFDEF TOP
	//Alias
	aAlias	:= {"ASE1","BSE1"}
	
	//Atribui os tipos de titulo de abatimento na variavel que sera utilizada no select
	For nI := 1 To Len(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM) Step 4
		cAbat := cAbat + "'" + SubStr(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM,nI,3) + "', "
	Next nI
	cAbat := SubStr(cAbat,1,Len(cAbat)-2)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuery 1 do SE1                                   ณ
	//ณ==============                                   ณ
	//ณVerifica apenas o que precisa incluir no SK1     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	// Tiago Rossini Coradini - 19/01/2016 - OS: 2826-15 - Clebes Jose - Filtro para nใo incluir titulos de pagamento antecipado (PR) na cobran็a do Call Center	
	cQuery := " SELECT E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VENCTO, E1_SITUACA, E1_VENCREA, E1_FILIAL, E1_SALDO, E1_CLIENTE, E1_LOJA, E1_NATUREZ, E1_PORTADO, EMPRESA "
	cQuery += " FROM ( "	
	
	//***************************************************
	// SLECIONANDO OS TITULOS DA BIANCOGRES
	//***************************************************
	cQuery	+=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
	"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
	"			SE1.E1_PORTADO, SE1.E1_PEDIDO, '01' AS EMPRESA " +;
	" FROM SE1010 SE1 " +;
	" WHERE "
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cQuery	+=	" SE1.E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	Endif
	If !Empty(cTipo)
		cQuery	+=	" SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " AND "
	Else
		cQuery	+=	" SE1.E1_TIPO NOT IN (" + cAbat + ") AND "
	Endif
	cQuery	+=	" SE1.E1_SALDO > 0 AND "
	// ...............: Tratamento efetuado em 06/12/11 :...............
	If Alltrim(FunName()) <> "TMKA271"
		cQuery	+=	" SE1.E1_VENCREA < '" + DtoS(dDataBase) + "' AND"
		cQuery	+=	" SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND "
	Else
		cQuery	+=	" SE1.E1_VENCREA < '" + dtos(dGet1) + "' AND"
		cQuery	+=	" SE1.E1_CLIENTE = '"+M->ACF_CLIENT+"' AND SE1.E1_LOJA = '"+M->ACF_LOJA+"' AND "
	EndIf
	// .................................................................
	cQuery 	+=	" SE1.D_E_L_E_T_ = '' " +;
	" AND NOT EXISTS " +;
	" 				(SELECT 1 "+;
	" 				FROM SK1010 SK1 " +;
	" 				WHERE K1_FILIAL = '" + xFilial("SK1") + "' AND " +;
	" 				SK1.K1_PREFIXO = SE1.E1_PREFIXO AND " +;
	" 				SK1.K1_NUM = SE1.E1_NUM AND " +;
	" 				SK1.K1_PARCELA = SE1.E1_PARCELA AND " +;
	" 				SK1.K1_TIPO =  SE1.E1_TIPO AND " +;
	" 				SK1.K1_FILORIG = '01' AND " +;
	" 				SK1.D_E_L_E_T_ = '') "
	cQuery	+=	" UNION ALL "
	
	//************************************************************
	// SLECIONANDO OS TITULOS DA INCESA
	//************************************************************
	cQuery	+=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
	"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
	"			SE1.E1_PORTADO, SE1.E1_PEDIDO, '05' AS EMPRESA  " +;
	" FROM SE1050 SE1 " +;
	" WHERE "
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cQuery	+=	" SE1.E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	Endif
	If !Empty(cTipo)
		cQuery	+=	" SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " AND "
	Else
		cQuery	+=	" SE1.E1_TIPO NOT IN (" + cAbat + ") AND "
	Endif
	cQuery	+=	" SE1.E1_SALDO > 0 AND "
	// ...............: Tratamento efetuado em 06/12/11 :...............
	If Alltrim(FunName()) <> "TMKA271"
		cQuery	+=	" SE1.E1_VENCREA < '" + DtoS(dDataBase) + "' AND"
		cQuery	+=	" SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND "
	Else
		cQuery	+=	" SE1.E1_VENCREA < '" + dtos(dGet1) + "' AND"
		cQuery	+=	" SE1.E1_CLIENTE = '"+M->ACF_CLIENT+"' AND SE1.E1_LOJA = '"+M->ACF_LOJA+"' AND "
	EndIf
	// .................................................................
	cQuery 	+=	" SE1.D_E_L_E_T_ = '' " +;
	" AND NOT EXISTS " +;
	" 				(SELECT 1 "+;
	" 				FROM SK1010 SK1 " +;
	" 				WHERE K1_FILIAL = '" + xFilial("SK1") + "' AND " +;
	" 				SK1.K1_PREFIXO = SE1.E1_PREFIXO AND " +;
	" 				SK1.K1_NUM = SE1.E1_NUM AND " +;
	" 				SK1.K1_PARCELA = SE1.E1_PARCELA AND " +;
	" 				SK1.K1_TIPO =  SE1.E1_TIPO AND " +;
	" 				SK1.K1_FILORIG = '05' AND " +;
	" 				SK1.D_E_L_E_T_ = '') "
	cQuery	+=	" UNION ALL "
	
	//************************************************************
	// SLECIONANDO OS TITULOS DA EMPRESA LM
	//************************************************************
	cQuery	+=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
	"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
	"			SE1.E1_PORTADO, SE1.E1_PEDIDO, '07' AS EMPRESA " +;
	" FROM SE1070 SE1 " +;
	" WHERE "
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cQuery	+=	" SE1.E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	Endif
	If !Empty(cTipo)
		cQuery	+=	" SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " AND "
	Else
		cQuery	+=	" SE1.E1_TIPO NOT IN (" + cAbat + ") AND "
	Endif
	cQuery	+=	" SE1.E1_SALDO > 0 AND "
	// ...............: Tratamento efetuado em 06/12/11 :...............
	If Alltrim(FunName()) <> "TMKA271"
		cQuery	+=	" SE1.E1_VENCREA < '" + DtoS(dDataBase) + "' AND"
		cQuery	+=	" SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND "
	Else
		cQuery	+=	" SE1.E1_VENCREA < '" + dtos(dGet1) + "' AND"
		cQuery	+=	" SE1.E1_CLIENTE = '"+M->ACF_CLIENT+"' AND SE1.E1_LOJA = '"+M->ACF_LOJA+"' AND "
	EndIf
	// .................................................................
	cQuery 	+=	" SE1.D_E_L_E_T_ = '' " +;
	" AND NOT EXISTS " +;
	" 				(SELECT 1 "+;
	" 				FROM SK1010 SK1 " +;
	" 				WHERE K1_FILIAL = '" + xFilial("SK1") + "' AND " +;
	" 				SK1.K1_PREFIXO = SE1.E1_PREFIXO AND " +;
	" 				SK1.K1_NUM = SE1.E1_NUM AND " +;
	" 				SK1.K1_PARCELA = SE1.E1_PARCELA AND " +;
	" 				SK1.K1_TIPO =  SE1.E1_TIPO AND " +;
	" 				SK1.K1_FILORIG = '07' AND " +;
	" 				SK1.D_E_L_E_T_ = '') "
	
	
	cQuery	+=	" UNION ALL "
	
	//************************************************************
	// SLECIONANDO OS TITULOS DA EMPRESA VITCER
	//************************************************************
	cQuery	+=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
	"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
	"			SE1.E1_PORTADO, SE1.E1_PEDIDO, '14' AS EMPRESA " +;
	" FROM SE1140 SE1 " +;
	" WHERE "
	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		cQuery	+=	" SE1.E1_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "
	Endif
	If !Empty(cTipo)
		cQuery	+=	" SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " AND "
	Else
		cQuery	+=	" SE1.E1_TIPO NOT IN (" + cAbat + ") AND "
	Endif
	cQuery	+=	" SE1.E1_SALDO > 0 AND "
	// ...............: Tratamento efetuado em 06/12/11 :...............
	If Alltrim(FunName()) <> "TMKA271"
		cQuery	+=	" SE1.E1_VENCREA < '" + DtoS(dDataBase) + "' AND"
		cQuery	+=	" SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND "
	Else
		cQuery	+=	" SE1.E1_VENCREA < '" + dtos(dGet1) + "' AND"
		cQuery	+=	" SE1.E1_CLIENTE = '"+M->ACF_CLIENT+"' AND SE1.E1_LOJA = '"+M->ACF_LOJA+"' AND "
	EndIf
	// .................................................................
	cQuery 	+=	" SE1.D_E_L_E_T_ = '' " +;
	" AND NOT EXISTS " +;
	" 				(SELECT 1 "+;
	" 				FROM SK1010 SK1 " +;
	" 				WHERE K1_FILIAL = '" + xFilial("SK1") + "' AND " +;
	" 				SK1.K1_PREFIXO = SE1.E1_PREFIXO AND " +;
	" 				SK1.K1_NUM = SE1.E1_NUM AND " +;
	" 				SK1.K1_PARCELA = SE1.E1_PARCELA AND " +;
	" 				SK1.K1_TIPO =  SE1.E1_TIPO AND " +;
	" 				SK1.K1_FILORIG = '14' AND " +;
	" 				SK1.D_E_L_E_T_ = '') "
	
	// Tiago Rossini Coradini - 19/01/2016 - OS: 2826-15 - Clebes Jose - Filtro para nใo incluir titulos de pagamento antecipado (PR) na cobran็a do Call Center			
	cQuery += " ) AS SE1 "
	cQuery += " WHERE NOT ( "
	cQuery += " SUBSTRING(E1_PREFIXO, 1, 2) = 'PR' "
	cQuery += " AND SUBSTRING(E1_PREFIXO, 3, 1) IN ('1', '2', '3', '4', '5', '6', '7', '8', '9') "
	cQuery += " AND E1_TIPO = 'BOL' "
	cQuery += " AND E1_PEDIDO <> '' "
	cQuery += " ) "
	
	cQuery	:= ChangeQuery(cQuery)
	MemoWrite("TMKA180AE1.SQL", cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), aAlias[1], .F., .T.)
	Conout(DTOC(dDatabase) + Time() + " TK180ATU 2- Termino da query para filtrar os titulos que serao incluidos no SK1")
	TCSetField(aAlias[1], "E1_VENCREA", "D")
	TCSetField(aAlias[1], "E1_VENCTO", "D")
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณQuery 2 do SE1                                   ณ
	//ณ==============                                   ณ
	//ณVerifica apenas as modificacoes entre o SE1 e SK1ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cQuery	:= ""
	
	//***************************************************
	// SLECIONANDO OS TITULOS DA BIANCOGRES
	//***************************************************
	cQuery	+=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
	"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
	"			SE1.E1_PORTADO, '01' AS EMPRESA  " +;
	" FROM SE1010 SE1, 	SK1010 SK1 " +;
	" WHERE SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' " +;
	" AND SE1.E1_PREFIXO 	= SK1.K1_PREFIXO " +;
	" AND SE1.E1_NUM 		= SK1.K1_NUM " +;
	" AND SE1.E1_PARCELA 	= SK1.K1_PARCELA " +;
	" AND SE1.E1_TIPO 		= SK1.K1_TIPO " +;
	" AND '01' 				= SK1.K1_FILORIG "
	If !Empty(cTipo)
		cQuery	+=	" AND SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " "
	Else
		cQuery	+=	" AND SE1.E1_TIPO NOT IN (" + cAbat + ") "
	Endif
	cQuery	+=	" AND SE1.E1_SALDO > 0 "
	// ...............: Tratamento efetuado em 06/12/11 :...............
	If Alltrim(FunName()) <> "TMKA271"
		cQuery	+=	" AND SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND "
	Else
		cQuery	+=	" AND SE1.E1_CLIENTE = '"+M->ACF_CLIENT+"' AND SE1.E1_LOJA = '"+M->ACF_LOJA+"' AND "
	EndIf
	// .................................................................
	IF lTk180Qry
		cQuery	+= U_TK180QRY()	+ " AND "
	Endif
	cQuery 	+=	"   SE1.D_E_L_E_T_ = '' " +;
	" 	AND SK1.D_E_L_E_T_ = '' " +;
	" 	AND (SK1.K1_VENCTO <> SE1.E1_VENCTO " +;
	" 	OR 	SK1.K1_VENCREA <> SE1.E1_VENCREA " +;
	" 	OR 	SK1.K1_NATUREZ <> SE1.E1_NATUREZ " +;
	" 	OR 	SK1.K1_PORTADO <> SE1.E1_PORTADO " +;
	" 	OR 	SK1.K1_SITUACA <> SE1.E1_SITUACA "
	If (SK1->(FieldPos("K1_SALDO"))  > 0)
		cQuery 	+=	" 	OR 	SK1.K1_SALDO <> SE1.E1_SALDO) "
	Else
		cQuery  += ") "
	Endif
	cQuery	+=	" UNION ALL "
	
	//***************************************************
	// SLECIONANDO OS TITULOS DA INCESA
	//***************************************************
	cQuery	+=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
	"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
	"			SE1.E1_PORTADO, '05' AS EMPRESA " +;
	" FROM SE1050 SE1, 	SK1010 SK1 " +;
	" WHERE SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' " +;
	" AND SE1.E1_PREFIXO 	= SK1.K1_PREFIXO " +;
	" AND SE1.E1_NUM 		= SK1.K1_NUM " +;
	" AND SE1.E1_PARCELA 	= SK1.K1_PARCELA " +;
	" AND SE1.E1_TIPO 		= SK1.K1_TIPO " +;
	" AND '05' 				= SK1.K1_FILORIG "
	If !Empty(cTipo)
		cQuery	+=	" AND SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " "
	Else
		cQuery	+=	" AND SE1.E1_TIPO NOT IN (" + cAbat + ") "
	Endif
	cQuery	+=	" AND SE1.E1_SALDO > 0 "
	// ...............: Tratamento efetuado em 06/12/11 :...............
	If Alltrim(FunName()) <> "TMKA271"
		cQuery	+=	" AND SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND "
	Else
		cQuery	+=	" AND SE1.E1_CLIENTE = '"+M->ACF_CLIENT+"' AND SE1.E1_LOJA = '"+M->ACF_LOJA+"' AND "
	EndIf
	// .................................................................
	IF lTk180Qry
		cQuery	+= U_TK180QRY()	+ " AND "
	Endif
	cQuery 	+=	"   SE1.D_E_L_E_T_ = '' " +;
	" 	AND SK1.D_E_L_E_T_ = '' " +;
	" 	AND (SK1.K1_VENCTO <> SE1.E1_VENCTO " +;
	" 	OR 	SK1.K1_VENCREA <> SE1.E1_VENCREA " +;
	" 	OR 	SK1.K1_NATUREZ <> SE1.E1_NATUREZ " +;
	" 	OR 	SK1.K1_PORTADO <> SE1.E1_PORTADO " +;
	" 	OR 	SK1.K1_SITUACA <> SE1.E1_SITUACA "
	If (SK1->(FieldPos("K1_SALDO"))  > 0)
		cQuery 	+=	" 	OR 	SK1.K1_SALDO <> SE1.E1_SALDO) "
	Else
		cQuery  += ") "
	Endif
	cQuery	+=	" UNION ALL "
	
	//***************************************************
	// SLECIONANDO OS TITULOS DA LM
	//***************************************************
	cQuery	+=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
	"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
	"			SE1.E1_PORTADO, '07' AS EMPRESA " +;
	" FROM SE1070 SE1, 	SK1010 SK1 " +;
	" WHERE SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' " +;
	" AND SE1.E1_PREFIXO 	= SK1.K1_PREFIXO " +;
	" AND SE1.E1_NUM 		= SK1.K1_NUM " +;
	" AND SE1.E1_PARCELA 	= SK1.K1_PARCELA " +;
	" AND SE1.E1_TIPO 		= SK1.K1_TIPO " +;
	" AND '07' 				= SK1.K1_FILORIG "
	If !Empty(cTipo)
		cQuery	+=	" AND SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " "
	Else
		cQuery	+=	" AND SE1.E1_TIPO NOT IN (" + cAbat + ") "
	Endif
	cQuery	+=	" AND SE1.E1_SALDO > 0 "
	// ...............: Tratamento efetuado em 06/12/11 :...............
	If Alltrim(FunName()) <> "TMKA271"
		cQuery	+=	" AND SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND "
	Else
		cQuery	+=	" AND SE1.E1_CLIENTE = '"+M->ACF_CLIENT+"' AND SE1.E1_LOJA = '"+M->ACF_LOJA+"' AND "
	EndIf
	// .................................................................
	IF lTk180Qry
		cQuery	+= U_TK180QRY()	+ " AND "
	Endif
	cQuery 	+=	"   SE1.D_E_L_E_T_ = '' " +;
	" 	AND SK1.D_E_L_E_T_ = '' " +;
	" 	AND (SK1.K1_VENCTO <> SE1.E1_VENCTO " +;
	" 	OR 	SK1.K1_VENCREA <> SE1.E1_VENCREA " +;
	" 	OR 	SK1.K1_NATUREZ <> SE1.E1_NATUREZ " +;
	" 	OR 	SK1.K1_PORTADO <> SE1.E1_PORTADO " +;
	" 	OR 	SK1.K1_SITUACA <> SE1.E1_SITUACA "
	If (SK1->(FieldPos("K1_SALDO"))  > 0)
		cQuery 	+=	" 	OR 	SK1.K1_SALDO <> SE1.E1_SALDO) "
	Else
		cQuery  += ") "
	Endif
		
	cQuery	+=	" UNION ALL "
	
	//***************************************************
	// SLECIONANDO OS TITULOS DA VITCER
	//***************************************************
	cQuery	+=	" SELECT	SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_VENCTO, SE1.E1_SITUACA, " +;
	"			SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_SALDO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NATUREZ, " +;
	"			SE1.E1_PORTADO, '14' AS EMPRESA " +;
	" FROM SE1140 SE1, 	SK1010 SK1 " +;
	" WHERE SK1.K1_FILIAL 	= '" + xFilial("SK1") + "' " +;
	" AND SE1.E1_PREFIXO 	= SK1.K1_PREFIXO " +;
	" AND SE1.E1_NUM 		= SK1.K1_NUM " +;
	" AND SE1.E1_PARCELA 	= SK1.K1_PARCELA " +;
	" AND SE1.E1_TIPO 		= SK1.K1_TIPO " +;
	" AND '14' 				= SK1.K1_FILORIG "
	If !Empty(cTipo)
		cQuery	+=	" AND SE1.E1_TIPO IN " + FormatIn(cTipo,cSep) + " "
	Else
		cQuery	+=	" AND SE1.E1_TIPO NOT IN (" + cAbat + ") "
	Endif
	cQuery	+=	" AND SE1.E1_SALDO > 0 "
	// ...............: Tratamento efetuado em 06/12/11 :...............
	If Alltrim(FunName()) <> "TMKA271"
		cQuery	+=	" AND SE1.E1_CLIENTE <> '      ' AND SE1.E1_LOJA <> '  ' AND "
	Else
		cQuery	+=	" AND SE1.E1_CLIENTE = '"+M->ACF_CLIENT+"' AND SE1.E1_LOJA = '"+M->ACF_LOJA+"' AND "
	EndIf
	// .................................................................
	IF lTk180Qry
		cQuery	+= U_TK180QRY()	+ " AND "
	Endif
	cQuery 	+=	"   SE1.D_E_L_E_T_ = '' " +;
	" 	AND SK1.D_E_L_E_T_ = '' " +;
	" 	AND (SK1.K1_VENCTO <> SE1.E1_VENCTO " +;
	" 	OR 	SK1.K1_VENCREA <> SE1.E1_VENCREA " +;
	" 	OR 	SK1.K1_NATUREZ <> SE1.E1_NATUREZ " +;
	" 	OR 	SK1.K1_PORTADO <> SE1.E1_PORTADO " +;
	" 	OR 	SK1.K1_SITUACA <> SE1.E1_SITUACA "
	If (SK1->(FieldPos("K1_SALDO"))  > 0)
		cQuery 	+=	" 	OR 	SK1.K1_SALDO <> SE1.E1_SALDO) "
	Else
		cQuery  += ") "
	Endif	
	
	cQuery	:= ChangeQuery(cQuery)
	MemoWrite("TMKA180BE1.SQL", cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), aAlias[2], .F., .T.)
	Conout(DTOC(dDatabase) + Time() + " TK180ATU 4- Termino da query para filtrar os titulos que serao alterados  no SK1")
	TCSetField(aAlias[2], "E1_VENCREA", "D")
	TCSetField(aAlias[2], "E1_VENCTO", "D")
	
#ELSE
	If !Empty(MV_PAR01)//Filial de Origem
		DbSeek(MV_PAR01,.T.)
	Else
		DbSeek(xFilial("SE1"),.T.)
	Endif
#ENDIF

For nY := 1 to Len(aAlias)
	Conout(DTOC(dDatabase) + Time() + " TK180ATU 5- Inicio do processamento para " + aAlias[nY] )
	nTot:= 0
	
	DbSelectArea(aAlias[nY])
	While (aAlias[nY])->(!Eof())
		nTot++
		cFilOrig	:= (aAlias[nY])->EMPRESA	//Filial de origem do titulo
		
		#IFNDEF TOP
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณConsidera apenas as filiais informadas no parametroณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If !((aAlias[nY])->E1_FILIAL >= MV_PAR01 .AND. (aAlias[nY])->E1_FILIAL <= MV_PAR02)
				DbSelectArea(aAlias[nY])
				(aAlias[nY])->(DbSkip())
				Loop
			Endif
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSepara o que e abatimento quando o parametro MV_TMKCOBR  que contem	ณ
			//ณos tipos de titulos a serem cobrados nao foi criado, caso contrario	ณ
			//ณconsidera apenas os tipos informados no parametro.                 	ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If Empty(cTipo)
				If (aAlias[nY])->E1_TIPO $ MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVABATIM
					DbSelectArea(aAlias[nY])
					(aAlias[nY])->(DbSkip())
					Loop
				Endif
			Else
				If !(Alltrim((aAlias[nY])->E1_TIPO) $ cTipo)
					DbSelectArea(aAlias[nY])
					(aAlias[nY])->(DbSkip())
					Loop
				Endif
			Endif
			
			// Valida o saldo restante do titulo
			If (aAlias[nY])->E1_SALDO <= 0
				DbSelectArea(aAlias[nY])
				(aAlias[nY])->(DbSkip())
				Loop
			Endif
			
			// Valida se o codigo do cliente e loja estao preenchidos
			If Empty((aAlias[nY])->E1_CLIENTE) .AND. Empty((aAlias[nY])->E1_LOJA)
				DbSelectArea(aAlias[nY])
				(aAlias[nY])->(DbSkip())
				Loop
			Endif
			
		#ENDIF
		
		//Valida se o cliente existe na base de dados
		Dbselectarea("SA1")
		DbsetOrder(1)
		If !DbSeek(xFilial("SA1")+ (aAlias[nY])->E1_CLIENTE + (aAlias[nY])->E1_LOJA)
			DbSelectArea(aAlias[nY])
			(aAlias[nY])->(DbSkip())
			Loop
		Endif
		
		// Somente incrementa a regua se nao for rotina automatica
		If !lTk180Auto
			IncProc()
		Endif
		
		DbSelectArea("SK1")
		DbSetOrder(1)
		If DbSeek(xFilial("SK1")+ (aAlias[nY])->E1_PREFIXO + (aAlias[nY])->E1_NUM + (aAlias[nY])->E1_PARCELA + (aAlias[nY])->E1_TIPO + cFilOrig)
			RecLock("SK1",.F.)
			REPLACE SK1->K1_VENCTO	WITH (aAlias[nY])->E1_VENCTO
			REPLACE SK1->K1_VENCREA	WITH (aAlias[nY])->E1_VENCREA
			REPLACE SK1->K1_NATUREZ	WITH (aAlias[nY])->E1_NATUREZ
			REPLACE SK1->K1_PORTADO	WITH (aAlias[nY])->E1_PORTADO
			REPLACE SK1->K1_SITUACA	WITH (aAlias[nY])->E1_SITUACA
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o campo existir, gravo O SALDO do titulo.          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If (SK1->(FieldPos("K1_SALDO"))  > 0)
				REPLACE SK1->K1_SALDO WITH (aAlias[nY])->E1_SALDO
			Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o campo existir, gravo O SALDO decrescente do titulo ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If (SK1->(FieldPos("K1_SALDEC"))  > 0)
				REPLACE SK1->K1_SALDEC WITH 100000 - (aAlias[nY])->E1_SALDO
			Endif
			
			MsUnLock()
		Else
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณQuando estiver em ambiente codebase, somente na inclusao tratar se o vencimento e menor que a databaseณ
			//ณem ambiente top a query ja realiza esse tratamento.                                                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			#IFNDEF TOP
				If (aAlias[nY])->E1_VENCREA > dDataBase
					DbSelectArea(aAlias[nY])
					(aAlias[nY])->(DbSkip())
					Loop
				Endif
			#ENDIF
			
			RecLock("SK1",.T.)
			REPLACE SK1->K1_FILIAL	WITH xFilial("SK1")
			REPLACE SK1->K1_PREFIXO	WITH (aAlias[nY])->E1_PREFIXO
			REPLACE SK1->K1_NUM		WITH (aAlias[nY])->E1_NUM
			REPLACE SK1->K1_PARCELA	WITH (aAlias[nY])->E1_PARCELA
			REPLACE SK1->K1_TIPO	WITH (aAlias[nY])->E1_TIPO
			REPLACE SK1->K1_VENCTO	WITH (aAlias[nY])->E1_VENCTO
			REPLACE SK1->K1_VENCREA	WITH (aAlias[nY])->E1_VENCREA
			REPLACE SK1->K1_CLIENTE	WITH (aAlias[nY])->E1_CLIENTE
			REPLACE SK1->K1_LOJA	WITH (aAlias[nY])->E1_LOJA
			REPLACE SK1->K1_NATUREZ	WITH (aAlias[nY])->E1_NATUREZ
			REPLACE SK1->K1_PORTADO	WITH (aAlias[nY])->E1_PORTADO
			REPLACE SK1->K1_SITUACA	WITH (aAlias[nY])->E1_SITUACA
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o campo existir, gravo a filial de origem do tituloณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			//If (SK1->(FieldPos("K1_FILORIG"))  > 0)
			REPLACE SK1->K1_FILORIG	WITH cFilOrig
			//Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o campo existir, gravo O SALDO do titulo.          ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If (SK1->(FieldPos("K1_SALDO"))  > 0)
				REPLACE SK1->K1_SALDO WITH (aAlias[nY])->E1_SALDO
			Endif
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณSe o campo existir, gravo O SALDO decrescente do titulo ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If (SK1->(FieldPos("K1_SALDEC"))  > 0)
				REPLACE SK1->K1_SALDEC WITH 100000 - (aAlias[nY])->E1_SALDO
			Endif
			
			MsUnLock()
		Endif
		
		DbSelectArea(aAlias[nY])
		DbSkip()
	End
	
	#IFDEF TOP
		DbSelectArea(aAlias[nY])
		DbCloseArea()
	#ENDIF
	
	Conout(DTOC(dDatabase) + Time() + " TK180ATU 6- Termino do processamento para " + aAlias[nY] + " Total de titulos processados = " + StrZero(nTot,10))
	
Next nY

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณAtualiza o parametro MV_TMKSK1 que indica quando foi feita a ultima atualizacaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectarea("SX6")
DbSetOrder(1)
If DbSeek(xFilial("SX6") + "MV_TMKSK1")
	RecLock("SX6",.F.)
	PutMv("MV_TMKSK1",DtoC(dDatabase)+"-"+Time())
	MsUnLock()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณValida a criacao LOG de inconsistencias do SK1, SOMENTE TOP ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
#IFDEF TOP
	If MV_PAR03 == 2
		Tk180VerK1()
	Endif
#ENDIF

Return

//******************************************************************************
//******************************************************************************
//*********************** BRUNO MADALENO ***************************************
//******************************************************************************
//******************************************************************************
//******************************************************************************

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ_CRIA_WORK ณ Autor ณ BRUNO MADALENO        ณ Data ณ 28/01/10   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDESCRICAO ณ CRIA E ENVIA O EMAIL PARA O FINANCEIRO COM OS TITULOS         ณฑฑ
ฑฑณ          ณ E OBSERVACAO QUE ESTAO EM ATRASO E DEVEM SER COBRADOS         ณฑฑ
ฑฑณ          ณ                                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ TELECOBRANCA                                                  ณฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
STATIC FUNCTION _CRIA_WORK()

PRIVATE ENTER := CHR(13)+CHR(10)
PRIVATE CSQL := ""
PRIVATE S_CLIENTE := ""
PRIVATE CHTML := ''
PRIVATE CHTML_1 := ''
PRIVATE CHTML_2 := ''
PRIVATE CHTML_3 := ''

// SELECIONANDO TODOS OS TITULOS
CSQL := "SELECT	E1_PORCJUR, K1_FILORIG, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, K1_CLIENTE, K1_LOJA, " + ENTER
CSQL += "		K1_VENCTO, E1_VALOR, E1_SALDO, E1_SALDO+E1_JUROS AS SALD_JUROS,  " + ENTER
CSQL += "		DATEDIFF(DAY,E1_VENCTO,GETDATE()) AS ATRASO  " + ENTER
CSQL += "FROM SK1010 SK1, SE1010 SE1 " + ENTER
CSQL += "WHERE	SK1.K1_FILIAL = '01' AND " + ENTER
CSQL += "		SE1.E1_FILIAL = '01' AND " + ENTER
CSQL += "		K1_FILORIG = '01' AND " + ENTER
CSQL += "		K1_SALDO <> '0' AND  E1_SALDO <> '0' AND " + ENTER
CSQL += "		K1_VENCTO >= '20090301' AND " + ENTER
CSQL += "		K1_VENCTO <= '"+DTOS(DDATABASE)+"' AND " + ENTER
CSQL += "		RTRIM(K1_PREFIXO)	= RTRIM(E1_PREFIXO) AND " + ENTER
CSQL += "		RTRIM(K1_NUM)		= RTRIM(E1_NUM) AND " + ENTER
CSQL += "		RTRIM(K1_PARCELA)	= RTRIM(E1_PARCELA) AND " + ENTER
CSQL += "		RTRIM(K1_TIPO)		= RTRIM(E1_TIPO) AND " + ENTER
CSQL += "		RTRIM(K1_CLIENTE)	= RTRIM(E1_CLIENTE) AND " + ENTER
CSQL += "		RTRIM(K1_LOJA)		= RTRIM(E1_LOJA) AND " + ENTER
CSQL += "		SK1.D_E_L_E_T_ = '' AND " + ENTER
CSQL += "		SE1.D_E_L_E_T_ = '' " + ENTER
CSQL += "UNION ALL " + ENTER
CSQL += "SELECT	E1_PORCJUR, K1_FILORIG, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, K1_CLIENTE, K1_LOJA, " + ENTER
CSQL += "		K1_VENCTO, E1_VALOR, E1_SALDO, E1_SALDO+E1_JUROS AS SALD_JUROS,  " + ENTER
CSQL += "		DATEDIFF(DAY,E1_VENCTO,GETDATE()) AS ATRASO  " + ENTER
CSQL += "FROM SK1010 SK1, SE1050 SE1 " + ENTER
CSQL += "WHERE	SK1.K1_FILIAL = '01' AND " + ENTER
CSQL += "		SE1.E1_FILIAL = '01' AND " + ENTER
CSQL += "		K1_FILORIG = '05' AND " + ENTER
CSQL += "		K1_SALDO <> '0' AND  E1_SALDO <> '0' AND " + ENTER
CSQL += "		K1_VENCTO >= '20090301' AND " + ENTER
CSQL += "		K1_VENCTO <= '"+DTOS(DDATABASE)+"' AND " + ENTER
CSQL += "		RTRIM(K1_PREFIXO)	= RTRIM(E1_PREFIXO) AND " + ENTER
CSQL += "		RTRIM(K1_NUM)		= RTRIM(E1_NUM) AND " + ENTER
CSQL += "		RTRIM(K1_PARCELA)	= RTRIM(E1_PARCELA) AND " + ENTER
CSQL += "		RTRIM(K1_TIPO)		= RTRIM(E1_TIPO) AND " + ENTER
CSQL += "		RTRIM(K1_CLIENTE)	= RTRIM(E1_CLIENTE) AND " + ENTER
CSQL += "		RTRIM(K1_LOJA)		= RTRIM(E1_LOJA) AND " + ENTER
CSQL += "		SK1.D_E_L_E_T_ = '' AND " + ENTER
CSQL += "		SE1.D_E_L_E_T_ = '' " + ENTER
CSQL += "UNION ALL " + ENTER
CSQL += "SELECT	E1_PORCJUR, K1_FILORIG, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, K1_CLIENTE, K1_LOJA, " + ENTER
CSQL += "		K1_VENCTO, E1_VALOR, E1_SALDO, E1_SALDO+E1_JUROS AS SALD_JUROS,  " + ENTER
CSQL += "		DATEDIFF(DAY,E1_VENCTO,GETDATE()) AS ATRASO  " + ENTER
CSQL += "FROM SK1010 SK1, SE1070 SE1 " + ENTER
CSQL += "WHERE	SK1.K1_FILIAL = '01' AND " + ENTER
CSQL += "		SE1.E1_FILIAL = '01' AND " + ENTER
CSQL += "		K1_FILORIG = '07' AND " + ENTER
CSQL += "		K1_SALDO <> '0' AND  E1_SALDO <> '0' AND " + ENTER
CSQL += "		K1_VENCTO >= '20090301' AND " + ENTER
CSQL += "		K1_VENCTO <= '"+DTOS(DDATABASE)+"' AND " + ENTER
CSQL += "		RTRIM(K1_PREFIXO)	= RTRIM(E1_PREFIXO) AND " + ENTER
CSQL += "		RTRIM(K1_NUM)		= RTRIM(E1_NUM) AND " + ENTER
CSQL += "		RTRIM(K1_PARCELA)	= RTRIM(E1_PARCELA) AND " + ENTER
CSQL += "		RTRIM(K1_TIPO)		= RTRIM(E1_TIPO) AND " + ENTER
CSQL += "		RTRIM(K1_CLIENTE)	= RTRIM(E1_CLIENTE) AND " + ENTER
CSQL += "		RTRIM(K1_LOJA)		= RTRIM(E1_LOJA) AND " + ENTER
CSQL += "		SK1.D_E_L_E_T_ = '' AND " + ENTER
CSQL += "		SE1.D_E_L_E_T_ = '' " + ENTER

// Vitcer - OS: 2087-14 - Usuแrio: Clebes Jose Andre
CSQL += "UNION ALL " + ENTER
CSQL += "SELECT	E1_PORCJUR, K1_FILORIG, K1_PREFIXO, K1_NUM, K1_PARCELA, K1_TIPO, K1_CLIENTE, K1_LOJA, " + ENTER
CSQL += "		K1_VENCTO, E1_VALOR, E1_SALDO, E1_SALDO+E1_JUROS AS SALD_JUROS,  " + ENTER
CSQL += "		DATEDIFF(DAY,E1_VENCTO,GETDATE()) AS ATRASO  " + ENTER
CSQL += "FROM SK1010 SK1, SE1140 SE1 " + ENTER
CSQL += "WHERE	SK1.K1_FILIAL = '01' AND " + ENTER
CSQL += "		SE1.E1_FILIAL = '01' AND " + ENTER
CSQL += "		K1_FILORIG = '14' AND " + ENTER
CSQL += "		K1_SALDO <> '0' AND  E1_SALDO <> '0' AND " + ENTER
CSQL += "		K1_VENCTO >= '20090301' AND " + ENTER
CSQL += "		K1_VENCTO <= '"+DTOS(DDATABASE)+"' AND " + ENTER
CSQL += "		RTRIM(K1_PREFIXO)	= RTRIM(E1_PREFIXO) AND " + ENTER
CSQL += "		RTRIM(K1_NUM)		= RTRIM(E1_NUM) AND " + ENTER
CSQL += "		RTRIM(K1_PARCELA)	= RTRIM(E1_PARCELA) AND " + ENTER
CSQL += "		RTRIM(K1_TIPO)		= RTRIM(E1_TIPO) AND " + ENTER
CSQL += "		RTRIM(K1_CLIENTE)	= RTRIM(E1_CLIENTE) AND " + ENTER
CSQL += "		RTRIM(K1_LOJA)		= RTRIM(E1_LOJA) AND " + ENTER
CSQL += "		SK1.D_E_L_E_T_ = '' AND " + ENTER
CSQL += "		SE1.D_E_L_E_T_ = '' " + ENTER
CSQL += "ORDER BY K1_CLIENTE " + ENTER

IF CHKFILE("_TABELA")
	DBSELECTAREA("_TABELA")
	DBCLOSEAREA()
ENDIF
TCQUERY CSQL ALIAS "_TABELA" NEW

IF ! _TABELA->(EOF())
	S_CLIENTE := _TABELA->K1_CLIENTE
	S_NOME 		:= 	ALLTRIM(Posicione("SA1",1,xFilial("SA1")+_TABELA->K1_CLIENTE+_TABELA->K1_LOJA,"A1_NOME"))
	CHTML := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> '
	CHTML += '<html xmlns="http://www.w3.org/1999/xhtml"> '
	CHTML += '<head> '
	CHTML += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" /> '
	CHTML += '<title>Untitled Document</title> '
	CHTML += '<style type="text/css"> '
	CHTML += '<!-- '
	CHTML += '.style12 {font-size: 9px; } '
	CHTML += '.style35 {font-size: 10pt; } '
	CHTML += '.style41 { '
	CHTML += '	font-size: 12px; '
	CHTML += '	font-weight: bold; '
	CHTML += '} '
	CHTML += '.style44 {color: #FFFFFF; font-size: 10px; } '
	CHTML += '.style45 {font-size: 10px; } '
	CHTML += ' '
	CHTML += '--> '
	CHTML += '</style> '
	CHTML += '</head> '
	CHTML += ' '
	CHTML += '<body> '
	CHTML += '<table width="956" border="1"> '
	CHTML += '  <tr> '
	CHTML += '    <th width="751" rowspan="3" scope="col">LISTA DOS T&Iacute;TULOS  DO CALL CENTER </th> '
	CHTML += '    <td width="189" class="style12"><div align="right"> DATA EMISSรO: 20/01/08 </div></td> '
	CHTML += '  </tr> '
	CHTML += '  <tr> '
	CHTML += '    <td class="style12"><div align="right">HORA DA EMISS&Atilde;O: 14:00:00 </div></td> '
	CHTML += '  </tr> '
	CHTML += '  <tr> '
	CHTML += '    <td><div align="center" class="style41"> BIANCOGRES CERยMICA SA </div></td> '
	CHTML += '  </tr> '
	CHTML += '</table> '
	CHTML += ' '
	CHTML += '<table width="957" border="1"> '
	CHTML += '  <tr bgcolor="#0066CC"> '
	CHTML += '    <th width="100"	scope="col"><span class="style44"> PRF-NUM -PARC </span></th> '
	CHTML += '    <th width="68" scope="col"><span class="style44"> VENC. </span></th> '
	CHTML += '    <th width="79" scope="col"><span class="style44">VAL. TIT.</span></th> '
	CHTML += '    <th width="83" scope="col"><span class="style44">SALDO</span></th> '
	CHTML += '    <th width="80" scope="col"><span class="style44">SAL. JUROS</span></th> '
	CHTML += '    <th width="89" scope="col"><span class="style44"> DIAS DE ATRASO </span></th> '
	CHTML += '    <th width="80" scope="col"><span class="style44"> JUROS </span></th> '
	CHTML += '    <th width="412" scope="col"><span class="style44">HIST&Oacute;RICO </span></th> '
	CHTML += '  </tr> '
	CHTML += ' 		  <tr bgcolor="#FFFFFF"> '
	CHTML += ' 	    <th colspan="8" scope="col"><div align="left" class="style35">CLIENTE: '+S_CLIENTE+' - '+ S_NOME +' </div></th> '
	CHTML += ' 	  </tr> '
ELSE
	RETURN
END IF

I := 1

WHILE ! _TABELA->(EOF())
	
	I ++
	/*IF I = 3000
	CHTML_1 := CHTML
	CHTML := ""
	ELSEIF I = 6000
	CHTML_2 := CHTML
	CHTML := ""
	ELSEIF I = 9000
	CHTML_3 := CHTML
	CHTML := ""
	ELSEIF I = 12000
	CHTML_4 := CHTML
	CHTML := ""
	ELSEIF I = 15000
	CHTML_5 := CHTML
	CHTML := ""
	ELSEIF I = 18000
	CHTML_6 := CHTML
	CHTML := ""
	ELSEIF I = 21000
	CHTML_7 := CHTML
	CHTML := ""
	ELSEIF I = 24000
	CHTML_8 := CHTML
	CHTML := ""
	ELSEIF I = 27000
	CHTML_9 := CHTML
	CHTML := ""
	ELSEIF I = 30000
	CHTML_10 := CHTML
	CHTML := ""*/
	//END IF*/
	
	IF S_CLIENTE <> _TABELA->K1_CLIENTE
		S_CLIENTE := _TABELA->K1_CLIENTE
		S_NOME := 	ALLTRIM(Posicione("SA1",1,xFilial("SA1")+_TABELA->K1_CLIENTE+_TABELA->K1_LOJA,"A1_NOME"))
		CHTML += ' <tr bordercolor="#FFFFFF"> '
		CHTML += ' 	    <td colspan="8">&nbsp;</td> '
		CHTML += ' 	  </tr> '
		CHTML += ' 	  <tr bgcolor="#FFFFFF"> '
		CHTML += ' 	    <th colspan="8" scope="col"><div align="left" class="style35">CLIENTE: '+S_CLIENTE+' - '+ S_NOME +' </div></th> '
		CHTML += ' 	  </tr>  '
	ENDIF
	
	CHTML += '   <tr> '
	CHTML += '     <td class="style45"> '+ALLTRIM(_TABELA->K1_PREFIXO)+' '+ALLTRIM(_TABELA->K1_NUM)+' '+ALLTRIM(_TABELA->K1_PARCELA)+' '+ALLTRIM(_TABELA->K1_TIPO)+' </td> '
	CHTML += '     <td class="style45"> '+DTOC(STOD(_TABELA->K1_VENCTO))+' </td> '
	CHTML += '     <td class="style45"> '+ TRANSFORM(_TABELA->E1_VALOR	,"@E 999,999,999.99") +' </td> '
	CHTML += '     <td class="style45"> '+ TRANSFORM(_TABELA->E1_SALDO	,"@E 999,999,999.99") +' </td> '
	
	CSALDO_JUROS := (_TABELA->E1_SALDO  / 100)   *    (_TABELA->E1_PORCJUR*_TABELA->ATRASO)
	
	CHTML += '     <td class="style45"> '+ TRANSFORM(_TABELA->E1_SALDO + CSALDO_JUROS	,"@E 999,999,999.99") +' </td> '
	CHTML += '     <td class="style45"> '+ALLTRIM(STR(_TABELA->ATRASO))+' </td> '
	CHTML += '     <td class="style45"> '+ TRANSFORM(CSALDO_JUROS	,"@E 999,999,999.99") +' </td> '
	
	CCOBS := ""
	// BUSCANDO O ULTIMO CODIGO DO ATENDIMENTO
	CSQL := " SELECT MAX(ACG_CODIGO) AS ACG_CODIGO  " + ENTER
	CSQL += " FROM "+RETSQLNAME("ACG")+" " + ENTER
	CSQL += " WHERE	RTRIM(ACG_TITULO) = '"+ALLTRIM(_TABELA->K1_NUM)+"' AND " + ENTER
	CSQL += " 			RTRIM(ACG_PREFIX) = '"+ALLTRIM(_TABELA->K1_PREFIXO)+"' AND " + ENTER
	CSQL += " 			RTRIM(ACG_PARCEL) = '"+ALLTRIM(_TABELA->K1_PARCELA)+"' AND " + ENTER
	CSQL += " 			RTRIM(ACG_TIPO) = '	"+ALLTRIM(_TABELA->K1_TIPO)+"' AND " + ENTER
	CSQL += " 			D_E_L_E_T_ = '' " + ENTER
	IF CHKFILE("_CODIGO")
		DBSELECTAREA("_CODIGO")
		DBCLOSEAREA()
	ENDIF
	TCQUERY CSQL ALIAS "_CODIGO" NEW
	
	IF _TABELA->K1_FILORIG = "01"
		CCOBS := "BIANCO  -  "
	ELSEIF _TABELA->K1_FILORIG = "05"
		CCOBS := "INCESA  -  "
	ELSEIF _TABELA->K1_FILORIG = "07"
		CCOBS := "LM  -  "
	ELSEIF _TABELA->K1_FILORIG = "14"
		CCOBS := "VITCER  -  "		
	ENDIF
	
	IF ! _CODIGO->(EOF())
		// BUSCANDO O CODIGO DE OBSERVACAO
		CSQL := " SELECT ACF_CODOBS FROM "+RETSQLNAME("ACF")+" WHERE ACF_CODIGO = '"+_CODIGO->ACG_CODIGO+"' AND D_E_L_E_T_ = '' "
		IF CHKFILE("_OBS")
			DBSELECTAREA("_OBS")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_OBS" NEW
		
		CSQL := " SELECT * FROM SYP010 WHERE YP_CHAVE = '"+_OBS->ACF_CODOBS+"' AND D_E_L_E_T_ = '' ORDER BY YP_SEQ "
		IF CHKFILE("_AUX")
			DBSELECTAREA("_AUX")
			DBCLOSEAREA()
		ENDIF
		TCQUERY CSQL ALIAS "_AUX" NEW
		WHILE ! _AUX->(EOF())
			CCOBS += _AUX->YP_TEXTO
			_AUX->(DBSKIP())
		END
		
	ENDIF
	CHTML += '     <td class="style45"> '+CCOBS+' </td> '
	CHTML += '   </tr> '
	
	_TABELA->(DBSKIP())
	
END

CHTML += '   <tr bordercolor="#FFFFFF"> '
CHTML += '     <td colspan="8">&nbsp;</td> '
CHTML += '   </tr> '
CHTML += ' </table> '
CHTML += ' <span class="style35">Esta ้ uma mensagem automแtica, favor nใo responde-la. </span> '
CHTML += ' </body> '
CHTML += ' </html> '

cRecebe     := "nadine.araujo@biancogres.com.br"
cRecebeCC	:= ""
cRecebeCO	:= ""
cAssunto	:= "TITULOS EM ATRASO."							// Assunto do Email

U_BIAEnvMail(,cRecebe,cAssunto,CHTML) 

RETURN