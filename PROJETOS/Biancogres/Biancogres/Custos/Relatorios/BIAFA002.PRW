#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BIAFA002
@author Artur Antunes
@since 10/05/2017
@version 1.0
@description Relatório de Custo Unitario
@obs OS 1172-17
@type function
/*/

User Function BIAFA002()

Local aArea     	:= GetArea()
Private oExcel      := nil 
private aPergs 		:= {}
 
Processa({|| fProcRel()},"Aguarde...","Carregando Registros...")

RestArea(aArea)  
return   

      
Static Function fProcRel()

Local cTab     	:= GetNextAlias() 
local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
local cTitulo   := "Relatório de Custo Unitario"  
local nRegAtu   := 0
local nTotReg   := 0
local cChave	:= ''
local cArqXML   := "BIAFA002_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
local cQuery	:= ''
local nDec1		:= TamSX3("D3_QUANT")[2]
local nDec2		:= TamSX3("D3_CUSTO1")[2]
local nDec3		:= 8

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

cQuery	:= " SELECT  D3_FILIAL, SUBSTRING(D3_EMISSAO, 1, 6) PERIODO , " + CRLF
cQuery	+= "         D3_EMISSAO , " + CRLF
cQuery	+= "         CASE WHEN D3_TM > '500' THEN 'SAIDA' " + CRLF
cQuery	+= "              ELSE 'ENTRADA' " + CRLF
cQuery	+= "         END OPERACAO , " + CRLF
cQuery	+= "         D3_DOC , " + CRLF
cQuery	+= "         D3_NUMSEQ , " + CRLF
cQuery	+= "         D3_TM , " + CRLF
cQuery	+= "         D3_CF , " + CRLF
cQuery	+= "         D3_COD , " + CRLF
cQuery	+= "         SUBSTRING(B1_DESC, 1, 70) DESCR , " + CRLF
cQuery	+= "         B1_TIPO , " + CRLF
cQuery	+= "         B1_GRUPO , " + CRLF
cQuery	+= "         BM_DESC , " + CRLF
cQuery	+= "         D3_QUANT , " + CRLF
cQuery	+= "         D3_CUSTO1 , " + CRLF
cQuery	+= "         D3_CUSTO1 / D3_QUANT MEDIO , " + CRLF
cQuery	+= "         D3_CUSTO1 / D3_QUANT MEDMEDIO , " + CRLF
cQuery	+= "         D3_CUSTO1 / D3_QUANT MINMEDIO , " + CRLF
cQuery	+= "         D3_CUSTO1 / D3_QUANT MAXMEDIO " + CRLF
cQuery	+= " FROM    "+RetSqlName("SD3")+" SD3 " + CRLF
cQuery	+= "         JOIN "+RetSqlName("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' " + CRLF
cQuery	+= "                            AND B1_COD = D3_COD " + CRLF
cQuery	+= "                            AND SB1.D_E_L_E_T_ = ' ' " + CRLF
cQuery	+= "         JOIN "+RetSqlName("SBM")+" SBM ON BM_FILIAL = '"+xFilial("SBM")+"' " + CRLF
cQuery	+= "                            AND BM_GRUPO = B1_GRUPO " + CRLF
cQuery	+= "                            AND SBM.D_E_L_E_T_ = ' ' " + CRLF
cQuery	+= " WHERE   D3_FILIAL = '01' " + CRLF
cQuery	+= "         AND D3_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' " + CRLF
cQuery	+= "         AND D3_QUANT <> 0 " + CRLF
cQuery	+= "  		 AND D3_FILIAL = '"+xFilial("SD3")+"' " + CRLF
if !Empty(MV_PAR03)
	cQuery	+= "  		AND SBM.BM_GRUPO IN " + FormatIn(Alltrim(MV_PAR03),";") + " " + CRLF
endif
cQuery	+= "         AND SD3.D_E_L_E_T_ = ' ' " + CRLF
cQuery	+= " ORDER BY SD3.D3_FILIAL,D3_EMISSAO,SD3.D3_COD " + CRLF

TcQuery cQuery Alias (cTab) New
(cTab)->(DbGoTop())
Count To nTotReg 
if nTotReg < 1
	MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
	return
endif
(cTab)->(dbGoTop())
nTotReg += 2
ProcRegua(nTotReg)
   
nRegAtu++
IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

oExcel := ARSexcel():New() 
oExcel:AddPlanilha('Relatorio',{20,50,80,80,80,80,80,80,80,80,150,80,80,150,90,90,90,90,90,90,20},6)
oExcel:AddLinha(20)
oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,18) 
oExcel:AddLinha(15)
oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,18) 
oExcel:AddLinha(15)
oExcel:AddLinha(20)
oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,18)  
    
oExcel:AddLinha(20)
oExcel:AddLinha(12) 
oExcel:AddCelula()  
oExcel:AddCelula("Filial"  				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Periodo"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Emissao"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Operação"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Doc"		  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Num. Seq"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("TM"		  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("CF"		  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Produto"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Descrição"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Tipo"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Grupo"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Desc. Grupo"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Quantidade"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Custo total"	  		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Custo Medio"			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Custo Med Medio"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Custo Min Medio"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Custo Max Medio"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
                  
While !(cTab)->(Eof())
	
	nRegAtu++
	if MOD(nRegAtu,2) > 0 
        cCorFun2 := '#DCE6F1'
	else
		cCorFun2 := '#B8CCE4'
	endif	  

	oExcel:AddLinha(14) 
	oExcel:AddCelula()   			

	oExcel:AddCelula( (cTab)->D3_FILIAL	 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->PERIODO	 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( stod((cTab)->D3_EMISSAO) 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->OPERACAO	 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->D3_DOC	 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->D3_NUMSEQ	 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->D3_TM	 		,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->D3_CF	 		,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->D3_COD	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->DESCR	 		,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B1_TIPO	 	,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->B1_GRUPO	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->BM_DESC	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->D3_QUANT		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->D3_CUSTO1		,nDec2	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->MEDIO		 	,nDec3	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->MEDMEDIO		,nDec3	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->MINMEDIO		,nDec3	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->MAXMEDIO		,nDec3	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

   	(cTab)->(DbSkip())                
EndDo    

fGeraParametros()
oExcel:SaveXml(Alltrim(MV_PAR04),cArqXML,.T.) 

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

aPergs[1,3] := MV_PAR01 
aPergs[2,3] := MV_PAR02  
aPergs[3,3] := MV_PAR03     
aPergs[4,3] := MV_PAR04     

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

local cLoad	    := "BIAFA002" + cEmpAnt
local cFileName := RetCodUsr() +"_"+ cLoad
local lRet		:= .F.

MV_PAR01 := stod('')
MV_PAR02 := stod('')
MV_PAR03 := space(170)
MV_PAR04 := space(170)

aAdd( aPergs ,{1,"Emissão De? " 	,MV_PAR01 ,""  ,"NAOVAZIO()"  ,''     ,'.T.',90,.F.})	
aAdd( aPergs ,{1,"Emissão Até?" 	,MV_PAR02 ,""  ,"NAOVAZIO()"  ,''     ,'.T.',90,.F.})	
aAdd( aPergs ,{1,"Grupos:"	   		,MV_PAR03 ,"@!","U_BIAFA003()",''     ,'.T.',90,.F.})	
aAdd( aPergs ,{6,"Pasta Destino" 	,MV_PAR04 ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	
If ParamBox(aPergs ,"Relatório de Custo Unitario",,,,,,,,cLoad,.T.,.T.)  

    lRet := .T.
 	MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01) 
	MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)     
	MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03) 
	MV_PAR04 := ParamLoad(cFileName,,4,MV_PAR04) 
	
	MV_PAR03 := Alltrim(MV_PAR03)
	MV_PAR03 := StrTran(MV_PAR03,'|',';')
	MV_PAR03 := StrTran(MV_PAR03,'/',';')
	MV_PAR03 := StrTran(MV_PAR03,'\',';')
	MV_PAR03 := StrTran(MV_PAR03,',',';')
	if substr(MV_PAR03,Len(MV_PAR03),1) <> ';'
		MV_PAR03 += ';'
	endif	

	if empty(MV_PAR04) 
		MV_PAR04 := AllTrim(GetTempPath()) 	
	endif  		
endif
	
return lRet

