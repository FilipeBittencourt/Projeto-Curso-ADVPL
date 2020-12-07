#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE F_BLOCK 1024 // Define o bloco de Bytes a serem lidos / gravados por vez

/*
##############################################################################################################
# PROGRAMA...: BIA186         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 03/12/2013                      
# DESCRICAO..: Rotina Para Utilizacao do EDI& no Windows 7 x64
##############################################################################################################
# ALTERACAO..:
# AUTOR......:
# MOTIVO.....:
##############################################################################################################
*/
User Function BIA186()

Local cFileINI	:= "C:\Serasa\Edi7Tcp_Serasa\ft.ini"
Local cFileEXE := "C:\Serasa\Edi7Tcp_Serasa\EDI7TCP.exe"

Local cFile := GetSrvProfString("StartPath", "") + "ft.ini"                          
Local cFileExe
Local cCodigo
Local cProduto
Local cBuffer 			:= SPACE(F_BLOCK)
Local nHandle   
Local nHOrigem := -1
Local nHDestino := -1
Local nBytesLidos , nBytesFalta , nTamArquivo
Local nBytesLer , nBytesSalvo
Local lCopiaOk := .T.
Local ENTER		:= CHR(13)+CHR(10)
Local lCopy := .F.


Private cPerg := 'BIA186' 


ValPerg()

If !Pergunte(cPerg,.T.)
	Return
EndIf    

Do Case
	Case MV_PAR01 == 1		//BIANCOGRES
		cCodigo := 	'17401___'
	Case MV_PAR01 == 2       //INCESA
		cCodigo := 	'28761___'
	Case MV_PAR01 == 3       //LM
		cCodigo := 	'30848___'
EndCase

Do Case
	Case MV_PAR02 == 1		//RELATO
		cProduto := '012'
	Case MV_PAR02 == 2       //PEFIN
		cProduto := '008'
EndCase

If File(cFileINI)
	
 	CpyS2T(cFile, StrTran(cFileINI, "\ft.ini"))
		 
	// Abre o arquivo de Origem
	nHOrigem := FOPEN(cFileINI, FO_READWRITE)
	cFileExe := cFileEXE
	
EndIf

If nHOrigem == -1
	MsgStop('Erro ao abrir o Arquivo de Configuracao. Ferror = '+str(ferror(),4),'Erro')
	Return .F.
EndIf
	

// Determina o tamanho do arquivo de origem
nTamArquivo := Fseek(nHOrigem,0,2)
// Move o ponteiro do arquivo de origem para o inicio do arquivo
Fseek(nHOrigem,0)


// Define que a quantidade que falta copiar é o próprio tamanho do Arquivo
nBytesFalta := nTamArquivo
// Enquanto houver dados a serem copiados
While nBytesFalta > 0
	// Determina quantidade de dados a serem lidos
	nBytesLer := Min(nBytesFalta , F_BLOCK )
	// lê os dados do Arquivo
	nBytesLidos := FREAD(nHOrigem, @cBuffer, nBytesLer )
	// Determina se não houve falha na leitura
	If nBytesLidos < nBytesLer
		MsgStop( "Erro de Leitura da Origem. "+;
		Str(nBytesLer,8,2)+" bytes a LER."+;
		Str(nBytesLidos,8,2)+" bytes Lidos."+;
		"Ferror = "+str(ferror(),4),'Erro')
		lCopiaOk := .F.
		Exit
	Endif
	// Salva os dados lidos 
	//cBuffer := Substr(cBuffer,1,7)+"Cliente="+cCodigo+Substr(cBuffer,24,nBytesFalta)
	cBuffer := Substr(cBuffer,1,7)+"Cliente="+cCodigo+ENTER+"Produto="+cProduto+Substr(cBuffer,37,nBytesFalta)       
	FSEEK(nHOrigem,0,0)
	nBytesSalvo := FWRITE(nHOrigem, cBuffer,nBytesLer)	
	// Determina se não houve falha na gravação
	If nBytesSalvo < nBytesLer
		MsgStop("Erro de gravação do Destino. "+;
		Str(nBytesLer,8,2)+" bytes a SALVAR."+;
		Str(nBytesSalvo,8,2)+" bytes gravados."+;
		"Ferror = "+str(ferror(),4),'Erro')
		lCopiaOk := .F.
		EXIT
	Endif

// Elimina do Total do Arquivo a quantidade de bytes copiados
	nBytesFalta -= nBytesLer
Enddo

FCLOSE(nHOrigem)     

If lCopiaOk
	//WinExec(cFileEXE)
	WinExec(cFileExe)

Else
	MsgStop( 'Falha na Gravação do Arquivo de Configuração. Verifique.')
Endif
Return

/*
##############################################################################################################
# PROGRAMA...: ValPerg         
# AUTOR......: Rubens Junior (FACILE SISTEMAS)
# DATA.......: 03/12/2013                      
# DESCRICAO..: Funcao para criar o grupo de perguntas SX1 se nao existir
##############################################################################################################
*/
Static Function ValPerg()
Local i,j,nX
Local aTRegs := {}
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

cPerg := PADR(cPerg,10)
                                                                                                                                           
aAdd(aTRegs,{"Empresa"	,"N",1,0,0,"C","","Biancogres","Incesa","LM","","","","Escolha a empresa em que deseja abrir o Programa do Serasa."})
aAdd(aTRegs,{"Produto"	,"N",1,0,0,"C","","Relato","Pefin","","","","","Escolha o produto que deseja enviar."})

//Criar aRegs na ordem do vetor Temporario
aRegs := {}
For I := 1 To Len(aTRegs)
	aAdd(aRegs,{cPerg, StrZero(I,2), aTRegs[I][1], aTRegs[I][1], aTRegs[I][1],;
	"mv_ch"+Alltrim(Str(I)), aTRegs[I][2],aTRegs[I][3],aTRegs[I][4],aTRegs[I][5],;
	aTRegs[I][6],aTRegs[I][7],"mv_par"+StrZero(I,2),aTRegs[I][8],"","","","",;
	aTRegs[I][9],"","","","",aTRegs[I][10],"","","","",aTRegs[I][11],"","","",;
	"",aTRegs[I][12],"","","",aTRegs[I][13],""})
Next I

//Grava no SX1 se ja nao existir
dbSelectArea("SX1")
For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Else
		RecLock("SX1",.F.)
		For j:=3 to FCount()
			If j <= Len(aRegs[i])
				If SubStr(FieldName(j),1,6) <> "X1_CNT"
					FieldPut(j,aRegs[i,j])
				EndIf
			Endif
		Next
		MsUnlock()
	EndIf
	
	//HELP DAS PERGUNTAS
	aHelpPor := {}
	__aRet := STRTOKARR(aTRegs[I][14],"#")
	FOR nX := 1 To Len(__aRet)
		AADD(aHelpPor,__aRet[nX])
	NEXT nX
	PutSX1Help("P."+AllTrim(cPerg)+aRegs[i,2]+".",aHelpPor,aHelpEng,aHelpSpa)
	
Next

RETURN
