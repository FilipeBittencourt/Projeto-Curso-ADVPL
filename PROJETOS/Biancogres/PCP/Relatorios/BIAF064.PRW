#Include 'Protheus.ch'

/*/{Protheus.doc} BIAF064
@author Artur Antunes
@since 24/02/2017
@version 1.0
@description Relatório de alterações realizadas pela rotina de ajuste de empenho (BIA556)
@obs Relatório de Backup - OS 0871-16
@type function
/*/

/*/{Protheus.doc} BIAF064
@author Artur Antunes
@since 06/04/2017
@version 1.0
@description Inclusão dos campos produto pai(codigo e descrição) e camada. Conversão para modelo excel
@obs OS: 0963-17
@type function
/*/
                                       
User Function BIAF064()

Local aArea     	:= GetArea()
private cFilDe		:= space(TAMSX3("Z05_FILIAL")[1])
private cFilAte		:= space(TAMSX3("Z05_FILIAL")[1])
private cProdDe		:= space(TAMSX3("Z05_PRODUT")[1])
private cProdAte	:= space(TAMSX3("Z05_PRODUT")[1])
private cLoteDe		:= space(TAMSX3("Z05_LOTCTL")[1])
private cLoteAte	:= space(TAMSX3("Z05_LOTCTL")[1])
private cLocalDe	:= space(TAMSX3("Z05_LOCAL")[1])
private cLocalAte	:= space(TAMSX3("Z05_LOCAL")[1])
private cOpDe		:= space(TAMSX3("Z05_OP")[1])
private cOpAte		:= space(TAMSX3("Z05_OP")[1])
private dDtAltDe  	:= STOD('')   
private dDtAltAte 	:= STOD('')    
Private oExcel      := nil 
private cDirDest    := space(170)
private aPergs 		:= {}
 
Processa({|| fProcRel()},"Aguarde...","Carregando Titulos...")

RestArea(aArea)  
return   

      
Static Function fProcRel()

Local cTab     	:= GetNextAlias() 
local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
local cTitulo   := "Relatório de alterações realizadas pela rotina de ajuste de empenho (BIA556)"  
local nRegAtu   := 0
local nTotReg   := 0
local cChave	:= ''
local cArqXML   := "BIAF064_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))

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

If !fPergunte()
	Return
endif	

ProcRegua(0)

BeginSql alias cTab
%noparser%  

SELECT X.*,
	   ISNULL(C2.C2_PRODUTO,'') CODPAI,
	   ISNULL(SB1.B1_DESC,'') DESCPAI,
	   (CASE 
	   		WHEN X.Z05_QUANT > 0 AND X.Z05_OP <> '' 
	   			THEN X.Z05_QUANT / ISNULL(C2.C2_QUANT,1) 
	   		ELSE 0 
	   	END ) CAMADA,
	   (CASE 
			WHEN X.SEQ = '999'
				THEN 'Atual'
			ELSE 'Backup'
		END) TPREG
