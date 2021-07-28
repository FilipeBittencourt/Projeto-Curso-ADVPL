#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funáao     ≥ FRQCRT02 ≥ Autor ≥ FERNANDO ROCHA        ≥ Data ≥31/10/2014≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descriáao  ≥ Gerar pedido de venda de produtos comuns				   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso        ≥ BIANCOGRES                                                 ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/ 

#DEFINE TIT_MSG "GERAR PV PRODUTOS COMUNS"

User Function FRQCRT02(cEmpDest, cCLVL, aProdutos)

Local aArea
Local aRet
Local bProcessa
Local cPedido := ""
Local cFile
Local _cDest := GetNewPar("FA_RQCDE"+AllTrim(cEmpDest),"ranisses.corona@biancogres.com.br")
Local _cTexto   

Private aExcel

aArea := GetArea()

//Execucao via JOB em outra empresa do EXECAUTO da replicacao do pedido LM
bProcessa := {|| aRet := GerarPV(cEmpDest, cCLVL, aProdutos)  }
U_BIAMsgRun("Aguarde... Gerando pedido de venda",,bProcessa) 

If !aRet[1]   
	U_FROPMSG(TIT_MSG, 	"Informe ao setor de TI erro com a geraÁ„o do pedido comum:"+CRLF+CRLF+aRet[2],,,"ERRO na geraÁ„o do Pedido")
	RestArea(aArea)
	Return("")
Else
	//U_FROPMSG(TIT_MSG, 	"Finalizado com Sucesso, incluido PEDIDO: "+aRet[3],,,"Gerar Pedido Produto Comum")
	cPedido := aRet[3]
EndIf 

//Gerando workflow
cFile := U_FRQ2WF01(AllTrim(cEmpAnt), cPedido, aExcel)  

_cTexto := "Pedido "+cPedido+" gerado na empresa "+AllTrim(cEmpAnt)+" para baixa do ArmazÈm 6T."+CRLF+;
			"È necess·rio faturar o PEDIDO DE VENDA antes do fechamento."

U_BIAEnvMail(,_cDest,"Produtos Pendentes no ArmazÈm 6T - Pedido Gerado",_cTexto,,cFile)
	

RestArea(aArea)

Return(cPedido)


//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//EXECAUTO DO PEDIDO DE VENDAS
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
Static Function GerarPV(cEmpDest, cCLVL, aProdutos)

Local aCabPV := {}
Local aItemPV:= {}
Local cItem
Local I
Local cNumPed
Local aAux := {}


Local _cLogTxt := ""
Local _cCondPag := GetNewPar("FA_RQCCPPV","014") 
Local _cCliente := GetNewPar("FA_RQCCL"+AllTrim(cEmpDest),"01008301")
Local _cC5SUBTP := GetNewPar("FA_RQCSTP","O")
Local _cC5VEND	:= GetNewPar("FA_RQCVEND","999999")    
Local _cTES		:= GetNewPar("FA_RQCTES","505")
Local _nAcres	:= GetNewPar("FA_RQCACR",0)
Local _lRet		:=	.T.

Local _dMesAnt := IIf( 	Month(dDataBase)==1,; 
 						STOD(StrZero(Year(dDataBase)-1,4)+"1231") ,; 
 						LastDate(STOD(StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2)+"01")) )
Local _nCusto
Local cAliasAux

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private lAutoErrNoFile := .T.

ConOut("FUNCAO: "+AllTrim(FunName())+" - Gerar pedido comum: Preparando...")

//Cabecalho
//Numero do novo pedido
cNumPed := GetSxENum("SC5","C5_NUM",AllTrim(CEMPANT)+"SC5_INT")

//Preenchimento dos Campos Padroes - Cabecalho
aCabPV:={}
aAdd(aCabPV,  {"C5_NUM"   		,cNumPed   						,Nil}) // Numero do pedido
aAdd(aCabPV,  {"C5_TIPO"   		,"N"					   		,Nil}) // Tipo do pedido
aAdd(aCabPV,  {"C5_YLINHA"  	,IIF(CEMPANT="01","1","2")   	,Nil})
aAdd(aCabPV,  {"C5_CLIENTE"   	,SubStr(_cCliente,1,6)			,Nil})
aAdd(aCabPV,  {"C5_LOJAENT"		,SubStr(_cCliente,7,2)			,Nil}) 
aAdd(aCabPV,  {"C5_LOJAENT"		,SubStr(_cCliente,7,2)			,Nil})
aAdd(aCabPV,  {"C5_YSUBTP"		,_cC5SUBTP						,Nil}) 
aAdd(aCabPV,  {"C5_CONDPAG"		, _cCondPag						,Nil})
aAdd(aCabPV,  {"C5_VEND1"		,_cC5VEND						,Nil})
aAdd(aCabPV,  {"C5_TPFRETE"		,"S"					   		,Nil})
aAdd(aCabPV,  {"C5_EMISSAO"		,dDataBase				   		,Nil})
aAdd(aCabPV,  {"C5_LIBEROK"		,"S"					   		,Nil}) 
//aAdd(aCabPV,  {"C5_YCLVL"		,cCLVL					   		,Nil}) // Retirado em 24/06/15 por Marcos Alberto Soprani para atender ao novo tratamento de clvl.
aAdd(aCabPV,  {"C5_YCONF"		,"S"					   		,Nil})
aAdd(aCabPV,  {"C5_MENNOTA"		,"CLVL: " + cCLVL		   		,Nil})

