#include "MATA235.CH"  
#include "PROTHEUS.CH" 
/*/ 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA        �Programa     MATA235.PRX���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data                            ���
�������������������������������������������������������������������������Ĵ��
���      01  �Alexandre Inacio Lemes    � 09/03/2006                      ���
���      02  �Erike Yuri da Silva       � 19/12/2005                      ���
���      03  �Alexandre Inacio Lemes    � 23/01/2005                      ���
���      04  �Ricardo Berti             � 24/01/2006                      ���
���      05  �Alexandre Inacio Lemes    � 23/01/2005                      ���
���      06  �Alexandre Inacio Lemes    � 09/03/2006                      ���
���      07  �Ricardo Berti             � 24/01/2006                      ���
���      08  �Alexandre Inacio Lemes    � 05/12/2005                      ���
���      09  �Erike Yuri da Silva       � 19/12/2005                      ���
���      10  �Alexandre Inacio Lemes    � 05/12/2005                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA235  � Autor � Marcelo B. Abe        � Data � 10.02.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Encerrar os Pedidos de compra, autoriza�oes de entrega e   ���
���          � Contratos de Parceria com residuos.                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��� Edson   M.   �21/08/98�xxxxxx�Inclusao do PE MT235G1.                 ���
��� Viviani      �11/01/99�Melhor�Nova criacao de dialog (Protheus)       ���
��� Patricia Sal.�28/04/00�003787�Alterar o dbSeek() no SB2 p/ : Filial + ���
���              �        �      �Produto + Local.                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATA235()
LOCAL nOpca := 0
Local aSays:={}, aButtons := {}
Local lRet := .T.
Local aRecSC1	:= {}
Local aNumSC1	:= {}
Local aRecSC7	:= {}
Local aNumSC7	:= {}
Local lIntegDef := .F.
Local n1Cnt	:=0   
Local dDataBloq	:= GetNewPar("MV_ATFBLQM",CTOD("")) //Data de Bloqueio da Movimenta��o - MV_ATFBLQM
Local aRet		:= {}
Local cMsgRet	:= ""
Local lConsEIC := SuperGetMV("MV_ELREIC",.F.,.T.)

PRIVATE lMT235G1 := existblock("MT235G1")

PRIVATE cCadastro := OemToAnsi(STR0001)		//"Elim. de res�duos dos Pedidos de Compras"

pergunte("MTA235",.F.)
//�����������������������������������������������������Ŀ
//� mv_par01 - Percentual maximo                        �
//� mv_par02 - Data de Emissao de:                      �
//� mv_par03 - Data de Emissao ate:                     �
//� mv_par04 - Pedido de  :                             �
//� mv_par05 - Pedido ate :                             �
//� mv_par06 - Produto de :                             �
//� mv_par07 - Produto ate:                             �
//� mv_par08 - Elimina residuo por: 1-Pedido 2-Aut.Entr.�
//�                      3-Pedido e Autor. 4-Solicitacao�
//� mv_par09 - Fornecedor de   :                        �
//� mv_par10 - Fornecedor ate  :                        �
//� mv_par11 - Data Entrega de :                        �
//� mv_par12 - Data Entrega ate:                        �
//� mv_par13 - Elimina SC com OP? 1-Sim  2-Nao          �
//�������������������������������������������������������

AADD(aSays,OemToAnsi(STR0002))
AADD(aSays,OemToAnsi(STR0003))
AADD(aSays,OemToAnsi(STR0004))

AADD(aButtons, { 5,.T.,{|| Pergunte("MTA235",.t.) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, o:oWnd:End() } } )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

FormBatch( cCadastro, aSays, aButtons,,200,445 )  

If nOpca == 1 .And. mv_par01 > 0
	
	//�����������������������������������������������������������������L�
	//�Ponto de Entrada que permite a eliminina��o dos res�duos ou n�o.�
	//�����������������������������������������������������������������L�
	If ExistBlock("MA235PC")
		lRet := Execblock("MA235PC",.F.,.F.,)
		If ValType(lRet) <> "L"
			lRet := .T.
		EndIf
	EndIf  
	
	//Verifica se existe bloqueio cont�bil
	If lRet
		lRet := CtbValiDt(Nil,dDataBase,/*.T.*/ ,Nil ,Nil ,{"COM001"}/*,"Data de apura��o bloqueada pelo calend�rio cont�bil."*/) 
	EndIf  
	
	If lRet
		Begin Transaction
		
			Do Case
			Case mv_par08 < 4  // 1=pedido  2=Aut.Entrega  3=Pedido e Autorizacao
				If mv_par08 == 1 //Pedido de compra
					aRet := A235ELIRM(mv_par04,mv_par05)
					If !aRet[1]
						Aviso(STR0010,aRet[2],{STR0013},2)
						lRet := .F.
						DisarmTransaction()
					Endif
				Endif
				
				If lRet
					Processa({|lEnd| MA235PC(mv_par01,mv_par08,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,mv_par14,mv_par15,lConsEIC,aRecSC7)})
				
					If mv_par08 == 1 //Pedido de compra
						lIntegDef	:=  FWHasEAI("MATA120",.T.,,.T.)
						If	lIntegDef
							If Len(aRecSC7) > 0
								//-- Somente PC processada pela funcao MA235PC
								For n1Cnt := 1 To Len(aRecSC7)
									SC7->(DbGoTo(aRecSC7[n1Cnt]))
									
									lIntReg := INTREG("SC7",SC7->C7_NUM)
									If Ascan(aNumSC7,SC7->C7_NUM) == 0 .And. lIntReg
										AAdd(aNumSC7,SC7->C7_NUM)
										Inclui := .T.
										Altera := .T.
										aRet := FwIntegDef( 'MATA120' )
										
										If Valtype(aRet) == "A"
											If Len(aRet) == 2
												If !aRet[1]
													If Empty(AllTrim(aRet[2]))
														cMsgRet := STR0011
													Else
														cMsgRet := AllTrim(aRet[2])
													Endif
													Aviso(STR0010,cMsgRet,{STR0013},3)
													DisarmTransaction()
													Return .F.
												Endif
											Endif
										Endif
									EndIf
								Next n1Cnt
							Endif
						EndIf
					Endif
				Endif
			Case mv_par08 == 4 //Contrato de Parceria
				Processa({|lEnd| MA235CP(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,mv_par14,mv_par15)})
			Case mv_par08 == 5 //Solicitacao de Compras
				Processa({|lEnd| MA235SC(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,mv_par07,mv_par09,mv_par10,mv_par11,mv_par12,(mv_par13==2),mv_par14,mv_par15,aRecSC1)})
				//-- Variavel usada para verificar se o disparo da funcao IntegDef() pode ser feita manualmente
				lIntegDef	:=  FWHasEAI("MATA110",.T.,,.T.)
				If	lIntegDef
					//-- Atualiza array de recnos a serem processados na mensagem unica no MATA110
					MTA110SC1(aRecSC1)
					//-- Somente SC processada pela funcao MA235SC
					For n1Cnt := 1 To Len(aRecSC1)
						SC1->(DbGoTo(aRecSC1[n1Cnt]))
						
						lIntReg := INTREG("SC1",SC1->C1_NUM)
						If	Ascan(aNumSC1,SC1->C1_NUM) == 0 .And. lIntReg
							AAdd(aNumSC1,SC1->C1_NUM)
							Inclui := .T.
							Altera := .T.
							FwIntegDef( 'MATA110' )
						EndIf
					Next n1Cnt
				EndIf
			EndCase
		End Transaction
	EndIf
EndIf

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A235ELIRM   � Autor � Rodrigo M Pontes   � Data � 12.01.16 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se pode realizar o processo de elimina��o de      ���
���          � residuos.                                                  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function A235ELIRM(cPedidoDe,cPedidoAte)

Local lRet	:= .T.
Local cMsg	:= ""
Local cQry	:= ""

If Select("PEDINT") > 0
	PEDINT->(DbCloseArea())
Endif

cQry := " SELECT C7_NUM"
cQry += " FROM " + RetSqlName("SC7")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND C7_ORIGEM = 'MSGEAI'"
cQry += " AND C7_NUM BETWEEN '" + cPedidoDe + "' AND '" + cPedidoAte + "'"
cQry += " AND C7_FILIAL = '" + xFilial("SC7") + "'"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"PEDINT",.T.,.T.)

DbSelectArea("PEDINT")
While PEDINT->(!EOF())
	If Empty(cMsg)
		cMsg := STR0014 + AllTrim(PEDINT->C7_NUM)
	Else
		cMsg := ", " + AllTrim(PEDINT->C7_NUM)
	Endif
	PEDINT->(DbSkip())
Enddo