FROM (
		SELECT  
				Z05_TABELA,
				Z05_RECORI,
				SEQ = REPLICATE('0',3-LEN(X.SEQ))+cast(X.SEQ as varchar(3)),
				Z05_ORIBKP,
				Z05_ORBKDE,		
				Z05_DTALT,
				Z05_HRALT,
				Z05_USRALT,
				Z05_FILIAL,
				Z05_PRODUT,
				Z05_LOCAL,
				Z05_OP,
				Z05_EMISSA,
				Z05_TMTRT,
				Z05_QUANT,
				Z05_LOTCTL,
				Z05_NUMLOT,
				Z05_LOCALZ,
				Z05_DTVALI
		FROM (	
				SELECT Z1.*, 
				SEQ = ROW_NUMBER() OVER(PARTITION BY Z05_ORIBKP,Z05_TABELA,Z05_RECORI ORDER BY Z05_ORIBKP,Z05_TABELA,Z05_RECORI,Z05_DTALT,Z05_HRALT)   
				FROM %TABLE:Z05% (NOLOCK) Z1
				WHERE Z05_FILIAL BETWEEN %exp:cFilDe% AND %exp:cFilAte%
				 AND Z05_PRODUT  BETWEEN %exp:cProdDe% AND %exp:cProdAte%
				 AND Z05_LOTCTL  BETWEEN %exp:cLoteDe% AND %exp:cLoteAte%
				 AND Z05_LOCAL   BETWEEN %exp:cLocalDe% AND %exp:cLocalAte%
				 AND Z05_OP      BETWEEN %exp:cOpDe% AND %exp:cOpAte%
				 AND Z05_DTALT 	 BETWEEN %exp:DtoS(dDtAltDe)% AND %exp:DtoS(dDtAltAte)%
				 AND D_E_L_E_T_ = ''
			  ) X 
		
	   UNION ALL
		
		SELECT 
				Z05_TABELA = 'SD4',
				Z05_RECORI = SD4.R_E_C_N_O_,
				SEQ = '999',
				Z05_ORIBKP = '',
				Z05_ORBKDE = '',
				Z05_DTALT = '',
				Z05_HRALT = '',
				Z05_USRALT = '',
				Z05_FILIAL = SD4.D4_FILIAL,
				Z05_PRODUT = SD4.D4_COD,
				Z05_LOCAL = SD4.D4_LOCAL,
				Z05_OP = SD4.D4_OP,
				Z05_EMISSA = SD4.D4_DATA,
				Z05_TMTRT = SD4.D4_TRT,
				Z05_QUANT = SD4.D4_QUANT,
				Z05_LOTCTL = SD4.D4_LOTECTL,
				Z05_NUMLOT = SD4.D4_NUMLOTE,
				Z05_LOCALZ = '',
				Z05_DTVALI = SD4.D4_DTVALID
		FROM %TABLE:SD4% (NOLOCK) SD4
		WHERE 
		EXISTS (SELECT * FROM %TABLE:Z05% (NOLOCK) Z1
				WHERE Z1.Z05_RECORI = SD4.R_E_C_N_O_
				 AND Z1.Z05_TABELA = 'SD4'
				 AND Z1.Z05_FILIAL  BETWEEN %exp:cFilDe% AND %exp:cFilAte%
				 AND Z1.Z05_PRODUT  BETWEEN %exp:cProdDe% AND %exp:cProdAte%
				 AND Z1.Z05_LOTCTL  BETWEEN %exp:cLoteDe% AND %exp:cLoteAte%
				 AND Z1.Z05_LOCAL   BETWEEN %exp:cLocalDe% AND %exp:cLocalAte%
				 AND Z1.Z05_OP      BETWEEN %exp:cOpDe% AND %exp:cOpAte%
				 AND Z1.Z05_DTALT 	BETWEEN %exp:DtoS(dDtAltDe)% AND %exp:DtoS(dDtAltAte)%
				 AND Z1.D_E_L_E_T_ = '') 
		 
	  UNION ALL
		
		SELECT 
				Z05_TABELA = 'SD3',
				Z05_RECORI = SD3.R_E_C_N_O_,
				SEQ = '999',
				Z05_ORIBKP = '',
				Z05_ORBKDE = '',
				Z05_DTALT = '',
				Z05_HRALT = '',
				Z05_USRALT = '',
				Z05_FILIAL = SD3.D3_FILIAL,
				Z05_PRODUT = SD3.D3_COD,
				Z05_LOCAL = SD3.D3_LOCAL,
				Z05_OP = SD3.D3_OP,
				Z05_EMISSA = SD3.D3_EMISSAO,
				Z05_TMTRT = SD3.D3_TM,
				Z05_QUANT = SD3.D3_QUANT,
				Z05_LOTCTL = SD3.D3_LOTECTL,
				Z05_NUMLOT = SD3.D3_NUMLOTE,
				Z05_LOCALZ = SD3.D3_LOCALIZ,
				Z05_DTVALI = SD3.D3_DTVALID
		FROM %TABLE:SD3% (NOLOCK) SD3
		WHERE 
		EXISTS (SELECT * FROM %TABLE:Z05% (NOLOCK) Z1
				WHERE Z1.Z05_RECORI = SD3.R_E_C_N_O_
				AND Z1.Z05_TABELA = 'SD3'
				 AND Z1.Z05_FILIAL  BETWEEN %exp:cFilDe% AND %exp:cFilAte%
				 AND Z1.Z05_PRODUT  BETWEEN %exp:cProdDe% AND %exp:cProdAte%
				 AND Z1.Z05_LOTCTL  BETWEEN %exp:cLoteDe% AND %exp:cLoteAte%
				 AND Z1.Z05_LOCAL   BETWEEN %exp:cLocalDe% AND %exp:cLocalAte%
				 AND Z1.Z05_OP      BETWEEN %exp:cOpDe% AND %exp:cOpAte%
				 AND Z1.Z05_DTALT 	BETWEEN %exp:DtoS(dDtAltDe)% AND %exp:DtoS(dDtAltAte)%
				 AND Z1.D_E_L_E_T_ = '') 
	) X