//Items 
aExcel := {}
aItemPV := {}

//Item inicial
cItem := StrZero(0,TamSx3("C6_ITEM")[1])
               
SB9->(DbSetOrder(1))//B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_

FOR I := 1 To Len(aProdutos)
	
	cItem := Soma1(cItem,Len(cItem))
	
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(XFilial("SB1")+aProdutos[I][1]))    
	
	//Vetor para gerar excel do wrokflow
	AAdd(aExcel, {cEmpDest, cCLVL, aProdutos[I][1], SB1->B1_DESC, aProdutos[I][2], aProdutos[I][4], aProdutos[I][5], aProdutos[I][6]} )
	
	//Buscar custo do mes anterior
	//Buscando data do ultimo fechamento
	cAliasAux := GetNextAlias()
	BeginSql Alias cAliasAux
	%NOPARSER%
	SELECT CUSTO =  CASE WHEN isnull((SELECT MAX(B9_DATA) from %TABLE:SB9% where B9_COD = %EXP:aProdutos[I][1]% and B9_LOCAL IN ('01','6B','6I') and B9_CM1 > 0 and D_E_L_E_T_=''),'20000101') > '20000101'
					THEN
						(SELECT TOP 1 CUSTO = B9_CM1 FROM %TABLE:SB9% where B9_COD = %EXP:aProdutos[I][1]% and B9_LOCAL IN ('01','6B','6I') and B9_CM1 > 0 and B9_DATA =
						(SELECT MAX(B9_DATA) from %TABLE:SB9% where B9_COD = %EXP:aProdutos[I][1]% and B9_LOCAL IN ('01','6B','6I') and B9_CM1 > 0 and D_E_L_E_T_=''))
					ELSE
						isnull((SELECT TOP 1 CUSTO = D1_CUSTO FROM %TABLE:SD1% where D1_COD = %EXP:aProdutos[I][1]% and D1_LOCAL IN ('01','6B','6I') and D1_CUSTO > 0 and D1_DTDIGIT >= '20000101' order by D1_DTDIGIT desc),0)
					END
	EndSql

	If !(cAliasAux)->(Eof())
		_nCusto := (cAliasAux)->CUSTO
	Else
		_nCusto := 0
		
		//fixado para gerar nota de 1 real
		//_cLogTxt += "Produto: "+aProdutos[I][1]+" sem custo no mÍs anterior!"
		//return({.F.,_cLogTxt})
	EndIf
	(cAliasAux)->(DbCloseArea())        
	
	If (_nCusto < 0.01)
		_nCusto := 0.01
	EndIf
	
	aAux := {}
	aAdd(aAux,{"C6_NUM"		,cNumPed								,Nil})
	aAdd(aAux,{"C6_ITEM"	,cItem									,Nil}) // Numero do Item no Pedido
	aAdd(aAux,{"C6_PRODUTO"	,aProdutos[I][1]						,Nil}) 
	aAdd(aAux,{"C6_QTDVEN"	,aProdutos[I][2]						,Nil}) 
	aAdd(aAux,{"C6_PRCVEN"	,_nCusto + (_nCusto*_nAcres)/100		,Nil}) 
	aAdd(aAux,{"C6_VALOR"	,Round(aProdutos[I][2]*_nCusto,2) 		,Nil}) 
	aAdd(aAux,{"C6_TES"		,_cTES					   				,Nil})
	aAdd(aAux,{"C6_QTDLIB"	,aProdutos[I][2]						,Nil})   
	aAdd(aAux,{"C6_YEMP"	,AllTrim(CEMPANT)+AllTrim(CFILANT)		,Nil}) 
	aAdd(aAux,{"C6_LOCAL"	,"6T"					   				,Nil}) 
	
	Aadd(aItemPV,AClone(aAux))
	
Next I

IF Len(aItemPV) <= 0
	_cLogTxt += "N„o È possÌvel gerar pedido de vendas sem itens!"
	return({.F.,_cLogTxt})
ENDIF

//Geracao do Pedido de Venda  
BEGIN TRANSACTION 


