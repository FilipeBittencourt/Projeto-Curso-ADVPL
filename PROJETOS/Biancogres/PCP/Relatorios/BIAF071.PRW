#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAF071
@author Artur Antunes
@since 13/04/2017
@version 1.0
@description Relatório de produtos obsoletos
@obs OS 3234-16
@type function
/*/

User Function BIAF071()

Local aArea     	:= GetArea()
private cProdDe		:= space(TAMSX3("B8_PRODUTO")[1])
private cProdAte	:= space(TAMSX3("B8_PRODUTO")[1])
private cMinDias  	:= "00000"
Private oExcel      := nil 
private cDirDest    := space(170)
private aPergs 		:= {}
 
Processa({|| fProcRel()},"Aguarde...","Carregando Registros...")

RestArea(aArea)  
return   

      
Static Function fProcRel()

Local cTab     	:= GetNextAlias() 
local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
local cTitulo   := "Relatório de Produtos Obsoletos"  
local nRegAtu   := 0
local nTotReg   := 0
local cChave	:= ''
local cArqXML   := "BIAF071_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
local cQuery	:= ''
local nDec1		:= TamSX3("B8_SALDO")[2]
local nDec2		:= TamSX3("B8_EMPENHO")[2]
local nDec3		:= TamSX3("B2_VATU1")[2]

local cCab1Fon	:= 'Calibri' 
local cCab1TamF	:= 8   
local cCab1CorF := '#FFFFFF'
local cCab1Fun	:= '#4F81BD'

local cFonte1	 := 'Arial'
local nTamFont1	 := 12   
local cCorFont1  := '#FFFFFF'
local cCorFun1	 := '#4F81BD'

local cFonte2	 := 'Arial'
local nTamFont2	 := 8   
local cCorFont2  := '#000000'
local cCorFun2	 := '#B8CCE4'

ProcRegua(0)

If !fPergunte()
	Return
endif	

cQuery	:= " WITH TAB_ITENS AS " + CRLF
cQuery	+= " ( " + CRLF
cQuery	+= " 	SELECT XB8C.*, " + CRLF 
cQuery	+= " 		   (B8_SALDO * " + CRLF
cQuery	+= " 	       ISNULL( (SELECT SUM(B2_VATU1) / SUM(B2_QATU) " + CRLF 
cQuery	+= "  					FROM " + RetSQLName("SB2") + " (NOLOCK) SB2 " + CRLF 
cQuery	+= "  					WHERE SB2.B2_FILIAL = XB8C.B8_FILIAL " + CRLF
cQuery	+= "  	 				 AND SB2.B2_COD = XB8C.B8_PRODUTO " + CRLF
cQuery	+= " 	 				 AND B2_VATU1 > 0 " + CRLF
cQuery	+= " 	 				 AND B2_QATU > 0 " + CRLF
cQuery	+= " 	 				 AND SB2.D_E_L_E_T_ = '' ) ,0)) CUSTO " + CRLF	    
cQuery	+= " 	FROM ( " + CRLF 
cQuery	+= " 			SELECT SB8.B8_FILIAL,SB8.B8_PRODUTO,SB8.B8_LOTECTL,SB1.B1_DESC,SB1.B1_UM,SB1.B1_GRUPO,SUM(SB8.B8_SALDO) B8_SALDO,SUM(SB8.B8_EMPENHO) B8_EMPENHO " + CRLF 
cQuery	+= "  			FROM " + RetSQLName("SB8") + " (NOLOCK) SB8 " + CRLF 
cQuery	+= "  			JOIN " + RetSQLName("SB1") + " (NOLOCK) SB1 " + CRLF 
cQuery	+= "  			 ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " + CRLF 
cQuery	+= "  			 AND SB1.B1_COD = SB8.B8_PRODUTO " + CRLF 
cQuery	+= "  			 AND SB1.D_E_L_E_T_ = '' " + CRLF 
cQuery	+= "  			WHERE SB8.B8_SALDO > 0 " + CRLF 
cQuery	+= "  			 AND SB8.B8_PRODUTO BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' " + CRLF 
cQuery	+= "  			 AND SB8.D_E_L_E_T_ = '' " + CRLF 
cQuery	+= "  			GROUP BY SB8.B8_FILIAL,SB8.B8_PRODUTO,SB8.B8_LOTECTL,SB1.B1_DESC,SB1.B1_UM,SB1.B1_GRUPO " + CRLF 
cQuery	+= " 	 ) XB8C " + CRLF
cQuery	+= " 	 UNION ALL " + CRLF 
cQuery	+= " 	SELECT SB2.B2_FILIAL B8_FILIAL,SB2.B2_COD B8_PRODUTO,'' B8_LOTECTL,SB1.B1_DESC,SB1.B1_UM,SB1.B1_GRUPO,SUM(SB2.B2_QATU) B8_SALDO, SUM(SB2.B2_RESERVA) B8_EMPENHO, SUM(B2_VATU1) CUSTO " + CRLF
cQuery	+= "   	FROM " + RetSQLName("SB2") + " (NOLOCK) SB2 " + CRLF 
cQuery	+= "  	JOIN " + RetSQLName("SB1") + " (NOLOCK) SB1 " + CRLF 
cQuery	+= "   	 ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' " + CRLF 
cQuery	+= "   	 AND SB1.B1_COD = SB2.B2_COD " + CRLF 
cQuery	+= "  	 AND SB1.D_E_L_E_T_ = '' " + CRLF 
cQuery	+= "  	WHERE SB2.B2_QATU > 0 " + CRLF 
cQuery	+= "   	 AND SB2.B2_COD BETWEEN '"+cProdDe+"' AND '"+cProdAte+"' " + CRLF 
cQuery	+= "  	 AND SB1.B1_RASTRO <> 'L' " + CRLF 
cQuery	+= "   	 AND SB2.D_E_L_E_T_ = '' " + CRLF 
cQuery	+= "  	GROUP BY SB2.B2_FILIAL,SB2.B2_COD,SB1.B1_DESC,SB1.B1_UM,SB1.B1_GRUPO " + CRLF 
cQuery	+= " ) " + CRLF
cQuery	+= " SELECT Y.DIASOBSOL, Y.B8_FILIAL, Y.B8_PRODUTO, Y.B8_LOTECTL, Y.B1_DESC, Y.B1_UM, " + CRLF
cQuery	+= " 	   Y.B1_GRUPO, Y.B8_SALDO,Y.B8_EMPENHO, Y.DTUTENT, Y.DTUTMOV, Y.DTUTSAI,Y.CUSTO " + CRLF 
cQuery	+= " FROM ( " + CRLF 
cQuery	+= " 		SELECT X.*, " + CRLF
cQuery	+= " 			  CASE " + CRLF 
cQuery	+= " 				WHEN X.DTUTENT > X.DTUTMOV AND X.DTUTENT > X.DTUTSAI " + CRLF
cQuery	+= " 					THEN DATEDIFF(DAY,X.DTUTENT,CONVERT(VARCHAR(8), GETDATE(), 112)) " + CRLF  
cQuery	+= " 				WHEN X.DTUTMOV > X.DTUTENT AND X.DTUTMOV > X.DTUTSAI " + CRLF
cQuery	+= " 					THEN DATEDIFF(DAY,X.DTUTMOV,CONVERT(VARCHAR(8), GETDATE(), 112)) " + CRLF  
cQuery	+= " 				WHEN X.DTUTSAI > X.DTUTENT AND X.DTUTSAI > X.DTUTMOV " + CRLF
cQuery	+= " 					THEN DATEDIFF(DAY,X.DTUTSAI,CONVERT(VARCHAR(8), GETDATE(), 112)) " + CRLF  
cQuery	+= " 				WHEN X.DTUTENT <> '' " + CRLF
cQuery	+= " 					THEN DATEDIFF(DAY,X.DTUTENT,CONVERT(VARCHAR(8), GETDATE(), 112)) " + CRLF  
cQuery	+= " 				WHEN X.DTUTMOV <> '' " + CRLF
cQuery	+= " 					THEN DATEDIFF(DAY,X.DTUTMOV,CONVERT(VARCHAR(8), GETDATE(), 112)) " + CRLF  
cQuery	+= " 				WHEN X.DTUTSAI <> '' " + CRLF
cQuery	+= " 					THEN DATEDIFF(DAY,X.DTUTSAI,CONVERT(VARCHAR(8), GETDATE(), 112)) " + CRLF  
cQuery	+= " 			  END DIASOBSOL " + CRLF
cQuery	+= " 		FROM ( " + CRLF
cQuery	+= " 				SELECT XB8.*, " + CRLF
cQuery	+= " 					   ISNULL( (SELECT MAX(SD1.D1_DTDIGIT) " + CRLF      
cQuery	+= " 								FROM " + RetSQLName("SD1") + " (NOLOCK) SD1 " + CRLF
cQuery	+= " 								JOIN " + RetSQLName("SF4") + " (NOLOCK) SF4 " + CRLF
cQuery	+= " 								 ON SF4.F4_FILIAL = '" + xFilial('SF4') + "' " + CRLF
cQuery	+= " 								 AND SF4.F4_CODIGO = SD1.D1_TES " + CRLF
cQuery	+= " 								WHERE SD1.D1_FILIAL = XB8.B8_FILIAL " + CRLF
cQuery	+= " 								 AND SD1.D1_COD = XB8.B8_PRODUTO " + CRLF
cQuery	+= " 								 AND SD1.D1_LOTECTL = XB8.B8_LOTECTL " + CRLF
cQuery	+= " 								 AND SF4.F4_ESTOQUE = 'S' " + CRLF
cQuery	+= " 								 AND SD1.D_E_L_E_T_ = '' " + CRLF
cQuery	+= " 								 AND SF4.D_E_L_E_T_ = ''),'') DTUTENT, " + CRLF
cQuery	+= " 					   ISNULL( (SELECT MAX(SD3.D3_EMISSAO) " + CRLF
cQuery	+= " 								FROM " + RetSQLName("SD3") + " (NOLOCK) SD3 " + CRLF
cQuery	+= " 								WHERE SD3.D3_FILIAL= XB8.B8_FILIAL " + CRLF
cQuery	+= " 								 AND SD3.D3_COD = XB8.B8_PRODUTO " + CRLF
cQuery	+= " 								 AND SD3.D3_CF NOT IN ('DE4','RE4','DE3','RE3','DE7','RE7') " + CRLF
cQuery	+= " 								 AND SD3.D_E_L_E_T_ = '' " + CRLF
cQuery	+= " 								 AND SD3.D3_LOTECTL = XB8.B8_LOTECTL),'') DTUTMOV, " + CRLF
cQuery	+= "  					   ISNULL( (SELECT MAX(SD2.D2_EMISSAO) " + CRLF 
cQuery	+= " 								FROM " + RetSQLName("SD2") + " (NOLOCK) SD2 " + CRLF
cQuery	+= " 								JOIN " + RetSQLName("SF4") + " (NOLOCK) SF4 " + CRLF
cQuery	+= " 								 ON SF4.F4_FILIAL = '" + xFilial('SF4') + "' " + CRLF
cQuery	+= " 								 AND SF4.F4_CODIGO = SD2.D2_TES " + CRLF
cQuery	+= " 								WHERE SD2.D2_FILIAL = XB8.B8_FILIAL " + CRLF
cQuery	+= " 								 AND SD2.D2_COD = XB8.B8_PRODUTO " + CRLF
cQuery	+= " 								 AND SD2.D2_LOTECTL = XB8.B8_LOTECTL " + CRLF
cQuery	+= " 								 AND SF4.F4_ESTOQUE = 'S' " + CRLF
cQuery	+= " 								 AND SD2.D_E_L_E_T_ = '' " + CRLF
cQuery	+= " 								 AND SF4.D_E_L_E_T_ = ''),'') DTUTSAI " + CRLF
cQuery	+= " 				FROM TAB_ITENS XB8 " + CRLF
cQuery	+= " 		) X " + CRLF
cQuery	+= " 	)Y " + CRLF
if val(cMinDias) > 0
	cQuery	+= " 	WHERE Y.DIASOBSOL >= "+ Alltrim(cMinDias) +" " + CRLF
endif	
cQuery	+= " ORDER BY Y.DIASOBSOL DESC, Y.B8_FILIAL,Y.B8_PRODUTO,Y.B8_LOTECTL " + CRLF

TcQuery cQuery Alias (cTab) New
(cTab)->(DbGoTop())
Count To nTotReg 
if nTotReg < 1
	MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
	return
endif
(cTab)->(dbGoTop())
ProcRegua(nTotReg + 2)
   
nRegAtu++
IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

oExcel := ARSexcel():New() 
oExcel:AddPlanilha('Relatorio',{20,50,80,60,170,50,50,90,90,90,90,90,90,90,20},6)
oExcel:AddLinha(20)
oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,12) 
oExcel:AddLinha(15)
oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,12) 
oExcel:AddLinha(15)
oExcel:AddLinha(20)
oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,12)  
    
oExcel:AddLinha(20)
oExcel:AddLinha(12) 
oExcel:AddCelula()  
oExcel:AddCelula("Filial"  				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Produto"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Lote"  				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("UM"	  				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Grupo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Saldo"		  		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Empenhado"  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Custo"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("DT Ult. Entrada"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("DT Ult. Mov. Interno" ,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("DT Ult. Saida"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Dias sem Movimento"	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
                  
While !(cTab)->(Eof())
	
	nRegAtu++
	if MOD(nRegAtu,2) > 0 
        cCorFun2 := '#DCE6F1'
	else
		cCorFun2 := '#B8CCE4'
	endif	  

	oExcel:AddLinha(14) 
	oExcel:AddCelula()   			

	oExcel:AddCelula( (cTab)->B8_FILIAL	 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B8_PRODUTO	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B8_LOTECTL	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B1_DESC	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B1_UM	 		,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B1_GRUPO	 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B8_SALDO	 	,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B8_EMPENHO	,nDec2	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->CUSTO			,nDec3	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->DTUTENT)	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->DTUTMOV)	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->DTUTSAI)	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->DIASOBSOL	 	,0		 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

   	(cTab)->(DbSkip())                
EndDo    

fGeraParametros()
oExcel:SaveXml(Alltrim(cDirDest),cArqXML,.T.) 

nRegAtu++
IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	
return
 
 
 //Gera parametros
Static Function fGeraParametros()

local nCont		 := 0 
local cCorFundo  := ""
local cTitulo	 := 'Parametros'

local cFonte1    := 'Calibri' 
local nTamFont1  := 9
local cCorFont1  := '#FFFFFF'
local cCorFund1  := '#4F81BD'

local cFonte2    := 'Arial' 
local nTamFont2  := 9
local cCorFont2  := '#000000'

local cCorFundo  := ''

aPergs[1,3] := cProdDe 
aPergs[2,3] := cProdAte  
aPergs[3,3] := cMinDias     
aPergs[4,3] := cDirDest         

oExcel:AddPlanilha('Parametros',{30,80,120,270})
oExcel:AddLinha(18)
oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
oExcel:AddLinha(15)
oExcel:AddLinha(12) 
oExcel:AddCelula()
oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

for nCont := 1 to Len(aPergs)	
	
	if MOD(nCont,2) > 0 
        cCorFundo := '#DCE6F1'	
	else
		cCorFundo := '#B8CCE4'	
	endif	  

	oExcel:AddLinha(16) 
	oExcel:AddCelula()
	oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
	oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
	oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 

next aPergs
Return 
          
       
//Perguntas
Static Function fPergunte()

local cLoad	    := "BIAF071" + cEmpAnt
local cFileName := RetCodUsr() +"_"+ cLoad
local lRet		:= .F.

aAdd( aPergs ,{1,"Produto de:"	   	,cProdDe  	,"@!"		 ,'.T.'	,"SB1"	,'.T.',50,.F.})	
aAdd( aPergs ,{1,"Produto Ate: "    ,cProdAte 	,"@!"		 ,'.T.'	,"SB1"	,'.T.',50,.F.})	

aAdd( aPergs ,{1,"Minimo de Dias"	,cMinDias  	,"@E 99999",'.T.'	,""		,'.T.',50,.F.})	

aAdd( aPergs ,{6,"Pasta Destino" 	,cDirDest   ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	
If ParamBox(aPergs ,"Relatório - Log ajuste de empenho",,,,,,,,cLoad,.T.,.T.)  

    lRet := .T.
    
	cProdDe  := ParamLoad(cFileName,,1,cProdDe) 
	cProdAte := ParamLoad(cFileName,,2,cProdAte)     
	cMinDias := ParamLoad(cFileName,,3,cMinDias) 
	cDirDest := ParamLoad(cFileName,,4,cDirDest)  
	
	if empty(cProdAte) 
		cProdAte := REPLICATE('Z',TamSX3("B8_PRODUTO")[1]) 
	endif
	if empty(cMinDias) 	
		cMinDias := "0"
	endif
	if empty(cDirDest) 
		cDirDest := AllTrim(GetTempPath()) 	
	endif  	
endif
	
return lRet

