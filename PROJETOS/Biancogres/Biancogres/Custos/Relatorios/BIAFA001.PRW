#Include "TOTVS.CH"
#Include "Protheus.ch"
#include "topconn.ch"

/*/{Protheus.doc} BIAFA001
@author Artur Antunes
@since 26/04/2017
@version 1.0
@description Relatorio de log de processamento referentes a rotina de custo
@obs OS 0782-17
@type function
/*/

User Function BIAFA001()

Local aArea    := GetArea()
private aPergs := {}

If !ValidPerg()
	Return
EndIf

Processa({|| fProcRel()},"Aguarde...","Carregando Registros...")

RestArea(aArea)  
return   


Static Function fProcRel()

Local cTab     	:= GetNextAlias() 
local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
local cTitulo   := "Relatório de Log de processamento - Fechamento do Custo"  
local nRegAtu   := 0
local nTotReg   := 0
local cArqXML   := "BIAFA001_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
local cQuery	:= ''

local cCab1Fon	:= 'Calibri' 
local nCab1TamF	:= 8   
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

cQuery := " SELECT Z06_EMPFIL,Z06_ROTINA,Z06_USER,Z06_DTINI,Z06_HRINI,Z06_DTFIM,Z06_HRFIM,Z06_TEMPEX,Z06_DTPSIS, " + CRLF 
cQuery += " XPARAM = ISNULL(CAST(CONVERT(VARBINARY(5000),Z06_PARAM) AS VARCHAR(5000)),'') " + CRLF 
cQuery += " FROM "+RetSqlName("Z06")+" (NOLOCK) " + CRLF 
cQuery += " WHERE Z06_EMPFIL 	 BETWEEN '"+ MV_PAR01+"'        AND '"+ MV_PAR02+"' " + CRLF 
cQuery += "  AND Z06_ROTINA  	 BETWEEN '"+ MV_PAR03+"'        AND '"+ MV_PAR04+"' " + CRLF 
cQuery += "  AND upper(Z06_USER) BETWEEN '"+ upper(MV_PAR05)+"' AND '"+ upper(MV_PAR06)+"' " + CRLF 
cQuery += "  AND Z06_DTINI   	 BETWEEN '"+ dtos(MV_PAR07)+"'  AND '"+ dtos(MV_PAR08)+"' " + CRLF 
cQuery += "  AND Z06_DTFIM   	 BETWEEN '"+ dtos(MV_PAR09)+"'  AND '"+ dtos(MV_PAR10)+"' " + CRLF 
cQuery += "  AND Z06_DTPSIS  	 BETWEEN '"+ dtos(MV_PAR11)+"'  AND '"+ dtos(MV_PAR12)+"' " + CRLF 
cQuery += " ORDER BY Z06_DTINI, Z06_ROTINA " + CRLF 

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
oExcel:AddPlanilha('Relatorio',{20,70,80,80,80,80,80,80,80,150,80,20},6)
oExcel:AddLinha(20)
oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,9) 
oExcel:AddLinha(15)
oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,9) 
oExcel:AddLinha(15)
oExcel:AddLinha(20)
oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,9)  
    
oExcel:AddLinha(20)
oExcel:AddLinha(12) 
oExcel:AddCelula()  
oExcel:AddCelula("Emp/Filial"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Rotina" 			,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Usuario"	  		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Data Inicial"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Horario Inicial"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Data Final"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Horario Final"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Tempo Decorrido"	,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Parâmetros"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Data Sistema"		,0,'C',cCab1Fon,nCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
                  
While !(cTab)->(Eof())
	
	nRegAtu++
	if MOD(nRegAtu,2) > 0 
        cCorFun2 := '#DCE6F1'
	else
		cCorFun2 := '#B8CCE4'
	endif	  

	oExcel:AddLinha(14) 
	oExcel:AddCelula()   			

	oExcel:AddCelula( (cTab)->Z06_EMPFIL		,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z06_ROTINA		,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z06_USER			,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->Z06_DTINI) 	,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z06_HRINI			,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->Z06_DTFIM)	,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z06_HRFIM			,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z06_TEMPEX		,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->XPARAM			,0 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->Z06_DTPSIS) 	,0 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

   	(cTab)->(DbSkip())                
EndDo    

fGeraParametros()
oExcel:SaveXml(Alltrim(MV_PAR13),cArqXML,.T.) 

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

aPergs[1 ,3] := MV_PAR01 
aPergs[2 ,3] := MV_PAR02  
aPergs[3 ,3] := MV_PAR03     
aPergs[4 ,3] := MV_PAR04         
aPergs[5 ,3] := MV_PAR05         
aPergs[6 ,3] := MV_PAR06 
aPergs[7 ,3] := MV_PAR07  
aPergs[8 ,3] := MV_PAR08     
aPergs[9 ,3] := MV_PAR09         
aPergs[10,3] := MV_PAR10  
aPergs[11,3] := MV_PAR11 
aPergs[12,3] := MV_PAR12  
aPergs[13,3] := MV_PAR13     

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
return


