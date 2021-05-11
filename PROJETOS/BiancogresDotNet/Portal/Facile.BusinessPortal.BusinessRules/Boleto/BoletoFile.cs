using Facile.BusinessPortal.Library.Structs.Interna;
using Facile.Financeiro.BoletoNetCore;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.IO.Compression;
using PdfSharpCore.Pdf.Security;
using PdfSharpCore.Pdf.IO;
using PdfSharpCore.Pdf;

namespace Facile.BusinessPortal.BusinessRules.Boleto
{
    public static class BoletoFile
    {
        public static byte[] GetByte(List<Financeiro.BoletoNetCore.Boleto> boletoList)
        {
            boletoList = boletoList.OrderBy(b => b.NumeroDocumento).ToList();

            var html = new StringBuilder();

            foreach (var boleto in boletoList)
            {
                using (var boletoParaImpressao = new BoletoBancario
                {
                    Boleto = boleto,
                    OcultarInstrucoes = false,
                    MostrarComprovanteEntrega = false,
                    MostrarEnderecoCedente = true,
                    ExibirDemonstrativo = true
                })
                {
                    if (html.Length > 0)
                        html.Append("<h1 style='page-break-before: always'></h1>");

                    html.Append(boletoParaImpressao.MontaHtmlEmbedded(true, true));
                }
            }

            var pdf = Financeiro.BoletoNetCore.Util.PDFUtil.GetPDF(html.ToString());
            return pdf;
        }

        public static void RenderBrowserPDF(List<Financeiro.BoletoNetCore.Boleto> boletoList, HttpContext httpContext)
        {
            var pdf = GetByte(boletoList);
            var nomeBase = "FBOLETO";
            var fileName = nomeBase.ToUpper().Trim() + "_" + DateTime.Now.ToString("yyyy-MM-dd") + ".pdf";

            httpContext.Response.Clear();
            httpContext.Response.ContentType = "application/pdf";
            httpContext.Response.Headers.Add("x-filename", fileName);
            httpContext.Response.Headers.Add("Access-Control-Expose-Headers", "x-filename");
            httpContext.Response.Body.Write(pdf.ToArray(), 0, pdf.ToArray().Length);
        }

        public static BoletoPDF GetPDF(List<Financeiro.BoletoNetCore.Boleto> boletoList, string nomeBaseArquivo = "", bool createZip = false, bool filepassword = false)
        {
            // Gera arquivo PDF
            try
            {
                var boletoPDF = new BoletoPDF();

                if (boletoList.Count <= 0)
                {
                    return boletoPDF;
                }

                var pdf = GetByte(boletoList);

                var doc = boletoList.First().NumeroDocumento;
                var sacado = boletoList.First().Sacado;
                if (boletoList.Count >= 2)
                {
                    doc += "_" + boletoList.Last().NumeroDocumento;
                }

                var fileName = (!string.IsNullOrWhiteSpace(nomeBaseArquivo) ? nomeBaseArquivo.ToUpper().Trim() + "_" : "") + doc + "_" + DateTime.Now.ToString("yyyy-MM-dd") + ".pdf";
                var filePath = Path.GetTempPath();

                if (File.Exists(filePath + @"\" + fileName))
                {
                    File.Delete(filePath + @"\" + fileName);
                }

                var fileNameZipDel = (!string.IsNullOrWhiteSpace(nomeBaseArquivo) ? nomeBaseArquivo.ToUpper().Trim() + "_" : "") + doc + "_" + DateTime.Now.ToString("yyyy-MM-dd") + ".zip";

                if (File.Exists(filePath + @"\" + fileNameZipDel))
                {
                    File.Delete(filePath + @"\" + fileNameZipDel);
                }

                FileStream fs = new FileStream(filePath + @"\" + fileName, FileMode.OpenOrCreate);
                fs.Write(pdf, 0, pdf.Length);
                fs.Close();

                if (filepassword)
                {
                    PdfDocument document = PdfReader.Open(filePath + @"\" + fileName, "");

                    PdfSecuritySettings securitySettings = document.SecuritySettings;

                    securitySettings.UserPassword = sacado.CPFCNPJ.Substring(0, 4);
                    securitySettings.OwnerPassword = sacado.CPFCNPJ.Substring(0, 4);

                    // Restrict some rights.
                    securitySettings.PermitAccessibilityExtractContent = false;
                    securitySettings.PermitAnnotations = false;
                    securitySettings.PermitAssembleDocument = false;
                    securitySettings.PermitExtractContent = false;
                    securitySettings.PermitFormsFill = false;
                    securitySettings.PermitModifyDocument = false;

                    securitySettings.PermitFullQualityPrint = true;
                    securitySettings.PermitPrint = true;

                    document.Save(filePath + @"\" + fileName);
                }

                boletoPDF.Pdf = pdf;
                boletoPDF.FileName = fileName;
                boletoPDF.FilePath = filePath;
                boletoPDF.FileNameZip = "";

                if (createZip)
                {
                    var caminhoArquivo = filePath + @"\" + fileName;
                    var fileNameZip = (!string.IsNullOrWhiteSpace(nomeBaseArquivo) ? nomeBaseArquivo.ToUpper().Trim() + "_" : "") + doc + "_" + DateTime.Now.ToString("yyyy-MM-dd") + ".zip";
                    var caminhoZip = filePath + @"\" + fileNameZip;

                    if (File.Exists(caminhoZip))
                    {
                        File.Delete(caminhoZip);
                    }

                    using (ZipArchive zip = ZipFile.Open(caminhoZip, ZipArchiveMode.Create))
                    {
                        zip.CreateEntryFromFile(caminhoArquivo, fileName);
                    }

                    boletoPDF.FileNameZip = fileNameZip;
                }

                return boletoPDF;
            }
            catch (Exception ex)
            {
                throw new Exception("Erro criação PDF: " + ex);
            }

        }

    }
}
