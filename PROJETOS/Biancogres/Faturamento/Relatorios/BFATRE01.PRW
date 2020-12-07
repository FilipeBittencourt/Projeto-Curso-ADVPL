#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BFATRE01         ³ Fernando Rocha     º Data ³  22/03/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressao da proposta de engenharia						  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BFATRE01()
Private cSQL
Private cProposta := Z68->Z68_NUM
Private cRevisao  := Z68->Z68_REV
Private cOpcao 	:= ""


cSQL := ""
cSQL += " ALTER VIEW [dbo].[IMP_PEDENG] AS "+CRLF
cSQL += " with tab_parc as "+CRLF
cSQL += " ( "+CRLF
cSQL += " 	select ROW_NUMBER() OVER(ORDER BY ZA5_DATA) AS ROW, ZA5_VALOR, ZA5_DATA from "+RetSQLName("ZA5")+" ZA5  "+CRLF
cSQL += " 	where	ZA5_NUM = '"+cProposta+"'  "+CRLF
cSQL += " 			and ZA5_REV = '"+cRevisao+"'  "+CRLF
cSQL += " 			and ZA5.D_E_L_E_T_='' "+CRLF
cSQL += " ) "+CRLF
cSQL += " select "+CRLF
cSQL += " Z69_NUM, "+CRLF
cSQL += " Z69_REV, "+CRLF
cSQL += " DATA = convert(varchar(10),getdate(),103), "+CRLF
cSQL += " Z68_EMISSA = substring(Z68_EMISSA,7,2)+'/'+substring(Z68_EMISSA,5,2)+'/'+substring(Z68_EMISSA,1,4), "+CRLF
cSQL += " REVISAO_ANT = (case when Z69_REV > '01' then right('00' +cast(convert(int,Z69_REV)-1 as varchar(2)),2) else '' end), "+CRLF
cSQL += " EMISSAO_ANT = (case when Z69_REV > '01' then  "+CRLF
cSQL += " 					(select substring(Z68_EMISSA,7,2)+'/'+substring(Z68_EMISSA,5,2)+'/'+substring(Z68_EMISSA,1,4) from "+RetSQLName("Z68")+" X  "+CRLF
cSQL += " 					where X.Z68_FILIAL = Z68.Z68_FILIAL  "+CRLF
cSQL += " 					and X.Z68_NUM = Z68.Z68_NUM  "+CRLF
cSQL += " 					and X.Z68_REV = right('00' +cast(convert(int,Z69_REV)-1 as varchar(2)),2) "+CRLF
cSQL += " 					and X.D_E_L_E_T_='')  "+CRLF
cSQL += " 					else '' end), "+CRLF
cSQL += " Z68_CODCLI, "+CRLF
cSQL += " Z68_LOJCLI, "+CRLF
cSQL += " Z68_ALIQ, "+CRLF
cSQL += " Z68_COND, "+CRLF
cSQL += " DESC_COND = (case when E4_CODIGO = '142' then 'Conforme Cronograma' else E4_COND end), "+CRLF
cSQL += " Z68_CODVEN, "+CRLF
cSQL += " Z68_NOMCLI, "+CRLF
cSQL += " Z68_END, "+CRLF
cSQL += " Z68_BAIRRO, "+CRLF
cSQL += " Z68_MUN, "+CRLF
cSQL += " Z68_EST, "+CRLF
cSQL += " Z68_CEP, "+CRLF
cSQL += " Z68_CNPJ = substring(Z68_CNPJ ,1,2) + '.' + substring(Z68_CNPJ ,3,3) + '.' + substring(Z68_CNPJ ,6,3) + '/' + substring(Z68_CNPJ ,9,4) + '-' + substring(Z68_CNPJ ,13,2), "+CRLF
cSQL += " Z68_CNOME, "+CRLF
cSQL += " Z68_CTEL, "+CRLF
cSQL += " Z68_CEMAIL, "+CRLF
cSQL += " Z68_APVLPR, "+CRLF
cSQL += " Z68_APTOMO = case when Z68_APTOMO = 'V' then 'Valor Previsto' when Z68_APTOMO = 'S' then 'Sim' else 'Não' end, "+CRLF
cSQL += " Z68_DTVALI = substring(Z68_DTVALI,7,2)+'/'+substring(Z68_DTVALI,5,2)+'/'+substring(Z68_DTVALI,1,4), "+CRLF
cSQL += " Z68_DTAPRO = substring(Z68_DTAPRO,7,2)+'/'+substring(Z68_DTAPRO,5,2)+'/'+substring(Z68_DTAPRO,1,4), "+CRLF
cSQL += " Z68_OBS = CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), Z68_OBSIMP)), "+CRLF
cSQL += " Z69_ITEM, "+CRLF
cSQL += " B1_DESC, "+CRLF
cSQL += " Z69_QTDVEN, "+CRLF
cSQL += " B1_UM, "+CRLF
cSQL += " Z69_PRCVEN, "+CRLF
cSQL += " Z69_VALOR, "+CRLF
cSQL += " Z69_DTNECE = substring(Z69_DTNECE,7,2)+'/'+substring(Z69_DTNECE,5,2)+'/'+substring(Z69_DTNECE,1,4), "+CRLF
cSQL += " TOTAL_VALOR = (select sum(Z69_VALOR) from "+RetSQLName("Z69")+" X where X.Z69_FILIAL = Z69.Z69_FILIAL and X.Z69_NUM = Z69.Z69_NUM and X.Z69_REV = Z69.Z69_REV and X.D_E_L_E_T_=' '), "+CRLF
cSQL += " Z68_FRTUNI, "+CRLF

