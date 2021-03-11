#include "protheus.ch"
#Include "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

// U_TSTFIL
User Function TSTFIL()

  If Select("SX6") <= 0
    RPCSetEnv("01", "01", NIL, NIL, "COM", NIL, {"SB1","SF1", "SF2"})
  EndIf

  //TSTFIL001() // biaxfunc.prw  - Teste Email SEND
  //TSTFIL002() // Teste pedidos provisionados
  //TSTFIL003()
  DbSelectArea("ZDJ")
  X31UPDTABLE('ZDJ')


RETURN

//Teste Email SEND
Static Function  TSTFIL001


  Local  cErro := ""
  Local  cMail := "filipe.bittencourt@facilesistemas.com.br;fsbvieira@gmail.com"

  cErro := " <html>"
  cErro += " <body>"
  cErro += " <div style='margin:0;padding:0;background-color:#ffffff;height:100%'>"

  cErro += " <table border='0' cellpadding='0' cellspacing='0' width='100%' style='background-color:#ffffff;overflow-x:hidden'>"
  cErro += " <tbody>"
  cErro += " <tr>"
  cErro += " <td align='left'>"
  cErro += " <table align='center' border='0' cellpadding='0' cellspacing='0' style='border-collapse:collapse;overflow-x:hidden;font-family:&#39;proxima-nova&#39;,sans-serif;width:100%;max-width:560px'>"


  cErro += " <tbody>"
  cErro += " <tr>"
  cErro += " <td align='center' style='padding:10px 20px 20px 20px;font-family:&#39;proxima-nova&#39;,sans-serif'>"

  cErro += " </td>"
  cErro += " </tr>"
  cErro += " <tr>"
  cErro += " <td align='center'>"
  cErro += " <table align='center' border='0' cellpadding='0' cellspacing='0' style='overflow-x:hidden;margin:0px 20px 0px 20px;border:1px solid #ebebeb'>"


  cErro += " <tbody>"


  cErro += " <tr>"
  cErro += " <td align='center' bgcolor='#3577B0'  style='padding:30px 30px 20px 30px; font-size:50px; color:#ffffff; font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " EMAIL TESTER"
  cErro += " </td>"
  cErro += " </tr>"


  cErro += " <tr>
  cErro += " <td align='left' bgcolor='#ffffff' style='padding:30px 30px 0px 30px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <h1 style='margin:0px;padding:0;font-size:22px;color:#333f4c;line-height:32px'>"
  cErro += " Olá, <span style='color:#3577B0'>Nome do user</span> ! Seja bem vindo.</h1>"
  cErro += " </td>"
  cErro += " </tr>"


  cErro += " <tr>"
  cErro += " <td align='left"
  cErro += " ' bgcolor='#ffffff' style='padding:15px 30px 10px 30px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <p style='padding:0px;color:#333f4c;margin:0;font-size:18px;line-height:28px'>"

  cErro += " Abaixo estão seus dados:"
  cErro += " <br /><br />"
  cErro += " <span style='font-weight:600;color:#3577B0'>Login: </span>Email user<br />"
  cErro += " <span style='font-weight:600;color:#3577B0'>Senha: </span>Senha <br /><br />"

  cErro += " </p>"
  cErro += " </td>"
  cErro += " </tr>"

  cErro += " <tr>"
  cErro += " <td align='center' bgcolor='#ffffff' style='padding:0px 30px 30px 30px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <a href='#' style= 'text-decoration: none; color: #FFF; background-color: #3577B0; border: solid #3577B0; border-width: 5px 10px; line-height: 2; font-weight: bold; text-align: center; cursor: pointer; display: inline-block; border-radius: 5px;'> Ir para o site &raquo;</a>"
  cErro += " </td>"
  cErro += " </tr>"

  cErro += " <tr>"
  cErro += " <td align='left"
  cErro += " ' bgcolor='#FAFAFA' style='padding:30px 30px 30px 30px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <p style='padding:0px;color:#333f4c;margin:0;font-size:14px;line-height:22px'>"
  cErro += " Recomendamos após o primeiro acesso mudar a senha."
  cErro += " </p>"
  cErro += " </td>"
  cErro += " </tr>"
  cErro += " </tbody>"
  cErro += " </table>"
  cErro += " </td>"
  cErro += " </tr> "




  cErro += " <tr>
  cErro += " <td align='left' bgcolor='#ffffff' style='padding:20px 20px 0px 20px;font-family:&#39;proxima-nova&#39;,sans-serif'>"
  cErro += " <p style='padding:0px;color:#7e8790;margin:0;font-size:14px;line-height:24px;text-align:center'>"
  cErro += " Enviado por <span style='font-weight:600;color:#3577B0'>TESTER</span>.<br /> <span style='font-weight:600;color:#3577B0'>TESTER SEND</span>"
  cErro += " </p>"
  cErro += " </td>"
  cErro += " </tr>"



  cErro += " </tbody>  "
  cErro += " </table>  "
  cErro += " </td> "
  cErro += " </tr> "
  cErro += " </tbody>  "
  cErro += " </table>  "
  cErro += " </div> "
  cErro += " </body> "
  cErro += " </html>   "




  U_BIAEnvMail(,cMail,'Error Subject',cErro)