If !Empty(cMsg)
	cMsg += STR0012
	lRet := .F.
Endif

Return {lRet,cMsg}

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA235PC	   � Autor � Marcelo B. Abe     � Data � 10.02.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fechar os Pedidos de Compras  e Autorizacoes de entrega    ���
���          � com residuos.                                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nPar1 : Percentual de residuo a ser eliminado              ���
���          � cTipo2: 1-Pedido, 2-Autor.Entrega, 3-Ambos                 ���
���          � dPar3 : Filtrar da Data de Emissao de                      ���
���          � dPar4 : Filtrar da Data de Emissao Ate                     ���
���          � cPar5 : Filtrar da Solicitacao de                          ���
���          � cPar6 : Filtrar da Solicitacao Ate                         ���
���          � cPar7 : Filtrar Produto de                                 ���
���          � cPar8 : Filtrar Produto Ate                                ���
���          � cPar9 : Filtrar Fornecedor de                              ���
���          � cPar10: Filtrar Fornecedor Ate                             ���
���          � dPar11: Filtrar Data Entrega de                            ���
���          � dPar12: Filtrar Data Entrega de                            ���
���          � cPar13: Filtrar Item de                                    ���
���          � cPar14: Filtrar Item Ate                                   ���
���          � lPar15: Filtra pedido de origem do EIC                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MA235PC(nPerc, cTipo, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte, lConsEIC, aRecSC7)

Local aRefImp   := {}
Local nRes      := 0
Local nPosRef1  := 0
Local nPosRef2  := 0
Local lProcessa := .T.
Local cAlias    := "SC7"
Local cQuery    := ""
Local nNaoProc  := 0
Local lRet      := .T.
Local lMT235AIR := existblock("MT235AIR")
Local lMT235G2  := existblock("MT235G2")
Local aNumPed	:= {}
Local aTNumPed	:= {}
Local lGCTRes   := (SuperGetMv("MV_CNRESID",.F.,"N") == "S") 	//Permite a Elimina��o de Res�duos no SIGAGCT?      
Local lVldVige  := GetNewPar("MV_CNFVIGE","N") == "N" 			//Permite configura��o de parcelas e realiza��o de medi��es fora do per�odo de vig�ncia do contrato ?
Local aArea
Local cUltSC7
Local cUltAlas

DEFAULT cItemDe := Space(4) 
DEFAULT cItemAte:= "ZZZZ"
DEFAULT lConsEIC:= .T.

If nModulo == 17 
	pergunte("MTA235",.F.)
EndIf

//������������������������������������������������������������������������Ŀ
//�Alimenta o Array aRefImp com base no dicionario                         �
//��������������������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC7")
While ( !Eof() .And. SX3->X3_ARQUIVO == "SC7" )
	nPosRef1	:= At("MAFISREF(",Upper(SX3->X3_VALID))
	If ( nPosRef1 > 0 )
		nPosRef1    += 10
		nPosRef2    := At(",",SubStr(SX3->X3_VALID,nPosRef1))-2
		aadd(aRefImp,{"SC7",SX3->X3_CAMPO,SubStr(SX3->X3_VALID,nPosRef1,nPosRef2)})
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo

ProcRegua(SC7->(RecCount())*5)

cQuery := "SELECT C7_FILIAL, C7_NUM,   C7_EMISSAO, C7_RESIDUO, C7_DATPRF, C7_PRODUTO, C7_FORNECE,"
cQuery += "       C7_LOJA,   C7_QUANT, C7_QUJE,    C7_TIPO,    C7_APROV,  C7_MOEDA,   C7_TXMOEDA, C7_ORIGEM, "
cQuery += "       R_E_C_N_O_ SC7RECNO 
cQuery += "  FROM " + RetSqlName("SC7") + " SC7 "
cQuery += " WHERE C7_EMISSAO  >= '"+Dtos(dEmisDe)+"' AND C7_EMISSAO <= '"+Dtos(dEmisAte)+"' "
cQuery += "   AND C7_NUM      >= '"+cCodigoDe+"' AND C7_NUM     <= '"+cCodigoAte+"' "
cQuery += "   AND C7_ITEM     >= '"+cItemDe+"'   AND C7_ITEM    <= '"+cItemAte+"' "
cQuery += "   AND C7_PRODUTO  >= '"+cProdDe+"'   AND C7_PRODUTO <= '"+ cProdAte + "' "
cQuery += "   AND C7_FORNECE  >= '"+cFornDe+"'   AND C7_FORNECE <= '"+cFornAte+"' "

If !Empty(dDatPrfDe) .And. !Empty(dDatPrfAte)
	cQuery += " AND C7_DATPRF >= '"+Dtos(dDatPrfDe)+"' AND C7_DATPRF<='"+Dtos(dDatPrfAte)+"' "
Endif		

cQuery += " AND C7_FILIAL ='" + xFilial("SC7") + "' "
cQuery += If(cTipo==1," AND C7_TIPO = 1 ",If(cTipo==2," AND C7_TIPO = 2 ",""))
cQuery += " AND C7_RESIDUO = ' ' "

If lConsEIC
	cQuery += " AND C7_ORIGEM <> 'EICPO400' "
Endif

cQuery += " AND SC7.D_E_L_E_T_<>'*'"
cQuery += " AND C7_QTDACLA = 0 "
cAlias := CriaTrab(,.F.)
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

PcoIniLan('000056')

While !Eof() .And. C7_FILIAL == xFilial("SC7") .And. C7_NUM <= cCodigoAte
	IncProc()
  
	dbSelectArea("SC7")
	SC7->(MsGoto((cAlias)->SC7RECNO))
	lProcessa := .T.
	
  	aArea	:= GetArea()
	If !Empty(SC7->C7_CONTRA) .And. lGCTRes
    	dbSelectArea("CN9")
 		CN9->(DbSetOrder(1))
		If CN9->(DbSeek(xFilial("CN9")+SC7->C7_CONTRA+SC7->C7_CONTREV))
  			If lVldVige .And.((CN9->CN9_SITUAC <> "05") .Or. (CN9->CN9_DTINIC > dDataBase .Or. CN9->CN9_DTFIM < dDataBase))  //Contrato finalizado ou fora do per�odo da vig�ncia 
			   	lProcessa := .F.
			EndIf			          
   		EndIf  
   	EndIf        
	RestArea(aArea)  

	If lProcessa
		If !Empty(cQuery)
			dbSelectArea("SC7")
			dbGoto((cAlias)->(SC7RECNO))
		EndIf
		//��������������������������������������������������������������Ŀ
		//� Ponto de entrada de validacao antes de executar a eliminacao �
		//����������������������������������������������������������������
		If lMT235G2
			lRet := ExecBlock("MT235G2",.F.,.F.,{IIf(Empty(cQuery),"SC7",(cAlias)),1})
			If If( ValType(lRet)="L", !lRet, .F.)
				dbSelectArea(cAlias)
				dbSkip()
				Loop
			EndIf
		Endif

		//��������������������������������������������������������������Ŀ
		//� Calcular o Residuo maximo da Compra.                         �
		//����������������������������������������������������������������
		nRes := (C7_QUANT * nPerc)/100

		//��������������������������������������������������������������Ŀ
		//� Verifica se o Pedido deve ser Encerrado.                     �
		//����������������������������������������������������������������    
		If (C7_QUANT - C7_QUJE <= nRes .And. C7_QUANT > C7_QUJE)
		 	aNumPed	:= {}
			Aadd(aNumPed,{xFilial("SC7"),SC7->C7_NUM,'PC'})			 
			If MA235PA(aNumPed,.T.)
				//-- Chama funcao que processa a eliminacao de residuos, acumulados e vinculados
				Ma235ElRes(@nNaoProc,aRefImp,aRecSC7)
				Aadd(aTNumPed,{xFilial("SC7"),SC7->C7_NUM,'PC'})
				
				dbSelectArea(cAlias)
		        If cUltSC7 != C7_NUM .and. !Empty(cUltSC7)//Apenas uma vez por PC				
					//Atualiza Al�ada do Pedido de Compras
		            MA235EPC(cUltAlias,cUltSC7)
		            dbSelectArea(cAlias)	
		        	cUltSC7 	:= C7_NUM
		        	cUltAlias 	:= C7_FILIAL
		        ElseIf Empty(cUltSC7)
		        	cUltSC7 	:= C7_NUM
		        	cUltAlias 	:= C7_FILIAL
		        EndIf				
			EndIf
		Endif
		
		//��������������������������������������������������������������Ŀ
		//� Ponto de entrada no final do processamento da eliminacao     �
		//����������������������������������������������������������������
		If lMT235AIR
			ExecBlock("MT235AIR",.F.,.F.,{If(Empty(cQuery),"SC7",(cAlias)),1})
    	EndIf
    	
	EndIf
	dbSelectArea(cAlias)
	dbSkip()
