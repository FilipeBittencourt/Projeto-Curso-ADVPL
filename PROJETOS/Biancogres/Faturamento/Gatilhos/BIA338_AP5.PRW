#include "rwmake.ch"        // incluido pelo assistente de conversao do AP5 IDE em 07/06/02

User Function BIA338()        // incluido pelo assistente de conversao do AP5 IDE em 07/06/02

SetPrvt("WALIAS,WPRODUTO,XXN,XCCAMPO,WTES,WCF")
SetPrvt("WYPERC,WYQUEBRA,WYDESC,WYPROMO,WYMAXPRO,WYMAXPAL")
SetPrvt("WYPERPAL,WYPERPTA,WYPERVOL,WYOUTDSC,WYCOMIS1,ACOLS")

/*/
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o    � BIA338     � Autor � Gustav Koblinger Jr   � Data � 10/10/00 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Duplica os campos do SC6 para as proximas linhas             潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso      � Interpretador x Base                                         潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
/*/
wAlias   := Alias()
wProduto := Gdfieldget('C6_PRODUTO',n) 	
wPolit   := M->C5_YPERC

//Alteracao solicitada pelo Sr. Cesar em 16/11/2000
If n > 1

	//Carrega variaveis da linha anterior
	wTes	:= Gdfieldget('C6_TES',n-1) 
	wCF		:= Gdfieldget('C6_CF',n-1) 
	wYPERC	:= If(Gdfieldget('C6_YPERC',n)<>0,Gdfieldget('C6_YPERC',n),wPolit)
	IF Inclui																							//VERIFICAR QWUANDO FOR INCLUSAO
		wYDESC	:= If(Gdfieldget('C6_YDESC',n)<>0,Gdfieldget('C6_YDESC',n),Gdfieldget('C6_YDESC',n-1))	//SOMENTE PARA DESCONTO DIFERENTE DE ZERO
	END IF
	wYCOMIS1 := Gdfieldget('C6_COMIS1',n-1) 

	//Replica variaveis para a linha atual
	Gdfieldput('C6_TES',wTes,n)
	Gdfieldput('C6_CF',wCF,n)
	Gdfieldput('C6_YPERC',wYPERC,n)	
	If Inclui
		Gdfieldput('C6_YDES',wYDESC,n)
	EndIf
	Gdfieldput('C6_COMIS1',wYCOMIS1,n)	                              

EndIf

dbSelectArea(wAlias)

Return(wProduto)