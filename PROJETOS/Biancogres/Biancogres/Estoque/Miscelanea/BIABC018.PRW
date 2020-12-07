#INCLUDE "Protheus.ch"
#INCLUDE "TOTVS.CH"

#DEFINE ENTER CHR(13)+CHR(10)

/*/{Protheus.doc} BIABC018
@author Barbara Coelho	  
@since 16/10/2020
@version 1.0
@description Rotina para importar os arquivos do inventário do almoxarifado para a tabela SB7 
@type function
/*/

/*
B7_STATUS:
"1" - Inventário ainda não processado pelo SIGAACD.
"2" - Inventário processado pelo SIGAACD.
*/

User Function BIABC018()
	Processa({|| RptDetail()})
Return

Static Function RptDetail()
	private aPergs   := {}
	private cDirDest := space(170)

	If !ValidPerg()
		Return
	EndIf

	LeArquivo(cDirDest)
return

Static function LeArquivo(cFile)    
    Local oFile     :=  Nil
    Local cSplit    := ';'
    Local cProd     := ''
    Local nQuant	:= 0
    Local cEndereco := ''
    
    oFile := FWFileReader():New(cFile)    
    
    If (oFile:Open())
    	Do while (oFile:hasLine())
    		cProd		:= ''
    		nQuant		:= 0
    		cEndereco	:= ''
    		cLinha		:= oFile:GetLine()
    		aRetLinha	:= StrTokArr( cLinha,  cSplit )            
            
    		If (aRetLinha[1] != Nil .And. aRetLinha[2] != Nil)         			
    			cProd  := aRetLinha[1]            
    			nQuant := Val(StrTran(StrTran(aRetLinha[2],".",""),",","."))
    			if len(aRetLinha) = 3
    				if (aRetLinha[3]) =! Nil
    					cEndereco := aRetLinha[3]
    				end if
	    		end if   			

    			DbSelectArea('SB1')
    			SB1->(DbSetOrder(1))    
                
    			If (SB1->(DbSeek(xFilial('SB1')+cProd)))
    				RecLock('SB7', .T.)
    				SB7->B7_FILIAL	:= ""
    				SB7->B7_COD		:= cProd
    				SB7->B7_LOCAL	:= MV_PAR02//IIF( TRIM(MV_PAR02) = '1',  '01', '20' )    				
    				SB7->B7_TIPO    := SB1->B1_TIPO
    				SB7->B7_DOC     := 'IN'+substr( dtoc(MV_PAR01),1,2)+substr( dtoc(MV_PAR01),4,2)
    				SB7->B7_QUANT	:= nQuant
    				SB7->B7_DATA    := MV_PAR01
    				SB7->B7_LOCALIZ := cEndereco
    				
    				SB7-> (MsUnlock())                      
                EndIf    
            EndIf
       End Do    
       oFile:Close()
    EndIf 
Return

Static Function ValidPerg()
	local cLoad	    := "BIABC018" + cEmpAnt
	local cFileName := RetCodUsr() +"_"+ cLoad
	local lRet		:= .F.
	local aOpcs 	:= {"01","20"}
	Local aPergs	:=	{}
	cArquivo		:= space(100) 

	MV_PAR01 := STOD('')
	MV_PAR02 := SPACE(50)
	MV_PAR03 := space(100) 

	aAdd( aPergs ,{1,"Data Inventário: " ,MV_PAR01 ,""  ,"NAOVAZIO()",''  ,'.T.',50,.F.})
	aAdd( aPergs ,{2,"Almoxarifado   : " ,MV_PAR02 ,aOpcs,60,'.T.',.F.})
	aAdd( aPergs ,{6,"Arquivo        : " ,MV_PAR03  ,"","","", 75 ,.T.,"Arquivo * |*",,GETF_LOCALHARD+GETF_NETWORKDRIVE})	

	If ParamBox(aPergs ,"Importar Arquivo do Inventário",,,,,,,,cLoad,.T.,.T.)  
		lRet := .T.
		MV_PAR01 := ParamLoad(cFileName,,1,MV_PAR01)
		MV_PAR02 := ParamLoad(cFileName,,2,MV_PAR02)
		MV_PAR03 := ParamLoad(cFileName,,3,MV_PAR03)
		cDirDest	:=	MV_PAR03

		if empty(MV_PAR03) 
			MV_PAR03 := AllTrim(GetTempPath()) 	
		endif
	EndIf
Return lRet
