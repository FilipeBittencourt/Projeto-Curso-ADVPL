#include "rwmake.ch"

User Function BIA139()

SetPrvt("XXN,XCCAMPO,WPROD,WCLVL,")

/*北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪勘�
北矲un噮o	 � BIA139	  � Autor � MICROSIGA VITORIA 	  � Data � 11/06/99 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪幢�
北矰escri噭o � Obriga a digitacao do Classe de Valor   Solicitacao/Pedido 	潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪幢�
北� Uso		 � Interpretador x Base 										潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪俦�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�*/
Private nPosProd, nPosCLVL

nPosProd := Ascan(aHeader,{|x| x[2] == "D1_COD    "})
nPosCLVL := Ascan(aHeader,{|x| x[2] == "D1_CLVL   "})

wProd := aCols[n,nPosProd]
wCLVL := aCols[n,nPosCLVL]

If Len(Alltrim(wProd)) == 7 .and. Subs(wProd,4,4) == "0000" .and. Len(Alltrim(wCLVL)) == 0
	MsgStop("Para este Produto e obrigatorio a Classe de Valor...")
	wCLVL := ""
EndIf

Return(wCLVL)
