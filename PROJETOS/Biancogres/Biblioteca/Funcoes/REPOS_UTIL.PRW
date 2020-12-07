#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
²±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²
²±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±²
²±±ºPrograma  ³ 		 ºAutor  ³ FERNANDO ROCHA     º Data ³  02/08/10   º±±²
²±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±²
²±±ºDesc.     ³ ROTINAS PARA MANIPULAR O REPOSITORIO DE IMAGENS DO PORTHEUSº±±²
²±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±²
²±±ºUso       ³ AP8                                                        º±±²
²±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±²
²±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±²
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ROTINA PARA INCLUIR IMAGENS NO REPOSITORIO DO PROTHEUS DE FORMA TRANSPARENTE PARA O USUARIO  
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
USER FUNCTION RIMGINC(cPathFile , cCNameImg, lReplace, cCodRet, cPergRep)
Local cFile	:= RetFileName( @cPathFile )
Local cExtFile := SubStr(cPathFile, Len(FileNoExt(cPathFile))+1)
Local cPath := SubStr(cPathFile,  1,   AT(cFile, Upper(cPathFile)) -1 )
Local cNPathFile := cPath + cCNameImg + cExtFile
Local lExist
Local oDlgAddImg

Default lReplace := .F.
Default cPergRep := ""

IF !FILE(cPathFile)
	MsgAlert("Arquivo a ser importado não existe","RIMGINC - IMPORTACAO DE IMAGENS")
	Return(.F.)
ENDIF

//Renomear o arquivo para o codigo da imagem passado no parametro
IF .NOT. (CpyS2T(cPathFile, cNPathFile))
	MsgAlert("Nao foi possivel renomear arquivo para o nome codigo da imagem","RIMGINC - IMPORTACAO DE IMAGENS")
	Return(.F.)
ENDIF

//Monta Dialogo "Escondido" para possibilitar a importacao  das imagens
DEFINE MSDIALOG oDlgAddImg FROM 0,0 TO 0,0 PIXEL

//Cria um Objeto do Tipo Repositorio
@ 000,000 REPOSITORY oRepository SIZE 0,0 OF oDlgAddImg

//Verificar se ja existe a imagem e deletar no caso de lReplace .T.
lExist := oRepository:ExistBmp(cCNameImg)
IF lExist
	IF lReplace
		If MsgNoYes(cPergRep+CRLF+"Tem certeza que deseja substituir?")
			oRepository:DeleteBmp(cCNameImg)
		Else
			Return(.F.)
		EndIf
	ELSE
		MsgAlert(cPergRep)
		Return(.F.)
	ENDIF
ENDIF

//Efetiva a importacao da imagem
lPutOk		:= PutImg(oRepository , cNPathFile, @cCodRet)
bDialogInit	:= { || oRepository:lStretch := .T. , oDlgAddImg:End() , oRepository := NIL , oDlgAddImg:= NIL }

//Ativa e Fecha o Dialogo Automaticamente
ACTIVATE MSDIALOG oDlgAddImg ON INIT Eval( bDialogInit )
     
//Apagar o arquivo temporario renomeado
IF FILE(cNPathFile)
	FERASE(cNPathFile)
ENDIF

Return( lPutOk )


Static Function FileNoPath( cPathFile )

Local cFileNoPath := RetFileName( @cPathFile )

cFileNoPath += SubStr( cPathFile , rAt( "." , cPathFile ) )

Return( cFileNoPath )


Static Function PutImg(oRepository , cPathFile, cCodRet)
Local lPut

IF !( lPut := File( cPathFile ) )
	Break
EndIF

//Utiliza o "Method" :IsertBmp para inserir a imagem no  Repositorio de Imagens do Protheus
cCodRet := oRepository:InsertBmp( cPathFile , NIL , @lPut )

Return(lPut)
               

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ROTINA PARA VISUALIZAR IMAGEM DO REPOSITORIO EM UMA DIALOG  
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function RIMGVIEW(cBitMap, cCustNoMens)

Local oDlgPreview
Local oBmp
Local oScrollBox  
Local lClose := .F.
Local bDialogInit := {|| IIF(lClose, oDlgPreview:End(), )}        

Default cCustNoMens := "Imagem com esta identificação não encontrada!"  //Mensagem customizada para caso de imagem nao encontrada

DEFINE MSDIALOG oDlgPreview FROM 000,000 TO 600,800 TITLE "Preview" PIXEL

@ 005,002 SCROLLBOX oScrollBox SIZE 000,000 OF oDlgPreview VERTICAL HORIZONTAL BORDER
oScrollBox:align:= CONTROL_ALIGN_ALLCLIENT

@ 000,000 REPOSITORY oBmp RESOURCE cBitMap SIZE 0,0 OF oScrollBox PIXEL

IF !(oBmp:ExistBmp(cBitMap))
	MsgAlert(cCustNoMens)   
	oDlgPreview:nWidth := 0;oDlgPreview:nHeight := 0
	lClose := .T.
ENDIF

oBmp:lAutoSize := .T.
oBmp:Refresh()

ACTIVATE MSDIALOG oDlgPreview CENTER ON INIT Eval( bDialogInit )

Return     


//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ROTINA PARA EXCLUIR IMAGEM DO REPOSITORIO DE FORMA TRANSPARENTE 
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
User Function RIMGDEL(cBitMap)
Local lRet := .T.
Local oDlgDelRp

DEFINE MSDIALOG oDlgDelRp FROM 000,000 TO 000,000 TITLE "Preview" PIXEL

//Cria um Objeto do Tipo Repositorio
@ 000,000 REPOSITORY oRepository SIZE 0,0 OF oDlgDelRp

//Verificar se ja existe a imagem e deletar no caso de lReplace .T.
IF oRepository:ExistBmp(cBitMap)
	oRepository:DeleteBmp(cBitMap)
ELSE
	lRet := .F.
ENDIF
        
//oRepository:Pack()
bDialogInit	:= { || oDlgDelRp:End() }

//Ativa e Fecha o Dialogo Automaticamente
ACTIVATE MSDIALOG oDlgDelRp ON INIT Eval( bDialogInit )

Return(lRet)