Enddo

dbSelectArea(cAlias)
If cUltSC7 != C7_NUM .and. !Empty(cUltSC7)				
	//Atualiza Al�ada do Pedido de Compras
    MA235EPC(cUltAlias,cUltSC7)
EndIf

If ValType(aTNumPed)<>"U"
	MA235PA(aTNumPed,.F.)
EndIf
				
If nNaoProc > 0  //" itens nao foram processados por estar em uso em outra estacao!"
	MsgInfo(Str(nNaoProc,4) + STR0009,STR0006)
EndIf
If !Empty(cQuery)
	dbSelectArea(cAlias)
	dbCloseArea()
EndIf

PcoFinLan('000056')
dbSelectArea("SC7")
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA235CP     � Autor � Marcelo B. Abe     � Data � 10.02.93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fechar os Contratos de Parceria com residuos               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nPar1 : Percentual de residuo a ser eliminado              ���
���          � dPar2 : Filtrar da Data de Emissao de                      ���
���          � dPar3 : Filtrar da Data de Emissao Ate                     ���
���          � cPar4 : Filtrar do Contrato de Parceria de                 ���
���          � cPar5 : Filtrar da Contrato de Parceria Ate                ���
���          � cPar6 : Filtrar Produto de                                 ���
���          � cPar7 : Filtrar Produto Ate                                ���
���          � cPar8 : Filtrar Fornecedor de                              ���
���          � cPar9 : Filtrar Fornecedor Ate                             ���
���          � dPar10: Filtrar Data Entrega de                            ���
���          � dPar11: Filtrar Data Entrega de                            ���
���          � cPar12: Filtrar Item de                                    ���
���          � cPar13: Filtrar Item Ate                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MA235CP(nPerc, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatprfde, dDatPrfAte, cItemDe, cItemAte)
Local nRes      := 0
Local cAlias    := "SC3"
Local cQuery    := ""
Local lProcessa := .T.
Local lRet	    := .T.
Local lMT235AIR := ExistBlock("MT235AIR")
Local nNaoProc  := 0
Local nTotItem	:= 0
DEFAULT cItemDe := Space(4) 
DEFAULT cItemAte:= "ZZZZ"

ProcRegua(SC3->(RecCount())*5)

cQuery := "SELECT C3_FILIAL, C3_QUANT,  C3_NUM,  C3_EMISSAO, C3_RESIDUO, C3_DATPRF, "
cQuery += "       C3_QUJE,   R_E_C_N_O_ SC3RECNO "
cQuery += "  FROM "+RetSqlName("SC3")+" SC3 "
cQuery += " WHERE C3_FILIAL   = '"+ xFilial("SC3") +"'"
cQuery += "   AND C3_NUM     >= '"+cCodigoDe+"' AND C3_NUM <= '"+cCodigoAte+"'"
cQuery += "   AND C3_ITEM    >= '"+cItemDe+"'   AND C3_ITEM <= '"+cItemAte+"' "
cQuery += "   AND C3_EMISSAO >= '"+DTOS(dEmisDe)+"' AND C3_EMISSAO <= '"+Dtos(dEmisAte)+"'"
cQuery += "   AND C3_PRODUTO >= '"+cProdDe+"' AND C3_PRODUTO <= '"+ cProdAte + "' "
cQuery += "   AND C3_FORNECE >= '"+cFornDe+"' AND C3_FORNECE <= '"+cFornAte+"' "

If !Empty(dDatPrfDe) .And. !Empty(dDatPrfAte)
	cQuery += " AND C3_DATPRF>='"+Dtos(dDatPrfDe)+"' AND C3_DATPRF<='"+Dtos(dDatPrfAte)+"' "
Endif		
cQuery += " AND C3_RESIDUO = ' ' And SC3.D_E_L_E_T_<>'*'"         

cAlias := CriaTrab(,.F.)
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

PcoIniLan('000056')
While !Eof() .And. C3_FILIAL == xFilial("SC3") .And. C3_NUM <= cCodigoAte
	lProcessa := .T.
	IncProc()

	If lProcessa
		//��������������������������������������������������������������Ŀ
		//� Ponto de entrada de validacao antes de executar a eliminacao �
		//����������������������������������������������������������������
		If ExistBlock("MT235G2")
			lRet := ExecBlock("MT235G2",.F.,.F.,{IIf(Empty(cQuery),"SC3",(cAlias)),2})
			If If( ValType(lRet)="L", !lRet, .F.)
				dbSelectArea(cAlias)
				dbSkip()
				Loop
			EndIf
		Endif
		//��������������������������������������������������������������Ŀ
		//� Calcular o Residuo maximo da Compra.                         �
		//����������������������������������������������������������������	
		nRes := (C3_QUANT * nPerc)/100
		//��������������������������������������������������������������Ŀ
		//� Verifica se a Autorizacao deve ser Encerrada                 �
		//����������������������������������������������������������������			
		If (C3_QUANT - C3_QUJE <= nRes .And. C3_QUANT > C3_QUJE)
			Begin Transaction
				If !Empty(cQuery)
					dbSelectArea("SC3")
					dbGoTo((cAlias)->(SC3RECNO))
				EndIf          
				nTotItem := SC3->C3_PRECO * (SC3->C3_QUANT - SC3->C3_QUJE)
				SCR->(dbSeek(xFilial("SCR")+"CP"+SC3->C3_NUM,.T.))

				If SimpleLock("SC3") .And. IIF(xFilial("SCR")+"CP"+SC3->C3_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SC3->C3_NUM)),SimpleLock("SCR"),.T.)

					RecLock("SC3",.F.)
					Replace C3_RESIDUO with "S"
					Replace C3_ENCER with "E"

					dbSelectArea("SCR")
					If xFilial("SCR")+"CP"+SC3->C3_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SC3->C3_NUM))
						MaAlcDoc({SC3->C3_NUM,"CP",nTotItem,,,SC3->C3_APROV,,SC3->C3_MOEDA,SC3->C3_TXMOEDA,SC3->C3_EMISSAO},SC3->C3_EMISSAO,5,,.T.)
					EndIf	

					SC3->(MsUnLock())
		            PcoDetLan('000056','03','MATA235')

				Else
					nNaoProc ++
				EndIf
			End Transaction
		Endif
		
		//��������������������������������������������������������������Ŀ
		//� Ponto de entrada no final do processamento da eliminacao     �
		//����������������������������������������������������������������
		If lMT235AIR
			ExecBlock("MT235AIR",.F.,.F.,{If(Empty(cQuery),"SC3",(cAlias)),2})
    	EndIf
	EndIf

	dbSelectArea(cAlias)
	dbSkip()
EndDo
If nNaoProc > 0  //" itens nao foram processados por estar em uso em outra estacao!"
	MsgInfo(Str(nNaoProc,4) + STR0009,STR0006)
EndIf

If !Empty(cQuery)
	dbSelectArea(cAlias)
	dbCloseArea()
EndIf

dbSelectArea("SC3")
PcoFinLan('000056')
Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA235SC     � Autor �Aline Correa do Vale� Data � 28.08.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fechar as Solicitacoes de Compras com residuos             ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nPar1 : Percentual de residuo a ser eliminado              ���
���          � dPar2 : Filtrar da Data de Emissao de                      ���
���          � dPar3 : Filtrar da Data de Emissao Ate                     ���
���          � cPar4 : Filtrar da Solicitacao de                          ���
���          � cPar5 : Filtrar da Solicitacao Ate                         ���
���          � cPar6 : Filtrar Produto de                                 ���
���          � cPar7 : Filtrar Produto Ate                                ���
���          � cPar8 : Filtrar Fornecedor de                              ���
���          � cPar9 : Filtrar Fornecedor Ate                             ���
���          � dPar10: Filtrar Data Entrega de                            ���
���          � dPar11: Filtrar Data Entrega de                            ���
���          � lPar12: Elimina SC com OP?                                 ���
���          � cPar13: Filtrar Item de                                    ���
���          � cPar14: Filtrar Item Ate                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MA235SC(nPerc, dEmisDe, dEmisAte, cCodigoDe, cCodigoAte, cProdDe, cProdAte, cFornDe, cFornAte, dDatPrfde, dDatPrfAte, lSemOp, cItemDe, cItemAte,aRecSC1)
Local nRes        := 0
Local nNaoProc    := 0   
Local nIndice     := 0 
Local cQuery      := ""
Local cSeekSCQ    := ""
Local cAlias      := "SC1"
Local cAliasTOP   := "SCQ"  
Local cAliasDBF   := "SCP"  
Local lProcessa   := .T.
Local lRet	      := .T.
Local lQuery      := .F.
Local lPrcPreReq  := .F.
Local lMT235AIR   := ExistBlock("MT235AIR")
Local aPosDhn	  := {}
Local cUltSC1	  := ""
Local cUltAlias   := ""

