#INCLUDE "MATC090.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CONS_NF  � Rev.  � BRUNO MADALENO        � Data �25.05.2009���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta Nota Fiscal de Saida.                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER Function CONS_NF()
	//������������������������������������������������������Ŀ
	//� Define Variaveis                                     �
	//��������������������������������������������������������
	Local aCores    := {}       

	//Variavel utilizada para filtrar as NF's de cada Representante.
	Local cFiltro	:= ""

	//Monta filtro
	cFiltro := "(F2_VEND1 = '"+cRepAtu+"' OR F2_VEND2 = '"+cRepAtu+"' OR F2_VEND3 = '"+cRepAtu+"' OR "
	cFiltro += " R_E_C_N_O_ IN 															"
	cFiltro += "     		(SELECT SF2.R_E_C_N_O_										"
	cFiltro += "			FROM "+RetSqlName("SF2")+" SF2, "+RetSqlName("SD2")+" SD2	"
	cFiltro += "			WHERE	SF2.F2_FILIAL 	= '"+xFilial("SF2")+"'	AND			"
	cFiltro += "					SD2.D2_FILIAL	= '"+xFilial("SD2")+"' 	AND			"
	cFiltro += "					SF2.F2_DOC 		= SD2.D2_DOC 			AND 		"
	cFiltro += "					SF2.F2_SERIE 	= SD2.D2_SERIE 			AND 		"
	cFiltro += "					SF2.F2_CLIENTE 	= SD2.D2_CLIENTE 		AND 		"
	cFiltro += "					SF2.F2_LOJA 	= SD2.D2_LOJA 			AND 		"
	cFiltro += "					SF2.F2_EMISSAO	>= '"+Dtos(ddatabase - 90)+"' AND 	"
	cFiltro += "					SD2.D_E_L_E_T_ 	= '' 					AND 		"
	cFiltro += "					SF2.D_E_L_E_T_ 	= '' 					AND 		"
	cFiltro += "					SD2.D2_PEDIDO IN (SELECT C5_YPEDORI FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YEMPPED = '"+cEmpant+"' AND (C5_VEND1 = '"+cRepAtu+"' OR C5_VEND2 = '"+cRepAtu+"' OR C5_VEND3 = '"+cRepAtu+"') AND D_E_L_E_T_ = ''))) AND F2_EMISSAO >= '"+Dtos(ddatabase - 90)+"'  "

	IF cPaisLoc == "BRA"
		aCores    := {	{  'F2_TIPO=="N"'	, 'DISABLE'}	,;	// NF Normal
		{  'F2_TIPO=="P"'	, 'BR_AZUL'}	,;	// NF de Compl. IPI
		{  'F2_TIPO=="I"'	, 'BR_MARRON'}	,;	// NF de Compl. ICMS
		{  'F2_TIPO=="C"'	, 'BR_PINK'}	,;	// NF de Compl. Preco/Frete
		{  'F2_TIPO=="B"'	, 'BR_CINZA'}	,;	// NF de Beneficiamento
		{  'F2_TIPO=="D"'	, 'BR_AMARELO'} }	// NF de Devolucao
	Else
		AAdd(aCores,{	'F2_TIPO	==	"N" .And. F2_TIPODOC	==	"01"'	, 'DISABLE'})		// NF Normal
		AAdd(aCores,{  	'F2_TIPO	==	"C"	.And. F2_TIPODOC	$	"02/03"', 'BR_PINK'})		// NF de Compl. Preco/Frete
		AAdd(aCores,{  	'F2_TIPO	==	"B"	'								, 'BR_CINZA'})		// NF de Beneficiamento
		AAdd(aCores,{  	'F2_TIPO	==	"D"	.And. F2_TIPODOC	$	"06/07"', 'BR_AMARELO'}) 	// NF de Devolucao
		AAdd(aCores,{  	'F2_TIPO	==	"D"	.And. F2_TIPODOC	==	"61"' 	, 'BR_AZUL'})		// Remito de devolucao
		AAdd(aCores,{  	'F2_TIPO	==	"N"	.And. F2_TIPODOC	==	"50"' 	, 'BR_MARRON'})		// Remito 
		AAdd(aCores,{  	'F2_TIPO	==	"B"	.And. F2_TIPODOC	==	"54"'   , 'BR_PRETO'}) 		// Remito transferencia
	Endif

	Private aRotina := MenuDef()				
	//������������������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes           �
	//��������������������������������������������������������
	PRIVATE cCadastro := IIf(cPaisLoc=="BRA",STR0004,STR0011) //"Consulta Nota Fiscal de Saida" ## "Consulta Documentos de Saida"
	//������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                          �
	//��������������������������������������������������������

	mBrowse(6,1,22,75,"SF2",,,,,,aCores,,,,,,,,cFiltro)

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mc090Visual� Autor � Edson Maricate       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para visualizacao de NF de Saida.                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void Mc090Visual(ExpC1,ExpN1)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN2 = Numero do registro                                 ���
���          � ExpN3 = Opcao da Mbrowse                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
USER Function Mc090Visual(cAlias,nReg,nOpc)

	Local aArea      := GetArea()
	Local aAreaSA1   := SA1->(GetArea())
	Local aAreaSA2   := SA2->(GetArea())
	Local aAreaSD2   := SD2->(GetArea())

	Local lQuery     := .F.
	Local cAliasSD2  := "SD2"
	Local hj

	#IFDEF TOP
	Local cQuery     := ""
	#ENDIF	

	IF ! SA1->(DBSEEK ( xFILIAL("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA))
		RETURN
	ENDIF

	IF SF2->F2_CLIENTE == '010064' .AND. DTOS(SF2->F2_EMISSAO) >= '20120101' 

		//Busca todos os pedidos
		aPedido := U_fBuscaPedido(SF2->F2_FILIAL,SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_CLIENTE,SF2->F2_LOJA)

		//Roda todos pedidos
		For hj := 1 to Len(aPedido)
			If hj > 1
				nPedido := nPedido+","
			EndIf
			nPedido := "'"+aPedido[hj]+"'"
		Next hj	

		cQuery := ""
		cQuery := "SELECT MAX(C5_VEND1) AS C5_VEND1 FROM SC5070 WHERE C5_FILIAL = '01' AND C5_YPEDORI IN ("+nPedido+") AND C5_YEMPPED = '"+cEmpAnt+"' AND D_E_L_E_T_ = '' "
		IF chkfile("cTrab")
			dbSelectArea("cTrab")
			dbCloseArea()
		ENDIF
		cQuery := ChangeQuery(cQuery)
		TCQUERY cQuery ALIAS "cTrab" NEW
		cTrab->(dbGoTop())            

		IF !EMPTY(cTrab->C5_VEND1)
			IF SUBSTRING(CREPATU,1,1) == "1"
				IF CEMPANT == "01"
					IF (SA1->A1_YVENDB2 <> CREPATU .AND. SA1->A1_YVENDB3 <> CREPATU) 
						ALERT("CLIENTE N�O PERTENCE A SUA CARTEIRA")
						RETURN
					ENDIF
				ELSE
					IF (SA1->A1_YVENDI2 <> CREPATU .AND. SA1->A1_YVENDI3 <> CREPATU) 
						ALERT("CLIENTE N�O PERTENCE A SUA CARTEIRA")
						RETURN
					ENDIF		
				ENDIF	
			ELSE	
				IF cTrab->C5_VEND1 <> CREPATU
					ALERT("CLIENTE N�O PERTENCE A SUA CARTEIRA - LM")
					RETURN
				ENDIF
			ENDIF	    
		ELSE
			ALERT("CLIENTE N�O ENCONTRADO NA EMPRESA LM")
			RETURN
		ENDIF
	ELSE
		// VERIFICANDO SE E O GERENTE // BRUNO MADALENO 
		IF SUBSTRING(CREPATU,1,1) = "1"
			IF CEMPANT == "01"
				IF (SA1->A1_YVENDB2 <> CREPATU .AND. SA1->A1_YVENDB3 <> CREPATU) 
					ALERT("CLIENTE N�O PERTENCE A SUA CARTEIRA")
					RETURN
				ENDIF
			ELSE
				IF (SA1->A1_YVENDI2 <> CREPATU .AND. SA1->A1_YVENDI3 <> CREPATU) 
					ALERT("CLIENTE N�O PERTENCE A SUA CARTEIRA")
					RETURN
				ENDIF		
			ENDIF	
		ELSE	
			IF SF2->F2_VEND1 <> CREPATU
				ALERT("CLIENTE N�O PERTENCE A SUA CARTEIRA")
				RETURN
			ENDIF
		ENDIF	    
	ENDIF

	//��������������������������������������������������������������Ŀ
	//� Salva a pilha da funcao fiscal                               �
	//����������������������������������������������������������������
	MaFisSave()
	MaFisEnd()

	dbSelectArea("SD2")
	dbSetOrder(3)
	#IFDEF TOP

	If TcSrvType() <> "AS/400"

		cAliasSD2 := CriaTrab(,.F.)
		lQuery := .T.
		cQuery := "SELECT D2_FILIAL,D2_DOC,D2_SERIE,D2_CLIENTE,D2_LOJA,D2_TIPO,R_E_C_N_O_ SD2RECNO "
		cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
		cQuery += "WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND "
		cQuery += "SD2.D2_DOC='"+SF2->F2_DOC+"' AND "
		cQuery += "SD2.D2_SERIE='"+SF2->F2_SERIE+"' AND "
		cQuery += "SD2.D2_CLIENTE='"+SF2->F2_CLIENTE+"' AND "
		cQuery += "SD2.D2_LOJA='"+SF2->F2_LOJA+"' AND "
		cQuery += "SD2.D2_TIPO='"+SF2->F2_TIPO+"' AND "
		cQuery += "SD2.D_E_L_E_T_=' ' "
		cQuery += "ORDER BY "+SqlOrder(SD2->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	Else		
		#ENDIF
		MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
		#IFDEF TOP
	Endif	
	#ENDIF

	While !Eof() .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
	SF2->F2_DOC == (cAliasSD2)->D2_DOC .And.;
	SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
	SF2->F2_CLIENTE == (cAliasSD2)->D2_CLIENTE .And.;
	SF2->F2_LOJA == (cAliasSD2)->D2_LOJA
		If SF2->F2_TIPO == (cAliasSD2)->D2_TIPO
			If lQuery
				SD2->(MsGoto((cAliasSD2)->SD2RECNO))
			EndIf
			A920NFSAI("SD2",SD2->(RecNo()),0)
			Exit
		EndIf
		dbSelectArea(cAliasSD2)
		dbSkip()
	EndDo
	If lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
		dbSelectArea("SD2")	
	EndIf
	//��������������������������������������������������������������Ŀ
	//� Restaura a pilha da funcao fiscal                            �
	//����������������������������������������������������������������
	MaFisRestore()
	RestArea(aAreaSD2)
	RestArea(aAreaSA2)
	RestArea(aAreaSA1)
	RestArea(aArea)

Return (.T.)


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MC090Legend� Autor � Edson Maricate       � Data � 01.02.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATC090                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function MC090Legend()
	If cPaisLoc == "BRA"
		BrwLegenda(cCadastro,STR0003,{{"DISABLE",STR0005} ,; //"Legenda"###"NF Normal"
		{"BR_AZUL",STR0006},; //"NF de Compl. IPI"
		{"BR_MARRON",STR0007},; //"NF de Compl. ICMS"
		{"BR_PINK",STR0008},; //"NF de Compl. Preco/Frete"
		{"BR_CINZA",STR0009},; //"NF de Beneficiamento"
		{"BR_AMARELO",STR0010 }} ) //"NF de Devolucao"
	Else
		LocxLegenda("SF2",.F.,STR0012)
	Endif
Return .T.


/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MenuDef()

	Private aRotina := {	{ STR0001,"AxPesqui"		,0,1,0,.F.},;		// "Pesquisar"
	{ STR0002,"U_MC090Visual"	,0,2,0,NIL},;		// "Visualizar"
	{ STR0003,"MC090Legend"	,0,5,0,NIL} }	 	// "Legenda"

Return(aRotina)
