using iText.Layout;
using iText.Kernel.Pdf;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using iText.Html2pdf;

namespace Facile.Financeiro.BoletoNetCore.Util
{
    public static class PDFUtil
    {
        public static byte[] GetPDF(string pHTML)
        {
            using (var workStream = new MemoryStream())
            {
                using (var pdfWriter = new PdfWriter(workStream))
                {
                    //Gera o documento PDF do HTML e retorna ele aberto
                    var document = HtmlConverter.ConvertToDocument(pHTML, pdfWriter);

                    document.Close();
                    //Returns the written-to MemoryStream containing the PDF.   
                    return workStream.ToArray();
                }
            }
        }
    }
}