DEFAULT lSemOp  := .T.
DEFAULT aRecSC1	:= {}

DbSelectArea("SCR")
SCR->(dbSetOrder(1))

ProcRegua(SC1->(RecCount())*5)

cQuery := "SELECT C1_FILIAL, C1_QUANT, C1_NUM,     C1_EMISSAO, C1_RESIDUO, C1_DATPRF,"
cQuery += "       C1_QUJE,   C1_OP,    C1_COTACAO, R_E_C_N_O_ SC1RECNO "
cQuery += "  FROM "+RetSqlName("SC1")+" SC1 "
cQuery += " WHERE C1_FILIAL   = '"+xFilial("SC1")+"'"
cQuery += "   AND C1_NUM     >= '"+cCodigoDe+"' AND C1_NUM<='"+cCodigoAte+"' "
cQuery += "   AND C1_ITEM    >= '"+cItemDe+"' AND C1_ITEM<='"+cItemAte+"' "
cQuery += "   AND C1_EMISSAO >= '"+Dtos(dEmisDe)+"' AND C1_EMISSAO<='"+Dtos(dEmisAte)+"' "
cQuery += "   AND C1_PRODUTO >= '"+cProdDe+"' AND C1_PRODUTO<='"+ cProdAte + "' " 
cQuery += "   AND C1_FORNECE >= '"+cFornDe+"' AND C1_FORNECE<='"+ cFornAte + "' " 

If !Empty(dDatPrfDe) .And. !Empty(dDatPrfAte)
	cQuery += "AND C1_DATPRF>='"+Dtos(dDatPrfDe)+"' AND C1_DATPRF<='"+Dtos(dDatPrfAte)+"' "
Endif		

cQuery += " AND C1_FLAGGCT <> '1' AND C1_RESIDUO = ' ' And SC1.D_E_L_E_T_<>'*'"
cAlias := CriaTrab(,.F.)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
PcoIniLan('000056')

