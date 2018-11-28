#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH" 
              
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVIXA038   บAutor  ณIhorran Milholi     บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gera็ใo de solicita็ใo e pedidos de compra      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGACOM                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VIXA038(aParam,cFabric,cCurvaDe,cCurvaAte,nQdeDias,cGrupoDe,cGrupoAte)
                       
Local aErros 	:= {{},{}}
 
Private cMsgLog	:= ''
Private lProcPC	:= AllTrim(FunName())=='VIXA116'
Private dDataSol

Default aParam 	:= {}
Default cFabric 	:= ''
Default cCurvaDe	:= ''
Default cCurvaAte	:= ''
Default nQdeDias	:= 0
Default cGrupoDe	:= '    '
Default cGrupoAte 	:= 'ZZZZ'

//Inicia ambiente para schedule
If !lProcPC
	VA038IniAmb()	
	//Atualiza data para gera็ใo dos pedidos   
	dDataSol:= iif(substr(time(),1,4) > "12:00",dDatabase+1,dDatabase)
Else
	dDataSol:= dDatabase
EndIf

AddMsgLog('Eliminando resํduos em aberto do fabricante.')

//Rotina para eliminar residuo de solicita็๕es em aberto
VA038ResSol(cFabric, cCurvaDe, cCurvaAte,cGrupoDe,cGrupoAte)

AddMsgLog('Gerando solicita็๕es de compras.')

//Rotina para gera็ใo das solicita็๕es de compra
VA038GerSol(cFabric, cCurvaDe, cCurvaAte,nQdeDias,cGrupoDe,cGrupoAte)

AddMsgLog('Gerando pedido de compras.')

//Rotina para gera็ใo dos pedidos de compra
VA038GerPed(@aErros, cFabric, cCurvaDe, cCurvaAte, nQdeDias,cGrupoDe,cGrupoAte)

AddMsgLog('Analisando os produtos sem CRU.')

//Rotina para analisar os produtos CRU que estใo sem pedido
VA038CRUSemPC(@aErros, cFabric, cCurvaDe, cCurvaAte,cGrupoDe,cGrupoAte)

AddMsgLog('Analisando filtro de pedido minimo.')

//Rotina para analisar se tiveram pedidos com valor minimo nใo atendido
VA038PedMin(@aErros, cFabric, cCurvaDe, cCurvaAte,cGrupoDe,cGrupoAte)

//Fun็ใo para esperar finalizar os pedidos para o email sair corretamente
While !VA038FimProcPed()
     
	//Espera 30 segundos para tentar novamente
	Sleep(30000)
	
EndDo

//Chama rotina de envio de emails
VA038Log(@aErros)

If !lProcPC
	VA038Email(aErros[2])
Endif

//Reseta ambiente para schedule
If !lProcPC
	VA038ResiAmb()
EndIf

Return cMsgLog

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAddMsgLog  ณHenrique  บ Data ณ  26/10/15          บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de montagem da mensagem de retorno                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function AddMsgLog(cMensagem)

	If lProcPC .and. AllTrim(cMensagem) != ''
		cMsgLog += Time()+ ' - '+AllTrim(cMensagem)+CHR(13)+CHR(10)
	EndIf
	 
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038CRUSemPCบAutor  ณIhorran Milholi  บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para analisar os produtos CRU que estใo sem pedido   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             
Static Function VA038CRUSemPC(aErros, cFabric, cCurvaDe, cCurvaAte,cGrupoDe,cGrupoAte)

Local cAlias 	:= GetNextAlias()
Local cPasta	:= "\COMPRAS\" 
Local oExcel	:= FWMSEXCEL():New()

MakeDir(cPasta)

BeginSQL Alias cAlias

SELECT	SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_PRODUTO, SB1.B1_DESC, SB1.B1_FABRIC, SB1.B1_PROC, SC1.C1_QUANT, SB1.B1_CUSTD, SB1.B1_GRUPCOM

FROM	%table:SC1% SC1

		INNER JOIN %table:SB1% SB1 ON	SB1.B1_FILIAL	= %xFilial:SB1%
									AND SB1.B1_COD		= SC1.C1_PRODUTO
									AND SB1.B1_GRUPO	BETWEEN %Exp:cGrupoDe% AND %Exp:cGrupoAte%
									AND SB1.%NotDel%
									
		INNER JOIN %table:SZP% SZP ON	SZP.ZP_FILIAL	= %xFilial:SZP%	
									AND SZP.ZP_PRODUTO	= SC1.C1_PRODUTO
									AND SZP.%NotDel%
																
		INNER JOIN %table:SZ1% SZ1 ON	SZ1.Z1_FILIAL	= %xFilial:SZ1%	
									AND SZ1.Z1_FABRIC	= SB1.B1_FABRIC	   
									AND SZ1.%NotDel%
									
		LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = C1_PRODUTO
																		
WHERE	SC1.C1_FILIAL	= %xFilial:SC1%
	AND SC1.C1_PEDIDO	= %Exp:''%	
	AND SC1.C1_RESIDUO	= %Exp:''%	
	AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0%
	AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
	AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
	AND SB1.B1_PROC 	IN (%Exp:''%,%Exp:'999998'%,%Exp:'999999'%)
	AND SC1.%NotDel%
	
ORDER BY SC1.C1_NUM, SC1.C1_ITEM

EndSql
              
//Nome do arquivo            
cFile := cPasta+"CRUSEMPC"+cEmpAnt+cFilAnt+dtos(dDatabase)+".XML"

oExcel:SetFontSize(9)
oExcel:AddworkSheet("Produtos")

oExcel:AddTable ("Produtos","Produtos sem CRU")

oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("C1_NUM"),1,1)
oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("C1_ITEM"),1,1)
oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("C1_PRODUTO"),1,1)
oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_DESC"),1,1)
oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_FABRIC"),1,1)
oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_PROC"),1,1)
oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("C1_QUANT"),3,2)
oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_CUSTD"),3,2)
oExcel:AddColumn("Produtos","Produtos sem CRU",RetTitle("B1_GRUPCOM"),1,1)

(cAlias)->(dbGoTop())     
If (cAlias)->(Eof()) 
	
	AddMsgLog('Nใo hแ produtos CRU sem pedidos.')
	
	Return
	
EndIf    
     
(cAlias)->(dbGoTop())
While (cAlias)->(!Eof())   

	oExcel:AddRow("Produtos","Produtos sem CRU",{	(cAlias)->C1_NUM,;
													(cAlias)->C1_ITEM,;
													(cAlias)->C1_PRODUTO,;
													(cAlias)->B1_DESC,;
													(cAlias)->B1_FABRIC,;
													(cAlias)->B1_PROC,;
													(cAlias)->C1_QUANT,;
													(cAlias)->B1_CUSTD,;
													POSICIONE("SAJ",1,xFilial("SAJ")+(cAlias)->B1_GRUPCOM,"AJ_US2NAME")})

	(cAlias)->(dbSkip())
	
EndDo
 
oExcel:Activate()
oExcel:GetXMLFile(cFile)
				
FreeObj(oExcel)

aAdd(aErros[2],cFile)

Return                                                                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038ResSolบAutor  ณIhorran Milholi    บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para eliminar residuo de solicita็oe em aberto       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             
Static Function VA038ResSol(cFabric, cCurvaDe, cCurvaAte,cGrupoDe,cGrupoAte)

Local cAliasSol 	:= GetNextAlias()
Local cPedido		:= ''

BeginSQL Alias cAliasSol

SELECT	SC1.R_E_C_N_O_ SC1RECNO

FROM %table:SC1% SC1
JOIN %table:SB1% SB1 ON SB1.%NotDel% AND SB1.B1_FILIAL = %xFilial:SB1% AND B1_COD = C1_PRODUTO AND SB1.B1_GRUPO	BETWEEN %Exp:cGrupoDe% AND %Exp:cGrupoAte%
LEFT JOIN %table:SZ1% SZ1 ON SZ1.%NotDel% AND SZ1.Z1_FILIAL = %xFilial:SZ1% AND Z1_FABRIC = B1_FABRIC 
LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = C1_PRODUTO
WHERE	SC1.%NotDel%
	AND SC1.C1_FILIAL	= %xFilial:SC1%    
	AND SC1.C1_RESIDUO = %Exp:''%		
	//AND SC1.C1_EMISSAO	<> %Exp:dDataBase%
	AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0%
	AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
	AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
ORDER BY SC1.C1_NUM, SC1.C1_ITEM

EndSql
	
(cAliasSol)->(dbGoTop())
If (cAliasSol)->(Eof())
	AddMsgLog('Nใo hแ residuo a ser eliminado.')
EndIf

(cAliasSol)->(dbGoTop())
While (cAliasSol)->(!Eof())                            

	SC1->(dbSetOrder(1))
	SC1->(dbGoto((cAliasSol)->SC1RECNO))
                                      
	If SC1->C1_QUANT <> SC1->C1_QUJE .and. SC1->C1_QUJE > 0
			       
		SB2->(dbSetOrder(1))
		If SB2->(dbSeek(xFilial("SB2")+SC1->C1_PRODUTO+SC1->C1_LOCAL))
			RecLock("SB2",.F.)
			SB2->B2_SALPEDI -= (SC1->C1_QUANT-SC1->C1_QUJE)
			SB2->B2_SALPED2 -= (SC1->C1_QTSEGUM-SC1->C1_QUJE2)
		    SB2->(msUnLock())
		EndIf                               
		
		RecLock("SC1",.F.)
		SC1->C1_QUANT	:= SC1->C1_QUJE
		SC1->C1_QTSEGUM	:= SC1->C1_QUJE2
    	SC1->(msUnLock())
    	
	Else
		
		SB2->(dbSetOrder(1))
		If SB2->(dbSeek(xFilial("SB2")+SC1->C1_PRODUTO+SC1->C1_LOCAL))
			RecLock("SB2",.F.)
			SB2->B2_SALPEDI -= SC1->C1_QUANT          
			SB2->B2_SALPED2 -= SC1->C1_QTSEGUM
			SB2->(msUnLock())
		EndIf                               
	    
		RecLock("SC1",.F.)
		SC1->(dbDelete())
  		SC1->(msUnLock())

	EndIf
	
	If AllTrim(cPedido) != SC1->C1_NUM
		AddMsgLog('Residuo eliminado. Pedido '+SC1->C1_NUM+ ' Produto: '+SC1->C1_PRODUTO)
		cPedido := SC1->C1_NUM
	EndIf
		
	(cAliasSol)->(dbSkip())
	
EndDo
(cAliasSol)->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038GerPedบAutor  ณIhorran Milholi    บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gera็ใo de pedidos de compra                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VA038GerPed(aErros, cFabric, cCurvaDe, cCurvaAte, nQdeDias,cGrupoDe,cGrupoAte)
                
Local cAliasSol := GetNextAlias()

Local aAux		:= {}     
Local aCab		:= {}
Local aItensPed	:= {}
Local cFornece	:= ""  
Local cRet		:= ''
Local cMsgErro	:= ''
Local dPrzEntr
Local nVlrMinPed:= iif(!lProcPC,150,0)
Local nVlrPed	:= 0
Local i

BeginSQL Alias cAliasSol