Return

Static Function TSTFIL002()


  Local cSQL := ""
  Local cQry := GetNextAlias()
  Local cHtml := ""
  Local  cMail :=  "filipe.bittencourt@facilesistemas.com.br" //"filipe.bittencourt@facilesistemas.com.br;nadine.araujo@biancogres.com.br"
  Local lErro := .F.


  cSQL := " select   " + CRLF
  cSQL += "   'LM COMERCIO' as EMPRESA,  " + CRLF
  cSQL += "   C5_FILIAL,  " + CRLF
  cSQL += "   C5_NUM,  " + CRLF
  cSQL += "   C5_CLIENTE,  " + CRLF
  cSQL += "   C5_YPEDORI ,  " + CRLF
  cSQL += "   C5_YEMPPED AS 'REPLICADO' ,  " + CRLF
  cSQL += "   C5_YLINHA AS 'LINHA DO PRODUTO',   " + CRLF
  cSQL += "   C5_EMISSAO+' '+C5_YHORA as hora,  " + CRLF
  cSQL += "   C5_YENVIO, C5_YFORMA, C5_YCONF,  " + CRLF
  cSQL += "   C5_EMISSAO, C5_CONDPAG, C5_YCONF, C5_YAPROV, C5_YAAPROV, C5_YUSCONF, C5_YHORA, C5_YPEDORI, C5_YENVIO  " + CRLF
  cSQL += "   from SC5070  SC5 with (nolock)   " + CRLF
  cSQL += "   where 1=1   " + CRLF
  cSQL += "   AND C5_FILIAL	  IN ('01','02','03','04','05','06')  " + CRLF
  cSQL += "   AND C5_EMISSAO >= '20200101'  " + CRLF
  cSQL += "   AND D_E_L_E_T_	= ''  " + CRLF
  cSQL += "   AND C5_CONDPAG	IN ('000', '208')  " + CRLF
  cSQL += "   AND C5_TIPO		= 'N'       " + CRLF
  cSQL += "   AND C5_YCONF		= 'S'   " + CRLF
  cSQL += "   AND C5_YENVIO		= 'N'   " + CRLF
  cSQL += "   AND C5_YPEDORI	<> ''       " + CRLF
  cSQL += "   AND C5_YHORA		<> ''   " + CRLF
  cSQL += "   AND C5_NOTA		= ''        " + CRLF
  cSQL += "   AND C5_YAPROV     <> ''   " + CRLF

  cSQL += "   and not exists (SELECT E1_NUM FROM SE1070 (nolock)  " + CRLF
  cSQL += "   	where   " + CRLF
  cSQL += "   	E1_FILIAL IN ('01','02','03','04','05','06') " + CRLF
  cSQL += " 	AND E1_CLIENTE	= C5_CLIENTE   " + CRLF
  cSQL += "   	AND E1_LOJA		= C5_LOJACLI     " + CRLF
  cSQL += " 	AND E1_PREFIXO	=   'PR'+C5_YLINHA   " + CRLF
  cSQL += "   	and E1_PEDIDO = C5_NUM    	     " + CRLF
  cSQL += "   	AND D_E_L_E_T_			= '' )   " + CRLF
  cSQL += "  order by R_E_C_N_O_ DESC              " + CRLF

  TcQuery cSQL New Alias (cQry)

  cHtml := " <html>"
  cHtml += " <body>"

  cHtml += " <div style='margin:0;padding:0;background-color:#ffffff;height:100%'>"

  cHtml += " <table border='1' cellpadding='0' cellspacing='0' width='100%' style='background-color:#ffffff;overflow-x:hidden'>"
  cHtml += " <tr>"
  cHtml += " <td>EMPRESA</td>"
  cHtml += " <td>FILIAL</td>"
  cHtml += " <td>CLIENTE</td>"
  cHtml += " <td>NUM. PV</td>"
  cHtml += " <td>NUM. PV. FABRICA</td>"
  cHtml += " <td>DATA</td>"
  cHtml += " </tr>"

  While (cQry)->(!EOF())
    lErro := .T.
    cHtml += " <tr>"
    cHtml += " <td>"+(cQry)->(EMPRESA)+"</td>"
    cHtml += " <td>"+(cQry)->(C5_FILIAL)+"</td>"
    cHtml += " <td>"+(cQry)->(C5_CLIENTE)+"</td>"
    cHtml += " <td>"+(cQry)->(C5_NUM)+"</td>"
    cHtml += " <td>"+(cQry)->(C5_YPEDORI)+"</td>"
    cHtml += " <td>"+(cQry)->(hora)+"</td>"
    cHtml += " </tr>"

    (cQry)->(DBSkip())

  EndDo

  cHtml += " </table> "
  cHtml += " </div> "
  cHtml += " </body> "
  cHtml += " </html>   "

  if lErro
    U_BIAEnvMail(,cMail,'Erro Geração de Titulos de Pedidos Antecipados',cHtml)
  Endif

