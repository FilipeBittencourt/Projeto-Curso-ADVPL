#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"

/*/
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFun┤└o	   Ё BIA526	    Ё Autor Ё 	MAGNAGO     	      Ё Data Ё 20/10/99 Ё╠╠
╠╠Ё      	   Ё       	    Ё Alter.Ё Ranisses A. Corona 	  Ё Data Ё 28/05/09 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤└o Ё RELATORIO DE NF POR TRANSPORTADORAS    		           				Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё Uso		   Ё Faturamento          				            			              Ё╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
User Function BIA526()
lEnd		:= .F.
cString     := ""
lAbortPrint := .F.
tamanho		:= "G"
limite		:= 80
titulo		:= "RELACAO DAS NOTAS FISCAIS POR TRANSPORTADORAS"
cDesc1		:= "Emite relacao de NF por Transportadoras  "
cDesc2		:= ""
cDesc3		:= ""
aReturn		:= { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
aLinha		:= { }
nomeprog 	:= "BIA526"
nLastKey 	:= 0
cPerg 		:= "BIA526"
li 			:= 1
PRIVATE aOrd := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ajuste dos par┐metros da impress└o via fun┤└o SETPRINT	     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.F.)
if lastkey()==27 .OR. nLastKey==27
	Return
endif

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Aceita par┐metros e faz ajustes necess═rios 			          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetDefault(aReturn,cString)
if lastkey()==27 .OR. nLastKey==27
	Return
endif

Pergunte("BIA526",.F.)
if lastkey()==27
	Return
endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Vari═veis utilizadas para Impress└o do Cabe┤alho e Rodap┌	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cbtxt 	:= SPACE(10)
cbcont	:= 0
cabec1	:= " Cliente                                        CNPJ           UF   Cidade            EmissЦo    Ser    NF         Peso Bruto   Volume         Valor NF         ICMS Aut.    Placa"
cabec2	:= "  "
cString	:= "SD2"
li 		:= 80
m_pag 	:= 1
wnrel 	:= "BIA526"   // nome default do relatorio em disco
nTipo    := IIF(aReturn[4]==1,15,18)



Processa({|| RptDetail()  })

fFinaliza()


Return



Static Function RptDetail()

Private Enter := CHR(13)+CHR(10)
//cQuery  := ""
//cQuery  += "SELECT F2_TIPO, F2_CLIENTE,									" + Enter
//cQuery  += "	   A1_NOME = CASE										" + Enter
//cQuery  += "					WHEN F2_TIPO IN ('D','B') THEN A2_NOME 	" + Enter
//cQuery  += "					ELSE A1_NOME							" + Enter
//cQuery  += "				END,										" + Enter
//cQuery  += "	   A1_EST = CASE										" + Enter
//cQuery  += "					WHEN F2_TIPO IN ('D','B') THEN A2_EST 	" + Enter
//cQuery  += "					ELSE A1_EST								" + Enter
//cQuery  += "				END,										" + Enter
//cQuery  += "	   A1_MUN = CASE										" + Enter
//cQuery  += "					WHEN F2_TIPO IN ('D','B') THEN A2_MUN 	" + Enter
//cQuery  += "					ELSE A1_MUN								" + Enter
//cQuery  += "				END,										" + Enter
//cQuery  += "	   ENDER  = CASE										" + Enter
//cQuery  += "					WHEN (SELECT C5_YFLAG FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = F2_YPEDIDO AND C5_CLIENTE = F2_CLIENTE AND C5_LOJACLI = F2_LOJA AND D_E_L_E_T_ = '') = '2' THEN	" + Enter
//cQuery  += "						 (SELECT RTRIM(C5_YEND)+' - '+RTRIM(C5_YBAIRRO)+' - '+RTRIM(C5_YMUN)+' - '+RTRIM(C5_YEST)+' - '+RTRIM(C5_YCEP) FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = F2_YPEDIDO AND C5_CLIENTE = F2_CLIENTE AND C5_LOJACLI = F2_LOJA AND D_E_L_E_T_ = '') " + Enter
//cQuery  += "					WHEN (SELECT C5_MENNOTA FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = F2_YPEDIDO AND C5_CLIENTE = F2_CLIENTE AND C5_LOJACLI = F2_LOJA AND D_E_L_E_T_ = '') LIKE '%ENTREGA%' THEN	" + Enter
//cQuery  += "						 (SELECT C5_MENNOTA FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = F2_YPEDIDO AND C5_CLIENTE = F2_CLIENTE AND C5_LOJACLI = F2_LOJA AND D_E_L_E_T_ = '') " + Enter
//cQuery  += "					ELSE ''									" + Enter
//cQuery  += "				END,  										" + Enter
//cQuery  += "	   A1_CGC = CASE 										" + Enter
//cQuery  += "					WHEN F2_TIPO IN ('D','B') AND A2_TIPO = 'J' THEN SUBSTRING(A2_CGC,1,2)+'.'+SUBSTRING(A2_CGC,3,3)+'.'+SUBSTRING(A2_CGC,6,3)+'/'+SUBSTRING(A2_CGC,9,4)+'-'+SUBSTRING(A2_CGC,13,2)			" + Enter	
//cQuery  += "					WHEN F2_TIPO IN ('D','B') AND A2_TIPO = 'F' THEN SUBSTRING(A2_CGC,1,3)+'.'+SUBSTRING(A2_CGC,4,3)+'.'+SUBSTRING(A2_CGC,7,3)+'-'+SUBSTRING(A2_CGC,10,2) 									" + Enter	
//cQuery  += "					WHEN F2_TIPO NOT IN ('D','B') AND A1_PESSOA = 'J' THEN SUBSTRING(A1_CGC,1,2)+'.'+SUBSTRING(A1_CGC,3,3)+'.'+SUBSTRING(A1_CGC,6,3)+'/'+SUBSTRING(A1_CGC,9,4)+'-'+SUBSTRING(A1_CGC,13,2) 	" + Enter	
//cQuery  += "					WHEN F2_TIPO NOT IN ('D','B') AND A1_PESSOA = 'F' THEN SUBSTRING(A1_CGC,1,3)+'.'+SUBSTRING(A1_CGC,4,3)+'.'+SUBSTRING(A1_CGC,7,3)+'-'+SUBSTRING(A1_CGC,10,2) 							" + Enter	
//cQuery  += "					ELSE A1_CGC 							" + Enter	
//cQuery  += "				END, 										" + Enter
//cQuery  += "		F2_EMISSAO, F2_SERIE, F2_DOC, F2_PBRUTO, F2_VOLUME1, F2_VALBRUT, F2_ICMAUTO, F2_YPLACA, F2_TRANSP, A4_NOME	" + Enter	
//cQuery  += "FROM "+RetSqlName("SF2")+" SF2, SA1010 SA1, SA2010 SA2, SA4010 SA4 													" + Enter
//cQuery  += "WHERE	SF2.F2_FILIAL	= '"+xFilial("SF2")+"'	AND	" + Enter
//cQuery  += "		SA1.A1_FILIAL	= '"+xFilial("SA1")+"'	AND	" + Enter

//cQuery  += "		SF2.F2_CLIENTE	*= A1_COD				AND	" + Enter
//cQuery  += "		SF2.F2_LOJA		*= A1_LOJA				AND	" + Enter
//cQuery  += "		SF2.F2_CLIENTE	*= A2_COD				AND	" + Enter
//cQuery  += "		SF2.F2_LOJA		*= A2_LOJA				AND	" + Enter

//cQuery  += "		SF2.F2_TRANSP	= A4_COD				AND	" + Enter
//cQuery  += "		SF2.F2_EMISSAO	>= '"+DTOS(MV_PAR03)+"' AND " + Enter
//cQuery  += "		SF2.F2_EMISSAO	<= '"+DTOS(MV_PAR04)+"' AND " + Enter
//cQuery  += "		SF2.F2_TRANSP	>= '"+MV_PAR01+"'		AND " + Enter
//cQuery  += "		SF2.F2_TRANSP	<= '"+MV_PAR02+"'		AND " + Enter
//cQuery  += "		SF2.F2_SERIE	>= '"+MV_PAR05+"'		AND " + Enter
//cQuery  += "		SF2.F2_SERIE	<= '"+MV_PAR06+"'		AND " + Enter
//cQuery  += "		SF2.F2_CLIENTE	>= '"+MV_PAR07+"'		AND " + Enter
//cQuery  += "		SF2.F2_CLIENTE	<= '"+MV_PAR08+"'		AND " + Enter
//cQuery  += "		SF2.D_E_L_E_T_ = ''		AND 				" + Enter
//cQuery  += "		SA1.D_E_L_E_T_ = ''		AND 				" + Enter
//cQuery  += "		SA4.D_E_L_E_T_ = ''							" + Enter
//cQuery  += "ORDER BY F2_TRANSP, F2_EMISSAO, F2_DOC				" + Enter

//ATUALIZAгцO QUERY - SQL ATUAL - 05/10/2015
cQuery  := ""
cQuery  += "SELECT F2_TIPO, F2_CLIENTE,									" + Enter
cQuery  += "	   A1_NOME = CASE										" + Enter
cQuery  += "					WHEN F2_TIPO IN ('D','B') THEN A2_NOME 	" + Enter
cQuery  += "					ELSE A1_NOME							" + Enter
cQuery  += "				END,										" + Enter
cQuery  += "	   A1_EST = CASE										" + Enter
cQuery  += "					WHEN F2_TIPO IN ('D','B') THEN A2_EST 	" + Enter
cQuery  += "					ELSE A1_EST								" + Enter
cQuery  += "				END,										" + Enter
cQuery  += "	   A1_MUN = CASE										" + Enter
cQuery  += "					WHEN F2_TIPO IN ('D','B') THEN A2_MUN 	" + Enter
cQuery  += "					ELSE A1_MUN								" + Enter
cQuery  += "				END,										" + Enter
cQuery  += "	   ENDER  = CASE										" + Enter
cQuery  += "					WHEN (SELECT C5_YFLAG FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = F2_YPEDIDO AND C5_CLIENTE = F2_CLIENTE AND C5_LOJACLI = F2_LOJA AND D_E_L_E_T_ = '') = '2' THEN	" + Enter
cQuery  += "						 (SELECT RTRIM(C5_YEND)+' - '+RTRIM(C5_YBAIRRO)+' - '+RTRIM(C5_YMUN)+' - '+RTRIM(C5_YEST)+' - '+RTRIM(C5_YCEP) FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = F2_YPEDIDO AND C5_CLIENTE = F2_CLIENTE AND C5_LOJACLI = F2_LOJA AND D_E_L_E_T_ = '') " + Enter
cQuery  += "					WHEN (SELECT C5_MENNOTA FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = F2_YPEDIDO AND C5_CLIENTE = F2_CLIENTE AND C5_LOJACLI = F2_LOJA AND D_E_L_E_T_ = '') LIKE '%ENTREGA%' THEN	" + Enter
cQuery  += "						 (SELECT C5_MENNOTA FROM "+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = F2_YPEDIDO AND C5_CLIENTE = F2_CLIENTE AND C5_LOJACLI = F2_LOJA AND D_E_L_E_T_ = '') " + Enter
cQuery  += "					ELSE ''									" + Enter
cQuery  += "				END,  										" + Enter
cQuery  += "	   A1_CGC = CASE 										" + Enter
cQuery  += "					WHEN F2_TIPO IN ('D','B') AND A2_TIPO = 'J' THEN SUBSTRING(A2_CGC,1,2)+'.'+SUBSTRING(A2_CGC,3,3)+'.'+SUBSTRING(A2_CGC,6,3)+'/'+SUBSTRING(A2_CGC,9,4)+'-'+SUBSTRING(A2_CGC,13,2)			" + Enter	
cQuery  += "					WHEN F2_TIPO IN ('D','B') AND A2_TIPO = 'F' THEN SUBSTRING(A2_CGC,1,3)+'.'+SUBSTRING(A2_CGC,4,3)+'.'+SUBSTRING(A2_CGC,7,3)+'-'+SUBSTRING(A2_CGC,10,2) 									" + Enter	
cQuery  += "					WHEN F2_TIPO NOT IN ('D','B') AND A1_PESSOA = 'J' THEN SUBSTRING(A1_CGC,1,2)+'.'+SUBSTRING(A1_CGC,3,3)+'.'+SUBSTRING(A1_CGC,6,3)+'/'+SUBSTRING(A1_CGC,9,4)+'-'+SUBSTRING(A1_CGC,13,2) 	" + Enter	
cQuery  += "					WHEN F2_TIPO NOT IN ('D','B') AND A1_PESSOA = 'F' THEN SUBSTRING(A1_CGC,1,3)+'.'+SUBSTRING(A1_CGC,4,3)+'.'+SUBSTRING(A1_CGC,7,3)+'-'+SUBSTRING(A1_CGC,10,2) 							" + Enter	
cQuery  += "					ELSE A1_CGC 							" + Enter	
cQuery  += "				END, 										" + Enter
cQuery  += "		F2_EMISSAO, F2_SERIE, F2_DOC, F2_PBRUTO, F2_VOLUME1, F2_VALBRUT, F2_ICMAUTO, F2_YPLACA, F2_TRANSP, A4_NOME	" + Enter
cQuery  += "FROM "+RetSqlName("SF2")+" SF2 "
cQuery  += "	INNER JOIN "+RetSqlName("SA4")+" SA4 ON SF2.F2_TRANSP	= SA4.A4_COD "
cQuery  += "		AND SA4.D_E_L_E_T_ = '' "
cQuery  += "	LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SF2.F2_CLIENTE = SA1.A1_COD AND "
cQuery  += "		SF2.F2_LOJA = SA1.A1_LOJA AND "
cQuery  += "		SA1.A1_FILIAL	= '"+xFilial("SA1")+"' AND "
cQuery  += "		SA1.D_E_L_E_T_ = '' "
cQuery  += "	LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SF2.F2_CLIENTE	= SA2.A2_COD AND "
cQuery  += "		SF2.F2_LOJA = SA2.A2_LOJA AND "
cQuery  += "		SA2.D_E_L_E_T_ = '' "
cQuery  += "WHERE	SF2.F2_FILIAL	= '"+xFilial("SF2")+"'	AND "
cQuery  += "		SF2.F2_EMISSAO	>= '"+DTOS(MV_PAR03)+"' AND "
cQuery  += "		SF2.F2_EMISSAO	<= '"+DTOS(MV_PAR04)+"' AND "
cQuery  += "		SF2.F2_TRANSP	>= '"+MV_PAR01+"'		AND "
cQuery  += "		SF2.F2_TRANSP	<= '"+MV_PAR02+"'		AND "
cQuery  += "		SF2.F2_SERIE	>= '"+MV_PAR05+"'		AND "
cQuery  += "		SF2.F2_SERIE	<= '"+MV_PAR06+"'		AND "
cQuery  += "		SF2.F2_CLIENTE	>= '"+MV_PAR07+"'		AND "
cQuery  += "		SF2.F2_CLIENTE	<= '"+MV_PAR08+"'		AND "
cQuery  += "		SF2.D_E_L_E_T_ = '' "
cQuery  += "ORDER BY F2_TRANSP, F2_EMISSAO, F2_DOC "


If chkfile("TRB")
	dbSelectArea("TRB")
	dbCloseArea()
EndIf
TCQUERY cQuery ALIAS "TRB" NEW

DbSelectArea("TRB")
DbGoTop()

//Variaveis para Total Geral
nTPeso		:= 0
nTVolume	:= 0
nTTotNf		:= 0   
nTTotIcm	:= 0

WHILE !EOF()
	
	INCPROC("Processando Cabecalho das NFs-Saida....")
	
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Impressao do cabecalho									  Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	
	#IFNDEF WINDOWS
		If  LastKey() == 286
			lEnd := .t.
		End
	#ENDIF
	
	IF  lEnd
		@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
		lContinua := .F.
		Return
	Endif
	
	
	IF  li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
		@li,01 PSAY "TRANSP.: "+TRB->F2_TRANSP+" - "+TRB->A4_NOME
		li := li + 1
	Endif
	//li		  := li + 1

	xTransp		:= TRB->F2_TRANSP

	//Variaveis para Total por Transportadora
	nPeso		:= 0
	nVolume		:= 0
	nTotNf		:= 0
	nTIcmAut	:= 0

	WHILE TRB->F2_TRANSP == xTransp .AND. !EOF()    
	
		If  li > 55
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,nTipo)
			@li,01 PSAY "TRANSP.: "+TRB->F2_TRANSP+" - "+TRB->A4_NOME
			li := li + 1
		Endif
		
		@ li,01   	PSAY TRB->F2_CLIENTE
		@ li,09   	PSAY Subst(TRB->A1_NOME,1,30)  				
		@ li,42 	PSAY TRB->A1_CGC
		@ li,63 	PSAY TRB->A1_EST
		@ li,68		PSAY Subst(TRB->A1_MUN,1,10)
		@ li,86		PSAY STOD(TRB->F2_EMISSAO)
		@ li,97 	PSAY TRB->F2_SERIE					  	
		@ li,102	PSAY TRB->F2_DOC 			  			
		@ li,111   	PSAY Transform(TRB->F2_PBRUTO	,"@E 999,999,999.99")
		@ li,129   	PSAY Transform(TRB->F2_VOLUME1	,"@E 999999")
		@ li,137   	PSAY Transform(TRB->F2_VALBRUT	,"@E 999,999,999.99")
		@ li,155   	PSAY Transform(TRB->F2_ICMAUTO	,"@E 999,999,999.99")
		@ li,173   	PSAY TRB->F2_YPLACA 			  		
		//@ li,183   	PSAY Alltrim(TRB->ENDER)
		
		
		If !Empty(Alltrim(TRB->ENDER))
			li	:=	li + 1
			@ li,09   	PSAY "EndereГo de Entrega: "
			@ li,30   	PSAY Alltrim(TRB->ENDER) 
		EndIf
		
		nPeso		:=	nPeso   + TRB->F2_PBRUTO
		nVolume		:=	nVolume + TRB->F2_VOLUME1
		nTotNf		:=  nTotNf  + TRB->F2_VALBRUT
		nTIcmAut	:=  nTIcmAut + TRB->F2_ICMAUTO

		
		nTPeso		:= 	nTPeso	 + TRB->F2_PBRUTO
		nTVolume	:= 	nTVolume + TRB->F2_VOLUME1
		nTTotNf		:= 	nTTotNf	 + TRB->F2_VALBRUT 
		nTTotIcm	:= 	nTTotIcm + TRB->F2_ICMAUTO 
		
		
		li	:=	li + 1
		
		DBSKIP()
		
	ENDDO

	li	:=	li + 1  
	@ li,86 		PSAY "TOTAL TRANSP."   			
	@ li,111   		PSAY Transform(nPeso	,"@E 999,999,999.99")
	@ li,129   		PSAY Transform(nVolume	,"@E 999999")
	@ li,137   		PSAY Transform(nTotNf	,"@E 999,999,999.99")
	@ li,155   		PSAY Transform(nTIcmAut	,"@E 999,999,999.99")	
	li	:=	li + 1

	
	@ li,01 		PSAY "-"
	@ li,02 		PSAY "------------------------------------------------------------"
	@ li,42 		PSAY "------------------------------------------------------------"
	@ li,82 		PSAY "------------------------------------------------------------"
	@ li,122		PSAY "------------------------------------------------------------"
	@ li,130		PSAY "-"
	li				:= li + 2
    
	If !EOF()
		@li,01 PSAY "TRANSP.: "+TRB->F2_TRANSP+" - "+TRB->A4_NOME
		li := li + 1
	EndIF
	
ENDDO

If EOF()
	//li := li + 1
	@ li,86 		PSAY "TOTAL GERAL"   			
	@ li,111   		PSAY Transform(nTPeso	,"@E 999,999,999.99")
	@ li,129   		PSAY Transform(nTVolume	,"@E 999999")
	@ li,137   		PSAY Transform(nTTotNf	,"@E 999,999,999.99")                                                        
	@ li,155   		PSAY Transform(nTTotIcm	,"@E 999,999,999.99")	
EndIF


Roda(cbcont,cbtxt,"G")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura Tela e Set's                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SET DEVICE TO SCREEN
RETURN( NIL )


// Substituido pelo assistente de conversao do AP5 IDE em 02/02/01 ==> FUNCTION fFinaliza
Static FUNCTION fFinaliza()

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se impress└o em Disco, chama SPOOL 									   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
IF aReturn[5] == 1		// disco
	Set Printer TO
	Commit					//grava em disco
	ourspool(wnrel)
ENDIF

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apaga os arquivos temporarios										   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If chkfile("_Trab")
	dbSelectArea("_Trab")
	dbCloseArea()
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera relat╒rio para Spool da Rede									   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FT_PFLUSH()

RETURN( NIL )