cSQL += " PESO_ITEM = ROUND((B1_PESO * Z69_QTDVEN)/1000,2), "+CRLF
cSQL += " FRETE_ITEM = ROUND(Z68_FRTUNI * ((B1_PESO * Z69_QTDVEN)/1000),2), "+CRLF
cSQL += " FRETE_M2 = ROUND((Z68_FRTUNI * ((B1_PESO * Z69_QTDVEN)/1000))/Z69_QTDVEN,2), "+CRLF 
cSQL += " PESO_TOTAL_TON = ROUND((select sum((B1_PESO * Z69_QTDVEN)/1000) "+CRLF
cSQL += "  					from "+RetSQLName("Z69")+" X "+CRLF 
cSQL += "     				join "+RetSQLName("SB1")+" SB1X on SB1X.B1_FILIAL = '  ' and SB1X.B1_COD = X.Z69_CODPRO and SB1X.D_E_L_E_T_='' "+CRLF
cSQL += "  					where X.Z69_FILIAL = Z69.Z69_FILIAL and X.Z69_NUM = Z69.Z69_NUM and X.Z69_REV = Z69.Z69_REV and X.D_E_L_E_T_=' '),2), "+CRLF 
cSQL += " FRETE_TOTAL = ROUND(Z68_FRTUNI * "+CRLF 
cSQL += "  				(select  sum((B1_PESO * Z69_QTDVEN)/1000) "+CRLF 
cSQL += "  				from "+RetSQLName("Z69")+" X "+CRLF 
cSQL += "  				join "+RetSQLName("SB1")+" SB1X on SB1X.B1_FILIAL = '  ' and SB1X.B1_COD = X.Z69_CODPRO and SB1X.D_E_L_E_T_='' "+CRLF
cSQL += "  				where X.Z69_FILIAL = Z69.Z69_FILIAL and X.Z69_NUM = Z69.Z69_NUM and X.Z69_REV = Z69.Z69_REV and X.D_E_L_E_T_=' '),2), "+CRLF
 				
cSQL += " PARC1_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 1), "+CRLF
cSQL += " PARC1_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 1), "+CRLF
cSQL += " PARC2_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 2), "+CRLF
cSQL += " PARC2_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 2), "+CRLF
cSQL += " PARC3_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 3), "+CRLF
cSQL += " PARC3_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 3), "+CRLF
cSQL += " PARC4_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 4), "+CRLF
cSQL += " PARC4_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 4), "+CRLF
cSQL += " PARC5_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 5), "+CRLF
cSQL += " PARC5_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 5), "+CRLF
cSQL += " PARC6_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 6), "+CRLF
cSQL += " PARC6_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 6), "+CRLF
cSQL += " PARC7_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 7), "+CRLF
cSQL += " PARC7_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 7), "+CRLF
cSQL += " PARC8_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 8), "+CRLF
cSQL += " PARC8_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 8), "+CRLF
cSQL += " PARC9_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 9), "+CRLF
cSQL += " PARC9_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 9), "+CRLF
cSQL += " PARC10_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 10), "+CRLF
cSQL += " PARC10_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 10), "+CRLF
cSQL += " PARC11_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 11), "+CRLF
cSQL += " PARC11_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 11), "+CRLF
cSQL += " PARC12_VALOR = (select top 1 ZA5_VALOR from tab_parc where ROW = 12), "+CRLF
cSQL += " PARC12_DATA = (select top 1 (substring(ZA5_DATA,7,2)+'/'+substring(ZA5_DATA,5,2)+'/'+substring(ZA5_DATA,1,4)) from tab_parc where ROW = 12) "+CRLF
cSQL += " from "+RetSQLName("Z68")+" Z68 "+CRLF
cSQL += " join "+RetSQLName("SE4")+" SE4 on E4_FILIAL = '  ' and E4_CODIGO = Z68_COND "+CRLF
cSQL += " join "+RetSQLName("Z69")+" Z69 on Z69_FILIAL = Z68_FILIAL and Z68_NUM = Z69_NUM and Z68_REV = Z69_REV "+CRLF
cSQL += " join "+RetSQLName("SB1")+" SB1 on B1_FILIAL = '  ' and B1_COD = Z69_CODPRO "+CRLF
cSQL += " where "+CRLF
cSQL += " Z68_NUM = '"+cProposta+"' "+CRLF
cSQL += " and Z68_REV = '"+cRevisao+"' "+CRLF
cSQL += " and Z68.D_E_L_E_T_ = '' "+CRLF
cSQL += " and SE4.D_E_L_E_T_ = '' "+CRLF
cSQL += " and Z69.D_E_L_E_T_ = '' "+CRLF
cSQL += " and SB1.D_E_L_E_T_ = '' "+CRLF

TcSQLExec(cSQL)

cOpcao	:=	"6;0;1;Proposta de Engenharia"

CallCrys("PEDENG_"+AllTrim(Z68->Z68_EMPFAT)+IIF(Z68->Z68_COND == "142","_142",""), cEmpant, cOpcao, .T., .T., .T., .F. )

Return()