Static Function ValidPerg()

local cLoad	    := "BIAFA001" + cEmpAnt
local cFileName := RetCodUsr() +"_"+ cLoad
local lRet		:= .F.

MV_PAR01 := space(TamSx3("Z06_EMPFIL")[1])
MV_PAR02 := space(TamSx3("Z06_EMPFIL")[1])
MV_PAR03 := space(TamSx3("Z06_ROTINA")[1])
MV_PAR04 := space(TamSx3("Z06_ROTINA")[1])
MV_PAR05 := space(TamSx3("Z06_USER")[1])
MV_PAR06 := space(TamSx3("Z06_USER")[1])
MV_PAR07 := STOD('')
MV_PAR08 := STOD('')
MV_PAR09 := STOD('')
MV_PAR10 := STOD('')
MV_PAR11 := STOD('')
MV_PAR12 := STOD('')
MV_PAR13 := space(100)

aAdd( aPergs ,{1,"Emp/Fil de?"		,MV_PAR01 ,"@!",'.T.'		,"",'.T.',50,.F.})	
aAdd( aPergs ,{1,"Emp/Fil Ate?"		,MV_PAR02 ,"@!",'.T.'		,"",'.T.',50,.F.})	
aAdd( aPergs ,{1,"Rotina de?"		,MV_PAR03 ,"@!",'.T.'		,"",'.T.',50,.F.})	
aAdd( aPergs ,{1,"Rotina Ate?"		,MV_PAR04 ,"@!",'.T.'		,"",'.T.',50,.F.})	
aAdd( aPergs ,{1,"Usuario de?"		,MV_PAR05 ,"@!",'.T.'		,"",'.T.',50,.F.})	
aAdd( aPergs ,{1,"Usuario Ate?"		,MV_PAR06 ,"@!",'.T.'		,"",'.T.',50,.F.})	
aAdd( aPergs ,{1,"DT Inicio De? " 	,MV_PAR07 ,""  ,"NAOVAZIO()",'','.T.',50,.F.})	
aAdd( aPergs ,{1,"DT Inicio Até?" 	,MV_PAR08 ,""  ,"NAOVAZIO()",'','.T.',50,.F.})	
aAdd( aPergs ,{1,"DT Fim De? " 		,MV_PAR09 ,""  ,"NAOVAZIO()",'','.T.',50,.F.})	
aAdd( aPergs ,{1,"DT Fim Até?" 		,MV_PAR10 ,""  ,"NAOVAZIO()",'','.T.',50,.F.})	
aAdd( aPergs ,{1,"DT Sistema De? " 	,MV_PAR11 ,""  ,"NAOVAZIO()",'','.T.',50,.F.})	
aAdd( aPergs ,{1,"DT Sistema Até?" 	,MV_PAR12 ,""  ,"NAOVAZIO()",'','.T.',50,.F.})	
aAdd( aPergs ,{6,"Pasta Destino?"  	,MV_PAR13 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	
If ParamBox(aPergs ,"Relatório de Log de processamento",,,,,,,,cLoad,.T.,.T.)  

    lRet := .T.
    
	MV_PAR01 := ParamLoad(cFileName,,1 ,MV_PAR01) 
	MV_PAR02 := ParamLoad(cFileName,,2 ,MV_PAR02) 
	MV_PAR03 := ParamLoad(cFileName,,3 ,MV_PAR03) 
	MV_PAR04 := ParamLoad(cFileName,,4 ,MV_PAR04) 
	MV_PAR05 := ParamLoad(cFileName,,5 ,MV_PAR05) 
	MV_PAR06 := ParamLoad(cFileName,,6 ,MV_PAR06) 
	MV_PAR07 := ParamLoad(cFileName,,7 ,MV_PAR07) 
	MV_PAR08 := ParamLoad(cFileName,,8 ,MV_PAR08) 
	MV_PAR09 := ParamLoad(cFileName,,9 ,MV_PAR09) 
	MV_PAR10 := ParamLoad(cFileName,,10,MV_PAR10) 
	MV_PAR11 := ParamLoad(cFileName,,11,MV_PAR11) 
	MV_PAR12 := ParamLoad(cFileName,,12,MV_PAR12) 
	MV_PAR13 := ParamLoad(cFileName,,13,MV_PAR13) 
	
	if Empty(MV_PAR02)
		MV_PAR02:= Repl("Z",TamSX3("Z06_EMPFIL")[1])
	endif

	if Empty(MV_PAR04)
		MV_PAR04:= Repl("Z",TamSX3("Z06_ROTINA")[1])
	endif
	
	if Empty(MV_PAR06)
		MV_PAR06:= Repl("Z",TamSX3("Z06_USER")[1])
	endif

	if empty(MV_PAR13) 
		MV_PAR13 := AllTrim(GetTempPath()) 	
	endif  	
endif
	
return lRet