While !Eof() .And. C1_FILIAL == xFilial("SC1") .And. C1_NUM <= cCodigoAte
	lProcessa  := .T.
    lPrcPreReq := .F.
	IncProc()
                                  
	If lSemOp .And. !Empty(C1_OP)
		lProcessa := .F.
	EndIf

	If lProcessa .And. (!Empty(C1_COTACAO) .And. C1_COTACAO<>'IMPORT') .And. (C1_QUANT == C1_QUJE .Or. C1_QUJE == 0)
		lProcessa := .F.
	Endif

	If lProcessa
		//��������������������������������������������������������������Ŀ
		//� Ponto de entrada de validacao antes de executar a eliminacao �
		//����������������������������������������������������������������
		If ExistBlock("MT235G2")
			lRet := ExecBlock("MT235G2",.F.,.F.,{IIf(Empty(cQuery),"SC1",(cAlias)),3})
			If If( ValType(lRet)="L", !lRet, .F.)
				dbSelectArea(cAlias)
				dbSkip()
				Loop
			EndIf
		Endif
		//��������������������������������������������������������������Ŀ
		//� Calcular o Residuo maximo da Compra.                         �
		//����������������������������������������������������������������	
		nRes := (C1_QUANT * nPerc)/100
		//��������������������������������������������������������������Ŀ
		//� Verifica se a Autorizacao deve ser Encerrada                 �
		//����������������������������������������������������������������			
		If (C1_QUANT - C1_QUJE <= nRes .And. C1_QUANT > C1_QUJE)

			Begin Transaction
				If !Empty(cQuery)
					dbSelectArea("SC1")
					dbGoto((cAlias)->(SC1RECNO))
				EndIf
				If !SB2->(dbSeek(xFilial("SB2")+SC1->C1_PRODUTO+SC1->C1_LOCAL))
					CriaSb2( SC1->C1_PRODUTO,SC1->C1_LOCAL)
				Endif
				If SimpleLock("SC1") .And. SimpleLock("SB2")
					MaAvalSC("SC1",2)
					
					RecLock("SC1",.F.)
					Replace C1_QTDORIG WITH C1_QUANT
					Replace C1_RESIDUO WITH "S"
					SC1->(MsUnLock())
					
					AAdd(aRecSC1,SC1->(Recno()))

		            PcoDetLan('000056','01','MATA235')   
		            If SC1->C1_OBS == "SC gerada por SA              "
	   		            lPrcPreReq := .T.
   		            EndIf
   		            
   		            dbSelectArea(cAlias)
   		            If cUltSC1 != C1_NUM .and. !Empty(cUltSC1)//Apenas uma vez por SC				
						//Atualiza Al�ada da Solicita��o de Compras
	   		            MA235ESC(cUltAlias,cUltSC1)
	   		            dbSelectArea(cAlias)	
   		            	cUltSC1 	:= C1_NUM
   		            	cUltAlias 	:= C1_FILIAL
   		            ElseIf Empty(cUltSC1)
   		            	cUltSC1 	:= C1_NUM
   		            	cUltAlias 	:= C1_FILIAL
   		            EndIf
				Else
					nNaoProc ++
				EndIf   
			
				//��������������������������������������������������������������Ŀ
				//� Processa eliminacao de residuo da baixa da pre-requisicao    |
				//����������������������������������������������������������������			
				If lPrcPreReq
					lQuery    := .T.
					cAliasTOP := GetNextAlias()
					If Select(cAliasTOP) > 0 
				    	dbSelectArea(cAliasTOP)
				       	dbCloseArea()
					EndIf 
					cQuery := "SELECT SCP.CP_FILIAL, SCP.CP_PRODUTO, SCP.CP_NUM,    SCP.CP_ITEM,    SCP.CP_QUANT, "
					cQuery += "       SCQ.CQ_QTDISP, SCP.CP_QTSEGUM, SCQ.CQ_NUMREQ, SCQ.CQ_QTSEGUM, SCQ.CQ_QUANT, "	
					cQuery += "       SCQ.CQ_PRODUTO, SCP.R_E_C_N_O_ SCPRECNO, SCQ.R_E_C_N_O_ SCQRECNO"
					cQuery += "  FROM "+RetSqlName("SCP")+" SCP , "+RetSqlName("SCQ")+" SCQ "
					cQuery += " , " + RetSqlName("DHN") + " DHN "
					cQuery += " WHERE SCP.CP_FILIAL  = '"+xFilial("SCP")+"'"
					cQuery += "   AND SCQ.CQ_FILIAL  = '"+xFilial("SCQ")+"'"
					cQuery += "   AND SCP.CP_PRODUTO = SCQ.CQ_PRODUTO "
					cQuery += "   AND SCP.CP_LOCAL   = SCQ.CQ_LOCAL   "
					cQuery += "   AND SCP.CP_NUM     = SCQ.CQ_NUM     "
					cQuery += "   AND SCP.CP_ITEM    = SCQ.CQ_ITEM    "
					//cQuery += "   AND SCP.CP_NUMSC   = '"+SC1->C1_NUM+"'"
					//cQuery += "   AND SCP.CP_ITSC    = '"+SC1->C1_ITEM+"'"
					cQuery += " 	AND DHN.DHN_FILIAL = '" + xFilial("DHN") + "' "
					cQuery += " 	AND DHN.D_E_L_E_T_= ' ' "
					cQuery += " 	AND DHN.DHN_TIPO = '1' "
					cQuery += " 	AND DHN.DHN_DOCDES = '" + SC1->C1_NUM + "' "
					cQuery += " 	AND DHN.DHN_ITDES = '" + SC1->C1_ITEM + "' "
					cQuery += " 	AND DHN.DHN_DOCORI = SCQ.CQ_NUM "
					cQuery += " 	AND DHN.DHN_ITORI = SCQ.CQ_ITEM "
					cQuery += "   AND SCQ.CQ_QUANT   > SCQ.CQ_QTDISP "
					cQuery += "   AND SCP.CP_STATUS  <> 'E' "
					cQuery += "   AND SCP.D_E_L_E_T_ = ' '  "
					cQuery += "   AND SCQ.D_E_L_E_T_ = ' '  "
					cQuery += " ORDER BY SCP.CP_FILIAL, SCP.CP_PRODUTO, SCP.CP_NUM, SCP.CP_ITEM "
					
					cQuery := ChangeQuery(cQuery)				
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTOP)
					
					aEval(SCP->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTOP,x[1],x[2],x[3],x[4]),Nil)})
					aEval(SCQ->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTOP,x[1],x[2],x[3],x[4]),Nil)})
					
					Do While !(cAliasTOP)->(Eof())
						SCP->(MsGoto((cAliasTOP)->SCPRECNO))
						RecLock("SCP",.F.)
						If SC1->C1_SOLICIT == "SA AGLUTINADA            "
					   		SCP->CP_QUANT -= ((cAliasTOP)->CP_QUANT - (cAliasTOP)->CQ_QTDISP)                      
						Else 
						  	SCP->CP_QUANT -= (SC1->C1_QTDORIG - SC1->C1_QUJE)
						EndIf
						If !Empty((cAliasTOP)->CP_QTSEGUM)
							SCP->CP_QTSEGUM	-= (cAliasTOP)->CP_QTSEGUM-ConvUM((cAliasTOP)->CP_PRODUTO,(cAliasTOP)->CQ_QTDISP,0,2)
						EndIf   
						
						// Verifica se encerra a Pre-Requisicao
						If SCP->CP_QUANT == SCP->CP_QUJE
							Replace CP_STATUS  with 'E'
							Replace CP_PREREQU with 'S'
						EndIf
						SCP->(MsUnLock())
						
						// Acerto na tabela SCQ (Eliminar Residuo)
						cSeekSCQ := (cAliasTOP)->CP_FILIAL+(cAliasTOP)->CP_PRODUTO+(cAliasTOP)->CP_NUM+(cAliasTOP)->CP_ITEM
		    			Do While !(cAliasTOP)->(Eof()) .And. cSeekSCQ == (cAliasTOP)->CP_FILIAL+(cAliasTOP)->CP_PRODUTO+(cAliasTOP)->CP_NUM+(cAliasTOP)->CP_ITEM
				   			SCQ->(MsGoto((cAliasTOP)->SCQRECNO))
							If Empty((cAliasTOP)->CQ_NUMREQ) .And. SCP->CP_STATUS == "E"
								RecLock("SCQ",.F.)
								SCQ->(dbDelete())
								SCQ->(MsUnLock())
							Else    
								RecLock("SCQ",.F.)
								If SC1->C1_SOLICIT == "SA AGLUTINADA            "
					   				SCQ->CQ_QUANT  -= ((cAliasTOP)->CQ_QUANT - (cAliasTOP)->CQ_QTDISP)
								Else 
									SCQ->CQ_QUANT  -= (SC1->C1_QTDORIG - SC1->C1_QUJE)
								EndIf

								If !Empty((cAliasTOP)->CQ_QTSEGUM)
									SCQ->CQ_QTSEGUM	-= (cAliasTOP)->CQ_QTSEGUM-ConvUM((cAliasTOP)->CQ_PRODUTO,(cAliasTOP)->CQ_QTDISP,0,2)
								EndIf
								SCQ->(MsUnLock()) 
							EndIf
							dbSelectArea(cAliasTop)
							dbSkip()
						EndDo										
					EndDo          	
					(cAliasTOP)->(dbCloseArea())  
      			EndIf
	
                    If !lQuery
	                    //cAliasDBF := CriaTrab(,.F.)
			
						//dbSelectArea("SCP")
						//IndRegua("SCP",cAliasDBF ,"CP_FILIAL+CP_NUMSC+SCP->CP_ITSC")	
						//nIndice :=RetIndex("SCP")+1 

						//dbSetorder(nIndice)
							
						//dbSeek(xFilial("SCP")+SC1->C1_NUM+SC1->C1_ITEM,.F.)
						
						aPosDhn := COMPosDHN({3,{'1',xFilial("DHN"),SC1->C1_NUM,SC1->C1_ITEM}})
						
						//Do While !SCP->(Eof())	.And. SCP->CP_NUMSC == SC1->C1_NUM .And. SCP->CP_ITSC == SC1->C1_ITEM
						If aPosDhn[1]
						
							SCP->(DbSetOrder(1))
							If SCP->(DbSeek(xFilial("SCP") + AllTrim((aPosDhn[2])->(DHN_DOCORI + DHN_ITORI))))
						
								Do While !(aPosDhn[2])->(Eof()) .And. AllTrim((aPosDhn[2])->(DHN_DOCDES + DHN_ITDES)) == AllTrim(SC1->(C1_NUM + C1_ITEM)) 
								
									dbSelectArea("SCQ")
									dbSetOrder(1)
									
									//If dbSeek(xFilial("SCQ")+SCP->CP_NUM+SCP->CP_ITEM)
									If SCQ->(DbSeek(xFilial("SCQ") + AllTrim((aPosDhn[2])->(DHN_DOCORI + DHN_ITORI))))
										if (SCP->CP_PRODUTO == SCQ->CQ_PRODUTO .And. SCP->CP_LOCAL == SCQ->CQ_LOCAL .And. SCQ->CQ_QUANT > SCQ->CQ_QTDISP .And. SCP->CP_STATUS <> 'E')
											RecLock("SCP",.F.)
											If SC1->C1_SOLICIT == "SA AGLUTINADA            "
								  				SCP->CP_QUANT -= (SCP->CP_QUANT - SCQ->CQ_QTDISP)                      
											Else 
										  		SCP->CP_QUANT -= (SC1->C1_QTDORIG - SC1->C1_QUJE)
											EndIf  
			
											If !Empty(SCP->CP_QTSEGUM)
												SCP->CP_QTSEGUM	-= SCP->CP_QTSEGUM-ConvUM(SCP->CP_PRODUTO,SCQ->CQ_QTDISP,0,2)
											EndIf 
										
											If SCP->CP_QUANT == SCP->CP_QUJE
												Replace CP_STATUS  with 'E'
												Replace CP_PREREQU with 'S'
											EndIf 
											SCP->(MsUnLock())  
								
											Do While !SCQ->(Eof()) .And. SCP->CP_FILIAL==SCQ->CQ_FILIAL .And. SCP->CP_PRODUTO==SCQ->CQ_PRODUTO .And. SCP->CP_NUM== SCQ->CQ_NUM .And. SCP->CP_ITEM==SCQ->CQ_ITEM
												If Empty(SCQ->CQ_NUMREQ) .And. SCP->CP_STATUS == "E"
													RecLock("SCQ",.F.)
													SCQ->(dbDelete())
													SCQ->(MsUnLock())
												Else    
													RecLock("SCQ",.F.)
													If SC1->C1_SOLICIT == "SA AGLUTINADA            "
														SCQ->CQ_QUANT  -= (SCQ->CQ_QUANT - SCQ->CQ_QTDISP)
													Else 
														SCQ->CQ_QUANT  -= (SC1->C1_QTDORIG - SC1->C1_QUJE)
													EndIf   
													
													If !Empty(SCQ->CQ_QTSEGUM)
														SCQ->CQ_QTSEGUM	-= SCQ->CQ_QTSEGUM-ConvUM(SCQ->CQ_PRODUTO,SCQ->CQ_QTDISP,0,2)
													EndIf
												EndIf
								
												SCQ->(MsUnLock()) 	
												dbSelectArea("SCQ")
												dbSkip()
											EndDo	
										EndIf
									EndIf
									//dbSelectArea("SCP") 		
									//dbSkip()
									(aPosDHN[2])->(dbSkip())
								EndDo
								(aPosDhn[2])->(DbCloseArea())
							EndIf
						EndIf	
                    EndIf	     
			End Transaction
		Endif
		
		//��������������������������������������������������������������Ŀ
		//� Ponto de entrada no final do processamento da eliminacao     �
		//����������������������������������������������������������������
		If lMT235AIR
			ExecBlock("MT235AIR",.F.,.F.,{If(Empty(cQuery),"SC1",(cAlias)),3})
    	EndIf
    	
	EndIf
	dbSelectArea(cAlias)
	dbSkip()
EndDo

dbSelectArea(cAlias)
If cUltSC1 != C1_NUM .and. !Empty(cUltSC1)				
	//Atualiza Al�ada da Solicita��o de Compras
    MA235ESC(cUltAlias,cUltSC1)
EndIf

If nNaoProc > 0  //" itens nao foram processados por estar em uso em outra estacao!"
	MsgInfo(Str(nNaoProc,4) + STR0009,STR0006)
EndIf

If !Empty(cQuery)
	dbSelectArea(cAlias)
	dbCloseArea()
EndIf
dbSelectArea("SC1")
PcoFinLan('000056')
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MA235PCCtb � Autor �Marcelo Custodio      � Data �13/02/2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Contabiliza a eliminacao de residuo do PC/AE               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA235                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function MA235PCCtb()
LOCAL aArea     := GetArea()

