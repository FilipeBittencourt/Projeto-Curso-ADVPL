#include "rwmake.ch" 
#include "Topconn.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VERI_COMIS³ Autor ³ BRUNO MADALENO        ³ Data ³ 05/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ VERIFICA SE A COMISAO E MAIOR QUE A DO VENDEDOR            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER FUNCTION VERI_COMIS()
Local nVend			//Vendedor
Local nCpComis 		//Campo para ser utilizado na Query
Local nComis		//Percentual Comissoa

//Biancogres
If ALLTRIM(__READVAR)	== 'M->A1_COMIS'
	nVend			:= M->A1_VEND
	nCpComis	:= '%A3_COMIS%'
	nComis		:= M->A1_COMIS
ElseIf ALLTRIM(__READVAR)	== 'M->A1_YCOMB2'
	nVend 		:= M->A1_YVENDB2
	nCpComis	:= 	'%A3_COMIS%'
	nComis		:= M->A1_YCOMB2
ElseIf ALLTRIM(__READVAR)	== 'M->A1_YCOMB3'
	nVend 		:= M->A1_YVENDB3
	nCpComis	:= '%A3_COMIS%'
	nComis		:= M->A1_YCOMB3
		
//Incesa
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMISI'
	nVend 		:= M->A1_YVENDI
	nCpComis	:= '%A3_YCOMISI%'
	nComis		:= M->A1_YCOMISI	
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMI2'
	nVend 		:= M->A1_YVENDI2
	nCpComis	:= '%A3_YCOMISI%'
	nComis		:= M->A1_YCOMI2	
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMI3'
	nVend 		:= M->A1_YVENDI3
	nCpComis	:= '%A3_YCOMISI%'
	nComis		:= M->A1_YCOMI3	
	
//Bellacasa
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMBE1'
	nVend 		:= M->A1_YVENBE1
	nCpComis	:= '%A3_YCOMIBE%'
	nComis		:= M->A1_YCOMBE1	
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMBE2'
	nVend 		:= M->A1_YVENBE2
	nCpComis	:= '%A3_YCOMIBE%'
	nComis		:= M->A1_YCOMBE2	
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMBE3'
	nVend 		:= M->A1_YVENBE3
	nCpComis	:= '%A3_YCOMIBE%'
	nComis		:= M->A1_YCOMBE3

//Mundialli
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMML1'
	nVend 		:= M->A1_YVENML1
	nCpComis	:= '%A3_YCOMIML%'
	nComis		:= M->A1_YCOMML1	
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMML2'
	nVend 		:= M->A1_YVENML2
	nCpComis	:= '%A3_YCOMIML%'
	nComis		:= M->A1_YCOMML2	
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMML3'
	nVend 		:= M->A1_YVENML3
	nCpComis	:= '%A3_YCOMIML%'
	nComis		:= M->A1_YCOMML3

//Vitcer
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMVT1'
	nVend 		:= M->A1_YVENVT1
	nCpComis	:= '%A3_YCOMIVT%'
	nComis		:= M->A1_YCOMVT1	
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMVT2'
	nVend 		:= M->A1_YVENVT2
	nCpComis	:= '%A3_YCOMIVT%'
	nComis		:= M->A1_YCOMVT2	
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMVT3'
	nVend 		:= M->A1_YVENVT3
	nCpComis	:= '%A3_YCOMIVT%'
	nComis		:= M->A1_YCOMVT3

//Pegasus
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMPEG'
	nVend 		:= M->A1_YVENPEG
	nCpComis	:= '%A3_YCOMPEG%'
	nComis		:= M->A1_YCOMPEG	

//Vinilico
ElseIf ALLTRIM(__READVAR) == 'M->A1_YCOMVI1'
	nVend 		:= M->A1_YVENVI1
	nCpComis	:= '%A3_YCOMVIN%'
	nComis		:= M->A1_YCOMVI1	

EndIf

cAliasTmp := GetNextAlias()
BeginSql Alias cAliasTmp
	SELECT %Exp:nCpComis%  AS COMIS FROM SA3010 WHERE A3_COD = %Exp:nVend% AND %NOTDEL%
EndSql

If (cAliasTmp)->COMIS < nComis
	MSGBOX("Favor verificar, pois o % de Comissão informado é maior que o permitido para este representante.","VERI_COMIS","STOP")
	nComis	:= (cAliasTmp)->COMIS
EndIf

(cAliasTmp)->(dbCloseArea())
                      
RETURN(nComis)