//Verificar numeracao do pedido
dbSelectArea("SC5")
cMay := "SC5"+ Alltrim(xFilial("SC5"))
SC5->(dbSetOrder(1))
While ( DbSeek(xFilial("SC5")+cNumPed) .or. !MayIUseCode(cMay+cNumPed) )
	cNumPed := Soma1(cNumPed,Len(cNumPed))
	aCabPV[1][2] := cNumPed 
EndDo

ConOut("PEDIDO PRODUTO COMUM - "+cNumPed+": Iniciando ExecAuto...")
MsExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItemPV,3)

If lMsErroAuto
	RollBackSX8()
	DisarmTransaction()
	//Grava log de erro para consulta posterior
	aAutoErro := GETAUTOGRLOG()
	_cLogTxt += XCONVERRLOG(aAutoErro)
	ConOut("PEDIDO PRODUTO COMUM - "+cNumPed+": ERRO: "+_cLogTxt)
	MemoWrite("\PEDREPL\PEDCOMUM_"+AllTrim(cNumPed)+".TXT", _cLogTxt)
	_lRet	:=	.F.
//	return({.F.,_cLogTxt})
Else
	ConfirmSX8()
EndIf

END TRANSACTION

ConOut("PEDIDO PRODUTO COMUM - Finalizado com Sucesso, incluido PEDIDO: "+cNumPed+" na empresa: "+CEMPANT)
return({_lRet,_cLogTxt, cNumPed})

//‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//CONVERTER LOG DE ERRO PARA TEXTO SIMPLES
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
STATIC FUNCTION XCONVERRLOG(aAutoErro)
LOCAL cRet := ""
LOCAL nX := 1

FOR nX := 1 to Len(aAutoErro)
	cRet += aAutoErro[nX]+CRLF
NEXT nX
RETURN cRet


/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
FUNCAO PARA GERAR EXCEL - WPRKFLOW APOS GERACAO DO PEDIDO
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
User Function FRQ2WF01(_cEmpresa, _cPedido, _aExcel)
Local cFile  
U_BIAMsgRun("Aguarde, gerando workflow para faturamento...",, {|| cFile := WFExcel(_cEmpresa, _cPedido, _aExcel)  }) 
Return(cFile)

Static Function WFExcel(_cEmpresa, _cPedido, _aExcel)

Local aArea := GetArea()
Local oFWExcel := Nil
Local oMsExcel := Nil
Local cDir := "\P10\DOCTEMP\" //GetSrvProfString("Startpath", "")
Local cFile := "REQ_COMUM_EXCEL-"+ dToS(Date()) +"-"+ StrTran(Time(), ":", "") + ".XML"
Local cWorkSheet := ""
Local cTable := ""
Local cDirTmp := AllTrim(GetTempPath())    
Local I

cWorkSheet := "Itens de Requisicao Comum Pendentes de Venda"
cTable := cWorkSheet + " - Empresa Origem: "+AllTrim(_cEmpresa)+" - Pedido: "+AllTrim(_cPedido)

oFWExcel := FWMsExcel():New()
oFWExcel:AddWorkSheet(cWorkSheet)
oFWExcel:AddTable(cWorkSheet, cTable)     

oFWExcel:AddColumn(cWorkSheet, cTable, "Empresa", 1, 1)
oFWExcel:AddColumn(cWorkSheet, cTable, "Classe de Valor", 1, 1)
oFWExcel:AddColumn(cWorkSheet, cTable, "Produto", 1, 1)
oFWExcel:AddColumn(cWorkSheet, cTable, "DescriÁ„o", 1, 1)
oFWExcel:AddColumn(cWorkSheet, cTable, "Quantidade", 1, 2)  
oFWExcel:AddColumn(cWorkSheet, cTable, "Solicitante", 1, 1)
oFWExcel:AddColumn(cWorkSheet, cTable, "Documento", 1, 1) 
oFWExcel:AddColumn(cWorkSheet, cTable, "Data", 1, 1) 

FOR I := 1 To Len(_aExcel)
	
	aAux := {}
	AAdd(aAux, _aExcel[I][1])
	AAdd(aAux, _aExcel[I][2])
	AAdd(aAux, _aExcel[I][3])
	AAdd(aAux, _aExcel[I][4])
	AAdd(aAux, _aExcel[I][5])
	AAdd(aAux, _aExcel[I][6])
	AAdd(aAux, _aExcel[I][7])
	AAdd(aAux, _aExcel[I][8])
	
	oFWExcel:AddRow(cWorkSheet, cTable,	aAux)

NEXT I	

oFWExcel:Activate()
oFWExcel:GetXMLFile(cDir+cFile)
oFWExcel:DeActivate()

RestArea(aArea)
Return(cDir + cFile)