LOCAL cPadrao   := "658"
LOCAL cLoteCtb  := ""

LOCAL lDigita   := If(MV_PAR17==1,.T.,.F.)                           
LOCAL lPadrao   := .F.

LOCAL nHdlPrv   := 0
LOCAL nTotal    := 0
LOCAL aCtbDia	:= {}

LOCAL cArquivo := " "

lPadrao := VerPadrao(cPadrao)

//�������������������Ŀ
//�Lancamento Contabil�
//���������������������
If ( lPadrao .and. MV_PAR16 == 1 )
	
	//�����������������������������������������������������������Ŀ
	//� Verifica o numero do lote contabil                        �
	//�������������������������������������������������������������
	dbSelectArea("SX5")
	dbSetOrder(1)
	If MsSeek(xFilial()+"09COM")
		cLoteCtb := AllTrim(X5Descri())
	Else
		cLoteCtb := "COM "
	EndIf

	//�����������������������������������������������������������Ŀ
	//� Executa o execblock                                       �
	//�������������������������������������������������������������
	If At(UPPER("EXEC"),X5Descri()) > 0
		cLoteCtb := &(X5Descri())
	EndIf
	
	nHdlPrv := HeadProva(cLoteCtb,"MATA235",Substr(cUsuario,7,6),@cArquivo)
	nTotal  += DetProva(nHdlPrv,cPadrao,"MATA235",cLoteCtb)
	RodaProva(nHdlPrv,nTotal)
	
	//������������������������������Ŀ
	//�Envia para Lancamento Contabil�
	//��������������������������������
	If ( UsaSeqCor() ) 
		aCtbDia := {{"SC7",SC7->(RECNO()),SC7->C7_DIACTB,"C7_NODIA","C7_DIACTB"}}
	Else
	    aCtbDia := {}
	EndIF    
	cA100Incl(cArquivo,nHdlPrv,3,cLoteCtb,lDigita,.F.,,,,,,aCtbDia)
EndIf

RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA235PA     � Autor � TOTVS              � Data � 13.09.11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Indica ao Faturamento que o Pedido de Compra ou            ���
���			   Contrato de Parceria pode ser desvinculado de              ���
���			   Pagamento Antecipado para que o t�tulo possa ser baixado   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� aPar1 : N�meros dos PC/CP                                  ���
���Parametros� lPar2 : S� Valida exist�ncia de PA e MV_MA235PA            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MA235PA(aDocs,lSoValida)

Local aAreaSC3 	:= SC3->(GetArea())
Local aAreaSC7 	:= SC7->(GetArea())
Local aAreaFIE 	:= {}
Local nX		:= 0
Local lMarca	:= .T.
Local lReturn	:= .T.
Local nAvaliaPA	:= GetNewPar("MV_MA235PA",0)

DEFAULT lSoValida := .T.

If ValType(aDocs)<>"U" .And. Len(aDocs)>0
	For nX := 1 To Len(aDocs)
		If aDocs[nX][3]=='PC'
			If !lSoValida
				dbSelectArea("SC7")
				dbSetOrder(1)
				dbSeek(aDocs[nX][1]+aDocs[nX][2])
				Do While !Eof() .And. C7_NUM = aDocs[nX][2]
					If !SC7->C7_RESIDUO$'S' .And. !SC7->C7_ENCER$'E'
						lMarca := .F.
					EndIf
					dbskip()
				Enddo
			EndIf
			If lMarca
				aAreaFIE := FIE->(GetArea())
				dbSelectArea("FIE")
				dbSetOrder(1)
				If dbSeek(aDocs[nX][1]+"P"+aDocs[nX][2])
					While (aDocs[nX][1]+"P"+aDocs[nX][2]) == FIE_FILIAL+FIE_CART+FIE_PEDIDO
						If lSoValida	//Valida exist�ncia de PA e MV_MA235PA (1a chamada da fun��o)
							If FIE->FIE_SALDO > 0
								If lReturn .and. nAvaliaPA == 1 //Avalia e Faculta ao Usu�rio
									If !ApMsgYesNo(STR0015 + "'" + aDocs[nX][2] +"'" + STR0016,STR0017)
										lReturn		:= .F.
									EndIf
								ElseIf lReturn .and. nAvaliaPA == 2 //Avalia e N�O Elimina Res�duos
									lReturn		:= .F.
									ApMsgAlert(STR0018 + "'"+aDocs[nX][2] + "'" + STR0019)
								EndIf
							EndIf
						Else			//Remove v�nculo (2a chamada da fun��o)
							RecLock( "FIE" )
							FIE->(DbDelete())
							FIE->(MsUnLock())
						EndIf
						FIE->(dbSkip())
					End
				EndIf
				RestArea(aAreaFIE)
			EndIf
		EndIf
	Next nX
EndIf

RestArea(aAreaSC7)
RestArea(aAreaSC3)
Return lReturn

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA235ElRes�Autor  � Andre Anjos		 � Data �  11/01/13   ���
�������������������������������������������������������������������������͹��
���Descricao � Funcao que processa a eliminacao de residuos e seus        ���
���          � relacionados.                                              ���
�������������������������������������������������������������������������͹��
���Uso       � Compras                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MA235ElRes(nNaoProc,aRefImp,aRecSC7)
Local nPosRef1  := 0
Local nPosRef2  := 0
Local nTotItem  := 0
Local nX        := 0
Local cAliasTOP := "SCQ"
Local cQuery	:= ""
Local cTipoSC7  := ""
Local cEntrega  := ""
Local lQuery    := .F.
Local lPrcPreReq:= .F.
Local lFilEnt   := SuperGetMv("MV_PCFILEN")
Local lGCTRes   := (SuperGetMv("MV_CNRESID",.F.,"N") == "S")
Local lAlcSolCtb:= SuperGetMv("MV_APRPCEC",.F.,.F.)
Local aAreaSCH
Local aProds	  := {}
Local aDados	  := {}
Local aNota	  := {}
Local lLockSC7
Local lLockSB2
Local lLockSCR	:= .T.

Default nNaoProc	:= 0
Default aRecSC7	:= {} 

// Efetua a validacao dos parametros
IF Valtype( MV_PAR16 ) == 'C'
	MV_PAR16 := 0
Endif
IF Valtype( MV_PAR17 ) == 'C'
	MV_PAR17 := 0
Endif

If aRefImp == NIL
	aRefImp := {} // Inicializa a variavel
	SX3->(dbSetOrder(1))
	SX3->(MsSeek("SC7"))
	While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == "SC7"
		nPosRef1 := At("MAFISREF(",Upper(SX3->X3_VALID))
		If nPosRef1 > 0
			nPosRef1 += 10
			nPosRef2 := At(",",SubStr(SX3->X3_VALID,nPosRef1))-2
			aAdd(aRefImp,{"SC7",SX3->X3_CAMPO,SubStr(SX3->X3_VALID,nPosRef1,nPosRef2)})
		EndIf
		SX3->(dbSkip())
	End
EndIf

If !lGCTRes 
	MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",aRefImp)
	MaFisIniLoad(1)
	For nX := 1 To Len(aRefImp)
		MaFisLoad(aRefImp[nX][3],FieldGet(FieldPos(aRefImp[nX][2])),1)
	Next nX
	MaFisEndLoad(1)
	MaFisAlt("IT_VALMERC",SC7->C7_TOTAL,1)
	nTotItem := MaFisRet(1,"IT_TOTAL")

	If SC7->C7_QUJE == 0
		nTotItem := MaFisRet(1,"IT_TOTAL")
	Else
		nTotItem := MaFisRet(1,"IT_TOTAL") / SC7->C7_QUANT    
		nTotItem := nTotItem * (SC7->C7_QUANT - SC7->C7_QUJE)         
	EndIf  
Else 
	//��������������������������������������������������������������Ŀ				
	//�Se eliminacao de residuo for originado do Gestao de Contratos,�
	//� sera considerado a Quant.Entregue no total.    				 �
       			//����������������������������������������������������������������			     
	If SC7->C7_QUJE == 0
		nTotItem := SC7->C7_TOTAL
	Else
		nTotItem := SC7->C7_TOTAL / SC7->C7_QUANT    
		nTotItem := nTotItem * (SC7->C7_QUANT - SC7->C7_QUJE)            
	EndIf  									

EndIF

MaFisEnd()

