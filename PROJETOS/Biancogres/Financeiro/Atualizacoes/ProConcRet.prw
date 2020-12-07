#INCLUDE "RWMAKE.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "TOTVS.CH"


//----------------------------------------------------------------------------
// Desenv	: Thiago Dantas
// Data	    : 18/09/14
// Desc		: Processa CONCILIACAO Serasa	
//----------------------------------------------------------------------------
User Function ProConcRet()
Local cSvAlias := Alias()
Local lAchou := .F.

Local cTipo := "Modelo de Documentos(*.*) |*.*| "
Local cNewPathArq := cGetFile( cTipo , "Selecione o arquivo " )
 
IF !Empty( cNewPathArq )
	//IF Upper( Subst( AllTrim( cNewPathArq), - 2 ) ) == Upper( AllTrim( "00" ) )
		//Aviso( "Arquivo Selecionado" , cNewPathArq , { "OK" } )
		If(MSGYESNO("Foi selecionado um arquivo válido! Gostaria de Processá-lo?","CONCILIACAO"))
			Processa(ProcRet(cNewPathArq))	
		Else
			MsgInfo("Processamento do arquivo cancelado!","CONCILIACAO",{ "OK" } )
			Return
		EndIf
	/*Else
		MsgAlert( "Arquivo Invalido " )
		Return
	EndIF*/
Else
	Aviso("Cancelada a Selecao!","Voce cancelou a selecao do arquivo." ,{ "OK" } )
	Return
EndIF

Return

//----------------------------------------------------------------------------
Static Function ProcRet(cArquivo)
Local	cDataComp 	:= ""
Local	cPeriod		:= ""
Local	cTitulo 	:= ""
Local	cNovoArq	:= ""
Local 	cDrive 		:= ""
Local 	cDir 		:= ""
Local 	cNomeArq 	:= ""
Local 	cExt 		:= ""
Local 	fArqIni
Local 	fArqNovo
Local 	Enter       := CHR(13)+CHR(10)


SplitPath( cArquivo, @cDrive, @cDir, @cNomeArq, @cExt )
 
cNovoArq := cDrive + cDir + cNomeArq +"_proc.C00"

nY 			:= 1
Enter       := CHR(13)+CHR(10)

//Monta Regua 
ProcRegua(10)		

IncProc("Processando Arquivo...")

lAchou 	:= .F.
lErro   := .F.
fArqIni := FT_FUSE(cArquivo)

If fArqIni > 0
	
	If File(cNovoArq)
		cNumVer := '1'
	    While(File(cNovoArq))
	    	cNumVer		:= Soma1(cNumVer) 
	    	cNovoArq 	:= cDir + cNomeArq +"_"+cNumVer+"_proc.C00"
	    End
	EndIf
	
	fArqNovo := FCreate(Upper(cNovoArq))
	
	// a primeira contém os dados da conciliacao.
	cBuffer 	:= FT_FREADLN()
	cDataComp	:= Substr(cBuffer,45,8) // data de competencia
	cPeriod 	:= Substr(cBuffer,53,1) // Periodicidade (D=Diário M=Mensal S=Semanal Q=Quinzenal)

	fWrite(fArqNovo,cBuffer+Enter)
	
	//Pula a primeira linha... e que comecem os jogos.    
	FT_FSKIP()
	
	While !FT_FEOF()
		
		IncProc()
		
		cBuffer := FT_FREADLN()
		
		If Substr(cBuffer,1,2) != '99'
			cTitulo := Substr(cBuffer,68,33)
			
			//Se Mensal, verificar se os títulos foram pagos no mês.
			// Como só vamos fazer mensal... então...
			//If cPeriod == "M" 
				//posiciono no SE1
				dbSelectArea("SE1")
				If (dbSeek(xFilial("SE1")+ Substr(alltrim(cTitulo),1,len(alltrim(cTitulo)))))
					//se pagou, substitui no arquivo.
					If!Empty(dtoS(SE1->E1_BAIXA)) .And. dtoS(SE1->E1_BAIXA) <= cDataComp //.And. Substr(dtoS(SE1->E1_BAIXA),1,6) == Substr(cDataComp,1,6)
						cLinRet := Substr(cBuffer,1,57)+ AllTrim(dtoS(SE1->E1_BAIXA)) + Substr(cBuffer,66,65) 	
					Else
						cLinRet := Substr(cBuffer,1,57)+ Space(8) + Substr(cBuffer,66,65) 
					EndIf	
				Else
					Alert("Não foi possível econtrar o Título "+cTitulo+" contido no arquivo. Por padrão será lançado como não pago.")
					cLinRet := Substr(cBuffer,1,57)+ Space(8) + Substr(cBuffer,66,65)
				EndIf
				
				fWrite(fArqNovo,cLinRet+Enter)
				
			//Se diário, verificar se os títulos foram pagos até no dia.
			//ElseIf cPeriod == "D" 
			  //(...)
			//EndIf
		Else
			fWrite(fArqNovo,cBuffer+Enter)
		EndIf
		
		FT_FSKIP()	
	End
	FT_FUSE()
	FCLOSE(fArqNovo)
	MsgInfo("A operação foi realizada com sucesso! Gerado o arquivo " +cNovoArq, "CONCILIACAO")
Else
	MsgInfo("Não foi possível abrir o arquivo!", "CONCILIACAO") 
EndIf	
Return
//---------------------------------------------------------------------------- 