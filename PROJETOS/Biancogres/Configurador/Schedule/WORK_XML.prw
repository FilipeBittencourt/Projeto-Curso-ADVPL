#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "AP5MAIL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROGRAMA  ณ WORK_XML       บAUTOR  ณ BRUNO MADALENO     บ DATA ณ  04/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDESC.     ณ WORKFLOW PARA COBRANCA DOS ARQUIVO XML DOS FORNECEDORES          บฑฑ
ฑฑบ          ณ	ARQUIVO XML                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUSO       ณ MP - 10                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
USER FUNCTION WORK_XML()
PRIVATE CSQL := ""
PRIVATE ENTER := CHR(13)+CHR(10)
PRIVATE EMAIL := ""
PRIVATE NOME_FOR := ""


If !PERGUNTE("NF_XML", .T.)
	Return
EndIf

cSQL := ""
cSQL += "SELECT F1_DOC, F1_SERIE, F1_EMISSAO, A2_COD, A2_NOME, A2_EMAIL " + Enter
cSQL += "FROM "+RETSQLNAME("SF1")+" SF1, SA2010 SA2, "+RETSQLNAME("SD1")+" SD1 " + Enter
cSQL += "WHERE	F1_FILIAL  = '01'       AND " + Enter
cSQL += "		F1_FORNECE     = A2_COD     AND " + Enter
cSQL += "		F1_LOJA        = A2_LOJA    AND " + Enter
cSQL += "		D1_FILIAL      = '01'       AND  " + Enter
cSQL += "		D1_DOC         = F1_DOC     AND  " + Enter
cSQL += "		D1_SERIE       = F1_SERIE   AND  " + Enter
cSQL += "		D1_FORNECE     = F1_FORNECE AND " + Enter
cSQL += "		D1_LOJA        = F1_LOJA    AND " + Enter
cSQL += "		SUBSTRING(D1_COD,1,3) <> '306' AND  " + Enter
CSQL += "		F1_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' AND " + ENTER
cSQL += "		F1_FORNECE BETWEEN '"+mv_par03+"' AND '"+mv_par04+"' AND " + Enter
cSQL += "		F1_YIMPXML     = ''     AND " + Enter
cSQL += "		F1_ESPECIE     = 'SPED' AND " + Enter
cSQL += "		F1_FORMUL 	   <> 'S'   AND " + Enter
cSQL += "		SF1.D_E_L_E_T_ = ''     AND " + Enter
cSQL += "		SD1.D_E_L_E_T_ = ''     AND " + Enter
cSQL += "		SA2.D_E_L_E_T_ = '' " + Enter
cSQL += "	GROUP BY F1_DOC, F1_SERIE, F1_EMISSAO, A2_COD, A2_NOME, A2_EMAIL  " + Enter
cSQL += "	ORDER BY A2_COD " + Enter
IF CHKFILE("_SF1")
	DBSELECTAREA("_SF1")
	DBCLOSEAREA()
ENDIF
TCQUERY cSQL ALIAS "_SF1" NEW

IF ! _SF1->(EOF())
	EMAIL 		:= 	_SF1->A2_EMAIL
	NOME_FOR 	:= _SF1->A2_NOME
END IF

CMENSA		:= "URGENTE" + CHR(13)+CHR(10)
CMENSA		+= "Favor encaminhar o arquivo XML das Notas Fiscais descritas abaixo para " 
If cempant == "01"
	CMENSA		+= "jessyca.delaia@biancogres.com.br" + CHR(13)+CHR(10)  + CHR(13)+CHR(10)
else
	CMENSA		+= "marcio.nascimento@biancogres.com.br" + CHR(13)+CHR(10) + CHR(13)+CHR(10)
end if
DO WHILE ! _SF1->(EOF())

	IF 	NOME_FOR <> _SF1->A2_NOME
			If cempant == "01"
				CMENSA		+=  CHR(13)+CHR(10) + "Biancogres Ceramica S/A"  + CHR(13)+CHR(10)
			else
				CMENSA		+= CHR(13)+CHR(10) +  "Incesa Revestimento Ceramico LTDA"  + CHR(13)+CHR(10)
			end if			
			CMENSA +=  "Mensagem automแtica, favor nใo responder este e-mail."  + CHR(13)+CHR(10)
 			PREP_EMAIL()

			EMAIL 		:= 	_SF1->A2_EMAIL
			NOME_FOR 	:= _SF1->A2_NOME
			CMENSA		:= "URGENTE" + CHR(13)+CHR(10)
			CMENSA		+= "Favor encaminhar o arquivo XML das Notas Fiscais descritas abaixo para "
			If cempant == "01"
				CMENSA		+= "jessyca.delaia@biancogres.com.br" + CHR(13)+CHR(10)  + CHR(13)+CHR(10)
			else
				CMENSA		+= "marcio.nascimento@biancogres.com.br" + CHR(13)+CHR(10) + CHR(13)+CHR(10)
			end if
	END IF

	CMENSA += "Nota Fiscal: " + ALLTRIM(_SF1->F1_DOC) + "  -  Emissao: " + DTOC(STOD(_SF1->F1_EMISSAO)) + CHR(13) + CHR(10)
	_SF1->(DBSKIP())
END DO

If cempant == "01"
	CMENSA		+= CHR(13)+CHR(10) + "Biancogres Ceramica S/A"  + CHR(13)+CHR(10)
else
	CMENSA		+= CHR(13)+CHR(10) + "Incesa Revestimento Ceramico LTDA"  + CHR(13)+CHR(10)
end if			
CMENSA +=  "Mensagem automแtica, favor nใo responder este e-mail."  + CHR(13)+CHR(10)
PREP_EMAIL()


RETURN 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PREP_EMAIL     บAutor  ณBRUNO MADALENO      บ Data ณ  05/05/10   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณROTINA PARA ENVIAR O EMAIL                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC Function PREP_EMAIL(cData,cTitulo,cMensagem)

Local lOk

If cempant == "01"
	CTITULO := "NOTAS FISCAIS ELETRONICAS - BIANCOGRES CERAMICA SA"
ELSE
	CTITULO := "NOTAS FISCAIS ELETRONICAS - INCESA REVESTIMENTO CERAMICO LTDA" 
END IF     

cRecebe 	:= IIF(ALLTRIM(EMAIL)="","wanisay.william@biancogres.com.br",ALLTRIM(EMAIL)) //EMAIL
cAssunto	:= CTITULO								// Assunto do Email
    
lOK := U_BIAEnvMail(,cRecebe,cAssunto,CMENSA)

Return