LEFT JOIN %TABLE:SC2% (NOLOCK) C2 
 ON C2.C2_FILIAL = X.Z05_FILIAL
 AND C2.C2_NUM+C2.C2_ITEM+C2.C2_SEQUEN = LEFT(X.Z05_OP,8) + '001'
 AND C2.D_E_L_E_T_ = ''
 AND X.Z05_OP <> ''
LEFT JOIN %TABLE:SB1% (NOLOCK) SB1 
 ON SB1.B1_COD = C2.C2_PRODUTO
 AND SB1.D_E_L_E_T_ = ''
ORDER BY X.Z05_TABELA,X.Z05_RECORI,X.SEQ,X.Z05_ORIBKP,X.Z05_DTALT,X.Z05_HRALT
		
EndSql     

dbSelectArea(cTab)      
(cTab)->(dbGoTop()) 
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
oExcel:AddPlanilha('Relatorio',{20,50,60,50,60,50,175,90,50,80,50,80,80,80,80,60,50,80,60,60,80,150,100})
oExcel:AddLinha(20)
oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,21) 
oExcel:AddLinha(15)
oExcel:AddCelula(DATE(),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,21) 
oExcel:AddLinha(15)
oExcel:AddLinha(20)
oExcel:AddCelula(cTitulo,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,21)  
    