Return


Static Function TSTFIL003()

  Local cQuery    := ""
  Local cQry      := GetNextAlias()
  Local lRet      := .F.
  Local c5Num     := "V0339"
  Local c6Item    := "02"

  X31UPDTABLE('SC6')

  cQuery += " SELECT ZZW.ZZW_FILIAL, ZZW.ZZW_PEDIDO, ZZW.ZZW_ITEM , ZZW.ZZW_CCLI,  ZZW.ZZW_LCLI, ZZW.ZZW_CARGA " + CRLF
  cQuery += " FROM  "+RetSQLName("ZZW")+"  ZZW " + CRLF

  cQuery += " INNER JOIN "+RetSQLName("SC6")+" SC6 ON SC6.C6_FILIAL = ZZW.ZZW_FILIAL " + CRLF
  cQuery += " AND SC6.C6_NUM = ZZW.ZZW_PEDIDO " + CRLF
  cQuery += " AND SC6.C6_ITEM = ZZW.ZZW_ITEM " + CRLF
  cQuery += " AND SC6.D_E_L_E_T_ = '' " + CRLF

  cQuery += " WHERE ZZW.ZZW_FILIAL = '"+FWxFilial('SC6')+"' " + CRLF
  cQuery += " AND ZZW.ZZW_PEDIDO = '"+c5Num+"' " + CRLF
  cQuery += " AND ZZW.ZZW_ITEM = '"+c6Item+"' " + CRLF
  cQuery += " AND ZZW.D_E_L_E_T_ = '' " + CRLF

  TcQuery cQuery New Alias (cQry)


  If !EMPTY((cQry)->ZZW_PEDIDO)
    lRet := .T.
  EndIf

  (cQry)->(DbCloseArea())

  if lRet

    MSGTXT("Não será possível eliminar resíduo do pedido <b>"+c5Num+"</b>, pois o item <b>"+c6Item+"</b> se econtra  em carga.","Atenção - MT500ANT")
  EndIf

Return lRet




Static Function MSGTXT(cMensagem,cTitulo)

  Local oDlg
  Local oGet
  Local oBtn1
  Local lRet			:= .F.
  Private cTexto 		:= ""

  Default cTitulo := "TESTE MSG"
  Default cMensagem := ""


  //cTexto += 'BLOQUEIO POR REGRAS DE NEGÃ“CIO:' +CRLF + CRLF
  cTexto := cMensagem

  DEFINE MSDIALOG oDlg Title cTitulo From 000,000	To 350,400 Pixel

  @ 005,005 Get oGet VAR cTexto MEMO SIZE 193,150 Of oDlg Pixel READONLY
  oGet:bRClicked := {||AllwaysTrue()}

  //oBtn1     := TButton():New( 020,160,"Cancelar",oDlg,{|| oDlg:End()},040,012,,,,.T.,,"",,,,.F. )

  ACTIVATE MSDIALOG oDlg CENTER

Return lRet