SELECT	SB1.B1_PROC, SB1.B1_FABRIC, SB1.B1_CUSTD, SB1.B1_IPI, SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_PRODUTO, (SC1.C1_QUANT-SC1.C1_QUJE) C1_QUANT, SC1.C1_LOCAL, SC1.C1_DATPRF
FROM	%table:SC1% SC1
	JOIN %table:SB1% SB1 ON SB1.B1_FILIAL	= %xFilial:SB1% AND SB1.%NotDel% AND SC1.C1_PRODUTO	= SB1.B1_COD AND SB1.B1_GRUPO	BETWEEN %Exp:cGrupoDe% AND %Exp:cGrupoAte%	
	LEFT JOIN %table:SZ1% SZ1 ON SZ1.%NotDel% AND SZ1.Z1_FILIAL = %xFilial:SZ1% AND Z1_FABRIC = B1_FABRIC
	LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = B1_COD		
WHERE	SC1.%NotDel%
	AND SC1.C1_FILIAL	= %xFilial:SC1%
	AND SC1.C1_PEDIDO	= %Exp:''%
	AND SC1.C1_RESIDUO = %Exp:''%	
	AND SB1.B1_YCOMPRA IN ('1', ' ')
	AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
	AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
	AND SB1.B1_PROC NOT IN (%Exp:''%,%Exp:'999998'%,%Exp:'999999'%)
	AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0% 
	
ORDER BY SB1.B1_PROC, SB1.B1_FABRIC, SB1.B1_COD, SC1.C1_NUM, SC1.C1_ITEM

EndSql
                            
(cAliasSol)->(dbGoTop())

If (cAliasSol)->(Eof())    
	AddMsgLog('Nใo hแ pedidos de compras a serem gerados')
EndIf	

//Analisa as cota็๕es geradas para incluir os pedidos de compra                                                         
While (cAliasSol)->(!Eof())      

	aAux := {}
	
	If cFornece <> (cAliasSol)->B1_PROC
		dPrzEntr := MaioDtEntr((cAliasSol)->B1_PROC )		
	EndIf
		                                                                                                                    	 	                           
   	cFornece:= (cAliasSol)->B1_PROC
   	cFabric	:= (cAliasSol)->B1_FABRIC

	If (cAliasSol)->B1_CUSTD == 0
	
		cMsgErro := "Nใo foi possivel gerar um pedido de compra para o produto "+AllTrim((cAliasSol)->C1_PRODUTO)+" pois encontra-se com o custo standard zerado." 	
		aAdd(aErros[1],cMsgErro)	
		AddMsgLog(cMsgErro)
	
	Else
	   	
		aAdd(aAux,{"C7_PRODUTO"	,(cAliasSol)->C1_PRODUTO,Nil})
		aAdd(aAux,{"C7_QUANT"	,(cAliasSol)->C1_QUANT	,Nil})
		aAdd(aAux,{"C7_LOCAL"	,(cAliasSol)->C1_LOCAL	,Nil})	
		aAdd(aAux,{"C7_PRECO"	,(cAliasSol)->B1_CUSTD	,Nil})
		aAdd(aAux,{"C7_NUMSC"	,(cAliasSol)->C1_NUM	,Nil})	
		aAdd(aAux,{"C7_ITEMSC"	,(cAliasSol)->C1_ITEM	,Nil})  
		aAdd(aAux,{"C7_QTDSOL"	,(cAliasSol)->C1_QUANT	,Nil})
		aAdd(aAux,{"C7_DATPRF"	,dPrzEntr				,Nil})
		aAdd(aAux,{"C7_OPER"	,'01'					,Nil})
		
		If SC7->(FieldPos("C7_YQTDLIB")) > 0 .AND. nQdeDias == 0
			aAdd(aAux,{"C7_YQTDLIB",(cAliasSol)->C1_QUANT,Nil})	
		EndIf
		
		If SC7->(FieldPos("C7_YTIPCMP")) > 0
			If !lProcPC
				aAdd(aAux,{"C7_YTIPCMP",'OT',Nil})
			ElseIf nQdeDias > 0
				aAdd(aAux,{"C7_YTIPCMP",'CO',Nil})
			Else
				aAdd(aAux,{"C7_YTIPCMP",'CD',Nil})
			EndIf
		EndIf
		
		aAdd(aItensPed,aAux)
		
		//incrementa para analisar o valor total do pedido
		nVlrPed += ((cAliasSol)->B1_CUSTD*(cAliasSol)->C1_QUANT)
		nVlrPed += ((cAliasSol)->B1_CUSTD*(cAliasSol)->C1_QUANT)*((cAliasSol)->B1_IPI/100)
		  
	EndIf
	
	(cAliasSol)->(dbSkip())                                                                                                
	
	If ((cAliasSol)->(Eof()) .or. cFornece+cFabric <> (cAliasSol)->B1_PROC+(cAliasSol)->B1_FABRIC) .and. Len(aItensPed) > 0
		      
		aCab 		:= {}
		lMsErroAuto	:= .f.
		
		SA2->(dbSetOrder(1))
		If SA2->(dbSeek(xFilial("SA2")+cFornece))		
			    
			aAdd(aCab,{"C7_EMISSAO"	,dDataSol												,Nil})
			aAdd(aCab,{"C7_FORNECE"	,cFornece												,Nil})
			aAdd(aCab,{"C7_LOJA"	,SA2->A2_LOJA											,Nil})		
			aAdd(aCab,{"C7_COND"	,IIF(Empty(SA2->A2_COND),"001",SA2->A2_COND)			,Nil}) 
			aAdd(aCab,{"C7_CONTATO"	,Posicione("SZ1",2,xFilial("SZ1")+cFabric,"Z1_REPRES")	,Nil})	
			aAdd(aCab,{"C7_FILENT"	,cFilAnt												,Nil})
		
			//verifica se o pedido ้ maior que o valor minimo
			If nVlrPed > nVlrMinPed
		
				cRet := u_VA038JobPed({SM0->M0_CODIGO,SM0->M0_CODFIL,aCab,aItensPed,cFornece,cFabric,.F.},@aErros)
	       		
				If ValType(cRet) == 'C'
					AddMsgLog(cRet)
				EndIf		
					
			EndIf
			
		EndIf
		
		aItensPed 	:= {}
		aGrpComp	:= {}
		nVlrPed		:= 0
			
	EndIf
	