oExcel:AddLinha(20)
oExcel:AddLinha(12) 
oExcel:AddCelula()  
oExcel:AddCelula("Tabela"  					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("RecOri"	  				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Seq"  					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Tipo Reg."				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Oper."  					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Descrição da Operação"  	,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Data Alteração"  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Horario"  				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Usuario Alteração"		,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Filial"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Produto"  				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Descrição do Produto"		,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Almoxarifado"  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("OP"  						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Emissão"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("TR/TM"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Quantidade"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Lote"						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("DT Validade"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Prod. Pai"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Descr. Pai"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Camada"					,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
                  
While !(cTab)->(Eof())
	
	if cChave <> Alltrim(STR((cTab)->Z05_RECORI))
		if cCorFun2 == '#B8CCE4'
			cCorFun2 := '#DCE6F1'
		else
			cCorFun2 := '#B8CCE4'
		endif	
	endif 

	oExcel:AddLinha(14) 
	oExcel:AddCelula()
	
	hdDescr := Substr(Posicione("SB1", 1, xFilial("SB1") + (cTab)->Z05_PRODUT, "B1_DESC"),1,70)   			

	oExcel:AddCelula( (cTab)->Z05_TABELA	 	,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_RECORI	 	,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->SEQ	 			,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->TPREG	 			,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_ORIBKP	 	,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_ORBKDE		,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->Z05_DTALT) 	,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_HRALT	 		,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_USRALT	 	,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_FILIAL	 	,2,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_PRODUT	 	,2,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula(  hdDescr            	 	,2,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_LOCAL			,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_OP			,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->Z05_EMISSA)	,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_TMTRT	 		,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_QUANT	 		,9,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->Z05_LOTCTL	 	,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( STOD((cTab)->Z05_DTVALI)	,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->CODPAI	 		,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->DESCPAI	 		,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->CAMADA	 		,9,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

	cChave := Alltrim(STR((cTab)->Z05_RECORI))

	nRegAtu++
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

aPergs[1 ,3] := cFilDe        
aPergs[2 ,3] := cFilAte 
aPergs[3 ,3] := cProdDe 
aPergs[4 ,3] := cProdAte  
aPergs[5 ,3] := cLoteDe     
aPergs[6 ,3] := cLoteAte  
aPergs[7 ,3] := cLocalDe  	      
aPergs[8 ,3] := cLocalAte       
aPergs[9 ,3] := cOpDe         
aPergs[10,3] := cOpAte         
aPergs[11,3] := dDtAltDe         
aPergs[12,3] := dDtAltAte         
aPergs[13,3] := cDirDest         

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

local cLoad	    := "BIAF064" + cEmpAnt
local cFileName := RetCodUsr() +"_"+ cLoad
local LRet		:= .F.

aAdd( aPergs ,{1,"Filial de:"	   	,cFilDe  	,"",'.T.'		,""		,'.T.',50,.F.})	
aAdd( aPergs ,{1,"Filial Ate: "     ,cFilAte 	,"",'.T.'		,""		,'.T.',50,.F.})	

aAdd( aPergs ,{1,"Produto de:"	   	,cProdDe  	,"",'.T.'		,"SB1"	,'.T.',50,.F.})	
aAdd( aPergs ,{1,"Produto Ate: "    ,cProdAte 	,"",'.T.'		,"SB1"	,'.T.',50,.F.})	

aAdd( aPergs ,{1,"Lote de:"	   		,cLoteDe  	,"",'.T.'		,""		,'.T.',50,.F.})	
aAdd( aPergs ,{1,"Lote Ate: "     	,cLoteAte 	,"",'.T.'		,""		,'.T.',50,.F.})	

aAdd( aPergs ,{1,"Armazem de:"	   	,cLocalDe  	,"",'.T.'		,"NNR"	,'.T.',50,.F.})	
aAdd( aPergs ,{1,"Armazem Ate: "    ,cLocalAte 	,"",'.T.'		,"NNR"	,'.T.',50,.F.})	

aAdd( aPergs ,{1,"OP de:"	   		,cOpDe  	,"",'.T.'		,""		,'.T.',50,.F.})	
aAdd( aPergs ,{1,"OP Ate: "     	,cOpAte		,"",'.T.'		,""		,'.T.',50,.F.})	
   
aAdd( aPergs ,{1,"DT Alteração de: ",dDtAltDe  	,"","NAOVAZIO()",""		,'.T.',50,.F.})	
aAdd( aPergs ,{1,"DT Alteração Ate:",dDtAltAte 	,"","NAOVAZIO()",""		,'.T.',50,.F.})	

aAdd( aPergs ,{6,"Pasta Destino" 	,cDirDest   ,"","","", 90 ,.F.,"Diretorio . |*.",,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE} )		
	
If ParamBox(aPergs ,"Relatório - Log ajuste de empenho",,,,,,,,cLoad,.T.,.T.)  

    LRet := .T.
    
	cFilDe  	:= ParamLoad(cFileName,,1 ,cFilDe) 
	cFilAte 	:= ParamLoad(cFileName,,2 ,cFilAte)     
	cProdDe  	:= ParamLoad(cFileName,,3 ,cProdDe) 
	cProdAte 	:= ParamLoad(cFileName,,4 ,cProdAte)     
	cLoteDe  	:= ParamLoad(cFileName,,5 ,cLoteDe) 
	cLoteAte 	:= ParamLoad(cFileName,,6 ,cLoteAte)     
	cLocalDe  	:= ParamLoad(cFileName,,7 ,cLocalDe) 
	cLocalAte 	:= ParamLoad(cFileName,,8 ,cLocalAte)     
	cOpDe  		:= ParamLoad(cFileName,,9 ,cOpDe) 
	cOpAte 		:= ParamLoad(cFileName,,10,cOpAte)     
	dDtAltDe  	:= ParamLoad(cFileName,,11,dDtAltDe) 
	dDtAltAte 	:= ParamLoad(cFileName,,12,dDtAltAte)     
	cDirDest	:= ParamLoad(cFileName,,13,cDirDest)  
	
	if empty(cFilAte) 
		cFilAte := REPLICATE('Z',TamSX3("Z05_FILIAL")[1]) 
	endif  
	if empty(cProdAte) 
		cProdAte := REPLICATE('Z',TamSX3("Z05_PRODUT")[1]) 
	endif
	if empty(cLoteAte) 
		cLoteAte := REPLICATE('Z',TamSX3("Z05_LOTCTL")[1]) 
	endif  
	if empty(cLocalAte) 
		cLocalAte := REPLICATE('Z',TamSX3("Z05_LOCAL")[1]) 
	endif  
	if empty(cOpAte) 
		cOpAte := REPLICATE('Z',TamSX3("Z05_OP")[1]) 
	endif  	
	if empty(cDirDest) 
		cDirDest := AllTrim(GetTempPath()) 	
	endif  	
endif
	
return LRet
          