Begin Transaction
	cEntrega  := If(lFilEnt,SB2->(SC7->(xFilEnt(SC7->C7_FILENT))),xFilial("SB2"))
	If !SB2->(dbSeek(cEntrega+SC7->C7_PRODUTO+SC7->C7_LOCAL))
		CriaSb2( SC7->C7_PRODUTO,SC7->C7_LOCAL,cEntrega)
	Endif
	//�����������������������������������������������������������������������������������Ŀ
	//� A rotina a seguir garante o funcionamento correto na base historica dos clientes, �
	//� pois com a implementacao do parametro MV_AEAPROV que estende o controle de alcadas�
	//� para a AE, em 22/07/04 foi alterada a gravacao do tipo do doc para PC e AE afim   �
	//� de diferenciar o tipo de doc nos arquivos SC7 e SCR sem afetar o funcionamento ant�
	//�������������������������������������������������������������������������������������
	If SCR->(dbSeek(xFilial("SCR")+"PC"+SC7->C7_NUM))
		cTipoSC7 := "PC"
	ElseIf SCR->(dbSeek(xFilial("SCR")+"IP"+SC7->C7_NUM))
		cTipoSC7 := "IP"
	EndIf

	If SCR->( Eof() )
		If SCR->(dbSeek(xFilial("SCR")+"AE"+SC7->C7_NUM,.T.))
			cTipoSC7 := "AE"
		EndIf
	EndIF

	lLockSC7 	:= SC7->(SimpleLock())
	lLockSB2 	:= SB2->(SimpleLock())
	If xFilial("SCR")+cTipoSC7+SC7->C7_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SC7->C7_NUM))
		lLockSCR := SCR->(SimpleLock())
	EndIf

	If lLockSC7 .And. lLockSB2 .And. lLockSCR
		
		RecLock("SC7",.F.)
		Replace C7_RESIDUO with "S"
		Replace C7_ENCER with "E"
		
		AAdd(aRecSC7,SC7->(Recno()))

		If !lAlcSolCtb
			dbSelectArea("SCR")
			If xFilial("SCR")+cTipoSC7+SC7->C7_NUM == SCR->CR_FILIAL+SCR->CR_TIPO+Subs(SCR->CR_NUM,1,Len(SC7->C7_NUM))
				MaAlcDoc({SC7->C7_NUM,cTipoSC7,nTotItem,,,SC7->C7_APROV,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,SC7->C7_EMISSAO},SC7->C7_EMISSAO,5,,.T.)
			EndIf
		EndIf

		PcoDetLan('000056','02','MATA235')

		//Lan�amento no PCO - Eliminar Res�duo - Pedido de Compra - Rateio por CC		
		aAreaSCH := SCH->(GetArea())
		SCH->(DbSetOrder(2))
		If SCH->(DbSeek(xFilial("SCH") + SC7->(C7_NUM+C7_ITEM)))
			cQuebraSCH := SCH->(CH_FILIAL+CH_PEDIDO+CH_ITEMPD)
			While cQuebraSCH == SCH->(CH_FILIAL+CH_PEDIDO+CH_ITEMPD) 
				PcoDetLan('000056','04','MATA235')
				SCH->(DbSkip())	
			EndDo
		EndIf
		RestArea(aAreaSCH)
		
		RecLock("SB2",.F.)
		dbSelectArea("SF4")
   		dbSetOrder(1)
		If !SF4->F4_ESTOQUE == "N" //VERIFICAR SE O TES N�O ATUALIZA ESTOQUE, SE SIM, RETIRA DO ESTOQUE, SE NAO DEXA COMO ESTA
			GravaB2Pre("-",(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA),SC7->C7_TPOP,(SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)*(SC7->C7_QTSEGUM/SC7->C7_QUANT))
		Endif
		If SC7->C7_TIPO == 2
			lPrcPreReq := .T.
		EndIf    

		//���������������������������������Ŀ
		//�Elimina��o de Res�duos no SIGAGCT�
		//�����������������������������������
		If !Empty(SC7->C7_CONTRA) .And. lGCTRes
			GravaGCT(nTotItem,SC7->C7_QUJE,SC7->C7_MOEDA,SC7->C7_TXMOEDA,SC7->C7_EMISSAO,.T.)
		EndIf
		
		//���������������������������������Ŀ
		//�Elimina��o de Res�duos no SIGAGCP�
		//�����������������������������������
		If !Empty(SC7->C7_CODNE)
			Aadd(aProds,{'001',nTotItem})
			Aadd(aDados, SC7->C7_CODNE)
			Aadd(aDados, '1')
			Aadd(aDados, SC7->C7_NUM)
			Aadd(aDados, '1')
			Aadd(aDados, '2')
			Aadd(aDados, aProds)	
			Aadd(aDados, STR0001)
			Aadd(aNota, aDados)
			GCPGrHistNE(aNota,/*lDelCX2*/,/*__lHabil*/,/*oModelNE*/,/*oModeloMdlAct*/,/*lMostraHlp*/)
		EndIf
	Else
		nNaoProc++
	EndIf
	
	SC7->(MsUnLock())
	SB2->(MsUnLock())

	//��������������������������������������������������������������Ŀ
	//� Processa eliminacao de residuo da baixa da pre-requisicao    |
	//����������������������������������������������������������������			
	If lPrcPreReq
			lQuery    := .T.
			cAliasTOP := GetNextAlias()
			If Select(cAliasTOP) > 0 
		    	dbSelectArea(cAliasTOP)
		       	dbCloseArea()
			EndIf    
			
			cQuery := "	SELECT 	SCP.CP_FILIAL, SCP.CP_PRODUTO, SCP.CP_NUM,    SCP.CP_ITEM,    SCP.CP_QUANT, "
			cQuery += "     	SCQ.CQ_QTDISP, SCP.CP_QTSEGUM, SCQ.CQ_NUMREQ, SCQ.CQ_QTSEGUM, SCQ.CQ_QUANT, "
			cQuery += "     	SCQ.CQ_PRODUTO, SCP.R_E_C_N_O_ SCPRECNO, SCQ.R_E_C_N_O_ SCQRECNO "
			cQuery += "   FROM "+RetSqlName("SCP")+" SCP, "+RetSqlName("SCQ")+" SCQ "
			cQuery += "  WHERE SCP.CP_FILIAL  = '"+xFilial("SCP")+"'"
			cQuery += "    AND SCQ.CQ_FILIAL  = '"+xFilial("SCQ")+"'"
			cQuery += "	   AND SCP.CP_PRODUTO = SCQ.CQ_PRODUTO "
			cQuery += "    AND SCP.CP_LOCAL   = SCQ.CQ_LOCAL   " 
			cQuery += "	   AND SCP.CP_NUM     = SCQ.CQ_NUM     "
			cQuery += "	   AND SCP.CP_ITEM    = SCQ.CQ_ITEM    "
			cQuery += "    AND SCQ.CQ_NUMAE   = '"+SC7->C7_NUM+"'"
			cQuery += "    AND SCQ.CQ_ITAE    = '"+SC7->C7_ITEM+"'"
			cQuery += "    AND SCQ.CQ_QUANT   > SCQ.CQ_QTDISP  "
			cQuery += "	   AND SCP.CP_STATUS  <> 'E' "
 			cQuery += "    AND SCP.D_E_L_E_T_ = ' '  "
			cQuery += "    AND SCQ.D_E_L_E_T_ = ' '  "
			cQuery += " ORDER BY SCP.CP_FILIAL, SCP.CP_PRODUTO, SCP.CP_NUM, SCP.CP_ITEM   "
									
			cQuery := ChangeQuery(cQuery)				
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTOP)
			
			aEval(SCP->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTOP,x[1],x[2],x[3],x[4]),Nil)})
			aEval(SCQ->(dbStruct()), {|x| If(x[2] <> "C", TcSetField(cAliasTOP,x[1],x[2],x[3],x[4]),Nil)})
			
			Do While !(cAliasTOP)->(Eof())
				SCP->(MsGoto((cAliasTOP)->SCPRECNO))
				RecLock("SCP",.F.)
		   		SCP->CP_QUANT -= ((cAliasTOP)->CP_QUANT - (cAliasTOP)->CQ_QTDISP)                      

				If !Empty((cAliasTOP)->CP_QTSEGUM)
					SCP->CP_QTSEGUM	-= (cAliasTOP)->CP_QTSEGUM-ConvUM((cAliasTOP)->CP_PRODUTO,(cAliasTOP)->CQ_QTDISP,0,2)
				EndIf   
				SCP->(MsUnLock())
				
				// Verifica se encerra a Pre-Requisicao
				If SCP->CP_QUANT == SCP->CP_QUJE
					Replace CP_STATUS  with 'E'
					Replace CP_PREREQU with 'S'
					SCP->(MsUnLock())
				EndIf
				// Acerto na tabela SCQ (Eliminar Residuo)
				cSeekSCQ := (cAliasTOP)->CP_FILIAL+(cAliasTOP)->CP_PRODUTO+(cAliasTOP)->CP_NUM+(cAliasTOP)->CP_ITEM
    			Do While !(cAliasTOP)->(Eof()) .And. cSeekSCQ == (cAliasTOP)->CP_FILIAL+(cAliasTOP)->CP_PRODUTO+(cAliasTOP)->CP_NUM+(cAliasTOP)->CP_ITEM
		   			SCQ->(MsGoto((cAliasTOP)->SCQRECNO))
					If Empty((cAliasTOP)->CQ_NUMREQ) .And. SCP->CP_STATUS == "E"
						RecLock("SCQ",.F.)
						SCQ->(dbDelete())
						SCQ->(MsUnLock())
					Else    
						RecLock("SCQ",.F.)
						SCQ->CQ_QUANT  -= ((cAliasTOP)->CQ_QUANT - (cAliasTOP)->CQ_QTDISP)

						If !Empty((cAliasTOP)->CQ_QTSEGUM)
							SCQ->CQ_QTSEGUM	-= (cAliasTOP)->CQ_QTSEGUM-ConvUM((cAliasTOP)->CQ_PRODUTO,(cAliasTOP)->CQ_QTDISP,0,2)
						EndIf
						SCQ->(MsUnLock())
					EndIf
					dbSelectArea(cAliasTop)
					dbSkip()
				EndDo										
			EndDo          	
			(cAliasTOP)->(dbCloseArea())  


		If !lQuery
			dbSelectArea("SCQ")
			dbSetOrder(3)					
			dbSeek(xFilial("SCQ")+SC7->C7_NUM+SC7->C7_ITEM,.F.)
		
			dbSelectArea("SCP")
			dbSetOrder(2)		
			dbSeek(xFilial("SCP")+SCQ->CQ_PRODUTO+SCQ->CQ_NUM+SCQ->CQ_ITEM)
							
			Do While !SCP->(Eof())	.And. (SCP->CP_PRODUTO == SCQ->CQ_PRODUTO .And. SCP->CP_LOCAL == SCQ->CQ_LOCAL .And. SCQ->CQ_QUANT > SCQ->CQ_QTDISP .And. SCP->CP_STATUS <> 'E')
								
				RecLock("SCP",.F.)
				SCP->CP_QUANT -= (SCP->CP_QUANT - SCQ->CQ_QTDISP)                      
				
				If !Empty(SCP->CP_QTSEGUM)
					SCP->CP_QTSEGUM	-= SCP->CP_QTSEGUM-ConvUM(SCP->CP_PRODUTO,SCQ->CQ_QTDISP,0,2)
				EndIf 
					
				If SCP->CP_QUANT == SCP->CP_QUJE
					Replace CP_STATUS  with 'E'
					Replace CP_PREREQU with 'S'
				EndIf 
				SCP->(MsUnLock())  
								
				Do While !SCQ->(Eof()) .And. SCP->CP_FILIAL==SCQ->CQ_FILIAL .And. SCP->CP_PRODUTO==SCQ->CQ_PRODUTO .And. SCP->CP_NUM== SCQ->CQ_NUM .And. SCP->CP_ITEM==SCQ->CQ_ITEM
					If Empty(SCQ->CQ_NUMREQ) .And. SCP->CP_STATUS == "E"
						RecLock("SCQ",.F.)
						SCQ->(dbDelete())
						SCQ->(MsUnLock())
					Else    
						RecLock("SCQ",.F.)
						SCQ->CQ_QUANT  -= (SCQ->CQ_QUANT - SCQ->CQ_QTDISP)
							
						If !Empty(SCQ->CQ_QTSEGUM)
							SCQ->CQ_QTSEGUM	-= SCQ->CQ_QTSEGUM-ConvUM(SCQ->CQ_PRODUTO,SCQ->CQ_QTDISP,0,2)
						EndIf
					EndIf
								
					SCQ->(MsUnLock()) 	
					dbSelectArea("SCQ")
					SCP->(dbSkip())
				EndDo	
				dbSelectArea("SCP") 		
				dbSkip()
			EndDo		
		EndIf	     
	EndIf	

