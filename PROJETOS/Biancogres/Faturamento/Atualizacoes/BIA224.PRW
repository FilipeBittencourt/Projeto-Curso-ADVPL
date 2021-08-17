#Include "PROTHEUS.CH"
#Include "TopConn.ch"

#DEFINE _NBIANCOGRES 	1
#DEFINE _NINCESA 		2
#DEFINE _NBELLACASA 	3
#DEFINE _MUNDIALLI		4
#DEFINE _PEGASUS		5
#DEFINE _VINILICO		6
#DEFINE _V01			7
#DEFINE _V02			8
#DEFINE _V03			9
#DEFINE _VRP			10
#DEFINE _VRT			11

//---------------------------------------------------------------------------------
// Desenv 	: Thiago Dantas
// Data	  	: 19/09/2014
// Desc		: Cadastro da Tabela de Preços Padrão
//---------------------------------------------------------------------------------
User Function BIA224()

Local cLoad				:= "BIA800" + cEmpAnt
Local cFileName			:= RetCodUsr() +"_"+ cLoad
Local cTitulo    := "Cadastro da Tabela de Preços Padrão "
Local cEmpTab	 := ""
Local cCondicao	 := ""
Local aIndDAK	 := {}
Local nMarca	 := 0

Private cCadastro := cTitulo
Private cAlias   := "SX5"
private aRotina  := {{"Pesquisa"  			,"AxPesqui" ,0,1},;
					{"Visualizar"			,"AxVisual"	,0,2},;
					{"Incluir"   			,"" ,0,3},;
					{"Alterar"   			,"U_BIA224ALT"	,0,4},;
					{"Excluir"   			,"" ,0,5}}

IF chkfile(cAlias)
	dbSelectArea(cAlias)
	dbCloseArea()
ENDIF

DbSelectArea(cAlias)
DbSetOrder(1)

fPerg := "BIA224"
fTamX1 := IIF(Alltrim(oApp:cVersion) == "MP8.11", 6, 10)

/*fValidPerg()
If !Pergunte(fPerg,.T.)
	Return
EndIf

nMarca := MV_PAR01
*/

aPergs := {}
MV_PAR01 := SPACE(1)
aMarca	:= {'1=Biancogres', '2=Incesa', '3=Bellacasa', '4=Mundialli', '5=Pegasus', '6=Vinilico', '7=Vinilico Dentro ES', '8=Vinilico Fora ES', '9=LM Filial SP','10=LM Replicação Mundi', '11=LM Replicação Mundi Transferencia'}
aAdd( aPergs ,{2,"Marca"				, MV_PAR01, aMarca, 100, ".T.",.F.})

If !ParamBox(aPergs ,"Filtro",,,,,,,,cLoad,.T.,.T.)
	Return()
EndIf

nMarca := Val(ParamLoad(cFileName,,1,MV_PAR01))


Do Case
   	Case nMarca == _NBIANCOGRES
      cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '1P_1E'"
   	Case nMarca == _NINCESA
      cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '2P_2E'"
	Case nMarca == _NBELLACASA
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '3P_3E'"
	Case nMarca == _MUNDIALLI
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '4P_4E'"
    Case nMarca == _PEGASUS
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '5P_5E'"      
    Case nMarca == _VINILICO
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '6P_5E'"  
    Case nMarca == _V01
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ 'V01'"  
    Case nMarca == _V02
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ 'V02'"  
    Case nMarca == _V03
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ 'V03'"  
   Case nMarca == _VRP   
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ 'VRP'"   
   Case nMarca == _VRT   
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ 'VRT'"                               
EndCase
/*
Do Case
   Case cEmpAnt == "01"
      cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '1P_1E'"
   Case cEmpAnt == "05"
      cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '2P_2E_3P_3E'"
	Case cEmpAnt == "13"
       cCondicao := "X5_TABELA == 'ZF' .AND. AllTrim(X5_CHAVE) $ '4P_4E'"
EndCase
*/

bFiltraBrw := {|| FilBrowse(cAlias,@aIndDAK,@cCondicao) }
(cAlias)->( Eval( bFiltraBrw ) )

DbSelectArea(cAlias)
DbSetOrder(1)

//Eval(bFiltraBrw)

mBrowse(6,1,22,75,cAlias,,,,,6)

Return Nil

//---------------------------------------------------------------------------------
USER Function BIA224ALT()

Local lRet   	:= .T.
Local aArea 	:= GetArea()
Local nOpcao 	:= 4
Local aAcho		:= {}
Local aCpoalt 	:= {}
Local nRet		

aAdd(aAcho	,"X5_CHAVE" )
aAdd(aAcho	,"X5_DESCRI")
aAdd(aCpoalt,"X5_DESCRI")

//AxAltera( <cAlias> , <nReg>		, <nOpc>, <aAcho>, <aCpos>, <nColMens>, <cMensagem>, <cTudoOk>  , <cTransact>	, <cFunc>	 , <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)
//EX:
//AxAltera("SA1"	 ,SA1->(Recno()),4		,	  	 , aCpos  ,/* */	  ,/* */	   ,"U_TudoOk()","U_Transaction","U_Before()", aButtons  ,aParam   ,	    ,			,.T.		  ,,,,,)

//AxAltera( cAlias ,nReg			,nOpc	,aAcho, aCpoalt,/* */,/* */,"U_BIA224TOK()")
nRet   := AxAltera( "SX5" , SX5->(RecNo()) , 4	,aAcho, aCpoalt	,,,"U_BIA224TOK()"	,,,,,,.T.)
//nRet := AxAltera("SC5"   , SC5->(RecNo()), 4  ,	  , aAlter	,,,"U_cTudoOk()"	,,,,,,.T.)

If nRet == 1
	SC5->(DbGoTop())
Else
	RestArea(aArea)
EndIf

Return lRet
//---------------------------------------------------------------------------------
User Function BIA224TOK()
	M->X5_DESCSPA	:= M->X5_DESCRI
	M->X5_DESCENG	:= M->X5_DESCRI
Return .T.

//----------------------------------------------------------------------------------------------------------------------------------------
//											::: BLOCO DE PERGUNTA :::
//----------------------------------------------------------------------------------------------------------------------------------------
Static Function fValidPerg()
local i,j
_sAlias := Alias()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(fPerg,fTamX1)
aRegs:={}

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Marca     		   ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","Biancogres","","","","","Incesa","","","","","Bellacasa","","","","","Mundialli","","","","","","","","",""})

For i := 1 to Len(aRegs)
	if !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1",.t.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
//---------------------------------------------------------------------------------
