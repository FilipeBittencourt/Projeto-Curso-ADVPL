#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"                
#INCLUDE "RWMAKE.CH"       
#INCLUDE "PRCONST.CH"                        

User Function TExcel()

Local aHeader := {}
Local aItens := {}

aAdd(aHeader,{"Teste1","C"})
aAdd(aHeader,{"Teste2","N"})
aAdd(aHeader,{"Teste3","C"})
aAdd(aHeader,{"Teste4","N"})

aAdd(aItens,{"A",2,"B",4})
aAdd(aItens,{"A",2,"B",4})
aAdd(aItens,{"A",2,"B",4})
aAdd(aItens,{"A",2,"B",4})

U_DadExcel(aHeader,aItens)

Return

User Function DadExcel(aHeader,aItens, cArquivo)

/*
aHeader
1 - Nome da Coluna
2 - Tipo de Dado da Coluna ["D","C","N"]
*/

Local cDirDocs := MsDocPath()
Local cPath //:= AllTrim(GetTempPath())
Local oExcelApp
Local nHandle
Local cCrLf := Chr(13) + Chr(10)
Local nX
Local _cArq := "" 
Local cDataChar                
                          
Default cArquivo := CriaTrab(,.F.)

cPath := cGetFile("Arquivo CSV ( *.CSV ) |*.CSV|",,,"C:\",.T.,GETF_RETDIRECTORY+GETF_LOCALHARD)

If Empty(cPath)
	Return
Endif 

AADD(aHeader, {"", "C"})
aEval(aItens, {|e|, AADD(e, "")})

nHandle := MsfCreate(cDirDocs+"\"+cArquivo+".CSV",0)
 
If nHandle > 0
	
	aEval(aHeader, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aHeader), ";", "") ) } )
	fWrite(nHandle, cCrLf ) // Pula linha
	
	For _Na := 1 To Len(aItens)
		
		For _Ni := 1 To Len(aHeader)
			
			_uValor := ""
			
			If aHeader[_ni,2] == "D" // Trata campos data
				cDataChar := dtoc(aItens[_Na,_Ni])
				_uValor := cDataChar
			Elseif aHeader[_ni,2] == "N" // Trata campos numericos
				_uValor := Replace(Alltrim(Str(aItens[_Na,_Ni])), ".", ",")
			Elseif aHeader[_ni,2] == "C" // Trata campos caracter
				_uValor := '="' + aItens[_Na,_Ni]+ '"'
			Endif
			
			/*            
			ConOut("_Na" + Str(_Na))
			ConOut("_Ni" + Str(_Ni))
			ConOut("_uValor" + _uValor)			   	
			*/
			If _ni <> len(aHeader)
				fWrite(nHandle, _uValor + ";" )
			Endif
			
		Next _Ni
		
		fWrite(nHandle, cCrLf )
		
	Next _Na
	
	fClose(nHandle)
	CpyS2T( cDirDocs+"\"+cArquivo+".CSV" , cPath, .T. )
	
	If (ApOleClient( 'MsExcel' ))
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open( cPath+cArquivo+".CSV" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)
	EndIf
	
Else
	MsgAlert("Falha na criação do arquivo")
	
EndIf

Return