End Transaction

dbSelectArea("SC7")

//��������������������������������������������������������������Ŀ
//� Contabiliza eliminacao de residuo do pedido de compra        �
//����������������������������������������������������������������
MA235PCCtb()

//��������������������������������������������������������������Ŀ
//� Ponto de entrada MT235G1								     �
//����������������������������������������������������������������
If ExistBlock("MT235G1")
	ExecBlock("MT235G1",.F.,.F.)
EndIf
			
Return nNaoProc == 0

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA235ESC	   � Autor � TOTVS              � Data � 11.01.18 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Refaz al�adas da Solicita��o de Compras                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MA235ESC(cFilSC1, cNumSC1)

Local aAreaSC1 := SC1->(GetArea())
Local aColsSCX:= NIl
Local aHeadSCX:= NIL
Local cSeek
Local bWhile
Local lGeraSCR  := SuperGetMv("MV_APROVSC",.F.,.F.)
Local lAlcSolCtb:= SuperGetMv("MV_APRSCEC",.F.,.F.)

Private CA110NUM := cNumSC1

DbSelectArea("SC1")
DbSetOrder(1)
If SC1->(DbSeek(cFilSC1+CA110NUM))
	cSeek  := SC1->C1_FILIAL+SC1->C1_NUM
	bWhile := {|| SC1->(C1_FILIAL+C1_NUM) }
	If SCR->(dbSeek(xFilial('SCR',cFilSC1)+'SC'+CA110NUM))
		If lGeraSCR .Or. lAlcSolCtb 
			FillGetDados(4,"SC1",1,cSeek,bWhile,,,/*aYesFields*/,/*lOnlyYes*/,"",/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,/*bafterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,)
			If lAlcSolCtb // Gera al�ada por entidade cont�bil (DBM)
				//��������������������������������������������Ŀ
				//� Monta o Array contendo as registros do SCX �
				//����������������������������������������������
				A110AcoSCX(@aHeadSCX,@aColsSCX)
				MaEntCtb("SC1","SCX",CA110NUM,"SC",aHeader,aCols,aHeadSCX,aColsSCX,2,dDataBase)
			Elseif !Empty(SCR->CR_GRUPO) // Gera al�ada sem entidade cont�bil
				//Exclui controle de al�ada existente
				MaAlcDoc({CA110NUM,"SC",0,,,SCR->CR_GRUPO,,,,dDataBase},,3)
				 
				//Gera novo controle de al�ada
				MaAlcDoc({CA110NUM,"SC",0,,,SCR->CR_GRUPO,,,,dDataBase},,1)
				SCR->(dbSetOrder(1))
				If SCR->(dbSeek(xFilial('SCR')+'SC'+CA110NUM))
					a110Lib('B')
				Else
					a110Lib('L')
				Endif
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSC1)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MA235EPC	   � Autor � TOTVS              � Data � 11.01.18 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � ExecAuto MATA120 atualiza��o para atualiza��o de al�ada    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function MA235EPC(cFilSC7, cNumSC7)

Local aAreaSC7 := SC7->(GetArea())
Local aColsSCH:= {}
Local aHeadSCH:= {}
Local cSeek
Local bWhile
Local cChaveRat
Local lGeraSCR  := .T.
Local lAlcSolCtb:= SuperGetMv("MV_APRPCEC",.F.,.F.)

DbSelectArea("SC7")
DbSetOrder(1)
If SC7->(DbSeek(cFilSC7+cNumSC7))
	cSeek  := SC7->C7_FILIAL+SC7->C7_NUM
	bWhile := {|| SC7->(C7_FILIAL+C7_NUM) }
	If SCR->(dbSeek(xFilial('SCR',cFilSC7)+'PC'+cNumSC7));
		.OR. SCR->(dbSeek(xFilial('SCR',cFilSC7)+'IP'+cNumSC7))
		If lGeraSCR .Or. lAlcSolCtb
			FillGetDados(4,"SC7",1,cSeek,bWhile,,,/*aYesFields*/,/*lOnlyYes*/,"",/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,/*bafterCols*/,/*bBeforeCols*/,/*bAfterHeader*/,)
			If lAlcSolCtb .AND. SCR->CR_TIPO == "IP" // Gera al�ada por entidade cont�bil (DBM)
				//��������������������������������������������Ŀ
				//� Monta o Array contendo as registros do SCH �
				//����������������������������������������������
				cChaveRat := SC7->(C7_NUMSC+C7_ITEMSC)
				A120BuRtSC(cChaveRat,@aHeadSCH,@aColsSCH,.T.)
				MaEntCtb("SC7","SCH",cNumSC7,"IP",aHeader,aCols,aHeadSCH,aColsSCH,2,SC7->C7_EMISSAO)
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSC7)
	                
Return