EndDo
(cAliasSol)->(dbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038PedMinบAutor  ณIhorran Milholi    บ Data ณ  23/01/16   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gera็ใo de pedidos de compra                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VA038PedMin(aErros, cFabric, cCurvaDe, cCurvaAte,cGrupoDe,cGrupoAte)
                
Local cAlias 	:= GetNextAlias()
Local cPasta	:= "\COMPRAS\" 
Local aCabec	:= {}
Local aDados	:= {}
Local cTXT		:= ""   
Local cCrLf		:= Chr(13) + Chr(10)
Local nHandle	:= 0
Local i 		:= 0
Local cChave	:= ''
Local cEmailOut	:= SuperGetMv("MV_Y038EML",.F.,"clayton@grupouniaosa.com.br; leonardo.teixeira@grupouniaosa.com.br")
Local cDestin	:= ""
Local oExcel

MakeDir(cPasta)

//Nome do arquivo            
cFile := cPasta+"PEDMIN"+cEmpAnt+cFilAnt+dtos(dDatabase)+".XML"

BeginSQL Alias cAlias

SELECT	SB1.B1_GRUPCOM, SB1.B1_PROC, SB1.B1_DESC, SB1.B1_FABRIC, SB1.B1_CUSTD, SC1.C1_NUM, SC1.C1_ITEM, SC1.C1_PRODUTO, (SC1.C1_QUANT-SC1.C1_QUJE) C1_QUANT, SC1.C1_LOCAL, SC1.C1_DATPRF

FROM	%table:SC1% SC1

		JOIN %table:SB1% SB1 ON SB1.B1_FILIAL	= %xFilial:SB1% AND SB1.%NotDel% AND SC1.C1_PRODUTO	= SB1.B1_COD AND SB1.B1_GRUPO	BETWEEN %Exp:cGrupoDe% AND %Exp:cGrupoAte%	
		
		LEFT JOIN %table:SZ1% SZ1 ON SZ1.%NotDel% AND SZ1.Z1_FILIAL = %xFilial:SZ1% AND Z1_FABRIC = B1_FABRIC
		
		LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = B1_COD
				
WHERE	SC1.%NotDel%
	AND SC1.C1_FILIAL	= %xFilial:SC1%
	AND SC1.C1_PEDIDO	= %Exp:''%
	AND SC1.C1_RESIDUO	= %Exp:''%	
	AND SB1.B1_YCOMPRA IN ('1', ' ')
	AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
	AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
	AND SB1.B1_PROC NOT IN (%Exp:''%,%Exp:'999998'%,%Exp:'999999'%)
	AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0% 
	
ORDER BY SB1.B1_GRUPCOM, SB1.B1_FABRIC, SB1.B1_PROC, SB1.B1_COD, SC1.C1_NUM, SC1.C1_ITEM

EndSql
                            
(cAlias)->(dbGoTop())     
If (cAlias)->(Eof()) 
	AddMsgLog('Nใo hแ produtos nใo gerados por nใo ter atingido o valor minimo do pedido.')
EndIf 

(cAlias)->(dbGoTop())
While (cAlias)->(!Eof())

	cChave 	:= (cAlias)->B1_GRUPCOM
	oExcel	:= FWMSEXCEL():New()
	
	oExcel:SetFontSize(9)
	oExcel:AddworkSheet("Produtos")
	
	oExcel:AddTable ("Produtos","Faturamento Minimo")
	
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("B1_FABRIC"),1,1)
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("B1_PROC"),1,1)
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C1_NUM"),1,1)
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C1_ITEM"),1,1)
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C1_PRODUTO"),1,1)
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("B1_DESC"),1,1)
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C1_QUANT"),3,2)
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("B1_CUSTD"),3,2)
	oExcel:AddColumn("Produtos","Faturamento Minimo",RetTitle("C7_TOTAL"),3,2)
		
	While (cAlias)->(!Eof()) .and. (cAlias)->B1_GRUPCOM == cChave
                         		
		oExcel:AddRow("Produtos","Faturamento Minimo",{	(cAlias)->B1_FABRIC,;
														(cAlias)->B1_PROC,;
														(cAlias)->C1_NUM,;
														(cAlias)->C1_ITEM,;
														(cAlias)->C1_PRODUTO,;
														(cAlias)->B1_DESC,;
														(cAlias)->C1_QUANT,;
														(cAlias)->B1_CUSTD,;
														(cAlias)->C1_QUANT*(cAlias)->B1_CUSTD})
		
		(cAlias)->(dbSkip())
	
	EndDo
	
	oExcel:Activate()
	oExcel:GetXMLFile(cFile)
				
	FreeObj(oExcel)
	
	//enviar email para o comprador
    SAJ->(Dbsetorder(1))
	If SAJ->(DbSeek(xFilial("SAJ")+cChave))
		
		While SAJ->(!Eof()) .and. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+cChave
		
			SY1->(Dbsetorder(3))
			If SY1->(DbSeek(xFilial("SY1")+SAJ->AJ_USER)) .and. !Empty(SY1->Y1_EMAIL)

				//Envia arquivo para o comprador
				u_EnvEmail(cEmailOut + "; " + AllTrim(SY1->Y1_EMAIL),Upper(AllTrim(SAJ->AJ_US2NAME))+" - Pedidos recusados por valor minimo de faturamento","Segue anexo arquivo(s) de log gerados pela rotina de gera็ใo de pedidos de compra do dia "+dToc(dDatabase)+" as "+Time(),cFile)
				
			EndIf

			SAJ->(dbSkip())
			
		EndDo			

	EndIf
	
EndDo

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038JobPedบAutor  ณIhorran Milholi    บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gera็ใo de pedidos de compra                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function VA038JobPed(aParametros,aErros)

Local cEmpJob	:= aParametros[1]
Local cFilJob	:= aParametros[2]
Local aCab 		:= aParametros[3]
Local aItensPed	:= aParametros[4]
Local cFornece	:= aParametros[5]
Local cFabric	:= aParametros[6]
Local lExecJob	:= aParametros[7]
Local cRetorno	:= ''

Private lMsErroAuto	:= .f.  

If lExecJob
	RPCCLEARENV()
	//RPCSETTYPE(3)
	RPCSETENV(cEmpJob,cFilJob,,,"COM")
EndIf

MsExecAuto({|x,y,z,w,k| Mata120(x,y,z,w,k)},1,aCab,aItensPed,3,.F.)

If lMsErroAuto

	DisarmTransaction()
	
	cRetorno := "Nใo foi possivel gerar um pedido de compra para o Fornecedor "+AllTrim(cFornece)+" e Fabricante "+AllTrim(cFabric)+" favor analisar o arquivo de log "
	
	aAdd(aErros[1],cRetorno+AllTrim(NomeAutoLog()))
			   	                  
	If aScan(aErros[2],"\SYSTEM\"+NomeAutoLog()) == 0
		aAdd(aErros[2],"\SYSTEM\"+NomeAutoLog())
	EndIf
	
Else
	// rotina que inserie as rotas no PC caso o Fornecedor tenha
	cRetorno += U_VIX259CR(SC7->C7_NUM, SC7->C7_FORNECE, SC7->C7_LOJA)	
	cRetorno += '  - Pedido "'+SC7->C7_NUM+'" gerado com sucesso. '				   	

EndIf

If lExecJob
	RPCCLEARENV()
EndIf

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038GerSolบAutor  ณIhorran Milholi    บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para gera็ใo de solicita็ใo                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VA038GerSol(cFabric, cCurvaDe, cCurvaAte, nQdeDias,cGrupoDe,cGrupoAte)

Local cArqTrb	:= GetNextAlias()
Local aParam	:= {}

Local cCadastro	:= OemToAnsi("Solicitao por Ponto de Pedido")
Local lMS170FOR := (ExistBlock("MS170FOR"))
Local lMT170SC1 := (ExistBlock("MT170SC1"))
Local lMT170FIM := (ExistBlock("MT170FIM"))
Local lMT170Sld := (ExistBlock("MT170SLD"))  

Local aQtdes    := {}
Local aFornepad := {}
Local aSolic    := {}

Local cFornece  := ""
Local cLoja     := ""
Local cNumSolic := ""
Local cItemSC	:= ""

Local nPrazo    := 0
Local nQuant    := 0
Local nSaldo    := 0
Local nNeces    := 0
Local nTamUser  := 15
Local nEstSeg   := 0
Local nAuxQuant := 0
Local nSavSaldo := 0
Local nSaldoMax := 0
Local ny        := 0
Local nSaldAux  := 0
Local nSaveSX8  := GetSX8Len()

Local lNumSC    := .T.
Local lEnvMail  := .T.
Local cPedido	  := ''

//Parametros para gera็ใo das solicita็๕es de compra   
               
aAdd(aParam,Replicate(" ",TamSX3("B1_COD")[1]))		//ณ mv_par01     // Produto de                  ณ
aAdd(aParam,Replicate("Z",TamSX3("B1_COD")[1]))		//ณ mv_par02     // Produto ate                 ณ 
aAdd(aParam,cGrupoDe)								//ณ mv_par03     // Grupo de                    ณ
aAdd(aParam,cGrupoAte)								//ณ mv_par04     // Grupo ate                   ณ
aAdd(aParam,"PA")									//ณ mv_par05     // Tipo de                     ณ
aAdd(aParam,"PA")									//ณ mv_par06     // Tipo ate                    ณ
aAdd(aParam,"01")									//ณ mv_par07     // Local de                    ณ
aAdd(aParam,"01")									//ณ mv_par08     // Local ate                   ณ
aAdd(aParam,1)										//ณ mv_par09     // Considera Necess Bruta 1 simณ  Pto Pedido
aAdd(aParam,1)										//ณ mv_par10     // Saldo Neg Considera    1 simณ  Lot.Economico
aAdd(aParam,GETMV("MV_ULMES"))						//ณ mv_par11     // Data limite p/ empenhos     ณ
aAdd(aParam,2)										//ณ mv_par12     // Cons.Qtd. De 3os.? Sim / Naoณ
aAdd(aParam,2)										//ณ mv_par13     // Cons.Qtd. Em 3os.? Sim / Naoณ
aAdd(aParam,1)										//ณ mv_par14     // Ao atingir Estoque Maximo ? ณ  1=Qtde. Original; 2=Ajusta Est. Max
aAdd(aParam,2)										//ณ mv_par15     // Quebra SC por Lote Econmico?ณ
aAdd(aParam,2)										//ณ mv_par16 Qtd.PV nao Liberado?" Subtr/Ignora ณ
aAdd(aParam,"01")									//ณ mv_par17     // Considera Saldo Armazem de  ณ
aAdd(aParam,"01")									//ณ mv_par18     // Considera Saldo Armazem ate ณ
aAdd(aParam,2)										//ณ mv_par19     // Seleciona Filiais? (Sim/Nao)ณ
aAdd(aParam,2)										//ณ mv_par20     // Gera SC por produto(Sim/Nao)ณ
aAdd(aParam,1)										//ณ mv_par21     // Considera Est. Seguranca ?  ณ (Sim / Nao)

//Chamada da fun็ใo
//MATA170(lOpcAuto,aParam)

//Necessario a retirada da chamada da rotina padrใo devido o tempo de processamento do mesmo              
BeginSql Alias cArqTrb

SELECT	SB1.R_E_C_N_O_ SB1RECNO 

FROM 	%table:SB1% SB1
		INNER JOIN	%table:SZ1% SZ1	ON	SZ1.Z1_FILIAL	= %xFilial:SZ1% 
									AND SZ1.Z1_ATACADO	IN (%Exp:'1'%,%Exp:'8'%)
									AND SZ1.Z1_FABRIC	= SB1.B1_FABRIC
									AND SZ1.%NotDel%
									
		LEFT JOIN %table:SBZ% SBZ ON SBZ.%NotDel% AND SBZ.BZ_FILIAL = %xFilial:SBZ% AND BZ_COD = B1_COD		
								
WHERE	SB1.B1_FILIAL	= %xFilial:SB1%
	AND	SB1.B1_COD		BETWEEN %Exp:aParam[1]% AND %Exp:aParam[2]%
	AND	SB1.B1_GRUPO	BETWEEN %Exp:aParam[3]% AND %Exp:aParam[4]%	
	AND	SB1.B1_TIPO		BETWEEN %Exp:aParam[5]% AND %Exp:aParam[6]%
	AND	SB1.B1_LOCPAD	BETWEEN %Exp:aParam[7]% AND %Exp:aParam[8]%
	AND	SB1.B1_CONTRAT	<> %Exp:'S'%
	AND SB1.B1_CONTRAT	<> %Exp:'A'%
	AND SB1.B1_TIPO		<> %Exp:'BN'%
	AND SB1.B1_YCOMPRA	IN ('1',' ')
	AND SB1.B1_MSBLQL	<> %Exp:'1'%
	AND (SZ1.Z1_COD = %Exp:cFabric% or %Exp:cFabric% = '')
	AND ((SBZ.BZ_YCURVA BETWEEN %Exp:cCurvaDe% AND %Exp:cCurvaAte%) or (%Exp:cCurvaDe% = '' and %Exp:cCurvaAte% = ''))
	AND SUBSTRING(SB1.B1_COD,1,3) <> %Exp:'MOD'%
	AND SB1.%NotDel% 
	
	AND NOT EXISTS(	SELECT	SC1.R_E_C_N_O_ SC1RECNO
					FROM	%table:SC1% SC1					
					WHERE	SC1.%NotDel%
						AND SC1.C1_FILIAL	= %xFilial:SC1%    
						AND SC1.C1_RESIDUO	= %Exp:''%		
						AND SC1.C1_EMISSAO	= %Exp:dDataBase%
						AND SC1.C1_QUJE 	= %Exp:0%
						AND SC1.C1_PRODUTO	= SB1.B1_COD)                            

ORDER BY SB1.B1_COD

EndSql

//Seta quantidade de registros par processamento
ProcRegua((cArqTrb)->(RecCount()))

SB1->(dbSetOrder(1))				
SB2->(dbSetOrder(1))
SG1->(dbSetOrder(1))

If (cArqTrb)->(Eof())
	AddMsgLog('Nใo hแ solici็ใo de compras a ser gerado.')
EndIf 

While (cArqTrb)->(!Eof())

	IncProc()
	                                              
	//Posiciona no produto
	SB1->(dbGoTo((cArqTrb)->SB1RECNO))
	       
	cFornece	:= Space(TamSx3("C1_FORNECE")[1])
	cLoja		:= Space(TamSx3("C1_LOJA")[1])
	aQtdes		:= {}		
	nSaldo		:= 0
	nQuant		:= 0  
	nNeces		:= 0
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Filtra se produto possui estrutura                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If SG1->(dbSeek(xFilial("SG1")+SB1->B1_COD))
		(cArqTrb)->(dbSkip())
		Loop
	EndIf
			
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Filtra se produto e sub-produto e deve ser alimentado via producao ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If FindFunction("IsNegEstr") .And. IsNegEstr(SB1->B1_COD)[1]
		(cArqTrb)->(dbSkip())
		Loop
	EndIf     
	                                                            
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Calcula o saldo atual de todos os almoxarifados ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	SB2->( dbSeek( xFilial("SB2")+SB1->B1_COD , .T. ))
	
	While SB2->(!Eof()) .And. SB2->B2_FILIAL+SB2->B2_COD == xFilial("SB2")+SB1->B1_COD
	
		If SB2->B2_LOCAL < aParam[17] .Or. SB2->B2_LOCAL > aParam[18]
			SB2->(dbSkip())
			Loop             
		EndIf                                                                                 
		
		nSaldo += (SaldoSB2(NIL,NIL,If(Empty(aParam[11]),dDataBase,aParam[11]),aParam[12]==1,aParam[13]==1)+SB2->B2_SALPEDI+SB2->B2_QACLASS)
		
		If aParam[16] == 1
			nSaldo -= SB2->B2_QPEDVEN
		EndIf              
		
		If lMT170Sld
			nSaldAux := ExecBlock("MT170SLD",.F.,.F.,{nSaldo,SB2->B2_COD,SB2->B2_LOCAL})
			If ValType(nSaldAux) == 'N'
				nSaldo := nSaldAux
			EndIf
		Endif
		
		SB2->(dbSkip())                                              
		
	EndDo
	
	nSaldoMax := A711Sb1EstMax(SB1->B1_COD)
	nSavSaldo := nSaldo
	
	If aParam[21] == 1
		nEstSeg	:= CalcEstSeg(RetFldProd(SB1->B1_COD,"B1_ESTFOR","SB1"),"SB1")
		
		//========================================================================
		//Para alguns produtos, a fun็ใo CalcEstSeg estแ alterando a posi็ใo da 
		//tabela SB1, foi adicionado o c๓digo abaixo para contornar este problema
		//========================================================================
		If SB1->(Recno()) <> (cArqTrb)->SB1RECNO
			SB1->(dbGoTo((cArqTrb)->SB1RECNO))
			nEstSeg := RetFldProd(SB1->B1_COD,"B1_ESTSEG","SB1")
		EndIf 
		
		nSaldo 	-= nEstSeg
	EndIf

	nAuxQuant := Execblock("MS170QTD",.F.,.F.,{nQuant, {'DIAS', nQdeDias}})
	If ValType(nAuxQuant) == "N"
		nQuant := nAuxQuant
		//-- Ajuste efetuado para compatibilizar a quantidade retorna pelo P.E
		aQtdes := {nQuant}
	EndIf
		
	If nQuant > 0
	
		For nY :=1 to Len(aQtdes)

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Efetua checagem do estoque maximo           ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If nSaldoMax # 0 .And. aParam[14] == 2 .And. ((QtdComp(nSaldo)+QtdComp(aQtdes[ny])) > QtdComp(nSaldoMax))
				aQtdes[ny] := Max(0,QtdComp(nSaldoMax)-QtdComp(nSaldo))
			EndIf
	
			Begin Transaction

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Pega o prazo de entrega do material         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nPrazo := CalcPrazo(SB1->B1_COD,aQtdes[nY])

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGera o numero da solicitacao de compras conforme o mv_par20ณ
			//ณ"Gera SC por Produto" se mv_par20 == 1 Sim, sera gerada umaณ
			//ณSC para cada produto processado pela rotina, porem se      ณ
			//ณmv_par20 = 2 Nao, sera gerada uma SC para todos os produtosณ
			//ณprocessados pela rotina.                                   ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lNumSC
			
				cNumSolic := GetNumSC1(.T.)
			    cItemSC   := StrZero(1,Len(SC1->C1_ITEM))

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Inicializa a gravacao dos lancamentos do SIGAPCO          ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				PcoIniLan("000051")

				If aParam[20] == 2  
                	lNumSC := .F.
				EndIf
				
				lEnvMail := .T.
			
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ PDE para gravaฦo de fornecedor na solicitaฦo de compra  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lMS170FOR
				aFornepad := Execblock("MS170FOR",.f.,.f.)
				If ValType(aFornepad) == "A"
					cFornece := aFornepad[1]
					cLoja    := aFornepad[2]
				EndIf
			EndiF
			
			RecLock("SC1",.T.)
			SC1->C1_FILIAL  := xFilial("SC1")
			SC1->C1_FILENT  := xFilEnt(C1_FILIAL)
			SC1->C1_NUM     := cNumSolic
			SC1->C1_ITEM    := cItemSC
			SC1->C1_EMISSAO := dDataSol
			SC1->C1_PRODUTO := SB1->B1_COD
			SC1->C1_LOCAL   := RetFldProd(SB1->B1_COD,"B1_LOCPAD","SB1")
			SC1->C1_UM      := SB1->B1_UM
			SC1->C1_SEGUM   := SB1->B1_SEGUM
			SC1->C1_DESCRI  := SB1->B1_DESC
			SC1->C1_QUANT   := aQtdes[nY]
			SC1->C1_CONTA   := SB1->B1_CONTA
			SC1->C1_CC      := SB1->B1_CC
			SC1->C1_ITEMCTA := SB1->B1_ITEMCC
			SC1->C1_CLVL    := SB1->B1_CLVL
			SC1->C1_QTSEGUM := ConvUm(SB1->B1_COD,aQtdes[ny],0,2)
			SC1->C1_SOLICIT := Substr(cUsuario,7,nTamUser)
			SC1->C1_DATPRF  := SomaPrazo(dDataSol,nPrazo)
			SC1->C1_OBS     := cCadastro
			SC1->C1_IMPORT  := SB1->B1_IMPORT
			SC1->C1_FORNECE := cFornece
			SC1->C1_LOJA    := cLoja   
			SC1->C1_ORIGEM	:= FunName()
			MaAvalSC("SC1",1)
			
			While ( GetSX8Len() > nSaveSX8 )
				ConfirmSX8()
			EndDo
			
			If lMt170SC1
				ExecBlock("MT170SC1",.f.,.f.)
			EndIf
			
			If lMt170FIM
				AAdd( aSolic, { SB1->B1_COD, cNumSolic } )
			EndIf
			
			End Transaction
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Ajusta variavel do saldo item a item para checar est. maximo ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			nSaldo += aQtdes[nY]

			If aParam[20] == 2  
				cItemSC	:= Soma1(cItemSC)
			Else
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				PcoFinLan("000051")  
				PcoFreeBlq("000051")
			EndIf
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Envia e-mail na inclusao de SC's     ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If lEnvMail
				MEnviaMail("035",{SC1->C1_NUM})
				lEnvMail := .F.
			EndIf     
			
			If AllTrim(cPedido) != SC1->C1_NUM
				AddMsgLog('Solicita็ใo de compras "'+SC1->C1_NUM+'" gerada.')
				cPedido := SC1->C1_NUM
			EndIf
			
		Next nY
		
	EndIf
	
	(cArqTrb)->(dbSkip())
	
EndDo

// Se foi gerada apenas uma solicitacao, entao deve-se finalizar os lancamentos do SIGAPCO
If aParam[20] == 2 .And. !Empty(cNumSolic)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a gravacao dos lancamentos do SIGAPCO            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PcoFinLan("000051")  
	PcoFreeBlq("000051")
EndIf

(cArqTrb)->(dbCloseArea())

If lMt170FIM
	ExecBlock( "MT170FIM", .F., .F., { aSolic } )
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038IniAmb บAutor ณIhorran Milholi    บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicia ambiente para schedule                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                   
Static Function VA038IniAmb()

//Separa as filiais em vetores
SET(_SET_DELETED,.T.)
dbUseArea(.T.,,"SIGAMAT.EMP","SM0",.T.,.F.) 
dbSetIndex("SIGAMAT.IND") 

//RPCSETType(3)	
Prepare Environment Empresa "08" Filial "01"

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหออออออัอออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038ResiAmbบAutor ณIhorran Milholi    บ Data ณ  12/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออออสออออออฯอออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณReseta ambiente para schedule                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VA038ResiAmb()

Reset Environment 

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA039Email บAutor ณIhorran Milholi     บ Data ณ  27/03/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para envio de email com os arquivos de log da rotina บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณVIXA038                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VA038Email(aArqLog)

Local cEmail	:= SuperGetMv("MV_Y038EML",.F.,"clayton@grupouniaosa.com.br; analistacompras@uniaovirtual.com.br; leonardo.teixeira@uniaovirtual.com.br")  
Local cArquivo	:= ""     
Local cAssunto	:= "Comunicado - Envio de Log de Pedidos de Compra Automaticos"
Local cMsg01	:= "Segue anexo arquivo(s) de log gerados pela rotina de gera็ใo de pedidos de compra do dia "+dToc(dDatabase)+" as "+Time()
Local cMsg02	:= "Rotina de Gera็ใo de Pedido de Compra Executada sem Erros no dia "+dToc(dDatabase)+" as "+Time()
Local i			:= 0

MODIFICAR WORKFLOW

//Monta lista dos arquivos que irใo em anexo
For i := 1 to Len(aArqLog)
	
	If i == Len(aArqLog)
		cArquivo += aArqLog[i]
	Else
		cArquivo += aArqLog[i]+","
	EndIf
Next

If !Empty(cArquivo)

	u_EnvEmail(cEmail,cAssunto,cMsg01,cArquivo)

Else
                                                  
	u_EnvEmail(cEmail,cAssunto,cMsg02)
	
EndIf
							
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038Log   บAutor ณIhorran Milholi     บ Data ณ  28/05/13   บฑฑ
ฑฑฬออออออออออุอออออออออออสออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para cria็ใo do log para analise da rotina           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณVIXA038                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VA038Log(aErros)

Local cLogFile	:= ""
Local nHandle	:= 0
Local aLogArq	:= {}
Local lRet		:= .f.
Local cPasta	:= "\COMPRAS\"
Local i, nX	:= 0
                 
MakeDir(cPasta)

Private lAutoErrNoFile := .T.

If Len(aErros[1]) > 0

	cLogFile := cPasta+"COM"+cEmpAnt+cFilAnt+dtos(dDatabase)+".LOG"

	// ---- Gera array Log
	AutoGrLog("-------------------------------------------------------------------------------------------------")	
	AutoGrLog(OemToAnsi("Pedidos de Compra gerados na Empresa\Filial "+cEmpAnt+"\"+cFilAnt))
	AutoGrLog(OemToAnsi("Log gerado em ")+DtoC(dDataBase)+OemToAnsi(", as ")+Time())                              
	AutoGrLog("-------------------------------------------------------------------------------------------------")		
	For i:= 1 to Len(aErros[1])
		
		AutoGrLog(OemToAnsi(aErros[1][i]))
		                                                  
	Next                                                                                                         
	AutoGrLog("-------------------------------------------------------------------------------------------------")	
	
	// ---- Grava Arquivo Log
	aLogArq := GetAutoGRLog()
	
	If	!File(cLogFile)
		If	(nHandle := MSFCreate(cLogFile,0)) <> -1
			lRet := .T.
		EndIf
	Else
		If	(nHandle := FOpen(cLogFile,2)) <> -1
			FSeek(nHandle,0,2)
			lRet := .T.
		EndIf
	EndIf
	
	If	lRet
		For nX := 1 To Len(aLogArq)
			FWrite(nHandle,aLogArq[nX]+CHR(13)+CHR(10))
		Next nX
		FClose(nHandle)
	EndIf

EndIf  

If !Empty(cLogFile)
	aAdd(aErros[2],cLogFile)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVA038FimProcPedบAutor ณIhorran Milholi บ Data ณ  28/05/13   บฑฑ
ฑฑฬออออออออออุอออออออออออออออสออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para analisar termino do processamento do p. compra  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณVIXA038                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VA038FimProcPed()

//Local nID		:= ThreadID()
Local aInfo 	:= GetUserInfoArray()
Local lRet		:= .T.
Local cFuncProc	:= "VA038JOBPED"
Local i            

For i := 1 to Len(aInfo)
	
	If cFuncProc $ AllTrim(Upper(aInfo[i][11])) .or. cFuncProc $ AllTrim(Upper(aInfo[i][5]))
		
		lRet := .f.
		Exit

	EndIf	

Next

Return lRet

//===================================================================================
//
//
//===================================================================================
Static Function MaioDtEntr(cFornecedor)
	Local aArea	:= GetArea()
	Local dRet 	:= nil 
	Local cAliasDt:= GetNextAlias()

	BeginSQL Alias cAliasDt
		SELECT	MAX(SC1.C1_DATPRF) C1_DATPRF
		FROM	%table:SC1% SC1
			JOIN %table:SB1% SB1 on SB1.%NotDel% AND SB1.B1_FILIAL	= %xFilial:SB1% AND SC1.C1_PRODUTO	= SB1.B1_COD
		WHERE	SC1.%NotDel%
			AND SC1.C1_FILIAL	= %xFilial:SC1%
			AND SC1.C1_PEDIDO	= %Exp:''%                                 
			AND SC1.C1_RESIDUO = %Exp:''%	
			AND SB1.B1_YCOMPRA IN ('1', ' ')
			AND SB1.B1_PROC NOT IN (%Exp:''%,%Exp:'999998'%,%Exp:'999999'%)
			AND SC1.C1_QUANT-SC1.C1_QUJE <> %Exp:0%
			AND SB1.B1_PROC = %Exp:cFornecedor%
	EndSql

	dRet := (cAliasDt)->C1_DATPRF
	
	RestArea(aArea)

	(cAliasDt)->(DbCloseArea())
	
Return dRet